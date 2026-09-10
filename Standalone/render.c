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
    GLuint scene_program, scene_vao, scene_vbo;
    GLint scene_matrix;
    GLint scene_ambient, scene_light_count, scene_light_positions, scene_light_colors;
    float ambient[3], background[3], light_positions[16 * 4], light_colors[16 * 4];
    size_t light_count;
    bool lighting_set;
    const float *scene_vertices;
    size_t scene_vertex_count;
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

static bool scene_init(void)
{
    const char *vertex = "#version 150\n"
        "in vec3 position; in vec3 normal; in vec3 color;"
        "uniform mat4 viewProjection; out vec3 surfaceNormal; out vec3 surfaceColor; out vec3 worldPosition;"
        "void main(){surfaceNormal=normal;surfaceColor=color;worldPosition=position;"
        "gl_Position=viewProjection*vec4(position,1.);}";
    const char *fragment = "#version 150\n"
        "in vec3 surfaceNormal; in vec3 surfaceColor; in vec3 worldPosition; out vec4 outputColor;"
        "uniform vec3 ambient; uniform int lightCount;"
        "uniform vec4 lightPositions[16]; uniform vec4 lightColors[16];"
        "void main(){vec3 n=normalize(surfaceNormal);vec3 light=ambient;"
        "for(int i=0;i<lightCount;i++){vec3 delta=lightPositions[i].xyz-worldPosition;"
        "float distance=length(delta);float radius=max(lightPositions[i].w,.0001);"
        "float attenuation=max(1.-distance/radius,0.);"
        "float diffuse=max(dot(n,delta/max(distance,.0001)),0.);"
        "light+=lightColors[i].rgb*lightColors[i].w*diffuse*attenuation*attenuation;}"
        "outputColor=vec4(pow(max(surfaceColor*light,vec3(0.)),vec3(1./2.2)),1.);}";
    GLuint vs = shader_create(GL_VERTEX_SHADER, vertex);
    GLuint fs = shader_create(GL_FRAGMENT_SHADER, fragment);
    if (!vs || !fs) { glDeleteShader(vs); glDeleteShader(fs); return false; }
    r.scene_program = glCreateProgram();
    glAttachShader(r.scene_program, vs);
    glAttachShader(r.scene_program, fs);
    glBindAttribLocation(r.scene_program, 0, "position");
    glBindAttribLocation(r.scene_program, 1, "normal");
    glBindAttribLocation(r.scene_program, 2, "color");
    glLinkProgram(r.scene_program);
    glDeleteShader(vs);
    glDeleteShader(fs);
    GLint ok;
    glGetProgramiv(r.scene_program, GL_LINK_STATUS, &ok);
    if (!ok) {
        char log[2048];
        glGetProgramInfoLog(r.scene_program, sizeof(log), NULL, log);
        fprintf(stderr, "Book scene shader: %s\n", log);
        glDeleteProgram(r.scene_program);
        r.scene_program = 0;
        return false;
    }
    r.scene_matrix = glGetUniformLocation(r.scene_program, "viewProjection");
    r.scene_ambient = glGetUniformLocation(r.scene_program, "ambient");
    r.scene_light_count = glGetUniformLocation(r.scene_program, "lightCount");
    r.scene_light_positions = glGetUniformLocation(r.scene_program, "lightPositions");
    r.scene_light_colors = glGetUniformLocation(r.scene_program, "lightColors");
    glGenVertexArrays(1, &r.scene_vao);
    glBindVertexArray(r.scene_vao);
    glGenBuffers(1, &r.scene_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, r.scene_vbo);
    for (int i = 0; i < 3; ++i) {
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(i, 3, GL_FLOAT, GL_FALSE, 9 * sizeof(float),
                              (void *)(size_t)(i * 3 * sizeof(float)));
    }
    return true;
}

void renderer_lighting(const float ambient[3], const float background[3],
                       const float *lights, size_t count)
{
    const float default_ambient[] = {.6f, .6f, .6f};
    const float default_background[] = {.17f, .16f, .145f};
    memcpy(r.ambient, ambient ? ambient : default_ambient, sizeof(r.ambient));
    memcpy(r.background, background ? background : default_background, sizeof(r.background));
    r.light_count = lights ? (count < 16 ? count : 16) : 0;
    for (size_t i = 0; i < r.light_count; ++i) {
        memcpy(r.light_positions + i * 4, lights + i * 8, 3 * sizeof(float));
        r.light_positions[i * 4 + 3] = lights[i * 8 + 6];
        memcpy(r.light_colors + i * 4, lights + i * 8 + 3, 3 * sizeof(float));
        r.light_colors[i * 4 + 3] = lights[i * 8 + 7];
    }
    r.lighting_set = true;
}

