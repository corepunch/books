#include "render.h"

#ifdef __APPLE__
#ifndef GL_SILENCE_DEPRECATION
#define GL_SILENCE_DEPRECATION
#endif
#include <OpenGL/gl3.h>
#else
#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <GL/glext.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>
#define STB_TRUETYPE_IMPLEMENTATION
#include <stb_truetype.h>

#define GLYPH_COUNT 512
#define FONT_PIXELS 48.0f

struct Glyph {
    int codepoint, x, y, width, height;
    float advance;
    GLuint texture;
};

static struct {
    GLuint program, vao, vbo, white, image;
    GLint viewport_uniform, color_uniform, glyph_uniform;
    int width, height, image_width, image_height, glyph_count;
    int framebuffer_width, framebuffer_height;
    float scale;
    char *image_path;
    unsigned char *font_data;
    stbtt_fontinfo font;
    float font_scale, ascent, line_height;
    struct Glyph glyphs[GLYPH_COUNT];
} r;

static GLuint texture_create(int width, int height, GLenum format, const void *pixels)
{
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D(GL_TEXTURE_2D, 0, format == GL_RED ? GL_R8 : GL_RGBA8,
                 width, height, 0, format, GL_UNSIGNED_BYTE, pixels);
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
    char log[2048];
    glGetShaderInfoLog(shader, sizeof(log), NULL, log);
    fprintf(stderr, "Book shader: %s\n", log);
    glDeleteShader(shader);
    return 0;
}

bool renderer_init(const char *font_path)
{
    FILE *file = fopen(font_path, "rb");
    if (!file) return fprintf(stderr, "Cannot open font: %s\n", font_path), false;
    fseek(file, 0, SEEK_END);
    long bytes = ftell(file);
    rewind(file);
    r.font_data = bytes > 0 ? malloc((size_t)bytes) : NULL;
    bool loaded = r.font_data && fread(r.font_data, 1, (size_t)bytes, file) == (size_t)bytes;
    fclose(file);
    if (!loaded || !stbtt_InitFont(&r.font, r.font_data, 0)) {
        renderer_shutdown();
        return false;
    }
    r.font_scale = stbtt_ScaleForPixelHeight(&r.font, FONT_PIXELS);
    int ascent, descent, gap;
    stbtt_GetFontVMetrics(&r.font, &ascent, &descent, &gap);
    r.ascent = ascent * r.font_scale;
    r.line_height = (ascent - descent + gap) * r.font_scale;
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
    r.white = texture_create(1, 1, GL_RGBA, white);
    return true;
}

void renderer_resize(int width, int height, float scale)
{
    r.width = width > 0 ? width : 1;
    r.height = height > 0 ? height : 1;
    r.scale = scale > 0 ? scale : 1;
    r.framebuffer_width = (int)lroundf(r.width * r.scale);
    r.framebuffer_height = (int)lroundf(r.height * r.scale);
    glViewport(0, 0, r.framebuffer_width, r.framebuffer_height);
}

void renderer_clip(float x, float y, float width, float height)
{
    glEnable(GL_SCISSOR_TEST);
    glScissor((int)floorf(x * r.scale), (int)floorf((r.height - y - height) * r.scale),
              (int)fmaxf(0, ceilf(width * r.scale)), (int)fmaxf(0, ceilf(height * r.scale)));
}

void renderer_unclip(void) { glDisable(GL_SCISSOR_TEST); }

bool renderer_screenshot(const char *path)
{
    if (r.framebuffer_width <= 0 || r.framebuffer_height <= 0) return false;
    size_t stride = (size_t)r.framebuffer_width * 3;
    unsigned char *pixels = malloc(stride * r.framebuffer_height);
    if (!pixels) return false;
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(0, 0, r.framebuffer_width, r.framebuffer_height, GL_RGB, GL_UNSIGNED_BYTE, pixels);
    FILE *file = fopen(path, "wb");
    if (!file) return free(pixels), false;
    bool ok = fprintf(file, "P6\n%d %d\n255\n", r.framebuffer_width, r.framebuffer_height) > 0;
    for (int y = r.framebuffer_height - 1; y >= 0 && ok; --y)
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
    glUniform2f(r.viewport_uniform, (float)r.width, (float)r.height);
}

static void quad(float x, float y, float w, float h, uint32_t rgba, GLuint texture, int glyph)
{
    if (w <= 0 || h <= 0 || x >= r.width || y >= r.height || x + w <= 0 || y + h <= 0) return;
    const float vertices[] = {
        x,y,0,0, x+w,y,1,0, x+w,y+h,1,1,
        x,y,0,0, x+w,y+h,1,1, x,y+h,0,1
    };
    glUniform4f(r.color_uniform, ((rgba >> 24) & 255) / 255.f,
                ((rgba >> 16) & 255) / 255.f, ((rgba >> 8) & 255) / 255.f,
                (rgba & 255) / 255.f);
    glUniform1i(r.glyph_uniform, glyph);
    glBindTexture(GL_TEXTURE_2D, texture);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STREAM_DRAW);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

void renderer_rect(float x, float y, float width, float height, uint32_t rgba)
{
    quad(x, y, width, height, rgba, r.white, false);
}

void renderer_ring(float x, float y, float diameter, uint32_t rgba)
{
    quad(x, y, diameter, diameter, rgba, r.white, 2);
}

