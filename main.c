#define _XOPEN_SOURCE 700
#include <stdbool.h>
#include <stdint.h>
#include <platform.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <libxml/parser.h>
#include <libxml/tree.h>
#include <limits.h>
#include <unistd.h>
#include <dirent.h>
#include <ctype.h>
#include <stdarg.h>

void renderer_shutdown(void);

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

/* ZIL is the world model. C owns only the coroutine, current page and input. */
#define MAX_OBJECTS 256
#define MAX_CHOICES 512
struct Object { char symbol[128], key[128], noun[256], adjective[128], desc[256]; };
struct Choice { char label[512], command[512]; int object; bool focus; };
struct Book {
    lua_State *lua, *co;
    int env, game, original_object;
    struct Object objects[MAX_OBJECTS];
    struct Choice choices[MAX_CHOICES];
    int choice_count, room, focus;
    bool beat, ended;
    char root[PATH_MAX], adventure[128], rooms[PATH_MAX], image[PATH_MAX], camera[512];
    char text[32768], room_text[32768], focus_text[32768];
} book;

static void fail(const char *format, ...)
{
    va_list args; va_start(args, format);
    fputs("Book: ", stderr); vfprintf(stderr, format, args); fputc('\n', stderr);
    va_end(args); exit(EXIT_FAILURE);
}

static void copy(char *dst, size_t size, const char *src)
{
    if (!src) src = "";
    if (strlen(src) >= size) fail("text exceeds buffer capacity (%zu)", size);
    memcpy(dst, src, strlen(src) + 1);
}

static void lower(char *s)
{
    for (; *s; ++s) *s = (char)tolower((unsigned char)*s);
}

static void asset_key(char *dst, size_t size, const char *src)
{
    copy(dst, size, src); lower(dst);
    for (char *s = dst; *s; ++s) {
        if (*s == '_') *s = '-';
        if (!isalnum((unsigned char)*s) && *s != '-') fail("invalid asset name: %s", src);
    }
}

static void checked_call(lua_State *L, int args, int results)
{
    if (lua_pcall(L, args, results, 0) != LUA_OK) fail("%s", lua_tostring(L, -1));
}

static void env_get(const char *name)
{
    lua_State *L = book.lua;
    lua_rawgeti(L, LUA_REGISTRYINDEX, book.env);
    lua_getfield(L, -1, name); lua_remove(L, -2);
}

static int env_number(const char *name)
{
    env_get(name); int n = (int)lua_tointeger(book.lua, -1); lua_pop(book.lua, 1); return n;
}

static int env_int_call(const char *name, int object, int value, int nargs)
{
    lua_State *L = book.lua;
    env_get(name); lua_pushinteger(L, object);
    if (nargs == 2) lua_pushinteger(L, value);
    checked_call(L, nargs, 1);
    int result = lua_isboolean(L, -1) ? lua_toboolean(L, -1) : (int)lua_tointeger(L, -1);
    lua_pop(L, 1); return result;
}

static bool flag(int object, const char *name)
{
    int bit = env_number(name);
    return bit && env_int_call("FSETQ", object, bit, 2);
}

static int location(int object) { return env_int_call("LOC", object, 0, 1); }

/* Record declaration identity and parser vocabulary as the VM loads objects.
   The VM still performs the entire declaration and owns all mutable state. */
static int capture_object(lua_State *L)
{
    lua_getfield(L, 1, "ZIL_NAME");
    if (!lua_isstring(L, -1)) { lua_pop(L, 1); lua_getfield(L, 1, "NAME"); }
    char symbol[128]; copy(symbol, sizeof(symbol), lua_tostring(L, -1)); lua_pop(L, 1);
    lua_rawgeti(L, LUA_REGISTRYINDEX, book.original_object);
    lua_pushvalue(L, 1); lua_call(L, 1, 1);
    lua_rawgeti(L, LUA_REGISTRYINDEX, book.env);
    lua_getfield(L, -1, symbol); int id = (int)lua_tointeger(L, -1); lua_pop(L, 2);
    if (id > 0 && id < MAX_OBJECTS) {
        struct Object *o = &book.objects[id];
        copy(o->symbol, sizeof(o->symbol), symbol); asset_key(o->key, sizeof(o->key), symbol);
        lua_getfield(L, 1, "DESC"); copy(o->desc, sizeof(o->desc), lua_tostring(L, -1)); lua_pop(L, 1);
        lua_getfield(L, 1, "SYNONYM");
        if (lua_istable(L, -1)) {
            lua_rawgeti(L, -1, 1); copy(o->noun, sizeof(o->noun), lua_tostring(L, -1)); lua_pop(L, 1);
            lua_getfield(L, 1, "ADJECTIVE");
            if (lua_istable(L, -1)) {
                for (size_t a = 1; a <= lua_rawlen(L, -1); ++a) {
                    lua_rawgeti(L, -1, (lua_Integer)a);
                    const char *adj = lua_tostring(L, -1); bool noun = false;
                    for (size_t n = 1; adj && n <= lua_rawlen(L, -3); ++n) {
                        lua_rawgeti(L, -3, (lua_Integer)n);
                        const char *word = lua_tostring(L, -1);
                        if (word && !strcmp(adj, word)) noun = true;
                        lua_pop(L, 1);
                    }
                    if (adj && !noun) {
                        copy(o->adjective, sizeof(o->adjective), adj); lower(o->adjective);
                        lua_pop(L, 1); break;
                    }
                    lua_pop(L, 1);
                }
            }
            lua_pop(L, 1);
        }
        lua_pop(L, 1); lower(o->noun);
    }
    return 1;
}

