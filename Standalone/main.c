#define _XOPEN_SOURCE 700
#include <platform.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <limits.h>
#include <unistd.h>
#include <math.h>
#include "render.h"

struct Hit { float x, y, w, h; int action; int circle; };
static struct Hit hits[256];
static int hit_count, module_ref, view_ref, scroll;
static lua_State *L;
static char input[512];
static const char *screenshot_path;
static int max_scroll, show_text = 1;
static float window_width = 1100, window_height = 800;

static void fail(const char *message)
{
    fprintf(stderr, "Book: %s\n", message);
    exit(EXIT_FAILURE);
}

static void call(const char *method, const char *string, int number)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, module_ref);
    lua_getfield(L, -1, method);
    lua_remove(L, -2);
    int argc = 0;
    if (string) { lua_pushstring(L, string); argc = 1; }
    else if (number) { lua_pushinteger(L, number); argc = 1; }
    if (lua_pcall(L, argc, 1, 0) != LUA_OK) fail(lua_tostring(L, -1));
    if (!lua_istable(L, -1)) fail("presentation did not return a view");
    luaL_unref(L, LUA_REGISTRYINDEX, view_ref);
    view_ref = luaL_ref(L, LUA_REGISTRYINDEX);
    scroll = 0;
    hit_count = 0;
}

static const char *string_field(const char *key)
{
    lua_getfield(L, -1, key);
    const char *value = lua_tostring(L, -1);
    lua_pop(L, 1);
    return value ? value : "";
}

static float number_field(const char *key)
{
    lua_getfield(L, -1, key);
    float value = (float)lua_tonumber(L, -1);
    lua_pop(L, 1);
    return value;
}

/* Text and markers share the scene; only the letterforms receive a shadow. */
static float story_text(const char *text, float x, float y, float size, float width)
{
    renderer_text(text, x + 1, y + 2, size, width, 0x120B07E6);
    return renderer_text(text, x, y, size, width, 0xF4E6CAFF);
}

static void add_hit(float x, float y, float w, float h, int action, int circle)
{
    if (w > 0 && h > 0 && hit_count < (int)(sizeof(hits) / sizeof(*hits)))
        hits[hit_count++] = (struct Hit){x, y, w, h, action, circle};
}

static void draw(void)
{
    struct AXsize size;
    axGetSize(&size);
    window_width = size.width;
    window_height = size.height;
    axBeginPaint();
    renderer_resize(size.width, size.height, axGetScaling());
    renderer_clear();
    hit_count = 0;
    lua_rawgeti(L, LUA_REGISTRYINDEX, view_ref);
    float scene_w = window_width, scene_h = window_height;
    float iw = number_field("source_width"), ih = number_field("source_height");
    if (iw <= 0 || ih <= 0) { iw = 1920; ih = 1440; }
    float scale = fmaxf(scene_w / iw, scene_h / ih);
    float w = iw * scale, h = ih * scale, x = (scene_w - w) / 2, y = (scene_h - h) / 2;
    /* Scener owns scene rendering. The image and projected anchors share this crop. */
    if (!renderer_image(string_field("image"), x, y, w, h))
        fail("cannot display Scener image; run `make render ROOM=workshop-new` from Book");
    lua_getfield(L, -1, "hotspots");
    for (size_t i = 1; i <= lua_rawlen(L, -1); ++i) {
        lua_rawgeti(L, -1, (lua_Integer)i);
        float hx = number_field("x"), hy = number_field("y");
        int action = number_field("action");
        float cx = x + hx * w, cy = y + hy * h;
        /* Never move a marker off its anchor to avoid another UI element. */
        if (cx >= 24 && cx <= window_width - 24 && cy >= 24 && cy <= window_height - 24) {
            renderer_ring(cx - 24, cy - 22, 48, 0x120B0780);
            renderer_ring(cx - 24, cy - 24, 48, 0xFFFFFFFF);
            add_hit(cx - 24, cy - 24, 48, 48, action, 1);
        }
        lua_pop(L, 1);
    }
    lua_pop(L, 1);
    max_scroll = 0;
    if (show_text) {
        /* Hardcoded slide layout for now: prose top-left, choices bottom-right. */
        float margin = fminf(32, window_width * .03f);
        float prose_width = window_width * .44f;
        float choice_width = window_width * .40f;
        float choice_x = window_width - margin - choice_width;
        float font_size = 24, choice_size = 22, gap = 16;
        float limit = window_height - margin - (*input ? 40 : 0);
        float choice_top = window_height * .52f;
        float total = 0;
        lua_getfield(L, -1, "buttons");
        for (size_t i = 1; i <= lua_rawlen(L, -1); ++i) {
            lua_rawgeti(L, -1, (lua_Integer)i);
            total += renderer_text_height(string_field("label"), choice_size, choice_width) + gap;
            lua_pop(L, 1);
        }
        total = fmaxf(0, total - gap);
        choice_top = fmaxf(choice_top, limit - total);
        int choice_scroll = MAX(0, (int)ceilf(total - (limit - choice_top)));
        lua_pop(L, 1);
        float prose_height = renderer_text_height(string_field("text"), font_size, prose_width);
        int prose_scroll = MAX(0, (int)ceilf(prose_height - (limit - margin)));
        max_scroll = MAX(choice_scroll, prose_scroll);
        scroll = MIN(scroll, max_scroll);
        renderer_clip(margin, margin, prose_width + 2, limit - margin);
        story_text(string_field("text"), margin, margin - MIN(scroll, prose_scroll), font_size, prose_width);
        renderer_unclip();

        renderer_clip(choice_x, choice_top, choice_width + 2, limit - choice_top);
        float bottom = choice_top - MIN(scroll, choice_scroll);
        lua_getfield(L, -1, "buttons");
        for (size_t i = 1; i <= lua_rawlen(L, -1); ++i) {
            lua_rawgeti(L, -1, (lua_Integer)i);
            float end = story_text(string_field("label"), choice_x, bottom, choice_size, choice_width);
            float hit_top = fmaxf(bottom, choice_top), hit_bottom = fminf(end, limit);
            add_hit(choice_x, hit_top, choice_width, hit_bottom - hit_top, number_field("action"), 0);
            bottom = end + gap;
            lua_pop(L, 1);
        }
        lua_pop(L, 1);
        renderer_unclip();
        if (choice_scroll > scroll)
            story_text("↓", window_width - margin - 18, limit, 18, 20);
    }
    /* Keep parser input available without an empty input window on every slide. */
    if (*input) {
        char command[sizeof(input) + 3];
        snprintf(command, sizeof(command), "> %s", input);
        renderer_clip(32, window_height - 40, window_width - 64, 32);
        story_text(command, 32, window_height - 40, 20, window_width - 64);
        renderer_unclip();
    }
    lua_pop(L, 1);
    if (screenshot_path && !renderer_screenshot(screenshot_path)) fail("cannot write screenshot");
    axEndPaint();
}

