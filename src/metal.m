#include "book.h"

#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>
#import <simd/simd.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

/* This layout is shared with the embedded Metal shader below. */
struct DrawUniforms {
    frect_t bounds;
    fsize2_t viewport;
    fvec2_t center;
    vector_float4 color;
    float radius;
    int mode, reveal;
    float scale;
    fvec2_t line_start, line_end;
    float corner, stroke;
};

static struct {
    id<MTLDevice> device;
    id<MTLCommandQueue> queue;
    id<MTLRenderPipelineState> pipeline;
    CAMetalLayer *layer;
    id<CAMetalDrawable> drawable;
    id<MTLCommandBuffer> command, last_command;
    id<MTLRenderCommandEncoder> encoder;
    id<MTLTexture> white;
    isize2_t viewport, framebuffer;
    float scale, opacity, radius;
    fvec2_t center;
    bool reveal, clipped_out;
} m;

bool renderer_init(void *layer)
{
    m.layer = (__bridge CAMetalLayer *)layer;
    m.device = MTLCreateSystemDefaultDevice();
    if (!m.device) return fprintf(stderr, "Metal is unavailable\n"), false;
    m.queue = [m.device newCommandQueue];
    m.layer.device = m.device;
    m.layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    /* Smoke captures blit the drawable to a CPU-readable buffer. */
    m.layer.framebufferOnly = NO;
    m.layer.opaque = YES;
    CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    m.layer.colorspace = colorspace;
    CGColorSpaceRelease(colorspace);
    NSString *source = @"#include <metal_stdlib>\n"
        "using namespace metal;\n"
        "struct Draw { float4 bounds; float2 viewport; float2 center; float4 color; "
        "float radius; int mode; int reveal; float scale; float2 line_start; float2 line_end; float corner; float stroke; };\n"
        "struct Vertex { float4 position [[position]]; float2 uv; };\n"
        "vertex Vertex book_vertex(uint i [[vertex_id]], constant Draw &d [[buffer(0)]]) {"
        "const float2 corners[] = {float2(0,0),float2(1,0),float2(1,1),"
        "float2(0,0),float2(1,1),float2(0,1)};"
        "float2 p=d.bounds.xy+corners[i]*d.bounds.zw;"
        "return {float4(p.x/d.viewport.x*2-1,1-p.y/d.viewport.y*2,0,1),corners[i]}; }\n"
        "fragment float4 book_fragment(Vertex v [[stage_in]], constant Draw &d [[buffer(0)]],"
        "texture2d<float> image [[texture(0)]]) {"
        "if(d.reveal && (d.radius<=0 || distance(v.position.xy/d.scale,d.center)>d.radius)) discard_fragment();"
        "if(d.mode==2) { float r=length(v.uv-float2(.5)); float aa=fwidth(r);"
        "float a=(1-smoothstep(.5-aa,.5,r))*smoothstep(.4375-aa,.4375+aa,r);"
        "return float4(d.color.rgb,d.color.a*a); }"
        "if(d.mode==4) { float2 half_size=d.bounds.zw*.5; float2 q=abs((v.uv-.5)*d.bounds.zw)-half_size+d.corner;"
        "float dist=length(max(q,0.0))+min(max(q.x,q.y),0.0)-d.corner; float aa=fwidth(dist);"
        "float a=1-smoothstep(-aa,aa,dist);"
        "if(d.stroke>0) a*=smoothstep(-d.stroke-aa,-d.stroke+aa,dist);"
        "return float4(d.color.rgb,d.color.a*a); }"
        "if(d.mode==3) { float2 delta=d.line_end-d.line_start;"
        "float2 p=v.position.xy/d.scale-d.line_start;"
        "float along=clamp(dot(p,delta)/max(dot(delta,delta),.001),0.0,1.0);"
        "float a=1-smoothstep(.5,1.5,length(p-along*delta));"
        "return float4(d.color.rgb,d.color.a*a); }"
        "constexpr sampler linear_sampler(coord::normalized,address::clamp_to_edge,filter::linear);"
        "float4 s=image.sample(linear_sampler,v.uv);"
        "return d.color*(d.mode==1?float4(1,1,1,s.r):s); }\n";
    NSError *error = nil;
    id<MTLLibrary> library = [m.device newLibraryWithSource:source options:nil error:&error];
    if (!library) return fprintf(stderr, "Metal shader: %s\n", error.localizedDescription.UTF8String), false;
    MTLRenderPipelineDescriptor *pipeline = [MTLRenderPipelineDescriptor new];
    pipeline.label = @"Book images, text and hotspots";
    pipeline.vertexFunction = [library newFunctionWithName:@"book_vertex"];
    pipeline.fragmentFunction = [library newFunctionWithName:@"book_fragment"];
    MTLRenderPipelineColorAttachmentDescriptor *color = pipeline.colorAttachments[0];
    color.pixelFormat = m.layer.pixelFormat;
    color.blendingEnabled = YES;
    color.sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    color.destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    color.sourceAlphaBlendFactor = MTLBlendFactorOne;
    color.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    m.pipeline = [m.device newRenderPipelineStateWithDescriptor:pipeline error:&error];
    if (!m.pipeline) return fprintf(stderr, "Metal pipeline: %s\n", error.localizedDescription.UTF8String), false;
    const unsigned char white[] = {255, 255, 255, 255};
    texture_t texture = renderer_texture_create(isize2(1, 1), false, white);
    m.white = (__bridge_transfer id<MTLTexture>)texture;
    return m.queue && m.white;
}

