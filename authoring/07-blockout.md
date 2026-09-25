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
3. **Furniture and props as prefabs.** Write Z-up prefabs in `rooms/prefabs/`
   (adapting Scener's library where useful), each with a leading comment
   stating footprint, baseline and front direction. Place them at the
   positions in `ROOMS.md`. Every object rests on its stated support; nothing
   floats or stands on hidden stands.
4. **Characters as bone skeletons.** Build each character from
   `CHARACTERS.md` with `<bone>` chains, `mirror`, `segments`, `taper` and
   `foot="1"`. Fix limb lengths until Scener reports no foot clearance
   warnings. Never place character spheres by hand in xyz.
5. **Poses.** Define each pose as a scene `<pose>` with `aim` re-aims and tip
   IK (`<ik tip="…">`, `plant="1"` for feet that stay put). Treat
   `IK … out of reach` as an error.
6. **Lighting.** Place the motivated lights from `ROOMS.md` inside their
   fixtures, with open shades (`<cylinder tube="…">`). Keep ambient at or
   below about 0.35. Render once with `ambient="0 0 0"` to confirm the lights
   alone read the room with visible cast shadows.
7. **Story objects and anchors.** Give each story object a named group whose
   name matches its C object key (`CopperStar` for `copperstar`). Add named
   anchor groups for route choices (`Chair`, `Sill-Ledge`).
8. **Cameras.** Add every camera from `SHOTS.md` with `textRect` and
   `textScale`. Place characters per camera with `<transform target="…">`
   plus `<use-pose>`. Hide collected story objects in "cleared" cameras by
   moving them out of the room.
9. **Load cleanly.** `scener --list-cameras rooms/<scene>.blks` must print no
   warnings: no ignored attributes, no sealed lights, no missing prefabs, no
   foot or IK messages.
10. **Render and review.** From the repository root run
    `make render BOOK=<name> SCENE=<scene> WIDTH=1536 HEIGHT=1152`. Tile the
    JPEGs into a contact sheet and apply Scener's world-logic review gate to
    every camera: point out floating objects, props with no reason, impossible
    moves, empty or cramped framing, hidden faces, and text zones on busy
    areas. Fix and re-render until each camera answers its story question.

## Outputs

- `rooms/<scene>.blks`, `rooms/prefabs/…`
- `rooms/<camera>.jpg` for every camera

## Acceptance checks

- The scene loads with no Scener warnings.
- Every object has a support and a reason visible in at least one camera.
- Every action camera shows actor, action and target, with the hero's face
  readable where the shot calls for it.
- Cast shadows are clearly visible and every light has a visible source.
- Text zones sit on quiet surfaces, and every anchor projects inside its
  camera.
