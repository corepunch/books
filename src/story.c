#define _XOPEN_SOURCE 700
#include "book.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* The story runtime: validates the page table from books/<name>.c, keeps the private
 * story state, publishes complete pages and navigates between them. Books are data. */

#define MAX_CHECK_CHAIN MAX_STORY_PAGES
#define ITEM_ICON_PREFIX "item-"

/* Everything "try again" restores: the facts, and where every thing is. */
struct World {
    storyFacts_t facts;   /* story facts that later pages check */
    storyItems_t carried; /* things the hero carries */
    int lying[MAX_STORY_ITEMS]; /* by table index: the location object a thing lies in, or zero */
};

static const struct Story *story;
static struct {
    struct World world;
    int page, room, object_count, last_decision, held; /* held: table index + 1 of the held thing */
    filePath_t root, rooms, illustrations;
    struct Object objects[MAX_OBJECTS];
    int object_room[MAX_OBJECTS];
    int item_object[MAX_STORY_ITEMS]; /* by table index */
    int item_slot[MAX_STORY_ITEMS];   /* by bit position: table index + 1 */
    /* The world as it was when each decision page was shown, for "try again". */
    struct World snapshot[MAX_STORY_PAGES];
    bool visited[MAX_STORY_PAGES];
} game;
/* The story choice behind each published object choice, or -1. */
static int choice_source[MAX_CHOICES];

/* Build into private scratch storage; consumers only see validated, complete pages.
 * Keep these large snapshots off the iPad main-thread stack. */
static struct BookPage current, draft;

static int find_page(const char *id)
{
    if (!id || !*id) return -1;
    for (int i = 0; i < story->page_count; ++i)
        if (!strcmp(story->pages[i].id, id)) return i;
    return -1;
}

static int page_index(const char *id, const char *from)
{
    int index = find_page(id);
    if (index < 0) fail("page %s names a missing page '%s'", from, id ? id : "");
    return index;
}

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

/* Table index of a single-bit thing, or -1. */
static int item_index(storyItems_t item)
{
    if (!item || (item & (item - 1))) return -1;
    int bit = 0;
    while (!(item & (1u << bit))) ++bit;
    return game.item_slot[bit] - 1;
}

static int valid_item(storyItems_t item, const char *page, const char *field)
{
    int index = item_index(item);
    if (index < 0) fail("page %s %s names no single known thing", page, field);
    return index;
}

static void check_items(storyItems_t items, const char *page, const char *field)
{
    for (int bit = 0; bit < MAX_STORY_ITEMS; ++bit)
        if ((items & (1u << bit)) && !game.item_slot[bit]) fail("page %s %s names an unknown thing", page, field);
}

static bool offered(const struct StoryChoice *choice, const struct StoryPage *page)
{
    const struct World *world = &game.world;
    if ((world->facts & choice->requires) != choice->requires || (world->facts & choice->excludes)) return false;
    if (choice->take) return world->lying[item_index(choice->take)] == object_for(page->location, 0);
    int with = choice->with ? item_index(choice->with) + 1 : 0;
    return with == game.held && (!with || (world->carried & choice->with));
}

