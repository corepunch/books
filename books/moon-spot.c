#define _XOPEN_SOURCE 700
#include "book.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Мира и лунный зайчик: a short example book for authoring/. One kitchen, two play
 * areas (floor and table), two story facts and two endings; see books/moon-spot/. */
enum {
    ROOM_FLOOR = 1,
    ROOM_TABLE,
    OBJECT_MOON_SPOT,
    OBJECT_BUBLIK,
    OBJECT_STOOL,
    OBJECT_MIRROR,
    OBJECT_CURTAIN
};

#define MIRROR_TURNED (1u << 0)  /* Mira pushed the mirror; the spot left the dresser. */
#define BUBLIK_INVITED (1u << 1) /* Бублик told her about the window and offered his side. */

static struct {
    unsigned int facts; /* Story facts that later pages check; there is no inventory. */
    int room;
    filePath_t root, rooms, illustrations;
    struct Object objects[MAX_OBJECTS];
} game;

/* Build into private scratch storage; consumers only see validated, complete pages.
 * Keep these large snapshots off the iPad main-thread stack. */
static struct BookPage current, draft;

static bool has(unsigned int fact) { return (game.facts & fact) != 0; }

static void set_object(int id, const char *key)
{
    copy(game.objects[id].key, sizeof(game.objects[id].key), key);
}

static const char *room_text(int room)
{
    switch (room) {
    case ROOM_FLOOR:
        if (has(MIRROR_TURNED))
            return has(BUBLIK_INVITED)
                ? "Бублик сидит на подстилке, а зайчик лежит у его тёплого бока. «Ну что, — зевает пёс, — ложись уже»."
                : "Бублик сидит на подстилке и трёт нос лапой. Зайчик лежит рядом с ним, круглый и светлый. Пёс смотрит на Миру очень подозрительно.";
        return has(BUBLIK_INVITED)
            ? "Бублик опять храпит. «Зайчик приходит с окна», — сказал он. А зайчик всё дрожит на дверце буфета, и табурет ждёт у стола."
            : "На дверце буфета дрожит лунный зайчик — светлый и круглый, как подушка. Мира хочет в нём поспать! Зайчик вздрагивает, когда у окна колышется занавеска. У печки храпит пёс Бублик, а к столу придвинут табурет.";
    case ROOM_TABLE:
        return has(MIRROR_TURNED)
            ? "Теперь Мира знает: куда повернёшь зеркальце, туда и прыгнет зайчик. Сейчас он лежит на подстилке Бублика. А корзинка Миры стоит в тёмном углу у буфета."
            : "На столе стоит бабушкино круглое зеркальце. Луна светит прямо в него, и от стекла через всю кухню бежит светлая дорожка — к зайчику на буфете. У окна колышется занавеска.";
    default: return "";
    }
}

