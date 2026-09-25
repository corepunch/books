# Stage 9 — Illustration

Paint finished pages over the reference renders. The render fixes
perspective, positions, scale and light; the painting adds material, detail,
atmosphere and character.

## Inputs

- `rooms/<camera>.jpg` for every camera, with its `textRect` from the scene
- `work/ROOMS.md` (materials, painting notes, palette), `work/CHARACTERS.md`,
  `work/SHOTS.md`

## Required actions

1. **Style bible.** At the top of `work/ILLUSTRATION.md`, write the book's
   visual style once: medium and rendering (painterly storybook, soft
   gouache), palette logic per location and time of day, how light behaves,
   level of detail, edge treatment, and the character model sheet (hero from
   front, side and three-quarter, with colours). Every page brief refers to
   it.
2. **One brief per camera.** For each camera, write:
   - the story question from `SHOTS.md`;
   - what must stay exactly as rendered: camera, perspective, horizon,
     furniture and object positions, the hero's pose and position, light
     direction, story objects;
   - what to enrich from `ROOMS.md`: materials and wear, secondary props that
     already have a reason, texture, atmosphere (dust in the lamplight,
     moonlight on the sill);
   - the detail hierarchy: the hero and story object first, the route and
     landmarks second, the room third;
   - the text zone: keep it naturally quiet (plain wall, dark window, soft
     shadow), with even values and no faces, strong edges or clues, and no
     panels or frames;
   - continuity notes: what the previous and next pages show.
3. **Lighting and depth.** Keep the rendered key light and cast shadows, and
   strengthen depth with values: foreground darker or softer, focal area with
   the highest contrast, background hazier. Avoid flat lighting and an
   all-over orange grade; keep each location's own mood.
4. **Keep the world stable.** Never add permanent furniture that is not in
   the blockout, move a route object, or change the hero's design. If a page
   needs something new, add it to `ROOMS.md` and the scene first, then
   re-render.
5. **Collectible objects on room pages.** Paint the full room with the object
   in place. Make a clean plate by removing only that object from the same
   painting, and cut the object from the same painting into a transparent
   full-size layer in `illustrations/items/`, so the in-game object matches
   the room exactly. Keep the plate's text zone unchanged.
6. **Output.** Save finished pages as `illustrations/<camera>.png` at the
   render size. Plates for rooms use the "cleared" camera name. Item layers
   are named `<object>-<camera>.png`.
7. **Review each page** against its brief and render at full size and as a
   thumbnail: story question readable, hero recognisable, anchors still on
   their objects, text zone quiet.

## Outputs

- `work/ILLUSTRATION.md` (style bible and per-camera briefs)
- `illustrations/*.png` and `illustrations/items/*.png`

## Acceptance checks

- Every page matches its render's camera, positions, pose and light
  direction; the hotspot circles still land on their objects.
- The hero looks the same on every page.
- Every text zone is quiet and varies in position between consecutive pages.
- Room plates and item layers come from the same painting and line up
  exactly.
- The book reads correctly in the app with the painted pages.
