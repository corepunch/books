#define _XOPEN_SOURCE 700
#include "book.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

struct Book book;

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
    storyText_t inventory_text;
} game;

static void set_object(int id, const char *key, const char *name, const char *description)
{
    struct Object *object = &book.objects[id];
    copy(object->symbol, sizeof(object->symbol), key);
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

static void select_image(const char *camera)
{
    book.image[0] = book.camera[0] = 0;
    if (!camera || !*camera) return;
    filePath_t path;
    int length = snprintf(path, sizeof(path), "%s/%s.jpg", book.rooms, camera);
    if (length < 0 || (size_t)length >= sizeof(path)) fail("illustration path is too long");
    if (access(path, R_OK)) return;
    copy(book.image, sizeof(book.image), path);
    copy(book.camera, sizeof(book.camera), camera);
}

static void add_choice(int object, const char *label, const char *command)
{
    if (book.choice_count >= MAX_CHOICES) fail("too many adventure choices");
    struct Choice *choice = &book.choices[book.choice_count++];
    copy(choice->label, sizeof(choice->label), label);
    copy(choice->command, sizeof(choice->command), command);
    choice->object = object;
    choice->focus = true;
}

static void refresh_choices(void)
{
    book.choice_count = 0;
    if (book.beat || book.ended) {
        if (book.beat) {
            struct Choice *choice = &book.choices[book.choice_count++];
            copy(choice->label, sizeof(choice->label), "Продолжить");
            choice->object = 0;
        }
        return;
    }

    switch (book.room) {
    case ROOM_FLOOR:
        if (!(game.inventory & STAR_BRASS))
            add_choice(OBJECT_BRASS_STAR, "Поднять латунную звёздочку", "take brass-star");
        add_choice(OBJECT_BOOK_STAIRS, "Взобраться на стол по книгам", "go table");
        break;
    case ROOM_TABLE:
        if (!(game.inventory & STAR_COPPER))
            add_choice(OBJECT_COPPER_STAR, "Поднять медную звёздочку", "take copper-star");
        add_choice(OBJECT_BOOK_STAIRS, "Спуститься на пол по книгам", "go floor");
        add_choice(OBJECT_POSTCARD_STAIRS, "Подняться к окну по открыткам", "go sill");
        break;
    case ROOM_SILL:
        if (!(game.inventory & STAR_PEARL))
            add_choice(OBJECT_PEARL_STAR, "Поднять светлую звёздочку", "take pearl-star");
        add_choice(OBJECT_POSTCARD_STAIRS, "Спуститься на стол по открыткам", "go table");
        break;
    }
}

static void show_room(void)
{
    book.beat = false;
    book.focus = 0;
    book.room_text[0] = 0;
    copy(book.room_text, sizeof(book.room_text), room_text(book.room));
    copy(book.text, sizeof(book.text), book.room_text);
    const char *camera = book.room == ROOM_FLOOR
        ? ((game.inventory & STAR_BRASS) ? "floor-show-cleared-room" : "floor-show-room")
        : book.room == ROOM_TABLE
            ? ((game.inventory & STAR_COPPER) ? "table-show-cleared-desk" : "table-show-desk")
            : "sill-show-window";
    select_image(camera);
    refresh_choices();
}

static void finish_story(void)
{
    book.beat = false;
    book.ended = true;
    book.choice_count = 0;
    copy(book.text, sizeof(book.text),
         "Мира возвращает все три звёздочки на бумажное созвездие. Чердак снова становится тихим, а над гнездом сияет маленькая карта неба.");
    select_image("attic-return-stars");
}

static void perform(int object)
{
    if (book.ended || book.beat) return;
    book.focus = 0;
    switch (object) {
    case OBJECT_BRASS_STAR:
        if (book.room != ROOM_FLOOR || game.inventory & STAR_BRASS) return;
        game.inventory |= STAR_BRASS;
        copy(book.text, sizeof(book.text), "Мира бережно поднимает латунную звёздочку у своего гнезда.");
        select_image("floor-take-gold-star");
        break;
    case OBJECT_COPPER_STAR:
        if (book.room != ROOM_TABLE || game.inventory & STAR_COPPER) return;
        game.inventory |= STAR_COPPER;
        copy(book.text, sizeof(book.text), "Мира находит медную звёздочку между листами.");
        select_image("table-take-copper-star");
        break;
    case OBJECT_PEARL_STAR:
        if (book.room != ROOM_SILL || game.inventory & STAR_PEARL) return;
        game.inventory |= STAR_PEARL;
        copy(book.text, sizeof(book.text), "Мира поднимает последнюю звёздочку у оконной рамы.");
        select_image("sill-take-pearl-star");
        break;
    case OBJECT_BOOK_STAIRS:
        if (book.room == ROOM_FLOOR) {
            book.room = ROOM_TABLE;
            copy(book.text, sizeof(book.text), "Мира перебирается по книжным ступеням на столешницу.");
            select_image("floor-climb-table");
        } else if (book.room == ROOM_TABLE) {
            book.room = ROOM_FLOOR;
            copy(book.text, sizeof(book.text), "Мира осторожно спускается по книгам на пол.");
            select_image("table-go-floor");
        } else return;
        break;
    case OBJECT_POSTCARD_STAIRS:
        if (book.room == ROOM_TABLE) {
            book.room = ROOM_SILL;
            copy(book.text, sizeof(book.text), "Мира взбирается по открыткам на подоконник.");
            select_image("table-climb-sill");
        } else if (book.room == ROOM_SILL) {
            book.room = ROOM_TABLE;
            copy(book.text, sizeof(book.text), "Мира спускается по открыткам обратно на стол.");
            select_image("sill-go-table");
        } else return;
        break;
    default: return;
    }

    if (game.inventory == ALL_STARS) finish_story();
    else {
        book.beat = true;
        refresh_choices();
    }
}

void book_init(const char *root, const char *adventure)
{
    (void)adventure;
    memset(&book, 0, sizeof(book));
    memset(&game, 0, sizeof(game));
    if (!realpath(root, book.root)) fail("cannot resolve asset root: %s", root);
    copy(book.adventure, sizeof(book.adventure), "three-stars");
    int length = snprintf(book.rooms, sizeof(book.rooms), "%s/books/three-stars/rooms", book.root);
    if (length < 0 || (size_t)length >= sizeof(book.rooms)) fail("adventure path is too long");
    book.room = ROOM_FLOOR;
    set_object(ROOM_FLOOR, "attic-floor", room_name(ROOM_FLOOR), "Чердачный пол");
    set_object(ROOM_TABLE, "writing-desk", room_name(ROOM_TABLE), "Письменный стол");
    set_object(ROOM_SILL, "window-sill", room_name(ROOM_SILL), "Подоконник");
    set_object(OBJECT_BRASS_STAR, "brassstar", "звёздочка", "латунная звёздочка");
    set_object(OBJECT_BOOK_STAIRS, "book-stairs", "ступени", "книжные ступени");
    set_object(OBJECT_COPPER_STAR, "copperstar", "звёздочка", "медная звёздочка");
    set_object(OBJECT_POSTCARD_STAIRS, "postcard-stairs", "открытки", "сложенные открытки");
    set_object(OBJECT_PEARL_STAR, "pearlstar", "звёздочка", "светлая звёздочка");
    copy(book.room_text, sizeof(book.room_text), room_text(book.room));
    copy(book.text, sizeof(book.text), book.room_text);
    select_image("floor-show-room");
    refresh_choices();
}

void book_shutdown(void) { memset(&game, 0, sizeof(game)); }

void book_command(const char *input, int subject)
{
    (void)subject;
    if (!input || !*input || book.ended) return;
    if (!strcmp(input, "inventory")) {
        size_t used = 0;
        used += (size_t)snprintf(game.inventory_text, sizeof(game.inventory_text), "У Миры: ");
        if (!game.inventory) snprintf(game.inventory_text + used, sizeof(game.inventory_text) - used, "пока нет звёздочек.");
        else {
            bool first = true;
            const struct { unsigned int bit; const char *name; } names[] = {
                {STAR_BRASS, "латунная звёздочка"}, {STAR_COPPER, "медная звёздочка"}, {STAR_PEARL, "светлая звёздочка"}
            };
            for (size_t i = 0; i < sizeof(names) / sizeof(names[0]); ++i) if (game.inventory & names[i].bit) {
                int n = snprintf(game.inventory_text + used, sizeof(game.inventory_text) - used,
                                 "%s%s", first ? "" : ", ", names[i].name);
                if (n > 0) used += (size_t)n;
                first = false;
            }
        }
        copy(book.text, sizeof(book.text), game.inventory_text);
        return;
    }
    for (int i = 0; i < book.choice_count; ++i)
        if (*book.choices[i].command && !strcmp(input, book.choices[i].command)) {
            perform(book.choices[i].object);
            return;
        }
}

void book_back(void)
{
    if (book.ended) return;
    show_room();
}

void book_focus_object(int object) { perform(object); }

void book_action(int index)
{
    if (index < 0 || index >= book.choice_count) return;
    const struct Choice choice = book.choices[index];
    if (choice.focus) perform(choice.object);
    else if (book.beat) book_back();
}

void book_reload(void)
{
    if (!book.beat && !book.ended) show_room();
    else if (book.ended) select_image("attic-return-stars");
}

int book_object_room(int object)
{
    if (object == OBJECT_BRASS_STAR || object == OBJECT_BOOK_STAIRS) return ROOM_FLOOR;
    if (object == OBJECT_COPPER_STAR || object == OBJECT_POSTCARD_STAIRS) return ROOM_TABLE;
    if (object == OBJECT_PEARL_STAR) return ROOM_SILL;
    return object >= ROOM_FLOOR && object <= ROOM_SILL ? object : 0;
}
