# Book

A small C engine for visual interactive ZIL books. `src/` contains the host,
2D drawing, fixed page UI and camera projection. C resumes zilscript's Lua
coroutine directly. ZIL owns objects, exits, actions, prose and game state.

Book displays pre-rendered JPEGs. Scener renders the artwork offline; `.blks`
files supply only camera and anchor metadata at runtime. There are no Book Lua
scripts, Orca dependencies, UI XML files or per-adventure mapping manifests.

## Build and run

Requires a C compiler, make, pkg-config, Lua **5.4**, libxml2 and
[libplatform](https://github.com/corepunch/platform). macOS uses system OpenGL;
Linux needs OpenGL and libplatform's display dependencies.

```sh
git submodule update --init --recursive
make run
make run BOOK=wondertown
make check
```

The default platform path is `../orca/libs/platform`; override it with
`make PLATFORM_DIR=/path/to/platform`. The application and platform library
are built together in `build/`.

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
src/ui.c                        fixed page UI, input and graphical event loop
src/headless.c                  JSON snapshots, commands and object catalog
src/renderer.c                  OpenGL drawing, images and screenshots
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

## Rendering and checks

```sh
make render BOOK=wondertown SCENE=workshop-new WIDTH=1920 HEIGHT=1440
make layout BOOK=wondertown SCENE=workshop-new
make check
build/book --root "$PWD" --book wondertown --smoke --screenshot /tmp/book.ppm
```

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
