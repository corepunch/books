#define _XOPEN_SOURCE 700
#include "book.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* The book tool: inspects and plays a book through the same loader and story runtime as
 * the app, so the tool and the game never disagree about a book. */

#define USAGE \
    "usage: book COMMAND BOOK [ARGS] [--root PATH]\n" \
    "  check  BOOK                 validate the story, stills, clips and scene anchors\n" \
    "  stats  BOOK [--json]        views, circles, charviews, conversations, clips and state\n" \
    "                              per location, as The X-Files Game counted them\n" \
    "  graph  BOOK [--dot]         every route, and pages, variables, icons and flags that go nowhere\n" \
    "  query  BOOK NAME            everything about a page, variable, icon, character, flag,\n" \
    "                              record, node, location, viewpoint, camera, clip or anchor\n" \
    "  play   BOOK [STEP ...]      a transcript; STEP is a choice's command, continue, retry,\n" \
    "                              hold:ICON or a choice number (commas also split)\n" \
    "  assets BOOK [--missing] [--json]\n" \
    "                              stills, clips, icons and photos, with the prose each one shows;\n" \
    "                              a placeholder is a file tools/placeholder.py made\n"
#define ILLUSTRATION_SUFFIX ".png"
#define RENDER_SUFFIX ".jpg"
#define CLIP_SUFFIX ".mp4"
#define ITEM_ICON_PREFIX "item-"
/* tools/placeholder.py stamps its stills and clips; the stamp sits near the start of the file. */
#define PLACEHOLDER_MARKER "book-placeholder "
#define PLACEHOLDER_SCAN_BYTES 65536
#define MAX_STORY_EDGES (MAX_STORY_HOTSPOTS + MAX_STORY_ACTIONS + MAX_STORY_PAGES * 2 + MAX_STORY_RECORDS)
#define MAX_WALK_DEPTH 64

static const struct Story *story;
static const char *root = ".", *name;
static bool json, dot, missing_only;
static int problems;

enum Asset { ASSET_PAINTING, ASSET_RENDER, ASSET_PRESENT, ASSET_PLACEHOLDER, ASSET_MISSING };
static const char *const asset_names[] = {"painting", "render", "present", "placeholder", "missing"};
static const char *const record_names[] = {"note", "email", "photo", "phone", "interface"};
static const char *const type_names[] = {"bool", "int", "char", "string"};

static const struct StoryPage *page_at(int index) { return &story->pages[index]; }
static const struct StoryHotspot *hotspot_at(const struct StoryPage *page, int i)
{
    return &story->hotspots[page->hotspot_first + i];
}

/* What a reader sees: a view, a charview, a map, a shot, a document, a reply, an ending. */
static const char *role(const struct StoryPage *page)
{
    switch (page->kind) {
    case STORY_ASSET: return !story->fmv ? "passage" : page->read ? "document" : "shot";
    case STORY_CONVERSATION: return "reply";
    case STORY_VIEW:
    case STORY_CHARVIEW:
    case STORY_ENDING:
    case STORY_MAP:
    case STORY_ACTIONLIST:
    case STORY_INVALID: break;
    }
    return story_page_kind_name(page->kind);
}

static bool shown(const struct StoryPage *page) { return page->kind != STORY_ACTIONLIST; }

static int find_page(const char *id)
{
    for (int i = 0; id && i < story->page_count; ++i)
        if (!strcmp(page_at(i)->id, id)) return i;
    return -1;
}

static void print_where(int page)
{
    printf("%s:%d", story->locations[page_at(page)->location].file, story_line(page));
}

/* --- Walking actions --------------------------------------------------------------- */

/* Visit every action in a range, inside if and else blocks too. */
typedef void (*ActionVisitor)(const struct StoryAction *action, void *context);
static void walk(struct StoryActions range, ActionVisitor visit, void *context, int depth)
{
    if (depth > MAX_WALK_DEPTH) return;
    for (int i = 0; i < range.count; ++i) {
        const struct StoryAction *action = &story->actions[range.first + i];
        visit(action, context);
        if (action->op == ACTION_IF) {
            walk(action->then, visit, context, depth + 1);
            walk(action->otherwise, visit, context, depth + 1);
        }
    }
}

/* Every action range a page owns: its triggers, its action list, its choices' actions. */
static void walk_page(const struct StoryPage *page, ActionVisitor visit, void *context)
{
    for (int e = 0; e < EVENT_COUNT; ++e) walk(page->triggers.on[e], visit, context, 0);
    walk(page->actions, visit, context, 0);
    for (int h = 0; h < page->hotspot_count; ++h) walk(hotspot_at(page, h)->click, visit, context, 0);
}

static void walk_story(ActionVisitor visit, void *context)
{
    for (int i = 0; i < story->page_count; ++i) walk_page(page_at(i), visit, context);
    for (int i = 0; i < story->location_count; ++i)
        for (int e = 0; e < EVENT_COUNT; ++e) walk(story->locations[i].triggers.on[e], visit, context, 0);
    for (int i = 0; i < story->node_count; ++i)
        for (int e = 0; e < EVENT_COUNT; ++e) walk(story->nodes[i].triggers.on[e], visit, context, 0);
    for (int r = 0; r < story->record_count; ++r)
        for (int h = 0; h < story->records[r].hotspot_count; ++h)
            walk(story->hotspots[story->records[r].hotspot_first + h].click, visit, context, 0);
}

/* Variables a condition reads. */
static void condition_variables(const struct StoryCondition *test, bool *used)
{
    for (int t = 0; t < test->count; ++t)
        if (story->terms[test->first + t].kind == TERM_VARIABLE) used[story->terms[test->first + t].value] = true;
}

static void condition_icons(const struct StoryCondition *test, bool *used)
{
    for (int t = 0; t < test->count; ++t) {
        const struct StoryTerm *term = &story->terms[test->first + t];
        if (term->kind == TERM_HAS || term->kind == TERM_HOLDING) used[term->value] = true;
    }
}

/* Each condition in the story, wherever it is. */
typedef void (*ConditionVisitor)(const struct StoryCondition *test, void *context);
struct ConditionWalk { ConditionVisitor visit; void *context; };
static void condition_in_action(const struct StoryAction *action, void *context)
{
    struct ConditionWalk *walker = context;
    if (action->op == ACTION_IF) walker->visit(&action->test, walker->context);
}

static void walk_conditions(ConditionVisitor visit, void *context)
{
    struct ConditionWalk walker = {visit, context};
    walk_story(condition_in_action, &walker);
    for (int i = 0; i < story->hotspot_count; ++i) visit(&story->hotspots[i].test, context);
    for (int i = 0; i < story->response_count; ++i) visit(&story->responses[i].test, context);
    for (int i = 0; i < story->record_count; ++i) visit(&story->records[i].test, context);
}

/* --- Assets ---------------------------------------------------------------------- */

