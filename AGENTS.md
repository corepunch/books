# Book Engine Guide

Book is a native C engine for visual interactive adventures. The default book
is The Salt Ledger, XML in `books/salt/title.xml` and
`books/salt/locations/*.xml`, read at launch by `src/storyxml.c` and run by the
story runtime in `src/story.c`: first-person stills and full-motion clips,
built like *The X-Files Game* (places you turn in, people you question with
what you carry, a town map and a telephone) and played on placeholders. The
format follows the Virtual Cinema database of *The X-Files Game* (HyperBole,
1998), name for name; [authoring/XML.md](authoring/XML.md) is its reference.
«Обратный отсчёт» is in `books/countdown/` in the same form. There is no ZIL
or Lua runtime.
Keep module internals private and shared declarations in the single
`src/book.h` header. Compile stb_image in `renderer.c` and stb_truetype in
`text.c`.

Use descriptive `MAX_*` macros for buffer capacities and collection limits; do
not hardcode numeric array capacities. Define shared string buffer array
typedefs in `src/book.h` and use them for fields and locals. Use `fvec2_t` /
`ivec2_t`, `fsize2_t` / `isize2_t` and `frect_t` / `irect_t` for 2D geometry.
Prefer value-returning geometry helpers for offsets, scaling, crops, clipping
and hit tests; pass structs instead of separate coordinate components.

## Writing a book

To create a new illustrated adventure book, follow the staged guide in
[authoring/README.md](authoring/README.md), starting with its `CRAFT.md`:
premise, story map, room bible, characters, shot list, page text, 3D blockout,
implementation, illustration, packaging and review, one stage at a time. To
continue The Salt Ledger, read `books/salt/DESIGN.md` first: the premise, the
mood, the plot, and the rules for a new page. A
book is an adventure in the manner of *Zork: The Forces of Krill*: a journey
through many distinct places with forks, strangers, dangers and several
endings, not a puzzle solved in one room. Books remember a few story facts
that later pages check. A book may also have things (ZIL-style objects that lie
in places, are taken, carried, held and used); see
[authoring/THINGS.md](authoring/THINGS.md) and the ledger in The Salt Ledger.

## Runtime

- Each book is data: `books/<name>/title.xml` declares the variables,
  characters, icons (inventory, evidence, idea, emotion, action-icon), records
  (notes, email, photos, phone numbers, interfaces) and nodes, each listing its
  locations; each `books/<name>/locations/<location>.xml` holds that
  location's viewpoints, views, charviews with their conversations, assets,
  maps, action lists and endings. One file per location keeps diffs small and
  lets parallel authors work on different locations. `src/storyxml.c` loads
  them into the tables in `src/book.h` and rejects unknown elements,
  attributes and names with file and line. Prose is folded to single spaces; a
  blank line starts a paragraph and `<region/>` starts the camera's second
  reading region. State is variables, enable flags and carried icons; triggers
  (`enter`, `leave`, `end`) and the actions inside choices change it, and
  `if`/`test` conditions read it. `src/story.c` validates the story at launch,
  runs it and keeps all mutable story state private. Consumers read
  `book_page()`; pages are built through its constructors and
  `publish_page()`. A page's `clip` names `books/<name>/clips/<clip>.mp4`, played in
  the picture, sliced by `from`/`to` and looped behind a view's circles with
  `loop`; the camera still is the poster, and headless play stays on the
  poster. Create whole choice values with explicit `ChoiceKind`;
  never partially overwrite a reused choice or infer its action from text or
  empty strings. A prose book gives every asset Continue. An fmv book
  (`fmv` on the title) draws no prose on views, shots or endings. Continue
  exists only on an asset marked `read`, which is a document being put down.
  Any other asset is a shot: it follows `next` when its clip ends or the
  picture is tapped. Endings have exactly one retry choice. See README's
  "Extending the adventure".
- Inspect and play books with the book tool (`make cli`, then
  `build/cli/book COMMAND BOOK`): `check`, `stats`, `graph`, `query NAME`,
  `play STEP...` and `assets`. It links the same loader, runtime and scene
  reader as the app; use it rather than reading the XML by eye, and run
  `check` and `graph` after editing a book. See README's "The book tool".
  `tests/test_engine.py` plays `tests/fixture/`, which uses every feature the
  reader plays, the map's destinations, notes, email, photos, phone and interfaces among
  them; extend it with each new element or action.
- Route all input through `book_action()`. Drawing and headless input share
  `page_layout()` and `page_hit_test()`; keep control bounds and labels there and
  in the published page. Tests tap the published Continue on a document, send
  `:continue` when a shot finishes, and tap retry.
- The UI discovers tappable targets from the current C page choices. Camera
  names select the matching pictures in `books/<name>/rooms/` and
  `books/<name>/illustrations/`.
- Camera and anchor metadata live in the `.blks` scene source. Keep named
  anchors aligned with the objects and routes shown in every matching image.
- The UI is hardcoded C over Metal with UIKit for iPad and AppKit/NSWindow for
  the fixed-size native Mac testing app. Graphical play uses circle/action taps
  only; reuse its focus, Back and document-Continue flow. A shot leaves on a
  picture tap, or when the clip ends.
- Keep anchors aligned under the same centered crop as the JPEG. Missing art
  must not display another room. Interaction circles must have at least one
  radius of clear space between their edges. Use the shared marker layout for
  drawing, hit areas and headless output; preserve exact projected anchors and
  connect displaced markers to them.

`make mac` (also `make run`) launches the native Mac app; `make ipad-mac`
launches the iPad app on Apple silicon Mac. Build directly with the SDK tools;
do not introduce an Xcode project.

## Artwork

`books/<name>/rooms/` holds pre-rendered JPEGs and the matching `.blks`
camera/anchor source. C reads those files for hotspot projection and per-camera
reading regions. Keep images and metadata synchronized. Scener renders are
spatial references for finished illustrations, not final artwork. Keep camera
perspective, object scale, layout and lighting direction consistent across
views. Do not invent permanent furnishings independently in each image.

Author Scener centimetres, X east, Y north, Z up, degrees and unitless scale.
New scenes declare `up="z"`. Compose establishing cameras obliquely; avoid
frontal views and dominant screen-horizontal architectural lines. Keep
interaction circles in clear space. A prose book, and an fmv document, use the
camera's reading region; an fmv hub does not cover the picture with prose.
Author per-camera `textRect` and optional `textScale` in `.blks`.
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
Use `make render BOOK=countdown SCENE=train` for artwork changes; render and
inspect affected cameras, keeping source and images synchronized. A book not
yet drawn plays on placeholders: run `make placeholders BOOK=<name>` after
adding or changing a camera, an anchor, a clip or the prose a clip shows, and
commit the stamped stills and clips it writes. Finished art replaces a
placeholder at the same path, or as `illustrations/<camera>.png`.
