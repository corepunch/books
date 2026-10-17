#define _XOPEN_SOURCE 700
#include "book.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* The story runtime: validates the story read from books/<name>/, keeps the private
 * story state, runs triggers and actions, publishes complete pages and navigates
 * between them. Books are data. */

#define MAX_REDIRECTS MAX_STORY_PAGES
#define MAX_CALL_DEPTH 64
#define MAX_TERM_STACK 256
#define ITEM_ICON_PREFIX "item-"
#define MAX_DIALED 32
#define MAP_COMMAND "map"
#define BITS(count) (((count) + 7) / 8)

/* Everything "try again" restores: variables, flags, icons, where the reader stands. */
struct World {
    int values[MAX_STORY_VARIABLES];
    int lying[MAX_STORY_ICONS];      /* location index + 1 an icon lies in, or zero */
    bool carried[MAX_STORY_ICONS];
    unsigned char enabled[BITS(MAX_STORY_FLAGS)];
    unsigned char shown[BITS(MAX_STORY_RECORDS)]; /* interfaces on screen */
    unsigned char seen[BITS(MAX_STORY_PAGES)];    /* pages the reader has been shown */
    unsigned char read[BITS(MAX_STORY_RECORDS)];  /* notes, email and photos opened */
    int location, node;              /* where the reader stands, or -1 */
};

static const struct Story *story;
static struct World world;
static struct {
    int page, room, object_count, last_decision, held; /* held: icon index + 1 */
    filePath_t root, rooms, illustrations;
    struct Object objects[MAX_OBJECTS];
    int object_room[MAX_OBJECTS];
    int icon_object[MAX_STORY_ICONS];
    struct World *snapshot; /* the world as each decision page was shown, for "try again" */
    bool visited[MAX_STORY_PAGES];
} game;
/* The story hotspot behind each published choice, or -1. */
static int choice_source[MAX_CHOICES];

/* Build into private scratch storage; consumers only see validated, complete pages.
 * Keep these large snapshots off the iPad main-thread stack. */
static struct BookPage current, draft;

/* The map opens over the view the reader stands on: its home lists the destinations of
 * every map page the reader has seen, then the notes, email and photos the story has
 * enabled, the phone, and each interface an action has shown. Like the PDA of The X-Files
 * Game, it is how the reader travels and what they keep; here it is simply the map. */
enum MapScreen { MAP_CLOSED, MAP_HOME, MAP_NOTES, MAP_EMAIL, MAP_PHOTOS, MAP_PHONE, MAP_INTERFACE, MAP_RECORD };
static struct {
    enum MapScreen screen, list; /* list: the screen the open record was chosen from */
    int record;                  /* the open record or interface */
    char dialed[MAX_DIALED];
    bool unanswered;
} map;

static bool bit(const unsigned char *bits, int index) { return bits[index / 8] & (1u << (index % 8)); }
static void set_bit(unsigned char *bits, int index, bool on)
{
    if (on) bits[index / 8] |= (unsigned char)(1u << (index % 8));
    else bits[index / 8] &= (unsigned char)~(1u << (index % 8));
}

static const struct StoryPage *page_at(int index) { return &story->pages[index]; }
static const struct StoryHotspot *hotspot_at(const struct StoryPage *page, int i)
{
    return &story->hotspots[page->hotspot_first + i];
}

static bool decision(const struct StoryPage *page)
{
    return page->kind == STORY_VIEW || page->kind == STORY_CHARVIEW || page->kind == STORY_MAP;
}

static bool shown(const struct StoryPage *page) { return page->kind != STORY_ACTIONLIST; }

/* Locations and anchors become objects: circles project onto anchors by key. */
static int object_for(const char *key, int room)
{
    for (int i = 1; i <= game.object_count; ++i)
        if (!strcmp(game.objects[i].key, key)) return i;
    if (game.object_count + 1 >= MAX_OBJECTS) fail("too many story anchors and locations");
    int id = ++game.object_count;
    copy(game.objects[id].key, sizeof(game.objects[id].key), key);
    game.object_room[id] = room ? room : id;
    return id;
}

static int location_object(int location) { return object_for(story->locations[location].id, 0); }

static const char *edge_key(enum StoryEdge edge)
{
    switch (edge) {
    case EDGE_LEFT: return "edge-left";
    case EDGE_RIGHT: return "edge-right";
    case EDGE_BACK: return "edge-back";
    case EDGE_NONE: break;
    }
    return "";
}

/* --- Conditions and actions ---------------------------------------------------- */

struct Value { int number; bool string; };

