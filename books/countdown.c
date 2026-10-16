#include "book.h"

/* Обратный отсчёт: Superman against Brainiac, after Mayfair's DC Heroes module "Countdown to
 * Armageddon" (1986). A runaway train, a raid on S.T.A.R. Labs, the Fortress of Solitude, a belt of
 * meteorites in orbit and Brainiac's ship over Metropolis. Superman carries his powers like things in
 * an inventory: hold one and the page shows where it can be used. The red sun takes two of them away.
 * The design lives in books/countdown/; src/story.c runs this table. */

enum {
    SAW_BRIDGE = 1u << 0,      /* X-ray showed the washed-out bridge and the old timbers */
    SAW_MERCS = 1u << 1,       /* X-ray showed the men crawling under the floor */
    MERCS_CAUGHT = 1u << 2,    /* Brock and his men are tied up */
    LEAD_FOUND = 1u << 3,      /* X-ray found the lead-shelled weapon in the belt */
    SAW_AIRLOCK = 1u << 4,     /* X-ray found the red-sun emitter in the ship's airlock */
    SEEDING_STOPPED = 1u << 5, /* the antidote is in Brainiac's seeding tanks */
};

enum {
    HEAT = 1u << 0,
    XRAY = 1u << 1,
    BREATH = 1u << 2,
    HEARING = 1u << 3,
    PASS = 1u << 4,
    CABLE = 1u << 5,
    VIAL = 1u << 6,
    SPRAYER = 1u << 7,
    DRONE = 1u << 8,
    CANISTER = 1u << 9,
};

static const struct StoryItem items[] = {
    {.item = HEAT, .id = "heat", .name = "Тепловое зрение", .carried = true,
     .text = "Тепловое зрение: взгляд, который плавит сталь и сваривает железо. Куда посмотреть?"},
    {.item = XRAY, .id = "xray", .name = "Рентген", .carried = true,
     .text = "Рентген: Супермен видит сквозь стены, полы и обшивку. Не видно только того, что за свинцом. "
             "Куда заглянуть?"},
    {.item = BREATH, .id = "breath", .name = "Супердыхание", .carried = true,
     .text = "Супердыхание: выдох сильнее урагана. Им можно остановить, задуть, заморозить. На что подуть?"},
    {.item = HEARING, .id = "hearing", .name = "Суперслух", .carried = true,
     .text = "Суперслух: Супермен слышит шёпот за километр и стук сердца за стеной. Кого послушать?"},
    {.item = PASS, .id = "pass", .name = "Пресс-карта", .carried = true,
     .text = "Пресс-карта WGBS: «Кларк Кент, ведущий новостей». С ней пускают туда, куда зевак не пускают."},
    {.item = CABLE, .id = "cable", .name = "Кабель", .where = "lab",
     .text = "Толстый компьютерный кабель, метров десять. Крепче любой верёвки, если тянет Супермен."},
    {.item = VIAL, .id = "vial", .name = "Граната", .where = "lab",
     .text = "Пустая газовая граната. На донышке фиолетовый осадок. Кажется, он шевелится."},
    {.item = SPRAYER, .id = "sprayer", .name = "Распылитель",
     .text = "Ранец с антидотом из Крепости. Одна струя, и бактерии засыпают."},
    {.item = DRONE, .id = "drone", .name = "Дрон", .where = "red-room",
     .text = "Дрон Брэйниака размером с колоду карт. Жужжит и рвётся из пальцев. Хватит сил на один бросок."},
    {.item = CANISTER, .id = "canister", .name = "Баллон", .where = "command",
     .text = "Баллон с бактериями Брэйниака. Того, что внутри, хватит на целый город. Или на одну машину."},
};

