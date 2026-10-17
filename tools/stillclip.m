/* stillclip: encode one still as a placeholder clip.
 *
 *   stillclip IN.jpg OUT.mp4 SECONDS MARKER
 *
 * The clip is the still for SECONDS, with a thin bar along the bottom that fills as it
 * plays, so a placeholder reads as film in the app. MARKER is written as the movie's
 * description; the book tool finds it near the start of the file (the movie header is
 * written first) and reports the clip as a placeholder. Built by `make placeholders`. */
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <ImageIO/ImageIO.h>

#define CLIP_WIDTH 720
#define CLIP_HEIGHT 480
#define CLIP_FPS 10
#define BAR_HEIGHT 6

static void die(const char *message)
{
    fprintf(stderr, "stillclip: %s\n", message);
    exit(1);
}

static CVPixelBufferRef frame(CVPixelBufferPoolRef pool, CGImageRef still, double progress)
{
    CVPixelBufferRef buffer = NULL;
    if (CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &buffer) != kCVReturnSuccess) die("no pixel buffer");
    CVPixelBufferLockBaseAddress(buffer, 0);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(buffer), CLIP_WIDTH, CLIP_HEIGHT, 8,
        CVPixelBufferGetBytesPerRow(buffer), space, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGContextDrawImage(context, CGRectMake(0, 0, CLIP_WIDTH, CLIP_HEIGHT), still);
    CGContextSetRGBFillColor(context, 1, 1, 1, 0.75);
    CGContextFillRect(context, CGRectMake(0, 0, CLIP_WIDTH * progress, BAR_HEIGHT));
    CGContextRelease(context);
    CGColorSpaceRelease(space);
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return buffer;
}

int main(int argc, char **argv)
{
    @autoreleasepool {
        if (argc != 5) die("usage: stillclip IN.jpg OUT.mp4 SECONDS MARKER");
        double seconds = atof(argv[3]);
        if (!(seconds > 0)) die("SECONDS must be positive");
        NSURL *input = [NSURL fileURLWithPath:@(argv[1])], *output = [NSURL fileURLWithPath:@(argv[2])];
        CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)input, NULL);
        CGImageRef still = source ? CGImageSourceCreateImageAtIndex(source, 0, NULL) : NULL;
        if (!still) die("cannot read the still");
        [[NSFileManager defaultManager] removeItemAtURL:output error:nil];

        NSError *error = nil;
        AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:output fileType:AVFileTypeMPEG4 error:&error];
        if (!writer) die(error.localizedDescription.UTF8String);
        writer.shouldOptimizeForNetworkUse = YES;
        AVMutableMetadataItem *marker = [AVMutableMetadataItem metadataItem];
        marker.keySpace = AVMetadataKeySpaceCommon;
        marker.key = AVMetadataCommonKeyDescription;
        marker.value = @(argv[4]);
        writer.metadata = @[marker];
        AVAssetWriterInput *video = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{
            AVVideoCodecKey: AVVideoCodecTypeH264, AVVideoWidthKey: @(CLIP_WIDTH), AVVideoHeightKey: @(CLIP_HEIGHT),
        }];
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
            assetWriterInputPixelBufferAdaptorWithAssetWriterInput:video sourcePixelBufferAttributes:@{
                (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                (id)kCVPixelBufferWidthKey: @(CLIP_WIDTH), (id)kCVPixelBufferHeightKey: @(CLIP_HEIGHT),
            }];
        [writer addInput:video];
        if (![writer startWriting]) die(writer.error.localizedDescription.UTF8String);
        [writer startSessionAtSourceTime:kCMTimeZero];

        int frames = (int)ceil(seconds * CLIP_FPS);
        for (int i = 0; i <= frames; ++i) {
            while (!video.readyForMoreMediaData) [NSThread sleepForTimeInterval:0.002];
            CVPixelBufferRef buffer = frame(adaptor.pixelBufferPool, still, (double)i / frames);
            if (![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(i, CLIP_FPS)])
                die(writer.error.localizedDescription.UTF8String);
            CVPixelBufferRelease(buffer);
        }
        [video markAsFinished];
        dispatch_semaphore_t done = dispatch_semaphore_create(0);
        [writer finishWritingWithCompletionHandler:^{ dispatch_semaphore_signal(done); }];
        dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);
        if (writer.status != AVAssetWriterStatusCompleted) die(writer.error.localizedDescription.UTF8String);
        CGImageRelease(still);
        CFRelease(source);
    }
    return 0;
}
