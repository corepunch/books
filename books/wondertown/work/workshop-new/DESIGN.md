# Workshop spatial reference and illustration handoff

Scener reference scene for final AI-painted storybook images. Geometry fixes
object shapes, inventory, scale, placement, occlusion and shadows across views.
Simple proxies are intentional; material finish and fine detail belong to painting. Coordinates: X east, Y north, Z up, centimetres.
`books/wondertown/rooms/workshop-new.blks` explicitly declares `up="z"` for Scener.

The workshop is 860 × 1030 cm (Y = −270…760), with a 400 cm ceiling. A high camera inside the south
wall sees three walls: a working bench and missing-key station to the
left, the rear pet door and storage loft ahead, and the tool bench/display to
the right. A small stocked repair trolley presents its top in the foreground.
The central floor remains walkable. The three primary visual directions are
left to the workbench, ahead to the pet door, and right to the tool bench;
upward travel to the loft is a fourth, conditional route.

The establishing shot is the interaction overview. Every workshop-floor subject
must be represented there, including the oil can underneath the bench's open front.
SAWDUST is the deliberate painted-only exception: its anchor and camera remain,
but raw reference renders contain no particle geometry.
Detail cameras supplement it. The back affordance belongs to the presentation
layer, in the lower-right screen corner, and returns each focus shot to
its physical parent area; it is not a painted sign or invented world exit.

Source: `libs/zilscript/books/wondertown/dungeon.zil`, workshop floor, workbench
top, tool bench, countertop, storage loft and their objects. The initial story
state has an empty hook with string, an available oil can, a closed repair book,
a locked ladder mechanism and dormant toys. Scene decoration is noninteractive.

Architecture and furniture are new design decisions: warm plaster above teal
wainscot, thick oak joinery, Roman-arched openings, shallow recessed shelving,
a loft supported on posts, a copper/brass practical over each working zone.
The frosted shop window supplies cool contrast; practical lamps light the
work surfaces and cast grounded shadows. Procedural boards provide floor scale
and direction; the final illustration supplies grain, wear and sawdust.

Density passes: shell and trim; recognizable benches/clock/loft; stocked shelves
and open furniture bays; framed pictures, timber storage, supply cabinet and
broad bench-tool shapes. Omit individual bristles, screws, page lines, dial ticks
and window frost from the geometry.
Keep every cluster physically supported and preserve identifying silhouettes.
Use 4:3 delivery at 1920 × 1440 to fit the Book page without horizontal cropping.

Coverage includes all five interior location cameras, every authored focus
subject identified by the ZIL source, and a threshold/reverse view. Focus images
are object coverage; they do not claim to depict animated actions or character
performances. Future book-open, oil-removed and ladder-deployed variants must
follow ZIL state and keep all permanent furniture fixed.

## Reproduction and review

See [VALIDATION.md](VALIDATION.md) for delivered image checks and their limits.

```sh
# From the engine root; use Scener as described in ../RENDERING.md.
make all
python3 books/wondertown/work/tools/build_workshop_new.py
make render BOOK=wondertown SCENE=workshop-new WIDTH=1920 HEIGHT=1440
make layout BOOK=wondertown SCENE=workshop-new
```

The new family is `books/wondertown/rooms/prefabs/workshop-new/`, independent of the former
workshop assets. `build_workshop_new.py` regenerates architecture, furniture,
fixtures and the scene, leaving the hand-authored `props/` family intact.

Review `books/wondertown/rooms/workshop-floor-look.jpg` and a contact sheet of
the named camera JPEGs for coverage. Do not generate SVG reviews or overlays. Navigation and Back
controls belong in Book's UI and must respect ZIL access conditions. The `.jpg`
renders contain no UI.

This workshop is the active Wondertown scene. `make run BOOK=wondertown`
launches the native C engine in `src/` with existing JPEGs. Scener generates the
reference images offline; the native host reads `.blks` cameras, reading regions and named anchors for
text placement and hotspot projection, preserving the source Z-up coordinate system. No camera
export or per-book presentation manifest is required.

No action-animation frames or changed-state variants are claimed. Inspect
prefab support/contact, routes and all changed camera images at final size;
metadata projection checks do not validate geometry or foreground occlusion.

## Reference revision — 2026-09-11

Added five picture frames to the west, east and rear walls, using subdued blank
insets for landscape/toy-study paintings. The three south-wall frames now use
the same simple prefab. The west foreground holds a rack of four timber blanks;
the east foreground has a low supply cabinet with paper rolls and a labeled box.
A cup of broad tool handles sits at the back of the main bench; two fabric rolls
occupy the rear of the loft. These are noninteractive dressing, not new clues.
All are shared geometry visible from the same positions in every camera.

Story-object placement, anchors, lamps, architectural openings and circulation
remain fixed. The overview camera was subsequently recomposed as described below;
the other 24 cameras retain their transforms. Preserve recognizable tiny story props even though
most detail is simplified. The clock hands indicate nearly midnight; the case
stays closed. Floor-level open supply crates retain their contents and footprint,
with plain sides replacing slats and dark straps. Shelf/loft boxes stay plain
closed boxes with labels, as approved.

## Overview reading-space revision

The overview now looks diagonally from `(330, -220, 345)` toward
`(-30, 410, -70)`, vertical FOV 65°. The lower-left floor reserves normalized
`textRect="0.04 0.66 0.56 0.30"`, with preferred `textScale="0.85"`.
All ten story hotspots remain visible above this region. The initial prose
fits fully without scrolling; no story text or interaction was removed.
Other cameras retain their transforms and legacy prose placement for now.

Keep the reserved floor softly textured with even warm/dark values in the final
painting. Grain and any scattered sawdust must not compete with cream prose.
Do not add props, bright scraps, hard shadows or picture-like panels inside it.
The room remains shared geometry; this is a camera choice, not a per-shot move
of the furnishings. Use oblique perspectives and avoid dominant horizontal
architectural lines in future establishing shots.

## What the AI paints

| Reference | Final illustration requirement |
|---|---|
| Bare reference floor / SAWDUST | Paint soft golden sawdust across floorboards, with a denser irregular area near the west bench, roughly X −249…−115, Y 264…476 cm. The unchanged SAWDUST anchor is (−182, 370, 0); the focus camera looks into this area. Keep a consistent footprint in the overview, bench approach and sawdust close-up. Paint small shavings within it instead of adding particle meshes. |
| Solid broom head | Worn bristles and polished handle within the rough silhouette. |
| Plain green repair book | Closed green leather volume; paint grain, page edges and restrained binding details. Do not invent readable clues. |
| Clock case and hands | Aged cuckoo clock, near midnight, with painted dial markings and selective ornament. Preserve hands, silhouette and closed initial state. |
| Blue window pane | Frost, muted exterior atmosphere and glass finish; keep the arch, muntins, sill and source of cool light aligned. |
| Plain picture insets | Non-narrative landscapes or toy studies, consistent in every view. They are mounted pictures, never UI panels or new clue documents. |
| Timber, cabinet, fabric rolls and containers | Rich material treatment and appropriate surface detail within their shared proxy sizes and placements. |
| Existing toy figures | Use the approved character designs and story state, respecting reference scale, support and pose; rough mesh detail is not the final character design. |

For each final image, use its Scener JPEG together with this handoff, ARTSTYLE.md,
relevant character references and adjacent approved views. Keep exact perspective,
major object silhouettes/footprints and lighting direction. Painterly shading,
softness, texture, wear and atmosphere may improve substantially. Check painted
story subjects against the real hotspot overlay before accepting the image.
