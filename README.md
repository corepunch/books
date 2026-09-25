# Book

Book is a native C engine for illustrated adventure gamebooks in the manner of
the Zork books. Its built-in story, **Огонь на маяке**, follows ten-year-old
Varya across a stormy bay to light her grandfather's lighthouse: seven places,
strangers on the road, the rising tide and seven endings. Each book is a table
of pages in C run by `src/story.c`. There is no ZIL or Lua runtime. Nothing is
picked up or carried.

Each page shows one whole picture: the finished PNG illustration for its camera
from `books/lighthouse/illustrations/` when it exists, otherwise the camera's
own Scener render from `books/lighthouse/rooms/`, whose `.blks` scenes (`bay`,
`home`, `tower`) also hold camera and anchor references. Nothing is layered on
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

`make ipad` builds an unsigned iPad app. `make ipad-deploy DEVICE="iPad name or UDID"`
installs it on a paired device. iPad builds use the installed Xcode SDK and
`actool`; the Lua interpreter and its source are not part of either target. Set
`BOOK` to choose which C book is compiled, for example
`make ipad-deploy BOOK=lighthouse DEVICE="iPad name or UDID"`.

The Mac executable is `build/lighthouse/book` for the default book. It reads
art from the checkout and opens a fixed-size AppKit window. The iPad app uses
UIKit and Metal, supports landscape orientations, and keeps progress in memory
until the app closes.

## Headless interface

`build/lighthouse/book --headless` prints a JSON snapshot for each page. It accepts
`:choose N`, `:tap X Y`, `:continue`, `:back`, `:reload`, or a choice command (its target page id); `N` is a zero-based
choice index and tap coordinates are logical pixels in the 1100 × 800 viewport.
Snapshots include explicit choice kinds and the controls used by drawing and hit
testing. `:continue` and the legacy `:back` alias select the published Continue
choice; `:focus KEY` selects a current object choice. They cannot bypass the page.
`make check` exercises the adventure, shared controls and projection without
opening a window. `make check-ui` checks the graphical reveal and visible
Continue label; it requires access to Metal and the window server.

## Extending the adventure

Each book is one C file in `books/`, such as `books/lighthouse.c`, holding a
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

Pages set facts with `.sets`. `src/story.c` validates the table at launch, keeps
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
books/lighthouse.c             Огонь на маяке: the story table
src/story.c                    story runtime: validation, facts, pages, retry
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
books/lighthouse/rooms/        scenes (bay, home, tower), prefabs and camera renders
books/lighthouse/work/         the authoring documents for the example book
fonts/                         shared application assets
vendor/                        stb image and font headers
platform/ipad/                 direct SDK build and app packaging
assets/                        app icon and Back button
```

Each camera has a matching reference JPEG. Camera names select projection
metadata, illustration names select finished PNGs, and named anchors in the
`.blks` source locate tappable objects and routes. The images and `.blks`
metadata describe the same places from multiple views.
