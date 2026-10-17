#define _XOPEN_SOURCE 700
#include "book.h"

#include <ctype.h>
#include <dirent.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

/* Read a book's XML into the story tables of src/book.h. books/<name>/title.xml declares
 * the variables, characters, icons, records and nodes; each node lists its locations, and
 * books/<name>/locations/<location>.xml holds that location's pages. Names are checked
 * here, with file and line; references to pages and enable flags are resolved once every
 * file is read, so order never matters. src/story.c then validates the story itself. */

#define TITLE_FILE "title.xml"
#define LOCATIONS_DIR "locations"
#define LOCATION_SUFFIX ".xml"
#define MAX_KEPT_STRINGS (MAX_STORY_PAGES * 8 + MAX_STORY_HOTSPOTS * 4 + MAX_STORY_ACTIONS + \
                          MAX_STORY_TERMS / 4 + MAX_STORY_VARIABLES * 2 + MAX_STORY_ICONS * 3 + \
                          MAX_STORY_RECORDS * 6)
#define MAX_PENDING (MAX_STORY_ACTIONS + MAX_STORY_HOTSPOTS + MAX_STORY_TERMS / 4)
#define MAX_LIST_ACTIONS 256
#define MAX_LIST_HOTSPOTS (MAX_PAGE_CHOICES * 4)
#define MAX_CONDITION_TERMS 512
#define MAX_EXPRESSION_DEPTH 64
#define MAX_STORY_MESSAGE 1024

static struct Story story;
static struct StoryPage pages[MAX_STORY_PAGES];
static struct StoryHotspot hotspots[MAX_STORY_HOTSPOTS];
static struct StoryResponse responses[MAX_STORY_RESPONSES];
static struct StoryAction actions[MAX_STORY_ACTIONS];
static struct StoryTerm terms[MAX_STORY_TERMS];
static struct StoryVariable variables[MAX_STORY_VARIABLES];
static const char *strings[MAX_STORY_STRINGS];
static struct StoryIcon icons[MAX_STORY_ICONS];
static struct StoryCharacter characters[MAX_STORY_CHARACTERS];
static struct StoryNode nodes[MAX_STORY_NODES];
static struct StoryLocation locations[MAX_STORY_LOCATIONS];
static struct StoryViewpoint viewpoints[MAX_STORY_VIEWPOINTS];
static struct StoryRecord records[MAX_STORY_RECORDS];
static struct StoryFlag flags[MAX_STORY_FLAGS];
static int lines[MAX_STORY_PAGES];
static char *kept[MAX_KEPT_STRINGS];
static int kept_count;
static filePath_t source; /* the file being read, relative to the root, for errors */

/* A page or flag named before it is read; resolved when every file is in. */
enum Reference { REFERENCE_PAGE, REFERENCE_FLAG };
struct Pending { int *slot; const char *name, *file, *what; int line; enum Reference kind; };
static struct Pending pending[MAX_PENDING];
static int pending_count;

static _Noreturn void error(xmlNode *node, const char *format, ...)
{
    char message[MAX_STORY_MESSAGE];
    va_list args;
    va_start(args, format);
    vsnprintf(message, sizeof(message), format, args);
    va_end(args);
    fail("%s:%ld: %s", source, node ? xmlGetLineNo(node) : 0L, message);
}

static const char *keep(const char *text)
{
    if (kept_count >= MAX_KEPT_STRINGS) fail("%s: the story has too many strings", source);
    char *duplicate = strdup(text);
    if (!duplicate) fail("out of memory");
    return kept[kept_count++] = duplicate;
}

static void *zeroed(size_t size)
{
    void *memory = calloc(1, size);
    if (!memory) fail("out of memory");
    return memory;
}

static bool element(xmlNode *node, const char *name)
{
    return node->type == XML_ELEMENT_NODE && !xmlStrcmp(node->name, (const xmlChar *)name);
}

static const char *tag(xmlNode *node) { return (const char *)node->name; }

/* Unknown attributes are mistakes: a misspelt "if" must not silently vanish. */
static void allow(xmlNode *node, const char *const names[])
{
    for (xmlAttr *attribute = node->properties; attribute; attribute = attribute->next) {
        bool known = false;
        for (int i = 0; names[i]; ++i) known |= !strcmp((const char *)attribute->name, names[i]);
        if (!known) error(node, "<%s> has no attribute %s", tag(node), attribute->name);
    }
}
#define ALLOW(node, ...) allow(node, (const char *const[]){__VA_ARGS__, NULL})
#define ALLOW_NONE(node) allow(node, (const char *const[]){NULL})

/* Lowercase words joined by hyphens: the names of everything a book declares. */
static void check_identifier(xmlNode *node, const char *field, const char *value)
{
    bool valid = *value && *value != '-' && value[strlen(value) - 1] != '-' && !strstr(value, "--");
    for (const char *p = value; *p; ++p)
        valid &= (*p >= 'a' && *p <= 'z') || (*p >= '0' && *p <= '9') || *p == '-';
    if (!valid) error(node, "%s \"%s\" must be lowercase words joined by hyphens", field, value);
}

static bool has(xmlNode *node, const char *name) { return xmlHasProp(node, (const xmlChar *)name) != NULL; }

static const char *attribute(xmlNode *node, const char *name, bool required)
{
    xmlChar *value = xmlGetProp(node, (const xmlChar *)name);
    if (!value) {
        if (required) error(node, "<%s> needs %s", tag(node), name);
        return NULL;
    }
    if (!*value) error(node, "<%s> has an empty %s", tag(node), name);
    const char *result = keep((const char *)value);
    xmlFree(value);
    return result;
}

static const char *identifier(xmlNode *node, const char *name, bool required)
{
    const char *value = attribute(node, name, required);
    if (value) check_identifier(node, name, value);
    return value;
}

static bool boolean(xmlNode *node, const char *name, bool fallback)
{
    xmlChar *value = xmlGetProp(node, (const xmlChar *)name);
    if (!value) return fallback;
    bool on = !xmlStrcmp(value, (const xmlChar *)"true");
    if (!on && xmlStrcmp(value, (const xmlChar *)"false")) error(node, "%s must be true or false", name);
    xmlFree(value);
    return on;
}

static int integer(xmlNode *node, const char *name, const char *text)
{
    char *end;
    long value = strtol(text, &end, 10);
    if (end == text || *end || value < INT_MIN || value > INT_MAX) error(node, "%s must be a whole number", name);
    return (int)value;
}

static int milliseconds(xmlNode *node, const char *name)
{
    const char *value = attribute(node, name, false);
    if (!value) return 0;
    int ms = integer(node, name, value);
    if (ms < 0) error(node, "%s cannot be negative", name);
    return ms;
}

static bool named_in(xmlNode *node, const char *const names[])
{
    for (int i = 0; names && names[i]; ++i)
        if (element(node, names[i])) return true;
    return false;
}

/* An element's prose: its text, with each run of white space folded to one space. A blank
 * line between words begins a new paragraph (a newline in the page text), and <region/>
 * begins the camera's next reading region (a form feed). Elements named in skip belong to
 * the caller; any other element is an error. */
