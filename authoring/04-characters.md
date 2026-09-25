# Stage 4 — Characters

Define each character's look, size, behaviour and poses so they can be built
as Scener bone skeletons and painted the same way on every page.

## Inputs

- `DESIGN.md`, `work/STORY_MAP.md`, `work/ROOMS.md`
- Scener's `docs/character-authoring.md` (bone skeletons, poses, IK)
- [CRAFT.md](CRAFT.md) §8

## Required actions

1. **Choose a readable hero.** The hero must stay recognisable at 6–8 % of
   the frame height in wide shots. A child or small adult human reads best in
   a journey: people fit every place the story visits, from a cottage to a
   cliff, and strangers are people too. If the hero is an animal, check the
   scale against every location on the route, and record the decision.
   Give the hero one or two bright story colours (a yellow coat, a red hat)
   that nothing else in any location uses.
2. **Scale sheet.** Height, length, head size, reach, and the step or jump
   limits used by the routes in `ROOMS.md`. Recheck every route step against
   these limits.
3. **Silhouette and design.** Proportions (head as a fraction of height),
   distinctive shapes that read at thumbnail size (ear shape, tail, hat),
   colours and markings with names ("smoke grey with white socks and a pink
   nose"), and one or two recurring costume or prop details.
4. **Face and expressions.** Eye shape and colour, and the expressions the
   pages need (curious, proud, startled, sleepy). Faces are painted, not
   modelled; list them so every painter draws the same set.
5. **Personality in the body.** How the character stands, moves and reacts:
   bold, careful, curious. Poses in stage 5 should show it.
6. **Behaviour and states.** For characters other than the hero, the states
   from `STORY_MAP.md` and how each looks (asleep with tucked head, awake
   with fluffed feathers).
7. **Skeleton plan.** For Scener bones: the root and spine (links, curve),
   neck and head, limbs with `mirror`, tail and ears with `segments` and
   `taper`, and surface details placed with `on`. List bone names; poses and
   IK refer to them.

   **People share one skeleton.** Build every human from the same template
   with the same bone names, so one pose library serves the whole cast:

   ```text
   spine (root, aim 0 90, 2 segments)
   ├── hem        coat or skirt hanging from the hips (at 0.12, from 0 -90, aim 0 -90, taper > 1)
   ├── neck → head   head extras with on=: hat, cap, scarf, eyes, nose; braid or beard bones
   ├── left_arm (at 0.92, from 90 0, aim 10 -85, mirror) → left_forearm → left_hand
   └── left_thigh (at 0.02, from 90 -40, aim 0 -90, mirror) → left_shin → left_foot (foot=1)
   ```

   Vary only lengths, girth and materials per person. Scale the head more
   slowly than the body (a child's head is a larger share of its height), so
   children read as children and adults as adults at thumbnail size.
   Name materials per person (`varya_coat`, `savely_beard`) and define them in
   each scene that shows that person. The Lighthouse cast in
   `books/lighthouse/rooms/prefabs/characters/` is a working set.
8. **Pose list.** Every pose the shot list will need, named by action (walk,
   run, balance on a plank, hang from a rope, sit, row, point, push a door),
   with which bones re-aim and which feet or hands plant with IK.

   A joint's `aim` is relative to its parent's *current* direction, not the
   body's. With a thigh re-aimed from `0 -90` to straight forward (`0 0`), the
   shin must be aimed `0 -178` to hang down; a child keeps its parent's turn
   unless re-aimed. Prefer re-aims to IK for poses reused across cameras: IK
   targets are world positions, so an IK pose only fits the one place it was
   made for.
9. **Model sheet shots.** Plan turnaround cameras (front, side, back,
   three-quarter) and a scale line-up next to a familiar object (the chair)
   for stage 7 to render. These renders plus the painted model sheet from
   stage 9 are the painters' reference.

## Output

`work/CHARACTERS.md` with one section per character: Scale, Silhouette and
design, Face and expressions, Personality, Behaviour and states, Skeleton
plan, Poses, Model sheet shots. Stage 7 builds
`rooms/prefabs/characters/<name>.blk` from it.

## Acceptance checks

- The hero reads clearly in the widest planned shot.
- Every route step in `ROOMS.md` is within the hero's limits.
- Every pose and expression needed by a page is listed.
- Every important character has visible states that the story changes.
- The design can be described in one breath and drawn from memory.