static bool visible(int object)
{
    int here = env_number("HERE"), actor = env_number("WINNER");
    if (object == actor || flag(object, "INVISIBLE")) return false;
    bool seen[MAX_OBJECTS] = {false}; int current = object;
    while (current > 0 && current < MAX_OBJECTS && !seen[current]) {
        seen[current] = true;
        int parent = location(current);
        if (parent == here || parent == actor) return true;
        if (!parent || (!flag(parent, "OPENBIT") && !flag(parent, "SURFACEBIT") && !flag(parent, "TRANSBIT"))) break;
        current = parent;
    }
    /* ZIL GLOBAL objects are visible in the current room without a LOC chain. */
    int prop = env_number("PQGLOBAL");
    int ptr = prop ? env_int_call("GETPT", here, prop, 2) : 0;
    int size = ptr ? env_int_call("PTSIZE", ptr, 0, 1) : 0;
    for (int i = 0; i < size; ++i)
        if (env_int_call("GETB", ptr, i, 2) == object) return true;
    return false;
}

static const char *noun_phrase(int id)
{
    static char phrase[384];
    struct Object *o = &book.objects[id];
    for (int i = 1; i < MAX_OBJECTS; ++i) {
        if (i != id && *o->adjective && !strcmp(o->noun, book.objects[i].noun) && visible(i)) {
            snprintf(phrase, sizeof(phrase), "%s %s", o->adjective, o->noun);
            return phrase;
        }
    }
    return o->noun;
}

/* lua_resume is called directly by C; zilscript supplies its existing GO/READ
   coroutine wrapper, including restart and quit handling. Queries consume no turn. */
static void resume_vm(const char *input)
{
    if (book.ended) return;
    if (input) lua_settop(book.co, 0);
    if (input) lua_pushstring(book.co, input);
    int count = 0;
    int status = lua_resume(book.co, book.lua, input ? 1 : 0, &count);
    if (status != LUA_OK && status != LUA_YIELD)
        fail("ZIL: %s", lua_tostring(book.co, -1));
    book.ended = status == LUA_OK;
}

static void read_output(char *dst, size_t size)
{
    const char *text = lua_gettop(book.co) ? lua_tostring(book.co, -1) : NULL;
    copy(dst, size, text);
    size_t n = strlen(dst);
    while (n && isspace((unsigned char)dst[n - 1])) dst[--n] = 0;
    if (n && dst[n - 1] == '>') dst[--n] = 0;
    while (n && isspace((unsigned char)dst[n - 1])) dst[--n] = 0;
}

static void add_choice(const char *label, const char *command, int object, bool focus)
{
    if (book.choice_count >= MAX_CHOICES) fail("too many visible choices");
    for (int i = 0; i < book.choice_count; ++i)
        if (book.choices[i].object == object && !strcmp(book.choices[i].command, command)
            && book.choices[i].focus == focus) return;
    struct Choice *c = &book.choices[book.choice_count++];
    copy(c->label, sizeof(c->label), label); copy(c->command, sizeof(c->command), command);
    c->object = object; c->focus = focus;
}

static bool image_for(const char *key)
{
    if (!*key) return false;
    char path[PATH_MAX];
    int n = snprintf(path, sizeof(path), "%s/%s.jpg", book.rooms, key);
    if (n < 0 || (size_t)n >= sizeof(path)) fail("asset path too long");
    if (access(path, R_OK)) return false;
    copy(book.image, sizeof(book.image), path); copy(book.camera, sizeof(book.camera), key);
    return true;
}

static void select_image(int subject, const char *verb, int origin)
{
    book.image[0] = book.camera[0] = 0;
    int room = origin ? origin : book.room;
    char key[512];
    if (subject > 0 && subject < MAX_OBJECTS) {
        if (verb && *verb) {
            snprintf(key, sizeof(key), "%s-%s-%s", book.objects[room].key, verb, book.objects[subject].key);
            lower(key);
            for (char *p = key; *p; ++p) if (!isalnum((unsigned char)*p) && *p != '-') *p = '-';
            if (image_for(key)) return;
        }
        if (room == book.room) {
            snprintf(key, sizeof(key), "%s-examine-%s", book.objects[room].key, book.objects[subject].key);
            if (image_for(key)) return;
        }
    }
    snprintf(key, sizeof(key), "%s-look", book.objects[book.room].key);
    image_for(key);
    /* Rooms without art remain playable as text. Never retain another room's image. */
}