static void file_path(filePath_t path, const char *directory, const char *file, const char *suffix)
{
    int length = snprintf(path, sizeof(filePath_t), "%s/books/%s/%s/%s%s", root, story->name, directory, file, suffix);
    if (length < 0 || (size_t)length >= sizeof(filePath_t)) fail("asset path is too long");
}

/* A file tools/placeholder.py made, to be replaced by finished art. */
static bool placeholder(const char *path)
{
    static char head[PLACEHOLDER_SCAN_BYTES];
    FILE *file = fopen(path, "rb");
    if (!file) return false;
    size_t length = fread(head, 1, sizeof(head), file);
    fclose(file);
    size_t marker = strlen(PLACEHOLDER_MARKER);
    for (size_t i = 0; i + marker <= length; ++i)
        if (!memcmp(head + i, PLACEHOLDER_MARKER, marker)) return true;
    return false;
}

/* A camera's picture: its painting, else its render; the same order the runtime uses. */
static enum Asset still(const char *camera, filePath_t path)
{
    file_path(path, "illustrations", camera, ILLUSTRATION_SUFFIX);
    if (!access(path, R_OK)) return ASSET_PAINTING;
    file_path(path, "rooms", camera, RENDER_SUFFIX);
    if (access(path, R_OK)) return ASSET_MISSING;
    return placeholder(path) ? ASSET_PLACEHOLDER : ASSET_RENDER;
}

static enum Asset clip(const char *name_of_clip, filePath_t path)
{
    file_path(path, "clips", name_of_clip, CLIP_SUFFIX);
    if (access(path, R_OK)) return ASSET_MISSING;
    return placeholder(path) ? ASSET_PLACEHOLDER : ASSET_PRESENT;
}

static void problem(int page, const char *format, const char *detail)
{
    ++problems;
    if (page >= 0) {
        print_where(page);
        printf(": %s: ", page_at(page)->id);
    }
    printf(format, detail);
    putchar('\n');
}

/* check: the runtime's own validation, then every picture and every anchor a circle needs. */
static void check(void)
{
    book_init(root, name);
    filePath_t rooms, path;
    int length = snprintf(rooms, sizeof(rooms), "%s/books/%s/rooms", root, story->name);
    if (length < 0 || (size_t)length >= sizeof(rooms)) fail("rooms path is too long");
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = page_at(i);
        if (!shown(page)) continue;
        if (still(page->camera, path) == ASSET_MISSING) problem(i, "camera %s has no still", page->camera);
        if (page->kind != STORY_VIEW && page->kind != STORY_MAP) continue;
        bool anchored = false;
        for (int h = 0; h < page->hotspot_count; ++h) anchored |= hotspot_at(page, h)->anchor != NULL;
        if (!anchored) continue;
        scene_load(rooms, page->camera);
        if (!scene_has_camera()) {
            problem(i, "camera %s is in no .blks scene, so its circles cannot be placed", page->camera);
            continue;
        }
        for (int h = 0; h < page->hotspot_count; ++h) {
            const struct StoryHotspot *hotspot = hotspot_at(page, h);
            if (hotspot->anchor && !scene_has_anchor(hotspot->anchor))
                problem(i, "anchor %s is not in the camera's scene", hotspot->anchor);
        }
    }
    scene_shutdown();
    for (int i = 0; i < story->icon_count; ++i) {
        assetName_t camera;
        snprintf(camera, sizeof(camera), ITEM_ICON_PREFIX "%s", story->icons[i].id);
        if (still(camera, path) == ASSET_MISSING) problem(-1, "icon %s has no icon still", story->icons[i].id);
    }
    for (int i = 0; i < story->record_count; ++i)
        if (story->records[i].kind == RECORD_PHOTO && still(story->records[i].camera, path) == ASSET_MISSING)
            problem(-1, "photo camera %s has no still", story->records[i].camera);
    if (problems) {
        fflush(stdout);
        fail("%s: %d problem%s", story->name, problems, problems == 1 ? "" : "s");
    }
    printf("%s: %d pages in %d locations and %d nodes, %d variables, %d icons, %d characters: ok\n", story->name,
           story->page_count, story->location_count, story->node_count, story->variable_count, story->icon_count,
           story->character_count);
}

/* --- stats ----------------------------------------------------------------------- */

struct Tally {
    int pages, viewpoints, views, maps, charviews, conversations, shots, documents, endings, actionlists;
    int navs, explorables, characters_in_views, destinations, held, screens, clips, triggers, actions;
    int icons;
};

static void count_action(const struct StoryAction *action, void *context)
{
    (void)action;
    ++*(int *)context;
}

static bool repeated(int first, int index, bool camera)
{
    const char *value = camera ? page_at(index)->camera : page_at(index)->clip;
    for (int i = first; i < index; ++i) {
        const char *other = camera ? page_at(i)->camera : page_at(i)->clip;
        if (shown(page_at(i)) && other && !strcmp(other, value)) return true;
    }
    return false;
}

static struct Tally tally(int first, int count, int location)
{
    struct Tally t = {0};
    for (int v = 0; v < story->viewpoint_count; ++v) t.viewpoints += story->viewpoints[v].location == location || location < 0;
    for (int i = first; i < first + count; ++i) {
        const struct StoryPage *page = page_at(i);
        ++t.pages;
        switch (page->kind) {
        case STORY_VIEW: ++t.views; break;
        case STORY_MAP: ++t.maps; break;
        case STORY_CHARVIEW: ++t.charviews; break;
        case STORY_ASSET:
            if (page->read || !story->fmv) ++t.documents;
            else ++t.shots;
            break;
        case STORY_CONVERSATION: break;
        case STORY_ENDING: ++t.endings; break;
        case STORY_ACTIONLIST: ++t.actionlists; break;
        case STORY_INVALID: break;
        }
        for (int h = 0; h < page->hotspot_count; ++h) {
            const struct StoryHotspot *hotspot = hotspot_at(page, h);
            if (hotspot->with >= 0) ++t.held;
            switch (hotspot->kind) {
            case HOTSPOT_NAV: ++t.navs; break;
            case HOTSPOT_EXPLORABLE: ++t.explorables; break;
            case HOTSPOT_CHARVIEW: ++t.characters_in_views; break;
            case HOTSPOT_CONVERSATION: ++t.conversations; break;
            case HOTSPOT_DESTINATION: ++t.destinations; break;
            case HOTSPOT_ITEM:
            case HOTSPOT_INVALID: break;
            }
        }
        for (int e = 0; e < EVENT_COUNT; ++e) t.triggers += page->triggers.on[e].count > 0;
        walk_page(page, count_action, &t.actions);
        if (!shown(page)) continue;
        if (!repeated(first, i, true)) ++t.screens;
        if (page->clip && !repeated(first, i, false)) ++t.clips;
    }
    for (int i = 0; i < story->icon_count; ++i) t.icons += story->icons[i].where == location;
    return t;
}