static bool evaluate(const struct StoryCondition *test)
{
    if (!test->count) return true;
    struct Value stack[MAX_TERM_STACK];
    int top = 0;
    for (int i = 0; i < test->count; ++i) {
        const struct StoryTerm *term = &story->terms[test->first + i];
        struct Value a = {0, false}, b = {0, false};
        switch (term->kind) {
        case TERM_VARIABLE:
        case TERM_NUMBER:
        case TERM_STRING:
        case TERM_HAS:
        case TERM_HOLDING:
        case TERM_ENABLED:
        case TERM_VISITED:
            if (top >= MAX_TERM_STACK) fail("condition \"%s\" is too deep", test->source);
            break;
        case TERM_NOT: if (top < 1) fail("condition \"%s\" is malformed", test->source); break;
        case TERM_AND: case TERM_OR: case TERM_EQ: case TERM_NE:
        case TERM_LT: case TERM_LE: case TERM_GT: case TERM_GE:
            if (top < 2) fail("condition \"%s\" is malformed", test->source);
            b = stack[--top];
            a = stack[--top];
            break;
        }
        bool strings = a.string && b.string;
        int order = strings ? strcmp(story->strings[a.number], story->strings[b.number]) :
                    (a.number > b.number) - (a.number < b.number);
        switch (term->kind) {
        case TERM_VARIABLE:
            stack[top++] = (struct Value){world.values[term->value],
                                          story->variables[term->value].type == VARIABLE_STRING};
            break;
        case TERM_NUMBER: stack[top++] = (struct Value){term->value, false}; break;
        case TERM_STRING: stack[top++] = (struct Value){term->value, true}; break;
        case TERM_HAS: stack[top++] = (struct Value){world.carried[term->value], false}; break;
        case TERM_HOLDING: stack[top++] = (struct Value){game.held == term->value + 1, false}; break;
        case TERM_ENABLED: stack[top++] = (struct Value){bit(world.enabled, term->value), false}; break;
        case TERM_VISITED: stack[top++] = (struct Value){bit(world.seen, term->value), false}; break;
        case TERM_NOT: stack[top - 1] = (struct Value){!stack[top - 1].number, false}; break;
        case TERM_AND: stack[top++] = (struct Value){a.number && b.number, false}; break;
        case TERM_OR: stack[top++] = (struct Value){a.number || b.number, false}; break;
        case TERM_EQ: stack[top++] = (struct Value){order == 0, false}; break;
        case TERM_NE: stack[top++] = (struct Value){order != 0, false}; break;
        case TERM_LT: stack[top++] = (struct Value){order < 0, false}; break;
        case TERM_LE: stack[top++] = (struct Value){order <= 0, false}; break;
        case TERM_GT: stack[top++] = (struct Value){order > 0, false}; break;
        case TERM_GE: stack[top++] = (struct Value){order >= 0, false}; break;
        }
    }
    if (top != 1) fail("condition \"%s\" is malformed", test->source);
    return stack[0].number != 0;
}

/* Run actions in order. A goto ends the list, and every list that called it: the page it
 * names is returned. Without one, -1. */
static int run(struct StoryActions range, int depth)
{
    if (depth > MAX_CALL_DEPTH) fail("action lists call each other too deeply");
    for (int i = 0; i < range.count; ++i) {
        const struct StoryAction *action = &story->actions[range.first + i];
        int next = -1;
        switch (action->op) {
        case ACTION_SET:
            world.values[action->target] = action->from_variable ? world.values[action->value] : action->value;
            break;
        case ACTION_ADD: world.values[action->target] += action->value; break;
        case ACTION_ENABLE: set_bit(world.enabled, action->target, true); break;
        case ACTION_DISABLE: set_bit(world.enabled, action->target, false); break;
        case ACTION_GIVE:
            world.carried[action->target] = true;
            world.lying[action->target] = 0;
            break;
        case ACTION_REMOVE:
            world.carried[action->target] = false;
            world.lying[action->target] = 0;
            if (game.held == action->target + 1) game.held = 0;
            break;
        case ACTION_GOTO: return action->target;
        case ACTION_CALL: next = run(page_at(action->target)->actions, depth + 1); break;
        case ACTION_IF: next = run(evaluate(&action->test) ? action->then : action->otherwise, depth + 1); break;
        case ACTION_SHOW: set_bit(world.shown, action->target, true); break;
        case ACTION_HIDE: set_bit(world.shown, action->target, false); break;
        case ACTION_SCRIPT: break; /* engine scripts are kept for tools; this reader runs none */
        case ACTION_INVALID: fail("invalid action");
        }
        if (next >= 0) return next;
    }
    return -1;
}

/* Leaving never redirects: a leave trigger tidies up, and the reader goes where they chose. */
static void run_leave(struct StoryActions range, const char *what, const char *id)
{
    if (run(range, 0) >= 0) fail("the leave trigger of %s %s cannot go anywhere", what, id);
}

/* --- Validation ------------------------------------------------------------------ */

