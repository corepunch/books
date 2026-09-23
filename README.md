# Book

Book is a native C adventure app. Its built-in story, **Три звёздочки для карты**,
follows Mira the mouse as she gathers three stars from the floor, desk and
window sill of one attic. The story state, locations, inventory, choices and
prose all live in C. There is no ZIL or Lua runtime.

The app displays pre-rendered JPEG illustrations. `books/three-stars/rooms/attic.blks`
stores camera and named-anchor metadata used to place story text and interaction
circles over each image. Tap a circle to collect a star or travel along the book
and postcard steps. The lower-right button continues after an action.

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
`actool`; the Lua interpreter and its source are not part of either target.

The Mac executable is `build/book`. It reads art from the checkout and opens a
fixed-size AppKit window. The iPad app uses UIKit and Metal, supports landscape
orientations, and keeps progress in memory until the app closes.

## Headless interface

`build/book --headless` prints a JSON snapshot for each page. It accepts
`:choose N`, `:continue`, `:back`, and `:reload`; `N` is a zero-based choice
index. `make check` exercises the C adventure and projection without opening a
window. `make check-ui` exercises the graphical reveal and requires a window
server.

## Source layout

```text
src/book.c                     C adventure state, story data and actions
src/ui.c                       page layout, interaction circles and navigation
src/headless.c                 JSON snapshots for the headless interface
src/scene.c                    camera, text-region and anchor projection
src/renderer.c                 JPEG decoding and image cache
src/text.c                     font loading and text layout
src/metal.m                    Metal drawing and screenshot readback
src/macos.m                    AppKit application and window
src/ipad.m                     UIKit app and touch input
src/book.h                     shared declarations and geometry
books/three-stars/rooms/       story JPEGs and attic camera/anchor metadata
fonts/                         shared application assets
vendor/                        stb image and font headers
platform/ipad/                 direct SDK build and app packaging
assets/                        app icon and Back button
```

Each camera has a matching JPEG. Camera names select action frames, and named
anchors in the `.blks` source locate the tappable objects and routes. The images
and `.blks` metadata describe the same attic from multiple views.