static const char *prose_skipping(xmlNode *node, const char *const skip[])
{
    storyText_t text;
    size_t length = 0;
    bool space = false;
    int breaks = 0; /* line breaks in the white space before the next word */
    for (xmlNode *child = node->children; child; child = child->next) {
        if (child->type == XML_COMMENT_NODE) continue;
        if (element(child, "region") && !child->properties && !child->children) {
            if (length + 2 >= sizeof(text)) error(node, "<%s> prose is too long", tag(node));
            text[length++] = '\f';
            space = false;
            breaks = 0;
            continue;
        }
        if (child->type == XML_ELEMENT_NODE) {
            if (!named_in(child, skip)) error(child, "<%s> cannot hold <%s>", tag(node), tag(child));
            continue;
        }
        if (child->type != XML_TEXT_NODE && child->type != XML_CDATA_SECTION_NODE)
            error(child, "<%s> holds only prose", tag(node));
        for (const char *p = (const char *)child->content; *p; ++p) {
            if (strchr(" \t\r\n", *p)) {
                space = length > 0 && text[length - 1] != '\f';
                breaks += *p == '\n';
                continue;
            }
            if (length + 2 >= sizeof(text)) error(node, "<%s> prose is too long", tag(node));
            if (space) text[length++] = breaks >= 2 ? '\n' : ' ';
            text[length++] = *p;
            space = false;
            breaks = 0;
        }
    }
    text[length] = 0;
    return length ? keep(text) : NULL;
}

static const char *prose(xmlNode *node) { return prose_skipping(node, NULL); }

/* Element children only: comments are skipped, and stray prose between elements is an error. */
static xmlNode *next_element(xmlNode *node)
{
    for (; node; node = node->next) {
        if (node->type == XML_ELEMENT_NODE) return node;
        if (node->type == XML_COMMENT_NODE) continue;
        if (node->type != XML_TEXT_NODE || node->content[strspn((const char *)node->content, " \t\r\n")])
            error(node, "unexpected text; prose belongs inside a page or <text>");
    }
    return NULL;
}
#define each_element(child, parent) \
    for (xmlNode *child = next_element((parent)->children); child; child = next_element(child->next))

/* Elements beside prose: for pages whose words sit next to their triggers. */
#define each_child_element(child, parent) \
    for (xmlNode *child = (parent)->children; child; child = child->next) \
        if (child->type == XML_ELEMENT_NODE && !element(child, "region"))

static void refer(int *slot, const char *name, enum Reference kind, xmlNode *node, const char *what)
{
    if (pending_count >= MAX_PENDING) error(node, "too many references");
    *slot = -1;
    pending[pending_count++] = (struct Pending){slot, name, keep(source), what, (int)xmlGetLineNo(node), kind};
}

/* Buffers fill before they are committed to the tables, so every range stays contiguous;
 * references filed against a buffer follow it. */
static void move_references(int *from, int *to, int since)
{
    for (int p = since; p < pending_count; ++p)
        if (pending[p].slot == from) pending[p].slot = to;
}

/* --- Declarations ------------------------------------------------------------- */

static int find_variable(const char *id)
{
    for (int i = 0; i < story.variable_count; ++i)
        if (!strcmp(variables[i].id, id)) return i;
    return -1;
}

static int find_icon(const char *id)
{
    for (int i = 0; i < story.icon_count; ++i)
        if (!strcmp(icons[i].id, id)) return i;
    return -1;
}

static int find_location(const char *id)
{
    for (int i = 0; i < story.location_count; ++i)
        if (!strcmp(locations[i].id, id)) return i;
    return -1;
}

static int find_record(const char *id, enum StoryRecordKind kind)
{
    for (int i = 0; i < story.record_count; ++i)
        if (records[i].kind == kind && records[i].id && !strcmp(records[i].id, id)) return i;
    return -1;
}

static int variable_named(xmlNode *node, const char *id)
{
    int index = find_variable(id);
    if (index < 0) error(node, "no variable is named \"%s\"", id);
    return index;
}

static int icon_named(xmlNode *node, const char *id)
{
    int index = find_icon(id);
    if (index < 0) error(node, "no icon is named \"%s\"", id);
    return index;
}

static int icon_attribute(xmlNode *node, const char *name)
{
    const char *id = attribute(node, name, false);
    return id ? icon_named(node, id) : -1;
}

static int intern(const char *text)
{
    for (int i = 0; i < story.string_count; ++i)
        if (!strcmp(strings[i], text)) return i;
    if (story.string_count >= MAX_STORY_STRINGS) fail("%s: too many string values", source);
    strings[story.string_count] = keep(text);
    return story.string_count++;
}

/* A literal for a variable of the given type: true/false, a number, a character or text. */
static int literal(xmlNode *node, const char *text, enum StoryVariableType type)
{
    switch (type) {
    case VARIABLE_BOOL:
        if (!strcmp(text, "true")) return 1;
        if (!strcmp(text, "false")) return 0;
        error(node, "a boolean is true or false, not \"%s\"", text);
    case VARIABLE_INT: return integer(node, "value", text);
    case VARIABLE_CHAR:
        if (strlen(text) != 1) error(node, "a character value is one character, not \"%s\"", text);
        return (unsigned char)text[0];
    case VARIABLE_STRING: return intern(text);
    }
    error(node, "invalid variable type");
}

static int new_flag(xmlNode *node, const char *id, bool initial)
{
    for (int i = 0; i < story.flag_count; ++i)
        if (!strcmp(flags[i].id, id)) error(node, "\"%s\" already names something that can be enabled", id);
    if (story.flag_count >= MAX_STORY_FLAGS) error(node, "more than %d enable flags", MAX_STORY_FLAGS);
    flags[story.flag_count] = (struct StoryFlag){id, initial};
    return story.flag_count++;
}

/* --- Conditions ------------------------------------------------------------------ */

/* Conditions are small expressions: "seen and not left", "goons >= 2", "mood == 't'",
 * "has(ledger)", "holding(badge)", "enabled(cook-office)", "visited(alley)". */
struct Lexer {
    xmlNode *node;
    const char *text, *p;
    struct StoryTerm out[MAX_CONDITION_TERMS];
    const char *names[MAX_CONDITION_TERMS]; /* pages and flags, resolved later */
    int count;
};

static void lex_space(struct Lexer *lex) { while (isspace((unsigned char)*lex->p)) ++lex->p; }

static bool lex_word(struct Lexer *lex, const char *word)
{
    lex_space(lex);
    size_t n = strlen(word);
    if (strncmp(lex->p, word, n) || isalnum((unsigned char)lex->p[n]) || lex->p[n] == '-') return false;
    lex->p += n;
    return true;
}

static bool lex_symbol(struct Lexer *lex, const char *symbol)
{
    lex_space(lex);
    size_t n = strlen(symbol);
    if (strncmp(lex->p, symbol, n)) return false;
    lex->p += n;
    return true;
}

static void emit(struct Lexer *lex, enum StoryTermKind kind, int value, const char *name)
{
    if (lex->count >= MAX_CONDITION_TERMS) error(lex->node, "condition \"%s\" is too long", lex->text);
    lex->names[lex->count] = name;
    lex->out[lex->count++] = (struct StoryTerm){kind, value};
}

static void lex_name(struct Lexer *lex, identifier_t name)
{
    lex_space(lex);
    size_t n = 0;
    while (islower((unsigned char)lex->p[n]) || isdigit((unsigned char)lex->p[n]) || lex->p[n] == '-') ++n;
    if (!n || n >= sizeof(identifier_t)) error(lex->node, "condition \"%s\": expected a name at \"%s\"", lex->text, lex->p);
    memcpy(name, lex->p, n);
    name[n] = 0;
    lex->p += n;
}

static void parse_or(struct Lexer *lex, int depth);