static void validate_story(void)
{
    if (!story || !story->name || !*story->name || !story->page_count) fail("book defines no story");
    if (page_at(story->start)->kind == STORY_CONVERSATION) fail("story starts inside a conversation");
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = page_at(i);
        if (!page->id || !*page->id) fail("story page %d has no id", i);
        if (shown(page) && (!page->camera || !*page->camera || !page->text || !*page->text))
            fail("page %s needs a camera and text", page->id);
        if (page->clip && (!shown(page) || !*page->clip || strpbrk(page->clip, "/.\\")))
            fail("page %s clip must be a bare file name", page->id);
        if (page->read && (!story->fmv || page->kind != STORY_ASSET))
            fail("page %s is a reading outside an fmv asset", page->id);
        if (page->kind != STORY_ENDING && page->ending != ENDING_NONE) fail("page %s is not an ending", page->id);

        for (int h = 0; h < page->hotspot_count; ++h) {
            const struct StoryHotspot *hotspot = hotspot_at(page, h);
            if (!hotspot->label || !*hotspot->label) fail("page %s choice %d needs a label", page->id, h);
            if (hotspot->target < 0 && !hotspot->click.count) fail("page %s choice %s goes nowhere", page->id, hotspot->label);
            bool circle = page->kind != STORY_CHARVIEW;
            if (circle && !hotspot->anchor && !hotspot->edge) fail("page %s circle %s needs an anchor", page->id, hotspot->label);
            if (!circle && (hotspot->anchor || hotspot->edge)) fail("charview %s line %s has an anchor", page->id, hotspot->label);
            if (hotspot->ends && page->kind != STORY_CHARVIEW) fail("page %s choice %s ends a talk", page->id, hotspot->label);
            if (hotspot->take >= 0 && hotspot->with >= 0) fail("page %s choice %s both takes and uses an icon", page->id, hotspot->label);
            if (hotspot->take >= 0 && story->icons[hotspot->take].where != page->location)
                fail("page %s takes %s, which never lies in %s", page->id, story->icons[hotspot->take].id,
                     story->locations[page->location].id);
            /* Two unconditional choices for the same held state never lead to one page. */
            for (int d = 0; d < h; ++d) {
                const struct StoryHotspot *other = hotspot_at(page, d);
                if (other->with == hotspot->with && other->target >= 0 && other->target == hotspot->target &&
                    !other->test.count && !hotspot->test.count && other->flag < 0 && hotspot->flag < 0)
                    fail("page %s offers two choices leading to %s", page->id, page_at(hotspot->target)->id);
            }
        }
        switch (page->kind) {
        case STORY_VIEW:
        case STORY_MAP:
            if (!page->hotspot_count) fail("%s %s has no choices", story_page_kind_name(page->kind), page->id);
            break;
        case STORY_CHARVIEW:
            if (!page->hotspot_count) fail("charview %s has no conversation", page->id);
            /* Each held state needs its own last line, and only one. */
            for (int h = 0; h < page->hotspot_count; ++h) {
                int ends = 0;
                for (int d = 0; d < page->hotspot_count; ++d)
                    ends += hotspot_at(page, d)->ends && hotspot_at(page, d)->with == hotspot_at(page, h)->with;
                if (ends != 1) fail("charview %s must end once for each icon the reader might hold", page->id);
            }
            break;
        case STORY_ASSET:
            if (page->next < 0 && !page->triggers.on[EVENT_END].count) fail("asset %s goes nowhere", page->id);
            break;
        case STORY_CONVERSATION:
            if (page->parent < 0 || page_at(page->parent)->kind != STORY_CHARVIEW)
                fail("conversation %s is outside a charview", page->id);
            break;
        case STORY_ENDING:
            if (page->ending == ENDING_NONE) fail("ending %s has no ending kind", page->id);
            if (page->ending == ENDING_SUCCESS && page->retry >= 0)
                fail("success ending %s restarts the book; give it no retry page", page->id);
            if (page->retry >= 0 && !decision(page_at(page->retry)))
                fail("ending %s must retry from a view, a charview or a map", page->id);
            break;
        case STORY_ACTIONLIST:
            if (!page->actions.count) fail("action list %s is empty", page->id);
            break;
        case STORY_INVALID:
        default: fail("page %s has no kind", page->id);
        }
    }
    for (int i = 0; i < story->action_count; ++i) {
        const struct StoryAction *action = &story->actions[i];
        if (action->op == ACTION_CALL && page_at(action->target)->kind != STORY_ACTIONLIST)
            fail("<call> names %s, which is not an action list", page_at(action->target)->id);
    }
    /* Register every location first, then anchors in the room where they first appear. */
    for (int i = 0; i < story->location_count; ++i) location_object(i);
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = page_at(i);
        if (page->kind == STORY_CHARVIEW) continue;
        for (int h = 0; h < page->hotspot_count; ++h)
            if (hotspot_at(page, h)->anchor) object_for(hotspot_at(page, h)->anchor, location_object(page->location));
    }
    for (int i = 0; i < story->icon_count; ++i) {
        const struct StoryIcon *icon = &story->icons[i];
        game.icon_object[i] = object_for(icon->id, icon->where >= 0 ? location_object(icon->where) : 0);
        if (icon->where < 0) game.object_room[game.icon_object[i]] = 0;
    }
}

/* --- Pictures -------------------------------------------------------------------- */

/* A camera's painting when it exists, otherwise its render. */
static bool find_image(const char *camera, filePath_t image)
{
    image[0] = 0;
    filePath_t path;
    int length = snprintf(path, sizeof(path), "%s/%s.png", game.illustrations, camera);
    if (length < 0 || (size_t)length >= sizeof(path)) fail("illustration path is too long");
    if (!access(path, R_OK)) {
        copy(image, sizeof(filePath_t), path);
        return true;
    }
    length = snprintf(path, sizeof(path), "%s/%s.jpg", game.rooms, camera);
    if (length < 0 || (size_t)length >= sizeof(path)) fail("reference image path is too long");
    if (access(path, R_OK)) return false;
    copy(image, sizeof(filePath_t), path);
    return true;
}

static void select_image(struct BookPage *page, const char *camera)
{
    copy(page->camera, sizeof(page->camera), camera);
    find_image(camera, page->image);
}

static void clip_file(const char *clip, char *dest, size_t size)
{
    int length = snprintf(dest, size, "%s/books/%s/clips/%s.mp4", game.root, story->name, clip);
    if (length < 0 || (size_t)length >= size) fail("clip path is too long");
}

static void check_clips(void)
{
    for (int i = 0; i < story->page_count; ++i) {
        const char *clip = page_at(i)->clip;
        if (!clip) continue;
        filePath_t path;
        clip_file(clip, path, sizeof(path));
        if (access(path, R_OK)) fail("missing clip %s", path);
    }
}

/* --- Publishing ------------------------------------------------------------------ */

static void append_choice(enum ChoiceKind kind, const char *label, const char *command, int object, int source)
{
    if (draft.choice_count >= MAX_CHOICES) fail("too many page choices");
    struct Choice choice = {.kind = kind, .object = object};
    copy(choice.label, sizeof(choice.label), label);
    copy(choice.command, sizeof(choice.command), command ? command : "");
    choice_source[draft.choice_count] = source;
    draft.choices[draft.choice_count++] = choice;
}

