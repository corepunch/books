#include "book.h"

/* Огонь на маяке: Varya must reach her sick grandfather's lighthouse across the bay and
 * light it before the storm brings the fishing boats home in the dark. The design and
 * every working document live in books/lighthouse/; src/story.c runs this table. */

enum {
    FOLLOWED_SEAL = 1u << 0,  /* the seal showed Varya the dry sandbar */
    AGAFYA_HELPED = 1u << 1,  /* the shepherd walked her round and vouched for her */
    FERRY_REFUSED = 1u << 2,  /* the ferryman already said no */
};

static const struct StoryPage pages[] = {
    /* Act 1: departure. */
    {.id = "start", .kind = STORY_PASSAGE, .location = "cottage", .camera = "home-show-grandpa",
     .text = "Ветер бьёт в окно дедушкиного дома. Дедушка Матвей — смотритель маяка, но сегодня он "
             "лежит в жару и не может встать. А в море ещё лодки, и среди них папина. «Солнце садится, "
             "— шепчет дедушка. — Кто-то должен зажечь маяк».",
     .next = "home-advice"},
    {.id = "home-advice", .kind = STORY_PASSAGE, .location = "cottage", .camera = "home-show-grandpa",
     .text = "«Запомни, Варя: наверху сначала закрой окно, а уж потом зажигай фитиль. Иначе ветер "
             "задует огонь». За окном, на острове за бухтой, чернеет маяк — тёмный, как погасшая свеча.",
     .next = "home-decide"},
    {.id = "home-decide", .kind = STORY_DECISION, .location = "cottage", .camera = "home-show-door",
     .text = "Варя смотрит на дедушку, потом на дверь. До маяка далеко: через гавань, по берегу или "
             "по обрыву, а потом через пролив. Скоро начнётся буря.",
     .choices = {{.label = "Бежать на маяк?", .anchor = "door", .target = "harbour"},
                 {.label = "Остаться с дедушкой?", .anchor = "grandpa", .target = "end-stay"}}},
    {.id = "end-stay", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "cottage",
     .camera = "home-night-stay",
     .text = "Варя остаётся у кровати и держит дедушку за руку. Всю ночь гремит буря, а маяк так и "
             "стоит тёмным. Лодки до утра кружат у входа в бухту и возвращаются только на рассвете, "
             "мокрые и усталые. «Ничего, — шепчет дедушка. — В другой раз»."},

    {.id = "harbour", .kind = STORY_PASSAGE, .location = "harbour", .camera = "harbour-show-timka",
     .text = "Варя бежит в гавань. Лодки вытащены на берег, чайки жмутся к крышам. Тимка, сын "
             "рыбака, сматывает сети. «На маяк? По отмели быстрее, пока отлив. Только вода скоро "
             "пойдёт. А по обрыву долго, зато сухо».",
     .next = "fork"},
    {.id = "fork", .kind = STORY_DECISION, .location = "harbour", .camera = "harbour-show-fork",
     .text = "За гаванью дорога расходится у старого столба. Направо песчаная тропа сбегает на "
             "отмель. Налево каменистая тропа карабкается на обрыв, где пасутся козы. Маяк чернеет "
             "впереди, за проливом.",
     .choices = {{.label = "Бежать по отмели?", .anchor = "flats-path", .target = "flats"},
                 {.label = "Идти по обрыву?", .anchor = "cliff-path", .target = "cliffs"}}},

    /* Act 2: the road across the flats. */
    {.id = "flats", .kind = STORY_PASSAGE, .location = "flats", .camera = "flats-show-wreck",
     .text = "Отмель блестит, как мокрое зеркало. Посреди неё лежит старая лодка «Чайка», разбитая "
             "много лет назад. На камне сидит тюлень и смотрит прямо на Варю. «Вода придёт с запада, "
             "— вдруг говорит он. — Кто торопится через „Чайку“, тот на ней и останется».",
     .next = "flats-decide"},
    {.id = "flats-decide", .kind = STORY_DECISION, .location = "flats", .camera = "flats-show-wreck",
     .text = "Тюлень ждёт на камне у песчаной косы. Сквозь разбитую «Чайку» путь короче. А позади, "
             "за дюнами, ещё видна тропа на обрыв.",
     .choices = {{.label = "Срезать через «Чайку»?", .anchor = "wreck", .target = "wreck"},
                 {.label = "Идти за тюленем?", .anchor = "seal", .target = "seal-bar"},
                 {.label = "Вернуться к обрыву?", .anchor = "dune-path", .target = "cliffs"}}},
    {.id = "wreck", .kind = STORY_PASSAGE, .location = "flats", .camera = "flats-climb-wreck",
     .text = "Варя пролезает в пролом борта. Внутри темно и пахнет водорослями. Когда она "
             "выбирается с другой стороны, под ногами уже хлюпает вода: прилив идёт с запада, как и "
             "говорил тюлень.",
     .next = "wreck-decide"},
    {.id = "wreck-decide", .kind = STORY_DECISION, .location = "flats", .camera = "flats-show-tide",
     .text = "Вода прибывает быстро. До камней у пролива ещё далеко, но пока мелко, по колено. А "
             "можно забраться на палубу «Чайки»: там сухо и высоко.",
     .choices = {{.label = "Бежать к проливу?", .anchor = "channel-stones", .target = "flats-run"},
                 {.label = "Залезть на палубу?", .anchor = "deck", .target = "end-wreck"}}},
    {.id = "end-wreck", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "flats",
     .camera = "flats-night-wreck",
     .text = "Варя сидит на палубе «Чайки», а вокруг плещется море. До утра отсюда не выбраться, и "
             "ночью маяк так и не загорается. На рассвете Тимка приплывает за ней на отцовской лодке. "
             "«Ну ты и капитан!» — смеётся он. Варе совсем не смешно."},
    {.id = "flats-run", .kind = STORY_PASSAGE, .location = "flats", .camera = "flats-run-stones",
     .text = "Варя бежит по воде, поднимая брызги. Волна толкает её в спину, в сапогах полно воды, "
             "но вот и камни у пролива. Она выбирается на берег, мокрая до пояса. Успела!",
     .next = "channel"},
    {.id = "seal-bar", .kind = STORY_PASSAGE, .location = "flats", .camera = "flats-follow-seal",
     .sets = FOLLOWED_SEAL,
     .text = "Тюлень плывёт вдоль косы, и Варя идёт за ним по узкой полоске песка. Вокруг уже вода, а "
             "коса остаётся сухой, будто тюлень знает тайную дорогу. У пролива он оборачивается: "
             "«На камнях я помогу ещё раз».",
     .next = "channel"},

    /* Act 2: the road over the cliffs. */
    {.id = "cliffs", .kind = STORY_PASSAGE, .location = "cliffs", .camera = "cliffs-show-hut",
     .text = "Тропа вьётся вверх по обрыву, ветер рвёт шарф. У каменной хижины пастушка Агафья "
             "загоняет коз. «На маяк? В такую погоду? Через овраг есть верёвочный мост. Только третью "
             "доску не трогай — гнилая. Или иди в обход, по овечьей тропе. Долго, правда».",
     .next = "cliffs-decide"},
    {.id = "cliffs-decide", .kind = STORY_DECISION, .location = "cliffs", .camera = "cliffs-show-hut",
     .text = "Над оврагом качается верёвочный мост. Агафья ждёт у калитки. А внизу, под обрывом, "
             "блестит отмель — туда тоже можно спуститься.",
     .choices = {{.label = "Перейти мост?", .anchor = "bridge", .target = "bridge"},
                 {.label = "Попросить Агафью?", .anchor = "agafya", .target = "sheep-track"},
                 {.label = "Спуститься на отмель?", .anchor = "flats-down", .target = "flats"}}},
    {.id = "bridge", .kind = STORY_DECISION, .location = "cliffs", .camera = "cliffs-cross-bridge",
     .text = "Мост скрипит и качается. Внизу, в овраге, шумит ручей. Первая доска, вторая… Третья "
             "— тёмная, в зелёных пятнах.",
     .choices = {{.label = "Шагнуть на третью доску?", .anchor = "plank", .target = "end-bridge"},
                 {.label = "Перешагнуть её?", .anchor = "far-plank", .target = "bridge-over"}}},
    {.id = "end-bridge", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "cliffs",
     .camera = "cliffs-hang-bridge",
     .text = "Доска с треском ломается! Варя повисает на верёвках, и Агафья вытаскивает её обратно. "
             "«Говорила же — третья!» Пока Варя греется в хижине, солнце садится, и пролив тонет в "
             "тумане. Маяк в эту ночь так и остаётся тёмным."},
    {.id = "bridge-over", .kind = STORY_PASSAGE, .location = "cliffs", .camera = "cliffs-past-bridge",
     .text = "Варя широко шагает через гнилую доску на четвёртую. Мост вздрагивает, но держит. На той "
             "стороне тропа сбегает вниз, к проливу.",
     .next = "channel"},
    {.id = "sheep-track", .kind = STORY_PASSAGE, .location = "cliffs", .camera = "cliffs-walk-agafya",
     .sets = AGAFYA_HELPED,
     .text = "Агафья ведёт Варю в обход, по узкой овечьей тропе. Идти долго, солнце уже касается моря. "
             "«Паромщик Савелий мне должен за козье молоко, — говорит Агафья. — Скажи, что я велела "
             "тебя перевезти».",
     .next = "channel"},

    /* The channel: every road meets here. */
    {.id = "channel", .kind = STORY_CHECK, .fact = FERRY_REFUSED, .next = "channel-refused",
     .otherwise = "channel-decide"},
    {.id = "channel-decide", .kind = STORY_DECISION, .location = "channel", .camera = "channel-show-ferry",
     .text = "Пролив кипит белыми барашками. У причала качается лодка паромщика Савелия, сам он "
             "курит трубку у сторожки. Из воды торчат камни старой переправы, но их уже заливает.",
     .choices = {{.label = "Попросить паромщика?", .anchor = "ferryman", .target = "ask-ferry"},
                 {.label = "Идти по камням?", .anchor = "stones", .target = "stones"},
                 {.label = "Переждать в сторожке?", .anchor = "hut-door", .target = "end-hut"}}},
    {.id = "channel-refused", .kind = STORY_DECISION, .location = "channel", .camera = "channel-show-ferry",
     .text = "Савелий отвернулся и пыхтит трубкой. Камни переправы почти скрылись под водой. Ещё "
             "немного — и их не будет видно вовсе.",
     .choices = {{.label = "Идти по камням?", .anchor = "stones", .target = "stones"},
                 {.label = "Переждать в сторожке?", .anchor = "hut-door", .target = "end-hut"}}},
    {.id = "ask-ferry", .kind = STORY_CHECK, .fact = AGAFYA_HELPED, .next = "ferry-agafya",
     .otherwise = "ferry-refuse"},
    {.id = "ferry-refuse", .kind = STORY_PASSAGE, .location = "channel", .camera = "channel-talk-ferryman",
     .sets = FERRY_REFUSED,
     .text = "«В такую погоду? Ни за что, — ворчит Савелий. — Лодку перевернёт, и тебя вместе с ней». "
             "Он отворачивается и больше не смотрит на Варю.",
     .next = "channel"},
    {.id = "ferry-agafya", .kind = STORY_PASSAGE, .location = "channel", .camera = "channel-talk-ferryman",
     .text = "«Агафья велела? — Савелий чешет бороду. — Эх, ей не откажешь». Он выбивает трубку и "
             "отвязывает лодку.",
     .next = "ferry-ride"},
    {.id = "ferry-relent", .kind = STORY_PASSAGE, .location = "channel", .camera = "channel-talk-ferryman",
     .text = "Варя возвращается к причалу, мокрая с головы до ног. Савелий долго смотрит на неё. «Вот "
             "отчаянная, — вздыхает он. — Садись в лодку, пока совсем не утонула».",
     .next = "ferry-ride"},
    {.id = "ferry-ride", .kind = STORY_PASSAGE, .location = "channel", .camera = "channel-row-ferry",
     .text = "Лодка взлетает на волну и падает вниз. Савелий гребёт, стиснув зубы, а Варя держится "
             "за скамейку обеими руками. Наконец днище скрипит о камни острова. «Беги! — кричит "
             "паромщик. — Я подожду!»",
     .next = "island"},
    {.id = "stones", .kind = STORY_CHECK, .fact = FOLLOWED_SEAL, .next = "stones-seal",
     .otherwise = "stones-mid"},
    {.id = "stones-seal", .kind = STORY_PASSAGE, .location = "channel", .camera = "channel-stones-seal",
     .text = "Варя прыгает на первый камень, и рядом из воды показывается знакомая усатая морда. "
             "Тюлень плывёт впереди и ныряет у тех камней, что ещё держатся над водой. Камень, другой, "
             "третий — и вот уже остров!",
     .next = "island"},
    {.id = "stones-mid", .kind = STORY_DECISION, .location = "channel", .camera = "channel-stones-mid",
     .text = "Варя прыгает с камня на камень. На середине пролива волны уже перехлёстывают через "
             "них. До дальнего камня большой прыжок, а назад, к причалу, ещё недалеко.",
     .choices = {{.label = "Прыгнуть на дальний камень?", .anchor = "far-stone", .target = "end-stones"},
                 {.label = "Вернуться к причалу?", .anchor = "near-stone", .target = "ferry-relent"}}},
    {.id = "end-stones", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "channel",
     .camera = "channel-fall-stones",
     .text = "Варя прыгает — и не долетает. Холодная волна накрывает её с головой. Савелий выуживает "
             "её веслом и ведёт греться в сторожку. «Вот бестолковая!» — ворчит он и укрывает её "
             "тулупом. Маяк этой ночью так и не загорается."},
    {.id = "end-hut", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "channel",
     .camera = "channel-hut-night",
     .text = "Варя садится у печки в сторожке. «Правильно, — кивает Савелий. — В бурю по морю не "
             "ходят». За окном ревёт ветер, остров с маяком тонет в темноте. Лодки всю ночь ищут "
             "вход в бухту и приходят только к утру."},

    /* Act 3: the lighthouse. */
    {.id = "island", .kind = STORY_PASSAGE, .location = "island", .camera = "island-show-door",
     .text = "Варя взбегает по мокрым камням к маяку. Буря уже здесь: ветер валит с ног, волны "
             "разбиваются о скалы и осыпают её брызгами. Тяжёлая дверь поддаётся. Внутри — "
             "винтовая лестница, сто ступенек вверх.",
     .next = "stairs"},
    {.id = "stairs", .kind = STORY_PASSAGE, .location = "tower", .camera = "tower-climb-stairs",
     .text = "Варя бежит вверх, считая ступеньки. Пятьдесят… восемьдесят… сто! Наверху, в "
             "стеклянной комнате, стоит огромный фонарь. Одно окно распахнуто, и в него со свистом "
             "врывается ветер.",
     .next = "lamp"},
    {.id = "lamp", .kind = STORY_DECISION, .location = "tower", .camera = "lamp-show-window",
     .text = "Спички лежат на полке, фитиль ждёт огня. Далеко в море мигают крошечные огоньки лодок: "
             "они ищут дорогу домой. Окно хлопает на ветру.",
     .choices = {{.label = "Зажечь фитиль?", .anchor = "wick", .target = "end-late"},
                 {.label = "Закрыть окно?", .anchor = "window", .target = "end-light"}}},
    {.id = "end-late", .kind = STORY_ENDING, .ending = ENDING_PARTIAL, .location = "tower",
     .camera = "lamp-wind-out",
     .text = "Варя чиркает спичкой, фитиль вспыхивает — и ветер тут же задувает огонь. Ещё раз, и ещё! "
             "Только когда она закрывает окно, маяк наконец загорается. Лодки находят дорогу, но "
             "одну всё-таки выносит на мель у Чёрных камней. Все живы, но лодку тянут до утра."},
    {.id = "end-light", .kind = STORY_ENDING, .ending = ENDING_SUCCESS, .location = "tower",
     .camera = "lamp-light-shines",
     .text = "Варя захлопывает окно, как учил дедушка, и только потом зажигает фитиль. Линза "
             "вспыхивает, и луч маяка ложится на море. Одна за другой лодки поворачивают к бухте. "
             "Утром папа приходит домой, мокрый и счастливый. А Савелий говорит, что на Дальнем "
             "острове есть маяк ещё старше…"},
};

static const struct Story lighthouse = {
    .name = "lighthouse",
    .start = "start",
    .continue_label = "Дальше",
    .retry_label = "Попробовать снова",
    .restart_label = "Начать сначала",
    .pages = pages,
    .page_count = sizeof(pages) / sizeof(pages[0]),
};

const struct Story *book_story(void) { return &lighthouse; }
