# Stage 4 — Characters

Define each character's look, size, behaviour and poses so they can be built
as Scener bone skeletons and painted the same way on every page.

## Inputs

- `DESIGN.md`, `work/STORY_MAP.md`, `work/ROOMS.md`
- Scener's `docs/character-authoring.md` (bone skeletons, poses, IK)
- [CRAFT.md](CRAFT.md) §8

## Required actions

1. **Choose a readable hero.** The hero must stay recognisable at 6–8 % of
   the frame height in wide shots. If the natural size is too small for the
   rooms (a mouse in a human house), choose a larger species or a smaller
   world, and record the decision.
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
8. **Pose list.** Every pose the shot list will need, named by action (sit,
   look down, reach up, jump from seat to desk, carry in teeth), with which
   bones re-aim and which paws or hands plant with IK.
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