static void parse_primary(struct Lexer *lex, int depth)
{
    if (depth > MAX_EXPRESSION_DEPTH) error(lex->node, "condition \"%s\" nests too deeply", lex->text);
    lex_space(lex);
    if (lex_symbol(lex, "(")) {
        parse_or(lex, depth + 1);
        if (!lex_symbol(lex, ")")) error(lex->node, "condition \"%s\" misses a )", lex->text);
        return;
    }
    if (*lex->p == '\'') {
        /* 'c' is a character; 'longer text' is a string. */
        const char *end = strchr(lex->p + 1, '\'');
        if (!end) error(lex->node, "condition \"%s\" has an unclosed quote", lex->text);
        size_t n = (size_t)(end - lex->p - 1);
        storyText_t text;
        if (n >= sizeof(text)) error(lex->node, "condition text is too long");
        memcpy(text, lex->p + 1, n);
        text[n] = 0;
        lex->p = end + 1;
        if (n == 1) emit(lex, TERM_NUMBER, (unsigned char)text[0], NULL);
        else emit(lex, TERM_STRING, intern(text), NULL);
        return;
    }
    if (isdigit((unsigned char)*lex->p) || (*lex->p == '-' && isdigit((unsigned char)lex->p[1]))) {
        char *end;
        long value = strtol(lex->p, &end, 10);
        lex->p = end;
        emit(lex, TERM_NUMBER, (int)value, NULL);
        return;
    }
    if (lex_word(lex, "true")) { emit(lex, TERM_NUMBER, 1, NULL); return; }
    if (lex_word(lex, "false")) { emit(lex, TERM_NUMBER, 0, NULL); return; }
    static const struct { const char *name; enum StoryTermKind kind; } functions[] = {
        {"has", TERM_HAS}, {"holding", TERM_HOLDING}, {"enabled", TERM_ENABLED}, {"visited", TERM_VISITED},
    };
    for (size_t f = 0; f < sizeof(functions) / sizeof(functions[0]); ++f) {
        const char *at = lex->p;
        if (!lex_word(lex, functions[f].name)) continue;
        if (!lex_symbol(lex, "(")) {
            lex->p = at;
            break;
        }
        identifier_t name;
        lex_name(lex, name);
        if (!lex_symbol(lex, ")")) error(lex->node, "condition \"%s\" misses a )", lex->text);
        if (functions[f].kind == TERM_HAS || functions[f].kind == TERM_HOLDING)
            emit(lex, functions[f].kind, icon_named(lex->node, name), NULL);
        else emit(lex, functions[f].kind, -1, keep(name));
        return;
    }
    identifier_t name;
    lex_name(lex, name);
    emit(lex, TERM_VARIABLE, variable_named(lex->node, name), NULL);
}

static void parse_comparison(struct Lexer *lex, int depth)
{
    parse_primary(lex, depth);
    static const struct { const char *symbol; enum StoryTermKind kind; } operators[] = {
        {"==", TERM_EQ}, {"!=", TERM_NE}, {"<=", TERM_LE}, {">=", TERM_GE}, {"<", TERM_LT}, {">", TERM_GT},
    };
    for (size_t i = 0; i < sizeof(operators) / sizeof(operators[0]); ++i)
        if (lex_symbol(lex, operators[i].symbol)) {
            parse_primary(lex, depth);
            emit(lex, operators[i].kind, 0, NULL);
            return;
        }
}

static void parse_not(struct Lexer *lex, int depth)
{
    if (lex_word(lex, "not")) {
        parse_not(lex, depth + 1);
        emit(lex, TERM_NOT, 0, NULL);
    } else parse_comparison(lex, depth);
}

static void parse_and(struct Lexer *lex, int depth)
{
    parse_not(lex, depth);
    while (lex_word(lex, "and")) {
        parse_not(lex, depth);
        emit(lex, TERM_AND, 0, NULL);
    }
}

static void parse_or(struct Lexer *lex, int depth)
{
    parse_and(lex, depth);
    while (lex_word(lex, "or")) {
        parse_and(lex, depth);
        emit(lex, TERM_OR, 0, NULL);
    }
}

static struct StoryCondition condition(xmlNode *node, const char *name)
{
    const char *text = attribute(node, name, false);
    if (!text) return (struct StoryCondition){0, 0, NULL};
    struct Lexer *lex = zeroed(sizeof(*lex));
    *lex = (struct Lexer){.node = node, .text = text, .p = text};
    parse_or(lex, 0);
    lex_space(lex);
    if (*lex->p) error(node, "condition \"%s\": unexpected \"%s\"", text, lex->p);
    if (story.term_count + lex->count > MAX_STORY_TERMS) error(node, "conditions are too long");
    struct StoryCondition result = {story.term_count, lex->count, text};
    for (int i = 0; i < lex->count; ++i) {
        terms[story.term_count] = lex->out[i];
        if (lex->names[i])
            refer(&terms[story.term_count].value, lex->names[i],
                  lex->out[i].kind == TERM_VISITED ? REFERENCE_PAGE : REFERENCE_FLAG, node, "a condition");
        ++story.term_count;
    }
    free(lex);
    return result;
}

/* --- Actions --------------------------------------------------------------------- */

struct ActionList { struct StoryAction items[MAX_LIST_ACTIONS]; int count, mark; };

static struct StoryAction *add_action(struct ActionList *list, xmlNode *node, enum StoryActionOp op)
{
    if (list->count >= MAX_LIST_ACTIONS) error(node, "more than %d actions in one list", MAX_LIST_ACTIONS);
    struct StoryAction *action = &list->items[list->count++];
    *action = (struct StoryAction){.op = op, .target = -1};
    return action;
}

static struct StoryActions commit_actions(struct ActionList *list, xmlNode *node)
{
    if (story.action_count + list->count > MAX_STORY_ACTIONS) error(node, "more than %d actions", MAX_STORY_ACTIONS);
    struct StoryActions range = {story.action_count, list->count};
    for (int i = 0; i < list->count; ++i) {
        actions[story.action_count] = list->items[i];
        move_references(&list->items[i].target, &actions[story.action_count].target, list->mark);
        ++story.action_count;
    }
    return range;
}

static void action_element(struct ActionList *list, xmlNode *child);

static struct StoryActions action_block(xmlNode *parent)
{
    struct ActionList *list = zeroed(sizeof(*list));
    list->mark = pending_count;
    each_element(child, parent) action_element(list, child);
    struct StoryActions range = commit_actions(list, parent);
    free(list);
    return range;
}