static struct Glyph *glyph_get(int codepoint)
{
    for (int i = 0; i < r.glyph_count; ++i)
        if (r.glyphs[i].codepoint == codepoint) return &r.glyphs[i];
    int index = r.glyph_count < GLYPH_COUNT ? r.glyph_count++ : codepoint % GLYPH_COUNT;
    struct Glyph *g = &r.glyphs[index];
    glDeleteTextures(1, &g->texture);
    memset(g, 0, sizeof(*g));
    g->codepoint = codepoint;
    int advance;
    stbtt_GetCodepointHMetrics(&r.font, codepoint, &advance, NULL);
    g->advance = advance * r.font_scale;
    unsigned char *bitmap = stbtt_GetCodepointBitmap(&r.font, 0, r.font_scale,
        codepoint, &g->width, &g->height, &g->x, &g->y);
    if (bitmap && g->width && g->height)
        g->texture = texture_create(g->width, g->height, GL_RED, bitmap);
    stbtt_FreeBitmap(bitmap, NULL);
    return g;
}

static int utf8_next(const char **cursor)
{
    const unsigned char *p = (const unsigned char *)*cursor;
    int codepoint = *p++;
    int count = codepoint < 0x80 ? 0 : codepoint >= 0xc2 && codepoint < 0xe0 ? 1 :
                codepoint >= 0xe0 && codepoint < 0xf0 ? 2 : codepoint >= 0xf0 && codepoint < 0xf5 ? 3 : -1;
    if (count < 0) { *cursor = (const char *)p; return 0xfffd; }
    if (count) codepoint &= (1 << (6 - count)) - 1;
    for (int i = 0; i < count; ++i) {
        if ((*p & 0xc0) != 0x80) { *cursor = (const char *)p; return 0xfffd; }
        codepoint = (codepoint << 6) | (*p++ & 0x3f);
    }
    *cursor = (const char *)p;
    return codepoint > 0x10ffff || (codepoint >= 0xd800 && codepoint <= 0xdfff) ? 0xfffd : codepoint;
}

static float advance_for(int codepoint)
{
    int advance;
    stbtt_GetCodepointHMetrics(&r.font, codepoint, &advance, NULL);
    return advance * r.font_scale;
}

static float text_layout(const char *text, float x, float y, float size, float max_width, uint32_t rgba, bool draw)
{
    if (!text || !*text || size <= 0) return y;
    float scale = size / FONT_PIXELS, pen = x, top = y;
    float line = fmaxf(r.line_height * scale, size * 1.3f);
    bool word_start = true;
    while (*text) {
        if (word_start && *text != ' ' && *text != '\n' && *text != '\t') {
            const char *word = text;
            float width = 0;
            while (*word && *word != ' ' && *word != '\n' && *word != '\t')
                width += advance_for(utf8_next(&word)) * scale;
            if (max_width > 0 && pen > x && pen + width > x + max_width) pen = x, top += line;
        }
        int cp = utf8_next(&text);
        word_start = cp == ' ' || cp == '\t' || cp == '\n';
        if (cp == '\r') continue;
        if (cp == '\n') { pen = x; top += line; continue; }
        float advance = advance_for(cp == '\t' ? ' ' : cp) * scale * (cp == '\t' ? 4 : 1);
        if (max_width > 0 && pen > x && pen + advance > x + max_width) {
            pen = x;
            top += line;
            if (cp == ' ' || cp == '\t') continue;
        }
        if (draw && cp != ' ' && cp != '\t' && top + line > 0 && top < r.height) {
            struct Glyph *g = glyph_get(cp);
            if (g->texture) quad(pen + g->x * scale, top + (r.ascent + g->y) * scale,
                                 g->width * scale, g->height * scale, rgba, g->texture, true);
        }
        pen += advance;
    }
    return top + line;
}

float renderer_text(const char *text, float x, float y, float size, float max_width, uint32_t rgba)
{
    return text_layout(text, x, y, size, max_width, rgba, true);
}

float renderer_text_height(const char *text, float size, float max_width)
{
    return text_layout(text, 0, 0, size, max_width, 0, false);
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
    unsigned char *pixels = stbi_load(path, &r.image_width, &r.image_height, &channels, 4);
    if (!pixels) return fprintf(stderr, "Cannot load image %s: %s\n", path, stbi_failure_reason()), false;
    r.image = texture_create(r.image_width, r.image_height, GL_RGBA, pixels);
    stbi_image_free(pixels);
    return true;
}

bool renderer_image_size(const char *path, int *width, int *height)
{
    if (!image_load(path)) return false;
    if (width) *width = r.image_width;
    if (height) *height = r.image_height;
    return true;
}

bool renderer_image(const char *path, float x, float y, float width, float height)
{
    if (!image_load(path)) return false;
    quad(x, y, width, height, 0xffffffff, r.image, false);
    return true;
}

void renderer_shutdown(void)
{
    for (int i = 0; i < r.glyph_count; ++i) glDeleteTextures(1, &r.glyphs[i].texture);
    glDeleteTextures(1, &r.white);
    glDeleteTextures(1, &r.image);
    glDeleteBuffers(1, &r.vbo);
    glDeleteVertexArrays(1, &r.vao);
    if (r.program) glDeleteProgram(r.program);
    free(r.font_data);
    free(r.image_path);
    memset(&r, 0, sizeof(r));
}
