#ifndef BOOK_H
#define BOOK_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <limits.h>

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

/* 2D geometry: positions, extents, and rectangles in logical or pixel units. */
typedef struct { float x, y; } fvec2_t;
typedef struct { int x, y; } ivec2_t;
typedef struct { float width, height; } fsize2_t;
typedef struct { int width, height; } isize2_t;
typedef struct { fvec2_t origin; fsize2_t size; } frect_t;
typedef struct { ivec2_t origin; isize2_t size; } irect_t;

fvec2_t fvec2(float x, float y);
fvec2_t fvec2_add(fvec2_t a, fvec2_t b);
fvec2_t fvec2_sub(fvec2_t a, fvec2_t b);
fvec2_t fvec2_scale(fvec2_t v, float scale);
fsize2_t fsize2(float width, float height);
fsize2_t fsize2_scale(fsize2_t size, float scale);
fsize2_t fsize2_max(fsize2_t a, fsize2_t b);
bool fsize2_is_empty(fsize2_t size);
frect_t frect(fvec2_t origin, fsize2_t size);
frect_t frect_from_size(fsize2_t size);
frect_t frect_translate(frect_t rect, fvec2_t offset);
frect_t frect_inset(frect_t rect, fvec2_t inset);
frect_t frect_intersection(frect_t a, frect_t b);
/* Point hits include the top/left edges and exclude the bottom/right edges. */
bool frect_contains_point(frect_t rect, fvec2_t point);
/* Coverage includes all edges, for projected anchors and containment. */
bool frect_covers_point(frect_t rect, fvec2_t point);
bool frect_overlaps(frect_t a, frect_t b);

ivec2_t ivec2(int x, int y);
ivec2_t ivec2_add(ivec2_t a, ivec2_t b);
ivec2_t ivec2_sub(ivec2_t a, ivec2_t b);
ivec2_t ivec2_scale(ivec2_t v, int scale);
isize2_t isize2(int width, int height);
isize2_t isize2_scale(isize2_t size, int scale);
isize2_t isize2_max(isize2_t a, isize2_t b);
bool isize2_is_empty(isize2_t size);
irect_t irect(ivec2_t origin, isize2_t size);
irect_t irect_from_size(isize2_t size);
irect_t irect_translate(irect_t rect, ivec2_t offset);
irect_t irect_inset(irect_t rect, ivec2_t inset);
irect_t irect_intersection(irect_t a, irect_t b);
/* Point hits include the top/left edges and exclude the bottom/right edges. */
bool irect_contains_point(irect_t rect, ivec2_t point);
/* Coverage includes all edges, for projected anchors and containment. */
bool irect_covers_point(irect_t rect, ivec2_t point);
bool irect_overlaps(irect_t a, irect_t b);

fvec2_t ivec2_to_float(ivec2_t v);
fsize2_t isize2_to_float(isize2_t size);
frect_t irect_to_float(irect_t rect);
ivec2_t fvec2_floor(fvec2_t v);
isize2_t fsize2_ceil(fsize2_t size);
isize2_t fsize2_round(fsize2_t size);
fvec2_t fvec2_with_x(fvec2_t v, float x);
fvec2_t fvec2_with_y(fvec2_t v, float y);
float fvec2_length_squared(fvec2_t v);
fvec2_t frect_bottom_right(frect_t rect);
fvec2_t frect_center(frect_t rect);
frect_t frect_center_at(frect_t rect, fvec2_t center);
frect_t frect_scale(frect_t rect, float scale);
frect_t frect_expand(frect_t rect, fsize2_t extra);
frect_t frect_flip_y(frect_t rect, float height);
/* Preserve aspect ratio and center the image, cropping overflow. */
frect_t frect_cover(fsize2_t image, frect_t bounds);
bool frect_ellipse_contains_point(frect_t rect, fvec2_t point);

/* Shared helpers */
_Noreturn void fail(const char *format, ...);
void copy(char *dst, size_t size, const char *src);
void lower(char *s);