static void print_tally_json(const struct Tally *t)
{
    printf("\"pages\":%d,\"viewpoints\":%d,\"views\":%d,\"maps\":%d,\"charviews\":%d,\"conversations\":%d,"
           "\"shots\":%d,\"documents\":%d,\"endings\":%d,\"actionlists\":%d,\"navs\":%d,\"explorables\":%d,"
           "\"characters_in_views\":%d,\"destinations\":%d,\"held_choices\":%d,\"screens\":%d,\"clips\":%d,"
           "\"triggers\":%d,\"actions\":%d,\"icons\":%d",
           t->pages, t->viewpoints, t->views, t->maps, t->charviews, t->conversations, t->shots, t->documents,
           t->endings, t->actionlists, t->navs, t->explorables, t->characters_in_views, t->destinations, t->held,
           t->screens, t->clips, t->triggers, t->actions, t->icons);
}

static double ratio(int a, int b) { return b ? (double)a / b : 0; }

static void stats(void)
{
    struct Tally total = tally(0, story->page_count, -1);
    total.icons = story->icon_count;
    int endings[ENDING_FAILURE + 1] = {0}, icon_kinds[ICON_ACTION + 1] = {0}, records[RECORD_INTERFACE + 1] = {0};
    int types[VARIABLE_STRING + 1] = {0};
    for (int i = 0; i < story->page_count; ++i)
        if (page_at(i)->kind == STORY_ENDING) ++endings[page_at(i)->ending];
    for (int i = 0; i < story->icon_count; ++i) ++icon_kinds[story->icons[i].kind];
    for (int i = 0; i < story->record_count; ++i) ++records[story->records[i].kind];
    for (int i = 0; i < story->variable_count; ++i) ++types[story->variables[i].type];
    int circles = total.navs + total.explorables + total.characters_in_views;
    if (json) {
        printf("{\"book\":"); json_string(story->name);
        printf(",\"fmv\":%s,\"locations\":[", story->fmv ? "true" : "false");
        for (int l = 0; l < story->location_count; ++l) {
            const struct StoryLocation *location = &story->locations[l];
            struct Tally t = tally(location->first, location->count, l);
            printf("%s{\"location\":", l ? "," : ""); json_string(location->id);
            printf(",\"node\":"); json_string(story->nodes[location->node].id);
            printf(",\"file\":"); json_string(location->file);
            printf(","); print_tally_json(&t); printf("}");
        }
        printf("],\"total\":{"); print_tally_json(&total);
        printf(",\"nodes\":%d,\"locations\":%d,\"characters\":%d,\"flags\":%d", story->node_count,
               story->location_count, story->character_count, story->flag_count);
        printf(",\"variables\":{\"bool\":%d,\"int\":%d,\"char\":%d,\"string\":%d}",
               types[VARIABLE_BOOL], types[VARIABLE_INT], types[VARIABLE_CHAR], types[VARIABLE_STRING]);
        printf(",\"icons_by_kind\":{");
        for (int k = 0; k <= ICON_ACTION; ++k) printf("%s\"%s\":%d", k ? "," : "", story_icon_kind_name(k), icon_kinds[k]);
        printf("},\"records\":{");
        for (int k = 0; k <= RECORD_INTERFACE; ++k) printf("%s\"%s\":%d", k ? "," : "", record_names[k], records[k]);
        printf("},\"success_endings\":%d,\"partial_endings\":%d,\"failure_endings\":%d}",
               endings[ENDING_SUCCESS], endings[ENDING_PARTIAL], endings[ENDING_FAILURE]);
        printf(",\"ratios\":{\"circles_per_view\":%.2f,\"conversations_per_charview\":%.2f,\"clips_per_screen\":%.2f,"
               "\"screens_per_location\":%.2f,\"shots_per_decision\":%.2f,\"actions_per_page\":%.2f}}\n",
               ratio(circles, total.views), ratio(total.conversations, total.charviews), ratio(total.clips, total.screens),
               ratio(total.screens, story->location_count), ratio(total.shots, total.views + total.charviews + total.maps),
               ratio(total.actions, total.pages));
        return;
    }
    const char *prose_name = story->fmv ? "docs" : "prose";
    printf("%-12s %5s %4s %5s %5s %4s %5s %5s %4s  %4s %5s %5s %6s %4s  %7s %5s %7s\n", "location", "pages", "vps",
           "views", "chars", "conv", "shots", prose_name, "ends", "navs", "expl", "lists", "icons", "held",
           "screens", "clips", "actions");
    for (int l = 0; l <= story->location_count; ++l) {
        bool sum = l == story->location_count;
        struct Tally t = sum ? total : tally(story->locations[l].first, story->locations[l].count, l);
        printf("%-12s %5d %4d %5d %5d %4d %5d %5d %4d  %4d %5d %5d %6d %4d  %7d %5d %7d\n",
               sum ? "total" : story->locations[l].id, t.pages, t.viewpoints, t.views + t.maps, t.charviews,
               t.conversations, t.shots, t.documents, t.endings, t.navs, t.explorables, t.actionlists, t.icons,
               t.held, t.screens, t.clips, t.actions);
    }
    printf("\n%d nodes, %d locations, %d screens (distinct stills), %d clips, %d characters\n", story->node_count,
           story->location_count, total.screens, total.clips, story->character_count);
    printf("variables: %d bool, %d int, %d char, %d string; %d enable flags\n", types[VARIABLE_BOOL],
           types[VARIABLE_INT], types[VARIABLE_CHAR], types[VARIABLE_STRING], story->flag_count);
    printf("icons:");
    for (int k = 0; k <= ICON_ACTION; ++k) printf(" %d %s%s", icon_kinds[k], story_icon_kind_name(k), k < ICON_ACTION ? "," : "\n");
    printf("records:");
    for (int k = 0; k <= RECORD_INTERFACE; ++k) printf(" %d %s%s", records[k], record_names[k], k < RECORD_INTERFACE ? "," : "\n");
    printf("endings: %d success, %d partial, %d failure\n", endings[ENDING_SUCCESS], endings[ENDING_PARTIAL],
           endings[ENDING_FAILURE]);
    printf("circles per view %.2f, conversations per charview %.2f, clips per screen %.2f, screens per location %.2f\n",
           ratio(circles, total.views), ratio(total.conversations, total.charviews), ratio(total.clips, total.screens),
           ratio(total.screens, story->location_count));
    printf("shots per decision %.2f, actions per page %.2f (a decision is a view, a charview or a map)\n",
           ratio(total.shots, total.views + total.charviews + total.maps), ratio(total.actions, total.pages));
}

/* --- graph ------------------------------------------------------------------------- */

struct Edge { int from, to; const char *label, *kind; const struct StoryHotspot *hotspot; };
static struct Edge edges[MAX_STORY_EDGES];
static int edge_count;

static void add_edge(int from, int to, const char *label, const char *kind, const struct StoryHotspot *hotspot)
{
    if (to < 0) return;
    if (edge_count >= MAX_STORY_EDGES) fail("too many story edges");
    edges[edge_count++] = (struct Edge){from, to, label, kind, hotspot};
}