static void action_element(struct ActionList *list, xmlNode *child)
{
    if (element(child, "set")) {
        ALLOW(child, "var", "value", "from", "add");
        int variable = variable_named(child, attribute(child, "var", true));
        const char *value = attribute(child, "value", false), *from = attribute(child, "from", false);
        const char *add = attribute(child, "add", false);
        if (!!value + !!from + !!add > 1) error(child, "<set> takes one of value, from and add");
        struct StoryAction *action = add_action(list, child, add ? ACTION_ADD : ACTION_SET);
        action->target = variable;
        if (add) {
            if (variables[variable].type != VARIABLE_INT && variables[variable].type != VARIABLE_CHAR)
                error(child, "only a number can be added to");
            action->value = integer(child, "add", add);
        } else if (from) {
            action->value = variable_named(child, from);
            action->from_variable = true;
            if (variables[action->value].type != variables[variable].type) error(child, "<set> from a variable of another type");
        } else if (value) action->value = literal(child, value, variables[variable].type);
        else if (variables[variable].type == VARIABLE_BOOL) action->value = 1;
        else error(child, "<set> of a %s needs a value", variables[variable].type == VARIABLE_STRING ? "string" : "number");
    } else if (element(child, "enable") || element(child, "disable")) {
        ALLOW(child, "target");
        struct StoryAction *action = add_action(list, child, element(child, "enable") ? ACTION_ENABLE : ACTION_DISABLE);
        refer(&action->target, identifier(child, "target", true), REFERENCE_FLAG, child, tag(child));
    } else if (element(child, "give") || element(child, "remove")) {
        ALLOW(child, "icon");
        struct StoryAction *action = add_action(list, child, element(child, "give") ? ACTION_GIVE : ACTION_REMOVE);
        action->target = icon_named(child, attribute(child, "icon", true));
    } else if (element(child, "goto")) {
        ALLOW(child, "target");
        struct StoryAction *action = add_action(list, child, ACTION_GOTO);
        refer(&action->target, identifier(child, "target", true), REFERENCE_PAGE, child, "<goto>");
    } else if (element(child, "call")) {
        ALLOW(child, "list");
        struct StoryAction *action = add_action(list, child, ACTION_CALL);
        refer(&action->target, identifier(child, "list", true), REFERENCE_PAGE, child, "<call>");
    } else if (element(child, "show") || element(child, "hide")) {
        ALLOW(child, "interface");
        struct StoryAction *action = add_action(list, child, element(child, "show") ? ACTION_SHOW : ACTION_HIDE);
        const char *id = attribute(child, "interface", true);
        action->target = find_record(id, RECORD_INTERFACE);
        if (action->target < 0) error(child, "no interface is named \"%s\"", id);
    } else if (element(child, "script")) {
        ALLOW(child, "name", "args");
        struct StoryAction *action = add_action(list, child, ACTION_SCRIPT);
        action->name = attribute(child, "name", true);
        action->args = attribute(child, "args", false);
    } else if (element(child, "if")) {
        ALLOW(child, "test");
        struct StoryCondition test = condition(child, "test");
        if (!test.count) error(child, "<if> needs a test");
        struct StoryActions then = action_block(child);
        if (!then.count) error(child, "<if> is empty");
        struct StoryAction *action = add_action(list, child, ACTION_IF);
        action->test = test;
        action->then = then;
    } else if (element(child, "else")) {
        ALLOW_NONE(child);
        if (!list->count || list->items[list->count - 1].op != ACTION_IF || list->items[list->count - 1].otherwise.count)
            error(child, "<else> follows an <if>");
        list->items[list->count - 1].otherwise = action_block(child);
        if (!list->items[list->count - 1].otherwise.count) error(child, "<else> is empty");
    } else error(child, "<%s> is not an action: set, enable, disable, give, remove, goto, call, if, else, "
                        "show, hide or script", tag(child));
}

/* --- Pages ----------------------------------------------------------------------- */

static int new_page(xmlNode *node, enum StoryPageKind kind, int location)
{
    if (story.page_count >= MAX_STORY_PAGES) error(node, "more than %d pages", MAX_STORY_PAGES);
    int index = story.page_count++;
    lines[index] = (int)xmlGetLineNo(node);
    pages[index] = (struct StoryPage){
        .kind = kind, .location = location, .viewpoint = -1, .character = -1, .parent = -1,
        .next = -1, .retry = -1,
    };
    return index;
}

/* The picture and clip every shown page has. */
static void picture(xmlNode *node, struct StoryPage *page, bool camera_required)
{
    page->camera = attribute(node, "camera", camera_required);
    page->clip = attribute(node, "clip", false);
    page->clip_from = milliseconds(node, "from");
    page->clip_to = milliseconds(node, "to");
    if ((page->clip_from || page->clip_to) && !page->clip) error(node, "from and to slice a clip");
    if (page->clip_to && page->clip_to <= page->clip_from) error(node, "a clip slice must end after it starts");
}

/* sets, gives and removes: the enter actions every book writes most. */
static void shorthand(xmlNode *node, struct ActionList *enter)
{
    static const char *const names[] = {"sets", "gives", "removes"};
    for (int k = 0; k < 3; ++k) {
        xmlChar *value = xmlGetProp(node, (const xmlChar *)names[k]);
        if (!value) continue;
        identifier_t word;
        for (const char *p = (const char *)value; *p;) {
            p += strspn(p, " \t\r\n");
            size_t length = strcspn(p, " \t\r\n");
            if (!length) break;
            if (length >= sizeof(word)) error(node, "%s holds an overlong name", names[k]);
            memcpy(word, p, length);
            word[length] = 0;
            p += length;
            struct StoryAction *action = add_action(enter, node, k == 0 ? ACTION_SET : k == 1 ? ACTION_GIVE : ACTION_REMOVE);
            if (k == 0) {
                action->target = variable_named(node, word);
                if (variables[action->target].type != VARIABLE_BOOL) error(node, "sets names booleans, not \"%s\"", word);
                action->value = 1;
            } else action->target = icon_named(node, word);
        }
        xmlFree(value);
    }
}

/* <trigger event="enter|leave|end"> blocks, after a page's shorthand enter actions. */
static void read_triggers(xmlNode *node, struct StoryTriggers *triggers, bool sugar, bool end_allowed)
{
    static const char *const events[] = {"enter", "leave", "end"};
    struct ActionList *lists[EVENT_COUNT];
    for (int e = 0; e < EVENT_COUNT; ++e) {
        lists[e] = zeroed(sizeof(struct ActionList));
        lists[e]->mark = pending_count;
    }
    if (sugar) shorthand(node, lists[EVENT_ENTER]);
    each_child_element(child, node) {
        if (!element(child, "trigger")) continue;
        ALLOW(child, "event");
        const char *event = attribute(child, "event", true);
        int e = 0;
        while (e < EVENT_COUNT && strcmp(events[e], event)) ++e;
        if (e == EVENT_COUNT) error(child, "a trigger's event is enter, leave or end, not \"%s\"", event);
        if (e == EVENT_END && !end_allowed) error(child, "only an asset or a conversation ends");
        each_element(action, child) action_element(lists[e], action);
    }
    for (int e = 0; e < EVENT_COUNT; ++e) {
        triggers->on[e] = commit_actions(lists[e], node);
        free(lists[e]);
    }
}

static void read_responses(xmlNode *node, struct StoryPage *page)
{
    page->response_first = story.response_count;
    each_child_element(child, node) {
        if (!element(child, "holding")) continue;
        ALLOW(child, "icon", "if");
        if (story.response_count >= MAX_STORY_RESPONSES) error(child, "more than %d responses", MAX_STORY_RESPONSES);
        struct StoryResponse *response = &responses[story.response_count++];
        *response = (struct StoryResponse){icon_named(child, attribute(child, "icon", true)), condition(child, "if"), prose(child)};
        if (!response->text) error(child, "<holding> needs prose");
    }
    page->response_count = story.response_count - page->response_first;
}

static const char *page_text(xmlNode *node, const char *name)
{
    const char *text = NULL;
    each_child_element(child, node) {
        if (!element(child, "text")) continue;
        ALLOW_NONE(child);
        if (text) error(child, "%s has two <text>", name);
        text = prose(child);
        if (!text) error(child, "<text> is empty");
    }
    return text;
}

struct HotspotList { struct StoryHotspot items[MAX_LIST_HOTSPOTS]; int count, mark; };

