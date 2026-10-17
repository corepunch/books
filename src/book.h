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
/* Print a quoted, escaped JSON string to stdout; NULL prints "". */
void json_string(const char *s);

/* Read-only adventure pages. Mutable story state stays private to story.c. */
#define MAX_OBJECTS 4096
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
/* An ending page offers one RETRY choice: back to a decision page, or to the start.
 * A room page lists every carried thing as an ITEM choice: tapping it holds or releases it. */
enum ChoiceKind {
    CHOICE_INVALID, CHOICE_OBJECT, CHOICE_CONTINUE, CHOICE_RETRY, CHOICE_ITEM,
    CHOICE_ASK, /* a talk line: choosing it plays that reply */
    CHOICE_END, /* the talk's last line: always under the questions */
    CHOICE_MAP, /* the map, a disc beside the carried icons on a view */
    CHOICE_KEY  /* a key on the map's phone keypad */
};
/* How an ending resolves the quest; only ending pages carry one. */
enum EndingKind { ENDING_NONE, ENDING_SUCCESS, ENDING_PARTIAL, ENDING_FAILURE };
/* Where a circle without a scene anchor sits: a turn at the picture's edge. */
enum ChoiceEdge { CHOICE_EDGE_NONE, CHOICE_EDGE_LEFT, CHOICE_EDGE_RIGHT, CHOICE_EDGE_BACK };
struct Choice {
    enum ChoiceKind kind;
    choiceLabel_t label;
    command_t command;
    int object;
    enum ChoiceEdge edge;
};
struct BookPage {
    enum PageKind kind;
    bool talk; /* questions are lines in a bottom band, and one of them ends the talk */
    bool keypad; /* a talk whose keys sit in a grid above its last line: the phone */
    bool read; /* a document: prose in the reading region, and Continue to put it down.
                  A beat without it is a shot: no prose and no Next. */
    identifier_t id;
    struct Choice choices[MAX_CHOICES];
    int choice_count, room;
    int held; /* object of the carried thing the reader is holding, or zero */
    enum EndingKind ending;
    filePath_t image, clip; /* clip is empty when the page is only a still */
    int clip_from, clip_to;  /* milliseconds; zero clip_to plays to the end */
    bool loop;               /* the clip repeats behind a room's circles */
    assetName_t camera;
    storyText_t text;
};

/* Story definition, after the Virtual Cinema database of The X-Files Game (1998).
 * A title holds nodes (chapters) of locations. A location holds viewpoints of views
 * (stills with circles: navs, explorables and charviews), charviews (a character in
 * frame, with conversation lines), assets (shots and documents), endings, maps for
 * travel and action lists. Variables, enable flags and carried icons are the state;
 * triggers run actions on enter, leave and end, and every circle or line may run actions
 * when chosen. src/storyxml.c reads books/<name>/title.xml and
 * books/<name>/locations/<location>.xml into these tables; src/story.c validates,
 * publishes and runs them. Indices name rows of the story's tables; -1 is none. */
#define MAX_STORY_PAGES 2048
#define MAX_STORY_HOTSPOTS 8192
#define MAX_STORY_RESPONSES 4096
#define MAX_STORY_ACTIONS 16384
#define MAX_STORY_TERMS 32768
#define MAX_STORY_VARIABLES 1024
#define MAX_STORY_STRINGS 1024
#define MAX_STORY_ICONS 256
#define MAX_STORY_CHARACTERS 128
#define MAX_STORY_NODES 64
#define MAX_STORY_LOCATIONS 256
#define MAX_STORY_VIEWPOINTS 1024
#define MAX_STORY_RECORDS 1024
#define MAX_STORY_FLAGS MAX_STORY_HOTSPOTS
/* Plain circles and held-icon circles share one page. At most five are on screen. */
#define MAX_PAGE_CHOICES 16

/* A variable is a boolean, an integer, a character or a string (its value indexes
 * story->strings). Booleans are 0 or 1. */
