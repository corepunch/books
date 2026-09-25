# Stage 5 — Shot list

Give every page exactly one camera and decide what it shows, where the text
sits, where the choice circles land, and how the page looks in the sequence.

## Inputs

- `work/STORY_MAP.md`, `work/ROOMS.md`, `work/CHARACTERS.md`
- Scener's `references/shot-composition-guide.md`
- [CHOICES.md](CHOICES.md) (anchors and caption space)

## Required actions

1. **One camera per page and per picture state.** Name cameras
   `location-verb-object`, for example `floor-show-room`,
   `floor-climb-table`, `bridge-cross-river`. Camera names are unique
   across the whole book. A room page whose picture changes with a fact gets
   another camera (`gate-show-open`), painted as its own whole picture.
   Consecutive story pages of one continuous moment may share a camera (the
   knights ride up, the knight speaks); a new place, a new action or a new
   decision gets a new camera. Most cameras show a different place from the
   previous one.
2. **Story question.** For each shot, the one thing the reader must
   understand at a glance: "Varya is halfway across the stones and the water is rising".
3. **Actor, action, target.** Who is in frame, what they are doing (a pose
   and expression from `CHARACTERS.md`), and what they act on. Action pages
   always show all three; never imply an action by pointing the camera at an
   empty object.
4. **Framing and camera height.** Wide (orientation, whole location), medium
   (action with its surroundings), or close (a discovery or a clue). Put the
   camera near the hero's eye height for intimate shots and higher for maps.
   Use oblique three-quarter views; avoid square-on walls. Vary framing from
   page to page.
5. **Clues and continuity.** List the clues from `STORY_MAP.md` that this shot
   must show clearly, the landmarks visible (so the reader always knows where
   they are), and the recurring painted details from `ROOMS.md` that fall in
   frame. On reconverging pages, note the detail that acknowledges the path
   taken.
6. **Colour script.** For each page, its time of day, dominant light and mood
   (warm lamplight, cold moonlight, first dawn). Read the column top to bottom:
   the book should build and release, not stay one colour.
7. **Text zone.** Choose a quiet surface from `ROOMS.md` for the page text as
   a normalised rectangle (x y width height of the image). Alternate sides and
   heights between consecutive pages. Keep it off faces, the hero, story
   objects, clues and routes.
8. **Choice anchors.** For room pages, each choice's anchor: the named point
   where its circle appears (the star itself, the chair seat, the sill edge).
   Every anchor must be visible in that camera. Circles are 48 px across on an
   1100 × 800 page, so anchors need at least a circle's radius of clear space
   from each other, and must stay out of the text zone. Each circle also shows
   its caption, so keep about 250 × 60 px free on one side of every anchor.
9. **Safe area.** Pages are 4:3; on wider screens the app crops about 3 %
   from the top and bottom. Keep the hero, story objects, clues, anchors and
   text zones at least 5 % inside every edge.
10. **Picture state.** Which facts are shown (which stars are still there,
    door open or shut) and where the hero stands.

## Output

`work/SHOTS.md` with a table: camera, page ID, story question,
actor/action/target, framing, clues and continuity, colour script, text
zone, anchors, picture state.

## Acceptance checks

- Every page in `STORY_MAP.md` has exactly one camera, and every picture
  state has its own camera.
- Every action shot shows the actor, the action and the target.
- Every clue the story map relies on is visible in the shots that promise it.
- Every room-page choice has an anchor visible in that camera, with clear
  space and inside the safe area.
- Text zones sit on quiet surfaces, avoid the hero, story objects and anchors,
  and vary between consecutive pages.
- Wide shots keep the hero at 6–8 % of frame height or more.
