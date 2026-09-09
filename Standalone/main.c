#define _XOPEN_SOURCE 700
#include <platform.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <limits.h>
#include <unistd.h>
#include <math.h>
#include "render.h"

struct Hit { float x, y, w, h; int action; };
static struct Hit hits[256];
static int hit_count, module_ref, view_ref, scroll;
static lua_State *L;
static char input[512];
static const char *screenshot_path;
static int max_scroll, show_panel = 1;
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

static void button(float x, float y, float w, float h, const char *label, int action)
{
    renderer_rect(x, y, w, h, 0xE8DCC8FF);
    renderer_text(label, x + 10, y + 7, 18, w - 20, 0x302B25FF);
    if (hit_count < (int)(sizeof(hits) / sizeof(*hits)))
        hits[hit_count++] = (struct Hit){x, y, w, h, action};
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
    float panel = fminf(390, window_width * .42f);
    float panel_x = window_width - panel - 18;
    float scene_w = window_width, scene_h = window_height;
    float iw = number_field("source_width"), ih = number_field("source_height");
    if (iw <= 0 || ih <= 0) { iw = 1920; ih = 1440; }
    float scale = fmaxf(scene_w / iw, scene_h / ih);
    float w = iw * scale, h = ih * scale, x = (scene_w - w) / 2, y = (scene_h - h) / 2;
    lua_getfield(L, -1, "lighting");
    float ambient[3], background[3], lights[16 * 8];
    const char *names[] = {"ambient", "background"};
    for (int a = 0; a < 2; ++a) {
        lua_getfield(L, -1, names[a]);
        for (int i = 0; i < 3; ++i) {
            lua_rawgeti(L, -1, i + 1);
            (a ? background : ambient)[i] = (float)lua_tonumber(L, -1);
            lua_pop(L, 1);
        }
        lua_pop(L, 1);
    }
    lua_getfield(L, -1, "lights");
    size_t light_count = MIN(16, lua_rawlen(L, -1));
    for (size_t a = 0; a < light_count; ++a) {
        lua_rawgeti(L, -1, a + 1);
        for (int i = 0; i < 8; ++i) {
            lua_rawgeti(L, -1, i + 1);
            lights[a * 8 + i] = (float)lua_tonumber(L, -1);
            lua_pop(L, 1);
        }
        lua_pop(L, 1);
    }
    lua_pop(L, 2);
    renderer_lighting(ambient, background, lights, light_count);
    lua_getfield(L, -1, "vertices");
    size_t mesh_bytes = 0;
    const char *mesh = lua_tolstring(L, -1, &mesh_bytes);
    lua_getfield(L, -2, "matrix");
    float matrix[16];
    for (int i = 0; i < 16; ++i) {
        lua_rawgeti(L, -1, i + 1);
        matrix[i] = (float)lua_tonumber(L, -1);
        lua_pop(L, 1);
    }
    if (mesh && mesh_bytes % (9 * sizeof(float)) == 0)
        renderer_scene((const float *)mesh, mesh_bytes / (9 * sizeof(float)), matrix, x, y, w, h);
    lua_pop(L, 2);
    lua_getfield(L, -1, "hotspots");
    for (size_t i = 1; i <= lua_rawlen(L, -1); ++i) {
        lua_rawgeti(L, -1, (lua_Integer)i);
        float hx = number_field("x"), hy = number_field("y");
        int action = number_field("action");
        if (hx >= 0 && hx <= 1 && hy >= 0 && hy <= 1) {
            char label[16];
            snprintf(label, sizeof(label), "%d", action);
            float bx = CLAMP(x + hx * w - 16, x, x + w - 32);
            float by = CLAMP(y + hy * h - 16, y, y + h - 34);
            for (int j = 0; j < hit_count; ++j) {
                if (fabsf(bx - hits[j].x) < 36 && fabsf(by - hits[j].y) < 38) {
                    by = hits[j].y + 40;
                    if (by + 34 > y + h) { by = y + hy * h - 56; bx += 38; }
                    j = -1;
                }
            }
            if (!show_panel || bx + 32 < panel_x || by + 34 < 18 || by > window_height - 50)
                button(bx, by, 32, 34, label, action);
        }
        lua_pop(L, 1);
    }
    lua_pop(L, 1);
    renderer_rect(10, window_height - 34, 370, 26, 0x181510B0);
    renderer_text("Tab story • F5 reload • Esc back • ↑/↓ scroll", 18, window_height - 30, 15, 355, 0xF6F0E5FF);
    if (show_panel) {
    renderer_rect(panel_x, 18, panel, window_height - 68, 0xF6F0E5DC);
    float px = panel_x + 20, pw = panel - 40;
    renderer_clip(panel_x, 18, panel, window_height - 155);
    float bottom = renderer_text(string_field("title"), px, 36 - scroll, 30, pw, 0x302B25FF);
    bottom = renderer_text(string_field("text"), px, bottom + 18, 20, pw, 0x40372FFF) + 24;
    lua_getfield(L, -1, "buttons");
    for (size_t i = 1; i <= lua_rawlen(L, -1); ++i) {
        lua_rawgeti(L, -1, (lua_Integer)i);
        const char *label = string_field("label");
        int action = number_field("action");
        char numbered[512];
        snprintf(numbered, sizeof(numbered), "%d. %s", action, label);
        /* Two lines accommodate the current Book interaction labels. */
        button(px, bottom, pw, 60, numbered, action);
        bottom += 68;
        lua_pop(L, 1);
    }
    lua_pop(L, 1);
    max_scroll = MAX(0, (int)(bottom + scroll - window_height + 145));
    scroll = MIN(scroll, max_scroll);
    renderer_unclip();
    /* Reserve the bottom strip for command input and keep it above scroll content. */
    renderer_rect(panel_x, window_height - 132, panel, 82, 0xF6F0E5DC);
    renderer_text("Type a command • Enter to submit", px, window_height - 124, 15, pw, 0x6E6254FF);
    renderer_rect(px, window_height - 97, pw, 38, 0xE8DCC8FF);
    renderer_clip(px + 8, window_height - 97, pw - 16, 38);
    renderer_text(input[0] ? input : ">", px + 8, window_height - 91, 18, pw - 16, 0x302B25FF);
    renderer_unclip();
    }
    lua_pop(L, 1);
    if (screenshot_path && !renderer_screenshot(screenshot_path)) fail("cannot write screenshot");
    axEndPaint();
}

static void key(struct AXmessage *event)
{
    if (event->keyCode == AX_KEY_TAB) { show_panel = !show_panel; hit_count = 0; }
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
                float panel_left = window_width - fminf(390, window_width * .42f) - 18;
                if (show_panel && event.x >= panel_left && event.x < window_width - 18 &&
                    (event.y < 18 || event.y >= window_height - 137)) continue;
                for (int i = hit_count - 1; i >= 0; --i) {
                    struct Hit hit = hits[i];
                    if (event.x >= hit.x && event.x < hit.x + hit.w && event.y >= hit.y && event.y < hit.y + hit.h) {
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