static void publish_page(void)
{
    if (draft.room <= 0 || draft.room >= MAX_OBJECTS || !*game.objects[draft.room].key)
        fail("page has no valid room");
    if (!*draft.id || !*draft.camera) fail("page must have an id and a camera");
    /* An fmv page draws prose only while a document is open. */
    if (!*draft.text && !(story->fmv && !draft.read)) fail("page must have prose and a camera");
    if (draft.choice_count < 0 || draft.choice_count > MAX_CHOICES) fail("invalid choice count");
    switch (draft.kind) {
    case PAGE_ROOM:
        if (!draft.choice_count || draft.ending != ENDING_NONE) fail("room page %s needs actions and no ending", draft.id);
        break;
    case PAGE_BEAT:
        if (draft.choice_count == 0) {
            if (!story->fmv || draft.read) fail("intermediate page must have exactly one Continue choice");
        } else if (draft.choice_count != 1 || draft.ending != ENDING_NONE) {
            fail("intermediate page must have exactly one Continue choice");
        }
        break;
    case PAGE_ENDED:
        if (draft.choice_count != 1 || draft.ending == ENDING_NONE)
            fail("ending page must have an ending kind and exactly one retry choice");
        break;
    case PAGE_INVALID:
    default: fail("invalid page kind %d", draft.kind);
    }
    for (int i = 0; i < draft.choice_count; ++i) {
        const struct Choice *choice = &draft.choices[i];
        if (!*choice->label) fail("choice %d has no label", i);
        switch (choice->kind) {
        case CHOICE_OBJECT:
            if (draft.kind != PAGE_ROOM || !*choice->command || choice->object <= 0 ||
                choice->object >= MAX_OBJECTS || !*game.objects[choice->object].key)
                fail("invalid object choice %d", i);
            break;
        case CHOICE_CONTINUE:
            if (draft.kind != PAGE_BEAT || choice->object || *choice->command)
                fail("invalid Continue choice %d", i);
            break;
        case CHOICE_RETRY:
            if (draft.kind != PAGE_ENDED || choice->object || !*choice->command)
                fail("invalid retry choice %d", i);
            break;
        case CHOICE_ITEM:
            if (draft.kind != PAGE_ROOM || !*choice->command || choice->object <= 0 ||
                choice->object >= MAX_OBJECTS || !*game.objects[choice->object].key)
                fail("invalid thing choice %d", i);
            break;
        case CHOICE_ASK:
        case CHOICE_END:
            if (!draft.talk || draft.kind != PAGE_ROOM || !*choice->command || choice->object)
                fail("invalid talk line %d", i);
            break;
        case CHOICE_MAP:
            if (draft.talk || draft.kind != PAGE_ROOM || !*choice->command || choice->object)
                fail("invalid map choice %d", i);
            break;
        case CHOICE_KEY:
            if (!draft.keypad || !draft.talk || draft.kind != PAGE_ROOM || !*choice->command || choice->object)
                fail("invalid keypad key %d", i);
            break;
        case CHOICE_INVALID:
        default: fail("invalid kind for choice %d", i);
        }
    }
    if (draft.talk) {
        if (draft.kind != PAGE_ROOM) fail("a talk page must be a room");
        int ends = 0;
        for (int i = 0; i < draft.choice_count; ++i) {
            enum ChoiceKind kind = draft.choices[i].kind;
            if (kind == CHOICE_OBJECT) fail("a talk page published a circle");
            if (kind == CHOICE_END) ++ends;
        }
        if (ends != 1) fail("talk page %s needs one way to end", draft.id);
    }
    if (draft.held) {
        bool listed = false;
        for (int i = 0; i < draft.choice_count; ++i)
            listed |= draft.choices[i].kind == CHOICE_ITEM && draft.choices[i].object == draft.held;
        if (draft.kind != PAGE_ROOM || !listed) fail("the held thing must be a carried thing on a room page");
    }
    current = draft;
}

static bool offered(const struct StoryHotspot *hotspot, const struct StoryPage *page)
{
    if (hotspot->flag >= 0 && !bit(world.enabled, hotspot->flag)) return false;
    if (!evaluate(&hotspot->test)) return false;
    if (hotspot->take >= 0) return world.lying[hotspot->take] == page->location + 1;
    int with = hotspot->with >= 0 ? hotspot->with + 1 : 0;
    return with == game.held && (!with || world.carried[hotspot->with]);
}

/* A choice's command: the page it leads to, or its own name when its actions decide. */
static void hotspot_command(const struct StoryPage *page, int index, command_t command)
{
    const struct StoryHotspot *hotspot = hotspot_at(page, index);
    if (hotspot->target >= 0) copy(command, sizeof(command_t), page_at(hotspot->target)->id);
    else if (hotspot->id) copy(command, sizeof(command_t), hotspot->id);
    else snprintf(command, sizeof(command_t), "%s:%d", page->id, index);
}

/* A book with map pages or records gives every view the map. */
static bool has_map(void)
{
    if (story->record_count) return true;
    for (int i = 0; i < story->page_count; ++i)
        if (page_at(i)->kind == STORY_MAP) return true;
    return false;
}

/* Fill a room page: the choices the reader can take, or the held icon's uses, then the
 * carried icons. A view shows inventory and evidence; a charview shows every icon. */
static void build_room(void)
{
    const struct StoryPage *page = page_at(game.page);
    bool talk = page->kind == STORY_CHARVIEW;
    draft.kind = PAGE_ROOM;
    draft.talk = talk;
    draft.held = game.held ? game.icon_object[game.held - 1] : 0;
    const char *text = page->text;
    if (game.held) {
        text = story->icons[game.held - 1].text;
        for (int r = 0; r < page->response_count; ++r) {
            const struct StoryResponse *response = &story->responses[page->response_first + r];
            if (response->icon == game.held - 1 && evaluate(&response->test)) {
                text = response->text;
                break;
            }
        }
    }
    copy(draft.text, sizeof(draft.text), text);
    for (int h = 0; h < page->hotspot_count; ++h) {
        const struct StoryHotspot *hotspot = hotspot_at(page, h);
        if (!offered(hotspot, page)) continue;
        command_t command;
        hotspot_command(page, h, command);
        enum ChoiceKind kind = CHOICE_OBJECT;
        int object = 0;
        if (talk) kind = hotspot->ends ? CHOICE_END : CHOICE_ASK;
        else object = object_for(hotspot->anchor ? hotspot->anchor : edge_key(hotspot->edge), game.room);
        append_choice(kind, hotspot->label, command, object, page->hotspot_first + h);
        draft.choices[draft.choice_count - 1].edge = (enum ChoiceEdge)hotspot->edge;
    }
    for (int i = 0; i < story->icon_count; ++i) {
        const struct StoryIcon *icon = &story->icons[i];
        bool everywhere = icon->kind == ICON_INVENTORY || icon->kind == ICON_EVIDENCE;
        if (world.carried[i] && (talk || everywhere))
            append_choice(CHOICE_ITEM, icon->name, icon->id, game.icon_object[i], -1);
    }
    if (!talk && has_map()) append_choice(CHOICE_MAP, "Map", MAP_COMMAND ":open", 0, -1);
}

