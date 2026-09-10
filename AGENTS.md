# Book Engine Guide

Book is a native engine for multiple visual interactive ZIL adventures.
The complete application currently lives in `main.c`. Keep it in one C file
until the user asks to split it. `fonts/` contains shared application assets.
`libs/zilscript/` is the only Lua dependency; read its `AGENTS.md` and
`ARCHITECTURE.md` before modifying the VM.

## Runtime

- C loads the selected ZIL adventure through zilscript and resumes its coroutine
  directly with `lua_resume`. ZIL owns all game state, text, rooms, objects and
  actions. Do not duplicate adventure rules in C or a presentation manifest.
- Discover interaction choices from the VM's object/verb metadata and room
  exits. Derive image names from ZIL identifiers, lowercased with hyphens:
  `{room}-look.jpg`, `{room}-examine-{object}.jpg`, `{room}-{verb}-{object}.jpg`.
- `books/<adventure>/rooms/` holds pre-rendered JPEGs and the matching `.blks`
  camera/anchor sources. C reads those files solely for hotspot projection.
  Do not introduce a live scene renderer, Lua host scripts, Orca XML exports,
  UI configuration files or hand-maintained image/interaction maps.
- The UI is hardcoded C over libplatform/OpenGL. Reuse its focus, Back,
  Continue and parser-command flow. Keep anchors aligned under the same
  centered crop as the JPEG. Missing art must not display another room.
- `make run BOOK=<name>` selects an adventure. The conventional ZIL entry point
  is `libs/zilscript/books/<name>/<name>.zil`. No new C code is needed per book.

## Artwork

Wondertown art and historical studies live in `books/wondertown/work/`.
Read only the relevant guides: `LOCATION_BRIEFS.md` for story geography,
`SCENE_COMPOSITION.md` for density/cameras, `ARTSTYLE.md` and
`CHARACTER_DESIGN_BIBLE.md` for the approved storybook identity, and
`RENDERING.md` for the offline workflow. Archived Orca/prototype documentation
is historical and does not define the current engine.

Scener is a separate checkout at `~/Developer/mapview/ui/apps/scener`.
Read that checkout's instructions before changing it. Author centimetres,
X east, Y north, Z up, degrees and unitless scale. New scenes declare `up="z"`.
Geometry belongs in `.blks` scenes and `.blk` prefabs; finished/review images
must be raster, never SVG. Keep connected zones in shared coordinates and
named interactive anchors aligned with exact ZIL IDs.

## Validation

Run `make check` after host changes. It builds the single C file and tests real
coroutine interactions, inferred asset names and projection without a display.
For display changes, run a graphical smoke capture and inspect the JPEG with
its hotspot/UI overlays. Do not rerender unchanged artwork just to test C code.
Use `make render BOOK=<name> SCENE=<scene>` for artwork changes; render and
inspect affected cameras, keeping their source and images synchronized.