static void key(struct AXmessage *event)
{
    if (event->keyCode == AX_KEY_TAB) { show_text = !show_text; hit_count = 0; }
    else if (event->keyCode == AX_KEY_F5) call("reload", NULL, 0);
    else if (event->keyCode == AX_KEY_ESCAPE) {
        if (*input) input[0] = 0;
        else call("back", NULL, 0);
    } else if (event->keyCode == AX_KEY_ENTER) {
        if (*input) { call("command", input, 0); input[0] = 0; }
        else call("continue", NULL, 0);
    } else if (event->keyCode == AX_KEY_BACKSPACE) {
        size_t n = strlen(input);
        if (n) {
            do { --n; } while (n && ((unsigned char)input[n] & 0xC0) == 0x80);
            input[n] = 0;
        }
    } else if (event->keyCode == AX_KEY_DOWNARROW) scroll = MIN(max_scroll, scroll + 40);
    else if (event->keyCode == AX_KEY_UPARROW) scroll = MAX(0, scroll - 40);
    else {
        /* libplatform packs UTF-8 bytes into lParam for native key events. */
        char utf8[sizeof(event->lParam) + 1];
        memcpy(utf8, &event->lParam, sizeof(event->lParam));
        utf8[sizeof(event->lParam)] = 0;
        if ((event->wParam & (AX_MOD_CTRL | AX_MOD_CMD | AX_MOD_ALT)) == 0 &&
            (unsigned char)utf8[0] >= 32 && (unsigned char)utf8[0] != 127 &&
            strlen(input) + strlen(utf8) < sizeof(input)) strcat(input, utf8);
    }
}

int main(int argc, char **argv)
{
    const char *root_arg = argc > 1 ? argv[1] : ".";
    char root[PATH_MAX], path[PATH_MAX];
    if (!realpath(root_arg, root)) fail("cannot resolve Book directory");
    if (chdir(root)) fail("cannot enter Book directory");
    L = luaL_newstate();
    if (!L) fail("cannot allocate Lua state");
    luaL_openlibs(L);
    view_ref = LUA_NOREF;
    if (luaL_dofile(L, "Standalone/book.lua") != LUA_OK) fail(lua_tostring(L, -1));
    module_ref = luaL_ref(L, LUA_REGISTRYINDEX);
    call("init", root, 0);
    if (argc > 2 && !strcmp(argv[2], "--check")) {
        lua_rawgeti(L, LUA_REGISTRYINDEX, view_ref);
        printf("Book standalone: %s\n", string_field("title"));
        lua_close(L);
        return 0;
    }
    axInit();
    if (!axCreateWindow("Book — Wondertown", 1100, 800, AX_WINDOW_RESIZABLE | AX_WINDOW_DOUBLEBUFFER)) fail("cannot create window");
    axMakeCurrentContext();
    snprintf(path, sizeof(path), "%s/Fonts/Literata-VariableFont_opsz,wght.ttf", root);
    if (!renderer_init(path)) fail("cannot initialize renderer or load Literata font");
    if (argc > 3 && !strcmp(argv[2], "--smoke")) screenshot_path = argv[3];
    int running = 1, frames = 0, dirty = 1;
    int smoke = argc > 2 && !strcmp(argv[2], "--smoke");
    while (running) {
        struct AXmessage event;
        while (axPeekMessage(&event)) {
            dirty = 1;
            if (event.message == kEventWindowClosed) running = 0;
            else if (event.message == kEventKeyDown) key(&event);
            else if (event.message == kEventScrollWheel) scroll = CLAMP(scroll - event.dy * 30, 0, max_scroll);
            else if (event.message == kEventLeftButtonDown) {
                for (int i = hit_count - 1; i >= 0; --i) {
                    struct Hit hit = hits[i];
                    if (event.x >= hit.x && event.x < hit.x + hit.w && event.y >= hit.y && event.y < hit.y + hit.h) {
                        if (hit.circle) {
                            float dx = event.x - hit.x - hit.w / 2, dy = event.y - hit.y - hit.h / 2;
                            if (dx * dx + dy * dy > hit.w * hit.w / 4) continue;
                        }
                        call("action", NULL, hit.action);
                        break;
                    }
                }
            }
        }
        if (!running) break;
        if (dirty || smoke) { draw(); dirty = 0; }
        if (smoke && ++frames >= 3) break;
        axWaitMessage(smoke ? 16 : 250);
    }
    renderer_shutdown();
    axShutdown();
    lua_close(L);
    return 0;
}