static void validate_story(void)
{
    if (!story || !story->name || !*story->name || !story->pages) fail("book defines no story");
    if (story->page_count <= 0 || story->page_count > MAX_STORY_PAGES) fail("story has %d pages", story->page_count);
    if (!story->continue_label || !story->retry_label || !story->restart_label) fail("story button labels missing");
    if (find_page(story->start) < 0) fail("story start page '%s' is missing", story->start ? story->start : "");
    if (story->item_count < 0 || story->item_count > MAX_STORY_ITEMS || (story->item_count && !story->items))
        fail("story has %d things", story->item_count);
    for (int i = 0; i < story->item_count; ++i) {
        const struct StoryItem *item = &story->items[i];
        if (!item->id || !*item->id || !item->name || !*item->name || !item->text || !*item->text)
            fail("thing %d needs an id, a name and a text", i);
        if (!item->item || (item->item & (item->item - 1))) fail("thing %s needs a single bit", item->id);
        int bit = 0;
        while (!(item->item & (1u << bit))) ++bit;
        if (game.item_slot[bit]) fail("things %s and %s share a bit", story->items[game.item_slot[bit] - 1].id, item->id);
        game.item_slot[bit] = i + 1;
        if (find_page(item->id) >= 0) fail("thing %s shares its id with a page", item->id);
        for (int j = 0; j < i; ++j)
            if (!strcmp(story->items[j].id, item->id)) fail("duplicate thing '%s'", item->id);
        if (item->carried && item->where) fail("thing %s cannot both lie somewhere and be carried", item->id);
        if (item->where) {
            bool found = false;
            for (int p = 0; p < story->page_count; ++p)
                found |= story->pages[p].kind != STORY_CHECK && story->pages[p].location &&
                         !strcmp(story->pages[p].location, item->where);
            if (!found) fail("thing %s lies in unknown location '%s'", item->id, item->where);
        }
    }
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = &story->pages[i];
        if (!page->id || !*page->id) fail("story page %d has no id", i);
        for (int j = 0; j < i; ++j)
            if (!strcmp(story->pages[j].id, page->id)) fail("duplicate story page '%s'", page->id);
        bool shown = page->kind != STORY_CHECK;
        if (shown && (!page->location || !*page->location || !page->camera || !*page->camera ||
                      !page->text || !*page->text))
            fail("page %s needs a location, a camera and text", page->id);
        if (page->clip && (page->kind == STORY_CHECK || !*page->clip || strpbrk(page->clip, "/.\\")))
            fail("page %s clip must be a bare file name", page->id);
        if (page->kind != STORY_ENDING && page->ending != ENDING_NONE) fail("page %s is not an ending", page->id);
        check_items(page->gives, page->id, "gives");
        check_items(page->removes, page->id, "removes");
        if (page->gives & page->removes) fail("page %s both gives and removes a thing", page->id);
        if (page->kind != STORY_CHECK && page->holds) fail("page %s is not a check", page->id);
        for (int t = 0; t < MAX_PAGE_ITEM_TEXTS; ++t) {
            const struct StoryItemText *response = &page->item_texts[t];
            if (!response->item && !response->text && !response->requires && !response->excludes) continue;
            valid_item(response->item, page->id, "item text");
            if (page->kind != STORY_DECISION || !response->text || !*response->text ||
                (response->requires & response->excludes))
                fail("page %s has invalid item text %d", page->id, t);
            for (int u = 0; u < t; ++u) {
                const struct StoryItemText *other = &page->item_texts[u];
                if (other->item == response->item &&
                    !(other->requires & response->excludes) && !(response->requires & other->excludes))
                    fail("page %s has overlapping item texts", page->id);
            }
        }
        switch (page->kind) {
        case STORY_DECISION: {
            int count = 0;
            for (int c = 0; c < MAX_PAGE_CHOICES; ++c) {
                const struct StoryChoice *choice = &page->choices[c];
                if (!choice->label) continue;
                if (!*choice->label || !choice->anchor || !*choice->anchor)
                    fail("page %s choice %d needs a label and an anchor", page->id, c);
                page_index(choice->target, page->id);
                if (choice->take && choice->with) fail("page %s choice %d both takes and uses a thing", page->id, c);
                if (choice->take) {
                    const struct StoryItem *item = &story->items[valid_item(choice->take, page->id, "take")];
                    if (!item->where || strcmp(item->where, page->location))
                        fail("page %s takes %s, which never lies in %s", page->id, item->id, page->location);
                }
                if (choice->with) valid_item(choice->with, page->id, "with");
                /* Choices for different held things are never offered together. */
                for (int d = 0; d < c; ++d)
                    if (page->choices[d].label && page->choices[d].with == choice->with &&
                        !strcmp(page->choices[d].target, choice->target) &&
                        !(page->choices[d].requires & choice->excludes) && !(choice->requires & page->choices[d].excludes))
                        fail("page %s offers two choices leading to %s", page->id, choice->target);
                ++count;
            }
            if (!count) fail("decision page %s has no choices", page->id);
            break;
        }
        case STORY_PASSAGE: page_index(page->next, page->id); break;
        case STORY_CHECK:
            if (!page->fact && !page->holds) fail("check %s tests no fact or thing", page->id);
            check_items(page->holds, page->id, "holds");
            page_index(page->next, page->id);
            page_index(page->otherwise, page->id);
            break;
        case STORY_ENDING:
            if (page->ending == ENDING_NONE) fail("ending %s has no ending kind", page->id);
            if (page->ending == ENDING_SUCCESS && page->retry)
                fail("success ending %s restarts the book; give it no retry page", page->id);
            if (page->retry && story->pages[page_index(page->retry, page->id)].kind != STORY_DECISION)
                fail("ending %s must retry from a decision page", page->id);
            break;
        case STORY_INVALID:
        default: fail("page %s has no kind", page->id);
        }
    }
    /* Register every location first, then anchors in the room where they first appear. */
    for (int i = 0; i < story->page_count; ++i)
        if (story->pages[i].kind != STORY_CHECK) object_for(story->pages[i].location, 0);
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = &story->pages[i];
        if (page->kind != STORY_DECISION) continue;
        for (int c = 0; c < MAX_PAGE_CHOICES; ++c)
            if (page->choices[c].label) object_for(page->choices[c].anchor, object_for(page->location, 0));
    }
    for (int i = 0; i < story->item_count; ++i) {
        const struct StoryItem *item = &story->items[i];
        game.item_object[i] = object_for(item->id, item->where ? object_for(item->where, 0) : 0);
        if (!item->where) game.object_room[game.item_object[i]] = 0;
    }
}

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
        const char *clip = story->pages[i].clip;
        if (!clip) continue;
        filePath_t path;
        clip_file(clip, path, sizeof(path));
        if (access(path, R_OK)) fail("missing clip %s", path);
    }
}

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
    if (!*draft.text || !*draft.camera) fail("page must have prose and a camera");
    if (draft.choice_count < 0 || draft.choice_count > MAX_CHOICES) fail("invalid choice count");
    switch (draft.kind) {
    case PAGE_ROOM:
        if (!draft.choice_count || draft.ending != ENDING_NONE) fail("room page needs actions and no ending");
        break;
    case PAGE_BEAT:
        if (draft.choice_count != 1 || draft.ending != ENDING_NONE)
            fail("intermediate page must have exactly one Continue choice");
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
        case CHOICE_INVALID:
        default: fail("invalid kind for choice %d", i);
        }
    }
    if (draft.held) {
        bool listed = false;
        for (int i = 0; i < draft.choice_count; ++i)
            listed |= draft.choices[i].kind == CHOICE_ITEM && draft.choices[i].object == draft.held;
        if (draft.kind != PAGE_ROOM || !listed) fail("the held thing must be a carried thing on a room page");
    }
    current = draft;
}

