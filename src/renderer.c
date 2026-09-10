#include "book.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

static struct {
    GLuint program, vao, vbo, white, image;
    GLint viewport_uniform, color_uniform, glyph_uniform;
    isize2_t viewport, image_size, framebuffer;
    float scale;
    char *image_path;
} r;

GLuint renderer_texture_create(isize2_t size, GLenum format, const void *pixels)
{
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D(GL_TEXTURE_2D, 0, format == GL_RED ? GL_R8 : GL_RGBA8,
                 size.width, size.height, 0, format, GL_UNSIGNED_BYTE, pixels);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    return texture;
}

static GLuint shader_create(GLenum type, const char *source)
{
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    GLint ok;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &ok);
    if (ok) return shader;
    shaderLog_t log;
    glGetShaderInfoLog(shader, sizeof(log), NULL, log);
    fprintf(stderr, "Book shader: %s\n", log);
    glDeleteShader(shader);
    return 0;
}

bool renderer_init(void)
{
    const char *vertex = "#version 150\n"
        "in vec2 position; in vec2 uv; out vec2 texcoord; uniform vec2 viewport;"
        "void main(){texcoord=uv;gl_Position=vec4(position.x/viewport.x*2.-1.,"
        "1.-position.y/viewport.y*2.,0.,1.);}";
    const char *fragment = "#version 150\n"
        "in vec2 texcoord; out vec4 outputColor; uniform sampler2D image;"
        "uniform vec4 color; uniform int glyph;"
        "void main(){if(glyph==2){float d=length(texcoord-vec2(.5));"
        "float aa=fwidth(d);float a=(1.-smoothstep(.5-aa,.5,d))*"
        "smoothstep(.4375-aa,.4375+aa,d);outputColor=vec4(color.rgb,color.a*a);return;}"
        "vec4 s=texture(image,texcoord);"
        "outputColor=color*(glyph==1?vec4(1.,1.,1.,s.r):s);}";
    GLuint vs = shader_create(GL_VERTEX_SHADER, vertex);
    GLuint fs = shader_create(GL_FRAGMENT_SHADER, fragment);
    if (!vs || !fs) {
        glDeleteShader(vs);
        glDeleteShader(fs);
        renderer_shutdown();
        return false;
    }
    r.program = glCreateProgram();
    glAttachShader(r.program, vs);
    glAttachShader(r.program, fs);
    glBindAttribLocation(r.program, 0, "position");
    glBindAttribLocation(r.program, 1, "uv");
    glLinkProgram(r.program);
    glDeleteShader(vs);
    glDeleteShader(fs);
    GLint ok;
    glGetProgramiv(r.program, GL_LINK_STATUS, &ok);
    if (!ok) return renderer_shutdown(), false;
    glUseProgram(r.program);
    r.viewport_uniform = glGetUniformLocation(r.program, "viewport");
    r.color_uniform = glGetUniformLocation(r.program, "color");
    r.glyph_uniform = glGetUniformLocation(r.program, "glyph");
    glUniform1i(glGetUniformLocation(r.program, "image"), 0);
    glGenVertexArrays(1, &r.vao);
    glBindVertexArray(r.vao);
    glGenBuffers(1, &r.vbo);
    glBindBuffer(GL_ARRAY_BUFFER, r.vbo);
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void *)0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void *)(2 * sizeof(float)));
    const unsigned char white[] = {255, 255, 255, 255};
    r.white = renderer_texture_create(isize2(1, 1), GL_RGBA, white);
    return true;
}

void renderer_resize(isize2_t size, float scale)
{
    r.viewport = isize2_max(size, isize2(1, 1));
    r.scale = scale > 0 ? scale : 1;
    r.framebuffer = fsize2_round(fsize2_scale(isize2_to_float(r.viewport), r.scale));
    glViewport(0, 0, r.framebuffer.width, r.framebuffer.height);
}

void renderer_clip(frect_t bounds)
{
    frect_t pixels = frect_scale(frect_flip_y(bounds, (float)r.viewport.height), r.scale);
    irect_t scissor = irect(fvec2_floor(pixels.origin),
                          fsize2_ceil(fsize2_max(pixels.size, fsize2(0, 0))));
    glEnable(GL_SCISSOR_TEST);
    glScissor(scissor.origin.x, scissor.origin.y, scissor.size.width, scissor.size.height);
}

