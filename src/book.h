#ifndef BOOK_H
#define BOOK_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <limits.h>

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
/* Map a normalized rectangle into another rectangle, including its offset. */
frect_t frect_relative(frect_t relative, frect_t bounds);
bool frect_ellipse_contains_point(frect_t rect, fvec2_t point);

/* Shared helpers */
_Noreturn void fail(const char *format, ...);
void copy(char *dst, size_t size, const char *src);
void lower(char *s);

/* Read-only adventure pages. Mutable story state stays private to book.c. */
#define MAX_OBJECTS 256
#define MAX_CHOICES 512
/* String capacities include the terminating null byte. */
#define MAX_IDENTIFIER 128
#define MAX_CHOICE_LABEL 512
#define MAX_COMMAND 512
#define MAX_ASSET_NAME 512
#define MAX_STORY_TEXT 32768

typedef char filePath_t[PATH_MAX];
typedef char identifier_t[MAX_IDENTIFIER];
typedef char choiceLabel_t[MAX_CHOICE_LABEL];
typedef char command_t[MAX_COMMAND];
typedef char assetName_t[MAX_ASSET_NAME];
typedef char storyText_t[MAX_STORY_TEXT];

struct Object {
    identifier_t key;
};
/* Zero is deliberately invalid: missing initialization must fail at publication. */
enum PageKind { PAGE_INVALID, PAGE_ROOM, PAGE_BEAT, PAGE_ENDED };
/* An ending page offers one RETRY choice: back to a decision page, or to the start. */
enum ChoiceKind { CHOICE_INVALID, CHOICE_OBJECT, CHOICE_CONTINUE, CHOICE_RETRY };
/* How an ending resolves the quest; only ending pages carry one. */
enum EndingKind { ENDING_NONE, ENDING_SUCCESS, ENDING_PARTIAL, ENDING_FAILURE };
struct Choice {
    enum ChoiceKind kind;
    choiceLabel_t label;
    command_t command;
    int object;
};
struct BookPage {
    enum PageKind kind;
    struct Choice choices[MAX_CHOICES];
    int choice_count, room;
    enum EndingKind ending;
    filePath_t image;
    assetName_t camera;
    storyText_t text;
};

/* Story definition. Each books/<name>.c is data: a table of pages that src/story.c
 * validates, publishes and navigates. Page IDs are unique; targets name page IDs. */
#define MAX_STORY_PAGES 512
#define MAX_PAGE_CHOICES 3
typedef unsigned int storyFacts_t;
enum StoryNode {
    STORY_INVALID,
    STORY_DECISION, /* a room page: 1..3 choices, each a circle on its scene anchor */
    STORY_PASSAGE,  /* a beat page: text, picture and Continue to .next */
    STORY_CHECK,    /* invisible: goes to .next when .fact is set, else to .otherwise */
    STORY_ENDING    /* success, partial or failure, with a retry target */
};
struct StoryChoice {
    const char *label, *anchor, *target;
    storyFacts_t requires, excludes; /* offered only when all requires and no excludes are set */
};
struct StoryPage {
    const char *id;
    enum StoryNode kind;
    const char *location; /* the place the page is in; a scene anchor key or a plain name */
    const char *camera;   /* consecutive pages of one moment may share a camera */
    const char *text;
    struct StoryChoice choices[MAX_PAGE_CHOICES];
    const char *next;      /* passage: Continue target; check: target when .fact is set */
    storyFacts_t sets;     /* facts set when the page is shown */
    storyFacts_t fact;     /* check only */
    const char *otherwise; /* check only */
    enum EndingKind ending;
    const char *retry;     /* failure or partial ending: an earlier decision page to try again
                              from; by default the reader retries their last decision */
};
struct Story {
    const char *name, *start;
    const char *continue_label, *retry_label, *restart_label;
    const struct StoryPage *pages;
    int page_count;
};
/* The one story compiled into this build, defined by books/<name>.c. */
const struct Story *book_story(void);

const char *book_name(void);
void book_init(const char *root);
void book_shutdown(void);
/* Borrowed until the next accepted action/reload. Copy to retain an outgoing page. */
const struct BookPage *book_page(void);
const struct Object *book_object(int object);
const char *book_root(void);
const char *book_rooms(void);
const char *book_page_kind_name(enum PageKind kind);
const char *book_choice_kind_name(enum ChoiceKind kind);
const char *book_ending_kind_name(enum EndingKind kind);
/* Every input adapter resolves a current choice and calls this dispatcher. */
bool book_action(int index);
bool book_command(const char *input);
bool book_continue(void);
bool book_choose_object(const char *key);
void book_reload(void);
/* Return the object's room, or zero when it has none. */
int book_object_room(int object);

