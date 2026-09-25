# Stage 5 — Shot list

Give every page exactly one camera and decide what it shows, where the text
sits and where the choice circles land.

## Inputs

- `work/STORY_MAP.md`, `work/ROOMS.md`, `work/CHARACTERS.md`
- Scener's `references/shot-composition-guide.md`

## Required actions

1. **One camera per page and per picture state.** Name cameras
   `location-verb-object`, for example `floor-show-room`,
   `floor-climb-table`, `table-take-copper-star`. A room page whose picture
   changes with a fact gets a second camera (`floor-show-cleared-room`) or an
   item layer.
2. **Story question.** For each shot, write the one thing the reader must
   understand at a glance: "Mira is halfway between the chair and the desk".
3. **Actor, action, target.** Who is in frame, what they are doing (a pose
   from `CHARACTERS.md`), and what they act on. Action pages always show all
   three; never imply an action by pointing the camera at an empty object.
4. **Framing and camera height.** Wide (orientation, whole location), medium
   (action with its surroundings), or close (a discovery). Put the camera near
   the hero's eye height for intimate shots and higher for maps. Use oblique
   three-quarter views; avoid square-on walls.
5. **Continuity.** List the landmarks visible in the shot so the reader
   always knows where they are, and check that furniture and light direction
   match `ROOMS.md`.
6. **Text zone.** Choose a quiet surface from `ROOMS.md` for the page text as
   a normalised rectangle (x y width height of the image). Alternate sides
   between pages. Keep it off faces, the hero, stars or story objects, and
   routes.
7. **Choice anchors.** For room pages, list each choice's anchor: the named
   point in the scene where its circle appears (the star itself, the chair
   seat, the sill edge). Every choice on a room page must have an anchor
   visible in that page's camera, with clear space between circles and away
   from the text zone.
8. **Picture state.** Which facts are shown (which stars are still there,
   door open or shut) and where the hero stands.

## Output

`work/SHOTS.md` with a table: camera, page ID, story question, actor/action/
target, framing, landmarks, text zone, anchors, picture state.

## Acceptance checks

- Every page in `STORY_MAP.md` has exactly one camera, and every picture
  state has a camera or item layer.
- Every action shot shows the actor, the action and the target.
- Every room-page choice has an anchor visible in that camera.
- Text zones sit on quiet surfaces and avoid the hero, story objects and
  anchors.
- Wide shots keep the hero at 6–8 % of frame height or more.