enum StoryVariableType { VARIABLE_BOOL, VARIABLE_INT, VARIABLE_CHAR, VARIABLE_STRING };
struct StoryVariable { const char *id, *text; enum StoryVariableType type; int initial; };
/* Icons the reader can carry and hold, as X-Files's inventory, evidence, idea (a topic),
 * emotion (a tone of voice) and action icons. Holding one offers only its uses. Views
 * show carried inventory and evidence; charviews show every carried icon. */
enum StoryIconKind { ICON_INVENTORY, ICON_EVIDENCE, ICON_IDEA, ICON_EMOTION, ICON_ACTION };
struct StoryIcon {
    const char *id, *name, *text;
    enum StoryIconKind kind;
    int where;    /* location it lies in at the start, or -1 */
    bool carried; /* the reader starts with it */
};
struct StoryCharacter { const char *id, *name, *text; };

/* A condition, compiled to postfix terms over variables, icons, flags and pages. */
enum StoryTermKind {
    TERM_VARIABLE, TERM_NUMBER, TERM_STRING, TERM_HAS, TERM_HOLDING, TERM_ENABLED, TERM_VISITED,
    TERM_NOT, TERM_AND, TERM_OR, TERM_EQ, TERM_NE, TERM_LT, TERM_LE, TERM_GT, TERM_GE
};
struct StoryTerm { enum StoryTermKind kind; int value; };
struct StoryCondition { int first, count; const char *source; }; /* no terms: always true */

/* X-Files's action ops: SetVariable, SetEnabled, GoTo, DoActionList, ShowInterface and
 * CallScript, with conditions; giving and removing icons; and if/else blocks. */
enum StoryActionOp {
    ACTION_INVALID, ACTION_SET, ACTION_ADD, ACTION_ENABLE, ACTION_DISABLE, ACTION_GIVE,
    ACTION_REMOVE, ACTION_GOTO, ACTION_CALL, ACTION_IF, ACTION_SHOW, ACTION_HIDE, ACTION_SCRIPT
};
struct StoryActions { int first, count; };
struct StoryAction {
    enum StoryActionOp op;
    int target;          /* variable, flag, icon, page or interface record */
    int value;           /* SET: a literal, or a variable when from_variable; ADD: the amount */
    bool from_variable;
    struct StoryCondition test;       /* IF */
    struct StoryActions then, otherwise;
    const char *name, *args;          /* SCRIPT: a named engine script, kept for tools */
};
enum StoryEvent { EVENT_ENTER, EVENT_LEAVE, EVENT_END, EVENT_COUNT };
struct StoryTriggers { struct StoryActions on[EVENT_COUNT]; };

/* Something the reader chooses: a circle on a view or map, or a line on a charview. */
enum StoryHotspotKind {
    HOTSPOT_INVALID, HOTSPOT_NAV, HOTSPOT_EXPLORABLE, HOTSPOT_CHARVIEW, HOTSPOT_CONVERSATION,
    HOTSPOT_DESTINATION, HOTSPOT_ITEM /* an interface item */
};
/* A nav may sit on a picture edge instead of an anchor: turning within a viewpoint. */
enum StoryEdge { EDGE_NONE, EDGE_LEFT, EDGE_RIGHT, EDGE_BACK };
struct StoryHotspot {
    enum StoryHotspotKind kind;
    const char *id;        /* names its enable flag, or NULL */
    const char *label, *anchor;
    enum StoryEdge edge;
    int target;            /* the page it leads to, or -1 when its actions decide */
    struct StoryCondition test;
    int with, take;        /* icons: offered only while holding with; take picks up an icon lying here */
    bool ends;             /* a conversation line pinned under the others; one per held state */
    int flag;              /* enable flag, or -1 */
    struct StoryActions click;
};
/* A scene-specific response while holding an icon. The first that applies is shown. */
struct StoryResponse { int icon; struct StoryCondition test; const char *text; };

