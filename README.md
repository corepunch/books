# Book

Book is a native C engine for illustrated adventure gamebooks in the manner of
the Zork books. `make run` launches **The Salt Ledger**, a Grayhaven case for
one rainy night: first-person stills you can tap, and first-person clips of
the people and the harbor. The premise, the mood, and how to continue it are
in `books/salt/DESIGN.md`. **Обратный отсчёт**, the Superman
adventure after the DC Heroes module *Countdown to Armageddon*, remains available
with `make run BOOK=countdown`: a runaway train,
S.T.A.R. Labs, the Fortress of Solitude, a belt of meteorites in orbit and
Brainiac's ship, with things in rooms, an inventory and twelve endings. Each book is XML
pages read at launch and run by `src/story.c`. There is no ZIL or Lua runtime;
things follow ZIL's objects as plain data.

Each page shows one whole picture: the finished PNG illustration for its camera
from `books/countdown/illustrations/` when it exists, otherwise the camera's
own Scener render from `books/countdown/rooms/`, whose `.blks` scenes (`train`,
`gorge`, `star`, `fortress`, `orbit`, `sky`, `ship`) also hold camera and anchor
references; `items.blks` holds the inventory icons. Nothing is layered on
top of a page picture; a changed state is another camera. Tap a circle or its
caption to choose. The lower-right button continues a story page, and on an
ending offers «Попробовать снова» (back to the last decision) or «Начать
сначала».

## Build and launch

The native Mac app needs macOS, the Apple command-line tools, `pkg-config`, and
libxml2. Build directly with the SDK tools; there is no Xcode project.

```sh
make mac
make run
make check
make ipad-simulator
make ipad-run
make ipad-mac
```

`make ipad` builds an unsigned iPad app. `make ipad-deploy` automatically selects
the sole available physical iPad, installs the app and launches it. It ignores
simulators, iPhones and unavailable devices. If there are zero or multiple
eligible iPads, use `make list-devices` and set `DEVICE="iPad name or UDID"`.
iPad builds use the installed Xcode SDK and
`actool`; the Lua interpreter and its source are not part of either target. Set
`BOOK` to choose which book is run and bundled, for example
`make ipad-deploy BOOK=countdown`.

The Mac executable is `build/<book>/book`; pass `--book NAME`. It reads the
book and its art from the checkout and opens a fixed-size AppKit window. The iPad app uses
UIKit and Metal, supports landscape orientations, and keeps progress in memory
until the app closes.

## Headless interface