void renderer_scene(const float *vertices, size_t vertex_count, const float *view_projection,
                    float x, float y, float width, float height)
{
    if (!vertices || !vertex_count || !view_projection || width <= 0 || height <= 0) return;
    GLint old_program, old_vao, old_vbo, old_viewport[4], old_scissor[4], old_depth_func;
    GLboolean old_depth = glIsEnabled(GL_DEPTH_TEST), old_scissor_test = glIsEnabled(GL_SCISSOR_TEST);
    GLboolean old_blend = glIsEnabled(GL_BLEND), old_depth_mask;
    GLfloat old_clear[4];
    glGetIntegerv(GL_CURRENT_PROGRAM, &old_program);
    glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &old_vao);
    glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &old_vbo);
    glGetIntegerv(GL_VIEWPORT, old_viewport);
    glGetIntegerv(GL_SCISSOR_BOX, old_scissor);
    glGetIntegerv(GL_DEPTH_FUNC, &old_depth_func);
    glGetBooleanv(GL_DEPTH_WRITEMASK, &old_depth_mask);
    glGetFloatv(GL_COLOR_CLEAR_VALUE, old_clear);
    if (!r.scene_program && !scene_init()) goto restore;
    glUseProgram(r.scene_program);
    glBindVertexArray(r.scene_vao);
    glBindBuffer(GL_ARRAY_BUFFER, r.scene_vbo);
    if (vertices != r.scene_vertices || vertex_count != r.scene_vertex_count) {
        glBufferData(GL_ARRAY_BUFFER, vertex_count * 9 * sizeof(float), vertices, GL_STATIC_DRAW);
        r.scene_vertices = vertices;
        r.scene_vertex_count = vertex_count;
    }
    int vx = (int)lroundf(x * r.scale), vy = (int)lroundf((r.height - y - height) * r.scale);
    int vw = (int)lroundf(width * r.scale), vh = (int)lroundf(height * r.scale);
    glViewport(vx, vy, vw, vh);
    glEnable(GL_SCISSOR_TEST);
    glScissor(vx, vy, vw, vh);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);
    if (!r.lighting_set) renderer_lighting(NULL, NULL, NULL, 0);
    glClearColor(r.background[0], r.background[1], r.background[2], 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glUniformMatrix4fv(r.scene_matrix, 1, GL_FALSE, view_projection);
    glUniform3fv(r.scene_ambient, 1, r.ambient);
    glUniform1i(r.scene_light_count, (GLint)r.light_count);
    glUniform4fv(r.scene_light_positions, (GLsizei)r.light_count, r.light_positions);
    glUniform4fv(r.scene_light_colors, (GLsizei)r.light_count, r.light_colors);
    glDrawArrays(GL_TRIANGLES, 0, (GLsizei)vertex_count);
restore:
    glUseProgram(old_program);
    glBindVertexArray(old_vao);
    glBindBuffer(GL_ARRAY_BUFFER, old_vbo);
    glViewport(old_viewport[0], old_viewport[1], old_viewport[2], old_viewport[3]);
    glScissor(old_scissor[0], old_scissor[1], old_scissor[2], old_scissor[3]);
    if (!old_scissor_test) glDisable(GL_SCISSOR_TEST);
    if (!old_depth) glDisable(GL_DEPTH_TEST);
    if (old_blend) glEnable(GL_BLEND);
    glDepthFunc(old_depth_func);
    glDepthMask(old_depth_mask);
    glClearColor(old_clear[0], old_clear[1], old_clear[2], old_clear[3]);
}

void renderer_shutdown(void)
{
    for (int i = 0; i < r.glyph_count; ++i) glDeleteTextures(1, &r.glyphs[i].texture);
    glDeleteTextures(1, &r.white);
    glDeleteTextures(1, &r.image);
    glDeleteBuffers(1, &r.vbo);
    glDeleteVertexArrays(1, &r.vao);
    glDeleteBuffers(1, &r.scene_vbo);
    glDeleteVertexArrays(1, &r.scene_vao);
    if (r.scene_program) glDeleteProgram(r.scene_program);
    if (r.program) glDeleteProgram(r.program);
    free(r.font_data);
    free(r.image_path);
    memset(&r, 0, sizeof(r));
}