texture_t renderer_texture_create(isize2_t size, bool glyph, const void *pixels)
{
    if (isize2_is_empty(size)) return NULL;
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:
        glyph ? MTLPixelFormatR8Unorm : MTLPixelFormatRGBA8Unorm
        width:size.width height:size.height mipmapped:NO];
    desc.usage = MTLTextureUsageShaderRead;
    desc.storageMode = MTLStorageModeShared;
    id<MTLTexture> texture = [m.device newTextureWithDescriptor:desc];
    if (!texture) fail("cannot allocate Metal texture (%d x %d)", size.width, size.height);
    [texture replaceRegion:MTLRegionMake2D(0, 0, size.width, size.height) mipmapLevel:0
        withBytes:pixels bytesPerRow:(size_t)size.width * (glyph ? 1 : 4)];
    return (__bridge_retained void *)texture;
}

void renderer_texture_destroy(texture_t texture)
{
    if (texture) { id released = (__bridge_transfer id)texture; (void)released; }
}

static void check_command(id<MTLCommandBuffer> command)
{
    if (command.status == MTLCommandBufferStatusError)
        fail("Metal command failed: %s", command.error.localizedDescription.UTF8String);
}

bool renderer_begin(isize2_t size, float scale)
{
    check_command(m.last_command);
    if (isize2_is_empty(size)) return false;
    m.viewport = size;
    m.scale = scale > 0 ? scale : 1;
    m.framebuffer = fsize2_round(fsize2_scale(isize2_to_float(size), m.scale));
    m.layer.contentsScale = m.scale;
    m.layer.drawableSize = CGSizeMake(m.framebuffer.width, m.framebuffer.height);
    m.drawable = [m.layer nextDrawable];
    if (!m.drawable) return false;
    m.command = [m.queue commandBuffer];
    MTLRenderPassDescriptor *pass = [MTLRenderPassDescriptor renderPassDescriptor];
    pass.colorAttachments[0].texture = m.drawable.texture;
    pass.colorAttachments[0].loadAction = MTLLoadActionClear;
    pass.colorAttachments[0].storeAction = MTLStoreActionStore;
    pass.colorAttachments[0].clearColor = MTLClearColorMake(.965, .949, .918, 1);
    m.encoder = [m.command renderCommandEncoderWithDescriptor:pass];
    if (!m.encoder) fail("cannot begin Metal frame");
    [m.encoder setRenderPipelineState:m.pipeline];
    [m.encoder setViewport:(MTLViewport){0, 0, m.framebuffer.width, m.framebuffer.height, 0, 1}];
    renderer_unclip();
    renderer_reveal_end();
    renderer_opacity(1);
    return true;
}

void renderer_clip(frect_t bounds)
{
    frect_t pixels = frect_scale(frect_intersection(bounds, renderer_bounds()), m.scale);
    ivec2_t start = fvec2_floor(pixels.origin);
    fvec2_t corner = frect_bottom_right(pixels);
    ivec2_t end = ivec2((int)ceilf(corner.x), (int)ceilf(corner.y));
    m.clipped_out = fsize2_is_empty(pixels.size);
    if (!m.clipped_out) [m.encoder setScissorRect:(MTLScissorRect){
        (NSUInteger)start.x, (NSUInteger)start.y,
        (NSUInteger)(end.x-start.x), (NSUInteger)(end.y-start.y)}];
}

void renderer_unclip(void)
{
    m.clipped_out = false;
    [m.encoder setScissorRect:(MTLScissorRect){0, 0, m.framebuffer.width, m.framebuffer.height}];
}

