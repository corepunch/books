# Book

Book is a native C adventure app. Its built-in story, **Три звёздочки для карты**,
follows Mira the kitten as she gathers three stars from the floor, desk and
window sill of one attic. The story state, locations, inventory, choices and
prose all live in C. There is no ZIL or Lua runtime.

The app displays finished PNG illustrations from `books/three-stars/illustrations/`
when they exist. Collectible stars use transparent layers extracted from the
matching painted scene; after collection, the page uses its clean PNG plate.
Until a page's painting and item layer exist, it shows the camera's own Scener
render from `books/three-stars/rooms/`, where `attic.blks` also holds camera and
anchor references. Tap a circle to collect a star or to jump between floor,
chair, desk and window sill. The lower-right button continues after an action.

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
`make ipad-deploy BOOK=three-stars DEVICE="iPad name or UDID"`.

The Mac executable is `build/three-stars/book` for the default book. It reads
art from the checkout and opens a fixed-size AppKit window. The iPad app uses
UIKit and Metal, supports landscape orientations, and keeps progress in memory
until the app closes.

## Headless interface

`build/three-stars/book --headless` prints a JSON snapshot for each page. It accepts
`:choose N`, `:tap X Y`, `:continue`, `:back`, and `:reload`; `N` is a zero-based
choice index and tap coordinates are logical pixels in the 1100 × 800 viewport.
Snapshots include explicit choice kinds and the controls used by drawing and hit
testing. `:continue` and the legacy `:back` alias select the published Continue
choice; `:focus KEY` selects a current object choice. They cannot bypass the page.
`make check` exercises the adventure, shared controls and projection without
opening a window. `make check-ui` checks the graphical reveal and visible
Continue label; it requires access to Metal and the window server.

## Extending the adventure

Each book is implemented by one C file in `books/`, such as
`books/three-stars.c`. The selected source owns mutable story state and
publishes a read-only `BookPage` through `book_page()`. It defines
`book_name()` to match its filename. `src/book.h` declares this interface along
with the shared engine modules. A page has one kind: room, intermediate
(`PAGE_BEAT`), or ending. Each choice has an explicit kind: object action or
Continue. Consumers must use these kinds, rather than infer behavior from
labels, command strings or flags.

To add another book, add `books/<name>.c` and its runtime assets under
`books/<name>/`, then build with `BOOK=<name>`. To add an action to an existing
book:

1. Register its object in `book_init()` and add its room choice in
   `add_room_choices()` using `append_choice(object_choice(...))`.
2. Handle it in `perform()`, updating private story state and selecting the
   response prose and camera. The existing `show_beat()` call supplies Continue
   automatically. Use `finish_story()` for a terminal response.
3. Add a reference JPEG, its finished PNG, and camera/anchor metadata. Only
   object anchors that project into the current camera become circles.
4. Extend `tests/test_book.py` with the route and use `continue_page()` to tap the
   actual Continue control. Run `make check`; for display changes also run
   `make check-ui` and inspect a smoke capture.

Page constructors clear private scratch storage and append complete choice
values. `publish_page()` checks the contract before exposing the result: rooms
have object actions, intermediate pages have exactly one Continue with no object
or command, and endings have no choices. Never write into a published page or
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
books/three-stars.c            Three Stars story state, data and actions
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
books/three-stars/rooms/       camera-reference JPEGs and attic metadata
books/three-stars/illustrations/ finished story art and aligned star cutouts
fonts/                         shared application assets
vendor/                        stb image and font headers
platform/ipad/                 direct SDK build and app packaging
assets/                        app icon and Back button
```

Each camera has a matching reference JPEG. Camera names select projection
metadata, illustration names select finished PNGs, and named anchors in the
`.blks` source locate tappable objects and routes. The images and `.blks`
metadata describe the same attic from multiple views.