static struct StoryHotspot *add_hotspot(struct HotspotList *list, xmlNode *node, enum StoryHotspotKind kind)
{
    if (list->count >= MAX_LIST_HOTSPOTS) error(node, "too many choices on one page");
    struct StoryHotspot *hotspot = &list->items[list->count++];
    *hotspot = (struct StoryHotspot){.kind = kind, .target = -1, .with = -1, .take = -1, .flag = -1};
    return hotspot;
}

static void commit_hotspots(struct HotspotList *list, xmlNode *node, int *first, int *count)
{
    if (story.hotspot_count + list->count > MAX_STORY_HOTSPOTS) error(node, "more than %d choices", MAX_STORY_HOTSPOTS);
    *first = story.hotspot_count;
    *count = list->count;
    for (int i = 0; i < list->count; ++i) {
        hotspots[story.hotspot_count] = list->items[i];
        move_references(&list->items[i].target, &hotspots[story.hotspot_count].target, list->mark);
        ++story.hotspot_count;
    }
}

/* The attributes every circle and line shares, and the actions it runs when chosen. */
static void hotspot_common(xmlNode *node, struct StoryHotspot *hotspot)
{
    hotspot->label = attribute(node, "label", true);
    hotspot->test = condition(node, "if");
    hotspot->with = icon_attribute(node, "with");
    const char *target = identifier(node, "target", false);
    if (target) refer(&hotspot->target, target, REFERENCE_PAGE, node, "target");
    if (hotspot->id) hotspot->flag = new_flag(node, hotspot->id, boolean(node, "enabled", true));
    else if (has(node, "enabled")) error(node, "only something with an id can start disabled");
    hotspot->click = action_block(node);
    if (!target && !hotspot->click.count) error(node, "<%s> \"%s\" needs a target or actions", tag(node), hotspot->label);
}

static void read_place_hotspot(xmlNode *child, struct HotspotList *list, enum StoryHotspotKind kind)
{
    if (kind == HOTSPOT_NAV) ALLOW(child, "id", "label", "anchor", "edge", "target", "if", "with", "enabled");
    else if (kind == HOTSPOT_EXPLORABLE) ALLOW(child, "id", "label", "anchor", "target", "if", "with", "take", "enabled");
    else ALLOW(child, "id", "label", "anchor", "target", "if", "enabled");
    struct StoryHotspot *hotspot = add_hotspot(list, child, kind);
    hotspot->id = identifier(child, "id", false);
    hotspot->anchor = attribute(child, "anchor", false);
    const char *edge = attribute(child, "edge", false);
    if (edge) {
        if (!strcmp(edge, "left")) hotspot->edge = EDGE_LEFT;
        else if (!strcmp(edge, "right")) hotspot->edge = EDGE_RIGHT;
        else if (!strcmp(edge, "back")) hotspot->edge = EDGE_BACK;
        else error(child, "a nav's edge is left, right or back");
        if (hotspot->anchor) error(child, "a nav sits on an anchor or an edge, not both");
    }
    if (!hotspot->anchor && !hotspot->edge)
        error(child, "<%s> needs an anchor%s", tag(child), kind == HOTSPOT_NAV ? " or an edge" : "");
    hotspot->take = icon_attribute(child, "take");
    hotspot_common(child, hotspot);
}

static void read_conversation(xmlNode *child, int charview, struct HotspotList *list)
{
    struct StoryHotspot *hotspot = add_hotspot(list, child, HOTSPOT_CONVERSATION);
    static const char *const skip[] = {
        "trigger", "set", "enable", "disable", "give", "remove", "goto", "call", "if", "else", "show", "hide", "script", NULL
    };
    const char *text = prose_skipping(child, skip);
    if (!text && !has(child, "clip")) {
        /* A line that leads somewhere, or runs actions: no reply of its own. */
        ALLOW(child, "id", "label", "target", "if", "with", "ends", "enabled");
        hotspot->id = identifier(child, "id", false);
        hotspot->ends = boolean(child, "ends", false);
        each_element(inner, child)
            if (element(inner, "trigger")) error(inner, "a line without a reply has no triggers; put its actions inside it");
        hotspot_common(child, hotspot);
        return;
    }
    /* A line with a reply: the reply is a page, shown when the line is chosen. */
    ALLOW(child, "id", "label", "if", "with", "ends", "enabled", "camera", "clip", "from", "to", "next",
          "sets", "gives", "removes");
    each_child_element(inner, child)
        if (!element(inner, "trigger")) error(inner, "a reply's actions go in a <trigger>");
    hotspot->id = identifier(child, "id", true);
    hotspot->ends = boolean(child, "ends", false);
    int index = new_page(child, STORY_CONVERSATION, pages[charview].location);
    struct StoryPage *page = &pages[index];
    page->id = hotspot->id;
    page->parent = charview;
    picture(child, page, false);
    if (!page->camera) page->camera = pages[charview].camera;
    page->text = text;
    if (!text) error(child, "conversation %s needs prose for its reply", page->id);
    const char *next = identifier(child, "next", false);
    if (next) refer(&page->next, next, REFERENCE_PAGE, child, "next");
    read_triggers(child, &page->triggers, true, true);
    hotspot->label = attribute(child, "label", true);
    hotspot->test = condition(child, "if");
    hotspot->with = icon_attribute(child, "with");
    hotspot->target = index;
    hotspot->flag = new_flag(child, hotspot->id, boolean(child, "enabled", true));
}

static void read_charview(xmlNode *node, int location, int view, struct HotspotList *view_hotspots)
{
    ALLOW(node, "id", "character", "camera", "clip", "from", "to", "loop", "sound", "sets", "gives", "removes",
          "label", "anchor", "if", "with", "enabled", "target");
    int index = new_page(node, STORY_CHARVIEW, location);
    struct StoryPage *page = &pages[index];
    page->id = identifier(node, "id", true);
    page->parent = view;
    const char *character = identifier(node, "character", true);
    for (int i = 0; i < story.character_count; ++i)
        if (!strcmp(characters[i].id, character)) page->character = i;
    if (page->character < 0) error(node, "no character is named \"%s\"", character);
    picture(node, page, true);
    page->loop = boolean(node, "loop", false);
    page->sound = attribute(node, "sound", false);
    page->text = page_text(node, page->id);
    if (!page->text) error(node, "charview %s needs <text>", page->id);
    read_triggers(node, &page->triggers, true, false);
    read_responses(node, page);
    struct HotspotList *list = zeroed(sizeof(*list));
    list->mark = pending_count;
    each_child_element(child, node) {
        if (element(child, "conversation")) read_conversation(child, index, list);
        else if (!element(child, "text") && !element(child, "trigger") && !element(child, "holding"))
            error(child, "a charview holds <text>, <trigger>, <holding> and <conversation>, not <%s>", tag(child));
    }
    commit_hotspots(list, node, &pages[index].hotspot_first, &pages[index].hotspot_count);
    free(list);
    if (view < 0) {
        if (has(node, "anchor") || has(node, "label") || has(node, "if") || has(node, "with") || has(node, "enabled") ||
            has(node, "target"))
            error(node, "a charview outside a view is no circle; give it no anchor, label, if, with, enabled or target");
        return;
    }
    /* Inside a view, the charview is also that view's circle on the character. */
    struct StoryHotspot *hotspot = add_hotspot(view_hotspots, node, HOTSPOT_CHARVIEW);
    hotspot->id = pages[index].id;
    hotspot->anchor = attribute(node, "anchor", true);
    hotspot->label = attribute(node, "label", true);
    hotspot->test = condition(node, "if");
    hotspot->with = icon_attribute(node, "with");
    hotspot->flag = new_flag(node, hotspot->id, boolean(node, "enabled", true));
    const char *target = identifier(node, "target", false);
    if (target) refer(&hotspot->target, target, REFERENCE_PAGE, node, "target");
    else hotspot->target = index;
}

