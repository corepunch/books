#define _XOPEN_SOURCE 700
#include "book.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

enum {
    ROOM_FLOOR = 1,
    ROOM_TABLE,
    ROOM_SILL,
    OBJECT_BRASS_STAR,
    OBJECT_CHAIR,
    OBJECT_COPPER_STAR,
    OBJECT_SILL_LEDGE,
    OBJECT_PEARL_STAR
};

#define FOUND_BRASS_STAR (1u << 0)
#define FOUND_COPPER_STAR (1u << 1)
#define FOUND_PEARL_STAR (1u << 2)
#define FOUND_ALL_STARS (FOUND_BRASS_STAR | FOUND_COPPER_STAR | FOUND_PEARL_STAR)

static struct {
    unsigned int facts; /* Story facts that later pages check; there is no inventory. */
    int room;
    filePath_t root, rooms, illustrations;
    struct Object objects[MAX_OBJECTS];
} game;

/* Build into private scratch storage; consumers only see validated, complete pages.
 * Keep these large snapshots off the iPad main-thread stack. */
static struct BookPage current, draft;

static void set_object(int id, const char *key, const char *name, const char *description)
{
    struct Object *object = &game.objects[id];
    copy(object->key, sizeof(object->key), key);
    copy(object->noun, sizeof(object->noun), name);
    copy(object->desc, sizeof(object->desc), description);
}

static const char *room_name(int room)
{
    switch (room) {
    case ROOM_FLOOR: return "Чердак · пол";
    case ROOM_TABLE: return "Чердак · письменный стол";
    case ROOM_SILL: return "Чердак · подоконник";
    default: return "";
    }
}

static const char *room_text(int room)
{
    switch (room) {
    case ROOM_FLOOR:
        return (game.facts & FOUND_BRASS_STAR)
            ? "Латунная звёздочка уже у Миры. Над корзинкой ждёт бумажное созвездие, а у стола стоит бабушкин стул."
            : "Сквозняк сорвал три звёздочки с бумажного созвездия над корзинкой Миры. Одна лежит на полу, а до стола можно допрыгнуть через стул.";
    case ROOM_TABLE:
        return (game.facts & FOUND_COPPER_STAR)
            ? "Мира уже забрала медную звёздочку. Среди писем остался карандаш, а прямо над столом — подоконник."
            : "Среди бабушкиных писем поблёскивает медная звёздочка. Вниз ведёт стул, а над столом — подоконник.";
    case ROOM_SILL:
        return (game.facts & FOUND_PEARL_STAR)
            ? "На подоконнике больше нет звёздочки. Внизу письменный стол, а за окном лежит тихая ночь."
            : "На подоконнике, у цветочного горшка, светится последняя звёздочка. За окном тихая ночь.";
    default: return "";
    }
}

static void select_image(struct BookPage *page, const char *camera, const char *illustration)
{
    page->image[0] = 0;
    copy(page->camera, sizeof(page->camera), camera);
    filePath_t path;
    int length = snprintf(path, sizeof(path), "%s/%s.png", game.illustrations, illustration);
    if (length < 0 || (size_t)length >= sizeof(path)) fail("illustration path is too long");
    if (!access(path, R_OK)) {
        copy(page->image, sizeof(page->image), path);
        return;
    }
    length = snprintf(path, sizeof(path), "%s/%s.jpg", game.rooms, illustration);
    if (length < 0 || (size_t)length >= sizeof(path)) fail("reference image path is too long");
    if (!access(path, R_OK)) copy(page->image, sizeof(page->image), path);
}

static struct Choice object_choice(int object, const char *label, const char *command)
{
    struct Choice choice = {.kind = CHOICE_OBJECT, .object = object};
    copy(choice.label, sizeof(choice.label), label);
    copy(choice.command, sizeof(choice.command), command);
    return choice;
}

static struct Choice continue_choice(void)
{
    struct Choice choice = {.kind = CHOICE_CONTINUE};
    copy(choice.label, sizeof(choice.label), "Дальше");
    return choice;
}

static void append_choice(struct Choice choice)
{
    if (draft.choice_count >= MAX_CHOICES) fail("too many adventure choices");
    draft.choices[draft.choice_count++] = choice;
}

static void begin_page(enum PageKind kind, const char *text, const char *camera, const char *illustration)
{
    memset(&draft, 0, sizeof(draft));
    draft.kind = kind;
    draft.room = game.room;
    copy(draft.text, sizeof(draft.text), text);
    select_image(&draft, camera, illustration);
}

