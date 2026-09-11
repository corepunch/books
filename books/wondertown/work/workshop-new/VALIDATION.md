# Workshop spatial-reference review — 2026-09-11

This records review of Scener references for the AI illustration pass. These
JPEGs are development backgrounds, not accepted final illustrations. Earlier
Orca-era commands and validation counts are superseded by this record.

- All 33 scene/prefab XML sources parse, and referenced prefab paths resolve.
- The overview camera is now oblique, with a lower-left reading region. The
  other 24 camera transforms and all existing interaction anchors are unchanged.
  The SAWDUST group deliberately has no particle geometry;
  its required painted footprint is recorded in [DESIGN.md](DESIGN.md).
- `make render BOOK=wondertown SCENE=workshop-new` renders all 25 JPEGs at
  1920 × 1440 on Apple M1 / OpenGL 4.1 Metal, with shadows and default 2×
  supersampling. The camera contact sheets and individual overview, bench,
  loft, window, reverse and book views were inspected.
- `make layout BOOK=wondertown SCENE=workshop-new` was inspected for the new
  timber rack and supply cabinet footprints. Both occupy wall-side space;
  the center route, door approach, bench access and loft landing remain clear.
- New picture frames are mounted against the inside wall faces, away from the
  window, door, tool rack and structural posts. Their blank insets intentionally
  reserve fixed locations for painted landscape/toy-study contents.
- The book's upper cover now meets its page block and spine at Z=8, removing
  the overlapping front edge exposed by simplifying its ornament.
- `make check` passed: geometry, transition, real coroutine interaction,
  inferred images, focus/navigation and projection. It does not certify
  furniture collisions or final painted-image registration.
- The native `--smoke` capture was inspected with prose and interaction circles.
  The full overview passage fits in its lower-left region without scrolling,
  clear of all ten circles. Automated checks include a 12-point gutter around
  each circle, metadata validation, font fitting/overflow, default placement,
  reload/reset behavior and normalized-region mapping through centered crops.
  The overview marker-spacing revision retains all ten circles with a measured
  minimum edge gap of 24.02 points. Hook/string and ladder/mechanism markers now
  separate, using short connectors to their unchanged anchors. The native
  capture was inspected; text remains clear. Layout tests cover coincident
  anchors, page edges, text exclusion and deterministic placement on Mac and
  iPad viewport sizes.
  The iPad simulator application also builds and packages successfully.
  The sawdust circle correctly remains over the reserved floor area, which is
  intentionally bare until the AI pass. The generator also reproduces the
  reviewed scene and prefabs byte for byte.

Current source: [workshop-new.blks](../../rooms/workshop-new.blks).
Review views: [overview](../../rooms/workshop-floor-look.jpg),
[reverse](../../rooms/workshop-return.jpg),
[loft](../../rooms/storage-loft-look.jpg), and
[bench](../../rooms/workbench-top-look.jpg).
`rooms/layout.jpg` is a local diagnostic, not a runtime camera.

The final AI pass must still paint sawdust, picture contents, texture, wear,
fine fittings and approved character designs. Review those outputs against
adjacent views, the scene brief and the actual Book hotspot/UI overlay. No
changed-state or action-animation images were added in this revision.