/* A destination on a map page the reader has seen, somewhere other than where they stand. */
static bool known_destination(int page, const struct StoryHotspot *destination)
{
    if (!bit(world.seen, page) || (destination->flag >= 0 && !bit(world.enabled, destination->flag)) ||
        !evaluate(&destination->test))
        return false;
    return destination->target < 0 || page_at(destination->target)->location != page_at(game.page)->location;
}

static bool record_enabled(int index)
{
    const struct StoryRecord *record = &story->records[index];
    if (record->kind == RECORD_INTERFACE) return bit(world.shown, index);
    return record->flag < 0 || bit(world.enabled, record->flag);
}

static int count_records(enum StoryRecordKind kind, bool enabled_only, bool unread_only)
{
    int count = 0;
    for (int i = 0; i < story->record_count; ++i)
        count += story->records[i].kind == kind && (!enabled_only || record_enabled(i)) &&
                 (!unread_only || !bit(world.read, i));
    return count;
}

static const char *record_title(const struct StoryRecord *record)
{
    return record->title ? record->title : record->id;
}

static void map_line(const char *label, const char *format, int value)
{
    command_t command;
    snprintf(command, sizeof(command), format, value);
    append_choice(CHOICE_ASK, label, command, 0, -1);
}

/* A map list: one line per enabled record of a kind, newest unread marked. */
static void map_list(enum StoryRecordKind kind, const char *heading, storyText_t text)
{
    copy(text, sizeof(storyText_t), heading);
    if (!count_records(kind, true, false)) copy(text, sizeof(storyText_t), "Nothing here yet.");
    for (int i = 0; i < story->record_count; ++i) {
        const struct StoryRecord *record = &story->records[i];
        if (record->kind != kind || !record_enabled(i)) continue;
        choiceLabel_t label;
        snprintf(label, sizeof(label), "%s%s%s%s", bit(world.read, i) ? "" : "New: ", record_title(record),
                 record->from ? ", from " : "", record->from ? record->from : "");
        map_line(label, MAP_COMMAND ":record:%d", i);
    }
}

static void publish_map(void)
{
    const struct StoryPage *page = page_at(game.page);
    memset(&draft, 0, sizeof(draft));
    draft.room = game.room;
    draft.kind = PAGE_ROOM;
    draft.talk = true;
    select_image(&draft, page->camera);
    storyText_t text = "";
    identifier_t id = MAP_COMMAND ":home";
    switch (map.screen) {
    case MAP_HOME: {
        copy(text, sizeof(text), "Map");
        for (int p = 0; p < story->page_count; ++p) {
            const struct StoryPage *chart = page_at(p);
            if (chart->kind != STORY_MAP) continue;
            for (int h = 0; h < chart->hotspot_count; ++h)
                if (known_destination(p, hotspot_at(chart, h))) {
                    command_t command;
                    snprintf(command, sizeof(command), MAP_COMMAND ":go:%d", chart->hotspot_first + h);
                    append_choice(CHOICE_ASK, hotspot_at(chart, h)->label, command, 0, chart->hotspot_first + h);
                }
        }
        static const struct { enum StoryRecordKind kind; const char *label, *command; } lists[] = {
            {RECORD_NOTE, "Notes", MAP_COMMAND ":notes"}, {RECORD_EMAIL, "Email", MAP_COMMAND ":email"},
            {RECORD_PHOTO, "Photos", MAP_COMMAND ":photos"},
        };
        for (size_t l = 0; l < sizeof(lists) / sizeof(lists[0]); ++l) {
            if (!count_records(lists[l].kind, false, false)) continue;
            choiceLabel_t label;
            int unread = count_records(lists[l].kind, true, true);
            if (unread) snprintf(label, sizeof(label), "%s (%d new)", lists[l].label, unread);
            else snprintf(label, sizeof(label), "%s (%d)", lists[l].label, count_records(lists[l].kind, true, false));
            append_choice(CHOICE_ASK, label, lists[l].command, 0, -1);
        }
        if (count_records(RECORD_PHONE, false, false)) append_choice(CHOICE_ASK, "Phone", MAP_COMMAND ":phone", 0, -1);
        for (int i = 0; i < story->record_count; ++i)
            if (story->records[i].kind == RECORD_INTERFACE && record_enabled(i))
                map_line(record_title(&story->records[i]), MAP_COMMAND ":interface:%d", i);
        append_choice(CHOICE_END, "Close", MAP_COMMAND ":close", 0, -1);
        break;
    }
    case MAP_NOTES: copy(id, sizeof(id), MAP_COMMAND ":notes"); map_list(RECORD_NOTE, "Notes", text); break;
    case MAP_EMAIL: copy(id, sizeof(id), MAP_COMMAND ":email"); map_list(RECORD_EMAIL, "Email", text); break;
    case MAP_PHOTOS: copy(id, sizeof(id), MAP_COMMAND ":photos"); map_list(RECORD_PHOTO, "Photos", text); break;
    case MAP_INTERFACE: {
        const struct StoryRecord *record = &story->records[map.record];
        snprintf(id, sizeof(id), MAP_COMMAND ":%s", record->id);
        copy(text, sizeof(text), record_title(record));
        for (int h = 0; h < record->hotspot_count; ++h) {
            int index = record->hotspot_first + h;
            const struct StoryHotspot *item = &story->hotspots[index];
            if ((item->flag >= 0 && !bit(world.enabled, item->flag)) || !evaluate(&item->test)) continue;
            command_t command;
            snprintf(command, sizeof(command), MAP_COMMAND ":item:%d", index);
            append_choice(CHOICE_ASK, item->label, command, 0, index);
        }
        break;
    }
    case MAP_PHONE: {
        copy(id, sizeof(id), MAP_COMMAND ":phone");
        draft.keypad = true;
        if (map.unanswered) copy(text, sizeof(text), "No one answers.");
        else snprintf(text, sizeof(text), "Dial %s", *map.dialed ? map.dialed : "a number.");
        static const char *const keys[] = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "Clear", "0", "Dial"};
        for (size_t k = 0; k < sizeof(keys) / sizeof(keys[0]); ++k) {
            command_t command;
            if (!strcmp(keys[k], "Clear")) copy(command, sizeof(command), MAP_COMMAND ":clear");
            else if (!strcmp(keys[k], "Dial")) copy(command, sizeof(command), MAP_COMMAND ":dial");
            else snprintf(command, sizeof(command), MAP_COMMAND ":key:%s", keys[k]);
            append_choice(CHOICE_KEY, keys[k], command, 0, -1);
        }
        break;
    }
    case MAP_RECORD: {
        /* A record reads like a document: a photo on its own picture, the rest over the view. */
        const struct StoryRecord *record = &story->records[map.record];
        snprintf(id, sizeof(id), MAP_COMMAND ":%s", record->id);
        draft.kind = PAGE_BEAT;
        draft.talk = false;
        draft.read = true;
        if (record->kind == RECORD_PHOTO) select_image(&draft, record->camera);
        if (record->kind == RECORD_EMAIL)
            snprintf(text, sizeof(text), "From %s: %s\n%s", record->from, record_title(record), record->text);
        else if (record->title) snprintf(text, sizeof(text), "%s\n%s", record->title, record->text);
        else copy(text, sizeof(text), record->text);
        append_choice(CHOICE_CONTINUE, story->continue_label, NULL, 0, -1);
        break;
    }
    case MAP_CLOSED: fail("the map is closed");
    }
    if (draft.talk && map.screen != MAP_HOME) append_choice(CHOICE_END, "Back", MAP_COMMAND ":back", 0, -1);
    copy(draft.id, sizeof(draft.id), id);
    copy(draft.text, sizeof(draft.text), text);
    publish_page();
}