static const struct StoryPage pages[] = {
    /* Act 1: the runaway train. */
    {.id = "start", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-clark",
     .text = "Восемь утра, жаркий июль. Кларк Кент едет в лаборатории S.T.A.R. снимать репортаж о "
             "компьютере «Звезда-7». Роберт Вирт проверяет звук, Эдди Чан бережёт камеру.\n"
             "Кларк раскрывает «Дейли Плэнет». За окном поля, но поезд то ускоряется, то замедляется. "
             "Лампы мигают. До станции ещё далеко.",
     .next = "train-stop"},
    {.id = "train-stop", .kind = STORY_DECISION, .location = "train", .camera = "train-show-clark",
     .text = "Поезд встаёт посреди поля, свет гаснет. Пассажиры ворчат. Кларк мог бы узнать, в чём "
             "дело: спросить кондуктора у тамбура или прислушаться к кабине. Можно и читать дальше. "
             "Для Супермена пока нет работы, а вокруг полно глаз.",
     .item_texts = {
         {.item = HEARING, .text = "Суперслух отделяет голоса машинистов от разговоров в вагоне. "
                                   "За дверью тамбура, через три вагона, обсуждают странную задержку. Что их тревожит?"},
         {.item = XRAY, .text = "Сквозь обшивку видны целые колёса, сцепки и кабина. Дыма или разбитых деталей нет. "
                                "Обычный осмотр не объясняет, почему погас свет и замер поезд."},
         {.item = HEAT, .text = "Вагон цел, двери свободны. Плавить здесь нечего: рядом люди, под потолком багаж. "
                                "Сначала стоит выяснить причину остановки."},
         {.item = BREATH, .text = "Поезд уже стоит. Ураган в тесном вагоне лишь сорвёт газеты и сбросит багаж "
                                  "на пассажиров. Кларк оставляет чашку на столе и смотрит в сторону тамбура."},
         {.item = PASS, .text = "Пресс-карта WGBS лежит в кармане пиджака. Она понадобится на проходной S.T.A.R.; "
                                "о задержке кондуктор ответит и обычному пассажиру."}},
     .choices = {{.label = "Читать газету дальше?", .anchor = "newspaper", .target = "train-lurch"},
                 {.label = "Переодеться в Супермена?", .anchor = "restroom-door", .target = "train-early"},
                 {.label = "Спросить о задержке?", .anchor = "vestibule", .target = "train-conductor"},
                 {.label = "Послушать кабину машиниста?", .anchor = "vestibule", .target = "train-hear",
                  .with = HEARING}}},
    {.id = "train-hear", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-clark",
     .text = "Кларк не опускает газету, но слышит обоих машинистов за три вагона.\n"
             "«После стрелочной станции управление чудит». — «Перезапусти. Может, отпустит».\n"
             "Они ещё не паникуют. Но задержка началась сразу за полем Райли, и обычной проверкой "
             "её объяснить не получается.",
     .next = "train-lurch"},
    {.id = "train-conductor", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-clark",
     .text = "«Техническая задержка, мистер Кент. Скоро поедем», — отвечает кондуктор от тамбура.\n"
             "Вирт поглядывает на часы: в S.T.A.R. их ждут утром. Чан предлагает снять репортаж о "
             "самой задержке. Кларк улыбается, но мигающие лампы его не успокаивают.",
     .next = "train-lurch"},
    {.id = "train-early", .kind = STORY_PASSAGE, .location = "train", .camera = "train-restroom-change",
     .text = "Кларк запирается в туалете и срывает галстук. Но за окном тишина: никакой беды, Супермену "
             "здесь делать нечего. Он застёгивает рубашку и, смутившись, идёт на место.\n"
             "«Быстро вы», — поднимает бровь Чан.",
     .next = "train-lurch"},
    {.id = "train-lurch", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-panic",
     .text = "Свет вспыхивает, поезд дёргается и катится дальше. Вирт облегчённо вздыхает. "
             "Но за окном мелькает заросшая ветка вместо главного пути.\n"
             "Скорость растёт. Кондуктор спешит к кабине и уже не повторяет, что всё в порядке.",
     .next = "train-panic"},
    {.id = "train-panic", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-panic",
     .text = "Треск! За окном летят деревянные щепки.\n"
             "«Мы снесли знак! Там было: мост разрушен!» — кричит пассажир. Чан поднимает камеру, "
             "Вирт вцепляется в сиденье. Из кабины доносится: «Тормоза не отвечают!»\n"
             "Теперь это работа для Супермена. Но все видят Кларка Кента.",
     .next = "train-decide"},
    {.id = "train-decide", .kind = STORY_DECISION, .location = "train", .camera = "train-show-panic",
     .text = "Вагон бросает из стороны в сторону, Чан снимает панику на камеру. До пропасти меньше "
             "минуты. Впереди тамбур, рядом дверь туалета. Кларку нужно исчезнуть так, чтобы никто "
             "не видел, кто появится вместо него. Резкий рывок поезда швыряет людей на сиденья.",
     .item_texts = {
         {.item = HEARING, .text = "Суперслух пробивается сквозь стук колёс. Из кабины слышны обрывки спора: "
                                   "стрелка, закрытая ветка, тормоза. Теперь машинисты говорят совсем другим голосом."},
         {.item = XRAY, .excludes = SAW_BRIDGE, .text = "Впереди три вагона закрывают путь от обычного взгляда. "
                                "Рентген позволит проверить мост и берега, пока Кларк ещё в вагоне."},
         {.item = XRAY, .requires = SAW_BRIDGE, .text = "За вагонами всё тот же провал и старые балки у путей. "
                                "Кларк уже знает, где оборван мост. Теперь нужно выбраться наружу незаметно."},
         {.item = HEAT, .text = "Луч прожжёт обшивку, но не остановит состав. Чан снимает проход: "
                                "вспышка из глаз Кларка попадёт в кадр вместе с ним самим."},
         {.item = BREATH, .text = "Чтобы плавно затормозить поезд встречным ветром, нужно оказаться перед тепловозом. "
                                  "Здесь выдох ударит в пассажиров и двери между вагонами."},
         {.item = PASS, .text = "На карточке имя Кларка Кента. Чан сейчас держит камеру наготове: "
                                "карточка не поможет объяснить, как её владелец превратился в Супермена."}},
     .choices = {{.label = "Скрыться в туалете?", .anchor = "restroom-door", .target = "restroom"},
                 {.label = "Переодеться прямо здесь?", .anchor = "aisle-clark", .target = "end-exposed"},
                 {.label = "Посмотреть вперёд сквозь вагоны?", .anchor = "vestibule", .target = "train-xray",
                  .with = XRAY, .excludes = SAW_BRIDGE},
                 {.label = "Послушать машинистов?", .anchor = "vestibule", .target = "train-hear-panic", .with = HEARING}}},
    {.id = "train-hear-panic", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-panic",
     .text = "«Стрелка сама перевела нас на закрытый путь!» — слышит Кларк. Второй машинист отвечает: "
             "«Тягу отключили. Тормозим — никакого толку!»\n"
             "Мотор больше не разгоняет поезд; его несёт по инерции. Исправлять двигатель поздно. "
             "Нужно спасать людей, не останавливая вагоны одним ударом.",
     .next = "train-decide"},
    {.id = "train-xray", .kind = STORY_PASSAGE, .location = "train", .camera = "gorge-xray-bridge",
     .sets = SAW_BRIDGE,
     .text = "Взгляд проходит сквозь вагоны и кабину. Впереди рельсы обрываются: от моста остался "
             "обломок фермы над ущельем. А на краю, у путей, сложены старые брёвна от прежнего моста. "
             "Из них можно кое-что построить.",
     .next = "train-decide"},
    {.id = "end-exposed", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "train",
     .camera = "train-exposed",
     .text = "Кларк срывает рубашку прямо в проходе, и через миг поезд стоит у края обрыва. Успел! Но Чан "
             "всё снял. Вечером вся страна видит, как репортёр Кент становится Суперменом. Мир спасён, а "
             "тайна нет."},
    {.id = "restroom", .kind = STORY_PASSAGE, .location = "train", .camera = "train-restroom-change",
     .text = "«Я на минутку!» Кларк запирает дверь туалета. Галстук, рубашка, а под ними синий костюм с "
             "алой буквой S. Окно не открывается. Супермен бережно выдавливает раму, оставляет её "
             "внутри и взмывает над крышей. На обратном пути придётся всё исправить.",
     .next = "gorge"},

    /* The gorge. */
    {.id = "gorge", .kind = STORY_CHECK, .fact = SAW_BRIDGE, .next = "gorge-plan", .otherwise = "gorge-decide"},
    {.id = "gorge-decide", .kind = STORY_DECISION, .location = "gorge", .camera = "gorge-show-train",
     .text = "Супермен летит рядом с тепловозом. До обрыва полкилометра, поезд несётся под сто двадцать. "
             "Внизу, в двадцати четырёх метрах, шумит река. Резкая остановка швырнёт людей вперёд. "
             "Можно замедлить поезд встречным ветром, поднять его или сначала осмотреть переправу.",
     .item_texts = {
         {.item = HEARING, .text = "Суперслух различает стук колёс и голоса в кабине. Мотор молчит. "
                                   "Стоит узнать, что машинисты уже пробовали, прежде чем хвататься за тепловоз."},
         {.item = XRAY, .text = "С воздуха видны остатки моста. Рентген поможет осмотреть старые опоры и балки "
                                "у путей: хватит ли материала для временной переправы?"},
         {.item = HEAT, .text = "Разрыв слишком широк, чтобы сварить оставшиеся рельсы: между ними нет металла. "
                                "Нужен пролёт или другой способ перенести поезд через ущелье."},
         {.item = BREATH, .text = "Перед тепловозом открытое место. Долгий, ровный выдох создаст встречный ветер "
                                  "и погасит скорость постепенно, без удара о стальное тело."},
         {.item = PASS, .text = "Пресс-карта осталась с одеждой Кларка в вагоне. Сейчас перед тепловозом "
                                "летит Супермен; машинистам нужна помощь, а не удостоверение репортёра."}},
     .choices = {{.label = "Упереться в тепловоз?", .anchor = "engine", .target = "end-headon"},
                 {.label = "Поднять весь поезд?", .anchor = "cars", .target = "gorge-lift"},
                 {.label = "Дунуть навстречу поезду?", .anchor = "engine", .target = "gorge-breath",
                  .with = BREATH},
                 {.label = "Послушать кабину?", .anchor = "engine", .target = "gorge-hear", .with = HEARING},
                 {.label = "Осмотреть переправу?", .anchor = "timber-pile", .target = "gorge-survey", .with = XRAY}}},
    {.id = "gorge-plan", .kind = STORY_DECISION, .location = "gorge", .camera = "gorge-show-train",
     .text = "Супермен летит рядом с тепловозом. До обрыва полкилометра. На краю лежат брёвна, которые он "
             "уже заметил. Из них получится временный пролёт. Резкая остановка опасна для пассажиров: "
             "лучше погасить скорость постепенно, перенести поезд или дать ему путь через ущелье.",
     .item_texts = {
         {.item = HEARING, .text = "Суперслух различает стук колёс и голоса в кабине. Мотор молчит. "
                                   "Стоит узнать, что машинисты уже пробовали, прежде чем хвататься за тепловоз."},
         {.item = XRAY, .text = "Старые балки и уцелевшие опоры уже осмотрены. Материала хватит на временный пролёт, "
                                "но старое дерево придётся поддержать, когда по нему пойдут вагоны."},
         {.item = HEAT, .text = "Разрыв слишком широк, чтобы сварить оставшиеся рельсы: между ними нет металла. "
                                "Нужен пролёт или другой способ перенести поезд через ущелье."},
         {.item = BREATH, .text = "Перед тепловозом открытое место. Долгий, ровный выдох создаст встречный ветер "
                                  "и погасит скорость постепенно, без удара о стальное тело."},
         {.item = PASS, .text = "Пресс-карта осталась с одеждой Кларка в вагоне. Сейчас перед тепловозом "
                                "летит Супермен; машинистам нужна помощь, а не удостоверение репортёра."}},
     .choices = {{.label = "Построить мост из брёвен?", .anchor = "timber-pile", .target = "gorge-bridge"},
                 {.label = "Упереться в тепловоз?", .anchor = "engine", .target = "end-headon"},
                 {.label = "Поднять весь поезд?", .anchor = "cars", .target = "gorge-lift"},
                 {.label = "Дунуть навстречу поезду?", .anchor = "engine", .target = "gorge-breath",
                  .with = BREATH},
                 {.label = "Послушать кабину?", .anchor = "engine", .target = "gorge-hear", .with = HEARING}}},
    {.id = "gorge-hear", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-show-train",
     .text = "Ветер не заглушает для Супермена слова из кабины.\n"
             "«Двигатель выключен! Ни основной тормоз, ни аварийный не срабатывает. Никогда такого не видел».\n"
             "Значит, дело не в заевшей ручке газа. Состав катится сам; остановить его нужно плавно "
             "или пронести над провалом.",
     .next = "gorge"},
    {.id = "gorge-survey", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-xray-bridge",
     .sets = SAW_BRIDGE,
     .text = "Супермен просматривает переправу насквозь. Уцелели береговые опоры; рядом сложены балки "
             "старого моста. Их хватит на временный путь.\n"
             "Но дерево старое. Даже работая на сверхскорости, придётся остаться под пролётом и "
             "поддерживать его, пока не пройдёт последний вагон.",
     .next = "gorge-plan"},
    {.id = "end-headon", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "gorge",
     .camera = "gorge-headon",
     .text = "Супермен упирается в тепловоз. Удар! Нос машины сминается, вагоны прыгают с рельсов. Поезд "
             "стоит в метре от обрыва, но людей бросило на сиденья, многих увозят в больницу. Сила без "
             "осторожности обошлась дорого."},
    {.id = "gorge-lift", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-lift-coupling",
     .text = "Супермен ныряет под тепловоз и поднимает его над рельсами. Вагоны тянутся следом, и вдруг "
             "суперслух ловит тонкий металлический треск. Сцепка за первым вагоном лопнула! "
             "Хвост поезда повис над обрывом. Сил поднять состав хватает; не выдержало железо.",
     .next = "gorge-coupling"},
    {.id = "gorge-coupling", .kind = STORY_DECISION, .location = "gorge", .camera = "gorge-lift-coupling",
     .text = "В руках тепловоз и первый вагон. Позади два вагона держатся на одном погнутом пальце "
             "сцепки, люди внутри кричат. Ещё рывок, и они сорвутся в ущелье.",
     .item_texts = {
         {.item = HEARING, .text = "Суперслух отделяет треск сцепки от криков пассажиров. Остаток пальца "
                                   "скрипит под нагрузкой: нужно сварить его сейчас или перехватить хвост поезда."},
         {.item = XRAY, .text = "Внутри сцепки видна трещина, но края ещё соприкасаются. Их можно сплавить. "
                                "Остальные сцепки целы; оторваться вот-вот могут два задних вагона."},
         {.item = HEAT, .text = "Тепловое зрение достанет до повреждённой сцепки, пока руки держат поезд. "
                                "Узкий луч сплавит края трещины; широкий прожжёт металл и ускорит падение."},
         {.item = BREATH, .text = "Висящие вагоны раскачаются от сильной струи воздуха. Тормозить ветер уже "
                                  "нечего: сейчас нужно восстановить сцепку или поддержать вагоны снизу."},
         {.item = PASS, .text = "Пресс-карта в оставленном пиджаке, а обе руки Супермена заняты поездом. "
                                "Здесь важны несколько секунд и треснувшая сцепка."}},
     .choices = {{.label = "Перехватить задние вагоны?", .anchor = "rear-cars", .target = "gorge-catch"},
                 {.label = "Сварить сцепку взглядом?", .anchor = "coupling", .target = "gorge-weld",
                  .with = HEAT}}},
    {.id = "gorge-weld", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-weld",
     .text = "Два тонких красных луча упираются в сцепку. Металл светлеет, течёт и схватывается. Вагоны "
             "выравниваются. Супермен проносит поезд над ущельем и мягко ставит колёса на рельсы.",
     .next = "gorge-saved"},
    {.id = "gorge-catch", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-lift-coupling",
     .text = "Супермен переносит тепловоз через пропасть, бросает его на рельсы и ныряет назад. Задние "
             "вагоны срываются, но он ловит их у самой воды. Неуклюже, с синяками, зато все живы.",
     .next = "gorge-saved"},
    {.id = "gorge-bridge", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-hold-span",
     .text = "Брёвна летят через пропасть: балка, вторая, третья, сверху рельсы. Старое дерево трещит, и "
             "Супермен сам встаёт под пролёт. Он держит мост на плечах, пока тепловоз переползает на тот "
             "берег.",
     .next = "gorge-saved"},
    {.id = "gorge-breath", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-breath",
     .text = "Супермен разворачивается к тепловозу и дует. Встречный ветер воет, гравий летит из-под "
             "колёс. Поезд замедляется и встаёт, когда передние колёса уже над пустотой.",
     .next = "gorge-tow"},
    {.id = "gorge-tow", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-breath",
     .text = "Состав замер перед провалом. Супермен убеждается, что вагоны больше не катятся, "
             "и просит машинистов вызвать помощь.\n"
             "Теперь обратно: через то же окно, пока Чан снимает ущелье. Рама встаёт на место, "
             "рубашка скрывает щит. Кларку осталось объяснить своё отсутствие.",
     .next = "train-return"},
    {.id = "gorge-saved", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-saved",
     .text = "Поезд стоит по ту сторону пропасти. Пассажиры прилипли к окнам и хлопают. "
             "Супермен машет, проверяет, что людям не нужна помощь, и скрывается за последним вагоном.\n"
             "Он возвращается через окно туалета, ставит раму на место и прячет костюм под рубашкой. "
             "Чан не должен заметить ни одной детали.",
     .next = "train-return"},
    {.id = "train-return", .kind = STORY_DECISION, .location = "train", .camera = "train-show-clark",
     .text = "«Где вы были? — Чан поворачивается к Кларку. — Супермен спас поезд, а вы всё пропустили!»\n"
             "Вирт включает диктофон: нужны слова для выпуска WGBS. Кларк берёт газету, пряча улыбку. "
             "Объяснить отсутствие укачиванием или сразу записать рассказ очевидцев?",
     .item_texts = {
         {.item = HEARING, .text = "Суперслух больше не ловит треска металла. В кабине вызывают буксир, "
                                   "пассажиры обсуждают спасение. Вирт рядом ждёт рассказа Кларка для WGBS."},
         {.item = XRAY, .text = "Крепления оконной рамы на месте. За стеной туалета не осталось ни "
                                "обломков, ни костюма. Обычный осмотр не выдаст обратный путь Супермена."},
         {.item = HEAT, .text = "Супермен уже закрепил раму перед возвращением. Теперь луч из глаз "
                                "Кларка лишь даст Чану новый, гораздо более сенсационный сюжет."},
         {.item = BREATH, .text = "Поезд надёжно остановлен. В вагоне снова слышны разговоры, "
                                  "и Кларк переводит дыхание. Здесь нужен спокойный ответ коллегам."},
         {.item = PASS, .text = "Пресс-карта снова в кармане Кларка. До S.T.A.R. он доберётся репортёром WGBS, "
                                "но сначала коллеги ждут от него объяснения и материала для новостей."}},
     .choices = {{.label = "Сослаться на укачивание?", .anchor = "seated-clark", .target = "train-alibi"},
                 {.label = "Записать репортаж?", .anchor = "newspaper", .target = "train-report"}}},
    {.id = "train-alibi", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-clark",
     .text = "«От этих рывков меня укачало», — говорит Кларк.\n"
             "Чан сочувственно кивает: «Тогда хорошо, что не видели пропасть». Вирт выключает "
             "диктофон. Кларк спрашивает о пассажирах, а коллеги наперебой рассказывают, как "
             "появился Супермен. Никто уже не спрашивает, как исчез Кент.",
     .next = "train-haul"},
    {.id = "train-report", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-clark",
     .text = "«Простите, укачало. Расскажите, что случилось», — просит Кларк. Чан показывает запись, "
             "Вирт даёт звук, пассажиры добавляют подробности.\n"
             "Кларк диктует для WGBS: закрытая ветка, отказ тормозов, спасённый поезд. Вместо догадок "
             "о причине он записывает вопрос к железной дороге: почему отказало всё сразу?",
     .next = "train-haul"},
    {.id = "train-haul", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-clark",
     .text = "Приходит старый маневровый тепловоз. Его простое управление работает без сбоев: "
             "состав медленно тянут в обход к станции возле S.T.A.R.\n"
             "Кларк смотрит на устойчивый свет под потолком. Одна машина отказала, другая — нет. "
             "Пока это лишь странная подробность. Впереди ещё репортаж о компьютере.",
     .next = "star-gate"},

    /* Act 2: S.T.A.R. Labs. */
    {.id = "star-gate", .kind = STORY_DECISION, .location = "gate", .camera = "star-show-gate",
     .text = "Лаборатории S.T.A.R. стоят на холме: пять этажей стекла. У дверей два охранника. Вирт и Чан "
             "показывают удостоверения. Охранник смотрит на Кларка. Пресс-карта у него где-то в кармане.",
     .choices = {{.label = "Показать пресс-карту?", .anchor = "guard", .target = "star-arrive", .with = PASS},
                 {.label = "Пройти мимо охраны?", .anchor = "gate-door", .target = "end-gate"}}},
    {.id = "end-gate", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "gate",
     .camera = "star-show-gate",
     .text = "Кларк Кент не Супермен, чтобы проходить сквозь охрану. Его крепко берут под локти и выводят "
             "за ворота. Через час в лабораториях что-то случается, и никто не знает что. А ведь хватило "
             "бы одной карточки."},
    {.id = "star-arrive", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-show-room",
     .removes = PASS,
     .text = "Охранник оставляет пресс-карту у себя до вечера. Наверху их встречает говорун Норман "
             "Рафферти. В хромированном зале гудит «Звезда-7», компьютер, который учится, как человек.",
     .next = "star-interview"},
    {.id = "star-interview", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-show-vent",
     .text = "«Четыре миллиарда таких машин, и люди станут не нужны! — хохочет Рафферти в камеру. — "
             "Шучу, конечно».\n"
             "Кларк чует сладкий запах. Из решётки у пола ползёт фиолетовая струйка.",
     .next = "star-decide"},
    {.id = "star-decide", .kind = STORY_DECISION, .location = "lab", .camera = "star-show-vent",
     .text = "Струйка густеет. Никто её не замечает: Рафферти говорит, Вирт снимает. Сладкий запах — это "
             "газ. А под полом, кажется, что-то скребётся.",
     .choices = {{.label = "Предупредить Рафферти?", .anchor = "rafferty-spot", .target = "star-rafferty"},
                 {.label = "Притвориться спящим?", .anchor = "clark-spot", .target = "star-gas"},
                 {.label = "Встать на люки?", .anchor = "floor-panels", .target = "star-pin",
                  .requires = SAW_MERCS},
                 {.label = "Задуть газ обратно?", .anchor = "vent", .target = "star-blowback", .with = BREATH},
                 {.label = "Заглянуть под пол?", .anchor = "floor-panels", .target = "star-xray-floor",
                  .with = XRAY, .excludes = SAW_MERCS}}},
    {.id = "star-xray-floor", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-xray-floor",
     .sets = SAW_MERCS,
     .text = "Пол становится прозрачным. Под панелями, среди кабелей, ползут трое в масках. Они "
             "подбираются к трём люкам перед «Звездой-7». Газ усыпит зал, и тогда они вылезут.",
     .next = "star-decide"},
    {.id = "star-rafferty", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-show-vent",
     .text = "«Мистер Рафферти, из вентиляции идёт дым!»\n"
             "«Новый освежитель воздуха, мистер Кент!» Рафферти отмахивается, говорит дальше и вдруг "
             "зевает посреди фразы.",
     .next = "star-gas"},
    {.id = "star-gas", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-gas",
     .text = "Фиолетовый туман ползёт по полу. Техники клюют носом, Рафферти оседает. Кларк тоже падает, "
             "подальше от камеры. Сквозь ресницы он видит, как поднимаются три панели пола.",
     .next = "star-mercs"},
    {.id = "star-blowback", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-blowback",
     .text = "Кларк будто кашляет и дует в решётку. Газ уходит обратно в трубы, техники чихают, но не "
             "спят. Тут поднимаются три панели пола, и из люков лезут люди в масках: «Всем на пол!»",
     .next = "star-mercs"},
    {.id = "star-pin", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-caught",
     .sets = MERCS_CAUGHT,
     .text = "«Я за водой!» Кларк выскальзывает за дверь, и в зал влетает Супермен. Он встаёт прямо на "
             "люки. Снизу толкают, ругаются, без толку. Потом он вытаскивает налётчиков по одному.",
     .next = "star-after"},
    {.id = "star-mercs", .kind = STORY_DECISION, .location = "lab", .camera = "star-show-mercs",
     .text = "Кларк исчез за пультом, и перед налётчиками стоит Супермен. Бородатый поднимает пистолет: "
             "«Шаг, и мы стреляем. Не в тебя». У люка валяется моток кабеля.",
     .choices = {{.label = "Взять кабель?", .anchor = "cable", .target = "star-cable", .take = CABLE},
                 {.label = "Отпустить их?", .anchor = "panel-hole", .target = "star-letgo"},
                 {.label = "Связать их кабелем?", .anchor = "mercs-group", .target = "star-lasso", .with = CABLE},
                 {.label = "Расплавить пистолеты?", .anchor = "mercs-group", .target = "star-melt",
                  .with = HEAT}}},
    {.id = "star-cable", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-show-mercs",
     .text = "Супермен поддевает моток носком сапога и ловит его рукой. Налётчики переглядываются: что он "
             "задумал? Бородатый крепче сжимает пистолет.",
     .next = "star-mercs"},
    {.id = "star-lasso", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-caught",
     .sets = MERCS_CAUGHT, .removes = CABLE,
     .text = "Кабель свистит, как лассо. Три петли, и налётчики стоят спина к спине, а пистолеты звякают "
             "об пол. «Нас наняли, — бормочет бородатый. — Голос по радио, будто из железной бочки».",
     .next = "star-after"},
    {.id = "star-melt", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-caught",
     .sets = MERCS_CAUGHT,
     .text = "Взгляд вспыхивает красным, пистолеты раскаляются, и налётчики с воплями их бросают. Пока они "
             "дуют на пальцы, Супермен связывает их проводами. «Нас наняли, — хрипит бородатый. — Голос "
             "по радио, как из бочки».",
     .next = "star-after"},
    {.id = "star-letgo", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-show-mercs",
     .text = "Супермен отступает, и налётчики ныряют в люк. Позже их найдут у сломанной машины на поле "
             "Райли. Заказчик, обещавший им деньги, так и не пришёл.",
     .next = "star-after"},
    {.id = "star-after", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-show-sample",
     .removes = CABLE,
     .text = "Люди трут глаза. Рафферти машет журналом: «Они хотели украсть это? Его же печатают в "
             "газетах!» Кража была для отвода глаз. А «Звезда-7» мигает красным, будто в ней что-то живое.",
     .next = "star-sample"},
    {.id = "star-sample", .kind = STORY_DECISION, .location = "lab", .camera = "star-show-sample",
     .text = "У решётки валяется пустая газовая граната с фиолетовым осадком. Газ был не для людей, а для "
             "машины. Вирт зовёт Кларка: пора в студию, к одиннадцатичасовому эфиру.",
     .choices = {{.label = "Взять гранату?", .anchor = "vial", .target = "star-took-vial", .take = VIAL},
                 {.label = "Лететь в Крепость?", .anchor = "east-window", .target = "fortress"},
                 {.label = "Ехать на эфир?", .anchor = "crew", .target = "end-newscast"}}},
    {.id = "star-took-vial", .kind = STORY_PASSAGE, .location = "lab", .camera = "star-show-sample",
     .text = "Кларк прячет гранату в карман. В Крепости Одиночества есть компьютер, который разберётся с "
             "этим осадком. «Мне нужно позвонить», — говорит он и выходит. Над холмом проносится синяя "
             "молния.",
     .next = "fortress"},
    {.id = "end-newscast", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "lab",
     .camera = "star-leave-crew",
     .text = "В одиннадцать Кларк читает новости о странном налёте. К вечеру в Метрополисе сходят с ума "
             "светофоры, банкоматы и поезда. Кто-то в небе доволен. Кларк был рядом с разгадкой и уехал."},

    /* Act 3: the Fortress and the belt. */
    {.id = "fortress", .kind = STORY_PASSAGE, .location = "fortress", .camera = "fortress-show-door",
     .text = "Арктика. Супермен поднимает ключ, который не сдвинет никто другой, и отпирает дверь в "
             "ледяной скале. Внутри Крепость Одиночества: трофеи, хрусталь и компьютер, который не "
             "ошибается.",
     .next = "fortress-lab"},
    {.id = "fortress-lab", .kind = STORY_DECISION, .location = "fortress", .camera = "fortress-show-computer",
     .text = "Компьютер гудит так низко, что ухо этого не слышит. На экране карта мира, и на ней мигают "
             "огоньки: поле Райли, Токио, Саудовская Аравия. Метеориты. Все упали сегодня.",
     .choices = {{.label = "Посмотреть на экран?", .anchor = "screen", .target = "fortress-alarm"},
                 {.label = "Дать компьютеру пробу?", .anchor = "computer", .target = "fortress-analysis",
                  .with = VIAL}}},
    {.id = "fortress-analysis", .kind = STORY_PASSAGE, .location = "fortress", .camera = "fortress-analysis",
     .removes = VIAL, .gives = SPRAYER,
     .text = "Под увеличением осадок оживает: крошечные машины на паучьих ножках. Они вгрызаются в "
             "электронику и растут. Такую форму делает лишь один мастер — Брэйниак. Из люка выезжает ранец "
             "с антидотом.",
     .next = "fortress-alarm"},
    {.id = "fortress-alarm", .kind = STORY_PASSAGE, .location = "fortress", .camera = "fortress-alarm",
     .text = "Экран вспыхивает красным. Над Землёй кружит пояс метеоритов, и один уже падает на Англию. "
             "В каждом камне бактерии. Брэйниак не бомбит планету. Он её засевает.",
     .next = "orbit-decide"},
    {.id = "orbit-decide", .kind = STORY_DECISION, .location = "orbit", .camera = "orbit-show-belt",
     .text = "Супермен висит среди кувыркающихся камней. Внизу синеет океан. Среди бурых метеоритов один "
             "серый и тусклый, как слиток. Если разбивать их по одному, то с какого начать?",
     .choices = {{.label = "Вернуться на Землю?", .anchor = "earth", .target = "end-meteors"},
                 {.label = "Просветить камни?", .anchor = "belt", .target = "orbit-xray", .with = XRAY,
                  .excludes = LEAD_FOUND},
                 {.label = "Сжечь метеориты по очереди?", .anchor = "belt", .target = "orbit-ambush",
                  .with = HEAT, .excludes = LEAD_FOUND},
                 {.label = "Сжечь серый камень?", .anchor = "lead-rock", .target = "orbit-clear", .with = HEAT,
                  .requires = LEAD_FOUND}}},
    {.id = "orbit-xray", .kind = STORY_PASSAGE, .location = "orbit", .camera = "orbit-xray",
     .sets = LEAD_FOUND,
     .text = "Камни бледнеют, как стекло, и в каждом видны фиолетовые капсулы. Только серый остаётся "
             "чёрным: свинец. Что-то в нём не хотят показывать рентгену. Это не метеорит. Это ловушка.",
     .next = "orbit-decide"},
    {.id = "orbit-ambush", .kind = STORY_PASSAGE, .location = "orbit", .camera = "orbit-ambush",
     .text = "Первый камень рассыпается, второй, третий. И тут серый камень раскрывается, как раковина. "
             "Красный луч бьёт Супермену в грудь, и он кувыркается вниз, к огромному кораблю над "
             "Метрополисом.",
     .next = "red-beam"},
    {.id = "orbit-clear", .kind = STORY_PASSAGE, .location = "orbit", .camera = "orbit-clear",
     .text = "Луч бьёт в серый камень, свинец лопается, внутри искрит разбитый излучатель. Остальные "
             "метеориты сгорают в атмосфере огненными нитями. А внизу Кларка ждёт Лана: сегодня Звёздная "
             "ночь.",
     .next = "observatory"},
    {.id = "end-meteors", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "orbit",
     .camera = "orbit-falling",
     .text = "Внизу столько бед, нужно помогать! Супермен ныряет к Земле, а пояс остаётся над головой. К "
             "ночи камни падают на Лондон, Сан-Франциско, Сидней, и в каждом городе гаснет свет."},

    /* Act 4: the Star Watch and Brainiac's ship. */
    {.id = "observatory", .kind = STORY_PASSAGE, .location = "observatory", .camera = "obs-show-lana",
     .text = "Вечер на горе Ройал: телескопы на лужайке, пары на скамейках. Лана Лэнг берёт Кларка под "
             "руку: «Смотри, падающая звезда! Загадай желание». Кларк хмурится. Звёзды не тормозят.",
     .next = "obs-decide"},
    {.id = "obs-decide", .kind = STORY_DECISION, .location = "observatory", .camera = "obs-show-ship",
     .text = "Над городом висит корабль: череп с щупальцами. Голос гремит над холмом: «Супермен! "
             "Сдавайся, или Земля умрёт». Люди бегут, кто-то падает у телескопов.",
     .choices = {{.label = "Успокоить толпу?", .anchor = "crowd-spot", .target = "obs-calm"},
                 {.label = "Сразу лететь к кораблю?", .anchor = "ship-spot", .target = "ship-fight"},
                 {.label = "Просветить корабль?", .anchor = "ship-spot", .target = "obs-xray", .with = XRAY,
                  .excludes = SAW_AIRLOCK}}},
    {.id = "obs-xray", .kind = STORY_PASSAGE, .location = "observatory", .camera = "ship-show-belly",
     .sets = SAW_AIRLOCK,
     .text = "Под днищем корабля шлюз, а над ним комната с огромным красным шаром. Красное солнце! Его "
             "луч отнимет у Супермена силы. К шлюзу нельзя подлетать, его надо выжечь издалека.",
     .next = "obs-decide"},
    {.id = "obs-calm", .kind = STORY_PASSAGE, .location = "observatory", .camera = "obs-calm",
     .text = "Кларк вскакивает на скамейку: «Спокойно! Отходите к обсерватории, не бегите!» Люди "
             "останавливаются. Лана изумлена: тихоня Кент командует толпой. А потом он исчезает.",
     .next = "ship-fight"},
    {.id = "ship-fight", .kind = STORY_DECISION, .location = "sky", .camera = "ship-show-tentacles",
     .text = "Щупальце обвивает Супермена, другие хлещут воздух. Шлюз под днищем наливается красным. "
             "«Иди ко мне, ангел смерти», — гудит Брэйниак из динамиков.",
     .choices = {{.label = "Сдаться?", .anchor = "airlock", .target = "red-beam"},
                 {.label = "Рвать щупальца?", .anchor = "tentacles", .target = "ship-tentacles"},
                 {.label = "Улететь от корабля?", .anchor = "down-city", .target = "end-starbolts"},
                 {.label = "Выжечь излучатель?", .anchor = "airlock", .target = "ship-breach", .with = HEAT,
                  .requires = SAW_AIRLOCK}}},
    {.id = "ship-tentacles", .kind = STORY_PASSAGE, .location = "sky", .camera = "ship-tentacles",
     .text = "Супермен рвёт щупальце, как канат, обрывок падает в реку. Второе, третье! Но корабль "
             "терпелив. Шлюз разворачивается к Супермену, и красный свет заливает всё вокруг.",
     .next = "red-beam"},
    {.id = "ship-breach", .kind = STORY_PASSAGE, .location = "sky", .camera = "ship-breach",
     .text = "Супермен не подлетает к шлюзу. Он бьёт взглядом издалека, и излучатель взрывается, не "
             "успев зажечься. Потом Супермен прожигает в обшивке дыру и ныряет прямо в рубку.",
     .next = "command"},
    {.id = "end-starbolts", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "sky",
     .camera = "ship-starbolts",
     .text = "Супермен уводит бой подальше от холма. Но Брэйниаку не нужен бой: пушки корабля бьют по "
             "набережной, и башни горят одна за другой. «Ты выбрал бегство, — гремит голос. — Смотри, чего "
             "оно стоит»."},
    {.id = "red-beam", .kind = STORY_PASSAGE, .location = "sky", .camera = "ship-red-beam",
     .removes = HEAT | BREATH,
     .text = "Красный луч хлещет из шлюза. Боль! Силы утекают, как вода из ведра. Супермена тянет вверх, "
             "и створки захлопываются под ним. Под красным солнцем остались лишь зрение и слух.",
     .next = "red-brainiac"},
    {.id = "red-brainiac", .kind = STORY_PASSAGE, .location = "red-room", .camera = "red-show-brainiac",
     .text = "Он висит в столбе красного света. Скрипят когти: входит Брэйниак с баллоном. «Мои бактерии. "
             "Новая жизнь, моя жизнь». Он ставит баллон на подставку и уходит засевать Землю.",
     .next = "red-decide"},
    {.id = "red-decide", .kind = STORY_DECISION, .location = "red-room", .camera = "red-show-room",
     .text = "Пальцы двигаются на сантиметр за раз. Дроны кружат рядом, один почти у ладони. Шар гудит "
             "под потолком, в углу ниша за свинцовой дверью. На подставке баллон с тонким соплом.",
     .choices = {{.label = "Поймать дрон?", .anchor = "drone", .target = "red-catch", .take = DRONE},
                 {.label = "Ждать?", .anchor = "globe", .target = "end-drain"},
                 {.label = "Бросить дрон в шар?", .anchor = "globe", .target = "red-globe", .with = DRONE},
                 {.label = "Сбить сопло баллона?", .anchor = "stand-canister", .target = "red-escape",
                  .with = DRONE},
                 {.label = "Заглянуть за дверь?", .anchor = "vault", .target = "red-vault-xray", .with = XRAY}}},
    {.id = "red-catch", .kind = STORY_PASSAGE, .location = "red-room", .camera = "red-catch",
     .text = "Рывок, и дрон в кулаке. Он жужжит и бьётся, как пойманный шмель. Сил хватит только на один "
             "бросок. Куда его бросить, чтобы не зря?",
     .next = "red-decide"},
    {.id = "red-vault-xray", .kind = STORY_PASSAGE, .location = "red-room", .camera = "red-show-room",
     .text = "Рентген скользит сквозь пульты и трубы и упирается в дверь ниши. Свинец, как у ловушки на "
             "орбите. Брэйниак прячет за свинцом то, к чему Супермену лучше не подходить.",
     .next = "red-decide"},
    {.id = "red-globe", .kind = STORY_PASSAGE, .location = "red-room", .camera = "red-show-room",
     .removes = DRONE,
     .text = "Дрон бьётся о красный шар, как муха о стекло. Шар даже не мигнул: он толще брони. Другие дроны "
             "держатся подальше. А под потолком уже гудят, выдвигаясь, пушки.",
     .next = "end-drain"},
    {.id = "end-drain", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "red-room",
     .camera = "red-drain",
     .text = "Четыре пушки бьют в Супермена белыми лучами, и его сила утекает в двигатели корабля. "
             "«Спасибо за энергию», — говорит Брэйниак. Земля на экране всё меньше. Нужно было действовать."},
    {.id = "red-escape", .kind = STORY_PASSAGE, .location = "red-room", .camera = "red-chaos",
     .removes = DRONE, .gives = HEAT | BREATH,
     .text = "Дрон бьёт по соплу. Шипение! Облако бактерий вырывается прямо в машины. Дроны падают, экраны "
             "несут чепуху, красный шар гаснет. Сила возвращается горячей волной, и Супермен встаёт.",
     .next = "red-free"},
    {.id = "red-free", .kind = STORY_DECISION, .location = "red-room", .camera = "red-show-free",
     .text = "Горит только аварийный свет. Супермен снова Супермен. Лифт ведёт наверх, в рубку, где "
             "Брэйниак засевает Землю. Свинцовая дверь в углу манит. А можно пробить стену и вырваться.",
     .choices = {{.label = "Открыть свинцовую дверь?", .anchor = "vault", .target = "end-kryptonite"},
                 {.label = "Подняться на лифте?", .anchor = "elevator", .target = "command"},
                 {.label = "Пробить обшивку?", .anchor = "hull-wall", .target = "end-leave"}}},
    {.id = "end-kryptonite", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "red-room",
     .camera = "red-kryptonite",
     .text = "Супермен срывает свинцовую дверь, и из ниши льётся зелёный свет. Криптонит! Ноги "
             "подгибаются. Ловушка ждала его, и он сам её открыл. Брэйниак спускается не спеша."},
    {.id = "end-leave", .kind = STORY_ENDING, .ending = ENDING_PARTIAL, .location = "red-room",
     .camera = "orbit-ship-escapes",
     .text = "Супермен вырывается в ночное небо. Корабль вздрагивает, втягивает щупальца и уходит за Луну. "
             "Брэйниак жив, его бактерии ждут в баллонах. Земля спасена сегодня, но он вернётся."},
    {.id = "command", .kind = STORY_PASSAGE, .location = "command", .camera = "cmd-show-brainiac",
     .text = "Рубка. Брэйниак сидит в кресле, пальцы в гнёздах управления. На экране Земля, а насосы "
             "гонят из баков фиолетовую жижу к соплам под днищем. У стены стойка с баллонами.",
     .next = "cmd-decide"},
    {.id = "cmd-decide", .kind = STORY_DECISION, .location = "command", .camera = "cmd-show-brainiac",
     .text = "Брэйниак не встаёт: в ближнем бою он слаб. Но если его разбить, его разум сбежит в космос и "
             "однажды вернётся. Насосы стучат, засевая Землю.",
     .choices = {{.label = "Взять баллон?", .anchor = "canister", .target = "cmd-took", .take = CANISTER},
                 {.label = "Разбить Брэйниака?", .anchor = "brainiac-throne", .target = "end-essence"},
                 {.label = "Залить антидот в баки?", .anchor = "seeding-tanks", .target = "cmd-spray",
                  .with = SPRAYER, .excludes = SEEDING_STOPPED},
                 {.label = "Впрыснуть ему бактерии?", .anchor = "brainiac-throne", .target = "cmd-trap",
                  .with = CANISTER}}},
    {.id = "cmd-spray", .kind = STORY_PASSAGE, .location = "command", .camera = "cmd-spray",
     .sets = SEEDING_STOPPED, .removes = SPRAYER,
     .text = "Супермен вскрывает горловину бака и пускает струю антидота. Жижа бледнеет и замирает: "
             "бактерии уснули. Насосы качают пустую воду. «Что ты сделал?!» — дёргается Брэйниак.",
     .next = "cmd-decide"},
    {.id = "cmd-took", .kind = STORY_PASSAGE, .location = "command", .camera = "cmd-show-brainiac",
     .text = "Супермен снимает со стойки тяжёлый баллон. Брэйниак впервые за весь день замолкает. Он "
             "слишком хорошо знает, что внутри.",
     .next = "cmd-decide"},
    {.id = "cmd-trap", .kind = STORY_CHECK, .fact = SEEDING_STOPPED, .next = "end-victory",
     .otherwise = "end-frozen"},
    {.id = "end-essence", .kind = STORY_ENDING, .ending = ENDING_PARTIAL, .location = "command",
     .camera = "cmd-essence",
     .text = "Один удар, и панцирь трескается. Из черепа вырывается светящийся клубок — разум Брэйниака. "
             "Он уходит сквозь купол к звёздам. Корабль мёртв, но где-то далеко Брэйниак уже собирает себя."},
    {.id = "end-frozen", .kind = STORY_ENDING, .ending = ENDING_PARTIAL, .location = "command",
     .camera = "cmd-frozen",
     .text = "Супермен вгоняет сопло в трещину панциря, и Брэйниак застывает, запертый в своих бактериях. "
             "Но насосы успели: над Землёй плывут фиолетовые облака. Если бы залить баки антидотом…"},
    {.id = "end-victory", .kind = STORY_ENDING, .ending = ENDING_SUCCESS, .location = "command",
     .camera = "cmd-victory",
     .text = "Сопло входит в трещину панциря, и бактерии заполняют машину. Брэйниак скрипит и замирает, "
             "запертый в своём творении. Земля чиста. Утром Кларк сдаст статью и, может, успеет к Лане."},
};

static const struct Story countdown = {
    .name = "countdown",
    .start = "start",
    .continue_label = "Дальше",
    .retry_label = "Попробовать снова",
    .restart_label = "Начать сначала",
    .pages = pages,
    .page_count = sizeof(pages) / sizeof(pages[0]),
    .items = items,
    .item_count = sizeof(items) / sizeof(items[0]),
};

const struct Story *book_story(void) { return &countdown; }