static int find_item(const char *desc)
{
    int found = 0;
    for (int i = 1; i < MAX_OBJECTS; ++i) {
        char name[256]; copy(name, sizeof(name), book.objects[i].desc); lower(name);
        if (*book.objects[i].noun && !strcmp(desc, name) && visible(i)) {
            if (found) return 0; /* ambiguous prose is not a reliable object identity */
            found = i;
        }
    }
    return found;
}

static void item_choices(lua_State *L, int table)
{
    table = lua_absindex(L, table);
    for (size_t i = 1; i <= lua_rawlen(L, table); ++i) {
        lua_rawgeti(L, table, (lua_Integer)i);
        lua_rawgeti(L, -1, 1);
        int object = find_item(lua_tostring(L, -1) ? lua_tostring(L, -1) : ""); lua_pop(L, 1);
        lua_rawgeti(L, -1, 2);
        if (object && (!book.focus || book.focus == object)) {
            struct Object *o = &book.objects[object];
            char label[512], command[512];
            if (!book.focus) {
                snprintf(label, sizeof(label), "Look at %s", o->desc);
                add_choice(label, "", object, true);
            } else {
                snprintf(command, sizeof(command), "examine %s", noun_phrase(object));
                snprintf(label, sizeof(label), "Examine %s", o->desc);
                add_choice(label, command, object, false);
                for (size_t v = 1; v <= lua_rawlen(L, -1); ++v) {
                    lua_rawgeti(L, -1, (lua_Integer)v);
                    const char *verb = lua_tostring(L, -1);
                    /* Internal parser action variants aren't typed vocabulary. */
                    if (verb && !strchr(verb, '-') && !strchr(verb, '_') && strcmp(verb, "EXAMINE")) {
                        char word[128]; copy(word, sizeof(word), verb); lower(word);
                        if ((!strcmp(word, "open") && flag(object, "OPENBIT")) ||
                            (!strcmp(word, "close") && !flag(object, "OPENBIT")) ||
                            (!strcmp(word, "take") && location(object) == env_number("WINNER"))) {
                            lua_pop(L, 1); continue;
                        }
                        snprintf(command, sizeof(command), "%s %s", word, noun_phrase(object));
                        word[0] = (char)toupper((unsigned char)word[0]);
                        snprintf(label, sizeof(label), "%s %s", word, o->desc);
                        add_choice(label, command, object, false);
                    }
                    lua_pop(L, 1);
                }
            }
        }
        lua_pop(L, 1);
        lua_rawgeti(L, -1, 3);
        if (lua_istable(L, -1)) item_choices(L, -1);
        lua_pop(L, 2);
    }
}

static void refresh_choices(void)
{
    book.choice_count = 0;
    if (book.ended) return;
    if (book.beat) { add_choice("Continue", "", 0, false); return; }
    if (book.focus && !visible(book.focus)) book.focus = 0;
    resume_vm("room-items");
    if (lua_istable(book.co, -1)) item_choices(book.co, -1);
    if (book.focus) {
        /* Inventory objects aren't included in the VM's room-items query. */
        if (!book.choice_count) {
            char command[512]; snprintf(command, sizeof(command), "examine %s", noun_phrase(book.focus));
            add_choice("Examine", command, book.focus, false);
        }
        add_choice("Back", "", 0, false);
    } else {
        lua_State *L = book.lua;
        env_get("_DIRECTIONS"); lua_pushnil(L);
        while (lua_next(L, -2)) {
            const char *direction = lua_tostring(L, -2);
            int prop = (int)lua_tointeger(L, -1);
            int ptr = env_int_call("GETPT", book.room, prop, 2);
            if (ptr && direction) {
                char command[128], label[512];
                copy(command, sizeof(command), direction); lower(command);
                int bytes = env_int_call("PTSIZE", ptr, 0, 1);
                int destination = (bytes == 1 || bytes == 4 || bytes == 5)
                    ? env_int_call("GETB", ptr, 0, 2) : 0;
                const char *desc = destination > 0 && destination < MAX_OBJECTS ? book.objects[destination].desc : "";
                snprintf(label, sizeof(label), *desc ? "Go %s — %s" : "Go %s", command, desc);
                add_choice(label, command, 0, false);
            }
            lua_pop(L, 1);
        }
        lua_pop(L, 1);
        add_choice("Inventory", "inventory", 0, false);
    }
}

