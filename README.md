# Book

A small C engine for visual interactive ZIL books. `src/` contains the host,
2D drawing, fixed page UI and camera projection. C resumes zilscript's Lua
coroutine directly. ZIL owns objects, exits, actions, prose and game state.

Book displays pre-rendered JPEGs. Scener renders the artwork offline; `.blks`
files supply only camera and anchor metadata at runtime. There are no Book Lua
scripts, Orca dependencies, UI XML files or per-adventure mapping manifests.

## Build and run

Requires macOS with Metal, Apple command-line developer tools (C/Objective-C),
make, pkg-config, Lua **5.4** and libxml2. The native window uses AppKit
(`NSWindow`); all drawing uses Metal through a `CAMetalLayer`.

```sh
git submodule update --init --recursive
make run
make run BOOK=wondertown
make check
```

The application is built in `build/` and links the system AppKit, Metal and
QuartzCore frameworks. No external windowing library is required.

```sh
build/book --root /path/to/books --book wondertown
```

`--root` selects the engine's asset/library directory, independently of the
working directory. `--book NAME` loads `libs/zilscript/books/NAME/NAME.zil` and
uses `books/NAME/rooms/` for artwork and projection metadata. Another adventure
needs its ZIL entry point and assets, with no C edits or mapping files.

## Layout

```text
src/main.c                      command-line options and application lifecycle
src/book.c                      ZIL coroutine host, page state and choices
src/ui.c                        fixed page UI, input and navigation
src/macos.m                     NSWindow, AppKit events and application lifecycle
src/transition.c                reveal/fade timing, easing and resize-aware coverage
src/headless.c                  JSON snapshots, commands and object catalog
src/renderer.c                  JPEG decoding and page texture cache
src/metal.m                     Metal drawing, textures and screenshot readback
src/text.c                      font loading, glyphs and text layout/rendering
src/scene.c                     fixed camera/anchor loading and projection
src/common.c                    shared error and string helpers
src/geometry.c                  vector, size and rectangle operations
src/book.h                      shared application types and declarations
fonts/                          shared font assets
vendor/                         stb image/font headers
libs/zilscript/                 the only Lua dependency, including ZIL adventures
books/wondertown/rooms/          JPEGs, .blks camera/anchor sources and prefabs/
books/wondertown/work/           art guides, references and historical studies
tools/render.py                 offline Scener batch rendering
tests/test_book.py               native host integration checks
tests/test_geometry.c            crops, clipping, hit boundaries and pixel scaling
```

The stb implementations compile directly in `renderer.c` (stb_image) and
`text.c` (stb_truetype).

Room art is `{room-id}-look.jpg`; focus art is `{room-id}-examine-{object-id}.jpg`; action art is
`{room-id}-{verb}-{object-id}.jpg`. IDs come from ZIL declarations, lowercased with
hyphens. Action art falls back to the room/object examine image and then the room look image.
A room without artwork displays text on a plain background. Missing camera or
anchor metadata leaves the object available as a text choice.

The engine discovers named cameras in the book's `rooms/*.blks` files. Shared
locations can use one scene with several room cameras. Each camera name must
be unique across those files. The JPEG and camera/anchor source must describe
the same shot. Actual JPEG dimensions determine the projection's aspect ratio
and centered window crop.

## Controls

Click an object or its projected circle to focus it. The VM's object verbs
become focus choices; the VM's exits become navigation choices. Parser commands
execute every action. Continue dismisses a response; Back leaves focus. Type a
command and press Enter for interactions requiring more words or another object.
Escape clears input or goes back. Tab toggles prose and choices, scrolling or
arrow keys scroll long pages, and F5 reloads images and projection metadata.

Page changes reveal the next JPEG through a growing circle originating
at the selected hotspot (or the click position for text choices, window center
for keyboard navigation). Text and circles fade in after the reveal. Navigation
is paused during animation; F5 cancels it and reloads. Same-image responses only
fade the overlays. `src/transition.c` owns timing and easing; the UI coordinates
navigation and drawing, and the renderer owns masking and opacity. Two cached
JPEG textures allow both pages to draw directly into the window without render
textures. The Metal fragment shader applies the circular reveal mask in logical
window coordinates; the drawable and clipping use the screen backing scale.

## Rendering and checks

```sh
make render BOOK=wondertown SCENE=workshop-new WIDTH=1920 HEIGHT=1440
make layout BOOK=wondertown SCENE=workshop-new
make check
build/book --root "$PWD" --book wondertown --smoke --screenshot /tmp/book.ppm
build/book --root "$PWD" --book wondertown --smoke-transition 275 --screenshot /tmp/reveal.ppm
```

`--smoke-transition MS` activates the first projected hotspot and captures a
deterministic animation time: 275 ms mid-reveal, 550 ms before the overlay fade,
700 ms mid-fade, and 850 ms complete. It requires a page with a projected hotspot.

`make run` consumes existing art. Scener is required only to generate new art.
`--headless` prints JSON page snapshots and accepts parser commands on stdin;
`:choose N`, `:focus object-id`, `:continue`, `:back` and `:reload` exercise the
same C presentation functions as the UI. Choice indexes start at zero.

For example: `kitchen-look.jpg`, `kitchen-examine-spoon.jpg`, and
`kitchen-take-spoon.jpg`. The noun is the declared ZIL object ID, so its synonyms
resolve to the same image. For movement actions, the action filename uses the
room where the action started; Continue shows the destination's look image.
`--catalog` prints VM-derived object IDs and their owning rooms for artwork
tools. It does not create a mapping file.