/* Publish the page the reader stands on, from the current world. */
static void publish(void)
{
    if (map.screen != MAP_CLOSED) {
        publish_map();
        return;
    }
    const struct StoryPage *page = page_at(game.page);
    memset(&draft, 0, sizeof(draft));
    draft.room = game.room;
    copy(draft.id, sizeof(draft.id), page->id);
    copy(draft.text, sizeof(draft.text), page->text);
    /* Every page is one whole picture: the painting for its camera, else the camera's render.
     * A clip plays in that picture; the still is the poster until the first frame. */
    select_image(&draft, page->camera);
    if (page->clip) clip_file(page->clip, draft.clip, sizeof(draft.clip));
    draft.clip_from = page->clip_from;
    draft.clip_to = page->clip_to;
    draft.loop = page->loop;
    switch (page->kind) {
    case STORY_VIEW:
    case STORY_CHARVIEW:
    case STORY_MAP:
        build_room();
        if (story->fmv) draft.text[0] = 0;
        break;
    case STORY_ASSET:
    case STORY_CONVERSATION:
        draft.kind = PAGE_BEAT;
        draft.read = story->fmv && page->read;
        if (draft.read || !story->fmv)
            append_choice(CHOICE_CONTINUE, story->continue_label, NULL, 0, -1);
        else draft.text[0] = 0;
        break;
    case STORY_ENDING:
        draft.kind = PAGE_ENDED;
        draft.ending = page->ending;
        if (story->fmv) draft.text[0] = 0;
        if (page->ending == ENDING_SUCCESS) append_choice(CHOICE_RETRY, story->restart_label, page_at(story->start)->id, 0, -1);
        else {
            /* Try again from the named decision when the reader has been there, else from their last one. */
            int retry = page->retry;
            if (retry < 0 || !game.visited[retry]) retry = game.last_decision;
            append_choice(CHOICE_RETRY, story->retry_label, page_at(retry)->id, 0, -1);
        }
        break;
    case STORY_ACTIONLIST:
    case STORY_INVALID:
    default: fail("cannot show page %s", page->id);
    }
    publish_page();
}

/* Arrive in a location: leave the old one (and its node), then enter the new node and
 * location. Returns the page an enter trigger goes to, or -1. */
static int arrive(int location)
{
    if (location == world.location) return -1;
    int node = story->locations[location].node;
    if (world.location >= 0) {
        run_leave(story->locations[world.location].triggers.on[EVENT_LEAVE], "location", story->locations[world.location].id);
        if (world.node != node) run_leave(story->nodes[world.node].triggers.on[EVENT_LEAVE], "node", story->nodes[world.node].id);
    }
    bool new_node = world.node != node;
    world.location = location;
    world.node = node;
    int next = new_node ? run(story->nodes[node].triggers.on[EVENT_ENTER], 0) : -1;
    if (next < 0) next = run(story->locations[location].triggers.on[EVENT_ENTER], 0);
    return next;
}

/* Show a page by index: action lists and enter triggers may send the reader on. */
static void show(int index)
{
    map.screen = MAP_CLOSED;
    for (int steps = 0;; ++steps) {
        if (steps >= MAX_REDIRECTS) fail("the story redirects in a loop at %s", page_at(index)->id);
        const struct StoryPage *page = page_at(index);
        int next;
        if (page->kind == STORY_ACTIONLIST) {
            next = run(page->actions, 0);
            if (next < 0) fail("action list %s goes nowhere", page->id);
        } else if ((next = arrive(page->location)) < 0) next = run(page->triggers.on[EVENT_ENTER], 0);
        if (next < 0) break;
        index = next;
    }
    const struct StoryPage *page = page_at(index);
    set_bit(world.seen, index, true);
    game.page = index;
    game.held = 0;
    game.room = location_object(page->location);
    if (decision(page)) {
        game.snapshot[index] = world;
        game.visited[index] = true;
        game.last_decision = index;
    }
    publish();
}