static void draw_quad(frect_t bounds, uint32_t rgba, texture_t texture, int glyph,
                       fvec2_t line_start, fvec2_t line_end, float corner, float stroke)
{
    if (!m.encoder || m.clipped_out || !frect_overlaps(bounds, renderer_bounds())) return;
    struct DrawUniforms draw = {
        .bounds = bounds, .viewport = isize2_to_float(m.viewport), .center = m.center,
        .color = {((rgba >> 24) & 255)/255.f, ((rgba >> 16) & 255)/255.f,
                  ((rgba >> 8) & 255)/255.f, (rgba & 255)/255.f * m.opacity},
        .radius = m.radius, .mode = glyph, .reveal = m.reveal, .scale = m.scale,
        .line_start = line_start, .line_end = line_end, .corner = corner, .stroke = stroke
    };
    [m.encoder setVertexBytes:&draw length:sizeof(draw) atIndex:0];
    [m.encoder setFragmentBytes:&draw length:sizeof(draw) atIndex:0];
    [m.encoder setFragmentTexture:texture ? (__bridge id<MTLTexture>)texture : m.white atIndex:0];
    [m.encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

void renderer_quad(frect_t bounds, uint32_t rgba, texture_t texture, int glyph)
{
    draw_quad(bounds,rgba,texture,glyph,fvec2(0,0),fvec2(0,0),0,0);
}

void renderer_line(fvec2_t start, fvec2_t end, uint32_t rgba)
{
    frect_t bounds=frect(fvec2(fminf(start.x,end.x)-2,fminf(start.y,end.y)-2),
                         fsize2(fabsf(end.x-start.x)+4,fabsf(end.y-start.y)+4));
    draw_quad(bounds,rgba,NULL,3,start,end,0,0);
}

void renderer_rect(frect_t bounds, uint32_t rgba) { renderer_quad(bounds, rgba, NULL, 0); }
void renderer_ring(frect_t bounds, uint32_t rgba) { renderer_quad(bounds, rgba, NULL, 2); }
void renderer_round_rect(frect_t bounds, float corner, float stroke, uint32_t rgba)
{
    corner = fminf(corner, fminf(bounds.size.width, bounds.size.height) / 2);
    draw_quad(bounds, rgba, NULL, 4, fvec2(0, 0), fvec2(0, 0), corner, stroke);
}
void renderer_opacity(float opacity) { m.opacity = fminf(1, fmaxf(0, opacity)); }
void renderer_reveal_begin(fvec2_t center, float radius)
{
    m.center = center; m.radius = radius; m.reveal = true;
}
void renderer_reveal_end(void) { m.reveal = false; }
frect_t renderer_bounds(void) { return frect_from_size(isize2_to_float(m.viewport)); }

void renderer_present(void)
{
    if (!m.command) return;
    [m.encoder endEncoding];
    m.encoder = nil;
    [m.command presentDrawable:m.drawable];
    [m.command commit];
    m.last_command = m.command;
    m.command = nil;
    m.drawable = nil;
}

bool renderer_screenshot(const char *path)
{
    if (!m.encoder) return false;
    size_t stride = ((size_t)m.framebuffer.width * 4 + 255) & ~(size_t)255;
    id<MTLBuffer> pixels = [m.device newBufferWithLength:stride * m.framebuffer.height options:MTLResourceStorageModeShared];
    if (!pixels) return false;
    [m.encoder endEncoding];
    m.encoder = nil;
    id<MTLBlitCommandEncoder> blit = [m.command blitCommandEncoder];
    [blit copyFromTexture:m.drawable.texture sourceSlice:0 sourceLevel:0 sourceOrigin:MTLOriginMake(0, 0, 0)
        sourceSize:MTLSizeMake(m.framebuffer.width, m.framebuffer.height, 1) toBuffer:pixels destinationOffset:0
        destinationBytesPerRow:stride destinationBytesPerImage:stride * m.framebuffer.height];
    [blit endEncoding];
    renderer_present();
    [m.last_command waitUntilCompleted];
    check_command(m.last_command);
    size_t row_bytes = (size_t)m.framebuffer.width * 3;
    unsigned char *row = malloc(row_bytes);
    if (!row) return false;
    FILE *file = fopen(path, "wb");
    if (!file) return free(row), false;
    bool ok = fprintf(file, "P6\n%d %d\n255\n", m.framebuffer.width, m.framebuffer.height) > 0;
    for (int y = 0; y < m.framebuffer.height && ok; ++y) {
        const unsigned char *src = (const unsigned char *)pixels.contents + y * stride;
        for (int x = 0; x < m.framebuffer.width; ++x) {
            row[x*3] = src[x*4+2]; row[x*3+1] = src[x*4+1]; row[x*3+2] = src[x*4];
        }
        ok = fwrite(row, 1, row_bytes, file) == row_bytes;
    }
    if (fclose(file)) ok = false;
    free(row);
    return ok;
}

void metal_shutdown(void)
{
    [m.last_command waitUntilCompleted];
    check_command(m.last_command);
    m.encoder = nil; m.command = nil; m.last_command = nil; m.drawable = nil;
    m.white = nil; m.pipeline = nil; m.queue = nil; m.layer = nil; m.device = nil;
}