static void command(const char *input, int subject)
{
    if (book.ended || !*input) return;
    int before = book.room;
    resume_vm(input); read_output(book.text, sizeof(book.text));
    book.room = env_number("HERE");
    if (book.room <= 0 || book.room >= MAX_OBJECTS) fail("invalid HERE object");
    if (!subject) {
        subject = env_number("PRSO");
        if (subject <= 0 || subject >= MAX_OBJECTS || !*book.objects[subject].key) subject = 0;
    }
    if (book.room != before) {
        book.focus = 0; copy(book.room_text, sizeof(book.room_text), book.text);
    }
    char verb[128]; size_t n = strcspn(input, " \t");
    if (n >= sizeof(verb)) n = sizeof(verb) - 1;
    memcpy(verb, input, n); verb[n] = 0;
    select_image(subject, verb, before);
    if (book.focus) copy(book.focus_text, sizeof(book.focus_text), book.text);
    book.beat = true; refresh_choices();
}

static void back(void)
{
    if (book.beat) book.beat = false;
    else book.focus = 0;
    if (book.focus && !visible(book.focus)) book.focus = 0;
    copy(book.text, sizeof(book.text), book.focus ? book.focus_text : book.room_text);
    select_image(book.focus, NULL, 0); refresh_choices();
}

static void focus_object(int object)
{
    if (!visible(object)) return;
    book.beat = false; book.focus = object;
    char cmd[512]; snprintf(cmd, sizeof(cmd), "examine %s", noun_phrase(object));
    command(cmd, object);
    if (!book.focus) return; /* examination may move the player */
    copy(book.focus_text, sizeof(book.focus_text), book.text);
    book.beat = false; select_image(book.focus, NULL, 0); refresh_choices();
}

static void action(int index)
{
    if (index < 0 || index >= book.choice_count) return;
    struct Choice c = book.choices[index];
    if (c.focus) focus_object(c.object);
    else if (!*c.command) back();
    else command(c.command, c.object);
}

static void init_book(const char *root, const char *adventure)
{
    if (!realpath(root, book.root)) fail("cannot resolve asset root: %s", root);
    asset_key(book.adventure, sizeof(book.adventure), adventure);
    snprintf(book.rooms, sizeof(book.rooms), "%s/books/%s/rooms", book.root, book.adventure);
    lua_State *L = book.lua = luaL_newstate();
    if (!L) fail("cannot allocate Lua state");
    luaL_openlibs(L);
    lua_getglobal(L, "package");
    lua_pushfstring(L, "%s/libs/zilscript/?.lua;%s/libs/zilscript/?/init.lua", book.root, book.root);
    lua_setfield(L, -2, "path");
    lua_pushfstring(L, "%s/libs/zilscript/?.zil;%s/libs/zilscript/infocom/zork1/?.zil", book.root, book.root);
    lua_setfield(L, -2, "zilpath"); lua_pop(L, 1);
    lua_getglobal(L, "require"); lua_pushliteral(L, "zilscript.runtime"); checked_call(L, 1, 1);
    int runtime = lua_gettop(L);
    lua_getfield(L, runtime, "create_game_env"); checked_call(L, 0, 1);
    book.env = luaL_ref(L, LUA_REGISTRYINDEX);
    lua_rawgeti(L, LUA_REGISTRYINDEX, book.env);
    lua_getglobal(L, "rawequal"); lua_setfield(L, -2, "rawequal"); lua_pop(L, 1);
    lua_getfield(L, runtime, "init"); lua_rawgeti(L, LUA_REGISTRYINDEX, book.env);
    lua_pushboolean(L, true); checked_call(L, 2, 1);
    if (!lua_toboolean(L, -1)) fail("cannot initialize zilscript"); lua_pop(L, 1);
    env_get("require"); lua_pushliteral(L, "zilscript"); checked_call(L, 1, 0);
    env_get("OBJECT"); book.original_object = luaL_ref(L, LUA_REGISTRYINDEX);
    lua_rawgeti(L, LUA_REGISTRYINDEX, book.env);
    lua_pushcfunction(L, capture_object); lua_setfield(L, -2, "OBJECT");
    lua_pushcfunction(L, capture_object); lua_setfield(L, -2, "ROOM"); lua_pop(L, 1);
    /* A book is selected by convention: zilscript/books/<name>/<name>.zil. */
    char module[384]; snprintf(module, sizeof(module), "books.%s.%s", book.adventure, book.adventure);
    lua_getfield(L, runtime, "load_modules"); lua_rawgeti(L, LUA_REGISTRYINDEX, book.env);
    lua_newtable(L); lua_pushstring(L, module); lua_rawseti(L, -2, 1);
    checked_call(L, 2, 1);
    if (!lua_toboolean(L, -1)) fail("cannot load %s", module); lua_pop(L, 1);
    lua_getfield(L, runtime, "create_game"); lua_rawgeti(L, LUA_REGISTRYINDEX, book.env);
    lua_pushboolean(L, true); checked_call(L, 2, 1);
    lua_getfield(L, -1, "coroutine"); book.co = lua_tothread(L, -1); lua_pop(L, 1);
    book.game = luaL_ref(L, LUA_REGISTRYINDEX); lua_pop(L, 1);
    resume_vm(NULL); read_output(book.text, sizeof(book.text));
    book.room = env_number("HERE");
    if (book.room <= 0 || book.room >= MAX_OBJECTS) fail("story did not set HERE");
    copy(book.room_text, sizeof(book.room_text), book.text);
    select_image(0, NULL, 0); refresh_choices();
}