/* Leave the page the reader stands on for another. */
static void go(int index)
{
    const struct StoryPage *page = page_at(game.page);
    run_leave(page->triggers.on[EVENT_LEAVE], story_page_kind_name(page->kind), page->id);
    show(index);
}

static void restart(void)
{
    memset(&world, 0, sizeof(world));
    memset(&map, 0, sizeof(map));
    world.location = world.node = -1;
    for (int i = 0; i < story->variable_count; ++i) world.values[i] = story->variables[i].initial;
    for (int i = 0; i < story->flag_count; ++i) set_bit(world.enabled, i, story->flags[i].initial);
    for (int i = 0; i < story->icon_count; ++i) {
        world.carried[i] = story->icons[i].carried;
        world.lying[i] = story->icons[i].where + 1;
    }
    game.last_decision = 0;
    memset(game.visited, 0, sizeof(game.visited));
    show(story->start);
}

/* An asset or a reply is done: its end trigger, then where it leads. */
static void finish(void)
{
    const struct StoryPage *page = page_at(game.page);
    int next = run(page->triggers.on[EVENT_END], 0);
    if (next < 0) next = page->next;
    if (next < 0 && page->kind == STORY_CONVERSATION) next = page->parent;
    if (next < 0) fail("page %s goes nowhere when it ends", page->id);
    go(next);
}

/* Digits only: "206-555-0182" and "2065550182" are one number. */
static void digits(const char *number, char *out, size_t size)
{
    size_t length = 0;
    for (; *number && length + 1 < size; ++number)
        if (*number >= '0' && *number <= '9') out[length++] = *number;
    out[length] = 0;
}

/* Dial what the keypad shows: an enabled number whose condition holds rings its page. */
static int dial(void)
{
    char wanted[MAX_DIALED], number[MAX_DIALED];
    digits(map.dialed, wanted, sizeof(wanted));
    for (int i = 0; *wanted && i < story->record_count; ++i) {
        const struct StoryRecord *record = &story->records[i];
        if (record->kind != RECORD_PHONE || !record_enabled(i) || !evaluate(&record->test)) continue;
        digits(record->number, number, sizeof(number));
        if (!strcmp(number, wanted)) return record->target;
    }
    return -1;
}

static bool map_command(const char *command, const char *name, const char **rest)
{
    size_t length = strlen(name);
    if (strncmp(command, name, length)) return false;
    *rest = command + length;
    return true;
}

static bool map_action(const char *command)
{
    const char *rest;
    if (!strcmp(command, MAP_COMMAND ":close")) map.screen = MAP_CLOSED;
    else if (!strcmp(command, MAP_COMMAND ":back")) map.screen = MAP_HOME;
    else if (!strcmp(command, MAP_COMMAND ":notes")) map.screen = MAP_NOTES;
    else if (!strcmp(command, MAP_COMMAND ":email")) map.screen = MAP_EMAIL;
    else if (!strcmp(command, MAP_COMMAND ":photos")) map.screen = MAP_PHOTOS;
    else if (!strcmp(command, MAP_COMMAND ":phone")) {
        map.screen = MAP_PHONE;
        map.dialed[0] = 0;
        map.unanswered = false;
    } else if (map_command(command, MAP_COMMAND ":interface:", &rest)) {
        map.screen = MAP_INTERFACE;
        map.record = atoi(rest);
    } else if (map_command(command, MAP_COMMAND ":record:", &rest)) {
        map.list = map.screen;
        map.screen = MAP_RECORD;
        map.record = atoi(rest);
        set_bit(world.read, map.record, true);
    } else if (map_command(command, MAP_COMMAND ":key:", &rest)) {
        size_t length = strlen(map.dialed);
        if (map.unanswered) length = 0;
        map.unanswered = false;
        if (length + strlen(rest) < sizeof(map.dialed)) copy(map.dialed + length, sizeof(map.dialed) - length, rest);
    } else if (!strcmp(command, MAP_COMMAND ":clear")) {
        map.dialed[0] = 0;
        map.unanswered = false;
    } else if (!strcmp(command, MAP_COMMAND ":dial")) {
        int target = dial();
        map.dialed[0] = 0;
        if (target >= 0) {
            go(target);
            return true;
        }
        map.unanswered = true;
    } else if (map_command(command, MAP_COMMAND ":item:", &rest) || map_command(command, MAP_COMMAND ":go:", &rest)) {
        /* A destination or an interface item runs its actions; going somewhere folds the map. */
        const struct StoryHotspot *item = &story->hotspots[atoi(rest)];
        int next = run(item->click, 0);
        if (next < 0) next = item->target;
        if (next >= 0) {
            go(next);
            return true;
        }
    } else return false;
    publish();
    return true;
}

const char *book_name(void)
{
    return story ? story->name : "";
}

void book_init(const char *root, const char *name)
{
    memset(&current, 0, sizeof(current));
    memset(&draft, 0, sizeof(draft));
    free(game.snapshot);
    memset(&game, 0, sizeof(game));
    if (!realpath(root, game.root)) fail("cannot resolve asset root: %s", root);
    if (!name || !*name) fail("name the book to read (--book NAME)");
    story = story_load(game.root, name);
    validate_story();
    game.snapshot = calloc((size_t)story->page_count, sizeof(struct World));
    if (!game.snapshot) fail("out of memory");
    int length = snprintf(game.rooms, sizeof(game.rooms), "%s/books/%s/rooms", game.root, story->name);
    if (length < 0 || (size_t)length >= sizeof(game.rooms)) fail("adventure path is too long");
    length = snprintf(game.illustrations, sizeof(game.illustrations),
                      "%s/books/%s/illustrations", game.root, story->name);
    if (length < 0 || (size_t)length >= sizeof(game.illustrations)) fail("illustration path is too long");
    check_clips();
    restart();
}