/* Rendering */
/* Native layer and texture handles keep Objective-C out of the C modules. */
typedef void *texture_t;
bool renderer_init(void *layer);
void metal_shutdown(void);
void renderer_shutdown(void);
void renderer_clip(frect_t bounds);
void renderer_unclip(void);
bool renderer_screenshot(const char *path);
bool renderer_begin(isize2_t size, float scale);
void renderer_present(void);
void renderer_rect(frect_t bounds, uint32_t rgba);
void renderer_ring(frect_t bounds, uint32_t rgba);
void renderer_line(fvec2_t start, fvec2_t end, uint32_t rgba);
/* Circular masks affect subsequent drawing until explicitly ended. */
void renderer_reveal_begin(fvec2_t center, float radius);
void renderer_reveal_end(void);
void renderer_opacity(float opacity);
isize2_t renderer_image_size(const char *path);
bool renderer_image(const char *path, frect_t bounds);
/* Drop the path cache so the next draw reloads replaced raster artwork. */
void renderer_invalidate_image(void);

/* Shared only by the renderer and text rasterizer. */
texture_t renderer_texture_create(isize2_t size, bool glyph, const void *pixels);
void renderer_texture_destroy(texture_t texture);
void renderer_quad(frect_t bounds, uint32_t rgba, texture_t texture, int glyph);
frect_t renderer_bounds(void);

/* Text rendering */
#define MAX_GLYPHS 512
#define TEXT_SPACING_SCALE 0.67f
#define TEXT_BASE_SIZE 36.0f
#define TEXT_MIN_FIT_RATIO 0.8f

bool text_init(const char *font_path);
void text_shutdown(void);
float text_draw(const char *text, fvec2_t origin, float size, float max_width, uint32_t rgba);
float text_height(const char *text, float size, float max_width);
fsize2_t text_size(const char *text, float size, float max_width);
float text_fit_size(const char *text, float preferred_size, fsize2_t bounds);

/* Scene projection */
/* Read fixed cameras, reading regions and anchors from the book's .blks files. */
void scene_load(const char *rooms, const char *camera_name);
void scene_shutdown(void);
bool scene_project_anchor(const char *key, isize2_t image, fsize2_t viewport, fvec2_t *point);
struct TextRegion {
    frect_t bounds; /* Returned in logical page coordinates after the image crop. */
    float font_size;
    bool authored;
};
struct TextRegion scene_text_region(isize2_t image, fsize2_t viewport);

/* Graphical interface */
#define HOTSPOT_DIAMETER 48.0f
#define HOTSPOT_GAP (HOTSPOT_DIAMETER / 2)
#define HOTSPOT_TEXT_GAP 12.0f
/* Each circle carries its choice label as a caption, like a gamebook's printed option. */
#define CAPTION_TEXT_SIZE 22.0f
#define CAPTION_MAX_WIDTH 230.0f
#define CAPTION_PADDING 8.0f
#define CAPTION_GAP 6.0f
struct Hotspot { fvec2_t anchor, center; int choice; };
typedef struct Hotspot hotspotList_t[MAX_CHOICES];
/* Returns false if the viewport cannot accommodate every marker. */
bool hotspots_place(struct Hotspot *spots, int count, fsize2_t viewport, frect_t prose);
struct HotspotTarget { identifier_t key; int choice; };
typedef struct HotspotTarget hotspotTargetList_t[MAX_CHOICES];
int scene_layout_hotspots(isize2_t image, fsize2_t viewport, const struct HotspotTarget *targets,
                          int count, bool has_text, hotspotList_t spots);

/* One layout supplies rendering, hit testing and headless inspection. */
struct PageControl { frect_t bounds; frect_t caption; int choice; bool circle; };
struct PageLayout {
    struct TextRegion region;
    float font_size;
    int max_scroll;
    hotspotList_t spots;
    int spot_count;
    struct PageControl controls[MAX_CHOICES];
    int control_count;
};
void page_layout(const struct BookPage *page, isize2_t image, fsize2_t viewport,
                 struct PageLayout *layout);
const struct PageControl *page_hit_test(const struct PageLayout *layout, fvec2_t point);

/* Presentation animation, independent of the adventure and graphics backend. Times are seconds. */
struct Transition {
    double started;
    fvec2_t origin;
    float initial_radius;
    bool active, reveal;
};
struct TransitionFrame {
    fvec2_t center;
    float radius, overlay_opacity;
    bool revealing, active;
};
void transition_start(struct Transition *transition, double now, fvec2_t point,
                      fsize2_t viewport, float initial_radius, bool reveal);
struct TransitionFrame transition_sample(struct Transition *transition, double now,
                                         fsize2_t viewport);

enum { UI_WIDTH = 1100, UI_HEIGHT = 800 };
void ui_run(bool smoke, const char *screenshot, double smoke_transition);
/* AppKit/UIKit forward hotspot/action taps and scrolling to the C page interface. */
void ui_init(void);
void ui_draw(void);
void ui_reload(void);
void ui_click(fvec2_t point);
void ui_scroll(float delta);
bool ui_animating(void);
void ui_preview(double seconds);

/* Headless interface */
void headless_run(bool interactive);
void headless_catalog(void);

#endif