static void publish_page(void)
{
    if (draft.room <= 0 || draft.room >= MAX_OBJECTS || !*game.objects[draft.room].key)
        fail("page has no valid room");
    if (!*draft.text || !*draft.camera) fail("page must have prose and a camera");
    if (draft.choice_count < 0 || draft.choice_count > MAX_CHOICES) fail("invalid choice count");
    switch (draft.kind) {
    case PAGE_ROOM:
        if (!draft.choice_count) fail("room page has no actions");
        break;
    case PAGE_BEAT:
        if (draft.choice_count != 1) fail("intermediate page must have exactly one Continue choice");
        break;
    case PAGE_ENDED:
        if (draft.choice_count) fail("ending page must not have choices");
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
        case CHOICE_INVALID:
        default: fail("invalid kind for choice %d", i);
        }
    }
    current = draft;
}

static void add_room_choices(void)
{
    switch (game.room) {
    case ROOM_FLOOR:
        if (!(game.facts & FOUND_BRASS_STAR))
            append_choice(object_choice(OBJECT_BRASS_STAR, "Поднять латунную звёздочку?", "take brass-star"));
        append_choice(object_choice(OBJECT_CHAIR, "Запрыгнуть на стол через стул?", "go table"));
        break;
    case ROOM_TABLE:
        if (!(game.facts & FOUND_COPPER_STAR))
            append_choice(object_choice(OBJECT_COPPER_STAR, "Поднять медную звёздочку?", "take copper-star"));
        append_choice(object_choice(OBJECT_CHAIR, "Спрыгнуть на пол через стул?", "go floor"));
        append_choice(object_choice(OBJECT_SILL_LEDGE, "Запрыгнуть на подоконник?", "go sill"));
        break;
    case ROOM_SILL:
        if (!(game.facts & FOUND_PEARL_STAR))
            append_choice(object_choice(OBJECT_PEARL_STAR, "Поднять светлую звёздочку?", "take pearl-star"));
        append_choice(object_choice(OBJECT_SILL_LEDGE, "Спрыгнуть на стол?", "go table"));
        break;
    default: fail("unknown room %d", game.room);
    }
}

static void show_room(void)
{
    const char *camera;
    if (game.room == ROOM_FLOOR)
        camera = (game.facts & FOUND_BRASS_STAR) ? "floor-show-cleared-room" : "floor-show-room";
    else if (game.room == ROOM_TABLE)
        camera = (game.facts & FOUND_COPPER_STAR) ? "table-show-cleared-desk" : "table-show-desk";
    else
        camera = (game.facts & FOUND_PEARL_STAR) ? "sill-show-cleared-window" : "sill-show-window";
    /* Every page is one whole picture: the painting for its camera, else the camera's render. */
    begin_page(PAGE_ROOM, room_text(game.room), camera, camera);
    add_room_choices();
    publish_page();
}

/* Story actions call this constructor; they never need to remember navigation. */
static void show_beat(const char *text, const char *camera)
{
    begin_page(PAGE_BEAT, text, camera, camera);
    append_choice(continue_choice());
    publish_page();
}

static void finish_story(void)
{
    begin_page(PAGE_ENDED,
        "Мира приносит все три звёздочки в свою корзинку, прямо под бумажное созвездие. Утром бабушка вернёт их на ниточки, а пока они светятся рядом с Мирой.",
        "attic-return-stars", "attic-return-stars");
    publish_page();
}