struct EdgeSource { int from; const char *label; const struct StoryHotspot *hotspot; };
static void goto_edge(const struct StoryAction *action, void *context)
{
    /* A called list's gotos leave from the caller's page. */
    static int calls;
    const struct EdgeSource *source = context;
    if (action->op == ACTION_GOTO) add_edge(source->from, action->target, source->label, "goto", source->hotspot);
    if (action->op == ACTION_CALL && calls < MAX_WALK_DEPTH) {
        ++calls;
        walk(page_at(action->target)->actions, goto_edge, context, 0);
        --calls;
    }
}

static void collect_edges(void)
{
    edge_count = 0;
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = page_at(i);
        for (int h = 0; h < page->hotspot_count; ++h) {
            const struct StoryHotspot *hotspot = hotspot_at(page, h);
            add_edge(i, hotspot->target, hotspot->label, story_hotspot_kind_name(hotspot->kind), hotspot);
            struct EdgeSource source = {i, hotspot->label, hotspot};
            walk(hotspot->click, goto_edge, &source, 0);
        }
        struct EdgeSource source = {i, NULL, NULL};
        for (int e = 0; e < EVENT_COUNT; ++e) walk(page->triggers.on[e], goto_edge, &source, 0);
        walk(page->actions, goto_edge, &source, 0);
        if (page->kind == STORY_ASSET || page->kind == STORY_CONVERSATION)
            add_edge(i, page->next >= 0 ? page->next : page->kind == STORY_CONVERSATION ? page->parent : -1, NULL, "next", NULL);
        if (page->kind == STORY_ENDING) {
            if (page->ending == ENDING_SUCCESS) add_edge(i, story->start, NULL, "restart", NULL);
            else add_edge(i, page->retry, NULL, "retry", NULL);
        }
    }
}

static bool retreat(const struct Edge *edge) { return !strcmp(edge->kind, "retry") || !strcmp(edge->kind, "restart"); }

static void spread(bool *marked, int page, bool forward)
{
    if (page < 0 || marked[page]) return;
    marked[page] = true;
    for (int e = 0; e < edge_count; ++e) {
        /* Retries and restarts lead back; they do not make a page reachable or an ending near. */
        if (retreat(&edges[e])) continue;
        if (forward && edges[e].from == page) spread(marked, edges[e].to, true);
        if (!forward && edges[e].to == page) spread(marked, edges[e].from, false);
    }
}

static void print_condition_text(const struct StoryCondition *test)
{
    if (test->count) printf(" if %s", test->source);
}

static void print_hotspot_conditions(const struct StoryHotspot *hotspot)
{
    print_condition_text(&hotspot->test);
    if (hotspot->take >= 0) printf(" takes %s", story->icons[hotspot->take].id);
    if (hotspot->with >= 0) printf(" with %s", story->icons[hotspot->with].id);
    if (hotspot->ends) printf(" ends the talk");
    if (hotspot->flag >= 0 && !story->flags[hotspot->flag].initial) printf(" (starts disabled)");
}

static void print_edge_text(const struct Edge *edge)
{
    printf("    ");
    if (edge->hotspot) {
        printf("%s \"%s\"", story_hotspot_kind_name(edge->hotspot->kind), edge->label);
        if (edge->hotspot->anchor) printf(" @%s", edge->hotspot->anchor);
        if (edge->hotspot->edge) printf(" @%s edge", edge->hotspot->edge == EDGE_LEFT ? "left" :
                                         edge->hotspot->edge == EDGE_RIGHT ? "right" : "back");
        print_hotspot_conditions(edge->hotspot);
        if (!strcmp(edge->kind, "goto")) printf(" (by its actions)");
    } else printf("%s", edge->kind);
    printf(" -> %s\n", page_at(edge->to)->id);
}

static void print_dot(void)
{
    printf("digraph \"%s\" {\n  rankdir=LR;\n  node [fontname=\"Helvetica\", fontsize=10];\n"
           "  edge [fontname=\"Helvetica\", fontsize=9];\n", story->name);
    for (int l = 0; l < story->location_count; ++l) {
        const struct StoryLocation *location = &story->locations[l];
        printf("  subgraph \"cluster_%s\" {\n    label=\"%s\";\n", location->id, location->id);
        for (int i = location->first; i < location->first + location->count; ++i) {
            const struct StoryPage *page = page_at(i);
            const char *shape = page->kind == STORY_VIEW || page->kind == STORY_MAP ? "box" :
                                page->kind == STORY_CHARVIEW ? "house" : page->kind == STORY_ACTIONLIST ? "diamond" :
                                page->kind == STORY_ENDING ? "doubleoctagon" : "ellipse";
            printf("    \"%s\" [shape=%s, tooltip=\"%s\"];\n", page->id, shape, role(page));
        }
        printf("  }\n");
    }
    for (int e = 0; e < edge_count; ++e) {
        const struct Edge *edge = &edges[e];
        printf("  \"%s\" -> \"%s\"", page_at(edge->from)->id, page_at(edge->to)->id);
        if (edge->label) {
            printf(" [label=\"");
            for (const char *p = edge->label; *p; ++p) printf(*p == '"' ? "\\\"" : "%c", *p);
            printf("\"%s]", edge->hotspot && edge->hotspot->with >= 0 ? ", style=dashed" : "");
        } else if (strcmp(edge->kind, "next")) printf(" [label=\"%s\", style=dotted]", edge->kind);
        printf(";\n");
    }
    printf("}\n");
}

struct Usage {
    bool set[MAX_STORY_VARIABLES], read[MAX_STORY_VARIABLES];
    bool given[MAX_STORY_ICONS], used[MAX_STORY_ICONS];
    bool enabled[MAX_STORY_FLAGS], tested[MAX_STORY_FLAGS];
    bool shown[MAX_STORY_RECORDS];
};

static void usage_of_action(const struct StoryAction *action, void *context)
{
    struct Usage *usage = context;
    switch (action->op) {
    case ACTION_SET:
    case ACTION_ADD:
        usage->set[action->target] = true;
        if (action->from_variable) usage->read[action->value] = true;
        break;
    case ACTION_ENABLE: usage->enabled[action->target] = true; break;
    case ACTION_DISABLE: usage->tested[action->target] = true; break;
    case ACTION_GIVE: usage->given[action->target] = true; break;
    case ACTION_REMOVE: usage->used[action->target] = true; break;
    case ACTION_SHOW: usage->shown[action->target] = true; break;
    case ACTION_IF:
    case ACTION_GOTO:
    case ACTION_CALL:
    case ACTION_HIDE:
    case ACTION_SCRIPT:
    case ACTION_INVALID: break;
    }
}

static void usage_of_condition(const struct StoryCondition *test, void *context)
{
    struct Usage *usage = context;
    condition_variables(test, usage->read);
    condition_icons(test, usage->used);
    for (int t = 0; t < test->count; ++t)
        if (story->terms[test->first + t].kind == TERM_ENABLED) usage->tested[story->terms[test->first + t].value] = true;
}