/* Read only fixed cameras and named anchor transforms from Scener XML. */
struct Vec { double x, y, z; };
struct Camera { struct Vec pos, look; double fov; bool zup; };
static xmlDoc *scene_doc;
static struct Camera camera;
static char loaded_camera[512];

static struct Vec sub(struct Vec a, struct Vec b) { return (struct Vec){a.x-b.x,a.y-b.y,a.z-b.z}; }
static double dot(struct Vec a, struct Vec b) { return a.x*b.x+a.y*b.y+a.z*b.z; }
static struct Vec cross(struct Vec a, struct Vec b) { return (struct Vec){a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x}; }
static struct Vec normal(struct Vec a)
{
    double d = sqrt(dot(a,a));
    return d > 1e-8 ? (struct Vec){a.x/d,a.y/d,a.z/d} : (struct Vec){0,0,1};
}

static struct Vec xml_vec(xmlNode *node, const char *name, struct Vec fallback)
{
    xmlChar *value = xmlGetProp(node, (const xmlChar *)name);
    if (!value) return fallback;
    struct Vec v; char extra;
    if (sscanf((char *)value, "%lf %lf %lf %c", &v.x,&v.y,&v.z,&extra) != 3 ||
        !isfinite(v.x) || !isfinite(v.y) || !isfinite(v.z)) fail("invalid %s in Scener metadata", name);
    xmlFree(value); return v;
}

static bool xml_name(xmlNode *node, const char *tag)
{
    return node->type == XML_ELEMENT_NODE && !xmlStrcmp(node->name, (const xmlChar *)tag);
}

static bool named(xmlNode *node, const char *key)
{
    xmlChar *value = xmlGetProp(node, (const xmlChar *)"name");
    if (!value) return false;
    char name[512]; copy(name, sizeof(name), (char *)value); xmlFree(value); lower(name);
    for (char *p = name; *p; ++p) if (*p == '_') *p = '-';
    return !strcmp(name, key);
}

static xmlNode *find_node(xmlNode *node, const char *key, bool is_camera)
{
    xmlNode *found = NULL;
    for (; node; node = node->next) {
        if (node->type != XML_ELEMENT_NODE) continue;
        if (xml_name(node,"camera") == is_camera && named(node,key)) found = node;
        xmlNode *child = find_node(node->children,key,is_camera);
        if (child) {
            if (found) fail("ambiguous scene anchor: %s", key);
            found = child;
        }
        if (found) {
            if (find_node(node->next,key,is_camera)) fail("duplicate scene name: %s", key);
            return found;
        }
    }
    return NULL;
}

static void load_camera(void)
{
    if (!strcmp(loaded_camera, book.camera)) return;
    xmlFreeDoc(scene_doc); scene_doc = NULL;
    copy(loaded_camera, sizeof(loaded_camera), book.camera);
    if (!*book.camera) return;
    struct dirent **entries;
    int count = scandir(book.rooms, &entries, NULL, alphasort);
    if (count < 0) return; /* Metadata is optional when no projected markers exist. */
    for (int i = 0; i < count; ++i) {
        const char *name = entries[i]->d_name; size_t n = strlen(name);
        if (n > 5 && !strcmp(name+n-5,".blks")) {
            char path[PATH_MAX]; snprintf(path,sizeof(path),"%s/%s",book.rooms,name);
            xmlDoc *doc = xmlReadFile(path,NULL,XML_PARSE_NONET);
            if (!doc) fail("cannot read camera metadata: %s",path);
            xmlNode *root = xmlDocGetRootElement(doc);
            xmlNode *node = find_node(root,book.camera,true);
            if (node) {
                if (scene_doc) fail("camera %s occurs in multiple .blks files",book.camera);
                if (!xml_name(root,"scene") || node->parent != root) fail("camera must be a direct scene child");
                camera.pos=xml_vec(node,"pos",(struct Vec){0,160,500});
                camera.look=xml_vec(node,"look",(struct Vec){0,120,0});
                xmlChar *fov=xmlGetProp(node,(const xmlChar *)"fov");
                camera.fov=fov ? strtod((char *)fov,NULL) : 60; xmlFree(fov);
                if (!(camera.fov>0 && camera.fov<180)) fail("invalid camera FOV");
                xmlChar *up=xmlGetProp(root,(const xmlChar *)"up");
                if (up && xmlStrcmp(up,(const xmlChar *)"z") && xmlStrcmp(up,(const xmlChar *)"y")) fail("invalid scene up axis");
                camera.zup=up && !xmlStrcmp(up,(const xmlChar *)"z"); xmlFree(up);
                scene_doc=doc;
            } else xmlFreeDoc(doc);
        }
        free(entries[i]);
    }
    free(entries);
}

