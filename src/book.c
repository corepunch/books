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
    OBJECT_BOOK_STAIRS,
    OBJECT_COPPER_STAR,
    OBJECT_POSTCARD_STAIRS,
    OBJECT_PEARL_STAR
};

#define STAR_BRASS (1u << 0)
#define STAR_COPPER (1u << 1)
#define STAR_PEARL (1u << 2)
#define ALL_STARS (STAR_BRASS | STAR_COPPER | STAR_PEARL)

static struct {
    unsigned int inventory;
    int room;
    filePath_t root, rooms;
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
        return (game.inventory & STAR_BRASS)
            ? "Латунная звёздочка уже у Миры. Над её бумажным гнездом ждёт созвездие, а к столу ведут ступени из книг."
            : "Сквозняк сорвал три звёздочки с бумажного созвездия Миры. У гнезда лежит латунная звёздочка. К столу ведут ступени из книг.";
    case ROOM_TABLE:
        return (game.inventory & STAR_COPPER)
            ? "Мира уже забрала медную звёздочку. Среди листов остался карандаш, а сложенные открытки ведут к подоконнику."
            : "Между листами и карандашом поблёскивает медная звёздочка. Книжная лестница ведёт вниз, а открытки — выше, к окну.";
    case ROOM_SILL:
        return (game.inventory & STAR_PEARL)
            ? "У оконной рамы больше нет звёздочки. Внизу виден письменный стол, а за окном лежит тихая ночь."
            : "У оконной рамы Мира замечает светлую звёздочку. За окном темно, а внизу виден письменный стол.";
    default: return "";
    }
}

static void select_image(struct BookPage *page, const char *camera)
{
    page->image[0] = 0;
    copy(page->camera, sizeof(page->camera), camera);
    filePath_t path;
    int length = snprintf(path, sizeof(path), "%s/%s.jpg", game.rooms, camera);
    if (length < 0 || (size_t)length >= sizeof(path)) fail("illustration path is too long");
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

static void begin_page(enum PageKind kind, const char *text, const char *camera)
{
    memset(&draft, 0, sizeof(draft));
    draft.kind = kind;
    draft.room = game.room;
    copy(draft.text, sizeof(draft.text), text);
    select_image(&draft, camera);
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
        if (!(game.inventory & STAR_BRASS))
            append_choice(object_choice(OBJECT_BRASS_STAR, "Поднять латунную звёздочку", "take brass-star"));
        append_choice(object_choice(OBJECT_BOOK_STAIRS, "Взобраться на стол по книгам", "go table"));
        break;
    case ROOM_TABLE:
        if (!(game.inventory & STAR_COPPER))
            append_choice(object_choice(OBJECT_COPPER_STAR, "Поднять медную звёздочку", "take copper-star"));
        append_choice(object_choice(OBJECT_BOOK_STAIRS, "Спуститься на пол по книгам", "go floor"));
        append_choice(object_choice(OBJECT_POSTCARD_STAIRS, "Подняться к окну по открыткам", "go sill"));
        break;
    case ROOM_SILL:
        if (!(game.inventory & STAR_PEARL))
            append_choice(object_choice(OBJECT_PEARL_STAR, "Поднять светлую звёздочку", "take pearl-star"));
        append_choice(object_choice(OBJECT_POSTCARD_STAIRS, "Спуститься на стол по открыткам", "go table"));
        break;
    default: fail("unknown room %d", game.room);
    }
}

static void show_room(void)
{
    const char *camera = game.room == ROOM_FLOOR
        ? ((game.inventory & STAR_BRASS) ? "floor-show-cleared-room" : "floor-show-room")
        : game.room == ROOM_TABLE
            ? ((game.inventory & STAR_COPPER) ? "table-show-cleared-desk" : "table-show-desk")
            : "sill-show-window";
    begin_page(PAGE_ROOM, room_text(game.room), camera);
    add_room_choices();
    publish_page();
}

/* Story actions call this constructor; they never need to remember navigation. */
static void show_beat(const char *text, const char *camera)
{
    begin_page(PAGE_BEAT, text, camera);
    append_choice(continue_choice());
    publish_page();
}

static void finish_story(void)
{
    begin_page(PAGE_ENDED,
        "Мира возвращает все три звёздочки на бумажное созвездие. Чердак снова становится тихим, а над гнездом сияет маленькая карта неба.",
        "attic-return-stars");
    publish_page();
}