static void graph(void)
{
    collect_edges();
    if (dot) {
        print_dot();
        return;
    }
    for (int l = 0; l < story->location_count; ++l) {
        const struct StoryLocation *location = &story->locations[l];
        printf("%s (%s, node %s)\n", location->id, location->file, story->nodes[location->node].id);
        for (int i = location->first; i < location->first + location->count; ++i) {
            const struct StoryPage *page = page_at(i);
            printf("  %s [%s", page->id, role(page));
            if (page->kind == STORY_ENDING) printf(" %s", book_ending_kind_name(page->ending));
            if (page->viewpoint >= 0) printf(" in viewpoint %s", story->viewpoints[page->viewpoint].id);
            printf("]\n");
            for (int e = 0; e < edge_count; ++e)
                if (edges[e].from == i) print_edge_text(&edges[e]);
        }
    }
    static bool reached[MAX_STORY_PAGES], ending_near[MAX_STORY_PAGES];
    memset(reached, 0, sizeof(reached));
    memset(ending_near, 0, sizeof(ending_near));
    spread(reached, story->start, true);
    /* A phone number or an interface item can open a page from anywhere. */
    for (int r = 0; r < story->record_count; ++r) {
        spread(reached, story->records[r].target, true);
        for (int h = 0; h < story->records[r].hotspot_count; ++h)
            spread(reached, story->hotspots[story->records[r].hotspot_first + h].target, true);
    }
    for (int i = 0; i < story->page_count; ++i)
        if (page_at(i)->kind == STORY_ENDING) spread(ending_near, i, false);
    static struct Usage usage;
    memset(&usage, 0, sizeof(usage));
    walk_story(usage_of_action, &usage);
    walk_conditions(usage_of_condition, &usage);
    for (int i = 0; i < story->hotspot_count; ++i) {
        const struct StoryHotspot *hotspot = &story->hotspots[i];
        if (hotspot->with >= 0) usage.used[hotspot->with] = true;
        if (hotspot->take >= 0) usage.given[hotspot->take] = true;
    }
    for (int i = 0; i < story->icon_count; ++i)
        if (story->icons[i].carried) usage.given[i] = true;
    printf("\nfindings\n");
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = page_at(i);
        if (!reached[i]) problem(i, "no route from the start reaches it%s", "");
        if (!ending_near[i] && page->kind != STORY_ENDING) problem(i, "no route from here reaches an ending%s", "");
        int plain = 0;
        for (int h = 0; h < page->hotspot_count; ++h) plain += hotspot_at(page, h)->with < 0;
        if (page->kind == STORY_VIEW && plain < 2) problem(i, "a view with fewer than two circles%s", "");
    }
    for (int i = 0; i < story->variable_count; ++i) {
        const char *id = story->variables[i].id;
        if (usage.set[i] && !usage.read[i]) problem(-1, "variable %s is set but never tested", id);
        if (!usage.set[i] && usage.read[i] && story->variables[i].type == VARIABLE_BOOL && !story->variables[i].initial)
            problem(-1, "variable %s is tested but never set", id);
        if (!usage.set[i] && !usage.read[i]) problem(-1, "variable %s is never used", id);
    }
    for (int i = 0; i < story->icon_count; ++i) {
        if (!usage.given[i] && story->icons[i].where < 0) problem(-1, "icon %s can never be had", story->icons[i].id);
        if (!usage.used[i]) problem(-1, "icon %s is never used", story->icons[i].id);
    }
    for (int i = 0; i < story->flag_count; ++i)
        if (!story->flags[i].initial && !usage.enabled[i]) problem(-1, "%s starts disabled and nothing enables it", story->flags[i].id);
    for (int i = 0; i < story->record_count; ++i)
        if (story->records[i].kind == RECORD_INTERFACE && !usage.shown[i])
            problem(-1, "interface %s is never shown", story->records[i].id);
    if (!problems) printf("none\n");
}

/* --- query ------------------------------------------------------------------------- */

static int mentions;

static void heading(const char *what)
{
    printf("%s%s\n", mentions++ ? "\n" : "", what);
}

static void mention(int page, const char *what)
{
    printf("  ");
    print_where(page);
    printf("  %s [%s]%s%s", page_at(page)->id, role(page_at(page)), *what && *what != '\n' ? " " : "", what);
}

static void print_actions(struct StoryActions range, int depth)
{
    for (int i = 0; i < range.count; ++i) {
        const struct StoryAction *action = &story->actions[range.first + i];
        printf("%*s", 6 + depth * 2, "");
        switch (action->op) {
        case ACTION_SET:
            printf("set %s = ", story->variables[action->target].id);
            if (action->from_variable) printf("%s\n", story->variables[action->value].id);
            else if (story->variables[action->target].type == VARIABLE_STRING) printf("'%s'\n", story->strings[action->value]);
            else if (story->variables[action->target].type == VARIABLE_CHAR) printf("'%c'\n", action->value);
            else printf("%d\n", action->value);
            break;
        case ACTION_ADD: printf("add %d to %s\n", action->value, story->variables[action->target].id); break;
        case ACTION_ENABLE: printf("enable %s\n", story->flags[action->target].id); break;
        case ACTION_DISABLE: printf("disable %s\n", story->flags[action->target].id); break;
        case ACTION_GIVE: printf("give %s\n", story->icons[action->target].id); break;
        case ACTION_REMOVE: printf("remove %s\n", story->icons[action->target].id); break;
        case ACTION_GOTO: printf("goto %s\n", page_at(action->target)->id); break;
        case ACTION_CALL: printf("call %s\n", page_at(action->target)->id); break;
        case ACTION_SHOW: printf("show %s\n", story->records[action->target].id); break;
        case ACTION_HIDE: printf("hide %s\n", story->records[action->target].id); break;
        case ACTION_SCRIPT: printf("script %s%s%s\n", action->name, action->args ? " " : "", action->args ? action->args : ""); break;
        case ACTION_IF:
            printf("if %s\n", action->test.source);
            print_actions(action->then, depth + 1);
            if (action->otherwise.count) {
                printf("%*selse\n", 6 + depth * 2, "");
                print_actions(action->otherwise, depth + 1);
            }
            break;
        case ACTION_INVALID: printf("?\n"); break;
        }
    }
}

