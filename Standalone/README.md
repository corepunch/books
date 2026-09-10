# Standalone Book

Book runs directly on libplatform and OpenGL, with stb_image for image decoding,
stb_truetype for fonts, and Lua for Book's scene and interaction logic. It does
not link Orca or load its plugins, XML UI, or object system.

Workshop geometry, camera settings, and interaction anchors are read directly
from `Rooms/workshop-new.blks` for the live renderer. There is no camera export
step, JPEG-generation requirement, or dependency on generated `WorkshopCamera.lua`
metadata. Prefabs, arrays, primitive materials, ambient lighting and point lights
load from the same source XML. F5 reloads the scene without resetting the story.
The small renderer uses diffuse lighting; it does not reproduce Scener's shadows
or its full material/CSG system. Unsupported geometry reports an error.

The scene fills the window with its aspect ratio preserved. Cream story text sits
directly over the top-left of the scene, with plain text choices at the lower-right
and white circular hotspots on interactive objects. The text positions are
hardcoded for now. Tab hides/shows text and choices; scroll or use the arrow keys
for overflowing text, press Escape to step back, or type a command and press Enter.
Command input appears only while typing. There are no panels behind the text.

From the repository root:

```sh
make -C samples/Book
make -C samples/Book run
make -C samples/Book check
```

Install a C compiler, make, pkg-config and Lua development files (`lua5.4` or
`lua`). macOS uses the system OpenGL framework; Linux also needs OpenGL and
libplatform's Wayland/EGL or X11/EGL development dependencies. macOS is the
initial validation target.

The executable and libplatform shared library live together in
`../build/standalone`. The executable accepts the Book asset directory as its
first argument, so it can run from any working directory:

```sh
samples/Book/build/standalone/book "$PWD/samples/Book"
```

Append `--check` to validate the Lua application without opening a window, or
`--smoke` to open the application and exit after three frames.
An optional path after `--smoke` saves a PPM screenshot. `make check` runs the
geometry and story tests plus binary initialization from `/tmp`, verifying asset
lookup independently of the current working directory.

Existing scene generation remains available through `make -C samples/Book
render`, `layout`, and `sanity`. It requires scener. To run the original Orca
version, use `make -C samples/Book run-orca`.

For a separate project, retain Book's assets and Lua modules together with this
directory, copy libplatform, and build with its location:

```sh
make -C Standalone PLATFORM_DIR=/path/to/libplatform
```

`BUILD_DIR`, `LUA_PKG`, `CC`, and `CFLAGS` can also be overridden. No Orca build
or generated headers are required.

The vendored stb headers come from [nothings/stb](https://github.com/nothings/stb)
at commit `f0569113c93ad095470c54bf34a17b36646bbbb5`. Each header includes its
upstream public-domain/MIT dual license.