static bool perform(int object)
{
    if (current.kind != PAGE_ROOM) return false;
    const char *text, *camera;
    switch (object) {
    case OBJECT_BRASS_STAR:
        if (game.room != ROOM_FLOOR || game.facts & FOUND_BRASS_STAR) return false;
        game.facts |= FOUND_BRASS_STAR;
        text = "Мира осторожно трогает лапкой латунную звёздочку и берёт её в зубки.";
        camera = "floor-take-gold-star";
        break;
    case OBJECT_COPPER_STAR:
        if (game.room != ROOM_TABLE || game.facts & FOUND_COPPER_STAR) return false;
        game.facts |= FOUND_COPPER_STAR;
        text = "Мира находит медную звёздочку между письмами и бережно берёт её.";
        camera = "table-take-copper-star";
        break;
    case OBJECT_PEARL_STAR:
        if (game.room != ROOM_SILL || game.facts & FOUND_PEARL_STAR) return false;
        game.facts |= FOUND_PEARL_STAR;
        text = "Мира достаёт последнюю звёздочку у самого окна.";
        camera = "sill-take-pearl-star";
        break;
    case OBJECT_CHAIR:
        if (game.room == ROOM_FLOOR) {
            game.room = ROOM_TABLE;
            text = "Мира прыгает на сиденье стула, а оттуда — лапками на край стола.";
            camera = "floor-climb-table";
        } else if (game.room == ROOM_TABLE) {
            game.room = ROOM_FLOOR;
            text = "Мира смотрит вниз, прыгает на стул, а потом на пол.";
            camera = "table-go-floor";
        } else return false;
        break;
    case OBJECT_SILL_LEDGE:
        if (game.room == ROOM_TABLE) {
            game.room = ROOM_SILL;
            text = "Мира тянется вверх и запрыгивает на подоконник.";
            camera = "table-climb-sill";
        } else if (game.room == ROOM_SILL) {
            game.room = ROOM_TABLE;
            text = "Мира мягко спрыгивает с подоконника на стол.";
            camera = "sill-go-table";
        } else return false;
        break;
    default: return false;
    }

    show_beat(text, camera);
    return true;
}

const char *book_name(void)
{
    return "three-stars";
}

void book_init(const char *root)
{
    memset(&current, 0, sizeof(current));
    memset(&draft, 0, sizeof(draft));
    memset(&game, 0, sizeof(game));
    if (!realpath(root, game.root)) fail("cannot resolve asset root: %s", root);
    int length = snprintf(game.rooms, sizeof(game.rooms), "%s/books/%s/rooms", game.root, book_name());
    if (length < 0 || (size_t)length >= sizeof(game.rooms)) fail("adventure path is too long");
    length = snprintf(game.illustrations, sizeof(game.illustrations),
                      "%s/books/%s/illustrations", game.root, book_name());
    if (length < 0 || (size_t)length >= sizeof(game.illustrations)) fail("illustration path is too long");
    game.room = ROOM_FLOOR;
    set_object(ROOM_FLOOR, "attic-floor", room_name(ROOM_FLOOR), "Чердачный пол");
    set_object(ROOM_TABLE, "writing-desk", room_name(ROOM_TABLE), "Письменный стол");
    set_object(ROOM_SILL, "window-sill", room_name(ROOM_SILL), "Подоконник");
    set_object(OBJECT_BRASS_STAR, "brassstar", "звёздочка", "латунная звёздочка");
    set_object(OBJECT_CHAIR, "chair", "стул", "бабушкин стул");
    set_object(OBJECT_COPPER_STAR, "copperstar", "звёздочка", "медная звёздочка");
    set_object(OBJECT_SILL_LEDGE, "sill-ledge", "подоконник", "край подоконника");
    set_object(OBJECT_PEARL_STAR, "pearlstar", "звёздочка", "светлая звёздочка");
    show_room();
}

void book_shutdown(void)
{
    memset(&game, 0, sizeof(game));
    memset(&current, 0, sizeof(current));
    memset(&draft, 0, sizeof(draft));
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
    case CHOICE_INVALID: break;
    }
    fail("invalid choice kind %d", kind);
}

bool book_action(int index)
{
    if (index < 0 || index >= current.choice_count) return false;
    const struct Choice choice = current.choices[index];
    switch (choice.kind) {
    case CHOICE_OBJECT: return perform(choice.object);
    case CHOICE_CONTINUE:
        if (game.facts == FOUND_ALL_STARS) finish_story();
        else show_room();
        return true;
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
    if (!input || !*input || current.kind == PAGE_ENDED) return false;
    for (int i = 0; i < current.choice_count; ++i)
        if (*current.choices[i].command && !strcmp(input, current.choices[i].command))
            return book_action(i);
    return false;
}

void book_reload(void)
{
    if (current.kind == PAGE_ROOM) show_room();
    else {
        draft = current;
        select_image(&draft, current.camera, current.camera);
        publish_page();
    }
}

int book_object_room(int object)
{
    if (object == OBJECT_BRASS_STAR || object == OBJECT_CHAIR) return ROOM_FLOOR;
    if (object == OBJECT_COPPER_STAR || object == OBJECT_SILL_LEDGE) return ROOM_TABLE;
    if (object == OBJECT_PEARL_STAR) return ROOM_SILL;
    return object >= ROOM_FLOOR && object <= ROOM_SILL ? object : 0;
}