static void query_page(int index)
{
    const struct StoryPage *page = page_at(index);
    filePath_t path;
    heading("page");
    mention(index, page->kind == STORY_ENDING ? book_ending_kind_name(page->ending) : "");
    printf("\n  location %s", story->locations[page->location].id);
    if (page->viewpoint >= 0) printf(", viewpoint %s", story->viewpoints[page->viewpoint].id);
    if (page->direction) printf(", facing %s", page->direction);
    if (page->character >= 0) printf(", character %s", story->characters[page->character].id);
    if (page->parent >= 0) printf(", within %s", page_at(page->parent)->id);
    printf("\n");
    if (shown(page)) {
        printf("  camera %s (%s)", page->camera, asset_names[still(page->camera, path)]);
        if (page->clip) {
            printf(", clip %s (%s)", page->clip, asset_names[clip(page->clip, path)]);
            if (page->clip_to) printf(" %d-%d ms", page->clip_from, page->clip_to);
            if (page->loop) printf(" looping");
        }
        printf("\n  \"%s\"\n", page->text);
    }
    static const char *const events[] = {"enter", "leave", "end"};
    for (int e = 0; e < EVENT_COUNT; ++e)
        if (page->triggers.on[e].count) {
            printf("  on %s\n", events[e]);
            print_actions(page->triggers.on[e], 0);
        }
    if (page->actions.count) {
        printf("  actions\n");
        print_actions(page->actions, 0);
    }
    for (int r = 0; r < page->response_count; ++r) {
        const struct StoryResponse *response = &story->responses[page->response_first + r];
        printf("  holding %s", story->icons[response->icon].id);
        print_condition_text(&response->test);
        printf(": \"%s\"\n", response->text);
    }
    collect_edges();
    printf("  leads to\n");
    for (int e = 0; e < edge_count; ++e)
        if (edges[e].from == index) print_edge_text(&edges[e]);
    for (int h = 0; h < page->hotspot_count; ++h)
        if (hotspot_at(page, h)->click.count) {
            printf("    when \"%s\" is chosen\n", hotspot_at(page, h)->label);
            print_actions(hotspot_at(page, h)->click, 0);
        }
    printf("  reached from\n");
    for (int e = 0; e < edge_count; ++e) {
        if (edges[e].to != index) continue;
        printf("    %s", page_at(edges[e].from)->id);
        if (edges[e].hotspot) {
            printf(" \"%s\"", edges[e].label);
            print_hotspot_conditions(edges[e].hotspot);
        } else printf(" %s", edges[e].kind);
        printf("\n");
    }
    if (index == story->start) printf("    the start\n");
}

/* Every action that touches a target, wherever it is: a page's trigger, a choice, a list. */
struct Touch { enum StoryActionOp ops[4]; int target; const char *what; int page; const char *where; };
static void touch_action(const struct StoryAction *action, void *context)
{
    struct Touch *touch = context;
    for (int k = 0; k < 4; ++k)
        if (touch->ops[k] && action->op == touch->ops[k] && action->target == touch->target) {
            if (touch->page >= 0) mention(touch->page, "");
            else printf("  %s", touch->where);
            static const char *const verbs[] = {
                [ACTION_SET] = "sets it", [ACTION_ADD] = "adds to it", [ACTION_ENABLE] = "enables it",
                [ACTION_DISABLE] = "disables it", [ACTION_GIVE] = "gives it", [ACTION_REMOVE] = "removes it",
                [ACTION_SHOW] = "shows it", [ACTION_HIDE] = "hides it", [ACTION_GOTO] = "goes there",
                [ACTION_CALL] = "calls it",
            };
            printf(" %s%s\n", verbs[action->op], touch->what ? touch->what : "");
        }
}

static void touches(enum StoryActionOp a, enum StoryActionOp b, enum StoryActionOp c, enum StoryActionOp d, int target)
{
    struct Touch touch = {{a, b, c, d}, target, NULL, -1, NULL};
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = page_at(i);
        touch.page = i;
        touch.what = NULL;
        for (int e = 0; e < EVENT_COUNT; ++e) walk(page->triggers.on[e], touch_action, &touch, 0);
        walk(page->actions, touch_action, &touch, 0);
        for (int h = 0; h < page->hotspot_count; ++h) {
            char what[MAX_CHOICE_LABEL + 32];
            snprintf(what, sizeof(what), " when \"%s\" is chosen", hotspot_at(page, h)->label);
            touch.what = what;
            walk(hotspot_at(page, h)->click, touch_action, &touch, 0);
        }
    }
    touch.page = -1;
    touch.what = NULL;
    for (int i = 0; i < story->location_count; ++i) {
        touch.where = story->locations[i].file;
        for (int e = 0; e < EVENT_COUNT; ++e) walk(story->locations[i].triggers.on[e], touch_action, &touch, 0);
    }
    touch.where = "books/<name>/title.xml";
    for (int i = 0; i < story->node_count; ++i)
        for (int e = 0; e < EVENT_COUNT; ++e) walk(story->nodes[i].triggers.on[e], touch_action, &touch, 0);
}

/* Pages whose conditions read a term. */
static bool condition_mentions(const struct StoryCondition *test, enum StoryTermKind kind, int value)
{
    for (int t = 0; t < test->count; ++t)
        if (story->terms[test->first + t].kind == kind && story->terms[test->first + t].value == value) return true;
    return false;
}

struct Reads { enum StoryTermKind kind; int value; int page; };
static void reads_in_action(const struct StoryAction *action, void *context)
{
    struct Reads *reads = context;
    if (action->op == ACTION_IF && condition_mentions(&action->test, reads->kind, reads->value)) {
        mention(reads->page, "");
        printf(" tests it: if %s\n", action->test.source);
    }
    if (reads->kind == TERM_VARIABLE && action->op == ACTION_SET && action->from_variable && action->value == reads->value) {
        mention(reads->page, "");
        printf(" copies it into %s\n", story->variables[action->target].id);
    }
}

static void readers(enum StoryTermKind kind, int value)
{
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = page_at(i);
        struct Reads reads = {kind, value, i};
        walk_page(page, reads_in_action, &reads);
        for (int h = 0; h < page->hotspot_count; ++h) {
            const struct StoryHotspot *hotspot = hotspot_at(page, h);
            bool held = kind == TERM_HOLDING && (hotspot->with == value || hotspot->take == value);
            if (condition_mentions(&hotspot->test, kind, value) || held) {
                mention(i, "");
                printf(" \"%s\"", hotspot->label);
                print_hotspot_conditions(hotspot);
                printf(" -> %s\n", hotspot->target >= 0 ? page_at(hotspot->target)->id : "(its actions)");
            }
        }
        for (int r = 0; r < page->response_count; ++r) {
            const struct StoryResponse *response = &story->responses[page->response_first + r];
            if (condition_mentions(&response->test, kind, value) || (kind == TERM_HOLDING && response->icon == value)) {
                mention(i, "");
                printf(" a response while holding %s: \"%s\"\n", story->icons[response->icon].id, response->text);
            }
        }
    }
}

