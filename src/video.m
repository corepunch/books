#include "book.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>

/* One clip at a time, drawn into the page picture. Smoke captures stay on the poster
 * so a transition check is not racing the decoder. */

static AVPlayer *player;
static AVPlayerItemVideoOutput *output;
static id endObserver;
static filePath_t openPath;
static isize2_t frameSize;
static int sliceFrom, sliceTo;
static bool posterOnly, primed, ended, looping;

void video_use_poster(bool poster) { posterOnly = poster; }

bool video_playing(void) { return !posterOnly && player && !ended; }
bool video_ended(void) { return !posterOnly && player && ended; }

void video_close(void)
{
    if (endObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:endObserver];
        endObserver = nil;
    }
    [player pause];
    player = nil;
    output = nil;
    openPath[0] = 0;
    frameSize = isize2(0, 0);
    primed = false;
    ended = false;
    renderer_video_discard();
}

bool video_open(const char *path, int from_ms, int to_ms, bool loop)
{
    if (posterOnly || !path || !*path) return false;
    if (player && !strcmp(openPath, path) && sliceFrom == from_ms && sliceTo == to_ms && looping == loop) return true;
    video_close();
    sliceFrom = from_ms;
    sliceTo = to_ms;
    looping = loop;
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:path]];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:@{
        (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)
    }];
    output.suppressesPlayerRendering = YES;
    [item addOutput:output];
    /* A slice ends at its out point; reaching it posts the same end notification. */
    if (to_ms > 0) item.forwardPlaybackEndTime = CMTimeMake(to_ms, 1000);
    player = [AVPlayer playerWithPlayerItem:item];
    player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    copy(openPath, sizeof(openPath), path);
#if TARGET_OS_IPHONE
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
#endif
    endObserver = [[NSNotificationCenter defaultCenter]
        addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:item
        queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
            (void)note;
            if (looping) {
                [player seekToTime:CMTimeMake(sliceFrom, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                [player play];
            } else ended = true;
        }];
    if (from_ms > 0)
        [player seekToTime:CMTimeMake(from_ms, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [player play];
    return true;
}

bool video_frame(frect_t viewport)
{
    if (posterOnly || !player || !output) return false;
    AVPlayerItem *item = player.currentItem;
    if (item.status == AVPlayerItemStatusFailed) {
        ended = true;
        return false;
    }
    CMTime host = [output itemTimeForHostTime:CACurrentMediaTime()];
    if ([output hasNewPixelBufferForItemTime:host]) {
        CVPixelBufferRef buffer = [output copyPixelBufferForItemTime:host itemTimeForDisplay:NULL];
        if (buffer) {
            CVPixelBufferLockBaseAddress(buffer, kCVPixelBufferLock_ReadOnly);
            const void *pixels = CVPixelBufferGetBaseAddress(buffer);
            int width = (int)CVPixelBufferGetWidth(buffer);
            int height = (int)CVPixelBufferGetHeight(buffer);
            int stride = (int)CVPixelBufferGetBytesPerRow(buffer);
            if (pixels && width > 0 && height > 0 && stride >= width * 4) {
                frameSize = isize2(width, height);
                primed = renderer_video(pixels, frameSize, stride,
                                        frect_cover(isize2_to_float(frameSize), viewport));
            }
            CVPixelBufferUnlockBaseAddress(buffer, kCVPixelBufferLock_ReadOnly);
            CVPixelBufferRelease(buffer);
        }
    } else if (primed) {
        renderer_video(NULL, isize2(0, 0), 0, frect_cover(isize2_to_float(frameSize), viewport));
    }
    return primed;
}
