# Stage 7 — 3D blockout

Build the room bible as one Scener scene per location group, with every
camera from the shot list, and render the reference images the painter works
over.

## Inputs

- `work/ROOMS.md`, `work/CHARACTERS.md`, `work/SHOTS.md`
- Scener instructions, read in full before editing
  (`~/Developer/mapview/ui/apps/scener`):
  - `skills/populate-simplegl-scenes/SKILL.md`
  - `skills/populate-simplegl-scenes/references/world-logic.md`
  - `skills/populate-simplegl-scenes/references/scene-format.md`
  - `docs/character-authoring.md`

## Required actions

1. **Scene file.** Create `rooms/<scene>.blks` with `up="z"`, centimetres,
   X east, Y north. Put the resident story and route summary in its leading
   comment.
2. **Shell first.** Floor, walls, ceiling, doors and windows as in
   `ROOMS.md`. Every camera is inside the room, so every wall is visible; use
   real doors and windows rather than invisible walls.
3. **Model what is marked M.** Build the items `ROOMS.md` marks M (shell,
   furniture, story objects, clues, route steps, large shadow casters). Leave
   P items to the painter; the blockout is a spatial reference, not the art.
   Exterior backdrops can be simple volumes and a background colour.
4. **Furniture and props as prefabs.** Write Z-up prefabs in `rooms/prefabs/`
   (adapting Scener's library where useful), each with a leading comment
   stating footprint, baseline and front direction. Place them at the
   positions in `ROOMS.md`. Every object rests on its stated support; nothing
   floats or stands on hidden stands.
5. **Characters as bone skeletons.** Build each character from
   `CHARACTERS.md` with `<bone>` chains, `mirror`, `segments`, `taper` and
   `foot="1"`. Fix limb lengths until Scener reports no foot clearance
   warnings. Never place character spheres by hand in xyz.
6. **Poses.** Define each pose as a scene `<pose>` with `aim` re-aims and tip
   IK (`<ik tip="…">`, `plant="1"` for feet that stay put). Treat
   `IK … out of reach` as an error.
7. **Lighting.** Place the motivated lights from `ROOMS.md` inside their
   fixtures, with open shades (`<cylinder tube="…">`). Keep ambient at or
   below about 0.35. Render once with `ambient="0 0 0"` to confirm the lights
   alone read the room with visible cast shadows.
8. **Story objects and anchors.** Give each story object a named group whose
   name matches its C object key (`CopperStar` for `copperstar`). Add named
   anchor groups for route choices (`Chair`, `Sill-Ledge`).
9. **Cameras.** Add every camera from `SHOTS.md` with `textRect` and
   `textScale`. Place characters per camera with `<transform target="…">`
   plus `<use-pose>`. Show each picture state with its own camera, using
   camera `<transform>` to move or hide the objects that differ.
10. **Load cleanly.** `scener --list-cameras rooms/<scene>.blks` must print no
   warnings: no ignored attributes, no sealed lights, no missing prefabs, no
   foot or IK messages.
11. **Render and review.** From the repository root run
    `make render BOOK=<name> SCENE=<scene> WIDTH=1536 HEIGHT=1152`. Tile the
    JPEGs into a contact sheet and apply Scener's world-logic review gate to
    every camera: point out floating objects, props with no reason, impossible
    moves, empty or cramped framing, hidden faces, and text zones on busy
    areas. Fix and re-render until each camera answers its story question.
12. **Model sheets.** Build a small `rooms/model-sheet.blks` with each
    character in its rest pose and the turnaround and scale-line-up cameras
    from `CHARACTERS.md`, plus close cameras on each story object. Render it
    with `make render BOOK=<name> SCENE=model-sheet`. Cameras here are
    painters' references, not pages.
13. **Plan view.** Run `make layout BOOK=<name> SCENE=<scene>` for a top-down
    plan. Check it against the footprint and furniture positions in
    `ROOMS.md`; it is also the basis for the map in stage 10.
14. **Safe area and circles.** For each room camera, confirm the story
    objects, clues and anchors sit at least 5 % inside the frame, and that the
    text zone holds none of them.

## Outputs

- `rooms/<scene>.blks`, `rooms/prefabs/…`
- `rooms/<camera>.jpg` for every camera, model-sheet renders, and a plan
  view

## Acceptance checks

- The scene loads with no Scener warnings.
- Every object has a support and a reason visible in at least one camera.
- Every action camera shows actor, action and target, with the hero's face
  readable where the shot calls for it.
- Cast shadows are clearly visible and every light has a visible source.
- Text zones sit on quiet surfaces, and every anchor projects inside its
  camera.
