# Book

Book is a native C engine for illustrated adventure gamebooks in the manner of
the Zork books. Its built-in story, **Обратный отсчёт**, is a Superman
adventure after the DC Heroes module *Countdown to Armageddon*: a runaway train,
S.T.A.R. Labs, the Fortress of Solitude, a belt of meteorites in orbit and
Brainiac's ship, with things in rooms, an inventory and twelve endings. Each book is a table
of pages in C run by `src/story.c`. There is no ZIL or Lua runtime; things
follow ZIL's objects in plain C data.

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
`BOOK` to choose which C book is compiled, for example
`make ipad-deploy BOOK=countdown`.

The Mac executable is `build/countdown/book` for the default book. It reads
art from the checkout and opens a fixed-size AppKit window. The iPad app uses
UIKit and Metal, supports landscape orientations, and keeps progress in memory
until the app closes.

## Headless interface

`build/countdown/book --headless` prints a JSON snapshot for each page. It accepts
`:choose N`, `:tap X Y`, `:continue`, `:back`, `:reload`, `:hold ID`, or a choice command (its target page id, or a carried thing's id to hold it); `N` is a zero-based
choice index and tap coordinates are logical pixels in the 1100 × 800 viewport.
Snapshots include explicit choice kinds and the controls used by drawing and hit
testing. `:continue` and the legacy `:back` alias select the published Continue
choice; `:focus KEY` selects a current object choice. They cannot bypass the page.
`make check` exercises the adventure, shared controls and projection without
opening a window. `--viewport W H` selects a headless layout size for iPad checks.
`--smoke-route continue,continue,harbour` follows published actions before a
graphical capture. `make check-ui` checks the graphical reveal and visible
Continue label; it requires access to Metal and the window server.

## Extending the adventure

Each book is one C file in `books/`, such as `books/countdown.c`, holding a
`const struct Story`: its name, start page, button labels and a table of
`StoryPage` entries (see `src/book.h`). Page kinds in the table:

- `STORY_DECISION`: up to three choices `{label, anchor, target}`; each is a
  circle on the named scene anchor. `.requires`/`.excludes` limit a choice by
  story facts.
- `STORY_PASSAGE`: a story page with Continue to `.next`.
- `STORY_CHECK`: invisible; goes to `.next` if `.fact` is set, else
  `.otherwise`.
- `STORY_ENDING`: success, partial or failure. Failures retry from the reader's
  last decision (or `.retry`) with the facts they had there; success restarts.

Pages set facts with `.sets`.

### Things and the inventory

A book may list things (`struct StoryItem`, after ZIL's objects): each lies in
a location, is carried by the hero, or is gone. A decision choice with `.take`
picks a thing up where it lies; a choice with `.with` is offered only while the
reader holds that thing. Pages move things with `.gives` and `.removes`, and a
check's `.holds` tests what is carried. Every room page publishes the carried
things as `CHOICE_ITEM` choices, drawn as round icons in the bottom-left row;
tapping one holds it (the prose becomes its description and only its uses are
offered), tapping again puts it away. "Try again" restores every thing's place.
A thing's icon is the picture for camera `item-<id>`. See
[authoring/THINGS.md](authoring/THINGS.md).
 `src/story.c` validates the table at launch, keeps
the private state, and publishes a read-only `BookPage` through `book_page()`.
A published page has one kind: room, intermediate (`PAGE_BEAT`) or ending. Each
choice has an explicit kind: object action, Continue or retry. Consumers must
use these kinds, rather than infer behaviour from labels, command strings or
flags. A choice's command is its target page id, used by tests and headless
play.

To add another book, add `books/<name>.c`, its assets under `books/<name>/` and
`tests/test_<name>.py`, then build with `BOOK=<name>`. The authoring guide in
`authoring/` describes the whole process.

`publish_page()` checks the contract before exposing a page: rooms have object
actions, intermediate pages have exactly one Continue with no object or
command, and endings have an ending kind and exactly one retry choice. Never write into a published page or
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
books/countdown.c              Обратный отсчёт: the Superman story table, with things
src/story.c                    story runtime: validation, facts, things, pages, retry
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
books/<name>.c                 one compile-time C implementation per book
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
crop as the art. A `\f` in a story's C string moves the following text into the
second region; `\n` starts a paragraph. Both regions share one story page and
one set of choices. Use scale 1 for body text, and a larger scale for a short
exclamation or spoken line. Text keeps its authored size. Compose enough room
for the entire passage and leave the lower-right Continue/retry area free.

Headless snapshots expose each block in `text_regions`, including its text,
font size, bounds and measured height. The example's tests check that all prose
fits, and that text, circles, captions and buttons do not overlap, at the Mac
size and three landscape iPad sizes.
