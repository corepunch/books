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
             "новом компьютере «Звезда-7». С ним операторы WGBS, Вирт и Чан.\n"
             "Поезд то разгоняется, то сбавляет ход. Лампы под потолком мигают.",
     .next = "train-stop"},
    {.id = "train-stop", .kind = STORY_DECISION, .location = "train", .camera = "train-show-clark",
     .text = "Поезд встаёт посреди поля, свет гаснет. Пассажиры ворчат. Кларк мог бы узнать, в чём "
             "дело, но вокруг полно глаз, а Чан не выпускает камеру из рук.",
     .choices = {{.label = "Читать газету дальше?", .anchor = "newspaper", .target = "train-lurch"},
                 {.label = "Переодеться в Супермена?", .anchor = "restroom-door", .target = "train-early"},
                 {.label = "Послушать кабину машиниста?", .anchor = "vestibule", .target = "train-hear",
                  .with = HEARING}}},
    {.id = "train-hear", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-clark",
     .text = "Сквозь гул Кларк слышит голоса в кабине, за три вагона.\n"
             "«Стрелка у поля Райли перекинула нас на старую ветку, — бормочет машинист. — А тормоза "
             "не отвечают. Чертовщина какая-то».",
     .next = "train-lurch"},
    {.id = "train-early", .kind = STORY_PASSAGE, .location = "train", .camera = "train-restroom-change",
     .text = "Кларк запирается в туалете и срывает галстук. Но за окном тишина: никакой беды, Супермену "
             "здесь делать нечего. Он застёгивает рубашку и, смутившись, идёт на место.\n"
             "«Быстро вы», — поднимает бровь Чан.",
     .next = "train-lurch"},
    {.id = "train-lurch", .kind = STORY_PASSAGE, .location = "train", .camera = "train-show-panic",
     .text = "Свет вспыхивает, и поезд срывается с места. Он мчится всё быстрее по заросшей ветке. "
             "Кондуктор бежит к кабине: «Тормоза отказали!»\n"
             "Кто-то кричит: «Мы снесли знак! Там было написано: мост разрушен!»",
     .next = "train-decide"},
    {.id = "train-decide", .kind = STORY_DECISION, .location = "train", .camera = "train-show-panic",
     .text = "Вагон бросает из стороны в сторону, Чан снимает панику на камеру. До пропасти меньше "
             "минуты. Кларку нужно исчезнуть так, чтобы никто не видел, кто появится вместо него.",
     .choices = {{.label = "Скрыться в туалете?", .anchor = "restroom-door", .target = "restroom"},
                 {.label = "Переодеться прямо здесь?", .anchor = "aisle-clark", .target = "end-exposed"},
                 {.label = "Посмотреть вперёд сквозь вагоны?", .anchor = "vestibule", .target = "train-xray",
                  .with = XRAY, .excludes = SAW_BRIDGE}}},
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
             "алой буквой S. Окно не открывается. Супермен выдавливает раму и взмывает над крышей вагона.",
     .next = "gorge"},

    /* The gorge. */
    {.id = "gorge", .kind = STORY_CHECK, .fact = SAW_BRIDGE, .next = "gorge-plan", .otherwise = "gorge-decide"},
    {.id = "gorge-decide", .kind = STORY_DECISION, .location = "gorge", .camera = "gorge-show-train",
     .text = "Супермен летит рядом с тепловозом. До обрыва полкилометра, поезд несётся под сто двадцать. "
             "Внизу, на глубине двадцати метров, шумит река. Остановить состав или поднять его в воздух?",
     .choices = {{.label = "Упереться в тепловоз?", .anchor = "engine", .target = "end-headon"},
                 {.label = "Поднять весь поезд?", .anchor = "cars", .target = "gorge-lift"},
                 {.label = "Дунуть навстречу поезду?", .anchor = "engine", .target = "gorge-breath",
                  .with = BREATH}}},
    {.id = "gorge-plan", .kind = STORY_DECISION, .location = "gorge", .camera = "gorge-show-train",
     .text = "Супермен летит рядом с тепловозом. До обрыва полкилометра. На краю лежат брёвна, которые он "
             "заметил из вагона. Если строить, то сейчас. Или остановить состав, или поднять в воздух?",
     .choices = {{.label = "Построить мост из брёвен?", .anchor = "timber-pile", .target = "gorge-bridge"},
                 {.label = "Упереться в тепловоз?", .anchor = "engine", .target = "end-headon"},
                 {.label = "Поднять весь поезд?", .anchor = "cars", .target = "gorge-lift"},
                 {.label = "Дунуть навстречу поезду?", .anchor = "engine", .target = "gorge-breath",
                  .with = BREATH}}},
    {.id = "end-headon", .kind = STORY_ENDING, .ending = ENDING_FAILURE, .location = "gorge",
     .camera = "gorge-headon",
     .text = "Супермен упирается в тепловоз. Удар! Нос машины сминается, вагоны прыгают с рельсов. Поезд "
             "стоит в метре от обрыва, но людей бросило на сиденья, многих увозят в больницу. Сила без "
             "осторожности обошлась дорого."},
    {.id = "gorge-lift", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-lift-coupling",
     .text = "Супермен ныряет под тепловоз и поднимает его над рельсами. Вагоны тянутся следом, и вдруг "
             "раздаётся скрежет. Сцепка за первым вагоном лопнула! Хвост поезда повис над обрывом.",
     .next = "gorge-coupling"},
    {.id = "gorge-coupling", .kind = STORY_DECISION, .location = "gorge", .camera = "gorge-lift-coupling",
     .text = "В руках тепловоз и первый вагон. Позади два вагона держатся на одном погнутом пальце "
             "сцепки, люди внутри кричат. Ещё рывок, и они сорвутся в ущелье.",
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
     .text = "Через полчаса по старой ветке приползает маневровый тепловоз и тянет поезд в обход, к "
             "лабораториям. Кларк сидит в вагоне, будто никуда не уходил.\n"
             "«Вы опять всё пропустили», — вздыхает Чан.",
     .next = "star-gate"},
    {.id = "gorge-saved", .kind = STORY_PASSAGE, .location = "gorge", .camera = "gorge-saved",
     .text = "Поезд стоит по ту сторону пропасти. Пассажиры прилипли к окнам и хлопают. Супермен машет и "
             "исчезает. Через минуту из туалета выходит Кларк Кент.\n"
             "«Пропустили всё самое интересное», — вздыхает Чан.",
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