static bool perform(int object)
{
    if (current.kind != PAGE_ROOM) return false;
    const char *text, *camera;
    switch (object) {
    case OBJECT_BRASS_STAR:
        if (game.room != ROOM_FLOOR || game.inventory & STAR_BRASS) return false;
        game.inventory |= STAR_BRASS;
        text = "Мира бережно поднимает латунную звёздочку у своего гнезда.";
        camera = "floor-take-gold-star";
        break;
    case OBJECT_COPPER_STAR:
        if (game.room != ROOM_TABLE || game.inventory & STAR_COPPER) return false;
        game.inventory |= STAR_COPPER;
        text = "Мира находит медную звёздочку между листами.";
        camera = "table-take-copper-star";
        break;
    case OBJECT_PEARL_STAR:
        if (game.room != ROOM_SILL || game.inventory & STAR_PEARL) return false;
        game.inventory |= STAR_PEARL;
        text = "Мира поднимает последнюю звёздочку у оконной рамы.";
        camera = "sill-take-pearl-star";
        break;
    case OBJECT_BOOK_STAIRS:
        if (game.room == ROOM_FLOOR) {
            game.room = ROOM_TABLE;
            text = "Мира перебирается по книжным ступеням на столешницу.";
            camera = "floor-climb-table";
        } else if (game.room == ROOM_TABLE) {
            game.room = ROOM_FLOOR;
            text = "Мира осторожно спускается по книгам на пол.";
            camera = "table-go-floor";
        } else return false;
        break;
    case OBJECT_POSTCARD_STAIRS:
        if (game.room == ROOM_TABLE) {
            game.room = ROOM_SILL;
            text = "Мира взбирается по открыткам на подоконник.";
            camera = "table-climb-sill";
        } else if (game.room == ROOM_SILL) {
            game.room = ROOM_TABLE;
            text = "Мира спускается по открыткам обратно на стол.";
            camera = "sill-go-table";
        } else return false;
        break;
    default: return false;
    }

    if (game.inventory == ALL_STARS) finish_story();
    else show_beat(text, camera);
    return true;
}

void book_init(const char *root, const char *adventure)
{
    (void)adventure;
    memset(&current, 0, sizeof(current));
    memset(&draft, 0, sizeof(draft));
    memset(&game, 0, sizeof(game));
    if (!realpath(root, game.root)) fail("cannot resolve asset root: %s", root);
    int length = snprintf(game.rooms, sizeof(game.rooms), "%s/books/three-stars/rooms", game.root);
    if (length < 0 || (size_t)length >= sizeof(game.rooms)) fail("adventure path is too long");
    game.room = ROOM_FLOOR;
    set_object(ROOM_FLOOR, "attic-floor", room_name(ROOM_FLOOR), "Чердачный пол");
    set_object(ROOM_TABLE, "writing-desk", room_name(ROOM_TABLE), "Письменный стол");
    set_object(ROOM_SILL, "window-sill", room_name(ROOM_SILL), "Подоконник");
    set_object(OBJECT_BRASS_STAR, "brassstar", "звёздочка", "латунная звёздочка");
    set_object(OBJECT_BOOK_STAIRS, "book-stairs", "ступени", "книжные ступени");
    set_object(OBJECT_COPPER_STAR, "copperstar", "звёздочка", "медная звёздочка");
    set_object(OBJECT_POSTCARD_STAIRS, "postcard-stairs", "открытки", "сложенные открытки");
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
    case CHOICE_CONTINUE: show_room(); return true;
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
    if (!strcmp(input, "inventory")) {
        /* Diagnostic prose preserves the current page's typed actions. */
        draft = current;
        size_t used = (size_t)snprintf(draft.text, sizeof(draft.text), "У Миры: ");
        if (!game.inventory) snprintf(draft.text + used, sizeof(draft.text) - used, "пока нет звёздочек.");
        else {
            bool first = true;
            const struct { unsigned int bit; const char *name; } names[] = {
                {STAR_BRASS, "латунная звёздочка"}, {STAR_COPPER, "медная звёздочка"}, {STAR_PEARL, "светлая звёздочка"}
            };
            for (size_t i = 0; i < sizeof(names) / sizeof(names[0]); ++i) if (game.inventory & names[i].bit) {
                int n = snprintf(draft.text + used, sizeof(draft.text) - used,
                                 "%s%s", first ? "" : ", ", names[i].name);
                if (n > 0) used += (size_t)n;
                first = false;
            }
        }
        publish_page();
        return true;
    }
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
        select_image(&draft, current.camera);
        publish_page();
    }
}

int book_object_room(int object)
{
    if (object == OBJECT_BRASS_STAR || object == OBJECT_BOOK_STAIRS) return ROOM_FLOOR;
    if (object == OBJECT_COPPER_STAR || object == OBJECT_POSTCARD_STAIRS) return ROOM_TABLE;
    if (object == OBJECT_PEARL_STAR) return ROOM_SILL;
    return object >= ROOM_FLOOR && object <= ROOM_SILL ? object : 0;
}
