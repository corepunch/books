#define _XOPEN_SOURCE 700
#include "book.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

struct Book book;
static struct {
    lua_State *lua, *co;
    int env, game, original_object;
} vm;

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
    lua_State *L = vm.lua;
    lua_rawgeti(L, LUA_REGISTRYINDEX, vm.env);
    lua_getfield(L, -1, name); lua_remove(L, -2);
}

static int env_number(const char *name)
{
    env_get(name); int n = (int)lua_tointeger(vm.lua, -1); lua_pop(vm.lua, 1); return n;
}

static int env_int_call(const char *name, int object, int value, int nargs)
{
    lua_State *L = vm.lua;
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
    identifier_t symbol; copy(symbol, sizeof(symbol), lua_tostring(L, -1)); lua_pop(L, 1);
    lua_rawgeti(L, LUA_REGISTRYINDEX, vm.original_object);
    lua_pushvalue(L, 1); lua_call(L, 1, 1);
    lua_rawgeti(L, LUA_REGISTRYINDEX, vm.env);
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
    static nounPhrase_t phrase;
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
    if (input) lua_settop(vm.co, 0);
    if (input) lua_pushstring(vm.co, input);
    int count = 0;
    int status = lua_resume(vm.co, vm.lua, input ? 1 : 0, &count);
    if (status != LUA_OK && status != LUA_YIELD)
        fail("ZIL: %s", lua_tostring(vm.co, -1));
    book.ended = status == LUA_OK;
}

static void read_output(char *dst, size_t size)
{
    const char *text = lua_gettop(vm.co) ? lua_tostring(vm.co, -1) : NULL;
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
    filePath_t path;
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
    assetName_t key;
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
        description_t name; copy(name, sizeof(name), book.objects[i].desc); lower(name);
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
            choiceLabel_t label; command_t command;
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
                        word_t word; copy(word, sizeof(word), verb); lower(word);
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
    if (lua_istable(vm.co, -1)) item_choices(vm.co, -1);
    if (book.focus) {
        /* Inventory objects aren't included in the VM's room-items query. */
        if (!book.choice_count) {
            command_t command; snprintf(command, sizeof(command), "examine %s", noun_phrase(book.focus));
            add_choice("Examine", command, book.focus, false);
        }
        add_choice("Back", "", 0, false);
    } else {
        lua_State *L = vm.lua;
        env_get("_DIRECTIONS"); lua_pushnil(L);
        while (lua_next(L, -2)) {
            const char *direction = lua_tostring(L, -2);
            int prop = (int)lua_tointeger(L, -1);
            int ptr = env_int_call("GETPT", book.room, prop, 2);
            if (ptr && direction) {
                word_t command; choiceLabel_t label;
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

void book_command(const char *input, int subject)
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
    word_t verb; size_t n = strcspn(input, " \t");
    if (n >= sizeof(verb)) n = sizeof(verb) - 1;
    memcpy(verb, input, n); verb[n] = 0;
    select_image(subject, verb, before);
    if (book.focus) copy(book.focus_text, sizeof(book.focus_text), book.text);
    book.beat = true; refresh_choices();
}

void book_back(void)
{
    if (book.beat) book.beat = false;
    else book.focus = 0;
    if (book.focus && !visible(book.focus)) book.focus = 0;
    copy(book.text, sizeof(book.text), book.focus ? book.focus_text : book.room_text);
    select_image(book.focus, NULL, 0); refresh_choices();
}

void book_focus_object(int object)
{
    if (!visible(object)) return;
    book.beat = false; book.focus = object;
    command_t cmd; snprintf(cmd, sizeof(cmd), "examine %s", noun_phrase(object));
    book_command(cmd, object);
    if (!book.focus) return; /* examination may move the player */
    copy(book.focus_text, sizeof(book.focus_text), book.text);
    book.beat = false; select_image(book.focus, NULL, 0); refresh_choices();
}

void book_action(int index)
{
    if (index < 0 || index >= book.choice_count) return;
    struct Choice c = book.choices[index];
    if (c.focus) book_focus_object(c.object);
    else if (!*c.command) book_back();
    else book_command(c.command, c.object);
}

void book_init(const char *root, const char *adventure)
{
    if (!realpath(root, book.root)) fail("cannot resolve asset root: %s", root);
    asset_key(book.adventure, sizeof(book.adventure), adventure);
    snprintf(book.rooms, sizeof(book.rooms), "%s/books/%s/rooms", book.root, book.adventure);
    lua_State *L = vm.lua = luaL_newstate();
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
    vm.env = luaL_ref(L, LUA_REGISTRYINDEX);
    lua_rawgeti(L, LUA_REGISTRYINDEX, vm.env);
    lua_getglobal(L, "rawequal"); lua_setfield(L, -2, "rawequal"); lua_pop(L, 1);
    lua_getfield(L, runtime, "init"); lua_rawgeti(L, LUA_REGISTRYINDEX, vm.env);
    lua_pushboolean(L, true); checked_call(L, 2, 1);
    if (!lua_toboolean(L, -1)) fail("cannot initialize zilscript"); lua_pop(L, 1);
    env_get("require"); lua_pushliteral(L, "zilscript"); checked_call(L, 1, 0);
    env_get("OBJECT"); vm.original_object = luaL_ref(L, LUA_REGISTRYINDEX);
    lua_rawgeti(L, LUA_REGISTRYINDEX, vm.env);
    lua_pushcfunction(L, capture_object); lua_setfield(L, -2, "OBJECT");
    lua_pushcfunction(L, capture_object); lua_setfield(L, -2, "ROOM"); lua_pop(L, 1);
    /* A book is selected by convention: zilscript/books/<name>/<name>.zil. */
    moduleName_t module; snprintf(module, sizeof(module), "books.%s.%s", book.adventure, book.adventure);
    lua_getfield(L, runtime, "load_modules"); lua_rawgeti(L, LUA_REGISTRYINDEX, vm.env);
    lua_newtable(L); lua_pushstring(L, module); lua_rawseti(L, -2, 1);
    checked_call(L, 2, 1);
    if (!lua_toboolean(L, -1)) fail("cannot load %s", module); lua_pop(L, 1);
    lua_getfield(L, runtime, "create_game"); lua_rawgeti(L, LUA_REGISTRYINDEX, vm.env);
    lua_pushboolean(L, true); checked_call(L, 2, 1);
    lua_getfield(L, -1, "coroutine"); vm.co = lua_tothread(L, -1); lua_pop(L, 1);
    vm.game = luaL_ref(L, LUA_REGISTRYINDEX); lua_pop(L, 1);
    resume_vm(NULL); read_output(book.text, sizeof(book.text));
    book.room = env_number("HERE");
    if (book.room <= 0 || book.room >= MAX_OBJECTS) fail("story did not set HERE");
    copy(book.room_text, sizeof(book.room_text), book.text);
    select_image(0, NULL, 0); refresh_choices();
}

void book_reload(void)
{
    select_image(book.focus, NULL, 0);
    refresh_choices();
}

int book_object_room(int object)
{
    int rooms = env_number("ROOMS"), room = object;
    bool seen[MAX_OBJECTS] = {false};
    while (room > 0 && room < MAX_OBJECTS && !seen[room] && location(room) != rooms) {
        seen[room] = true;
        room = location(room);
    }
    return room > 0 && room < MAX_OBJECTS && !seen[room] ? room : 0;
}

void book_shutdown(void)
{
    if (vm.lua) lua_close(vm.lua);
    memset(&vm, 0, sizeof(vm));
    memset(&book, 0, sizeof(book));
}