`build/countdown/book --book countdown --headless` prints a JSON snapshot for each page. It accepts
`:choose N`, `:tap X Y`, `:continue`, `:back`, `:reload`, `:hold ID`, or a choice command (its target page id, or a carried thing's id to hold it); `N` is a zero-based
choice index and tap coordinates are logical pixels in the 1100 × 800 viewport.
Snapshots include explicit choice kinds and the controls used by drawing and hit
testing. `:continue` and the legacy `:back` alias select the published Continue
choice, or finish a shot that has no button. `:focus KEY` selects a current
object choice. They cannot bypass the page.
`make check` exercises the adventure, shared controls and projection without
opening a window. `--viewport W H` selects a headless layout size for iPad checks.
`--smoke-route continue,continue,harbour` follows published actions before a
graphical capture. `make check-ui` checks the graphical reveal and visible
Continue label; it requires access to Metal and the window server.

## Extending the adventure

A book is XML, read at launch, modelled on the Virtual Cinema database of *The
X-Files Game*. `books/<name>/title.xml` declares the variables, characters,
icons, records and nodes (chapters); each node lists its locations, and
`books/<name>/locations/<location>.xml` holds that location's viewpoints,
views, charviews, assets, maps, action lists and endings. `src/storyxml.c`
loads them into the tables in `src/book.h` and reports any unknown element,
attribute or name with its file and line. [authoring/XML.md](authoring/XML.md)
is the reference, element by element, with the X-Files class each one
follows. The Salt Ledger's alley:

```xml
<location id="alley">
  <view id="alley" camera="alley">
    <text>The lane becomes an alley. A man stands in a lit doorway…</text>
    <holding icon="ledger">The rain is not a room. He said so.</holding>
    <explorable label="The board" anchor="alley-board" target="alley-board"/>
    <explorable label="The man" anchor="alley-man" target="penry-greet"/>
    <nav label="The bridge" anchor="alley-bridge" target="sluice-entry"/>
  </view>
  <asset id="alley-board" camera="board" read="true" sets="board" next="alley">
    The board is a wash of chalk…
  </asset>
  <charview id="penry" character="penry" camera="penry">
    <text>He stands in his light, hands in the towel.</text>
    <conversation id="penry-chalk" label="The chalk?" if="board and not penry" clip="penry-wash" sets="penry">
      "I washed it…"
    </conversation>
    <conversation label="That's all" target="alley" ends="true"/>
  </charview>
</location>
```

Pages, as published:

- `<view>` and `<map>` are room pages: circles on scene anchors (navs,
  explorables, a charview's circle, destinations), or on a picture edge for a
  nav that turns within its `<viewpoint>`. A `loop="true"` clip plays behind
  them.
- `<charview>` is a room page with lines in a darkened band; one line per
  held icon `ends="true"` and is pinned at the bottom. A `<conversation>` with
  prose or a clip has a reply, played as a beat that returns to the charview.
- `<asset>` is a beat. A prose book shows the text and Continue. An fmv shot
  (`fmv="true"` on the title) shows neither: the clip ends into `next`, after
  its end trigger, and a tap on the picture does the same. `read="true"` marks
  a document, which keeps the text and Continue.
- `<actionlist>` is invisible: its actions, with `<if>` and `<else>`, go on to
  another page.
- `<ending kind="success|partial|failure">`. Failures retry from the reader's
  last view (or `retry`) with the world they had there; success restarts.

A book with `<map>` pages, notes, email, photos, phone numbers or interfaces
gives every view the map, where *The X-Files Game* had its PDA: a disc beside
the carried icons, opening lists in the talk band of the destinations the
reader has seen and the records the story has enabled, records as documents,
and a phone keypad (`CHOICE_MAP` and `CHOICE_KEY`; the keypad page sets
`keypad`). See [authoring/XML.md](authoring/XML.md).

State is X-Files state: `<variable type="bool|int|char|string">`, enable flags
on any choice or record with an `id`, and carried icons. Conditions (`if`,
`test`) read them: `seen and not left`, `goons >= 2`, `has(ledger)`,
`enabled(lamp)`, `visited(alley)`. Triggers on nodes, locations and pages
(`enter`, `leave`, and `end` on assets) and the actions inside choices change
them; `sets`, `gives` and `removes` on a page are shorthand for its first enter
actions. A page may set `clip` to a bare file name, sliced with `from` and `to`
in milliseconds. The app plays `books/<name>/clips/<clip>.mp4` in the picture;
the camera's still is the poster, and headless play uses the poster.

### Icons and the inventory

A book may list icons, after X-Files's inventory, evidence, idea (topic),
emotion (tone) and action icons: each lies in a location, is carried by the
reader (`carried="true"`), or is gone. An explorable with `take` picks an icon
up where it lies; any choice with `with` is offered only while the reader holds
that icon. `<give>`, `<remove>`, `gives` and `removes` move icons, and `has()`
tests what is carried. A view publishes carried inventory and evidence as
`CHOICE_ITEM` choices, drawn as round icons in the bottom-left row; a charview
publishes every carried icon, so topics, tones and gestures are used in
conversation. Tapping one holds it (only its uses are offered; a prose book also
replaces the page text with the icon's description), tapping again puts it
away. "Try again" restores every icon's place. An fmv book does not draw that
description. A page can supply `<holding icon="…" if="…">` responses to
describe what a held icon reveals or could do in that scene; the first that
applies is shown, and the icon's own prose is the fallback.
An icon's picture is camera `item-<id>`. See
[authoring/THINGS.md](authoring/THINGS.md).
 `src/story.c` validates the table at launch, keeps
the private state, and publishes a read-only `BookPage` through `book_page()`.
A published page has one kind: room, intermediate (`PAGE_BEAT`) or ending. Each
choice has an explicit kind: object action, talk line (`ask` or `end`), Continue or retry. Consumers must
use these kinds, rather than infer behaviour from labels, command strings or
flags. A choice's command is the id of the page it leads to (or the choice's own
id, when its actions decide), used by tests and headless play; the map's choices
use `map:` commands (`map:open`, `map:phone`, `map:key:5`, `map:dial`,
`map:close`), and its pages `map:` ids (`map:home`, `map:notes`). A choice on a
picture edge carries its `edge`, and a page its clip slice and `loop`.

To add another book, add `books/<name>/title.xml`, its locations and assets
under `books/<name>/`, and `tests/test_<name>.py`, then build with
`BOOK=<name>`. The authoring guide in `authoring/` describes the whole process.

### The book tool

`make cli` builds `build/cli/book`, which reads a book through the same
loader, runtime and scene reader as the app. Agents and authors use it instead
of reading the XML by eye:

```bash
build/cli/book check salt
```

- `check BOOK` runs the runtime's validation, then reports every missing still
  (pages, icons, photos), every view camera absent from the `.blks` scenes and
  every anchor its scene lacks. `make check` runs it through `tests/test_cli.py`.
- `stats BOOK [--json]`: per location, as *The X-Files Game* counted them:
  viewpoints, views, charviews, conversations, shots, documents, endings, navs,
  explorables, action lists, icons, held-icon choices, distinct stills
  ("screens"), clips and actions; then the nodes, variables by type, icons by
  kind, records and ratios such as circles per view and clips per screen, for
  keeping a book evenly filled.
- `graph BOOK [--dot]`: every route out of every page (choices, gotos in
  triggers, called action lists, next, retry), then findings: pages the start
  cannot reach, pages with no route to an ending, views with fewer than two
  circles, variables set but never tested (or the reverse), icons that can never
  be had or are never used, flags that start disabled and are never enabled,
  and interfaces never shown.
- `query BOOK NAME`: everything about one name, whatever it names: a page (its
  file and line, prose, triggers, actions, routes out and in), a variable, an
  icon, a character, an enable flag, a record or phone number, a node, a
  location, a viewpoint, a camera, a clip or an anchor.
- `play BOOK [STEP ...]`: a transcript through the real runtime. A step is a
  choice's command, `continue`, `retry`, `hold:ICON` or a choice number.
- `assets BOOK [--missing] [--json]`: every still, clip, icon picture and photo
  with its status (painting, render, present, missing) and the prose of each
  page that shows it: the list of pictures and clips still to make.

`tests/test_engine.py` plays `tests/fixture/`, a small book that uses every
feature the reader plays, on The Salt Ledger's pictures.

`publish_page()` checks the contract before exposing a page: rooms have object
actions, a prose passage has exactly one Continue with no object or command, an
fmv shot has no choices, a document has that Continue, and endings have an
ending kind and exactly one retry choice. Never write into a published page or
reuse choice slots by changing selected fields. Large snapshots stay in static
storage to avoid exhausting the iPad main-thread stack.

All input adapters resolve a current choice and call `book_action()`. `page.c`
turns a published page into a `PageLayout`; its control rectangles supply both
drawing and `page_hit_test()`, including the headless `:tap` path. The UI retains
its own copy of the published page during transitions, including button labels.
Adding a page or choice kind requires updating publication checks, dispatch,
layout, rendering and JSON names. Both build targets treat incomplete enum
switches as errors so those sites are identified by the compiler.

## Source layout

```text
books/salt/title.xml           The Salt Ledger: variables, Penry, the ledger, and its node of locations
books/salt/locations/          one XML file per location
books/countdown/title.xml      Обратный отсчёт: variables, Superman's powers and things, four act nodes
books/countdown/locations/     one XML file per location
tests/fixture/                 a small book using every feature, for tests/test_engine.py
src/story.c                    story runtime: validation, facts, things, pages, retry
src/storyxml.c                 reads a book's XML into the story tables
src/cli.c                      the book tool: check, stats, graph, query, play, assets
src/page.c                     shared page layout, control bounds and hit testing
src/ui.c                       rendering, retained page views and transitions
src/headless.c                 JSON snapshots for the headless interface
src/scene.c                    camera, text-region and anchor projection
src/renderer.c                 raster image decoding and image cache
src/text.c                     font loading and text layout
src/metal.m                    Metal drawing and screenshot readback
src/macos.m                    AppKit application and window
src/ipad.m                     UIKit app and touch input
src/book.h                     shared declarations and geometry
books/countdown/rooms/         scenes, prefabs, camera renders and item icons
books/countdown/               DESIGN.md and WALKTHROUGH.md for the example book
fonts/                         shared application assets
vendor/                        stb image and font headers
platform/ipad/                 direct SDK build and app packaging
assets/                        app icon and Back button
```

Each camera has a matching reference JPEG. Camera names select projection
metadata, illustration names select finished PNGs, and named anchors in the
`.blks` source locate tappable objects and routes. The images and `.blks`
metadata describe the same places from multiple views.

## Composing prose

Camera metadata supports `textRect` / `textScale` and an optional
`textRect2` / `textScale2`, in normalized image coordinates under the same centered
crop as the art. A `<region/>` in a page's prose moves the following text into
the second region; a blank line starts a paragraph. Both regions share one story page and
one set of choices. Use scale 1 for body text, and a larger scale for a short
exclamation or spoken line. Text keeps its authored size. Compose enough room
for the entire passage and leave the lower-right Continue/retry area free.

Headless snapshots expose each block in `text_regions`, including its text,
font size, bounds and measured height. The example's tests check that all prose
fits, and that text, circles, captions and buttons do not overlap, at the Mac
size and three landscape iPad sizes.