static bool anchor_point(const char *key, struct Vec *point)
{
    if (!scene_doc) return false;
    xmlNode *node=find_node(xmlDocGetRootElement(scene_doc),key,false);
    if (!node) return false;
    *point=(struct Vec){0,0,0};
    for (; node && !xml_name(node,"scene"); node=node->parent) {
        if (xmlHasProp(node,(const xmlChar *)"attach") || xmlHasProp(node,(const xmlChar *)"pivotOffset")) return false;
        if (node->parent && !xml_name(node->parent,"group") && !xml_name(node->parent,"scene")) return false;
        struct Vec p=xml_vec(node,"pos",(struct Vec){0,0,0});
        struct Vec s=xml_vec(node,"scale",(struct Vec){1,1,1});
        struct Vec rot=xml_vec(node,"rot",(struct Vec){0,0,0});
        double x=point->x*s.x,y=point->y*s.y,z=point->z*s.z,t;
        double radians=acos(-1)/180, c=cos(rot.x*radians),sn=sin(rot.x*radians);
        t=c*y-sn*z; z=sn*y+c*z; y=t;
        c=cos(rot.y*radians); sn=sin(rot.y*radians); t=c*x+sn*z; z=-sn*x+c*z; x=t;
        c=cos(rot.z*radians); sn=sin(rot.z*radians); t=c*x-sn*y; y=sn*x+c*y; x=t;
        *point=(struct Vec){x+p.x,y+p.y,z+p.z};
    }
    return true;
}

static bool project(struct Camera cam, struct Vec point, double iw, double ih,
                    double width, double height, float *x, float *y)
{
    if (iw<=0 || ih<=0 || width<=0 || height<=0) return false;
    struct Vec forward=normal(sub(cam.look,cam.pos));
    struct Vec right=normal(cross(forward,cam.zup ? (struct Vec){0,0,1} : (struct Vec){0,1,0}));
    struct Vec up=cross(right,forward),delta=sub(point,cam.pos);
    double depth=dot(delta,forward);
    if (depth<=10) return false; /* Scener centimetres; matching 0.1 m near plane. */
    double focal=ih/(2*tan(cam.fov*acos(-1)/360));
    double sx=iw/2+dot(delta,right)*focal/depth, sy=ih/2-dot(delta,up)*focal/depth;
    if (sx<0 || sx>iw || sy<0 || sy>ih) return false;
    double scale=fmax(width/iw,height/ih);
    *x=(float)(sx*scale+(width-iw*scale)/2); *y=(float)(sy*scale+(height-ih*scale)/2);
    return *x>=0 && *x<=width && *y>=0 && *y<=height;
}

struct Hit { float x,y,w,h; int action; bool circle; };
static struct Hit hits[MAX_CHOICES*2];
static int hit_count,scroll,max_scroll,show_text=1;
static char input[512];
static float window_width=1100,window_height=800;
static const char *screenshot_path;

static float story_text(const char *text,float x,float y,float size,float width)
{
    renderer_text(text,x+1,y+2,size,width,0x120B07E6);
    return renderer_text(text,x,y,size,width,0xF4E6CAFF);
}

static void add_hit(float x,float y,float w,float h,int action,bool circle)
{
    if (w>0 && h>0 && hit_count<(int)(sizeof(hits)/sizeof(*hits)))
        hits[hit_count++]=(struct Hit){x,y,w,h,action,circle};
}