static void read_view(xmlNode *node, int location, int viewpoint, bool map)
{
    if (map) ALLOW(node, "id", "camera", "clip", "from", "to", "loop", "sound", "sets", "gives", "removes");
    else ALLOW(node, "id", "camera", "direction", "clip", "from", "to", "loop", "sound", "sets", "gives", "removes");
    int index = new_page(node, map ? STORY_MAP : STORY_VIEW, location);
    struct StoryPage *page = &pages[index];
    page->id = identifier(node, "id", true);
    page->viewpoint = viewpoint;
    page->direction = attribute(node, "direction", false);
    picture(node, page, true);
    page->loop = boolean(node, "loop", false);
    if (page->loop && !page->clip) error(node, "only a clip loops");
    page->sound = attribute(node, "sound", false);
    page->text = page_text(node, page->id);
    if (!page->text) error(node, "%s %s needs <text>", tag(node), page->id);
    read_triggers(node, &page->triggers, true, false);
    read_responses(node, page);
    struct HotspotList *list = zeroed(sizeof(*list));
    list->mark = pending_count;
    each_child_element(child, node) {
        if (element(child, "text") || element(child, "trigger") || element(child, "holding")) continue;
        if (map) {
            if (!element(child, "destination"))
                error(child, "a map holds <text>, <trigger>, <holding> and <destination>, not <%s>", tag(child));
            read_place_hotspot(child, list, HOTSPOT_DESTINATION);
        } else if (element(child, "nav")) read_place_hotspot(child, list, HOTSPOT_NAV);
        else if (element(child, "explorable")) read_place_hotspot(child, list, HOTSPOT_EXPLORABLE);
        else if (element(child, "charview")) read_charview(child, location, index, list);
        else error(child, "a view holds <text>, <trigger>, <holding>, <nav>, <explorable> and <charview>, not <%s>", tag(child));
    }
    commit_hotspots(list, node, &pages[index].hotspot_first, &pages[index].hotspot_count);
    free(list);
}

static void read_asset(xmlNode *node, int location, bool ending)
{
    if (ending) ALLOW(node, "id", "kind", "camera", "clip", "from", "to", "retry", "sets", "gives", "removes");
    else ALLOW(node, "id", "camera", "clip", "from", "to", "read", "next", "sets", "gives", "removes");
    int index = new_page(node, ending ? STORY_ENDING : STORY_ASSET, location);
    struct StoryPage *page = &pages[index];
    page->id = identifier(node, "id", true);
    picture(node, page, true);
    page->text = prose_skipping(node, (const char *const[]){"trigger", NULL});
    if (!page->text) error(node, "%s %s needs prose", tag(node), page->id);
    read_triggers(node, &page->triggers, true, !ending);
    if (ending) {
        const char *kind = attribute(node, "kind", true);
        if (!strcmp(kind, "success")) page->ending = ENDING_SUCCESS;
        else if (!strcmp(kind, "partial")) page->ending = ENDING_PARTIAL;
        else if (!strcmp(kind, "failure")) page->ending = ENDING_FAILURE;
        else error(node, "ending kind must be success, partial or failure");
        const char *retry = identifier(node, "retry", false);
        if (retry) refer(&page->retry, retry, REFERENCE_PAGE, node, "retry");
        return;
    }
    page->read = boolean(node, "read", false);
    const char *next = identifier(node, "next", false);
    if (next) refer(&page->next, next, REFERENCE_PAGE, node, "next");
    else if (!page->triggers.on[EVENT_END].count) error(node, "asset %s needs next, or an end trigger", page->id);
}

static void read_actionlist(xmlNode *node, int location)
{
    ALLOW(node, "id");
    int index = new_page(node, STORY_ACTIONLIST, location);
    pages[index].id = identifier(node, "id", true);
    pages[index].actions = action_block(node);
    if (!pages[index].actions.count) error(node, "action list %s is empty", pages[index].id);
}

static xmlDoc *open_file(const char *root, const char *relative, const char *root_tag)
{
    copy(source, sizeof(source), relative);
    filePath_t path;
    int length = snprintf(path, sizeof(path), "%s/%s", root, relative);
    if (length < 0 || (size_t)length >= sizeof(path)) fail("%s: path is too long", relative);
    xmlDoc *doc = xmlReadFile(path, NULL, XML_PARSE_NONET | XML_PARSE_BIG_LINES);
    if (!doc) fail("cannot read %s", relative);
    xmlNode *top = xmlDocGetRootElement(doc);
    if (!top || !element(top, root_tag)) error(top, "the root element must be <%s>", root_tag);
    return doc;
}

static void read_location(const char *root, int index)
{
    struct StoryLocation *location = &locations[index];
    xmlDoc *doc = open_file(root, location->file, "location");
    xmlNode *top = xmlDocGetRootElement(doc);
    ALLOW(top, "id", "name", "sound");
    const char *id = identifier(top, "id", true);
    if (strcmp(id, location->id)) error(top, "this file is location %s, so its id is \"%s\"", location->id, location->id);
    location->name = attribute(top, "name", false);
    location->sound = attribute(top, "sound", false);
    location->text = page_text(top, location->id);
    location->first = story.page_count;
    read_triggers(top, &location->triggers, false, false);
    each_element(child, top) {
        if (element(child, "text") || element(child, "trigger")) continue;
        if (element(child, "viewpoint")) {
            ALLOW(child, "id");
            if (story.viewpoint_count >= MAX_STORY_VIEWPOINTS) error(child, "more than %d viewpoints", MAX_STORY_VIEWPOINTS);
            int viewpoint = story.viewpoint_count++;
            viewpoints[viewpoint] = (struct StoryViewpoint){identifier(child, "id", true), index};
            for (int i = 0; i < viewpoint; ++i)
                if (!strcmp(viewpoints[i].id, viewpoints[viewpoint].id)) error(child, "viewpoint %s is declared twice", viewpoints[i].id);
            int views = 0;
            each_element(view, child) {
                if (!element(view, "view")) error(view, "a viewpoint holds <view>s, not <%s>", tag(view));
                read_view(view, index, viewpoint, false);
                ++views;
            }
            if (!views) error(child, "viewpoint %s has no views", viewpoints[viewpoint].id);
        } else if (element(child, "view")) read_view(child, index, -1, false);
        else if (element(child, "map")) read_view(child, index, -1, true);
        else if (element(child, "charview")) read_charview(child, index, -1, NULL);
        else if (element(child, "asset")) read_asset(child, index, false);
        else if (element(child, "ending")) read_asset(child, index, true);
        else if (element(child, "actionlist")) read_actionlist(child, index);
        else error(child, "a location holds <text>, <trigger>, <viewpoint>, <view>, <map>, <charview>, <asset>, "
                          "<ending> and <actionlist>, not <%s>", tag(child));
    }
    location->count = story.page_count - location->first;
    if (!location->count) error(top, "location %s has no pages", location->id);
    xmlFreeDoc(doc);
}

/* --- The title ------------------------------------------------------------------- */