/* Fill a room page: the choices the reader can take, or the held thing's uses, then the carried things. */
static void build_room(void)
{
    const struct StoryPage *page = &story->pages[game.page];
    draft.kind = PAGE_ROOM;
    draft.held = game.held ? game.item_object[game.held - 1] : 0;
    const char *text = page->text;
    if (game.held) {
        storyItems_t item = story->items[game.held - 1].item;
        text = story->items[game.held - 1].text;
        for (int t = 0; t < MAX_PAGE_ITEM_TEXTS; ++t) {
            const struct StoryItemText *response = &page->item_texts[t];
            if (response->item == item && (game.world.facts & response->requires) == response->requires &&
                !(game.world.facts & response->excludes)) {
                text = response->text;
                break;
            }
        }
    }
    copy(draft.text, sizeof(draft.text), text);
    for (int c = 0; c < MAX_PAGE_CHOICES; ++c) {
        const struct StoryChoice *choice = &page->choices[c];
        if (choice->label && offered(choice, page))
            append_choice(CHOICE_OBJECT, choice->label, choice->target, object_for(choice->anchor, game.room), c);
    }
    for (int i = 0; i < story->item_count; ++i)
        if (game.world.carried & story->items[i].item)
            append_choice(CHOICE_ITEM, story->items[i].name, story->items[i].id, game.item_object[i], -1);
}