/* ZIL host and current page */
/* ZIL is the world model. C owns only the coroutine, current page and input. */
#define MAX_OBJECTS 256
#define MAX_CHOICES 512
/* String capacities include the terminating null byte. */
#define MAX_IDENTIFIER 128
#define MAX_WORD 128
#define MAX_NOUN 256
#define MAX_DESCRIPTION 256
#define MAX_CHOICE_LABEL 512
#define MAX_COMMAND 512
#define MAX_ASSET_NAME 512
#define MAX_STORY_TEXT 32768
#define MAX_NOUN_PHRASE (MAX_WORD + MAX_NOUN)
#define MAX_MODULE_NAME 384

typedef char filePath_t[PATH_MAX];
typedef char identifier_t[MAX_IDENTIFIER];
typedef char word_t[MAX_WORD];
typedef char noun_t[MAX_NOUN];
typedef char description_t[MAX_DESCRIPTION];
typedef char choiceLabel_t[MAX_CHOICE_LABEL];
typedef char command_t[MAX_COMMAND];
typedef char assetName_t[MAX_ASSET_NAME];
typedef char storyText_t[MAX_STORY_TEXT];
typedef char nounPhrase_t[MAX_NOUN_PHRASE];
typedef char moduleName_t[MAX_MODULE_NAME];

struct Object {
    identifier_t symbol, key;
    noun_t noun;
    word_t adjective;
    description_t desc;
};
struct Choice {
    choiceLabel_t label;
    command_t command;
    int object;
    bool focus;
};
struct Book {
    struct Object objects[MAX_OBJECTS];
    struct Choice choices[MAX_CHOICES];
    int choice_count, room, focus;
    bool beat, ended;
    filePath_t root;
    identifier_t adventure;
    filePath_t rooms, image;
    assetName_t camera;
    storyText_t text, room_text, focus_text;
};

extern struct Book book;

void book_init(const char *root, const char *adventure);
void book_shutdown(void);
void book_command(const char *input, int subject);
void book_back(void);
void book_focus_object(int object);
void book_action(int index);
void book_reload(void);
/* Return the object's enclosing room, or zero when it has none. */
int book_object_room(int object);

/* Rendering */
#define MAX_SHADER_LOG 2048
typedef char shaderLog_t[MAX_SHADER_LOG];

bool renderer_init(void);
void renderer_shutdown(void);
void renderer_resize(isize2_t size, float scale);
void renderer_clip(frect_t bounds);
void renderer_unclip(void);
bool renderer_screenshot(const char *path);
void renderer_clear(void);
void renderer_rect(frect_t bounds, uint32_t rgba);
void renderer_ring(frect_t bounds, uint32_t rgba);
isize2_t renderer_image_size(const char *path);
bool renderer_image(const char *path, frect_t bounds);
/* Drop the path cache so the next draw reloads a replaced JPEG. */
void renderer_invalidate_image(void);

/* Shared only by the renderer and text rasterizer. */
GLuint renderer_texture_create(isize2_t size, GLenum format, const void *pixels);
void renderer_quad(frect_t bounds, uint32_t rgba, GLuint texture, int glyph);
frect_t renderer_bounds(void);

/* Text rendering */
#define MAX_GLYPHS 512

bool text_init(const char *font_path);
void text_shutdown(void);
float text_draw(const char *text, fvec2_t origin, float size, float max_width, uint32_t rgba);
float text_height(const char *text, float size, float max_width);

/* Scene projection */
/* Read fixed cameras and anchors from the book's .blks files. */
void scene_load(const char *rooms, const char *camera_name);
void scene_shutdown(void);
bool scene_project_anchor(const char *key, isize2_t image, fsize2_t viewport, fvec2_t *point);

/* Graphical interface */
#define HOTSPOT_DIAMETER 48.0f

#define MAX_HITS (MAX_CHOICES * 2) /* Each choice can have a marker and a text hit. */

enum { UI_WIDTH = 1100, UI_HEIGHT = 800 };
void ui_run(bool smoke, const char *screenshot);

/* Headless interface */
void headless_run(bool interactive);
void headless_catalog(void);

#endif