static void read_icon(xmlNode *child, enum StoryIconKind kind, const char **where)
{
    ALLOW(child, "id", "name", "where", "carried");
    if (story.icon_count >= MAX_STORY_ICONS) error(child, "more than %d icons", MAX_STORY_ICONS);
    struct StoryIcon *icon = &icons[story.icon_count];
    *icon = (struct StoryIcon){
        .id = identifier(child, "id", true), .name = attribute(child, "name", true), .text = prose(child),
        .kind = kind, .where = -1, .carried = boolean(child, "carried", false),
    };
    if (!icon->text) error(child, "icon %s needs prose", icon->id);
    if (find_icon(icon->id) >= 0) error(child, "icon %s is declared twice", icon->id);
    where[story.icon_count++] = identifier(child, "where", false);
}

static struct StoryRecord *new_record(xmlNode *node, enum StoryRecordKind kind)
{
    if (story.record_count >= MAX_STORY_RECORDS) error(node, "more than %d records", MAX_STORY_RECORDS);
    struct StoryRecord *record = &records[story.record_count++];
    *record = (struct StoryRecord){.kind = kind, .target = -1, .flag = -1};
    return record;
}

static const char *const declaration_tags[] = {
    "variable", "character", "inventory", "evidence", "idea", "emotion", "action-icon", NULL
};

/* Declarations first, so conditions anywhere may name them. */
static void read_declarations(xmlNode *top, const char *name)
{
    static const char *where[MAX_STORY_ICONS];
    each_element(child, top) {
        if (element(child, "variable")) {
            ALLOW(child, "id", "type", "initial");
            if (story.variable_count >= MAX_STORY_VARIABLES) error(child, "more than %d variables", MAX_STORY_VARIABLES);
            struct StoryVariable *variable = &variables[story.variable_count];
            variable->id = identifier(child, "id", true);
            if (find_variable(variable->id) >= 0) error(child, "variable %s is declared twice", variable->id);
            const char *type = attribute(child, "type", false);
            if (!type || !strcmp(type, "bool")) variable->type = VARIABLE_BOOL;
            else if (!strcmp(type, "int")) variable->type = VARIABLE_INT;
            else if (!strcmp(type, "char")) variable->type = VARIABLE_CHAR;
            else if (!strcmp(type, "string")) variable->type = VARIABLE_STRING;
            else error(child, "a variable's type is bool, int, char or string");
            const char *initial = attribute(child, "initial", false);
            variable->initial = initial ? literal(child, initial, variable->type) :
                                variable->type == VARIABLE_STRING ? intern("") : 0;
            variable->text = prose(child);
            ++story.variable_count;
        } else if (element(child, "character")) {
            ALLOW(child, "id", "name");
            if (story.character_count >= MAX_STORY_CHARACTERS) error(child, "more than %d characters", MAX_STORY_CHARACTERS);
            struct StoryCharacter *character = &characters[story.character_count];
            *character = (struct StoryCharacter){identifier(child, "id", true), attribute(child, "name", true), prose(child)};
            for (int i = 0; i < story.character_count; ++i)
                if (!strcmp(characters[i].id, character->id)) error(child, "character %s is declared twice", character->id);
            ++story.character_count;
        } else if (element(child, "inventory")) read_icon(child, ICON_INVENTORY, where);
        else if (element(child, "evidence")) read_icon(child, ICON_EVIDENCE, where);
        else if (element(child, "idea")) read_icon(child, ICON_IDEA, where);
        else if (element(child, "emotion")) read_icon(child, ICON_EMOTION, where);
        else if (element(child, "action-icon")) read_icon(child, ICON_ACTION, where);
        else if (element(child, "node")) {
            ALLOW(child, "id", "name");
            if (story.node_count >= MAX_STORY_NODES) error(child, "more than %d nodes", MAX_STORY_NODES);
            int node = story.node_count++;
            nodes[node] = (struct StoryNode){.id = identifier(child, "id", true), .name = attribute(child, "name", false)};
            for (int i = 0; i < node; ++i)
                if (!strcmp(nodes[i].id, nodes[node].id)) error(child, "node %s is declared twice", nodes[i].id);
            int listed = 0;
            each_element(item, child) {
                if (element(item, "trigger") || element(item, "text")) continue;
                if (!element(item, "location")) error(item, "a node holds <text>, <trigger> and <location>, not <%s>", tag(item));
                ALLOW(item, "id");
                if (story.location_count >= MAX_STORY_LOCATIONS) error(item, "more than %d locations", MAX_STORY_LOCATIONS);
                struct StoryLocation *location = &locations[story.location_count];
                *location = (struct StoryLocation){.id = identifier(item, "id", true), .node = node};
                if (find_location(location->id) >= 0) error(item, "location %s is listed twice", location->id);
                filePath_t file;
                int length = snprintf(file, sizeof(file), "books/%s/" LOCATIONS_DIR "/%s" LOCATION_SUFFIX, name, location->id);
                if (length < 0 || (size_t)length >= sizeof(file)) error(item, "location path is too long");
                location->file = keep(file);
                ++story.location_count;
                ++listed;
            }
            if (!listed) error(child, "node %s lists no <location>", nodes[node].id);
        } else if (element(child, "interface")) {
            ALLOW(child, "id", "title");
            struct StoryRecord *record = new_record(child, RECORD_INTERFACE);
            record->id = identifier(child, "id", true);
            record->title = attribute(child, "title", false);
            if (find_record(record->id, RECORD_INTERFACE) != story.record_count - 1)
                error(child, "interface %s is declared twice", record->id);
        }
    }
    for (int i = 0; i < story.icon_count; ++i)
        if (where[i]) {
            icons[i].where = find_location(where[i]);
            if (icons[i].where < 0) fail("%s: icon %s lies in unknown location \"%s\"", source, icons[i].id, where[i]);
            if (icons[i].carried) fail("%s: icon %s cannot both lie somewhere and be carried", source, icons[i].id);
        }
    if (!story.location_count) error(top, "the title lists no <node> with a <location>");
}