/* Show a page by index, following invisible checks, and publish it. */
static void show(int index)
{
    struct World *world = &game.world;
    for (int steps = 0; story->pages[index].kind == STORY_CHECK; ++steps) {
        if (steps >= MAX_CHECK_CHAIN) fail("story checks loop at %s", story->pages[index].id);
        const struct StoryPage *check = &story->pages[index];
        bool passed = (world->facts & check->fact) == check->fact && (world->carried & check->holds) == check->holds;
        index = find_page(passed ? check->next : check->otherwise);
    }
    const struct StoryPage *page = &story->pages[index];
    world->facts |= page->sets;
    for (int i = 0; i < story->item_count; ++i)
        if ((page->removes | page->gives) & story->items[i].item) world->lying[i] = 0;
    world->carried = (world->carried & ~page->removes) | page->gives;
    game.page = index;
    game.held = 0;
    game.room = object_for(page->location, 0);
    memset(&draft, 0, sizeof(draft));
    draft.room = game.room;
    copy(draft.text, sizeof(draft.text), page->text);
    /* Every page is one whole picture: the painting for its camera, else the camera's render.
     * A clip plays in that picture; the still is the poster until the first frame. */
    select_image(&draft, page->camera);
    draft.clip[0] = 0;
    if (page->clip) clip_file(page->clip, draft.clip, sizeof(draft.clip));
    switch (page->kind) {
    case STORY_DECISION:
        game.snapshot[index] = *world;
        game.visited[index] = true;
        game.last_decision = index;
        build_room();
        break;
    case STORY_PASSAGE:
        draft.kind = PAGE_BEAT;
        append_choice(CHOICE_CONTINUE, story->continue_label, NULL, 0, -1);
        break;
    case STORY_ENDING:
        draft.kind = PAGE_ENDED;
        draft.ending = page->ending;
        if (page->ending == ENDING_SUCCESS) append_choice(CHOICE_RETRY, story->restart_label, story->start, 0, -1);
        else {
            /* Try again from the named decision when the reader has been there, else from their last one. */
            int retry = find_page(page->retry);
            if (retry < 0 || !game.visited[retry]) retry = game.last_decision;
            append_choice(CHOICE_RETRY, story->retry_label, story->pages[retry].id, 0, -1);
        }
        break;
    case STORY_CHECK:
    case STORY_INVALID:
    default: fail("cannot show page %s", page->id);
    }
    publish_page();
}

static void restart(void)
{
    memset(&game.world, 0, sizeof(game.world));
    for (int i = 0; i < story->item_count; ++i) {
        const struct StoryItem *item = &story->items[i];
        if (item->carried) game.world.carried |= item->item;
        if (item->where) game.world.lying[i] = object_for(item->where, 0);
    }
    game.last_decision = 0;
    memset(game.visited, 0, sizeof(game.visited));
    show(page_index(story->start, "start"));
}

const char *book_name(void)
{
    return book_story()->name;
}

void book_init(const char *root)
{
    memset(&current, 0, sizeof(current));
    memset(&draft, 0, sizeof(draft));
    memset(&game, 0, sizeof(game));
    story = book_story();
    validate_story();
    if (!realpath(root, game.root)) fail("cannot resolve asset root: %s", root);
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
    memset(&game, 0, sizeof(game));
    memset(&current, 0, sizeof(current));
    memset(&draft, 0, sizeof(draft));
    story = NULL;
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
    const struct StoryPage *page = &story->pages[game.page];
    switch (choice.kind) {
    case CHOICE_OBJECT: {
        const struct StoryChoice *source = &page->choices[choice_source[index]];
        if (source->take) {
            int item = item_index(source->take);
            game.world.lying[item] = 0;
            game.world.carried |= source->take;
        }
        show(page_index(choice.command, page->id));
        return true;
    }
    case CHOICE_ITEM: {
        /* Tapping a carried thing holds it; tapping it again puts it away. The page stays. */
        int held = 0;
        for (int i = 0; i < story->item_count; ++i)
            if (game.item_object[i] == choice.object) held = i + 1;
        if (!held) fail("unknown carried thing %s", choice.command);
        game.held = game.held == held ? 0 : held;
        memset(&draft, 0, sizeof(draft));
        draft.room = game.room;
        select_image(&draft, page->camera);
        build_room();
        publish_page();
        return true;
    }
    case CHOICE_CONTINUE:
        show(page_index(page->next, page->id));
        return true;
    case CHOICE_RETRY: {
        int target = find_page(choice.command);
        /* Return with the facts the reader had when they last stood at that decision. */
        if (page->ending == ENDING_SUCCESS || target < 0 || !game.visited[target]) restart();
        else {
            game.world = game.snapshot[target];
            show(target);
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
        if ((current.choices[i].kind == CHOICE_OBJECT || current.choices[i].kind == CHOICE_ITEM) &&
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
    for (int i = 0; i < story->item_count; ++i) {
        if (game.item_object[i] != object) continue;
        assetName_t camera;
        int length = snprintf(camera, sizeof(camera), ITEM_ICON_PREFIX "%s", story->items[i].id);
        if (length < 0 || (size_t)length >= sizeof(camera)) fail("thing icon name is too long");
        return find_image(camera, path);
    }
    return false;
}