enum StoryPageKind {
    STORY_INVALID,
    STORY_VIEW,         /* a still with circles: navs, explorables, charviews */
    STORY_CHARVIEW,     /* a character in frame; conversation lines in a band */
    STORY_ASSET,        /* a shot, or a document with .read; then .next */
    STORY_CONVERSATION, /* a conversation line's reply; then back to its charview */
    STORY_ENDING,       /* success, partial or failure, with a retry */
    STORY_MAP,          /* travel: destinations as circles on a map picture */
    STORY_ACTIONLIST    /* invisible: runs its actions, which must go somewhere */
};
struct StoryPage {
    const char *id;
    enum StoryPageKind kind;
    int location, viewpoint;  /* viewpoint is -1 outside one */
    int character, parent;    /* a charview's character; a conversation's charview, a charview's view */
    const char *direction;    /* a view's compass direction within its viewpoint */
    const char *camera;       /* consecutive pages of one moment may share a camera */
    const char *clip;         /* bare file name in books/<name>/clips/, or NULL; the still is the poster */
    int clip_from, clip_to;   /* a slice of the clip in milliseconds; zero to is the whole clip */
    bool loop;                /* a view's clip loops behind its circles */
    const char *sound;        /* an ambient sound, kept for tools */
    bool read;                /* fmv asset only: the reader is reading. Text stays, and Continue dismisses it. */
    const char *text;
    int hotspot_first, hotspot_count;
    int response_first, response_count;
    struct StoryTriggers triggers;
    int next;                 /* asset: where it goes; conversation: -1 returns to the charview */
    enum EndingKind ending;
    int retry;                /* failure or partial ending: an earlier view to try again from, or -1 */
    struct StoryActions actions; /* action list body */
};
struct StoryNode { const char *id, *name, *text; struct StoryTriggers triggers; };
struct StoryLocation {
    const char *id, *name, *text, *file, *sound;
    int node, first, count; /* its pages: pages[first] to pages[first + count - 1] */
    struct StoryTriggers triggers;
};
struct StoryViewpoint { const char *id; int location; };
/* The map's records, after The X-Files Game's PDA: notes, email, photos, phone numbers and
 * interface screens. The map over a view lists them, opens them and dials the phone. */
enum StoryRecordKind { RECORD_NOTE, RECORD_EMAIL, RECORD_PHOTO, RECORD_PHONE, RECORD_INTERFACE };
struct StoryRecord {
    enum StoryRecordKind kind;
    const char *id, *title, *from, *camera, *number, *text;
    int target;            /* a phone number's page */
    struct StoryCondition test;
    int flag;
    int hotspot_first, hotspot_count; /* an interface's items */
};
struct StoryFlag { const char *id; bool initial; };
struct Story {
    const char *name;
    int start;
    const char *continue_label, *retry_label, *restart_label;
    bool fmv; /* the picture is the page. Views, shots and endings draw no prose.
                 Continue exists only on an asset with .read. */
    const struct StoryPage *pages;          int page_count;
    const struct StoryHotspot *hotspots;    int hotspot_count;
    const struct StoryResponse *responses;  int response_count;
    const struct StoryAction *actions;      int action_count;
    const struct StoryTerm *terms;          int term_count;
    const struct StoryVariable *variables;  int variable_count;
    const char *const *strings;             int string_count;
    const struct StoryIcon *icons;          int icon_count;
    const struct StoryCharacter *characters; int character_count;
    const struct StoryNode *nodes;          int node_count;
    const struct StoryLocation *locations;  int location_count;
    const struct StoryViewpoint *viewpoints; int viewpoint_count;
    const struct StoryRecord *records;      int record_count;
    const struct StoryFlag *flags;          int flag_count;
};
/* A book: books/<name>/title.xml declares its variables, characters, icons, records and
 * nodes of locations, and books/<name>/locations/<location>.xml holds that location's
 * pages. Errors name file and line. Strings stay valid until story_unload(). */
