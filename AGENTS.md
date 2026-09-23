# Book Engine Guide

Book is a native C engine for visual interactive adventures. The built-in
adventure is “Три звёздочки для карты”; its state, objects, rooms, prose and
actions are implemented in C under `src/`. There is no ZIL or Lua runtime.
Keep module internals private and shared declarations in the single
`src/book.h` header. Compile stb_image in `renderer.c` and stb_truetype in
`text.c`.

Use descriptive `MAX_*` macros for buffer capacities and collection limits; do
not hardcode numeric array capacities. Define shared string buffer array
typedefs in `src/book.h` and use them for fields and locals. Use `fvec2_t` /
`ivec2_t`, `fsize2_t` / `isize2_t` and `frect_t` / `irect_t` for 2D geometry.
Prefer value-returning geometry helpers for offsets, scaling, crops, clipping
and hit tests; pass structs instead of separate coordinate components.

## Runtime

- The C adventure owns all game state, text, rooms, objects and actions.
- The UI discovers tappable targets from the current C page choices. Camera
  names select the matching illustrations in `books/three-stars/rooms/`.
- Camera and anchor metadata live in the `.blks` scene source. Keep named
  anchors aligned with the objects and routes shown in every matching image.
- The UI is hardcoded C over Metal with UIKit for iPad and AppKit/NSWindow for
  the fixed-size native Mac testing app. Graphical play uses circle/action taps
  only; reuse its focus, Back and Continue flow.
- Keep anchors aligned under the same centered crop as the JPEG. Missing art
  must not display another room. Interaction circles must have at least one
  radius of clear space between their edges. Use the shared marker layout for
  drawing, hit areas and headless output; preserve exact projected anchors and
  connect displaced markers to them.

`make mac` (also `make run`) launches the native Mac app; `make ipad-mac`
launches the iPad app on Apple silicon Mac. Build directly with the SDK tools;
do not introduce an Xcode project.

## Artwork

`books/three-stars/rooms/` holds pre-rendered JPEGs and the matching `.blks`
camera/anchor source. C reads those files for hotspot projection and per-camera
reading regions. Keep images and metadata synchronized. Scener renders are
spatial references for finished illustrations, not final artwork. Keep camera
perspective, object scale, layout and lighting direction consistent across
views. Do not invent permanent furnishings independently in each image.

Author Scener centimetres, X east, Y north, Z up, degrees and unitless scale.
New scenes declare `up="z"`. Compose establishing cameras obliquely; avoid
frontal views and dominant screen-horizontal architectural lines. Reserve
natural negative space for the full prose and keep interaction circles outside
it. Author per-camera `textRect` and optional `textScale` in `.blks`.
Geometry belongs in `.blks` scenes and `.blk` prefabs; finished and review
images must be raster, never SVG. The Scener checkout is separate at
`~/Developer/mapview/ui/apps/scener`; read its instructions before changing it.

## Validation

Run `make check` after host changes. It builds the native application and checks
the C adventure, inferred asset names and projection without a display. For
display changes, run a graphical smoke capture and inspect the JPEG with its
hotspot/UI overlays. Do not rerender unchanged artwork just to test C code.
Use `make render BOOK=three-stars SCENE=attic` for artwork changes; render and
inspect affected cameras, keeping source and images synchronized.
