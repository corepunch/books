# Book

A small C engine for visual interactive ZIL books. `src/` contains the host,
2D drawing, fixed page UI and camera projection. C resumes zilscript's Lua
coroutine directly. ZIL owns objects, exits, actions, prose and game state.

Book displays pre-rendered JPEGs. Scener produces consistent spatial references
for an AI illustration pass: rough object shapes, layout, scale and shadows.
The AI paints the final storybook finish over those references while preserving
their camera and object registration. `.blks` files supply only camera and
anchor metadata at runtime. There are no Book Lua
scripts, Orca dependencies, UI XML files or per-adventure mapping manifests.

## iPad app

The shipping app is a landscape-only iPad UIKit app (iPadOS 16+), with the same
C/ZIL engine and Metal renderer as the desktop harness. There is no `.xcodeproj`
and no `xcodebuild` step. Make invokes `xcrun clang` directly, compiles the icon
with `actool`, and stages the executable and resources into `Book.app`.
The installed Xcode SDK/toolchain is required; the Xcode IDE is not used.

```sh
make ipad-simulator             # compile and ad-hoc sign an iPad simulator app
make ipad-run                   # build, install and launch on an iPad simulator
make ipad-run DEVICE="iPad Pro 11-inch (M5)"  # or a simulator UDID
make ipad                       # compile an unsigned ARM64 iPad app
make ipad-mac                   # development-sign and launch the iPad app on Mac
```

Build products are in `build/ipad/iphoneos-arm64/` and
`build/ipad/iphonesimulator-<arch>/`. `ipad-mac` packages the signed iOS app as
`build/ipad/Book.app` for Launch Services. It runs the same iPad executable on
Apple silicon using macOS's iPad app support. Mac Catalyst is not involved.

Simulator builds use ad-hoc signing and require no developer account. For local
Mac execution, `tools/sign_ipad.py` selects an installed, unexpired development
profile and a matching certificate/private key for `BUNDLE_ID` (default
`com.igor.book`). It can reuse a wildcard profile. Set `TEAM=...` to select a
team or `PROFILE=/path/to/profile.mobileprovision` explicitly. This build never
creates profiles or contacts the developer portal. Physical iPads also need a
valid development signature and a profile covering the device; `make ipad`
only produces an unsigned build. App Store release packaging is separate.

`BOOK=wondertown` selects the bundled adventure. The native objects are cached;
changing ZIL, Lua, art, or `BOOK` repackages resources without recompiling C.
Runtime Lua/ZIL files, the font, existing JPEGs, and scene projection sources
are copied into the app bundle. Art work directories are excluded. Lua 5.4.8
is compiled from `vendor/lua` for iOS; Homebrew libraries are used only by the
desktop harness. No network or external asset directory is needed at runtime.
The icon is in `assets/AppIcon.xcassets`, with its larger source and edit prompt
in `assets/`. `IOS_MIN`, `ARCH`, and `BUNDLE_ID` can be overridden on the make
command line. `BUILD_DIR` keeps generated files separate from the source.

Tap circles to focus objects and use the bottom-right Back button to return
to the room. The text action list, including verbs, exits and Continue, is
temporarily hidden for the visual pass. Drag to scroll long pages. There is no
bottom bar, text field, or keyboard command entry in either graphical app.
The page fills the safe area and supports both landscape orientations. iPad
full-screen presentation is requested to avoid portrait multitasking layouts.
The engine currently keeps progress in memory; terminating the app starts a
fresh game on the next launch.

## Native Mac app for rapid iteration

Requires macOS with Metal, Apple command-line developer tools (C/Objective-C),
make, pkg-config, Lua **5.4** and libxml2. The native window uses AppKit
(`NSWindow`); all drawing uses Metal through a `CAMetalLayer`.

```sh
git submodule update --init --recursive
make mac                       # native AppKit app, fixed-size window
make mac BOOK=wondertown
make run                       # alias for make mac
make check
```

This is a separate native macOS executable built from `src/macos.m`, using a
fixed 1100 × 800 point `NSWindow` with resizing, zoom and full-screen disabled.
Its title is **Book — Native Mac**. `make ipad-mac` instead compiles `src/ipad.m`
and runs the UIKit iPad app on Apple silicon. Both share the C engine, Metal
renderer and tap/action controls; neither build uses an Xcode project.