const struct Story *story_load(const char *root, const char *name);
void story_unload(void);
/* The XML line where a loaded page begins, or zero. */
int story_line(int page);
const char *story_icon_kind_name(enum StoryIconKind kind);
const char *story_page_kind_name(enum StoryPageKind kind);
const char *story_hotspot_kind_name(enum StoryHotspotKind kind);

const char *book_name(void);
/* Read books/<name>/ under root, validate it and show the start page. */
void book_init(const char *root, const char *name);
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
/* The icon for a carried thing's object: its painting, else its render; false when neither exists. */
bool book_item_image(int object, filePath_t path);

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
/* Vertical darkening: clear at the top of bounds, the colour's alpha at the bottom. */
void renderer_shade(frect_t bounds, uint32_t rgba);
void renderer_ring(frect_t bounds, uint32_t rgba);
/* Rounded rectangle, filled when stroke is zero, else an inner outline of that width. */
void renderer_round_rect(frect_t bounds, float corner, float stroke, uint32_t rgba);
void renderer_line(fvec2_t start, fvec2_t end, uint32_t rgba);
/* Circular masks affect subsequent drawing until explicitly ended. */
void renderer_reveal_begin(fvec2_t center, float radius);
void renderer_reveal_end(void);
void renderer_opacity(float opacity);
isize2_t renderer_image_size(const char *path);
bool renderer_image(const char *path, frect_t bounds);
/* Draw a carried thing's icon, reduced once at load and cropped to cover bounds. */
bool renderer_icon(const char *path, frect_t bounds);
/* Upload one BGRA frame, or redraw the last uploaded frame when pixels are NULL. */
bool renderer_video(const void *bgra, isize2_t size, int stride, frect_t bounds);
void renderer_video_discard(void);

/* Full-motion clip in the picture. Headless play never calls these and shows the poster. */
void video_use_poster(bool poster);
/* Play a slice from from_ms to to_ms (zero: the end), repeating it when loop is set. */
bool video_open(const char *path, int from_ms, int to_ms, bool loop);
void video_close(void);
bool video_playing(void);
/* True after the open clip has played to the end. Smoke captures stay on the poster. */
bool video_ended(void);
/* Cover-crop the current frame into the viewport. False until the first decoded frame. */
bool video_frame(frect_t viewport);
/* Drop the path cache so the next draw reloads replaced raster artwork. */
void renderer_invalidate_image(void);

/* Shared only by the renderer and text rasterizer. */
texture_t renderer_texture_create(isize2_t size, bool glyph, const void *pixels);
void renderer_texture_destroy(texture_t texture);
void renderer_quad(frect_t bounds, uint32_t rgba, texture_t texture, int glyph);
frect_t renderer_bounds(void);

/* Text rendering */
#define MAX_GLYPHS 512
#define TEXT_SPACING_SCALE 0.73f
#define TEXT_BASE_SIZE 38.0f

bool text_init(const char *font_path);
void text_shutdown(void);
float text_draw(const char *text, fvec2_t origin, float size, float max_width, uint32_t rgba);
float text_height(const char *text, float size, float max_width);
fsize2_t text_size(const char *text, float size, float max_width);
/* Offsets from a text_draw origin for one font size: line advance, first baseline, capital height. */
struct TextMetrics { float line, baseline, cap_height; };
struct TextMetrics text_metrics(float size);
/* A label box: the text's width plus padding, and its capital-height band plus padding. */
frect_t text_label_box(const char *text, float size, float max_width, fvec2_t padding);
/* Draw text centred in a box by its capital-height band; returns the bottom of the text. */
float text_draw_centered(const char *text, frect_t box, float size, uint32_t rgba);

