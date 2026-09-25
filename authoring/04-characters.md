# Stage 4 — Characters

Define each character's look, size and poses so they can be built as Scener
bone skeletons and painted consistently on every page.

## Inputs

- `DESIGN.md`, `work/STORY_MAP.md`, `work/ROOMS.md`
- Scener's `docs/character-authoring.md` (bone skeletons, poses, IK)

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
   colours and markings, and one or two costume or prop details that recur.
4. **Personality in the body.** How the character stands, moves and reacts:
   bold, careful, curious. Poses in stage 5 should show it.
5. **Skeleton plan.** For Scener bones: the root and spine (links, curve),
   neck and head, limbs with `mirror`, tail and ears with `segments` and
   `taper`, and surface details placed with `on`. List bone names; poses and
   IK refer to them.
6. **Pose list.** Every pose the shot list will need, named by action (sit,
   look down, reach up, jump from seat to desk, carry in teeth), with which
   bones re-aim and which paws or hands plant with IK.
7. **Other characters.** The same sheet for every other character who
   appears, including how their size compares with the hero's.

## Output

`work/CHARACTERS.md` with one section per character: Scale, Silhouette and
design, Personality, Skeleton plan, Poses. Stage 7 builds
`rooms/prefabs/characters/<name>.blk` from it.

## Acceptance checks

- The hero reads clearly in the widest planned shot.
- Every route step in `ROOMS.md` is within the hero's limits.
- Every pose needed by a page exists in the pose list.
- The design can be described in one breath and drawn from memory.