static void query(const char *term)
{
    int page = find_page(term);
    if (page >= 0) query_page(page);
    for (int i = 0; i < story->variable_count; ++i) {
        const struct StoryVariable *variable = &story->variables[i];
        if (strcmp(variable->id, term)) continue;
        heading("variable");
        printf("  %s, starts ", type_names[variable->type]);
        if (variable->type == VARIABLE_STRING) printf("'%s'", story->strings[variable->initial]);
        else if (variable->type == VARIABLE_CHAR) printf("'%c'", variable->initial ? variable->initial : ' ');
        else if (variable->type == VARIABLE_BOOL) printf("%s", variable->initial ? "true" : "false");
        else printf("%d", variable->initial);
        if (variable->text) printf(": \"%s\"", variable->text);
        printf("\n");
        touches(ACTION_SET, ACTION_ADD, 0, 0, i);
        readers(TERM_VARIABLE, i);
    }
    for (int i = 0; i < story->icon_count; ++i) {
        const struct StoryIcon *icon = &story->icons[i];
        if (strcmp(icon->id, term)) continue;
        heading(story_icon_kind_name(icon->kind));
        printf("  %s: \"%s\"\n", icon->name, icon->text);
        if (icon->where >= 0) printf("  lies in %s at the start\n", story->locations[icon->where].id);
        if (icon->carried) printf("  carried from the start\n");
        touches(ACTION_GIVE, ACTION_REMOVE, 0, 0, i);
        readers(TERM_HAS, i);
        readers(TERM_HOLDING, i);
    }
    for (int i = 0; i < story->character_count; ++i) {
        if (strcmp(story->characters[i].id, term)) continue;
        heading("character");
        printf("  %s%s%s%s\n", story->characters[i].name, story->characters[i].text ? ": \"" : "",
               story->characters[i].text ? story->characters[i].text : "", story->characters[i].text ? "\"" : "");
        for (int p = 0; p < story->page_count; ++p)
            if (page_at(p)->character == i) mention(p, "\n");
    }
    for (int i = 0; i < story->flag_count; ++i) {
        if (strcmp(story->flags[i].id, term)) continue;
        heading("enable flag");
        printf("  starts %s\n", story->flags[i].initial ? "enabled" : "disabled");
        touches(ACTION_ENABLE, ACTION_DISABLE, 0, 0, i);
        readers(TERM_ENABLED, i);
    }
    for (int i = 0; i < story->record_count; ++i) {
        const struct StoryRecord *record = &story->records[i];
        bool named = (record->id && !strcmp(record->id, term)) || (record->number && !strcmp(record->number, term));
        if (!named) continue;
        heading(record_names[record->kind]);
        if (record->title) printf("  \"%s\"", record->title);
        if (record->from) printf(" from %s", record->from);
        if (record->camera) printf(" camera %s", record->camera);
        if (record->number) printf(" dial %s", record->number);
        if (record->target >= 0) printf(" -> %s", page_at(record->target)->id);
        print_condition_text(&record->test);
        printf("\n");
        if (record->text) printf("  \"%s\"\n", record->text);
        for (int h = 0; h < record->hotspot_count; ++h) {
            const struct StoryHotspot *item = &story->hotspots[record->hotspot_first + h];
            printf("  item \"%s\"", item->label);
            print_hotspot_conditions(item);
            printf(" -> %s\n", item->target >= 0 ? page_at(item->target)->id : "(its actions)");
        }
        if (record->kind == RECORD_INTERFACE) touches(ACTION_SHOW, ACTION_HIDE, 0, 0, i);
    }
    for (int i = 0; i < story->node_count; ++i) {
        if (strcmp(story->nodes[i].id, term)) continue;
        heading("node");
        printf("  %s\n", story->nodes[i].name ? story->nodes[i].name : story->nodes[i].id);
        for (int l = 0; l < story->location_count; ++l)
            if (story->locations[l].node == i) printf("  location %s (%s)\n", story->locations[l].id, story->locations[l].file);
    }
    for (int l = 0; l < story->location_count; ++l) {
        const struct StoryLocation *location = &story->locations[l];
        if (strcmp(location->id, term)) continue;
        heading("location");
        printf("  %s, node %s, %d pages\n", location->file, story->nodes[location->node].id, location->count);
        for (int i = 0; i < story->icon_count; ++i)
            if (story->icons[i].where == l) printf("  icon %s lies here at the start\n", story->icons[i].id);
        for (int i = location->first; i < location->first + location->count; ++i) mention(i, "\n");
    }
    for (int v = 0; v < story->viewpoint_count; ++v) {
        if (strcmp(story->viewpoints[v].id, term)) continue;
        heading("viewpoint");
        for (int i = 0; i < story->page_count; ++i)
            if (page_at(i)->viewpoint == v) {
                mention(i, "");
                printf(" facing %s\n", page_at(i)->direction ? page_at(i)->direction : "-");
            }
    }
    /* Cameras, clips and anchors are plain strings on pages. */
    static const char *const kinds[] = {"camera", "clip", "anchor"};
    for (int k = 0; k < 3; ++k) {
        bool found = false;
        for (int i = 0; i < story->page_count; ++i) {
            const struct StoryPage *page = page_at(i);
            if (!shown(page)) continue;
            if (k == 2) {
                for (int h = 0; h < page->hotspot_count; ++h) {
                    const struct StoryHotspot *hotspot = hotspot_at(page, h);
                    if (!hotspot->anchor || strcmp(hotspot->anchor, term)) continue;
                    if (!found) heading(kinds[k]);
                    found = true;
                    mention(i, "");
                    printf(" %s \"%s\"", story_hotspot_kind_name(hotspot->kind), hotspot->label);
                    print_hotspot_conditions(hotspot);
                    printf("\n");
                }
                continue;
            }
            const char *value = k == 0 ? page->camera : page->clip;
            if (!value || strcmp(value, term)) continue;
            if (!found) {
                filePath_t path;
                heading(kinds[k]);
                if (k == 0) printf("  %s %s\n", asset_names[still(term, path)], path);
                else printf("  %s %s\n", asset_names[clip(term, path)], path);
            }
            found = true;
            mention(i, "\n");
        }
    }
    if (!mentions) fail("%s names nothing called \"%s\"", story->name, term);
}

/* --- play -------------------------------------------------------------------------- */

static void print_page(void)
{
    const struct BookPage *page = book_page();
    int index = find_page(page->id);
    /* The map's own pages (its home, lists, records and keypad) have no story page. */
    const struct StoryPage *source = index >= 0 ? page_at(index) : NULL;
    printf("[%s] %s", source ? role(source) : "map", page->id);
    if (page->ending != ENDING_NONE) printf(" (%s)", book_ending_kind_name(page->ending));
    if (source) printf("  in %s,", story->locations[source->location].id);
    printf("  camera %s", page->camera);
    if (source && source->clip) printf(", clip %s", source->clip);
    if (page->held) printf(", holding %s", book_object(page->held)->key);
    printf("\n  \"%s\"\n", *page->text || !source ? page->text : source->text);
    for (int i = 0; i < page->choice_count; ++i) {
        const struct Choice *choice = &page->choices[i];
        printf("  %d %-8s \"%s\"", i, book_choice_kind_name(choice->kind), choice->label);
        if (*choice->command) printf(" -> %s", choice->command);
        printf("\n");
    }
    if (page->kind == PAGE_BEAT && !page->read) printf("  (a shot: continue when the clip ends)\n");
}