static const char *room_camera(int room)
{
    if (room == ROOM_FLOOR) return has(MIRROR_TURNED) ? "floor-show-awake" : "floor-show-kitchen";
    return has(MIRROR_TURNED) ? "table-show-turned" : "table-show-mirror";
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

static void begin_page(enum PageKind kind, const char *text, const char *camera)
{
    memset(&draft, 0, sizeof(draft));
    draft.kind = kind;
    draft.room = game.room;
    copy(draft.text, sizeof(draft.text), text);
    /* Every page is one whole picture: the painting for its camera, else the camera's render. */
    select_image(&draft, camera, camera);
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

/* Offer only what is possible under the current facts; never publish a "you can't" page. */
static void add_room_choices(void)
{
    switch (game.room) {
    case ROOM_FLOOR:
        if (!has(MIRROR_TURNED)) {
            append_choice(object_choice(OBJECT_MOON_SPOT, "Поймать зайчика?", "catch spot"));
            if (!has(BUBLIK_INVITED))
                append_choice(object_choice(OBJECT_BUBLIK, "Разбудить Бублика?", "wake bublik"));
        } else if (!has(BUBLIK_INVITED))
            append_choice(object_choice(OBJECT_BUBLIK, "Поговорить с Бубликом?", "talk bublik"));
        else
            append_choice(object_choice(OBJECT_BUBLIK, "Лечь к Бублику?", "lie bublik"));
        append_choice(object_choice(OBJECT_STOOL, "Запрыгнуть на табурет?", "climb stool"));
        break;
    case ROOM_TABLE:
        append_choice(has(MIRROR_TURNED)
            ? object_choice(OBJECT_MIRROR, "Повернуть зайчика к корзинке?", "aim mirror")
            : object_choice(OBJECT_MIRROR, "Толкнуть зеркальце?", "push mirror"));
        append_choice(object_choice(OBJECT_CURTAIN, "Поймать занавеску?", "catch curtain"));
        append_choice(object_choice(OBJECT_STOOL, "Спуститься на пол?", "go floor"));
        break;
    default: fail("unknown room %d", game.room);
    }
}

static void show_room(void)
{
    begin_page(PAGE_ROOM, room_text(game.room), room_camera(game.room));
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

static void finish_story(const char *text, const char *camera)
{
    begin_page(PAGE_ENDED, text, camera);
    publish_page();
}

static void finish_in_basket(void)
{
    /* The ending remembers whether Бублик gave Mira the first clue. */
    storyText_t text;
    int length = snprintf(text, sizeof(text), "%s%s%s",
        "Мира поворачивает зеркальце чуть-чуть, ещё чуть-чуть… Зайчик сползает с подстилки, бежит по полу и забирается в её корзинку. Мира спрыгивает вниз и сворачивается прямо в лунном свете. Поймала — не прыжком, а головой!",
        has(BUBLIK_INVITED) ? " «Я же говорил — с окна», — бормочет во сне Бублик." : "",
        " А утром в окно заглянет солнце.");
    if (length < 0 || (size_t)length >= sizeof(text)) fail("ending text is too long");
    finish_story(text, "kitchen-sleep-basket");
}

static bool perform(int object)
{
    if (current.kind != PAGE_ROOM) return false;
    const char *text, *camera;
    switch (object) {
    case OBJECT_MOON_SPOT:
        if (game.room != ROOM_FLOOR || has(MIRROR_TURNED)) return false;
        text = "Мира прыгает — хлоп! Лапы скользят по дверце, а зайчик уже сидит у неё на спине. Свою спину никак не поймать!";
        camera = "floor-pounce-spot";
        break;
    case OBJECT_BUBLIK:
        if (game.room != ROOM_FLOOR) return false;
        if (has(BUBLIK_INVITED)) {
            if (!has(MIRROR_TURNED)) return false;
            finish_story("Мира сворачивается у тёплого бока Бублика, прямо в лунном зайчике. Пёс укрывает её ухом. На старой фотографии у окна щенок Бублик ловит солнечного зайчика. А теперь они поймали лунного — вдвоём.",
                         "kitchen-sleep-bublik");
            return true;
        }
        game.facts |= BUBLIK_INVITED;
        if (has(MIRROR_TURNED)) {
            text = "«Это ты мне зайчика на нос посадила? — ворчит Бублик и вдруг улыбается. — Я щенком тоже зайчиков ловил. Ложись рядом, тут тепло».";
            camera = "floor-talk-bublik";
        } else {
            text = "Бублик приоткрывает один глаз. «Зайчик приходит с окна, — ворчит он. — А спать лучше у меня под боком». И снова храпит.";
            camera = "floor-wake-bublik";
        }
        break;
    case OBJECT_STOOL:
        if (game.room == ROOM_FLOOR) {
            game.room = ROOM_TABLE;
            text = "Мира прыгает на табурет, а оттуда — лапами на край стола. Стол пахнет бабушкиным чаем.";
            camera = "floor-climb-stool";
        } else if (game.room == ROOM_TABLE) {
            game.room = ROOM_FLOOR;
            text = "Мира спрыгивает на табурет, а с него — на пол. Тихо-тихо, как умеют только кошки.";
            camera = "table-go-floor";
        } else return false;
        break;
    case OBJECT_MIRROR:
        if (game.room != ROOM_TABLE) return false;
        if (has(MIRROR_TURNED)) {
            finish_in_basket();
            return true;
        }
        game.facts |= MIRROR_TURNED;
        text = "Мира толкает зеркальце лапкой. Зайчик срывается с буфета — и прыгает Бублику прямо на нос! «Апчхи!» Бублик садится и сердито моргает.";
        camera = "table-push-mirror";
        break;
    case OBJECT_CURTAIN:
        if (game.room != ROOM_TABLE) return false;
        text = "Мира ловит занавеску и повисает на ней, как носок на верёвке. Окно закрыто — и зайчик погас! Мира отпускает ткань, и зайчик вернулся.";
        camera = "table-catch-curtain";
        break;
    default: return false;
    }

    show_beat(text, camera);
    return true;
}

const char *book_name(void)
{
    return "moon-spot";
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
    set_object(ROOM_FLOOR, "kitchen-floor");
    set_object(ROOM_TABLE, "kitchen-table");
    /* Keys match the anchor group names in rooms/kitchen.blks. */
    set_object(OBJECT_MOON_SPOT, "moonspot");
    set_object(OBJECT_BUBLIK, "bublik");
    set_object(OBJECT_STOOL, "stool");
    set_object(OBJECT_MIRROR, "mirror");
    set_object(OBJECT_CURTAIN, "curtain");
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
        show_room();
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
    switch (object) {
    case OBJECT_MOON_SPOT:
    case OBJECT_BUBLIK:
    case OBJECT_STOOL: return ROOM_FLOOR;
    case OBJECT_MIRROR:
    case OBJECT_CURTAIN: return ROOM_TABLE;
    default: return object == ROOM_FLOOR || object == ROOM_TABLE ? object : 0;
    }
}