static void draw(void)
{
    struct AXsize size; axGetSize(&size);
    window_width=size.width; window_height=size.height;
    axBeginPaint(); renderer_resize(size.width,size.height,axGetScaling()); renderer_clear();
    hit_count=0;
    int iw=0,ih=0;
    if (*book.image) {
        if (!renderer_image_size(book.image,&iw,&ih)) fail("cannot decode %s",book.image);
        float scale=fmaxf(window_width/iw,window_height/ih);
        float w=iw*scale,h=ih*scale;
        renderer_image(book.image,(window_width-w)/2,(window_height-h)/2,w,h);
    } else renderer_rect(0,0,window_width,window_height,0x211C18FF);
    load_camera();
    if (!book.beat && !book.focus) {
        for (int i=0;i<book.choice_count;++i) {
            struct Choice *c=&book.choices[i]; struct Vec point; float x,y;
            if (c->focus && anchor_point(book.objects[c->object].key,&point) &&
                project(camera,point,iw,ih,window_width,window_height,&x,&y) &&
                x>=24 && y>=24 && x<=window_width-24 && y<=window_height-24) {
                renderer_ring(x-24,y-22,48,0x120B0780); renderer_ring(x-24,y-24,48,0xFFFFFFFF);
                add_hit(x-24,y-24,48,48,i,true);
            }
        }
    }
    max_scroll=0;
    if (show_text) {
        float margin=fminf(32,window_width*.03f),prose_width=window_width*.44f;
        float choice_width=window_width*.40f,choice_x=window_width-margin-choice_width;
        float font_size=24,choice_size=22,gap=16,limit=window_height-margin-(*input ? 40 : 0);
        float choice_top=window_height*.52f,total=0;
        for (int i=0;i<book.choice_count;++i)
            total+=renderer_text_height(book.choices[i].label,choice_size,choice_width)+gap;
        total=fmaxf(0,total-gap); choice_top=fmaxf(choice_top,limit-total);
        int choice_scroll=MAX(0,(int)ceilf(total-(limit-choice_top)));
        float prose_height=renderer_text_height(book.text,font_size,prose_width);
        int prose_scroll=MAX(0,(int)ceilf(prose_height-(limit-margin)));
        max_scroll=MAX(choice_scroll,prose_scroll); scroll=MIN(scroll,max_scroll);
        renderer_clip(margin,margin,prose_width+2,limit-margin);
        story_text(book.text,margin,margin-MIN(scroll,prose_scroll),font_size,prose_width); renderer_unclip();
        renderer_clip(choice_x,choice_top,choice_width+2,limit-choice_top);
        float bottom=choice_top-MIN(scroll,choice_scroll);
        for (int i=0;i<book.choice_count;++i) {
            float end=story_text(book.choices[i].label,choice_x,bottom,choice_size,choice_width);
            float top=fmaxf(bottom,choice_top),last=fminf(end,limit);
            add_hit(choice_x,top,choice_width,last-top,i,false); bottom=end+gap;
        }
        renderer_unclip();
        if (choice_scroll>scroll) story_text("↓",window_width-margin-18,limit,18,20);
    }
    if (*input) {
        char text[sizeof(input)+3]; snprintf(text,sizeof(text),"> %s",input);
        renderer_clip(32,window_height-40,window_width-64,32);
        story_text(text,32,window_height-40,20,window_width-64); renderer_unclip();
    }
    if (screenshot_path && !renderer_screenshot(screenshot_path)) fail("cannot write screenshot");
    axEndPaint();
}

static void reload(void)
{
    loaded_camera[0]=0;
    free(r.image_path); r.image_path=NULL; /* F5 also reloads a replaced JPEG. */
    select_image(book.focus,NULL,0);
    load_camera(); refresh_choices();
}

static void key(struct AXmessage *event)
{
    if (event->keyCode==AX_KEY_TAB) { show_text=!show_text; hit_count=0; }
    else if (event->keyCode==AX_KEY_F5) reload();
    else if (event->keyCode==AX_KEY_ESCAPE) { if (*input) input[0]=0; else back(); }
    else if (event->keyCode==AX_KEY_ENTER) {
        if (*input) { command(input,0); input[0]=0; }
        else if (book.beat) back();
    } else if (event->keyCode==AX_KEY_BACKSPACE) {
        size_t n=strlen(input);
        if (n) { do { --n; } while (n && ((unsigned char)input[n]&0xC0)==0x80); input[n]=0; }
    } else if (event->keyCode==AX_KEY_DOWNARROW) scroll=MIN(max_scroll,scroll+40);
    else if (event->keyCode==AX_KEY_UPARROW) scroll=MAX(0,scroll-40);
    else {
        char utf8[sizeof(event->lParam)+1]; memcpy(utf8,&event->lParam,sizeof(event->lParam)); utf8[sizeof(event->lParam)]=0;
        if (!(event->wParam&(AX_MOD_CTRL|AX_MOD_CMD|AX_MOD_ALT)) &&
            (unsigned char)utf8[0]>=32 && (unsigned char)utf8[0]!=127 && strlen(input)+strlen(utf8)<sizeof(input)) strcat(input,utf8);
    }
}

static void json_string(const char *s)
{
    putchar('"');
    for (const unsigned char *p=(const unsigned char *)s; *p; ++p) {
        if (*p=='"' || *p=='\\') printf("\\%c",*p);
        else if (*p<32) printf("\\u%04x",*p);
        else putchar(*p);
    }
    putchar('"');
}

/* The headless interface exercises exactly the same C page/actions as the UI. */
static void dump(void)
{
    printf("{\"room\":"); json_string(book.objects[book.room].key);
    printf(",\"focus\":"); json_string(book.objects[book.focus].key);
    printf(",\"kind\":"); json_string(book.ended ? "ended" : book.beat ? "beat" : book.focus ? "focus" : "room");
    printf(",\"image\":"); json_string(book.image);
    printf(",\"text\":"); json_string(book.text);
    printf(",\"choices\":[");
    for (int i=0;i<book.choice_count;++i) {
        struct Choice *c=&book.choices[i];
        printf("%s{\"label\":",i ? "," : ""); json_string(c->label);
        printf(",\"command\":"); json_string(c->command);
        printf(",\"object\":"); json_string(book.objects[c->object].key); printf("}");
    }
    printf("],\"hotspots\":[");
    load_camera();
    int iw=0,ih=0,channels=0,count=0;
    if (*book.image && !stbi_info(book.image,&iw,&ih,&channels)) fail("cannot inspect JPEG: %s",book.image);
    if (!book.beat && !book.focus) {
        for (int i=0;i<book.choice_count;++i) {
            struct Choice *c=&book.choices[i]; struct Vec point; float x,y;
            if (c->focus && anchor_point(book.objects[c->object].key,&point) &&
                project(camera,point,iw,ih,window_width,window_height,&x,&y) &&
                x>=24 && y>=24 && x<=window_width-24 && y<=window_height-24) {
                printf("%s{\"object\":",count++ ? "," : ""); json_string(book.objects[c->object].key);
                printf(",\"x\":%.6f,\"y\":%.6f}",x,y);
            }
        }
    }
    printf("]}\n"); fflush(stdout);
}