The native executable is built in `build/book` and links the system AppKit,
Metal and QuartzCore frameworks. It reads assets straight from the checkout,
so iteration needs no packaging, signing or simulator. F5 reloads artwork and
projection metadata. Re-run `make mac` after native-code or ZIL edits.

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
src/ipad.m                      UIKit scenes, touch input and lifecycle
src/transition.c                reveal/fade timing, easing and resize-aware coverage
src/headless.c                  JSON snapshots, commands and object catalog
src/renderer.c                  JPEG decoding and page texture cache
src/metal.m                     Metal drawing, textures and screenshot readback
src/text.c                      font loading, glyphs and text layout/rendering
src/scene.c                     fixed camera/anchor loading and projection
src/hotspots.c                  spaced marker placement around projected anchors
src/common.c                    shared error and string helpers
src/geometry.c                  vector, size and rectangle operations
src/book.h                      shared application types and declarations
fonts/                          shared font assets
vendor/                         stb image/font headers
vendor/lua/                     Lua 5.4.8 source for the iPad target
platform/ipad/build.mk          direct clang, icon, packaging and launch targets
platform/ipad/Info.plist        iPad lifecycle and landscape-only metadata
assets/                        app icon master and asset catalog
libs/zilscript/                 the only Lua dependency, including ZIL adventures
books/wondertown/rooms/          JPEGs, .blks camera/anchor sources and prefabs/
books/wondertown/work/           art guides, references and historical studies
tools/render.py                 offline Scener batch rendering
tools/bundle_ipad.py            stage runtime resources into the iPad app bundle
tools/sign_ipad.py              sign with a matching local development profile
tools/run_ipad_simulator.py     boot, install and launch on an iPad simulator
tools/wrap_ipad_mac.py          local Designed for iPad launch packaging
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

Cameras may also declare `textRect="x y width height"` in normalized JPEG
coordinates and a preferred `textScale`. Prose follows that image region through
the centered crop, wraps and fits modestly, with scrolling for overflow. The
workshop overview uses a lower-left region clear of its interaction circles;
other cameras keep the legacy placement until individually authored. See
[reading-region parameters](books/wondertown/work/RENDERING.md#per-camera-reading-regions).

## Controls

Click or tap a circle to focus an object; the bottom-right circular Back button
uses `assets/back-button.png` with a 96-point circular hit area and leaves focus.
Circles keep a 24-point edge gap (one radius). Crowded markers move to
nearby free space and use short connector lines when their anchor lies outside
the circle; their hit areas follow the displayed positions. Authored text regions
remain clear. The VM still supplies object verbs, exits and Continue,
but their text action list and hit regions are hidden for the current
visual pass. Drag or use the scroll wheel for long pages. The
native Mac app also provides F5 to reload images and projection metadata during
development. Parser commands remain available through `--headless` for engine
testing.

Page changes reveal the next JPEG through a growing circle originating
at the selected hotspot (or the click position for text choices).
The outgoing page keeps its text, circles, connector lines and Back button
until the reveal covers them. The new text and circles fade in after the reveal. Navigation
is paused during animation; F5 cancels it and reloads. Same-image responses only
crossfade the overlays. `src/transition.c` owns timing and easing; the UI coordinates
navigation and drawing from independent page presentation snapshots, and the
renderer owns masking and opacity. Three cached
images keep both pages and the Back asset resident without render textures. The
Metal fragment shader applies the circular reveal mask in logical
window coordinates; the drawable and clipping use the screen backing scale.

## Rendering and checks

```sh
make render BOOK=wondertown SCENE=workshop-new WIDTH=1920 HEIGHT=1440
make layout BOOK=wondertown SCENE=workshop-new
make check
make check-ui # Graphical transition regression; requires the macOS window server.
build/book --root "$PWD" --book wondertown --smoke --screenshot /tmp/book.ppm
build/book --root "$PWD" --book wondertown --smoke-transition 275 --screenshot /tmp/reveal.ppm
```

`--smoke-transition MS` activates the first projected hotspot and captures a
deterministic animation time: 275 ms mid-reveal, 550 ms before the overlay fade,
700 ms mid-fade, and 850 ms complete. It requires a page with a projected hotspot.

`make run` consumes existing art. `make render` generates Scener references,
currently also used as development backgrounds; it does not perform the final
AI illustration pass. See [the artwork workflow](books/wondertown/work/RENDERING.md)
before replacing an illustrated JPEG with a new reference render.
`--headless` prints JSON page snapshots and accepts parser commands on stdin;
`:choose N`, `:focus object-id`, `:continue`, `:back` and `:reload` exercise the
same C presentation functions as the UI. Choice indexes start at zero.

For example: `kitchen-look.jpg`, `kitchen-examine-spoon.jpg`, and
`kitchen-take-spoon.jpg`. The noun is the declared ZIL object ID, so its synonyms
resolve to the same image. For movement actions, the action filename uses the
room where the action started; Continue shows the destination's look image.
`--catalog` prints VM-derived object IDs and their owning rooms for artwork
tools. It does not create a mapping file.
