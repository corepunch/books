# Stage 3 — Room bible

Describe every location completely enough that one person can model it in 3D
and another can paint it without asking questions. This is the richest
document in the book. The reader never sees it; page text (stage 6) stays
short because the picture and this bible carry the detail.

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
2. **Footprint and shell.** Interior size, ceiling height and shape (flat,
   sloped, beams), and which wall each door, window or opening is on, with its
   size and sill height. Floor, wall and ceiling materials and their condition.
3. **Furniture.** A table with one row per piece: name, real size, position
   (distance from walls), facing, what it rests on, why it is there, and its
   age or condition. Use real proportions (chair seat 45 cm, desk 75 cm,
   door 200 cm).
4. **Props.** One row per movable thing: what it is, exactly what it rests on
   or hangs from, why it is there, and whether it is story-critical, a clue,
   or dressing. Group clutter the way people leave it: letters in a stack
   under an inkwell, not an aligned brick.
5. **Story objects and states.** Each object that choices or facts touch, its
   position, and how it looks in every state from `STORY_MAP.md` ("the copper
   star lies on the second letter; after it is found, the letter is bare").
6. **Routes as physical moves.** For each route in and out: the exact
   sequence of surfaces with heights and gaps ("floor 0 → chair seat 45,
   pulled 6 cm from the desk → desk top 76"). Check each step against the
   hero's limits from stage 4.
7. **Light.** The motivated sources (window with time of day and direction, a
   named lamp, a fire), their colour and strength, which one is the key, and
   where the main shadows fall. Ambient is only a low fill. Every lamp needs an
   opening its light can leave through.
8. **Atmosphere.** Sound, smell, temperature and air (dust in a sunbeam,
   draught, cold stone). Page text and paintings draw on these.
9. **Sightlines.** What is visible from where: which landmarks connect this
   location to others. This keeps pages coherent and gives the reader a
   mental map.
10. **Painting notes.** Materials and wear worth showing (worn varnish,
    patched curtains), a palette hint, and a detail hierarchy: what must read
    first, second and third.
11. **Quiet surfaces for text.** The calm areas that can hold page text
    (a plain wall, dark window, shadowed floor), so stage 5 can place text
    zones on real surfaces.
12. **Longer description.** One or two paragraphs of evocative, concrete
    prose describing the room as if walking in. This is for the modeller's and
    painter's imagination, not for the reader. Use senses, materials and light;
    no emotion labels in place of detail.

## Output

`work/ROOMS.md`, one section per location in the order above. Tables for
furniture, props and story objects; prose for the rest.

## Acceptance checks

- Every object has a support, a reason, a real size and a position.
- No routes are built from props stacked into stairs; each uses furniture
  or fixtures the resident owns.
- Every route step fits the hero's limits.
- Every light source is motivated, named, and able to reach the room.
- Every story object has a described look in every state.
- A modeller could build the shell and furniture from this document alone,
  and a painter could choose materials and palette from it.