static void read_title(xmlNode *top, const char *name)
{
    ALLOW(top, "name", "start", "fmv", "continue", "retry", "restart");
    story.name = identifier(top, "name", true);
    if (strcmp(story.name, name)) error(top, "this is book %s, so its name is \"%s\"", name, name);
    refer(&story.start, identifier(top, "start", true), REFERENCE_PAGE, top, "start");
    story.fmv = boolean(top, "fmv", false);
    story.continue_label = attribute(top, "continue", false);
    story.retry_label = attribute(top, "retry", false);
    story.restart_label = attribute(top, "restart", false);
    if (!story.continue_label) story.continue_label = "Continue";
    if (!story.retry_label) story.retry_label = "Try again";
    if (!story.restart_label) story.restart_label = "Start over";
    read_declarations(top, name);
    /* Then everything that refers: node triggers, records, interface items. */
    int node = 0, interface = 0;
    each_element(child, top) {
        if (element(child, "node")) {
            read_triggers(child, &nodes[node].triggers, false, false);
            nodes[node].text = page_text(child, nodes[node].id);
            ++node;
        } else if (element(child, "note") || element(child, "email") || element(child, "photo")) {
            enum StoryRecordKind kind = element(child, "note") ? RECORD_NOTE : element(child, "email") ? RECORD_EMAIL : RECORD_PHOTO;
            if (kind == RECORD_NOTE) ALLOW(child, "id", "title", "enabled");
            else if (kind == RECORD_EMAIL) ALLOW(child, "id", "from", "title", "enabled");
            else ALLOW(child, "id", "camera", "title", "enabled");
            struct StoryRecord *record = new_record(child, kind);
            record->id = identifier(child, "id", true);
            record->title = attribute(child, "title", kind != RECORD_PHOTO);
            record->from = attribute(child, "from", kind == RECORD_EMAIL);
            record->camera = attribute(child, "camera", kind == RECORD_PHOTO);
            record->text = prose(child);
            if (!record->text) error(child, "<%s> needs prose", tag(child));
            record->flag = new_flag(child, record->id, boolean(child, "enabled", false));
        } else if (element(child, "phone")) {
            ALLOW(child, "id", "number", "target", "if", "enabled");
            struct StoryRecord *record = new_record(child, RECORD_PHONE);
            record->id = identifier(child, "id", false);
            record->number = attribute(child, "number", true);
            record->test = condition(child, "if");
            refer(&record->target, identifier(child, "target", true), REFERENCE_PAGE, child, "target");
            if (record->id) record->flag = new_flag(child, record->id, boolean(child, "enabled", true));
            else if (has(child, "enabled")) error(child, "only something with an id can start disabled");
            if (prose(child)) error(child, "<phone> holds no prose");
        } else if (element(child, "interface")) {
            int index = -1;
            for (int i = 0, seen = 0; i < story.record_count && index < 0; ++i)
                if (records[i].kind == RECORD_INTERFACE && seen++ == interface) index = i;
            ++interface;
            struct HotspotList *list = zeroed(sizeof(*list));
            list->mark = pending_count;
            each_element(item, child) {
                if (!element(item, "item")) error(item, "an interface holds <item>s, not <%s>", tag(item));
                ALLOW(item, "id", "label", "target", "if", "enabled");
                struct StoryHotspot *hotspot = add_hotspot(list, item, HOTSPOT_ITEM);
                hotspot->id = identifier(item, "id", false);
                hotspot_common(item, hotspot);
            }
            commit_hotspots(list, child, &records[index].hotspot_first, &records[index].hotspot_count);
            free(list);
        } else if (!named_in(child, declaration_tags))
            error(child, "a title holds <variable>, <character>, <inventory>, <evidence>, <idea>, <emotion>, "
                         "<action-icon>, <note>, <email>, <photo>, <phone>, <interface> and <node>, not <%s>", tag(child));
    }
}

/* Every location file is listed, so a page cannot be left out of the book by accident. */
static void check_listed(const char *root, const char *name)
{
    filePath_t directory;
    int length = snprintf(directory, sizeof(directory), "%s/books/%s/" LOCATIONS_DIR, root, name);
    if (length < 0 || (size_t)length >= sizeof(directory)) fail("locations path is too long");
    DIR *dir = opendir(directory);
    if (!dir) fail("books/%s/" LOCATIONS_DIR " is missing", name);
    for (struct dirent *entry; (entry = readdir(dir));) {
        size_t n = strlen(entry->d_name), suffix = strlen(LOCATION_SUFFIX);
        if (n <= suffix || strcmp(entry->d_name + n - suffix, LOCATION_SUFFIX)) continue;
        bool listed = false;
        for (int i = 0; i < story.location_count; ++i)
            listed |= strlen(locations[i].id) == n - suffix && !strncmp(locations[i].id, entry->d_name, n - suffix);
        if (!listed) fail("books/%s/" LOCATIONS_DIR "/%s is not listed in a <node> in " TITLE_FILE, name, entry->d_name);
    }
    closedir(dir);
}

static int page_named(const char *id)
{
    for (int i = 0; id && i < story.page_count; ++i)
        if (!strcmp(pages[i].id, id)) return i;
    return -1;
}

static const char *page_file(int page)
{
    for (int i = 0; i < story.location_count; ++i)
        if (page >= locations[i].first && page < locations[i].first + locations[i].count) return locations[i].file;
    return TITLE_FILE;
}

static void resolve(void)
{
    for (int i = 0; i < story.page_count; ++i) {
        int first = page_named(pages[i].id);
        if (first != i)
            fail("%s:%d: page %s is also at %s:%d", page_file(i), lines[i], pages[i].id, page_file(first), lines[first]);
    }
    for (int p = 0; p < pending_count; ++p) {
        const struct Pending *ref = &pending[p];
        int index = -1;
        if (ref->kind == REFERENCE_PAGE) index = page_named(ref->name);
        else
            for (int i = 0; i < story.flag_count && index < 0; ++i)
                if (!strcmp(flags[i].id, ref->name)) index = i;
        if (index < 0)
            fail("%s:%d: %s names no %s \"%s\"", ref->file, ref->line, ref->what,
                 ref->kind == REFERENCE_PAGE ? "page" : "enable flag", ref->name);
        *ref->slot = index;
    }
}

const struct Story *story_load(const char *root, const char *name)
{
    story_unload();
    filePath_t relative;
    int length = snprintf(relative, sizeof(relative), "books/%s/" TITLE_FILE, name);
    if (length < 0 || (size_t)length >= sizeof(relative)) fail("book name is too long");
    xmlDoc *doc = open_file(root, relative, "title");
    read_title(xmlDocGetRootElement(doc), name);
    xmlFreeDoc(doc);
    check_listed(root, name);
    for (int i = 0; i < story.location_count; ++i) read_location(root, i);
    resolve();
    story.pages = pages;
    story.hotspots = hotspots;
    story.responses = responses;
    story.actions = actions;
    story.terms = terms;
    story.variables = variables;
    story.strings = strings;
    story.icons = icons;
    story.characters = characters;
    story.nodes = nodes;
    story.locations = locations;
    story.viewpoints = viewpoints;
    story.records = records;
    story.flags = flags;
    return &story;
}

void story_unload(void)
{
    for (int i = 0; i < kept_count; ++i) free(kept[i]);
    kept_count = pending_count = 0;
    memset(&story, 0, sizeof(story));
    memset(lines, 0, sizeof(lines));
}

int story_line(int page)
{
    return story.pages && page >= 0 && page < story.page_count ? lines[page] : 0;
}

const char *story_icon_kind_name(enum StoryIconKind kind)
{
    switch (kind) {
    case ICON_INVENTORY: return "inventory";
    case ICON_EVIDENCE: return "evidence";
    case ICON_IDEA: return "idea";
    case ICON_EMOTION: return "emotion";
    case ICON_ACTION: return "action-icon";
    }
    return "invalid";
}

const char *story_page_kind_name(enum StoryPageKind kind)
{
    switch (kind) {
    case STORY_VIEW: return "view";
    case STORY_CHARVIEW: return "charview";
    case STORY_ASSET: return "asset";
    case STORY_CONVERSATION: return "conversation";
    case STORY_ENDING: return "ending";
    case STORY_MAP: return "map";
    case STORY_ACTIONLIST: return "actionlist";
    case STORY_INVALID: break;
    }
    return "invalid";
}

const char *story_hotspot_kind_name(enum StoryHotspotKind kind)
{
    switch (kind) {
    case HOTSPOT_NAV: return "nav";
    case HOTSPOT_EXPLORABLE: return "explorable";
    case HOTSPOT_CHARVIEW: return "charview";
    case HOTSPOT_CONVERSATION: return "conversation";
    case HOTSPOT_DESTINATION: return "destination";
    case HOTSPOT_ITEM: return "item";
    case HOTSPOT_INVALID: break;
    }
    return "invalid";
}