void book_shutdown(void)
{
    free(game.snapshot);
    memset(&game, 0, sizeof(game));
    memset(&current, 0, sizeof(current));
    memset(&draft, 0, sizeof(draft));
    story = NULL;
    story_unload();
}

const struct BookPage *book_page(void) { return &current; }
const char *book_root(void) { return game.root; }
const char *book_rooms(void) { return game.rooms; }
const struct Object *book_object(int object)
{
    return &game.objects[object > 0 && object < MAX_OBJECTS ? object : 0];
}

const char *book_page_kind_name(enum PageKind kind)
{
    switch (kind) {
    case PAGE_ROOM: return "room";
    case PAGE_BEAT: return "beat";
    case PAGE_ENDED: return "ended";
    case PAGE_INVALID: break;
    }
    fail("invalid page kind %d", kind);
}

const char *book_choice_kind_name(enum ChoiceKind kind)
{
    switch (kind) {
    case CHOICE_OBJECT: return "object";
    case CHOICE_CONTINUE: return "continue";
    case CHOICE_RETRY: return "retry";
    case CHOICE_ITEM: return "item";
    case CHOICE_ASK: return "ask";
    case CHOICE_END: return "end";
    case CHOICE_MAP: return "map";
    case CHOICE_KEY: return "key";
    case CHOICE_INVALID: break;
    }
    fail("invalid choice kind %d", kind);
}

const char *book_ending_kind_name(enum EndingKind kind)
{
    switch (kind) {
    case ENDING_NONE: return "";
    case ENDING_SUCCESS: return "success";
    case ENDING_PARTIAL: return "partial";
    case ENDING_FAILURE: return "failure";
    }
    fail("invalid ending kind %d", kind);
}

bool book_action(int index)
{
    if (index < 0 || index >= current.choice_count) return false;
    const struct Choice choice = current.choices[index];
    if (map.screen != MAP_CLOSED && choice.kind != CHOICE_CONTINUE) return map_action(choice.command);
    switch (choice.kind) {
    case CHOICE_MAP:
        game.held = 0;
        map.screen = MAP_HOME;
        publish();
        return true;
    case CHOICE_KEY: break;
    case CHOICE_OBJECT:
    case CHOICE_ASK:
    case CHOICE_END: {
        const struct StoryHotspot *hotspot = &story->hotspots[choice_source[index]];
        if (hotspot->take >= 0) {
            world.lying[hotspot->take] = 0;
            world.carried[hotspot->take] = true;
        }
        int next = run(hotspot->click, 0);
        if (next < 0) next = hotspot->target;
        /* Actions alone: the reader stays, and the page shows what changed. */
        if (next < 0) {
            game.held = 0;
            publish();
        } else go(next);
        return true;
    }
    case CHOICE_ITEM: {
        /* Tapping a carried icon holds it; tapping it again puts it away. The page stays. */
        int held = 0;
        for (int i = 0; i < story->icon_count; ++i)
            if (game.icon_object[i] == choice.object) held = i + 1;
        if (!held) fail("unknown carried thing %s", choice.command);
        game.held = game.held == held ? 0 : held;
        publish();
        return true;
    }
    case CHOICE_CONTINUE:
        if (map.screen == MAP_RECORD) {
            map.screen = map.list;
            publish();
        } else finish();
        return true;
    case CHOICE_RETRY: {
        int target = -1;
        for (int i = 0; i < story->page_count; ++i)
            if (!strcmp(page_at(i)->id, choice.command)) target = i;
        /* Return with the world the reader had when they last stood at that decision. */
        if (page_at(game.page)->ending == ENDING_SUCCESS || target < 0 || !game.visited[target]) restart();
        else {
            world = game.snapshot[target];
            game.page = target;
            game.held = 0;
            game.room = location_object(page_at(target)->location);
            game.last_decision = target;
            publish();
        }
        return true;
    }
    case CHOICE_INVALID: break;
    }
    fail("cannot execute choice kind %d", choice.kind);
}

bool book_continue(void)
{
    for (int i = 0; i < current.choice_count; ++i)
        if (current.choices[i].kind == CHOICE_CONTINUE) return book_action(i);
    /* A shot has no Next. The clip ending, or a tap on the picture, finishes it. */
    if (current.kind == PAGE_BEAT && !current.read) {
        finish();
        return true;
    }
    return false;
}

bool book_choose_object(const char *key)
{
    for (int i = 0; i < current.choice_count; ++i) {
        const struct Choice *choice = &current.choices[i];
        if (choice->kind == CHOICE_OBJECT && !strcmp(book_object(choice->object)->key, key))
            return book_action(i);
    }
    return false;
}

bool book_command(const char *input)
{
    if (!input || !*input) return false;
    for (int i = 0; i < current.choice_count; ++i)
        if ((current.choices[i].kind == CHOICE_OBJECT || current.choices[i].kind == CHOICE_ITEM ||
             current.choices[i].kind == CHOICE_ASK || current.choices[i].kind == CHOICE_END ||
             current.choices[i].kind == CHOICE_MAP || current.choices[i].kind == CHOICE_KEY) &&
            !strcmp(input, current.choices[i].command))
            return book_action(i);
    return false;
}

void book_reload(void)
{
    draft = current;
    select_image(&draft, current.camera);
    publish_page();
}

int book_object_room(int object)
{
    return object > 0 && object <= game.object_count ? game.object_room[object] : 0;
}

bool book_item_image(int object, filePath_t path)
{
    path[0] = 0;
    for (int i = 0; i < story->icon_count; ++i) {
        if (game.icon_object[i] != object) continue;
        assetName_t camera;
        int length = snprintf(camera, sizeof(camera), ITEM_ICON_PREFIX "%s", story->icons[i].id);
        if (length < 0 || (size_t)length >= sizeof(camera)) fail("thing icon name is too long");
        return find_image(camera, path);
    }
    return false;
}
