# Stage 9 — Illustration

Paint the finished pages. The render is a rough spatial reference that keeps
every page consistent: camera, layout, scale, the hero's pose and the light
direction. The painting is the art: material, detail, atmosphere, character
and charm. Paint *over* the model's decisions, not its surfaces.

## Inputs

- `rooms/<camera>.jpg` for every page camera, with its `textRect`
- Model-sheet renders and the plan view from stage 7
- `work/ROOMS.md` (materials, palette, painted-detail registry),
  `work/CHARACTERS.md`, `work/SHOTS.md` (story questions, clues, colour script)

## What the painter keeps and what the painter may change

**Keep** (the reader relies on these across pages):

- the camera, perspective and horizon, and the page's framing;
- the position, scale and facing of the hero, characters, furniture, story
  objects and routes;
- the hero's pose and gesture;
- the key light direction and the main cast shadows;
- every clue the shot promises, clearly visible;
- the text zone as a quiet area, and each anchor's object at its rendered
  position (so the circles still land on it).

**Change freely** (this is where the art lives):

- materials, textures, wear and colour, following `ROOMS.md`;
- blockout simplifications: boxy furniture becomes turned legs and carved
  aprons, spheres become fur, an ellipsoid becomes a face;
- small props and dressing, provided a detail seen on more than one page is in
  the painted-detail registry and painted the same way each time;
- atmosphere: dust in the light, haze, glow, depth of field;
- small adjustments to proportion or pose for appeal, as long as the silhouette
  and position still match.

Never add or move permanent furniture, a route, or a story object on one page
only. If a page needs that, change `ROOMS.md` and the scene, and re-render.

## Required actions

Work in this order; approve each step before the next.

1. **Style bible.** At the top of `work/ILLUSTRATION.md`, write the book's
   visual style once: medium and rendering (painterly storybook, soft
   gouache), edge treatment, detail density, how light and shadow behave,
   and what to avoid (flat lighting, an all-over orange grade, decorative text
   panels, clutter competing with the hero).
2. **Character model sheets.** Paint each character over the turnaround
   renders: front, side, back, three-quarter, the expression set from
   `CHARACTERS.md`, and a scale line-up next to the chair or another landmark.
   Every page paints the character from these sheets.
3. **Story object sheets.** Paint each story object and clue close up from its
   model-sheet render, with its states. Its look on every page comes from
   here.
4. **Location key art.** For each location, paint one master painting from
   its widest camera, applying the materials, palette and registry details.
   This fixes how the place looks; all other pages of that location match it.
5. **Colour script.** Lay out small thumbnails of every page in story order,
   following the colour script in `SHOTS.md`, to check the flow of light and
   mood across the book before painting pages in full.
6. **Page briefs.** For each camera, write in `ILLUSTRATION.md`: the story
   question; the keep list specific to this page (hero pose, story objects,
   clues, anchors); what to enrich; the detail hierarchy; the text zone and
   how to keep it quiet naturally (plain wall, dark window, soft shadow, with
   even values and no faces or edges); continuity notes (what the previous and
   next pages show).
7. **Paint the pages** in story order, each from its render, its location key
   art, the model sheets and the registry. Strengthen depth with values:
   foreground softer or darker, the focal area with the highest contrast,
   background hazier. Keep each location's own mood.
8. **Collectible objects on room pages.** Paint the full room with the object
   in place. Make the clean plate by removing only that object from the same
   painting, saved under the "cleared" camera's name. Draw the object's
   outline in `illustrations/items/polygons.json` and run
   `swift tools/extract_items.swift books/<name>/illustrations` to cut the
   transparent full-size layer (`items/<object>-<camera>.png`), a compact crop
   and `items/rects.json`. The in-game object then matches the room exactly.
9. **Files.** Save pages as `illustrations/<camera>.png` in 4:3, ideally at the
   render size. The `illustrations/` folder is local and not in git; keep a
   backup.
10. **Review each page** in the app, at full size and as a thumbnail: story
    question readable, hero on model, clues visible, circles still on their
    objects, text readable in its zone, and continuity with its neighbours.

## Outputs

- `work/ILLUSTRATION.md` (style bible, sheet notes, colour script, page briefs)
- Character and object sheets, location key art (kept with the illustrations)
- `illustrations/*.png`, `illustrations/items/*.png`,
  `illustrations/items/polygons.json`

## Acceptance checks

- Every page keeps its render's camera, layout, pose, light direction and
  clues, and the circles land on their objects in the app.
- Every page of a location matches its key art; recurring details match the
  registry.
- The hero and story objects match their sheets on every page.
- Text zones are quiet and vary in position between consecutive pages.
- Plates and item layers come from the same painting and line up exactly.
- Read in order, the colour script builds and releases rather than staying one
  mood.
