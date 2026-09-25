# Stage 3 — Room bible

Describe every location completely enough that one person can model it in 3D
and another can paint every page of it consistently, without asking
questions. This is the richest document in the book. The reader never sees
it; page text (stage 6) stays short because the picture and this bible carry
the detail.

The bible serves two different jobs:

- **Modelling** needs measurable facts: sizes, positions, supports, heights,
  light positions. The blockout is a spatial reference, not the art. It holds
  large forms, story objects, routes and anything that casts an important
  shadow.
- **Painting** needs look and consistency: materials, wear, colour,
  atmosphere, and fine details that are painted, not modelled, but must appear
  the same in every shot that sees them. The painter uses the render as a
  rough guide to camera, layout and light, and is free to enrich everything
  else within this bible.

So every item below is marked **M** (modelled in the blockout) or **P**
(painted only, recorded here for continuity).

## Inputs

- `DESIGN.md`, `work/STORY_MAP.md`
- Scener's world-logic reference:
  `~/Developer/mapview/ui/apps/scener/skills/populate-simplegl-scenes/references/world-logic.md`

## Required actions

For each location, write every section below. Use centimetres and compass
directions (X east, Y north, Z up) so stage 7 can build it directly.

1. **Resident story.** Two or three sentences: who lives or works here, what
   they were doing just before the story, and how long the place has been
   used. Every later item needs a reason that comes from this.
2. **Walk-in description.** One or two paragraphs of evocative, concrete
   prose, as if walking in: what you see first, what is underfoot, the light,
   the air, the sounds. Use senses and materials, not emotion labels. This
   sets the mood for everyone downstream.
3. **Footprint and shell (M).** Interior size and ceiling height and shape,
   or for exteriors the ground area and its slopes. Each door, window, arch
   or gap: which wall, its width, height and sill height, and what is seen
   through it. Floor, wall and ceiling construction (boards, plaster, beams,
   stone).
4. **Exteriors (M and P), when outdoors.** Ground shape and heights, paths
   with widths, water, rocks and large vegetation masses (M, as simple
   volumes); the backdrop in three layers (near, middle, far) with what each
   holds; sky, weather and time of day (P); the scale of distant landmarks.
5. **Furniture and fixtures (M).** A table with one row per piece: name, real
   size, position (distances from walls or landmarks), facing, what it rests
   on, why it is there, age or condition, and the parts it is built from (legs,
   apron, drawers, back slats) so it can be modelled as a prefab. Use real
   proportions (chair seat 45 cm, desk 75 cm, door 200 cm).
6. **Props (M or P).** One row per movable thing: what it is, its size,
   exactly what it rests on or hangs from, why it is there, and its role
   (story, clue, dressing). Model it if it is a story object, a clue, a route
   step, or large enough to cast a notable shadow; otherwise paint it. Group
   clutter the way people leave it: letters in a stack under an inkwell, not an
   aligned brick.
7. **Story objects and states (M).** Each object that choices or facts touch:
   position, size, colour, a one-line design (the brass star has five rounded
   points and a hole for its thread), and how it looks in every state from
   `STORY_MAP.md`. For clue objects, what exactly must be visible and from
   which cameras.
8. **Routes as physical moves (M).** For each route in and out, the exact
   sequence of surfaces with heights and gaps ("floor 0 → chair seat 45,
   pulled 6 cm from the desk → desk top 76"). Check each step against the
   hero's limits from stage 4.
9. **Light (M and P).** The motivated sources: window with time of day and
   direction, each lamp with position and shade type, fire, glow. Colour and
   strength, which one is the key, where the main shadows and pools of light
   fall, and how light changes between states or acts. Ambient is only a low
   fill. Every lamp needs an opening its light can leave through.
10. **Materials and palette (P).** For each surface and major object: material,
    finish, wear and colour (worn honey-coloured varnish, whitewashed plaster
    with a water stain above the window, faded red rug with a cream border).
    Give a small palette per location and say which colours belong to story
    objects so nothing else competes with them.
11. **Painted-detail registry (P).** Fine details that are not modelled but
    must stay consistent across pages: wallpaper or plank patterns, a crack in
    the plaster, pictures on the wall and what they show, the rug's pattern,
    labels on jars, titles on the book spines, stains and scratches, cobwebs.
    For each: where it is, what it looks like, and which cameras are likely to
    see it. Painters add details freely, but anything that appears in more
    than one page belongs here first.
12. **Atmosphere (P).** Sound, smell, temperature and air (dust in the
    lamplight, a draught under the door, the tick of a clock). Page text and
    paintings draw on these.
13. **Sightlines and connections.** What is visible from where, which
    landmarks connect this location to others, and how each connection looks
    from both sides (the attic door seen from inside and from the stairs).
14. **Quiet surfaces for text.** The calm areas that can hold page text (a
    plain wall, the dark window, a shadowed floor), so stage 5 can place text
    zones on real surfaces.
15. **Detail hierarchy.** What must read first (hero, story object), second
    (route, landmarks), third (room character), and what must stay quiet.

## Output

`work/ROOMS.md`, one section per location in the order above, with tables for
furniture, props, story objects and the painted-detail registry, and prose for
the rest.

## Acceptance checks

- Every object has a support, a reason, a real size and a position, and is
  marked M or P.
- Every story object and clue is modelled, designed in one line, and described
  in every state.
- No routes are built from props stacked into stairs; each uses furniture or
  fixtures the resident owns, and every step fits the hero's limits.
- Every light source is motivated, named, and able to reach the room.
- Every detail that recurs across pages is in the painted-detail registry.
- A modeller could build the shell, furniture and story objects from this
  document alone, and a painter could choose materials, palette and recurring
  details from it.