void renderer_unclip(void) { glDisable(GL_SCISSOR_TEST); }

bool renderer_screenshot(const char *path)
{
    if (isize2_is_empty(r.framebuffer)) return false;
    size_t stride = (size_t)r.framebuffer.width * 3;
    unsigned char *pixels = malloc(stride * r.framebuffer.height);
    if (!pixels) return false;
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(0, 0, r.framebuffer.width, r.framebuffer.height, GL_RGB, GL_UNSIGNED_BYTE, pixels);
    FILE *file = fopen(path, "wb");
    if (!file) return free(pixels), false;
    bool ok = fprintf(file, "P6\n%d %d\n255\n", r.framebuffer.width, r.framebuffer.height) > 0;
    for (int y = r.framebuffer.height - 1; y >= 0 && ok; --y)
        ok = fwrite(pixels + y * stride, 1, stride, file) == stride;
    if (fclose(file)) ok = false;
    free(pixels);
    return ok;
}

void renderer_clear(void)
{
    renderer_unclip();
    glClearColor(0.965f, 0.949f, 0.918f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glUseProgram(r.program);
    glBindVertexArray(r.vao);
    glBindBuffer(GL_ARRAY_BUFFER, r.vbo);
    glActiveTexture(GL_TEXTURE0);
    glUniform2f(r.viewport_uniform, (float)r.viewport.width, (float)r.viewport.height);
}

void renderer_quad(frect_t bounds, uint32_t rgba, GLuint texture, int glyph)
{
    if (!frect_overlaps(bounds, renderer_bounds())) return;
    fvec2_t start = bounds.origin, end = frect_bottom_right(bounds);
    const float vertices[] = {
        start.x,start.y,0,0, end.x,start.y,1,0, end.x,end.y,1,1,
        start.x,start.y,0,0, end.x,end.y,1,1, start.x,end.y,0,1
    };
    glUniform4f(r.color_uniform, ((rgba >> 24) & 255) / 255.f,
                ((rgba >> 16) & 255) / 255.f, ((rgba >> 8) & 255) / 255.f,
                (rgba & 255) / 255.f);
    glUniform1i(r.glyph_uniform, glyph);
    glBindTexture(GL_TEXTURE_2D, texture);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STREAM_DRAW);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

void renderer_rect(frect_t bounds, uint32_t rgba)
{
    renderer_quad(bounds, rgba, r.white, false);
}

void renderer_ring(frect_t bounds, uint32_t rgba)
{
    renderer_quad(bounds, rgba, r.white, 2);
}

static bool image_load(const char *path)
{
    if (!path) return false;
    if (r.image_path && !strcmp(path, r.image_path)) return r.image != 0;
    glDeleteTextures(1, &r.image);
    r.image = 0;
    free(r.image_path);
    r.image_path = malloc(strlen(path) + 1);
    if (r.image_path) strcpy(r.image_path, path);
    int channels;
    unsigned char *pixels = stbi_load(path, &r.image_size.width, &r.image_size.height, &channels, 4);
    if (!pixels) return fprintf(stderr, "Cannot load image %s: %s\n", path, stbi_failure_reason()), false;
    r.image = renderer_texture_create(r.image_size, GL_RGBA, pixels);
    stbi_image_free(pixels);
    return true;
}

isize2_t renderer_image_size(const char *path)
{
    return image_load(path) ? r.image_size : isize2(0, 0);
}

bool renderer_image(const char *path, frect_t bounds)
{
    if (!image_load(path)) return false;
    renderer_quad(bounds, 0xffffffff, r.image, false);
    return true;
}

void renderer_shutdown(void)
{
    glDeleteTextures(1, &r.white);
    glDeleteTextures(1, &r.image);
    glDeleteBuffers(1, &r.vbo);
    glDeleteVertexArrays(1, &r.vao);
    if (r.program) glDeleteProgram(r.program);
    free(r.image_path);
    memset(&r, 0, sizeof(r));
}

void renderer_invalidate_image(void)
{
    free(r.image_path);
    r.image_path = NULL;
}

frect_t renderer_bounds(void) { return frect_from_size(isize2_to_float(r.viewport)); }
