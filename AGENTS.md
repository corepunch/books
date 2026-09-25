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
- Keep mutable adventure state private to `book.c`. Consumers read `book_page()`;
  build new pages through the private constructors and `publish_page()`. Create
  whole choice values with explicit `ChoiceKind`; never partially overwrite a
  reused choice or infer its action from text or empty strings. `show_beat()`
  always supplies Continue. See README's "Extending the adventure" for the path
  to add an action.
- Route all input through `book_action()`. Drawing and headless input share
  `page_layout()` and `page_hit_test()`; keep control bounds and labels there and
  in the published page. Tests must activate the published Continue choice or
  tap its control, so they exercise the player-facing navigation path.
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
Scenes must make physical sense. Follow Scener's
`skills/populate-simplegl-scenes/references/world-logic.md`: every object has
a support and a reason to be there, and character routes use plausible
furniture (a chair, a drawer, a trunk), never props stacked into stairs. Each
book's `DESIGN.md` holds its resident story and scale sheet: protagonist size,
reach and jump limits, the height of every route surface, and the
protagonist's on-screen size in establishing shots. Scenes resolve prefabs from
their own `rooms/prefabs/`; start furniture by adapting Scener's
`prefabs/furniture`, `fixtures` and `items` into that folder rather than
modelling from raw boxes. Build characters as Scener `<bone>` skeletons
(direction, length, girth, `mirror`, `segments`) following Scener's
`docs/character-authoring.md`; pose them with `aim` and tip IK, never with
hand-placed spheres.
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