/* Scene projection */
/* Read fixed cameras, reading regions and anchors from the book's .blks files. */
void scene_load(const char *rooms, const char *camera_name);
void scene_shutdown(void);
/* True when the loaded camera exists, and when its scene names this anchor. */
bool scene_has_camera(void);
bool scene_has_anchor(const char *key);
bool scene_project_anchor(const char *key, isize2_t image, fsize2_t viewport, fvec2_t *point);
struct TextRegion {
    frect_t bounds; /* Returned in logical page coordinates after the image crop. */
    float font_size;
    bool authored;
};
#define MAX_TEXT_REGIONS 2
typedef struct TextRegion textRegionList_t[MAX_TEXT_REGIONS];
/* Reading order; form-feed in prose begins the next authored region. */
int scene_text_regions(isize2_t image, fsize2_t viewport, textRegionList_t regions);

/* Graphical interface */
#define HOTSPOT_DIAMETER 48.0f
#define HOTSPOT_GAP (HOTSPOT_DIAMETER / 2)
#define HOTSPOT_TEXT_GAP 12.0f
/* Each circle carries its choice label as a caption, like a gamebook's printed option. */
#define CAPTION_TEXT_SIZE 22.0f
#define CAPTION_MAX_WIDTH 230.0f
#define CAPTION_PADDING 8.0f
#define CAPTION_GAP 6.0f
#define CAPTION_CORNER_RADIUS 8.0f
#define BUTTON_CORNER_RADIUS 14.0f
/* Carried things sit in a row of round icons along the bottom-left edge of a room page. */
#define ITEM_DIAMETER 64.0f
#define ITEM_GAP 22.0f
#define ITEM_CAPTION_TEXT_SIZE 18.0f
#define ITEM_CAPTION_MAX_WIDTH 120.0f
/* The map's phone: three keys a row, above the line that puts it away. */
#define KEYPAD_COLUMNS 3
#define KEY_WIDTH 150.0f
#define KEY_GAP 12.0f
/* A talk band: prose, then the ask-lines, then the line that ends it. Type tracks the window. */
#define ASK_MARGIN 36.0f
#define ASK_ROW_PAD 14.0f
#define ASK_TOP_PAD 20.0f
#define ASK_PROSE_GAP 16.0f
#define ASK_LINE_GAP 8.0f
#define ASK_END_GAP 18.0f
#define ASK_VEIL_FEATHER 72.0f
#define talk_type_size(height) (TEXT_BASE_SIZE * (height) / (float)UI_HEIGHT)
struct Hotspot { fvec2_t anchor, center; int choice; };
typedef struct Hotspot hotspotList_t[MAX_CHOICES];
/* Returns false if the viewport cannot accommodate every marker. */
bool hotspots_place(struct Hotspot *spots, int count, fsize2_t viewport, frect_t prose);
bool hotspots_place_regions(struct Hotspot *spots, int count, fsize2_t viewport,
                            const struct TextRegion *regions, int region_count);
struct HotspotTarget { identifier_t key; int choice; };
typedef struct HotspotTarget hotspotTargetList_t[MAX_CHOICES];
int scene_layout_hotspots(isize2_t image, fsize2_t viewport, const struct HotspotTarget *targets,
                          int count, const struct TextRegion *regions, int region_count, hotspotList_t spots);

/* One layout supplies rendering, hit testing and headless inspection. */
/* circle: a scene hotspot; item: a carried thing in the inventory row. Both hit on the disc or caption. */
struct PageControl { frect_t bounds; frect_t caption; int choice; bool circle, item; };
struct ProseLayout { struct TextRegion region; storyText_t text; float content_height; };
struct PageLayout {
    int max_scroll;
    struct ProseLayout prose[MAX_TEXT_REGIONS];
    int prose_count;
    hotspotList_t spots;
    int spot_count;
    struct PageControl controls[MAX_CHOICES];
    int control_count;
    frect_t veil;    /* solid dark band behind the lines; empty on other pages */
    frect_t feather; /* soft falloff above the veil */
    float rule;      /* hairline above the line that ends the talk; zero when there is none */
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
void headless_run(bool interactive, fsize2_t viewport);
void headless_catalog(void);

#endif