static void catalog(void)
{
    int rooms=env_number("ROOMS");
    putchar('['); int count=0;
    for (int i=1;i<MAX_OBJECTS;++i) {
        if (!*book.objects[i].key) continue;
        int room=i; bool seen[MAX_OBJECTS]={false};
        while (room>0 && room<MAX_OBJECTS && !seen[room] && location(room)!=rooms) {
            seen[room]=true; room=location(room);
        }
        if (room<=0 || room>=MAX_OBJECTS || seen[room]) continue;
        printf("%s{\"id\":",count++ ? "," : ""); json_string(book.objects[i].key);
        printf(",\"room\":"); json_string(book.objects[room].key); putchar('}');
    }
    puts("]");
}

int main(int argc,char **argv)
{
    const char *root=".",*adventure="wondertown";
    bool smoke=false,headless=false,check=false,list=false;
    for (int i=1;i<argc;++i) {
        if (!strcmp(argv[i],"--root") && i+1<argc) root=argv[++i];
        else if (!strcmp(argv[i],"--book") && i+1<argc) adventure=argv[++i];
        else if (!strcmp(argv[i],"--check")) check=true;
        else if (!strcmp(argv[i],"--catalog")) list=true;
        else if (!strcmp(argv[i],"--headless")) headless=true;
        else if (!strcmp(argv[i],"--smoke")) smoke=true;
        else if (!strcmp(argv[i],"--screenshot") && i+1<argc) screenshot_path=argv[++i];
        else fail("usage: book [--root PATH] [--book NAME] [--check | --headless | --smoke | --catalog] [--screenshot PATH]");
    }
    init_book(root,adventure);
    if (list) { catalog(); lua_close(book.lua); return 0; }
    if (check || headless) {
        dump();
        char line[512];
        while (headless && fgets(line,sizeof(line),stdin)) {
            line[strcspn(line,"\r\n")]=0;
            if (!strcmp(line,":back") || !strcmp(line,":continue")) back();
            else if (!strcmp(line,":reload")) reload();
            else if (!strncmp(line,":choose ",8)) action(atoi(line+8));
            else if (!strncmp(line,":focus ",7)) {
                for (int i=1;i<MAX_OBJECTS;++i) if (!strcmp(book.objects[i].key,line+7)) { focus_object(i); break; }
            } else command(line,0);
            dump();
        }
        xmlFreeDoc(scene_doc); lua_close(book.lua); return 0;
    }
    axInit();
    if (!axCreateWindow("Book",1100,800,AX_WINDOW_RESIZABLE|AX_WINDOW_DOUBLEBUFFER)) fail("cannot create window");
    axMakeCurrentContext();
    char font[PATH_MAX]; snprintf(font,sizeof(font),"%s/fonts/Literata-VariableFont_opsz,wght.ttf",book.root);
    if (!renderer_init(font)) fail("cannot initialize graphics or load Literata");
    bool running=true,dirty=true; int frames=0;
    while (running) {
        struct AXmessage event;
        while (axPeekMessage(&event)) {
            dirty=true;
            if (event.message==kEventWindowClosed) running=false;
            else if (event.message==kEventKeyDown) key(&event);
            else if (event.message==kEventScrollWheel) scroll=CLAMP(scroll-event.dy*30,0,max_scroll);
            else if (event.message==kEventLeftButtonDown) {
                for (int i=hit_count-1;i>=0;--i) {
                    struct Hit h=hits[i];
                    if (event.x>=h.x && event.x<h.x+h.w && event.y>=h.y && event.y<h.y+h.h) {
                        float dx=event.x-h.x-h.w/2,dy=event.y-h.y-h.h/2;
                        if (h.circle && dx*dx+dy*dy>h.w*h.w/4) continue;
                        action(h.action); scroll=0; hit_count=0; break;
                    }
                }
            }
        }
        if (!running) break;
        if (dirty || smoke) { draw(); dirty=false; }
        if (smoke && ++frames>=3) break;
        axWaitMessage(smoke ? 16 : 250);
    }
    renderer_shutdown(); axShutdown(); xmlFreeDoc(scene_doc); lua_close(book.lua);
    return 0;
}