static bool step(const char *word)
{
    if (!strcmp(word, "continue")) return book_continue();
    if (!strcmp(word, "retry")) {
        for (int i = 0; i < book_page()->choice_count; ++i)
            if (book_page()->choices[i].kind == CHOICE_RETRY) return book_action(i);
        return false;
    }
    if (!strncmp(word, "hold:", 5)) return book_command(word + 5);
    char *end;
    long index = strtol(word, &end, 10);
    if (end != word && !*end) return book_action((int)index);
    return book_command(word);
}

static void play(int count, char **steps)
{
    book_init(root, name);
    print_page();
    for (int i = 0; i < count; ++i) {
        command_t words;
        copy(words, sizeof(words), steps[i]);
        for (char *word = strtok(words, ", "); word; word = strtok(NULL, ", ")) {
            printf("\n> %s\n", word);
            if (!step(word)) {
                fflush(stdout);
                fail("cannot %s on page %s", word, book_page()->id);
            }
            print_page();
        }
    }
}

/* --- assets ------------------------------------------------------------------------ */

static void print_pages_json(const char *value, int field)
{
    bool first = true;
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = page_at(i);
        const char *other = field ? page->clip : page->camera;
        if (!shown(page) || !other || strcmp(other, value)) continue;
        printf("%s{\"id\":", first ? "" : ",");
        json_string(page->id);
        printf(",\"role\":"); json_string(role(page));
        printf(",\"location\":"); json_string(story->locations[page->location].id);
        if (page->character >= 0) {
            printf(",\"character\":");
            json_string(story->characters[page->character].name);
        }
        printf(",\"text\":"); json_string(page->text);
        printf("}");
        first = false;
    }
}

static void print_pages_text(const char *value, int field)
{
    for (int i = 0; i < story->page_count; ++i) {
        const struct StoryPage *page = page_at(i);
        const char *other = field ? page->clip : page->camera;
        if (shown(page) && other && !strcmp(other, value)) printf("    %s [%s] \"%s\"\n", page->id, role(page), page->text);
    }
}

static void print_asset(bool *first, const char *kind, const char *asset, enum Asset status, const char *path,
                        const char *subject, const char *text)
{
    if (json) {
        printf("%s{\"kind\":\"%s\",\"name\":", *first ? "" : ",", kind);
        json_string(asset);
        printf(",\"status\":\"%s\",\"path\":", asset_names[status]);
        json_string(path);
        printf(",\"subject\":"); json_string(subject);
        printf(",\"text\":"); json_string(text);
        printf("}");
        *first = false;
    } else printf("  %-8s %s  \"%s\"\n", asset_names[status], asset, text);
}

static void assets(void)
{
    int counts[2][ASSET_MISSING + 1] = {{0}};
    if (json) printf("{\"book\":\"%s\",\"assets\":[", story->name);
    bool first = true;
    for (int field = 0; field < 2; ++field) {
        if (!json) printf("%s%s\n", field ? "\n" : "", field ? "clips (books/<name>/clips/<clip>.mp4)" :
                          "stills (illustrations/<camera>.png, else rooms/<camera>.jpg)");
        for (int i = 0; i < story->page_count; ++i) {
            const struct StoryPage *page = page_at(i);
            const char *value = field ? page->clip : page->camera;
            if (!shown(page) || !value || repeated(0, i, !field)) continue;
            filePath_t path;
            enum Asset status = field ? clip(value, path) : still(value, path);
            ++counts[field][status];
            if (missing_only && status != ASSET_MISSING) continue;
            if (json) {
                printf("%s{\"kind\":\"%s\",\"name\":", first ? "" : ",", field ? "clip" : "still");
                json_string(value);
                printf(",\"status\":\"%s\",\"path\":", asset_names[status]);
                json_string(path);
                printf(",\"pages\":[");
                print_pages_json(value, field);
                printf("]}");
                first = false;
            } else {
                printf("  %-8s %s\n", asset_names[status], value);
                print_pages_text(value, field);
            }
        }
    }
    if (!json) printf("\nicons (camera item-<icon>)\n");
    for (int i = 0; i < story->icon_count; ++i) {
        assetName_t camera;
        snprintf(camera, sizeof(camera), ITEM_ICON_PREFIX "%s", story->icons[i].id);
        filePath_t path;
        enum Asset status = still(camera, path);
        if (!missing_only || status == ASSET_MISSING)
            print_asset(&first, "icon", camera, status, path, story->icons[i].id, story->icons[i].text);
    }
    bool photos = false;
    for (int i = 0; i < story->record_count; ++i) {
        const struct StoryRecord *record = &story->records[i];
        if (record->kind != RECORD_PHOTO) continue;
        if (!json && !photos) printf("\nphotos (camera of each <photo>)\n");
        photos = true;
        filePath_t path;
        enum Asset status = still(record->camera, path);
        if (!missing_only || status == ASSET_MISSING)
            print_asset(&first, "photo", record->camera, status, path, record->id, record->text);
    }
    if (json) {
        printf("]}\n");
        return;
    }
    printf("\nstills: %d painted, %d rendered, %d placeholders, %d missing; "
           "clips: %d present, %d placeholders, %d missing\n",
           counts[0][ASSET_PAINTING], counts[0][ASSET_RENDER], counts[0][ASSET_PLACEHOLDER], counts[0][ASSET_MISSING],
           counts[1][ASSET_PRESENT], counts[1][ASSET_PLACEHOLDER], counts[1][ASSET_MISSING]);
}

int main(int argc, char **argv)
{
    const char *command = NULL;
    char **rest = argv; /* the words after the book, gathered in place */
    int rest_count = 0;
    for (int i = 1; i < argc; ++i) {
        if (!strcmp(argv[i], "--root") && i + 1 < argc) root = argv[++i];
        else if (!strcmp(argv[i], "--json")) json = true;
        else if (!strcmp(argv[i], "--dot")) dot = true;
        else if (!strcmp(argv[i], "--missing")) missing_only = true;
        else if (!strcmp(argv[i], "--help") || !strcmp(argv[i], "-h")) {
            fputs(USAGE, stdout);
            return 0;
        }
        else if (argv[i][0] == '-' && argv[i][1] == '-') fail("unknown option %s\n%s", argv[i], USAGE);
        else if (!command) command = argv[i];
        else if (!name) name = argv[i];
        else rest[rest_count++] = argv[i];
    }
    if (!command || !name) {
        fputs(USAGE, stderr);
        return 2;
    }
    story = story_load(root, name);
    if (!strcmp(command, "check") && !rest_count) check();
    else if (!strcmp(command, "stats") && !rest_count) stats();
    else if (!strcmp(command, "graph") && !rest_count) graph();
    else if (!strcmp(command, "query") && rest_count == 1) query(rest[0]);
    else if (!strcmp(command, "play")) play(rest_count, rest);
    else if (!strcmp(command, "assets") && !rest_count) assets();
    else {
        fputs(USAGE, stderr);
        return 2;
    }
    return 0;
}
