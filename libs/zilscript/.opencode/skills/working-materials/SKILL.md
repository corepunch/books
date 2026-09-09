---
name: working-materials
description: Create the design artifacts (MAP, OBJECTS, PUZZLES, STORY_STATE, TRANSCRIPT_TESTS) that externalize world structure and puzzle logic
---

Create the design artifacts that externalize world structure and puzzle logic.

## Inputs
- `DESIGN.md`

## Required Actions
1. Build `MAP.md` with room graph, blocked exits, and rationale.
2. Build `OBJECTS.md` with IDs, synonyms, flags, locations, puzzle role.
3. Build `PUZZLES.md` with goal, clue chain, wrong attempts, hint tiers, softlock prevention.
4. Build `STORY_STATE.md` with globals, counters, milestones.
5. Build `TRANSCRIPT_TESTS.md` with golden path and failure-path plans.
6. Keep a dungeon report/changelog for iterative memory.
7. Add an opening-scene spec to `DESIGN.md`/`MAP.md` (landmark, object, blocker, first reward).
8. Annotate `MAP.md` with hubs, loops, landmarks, and any one-way/non-Euclidean transitions.
9. Tag each important object with at least two roles: practical use, clue, worldbuilding, joke, risk, score marker.
10. Record at least one alternate or fallback approach for major puzzles when feasible.
11. Add explicit unwinnable-state prevention notes to puzzle and state docs.
12. Define progress structure (score/chapter/rank/objective milestones) in `STORY_STATE.md`.
13. Add co-play and discussion surfaces (shared vocabulary, parent hints, printable notes/log prompts).
14. Treat `TRANSCRIPT_TESTS.md` as an exact command contract, not pseudocode. For every critical step record:
    - exact typed command, including spaces or hyphens;
    - expected room/object output;
    - required noun synonyms and adjectives;
    - state change and inventory/location change;
    - a likely alternate wording and wrong-order attempt.
15. Keep `OBJECTS.md` parser-facing: list the canonical head noun, exact compound spelling, adjectives, ambiguity risks, containment flags, and discovery command for every object.
16. Populate `OBJECTS.md` from every concrete noun promised by room prose, blocked exits, and puzzle responses. Do not list a door, window, drawer, switch, rope, vehicle, gate, or container only in `STORY_STATE.md` as a Boolean; give the physical entity its own object row and reserve globals for supplementary or abstract state.
17. Add a prose-to-mechanics audit column to `MAP.md`: for each directional phrase in a room description, record the matching exit and destination. Record intentional one-way routes explicitly.
18. Add scope and parser-gating columns to `OBJECTS.md`: initial/possible locations, rooms where globally in scope, relevant topic/NPC scope, required parser flags (such as `TAKEBIT`, `CONTBIT`, `SEARCHBIT`, or `CLIMBBIT`), and the default verbs that must remain available.
19. Extract every player-facing noun from `DESC`, `FDESC`, `LDESC`, room prose, and hints into the vocabulary plan; include singular, plural, and collective head nouns players are likely to repeat verbatim.
20. **Prevent duplicate objects across the world.** Each distinct physical item (knife, key, rope, etc.) must exist as exactly one object instance. Do not place functionally identical items in multiple locations (e.g. a knife in the kitchen drawer AND a knife in the workshop). If a player needs a knife for a puzzle, place it in one location and ensure that location is reachable from the puzzle's solution path. If the same object type appears in multiple rooms for worldbuilding, either (a) make them distinct objects with different descriptions and properties, or (b) use scenery/NDESCBIT for non-interactive duplicates and clearly document why only one is interactive.

## Outputs
- `MAP.md`
- `OBJECTS.md`
- `PUZZLES.md`
- `STORY_STATE.md`
- `TRANSCRIPT_TESTS.md`

## Acceptance Checks
- Every room has a role.
- Every puzzle has clue chain and reasonable-failure responses.
- Every critical state transition is represented in `STORY_STATE.md`.
- Geography is mostly mappable and room naming is consistent enough for player notes.
- Opening setup is concrete and testable in under one minute of play.
- Object and puzzle docs support both mastery play and hint-assisted completion.
- Every golden-path command is valid player input rather than an internal object ID or direct `PERFORM` shorthand.
- Every noun in the opening slice has an explicit parser-vocabulary plan before ZIL implementation begins.
- Every prose-promised route has a matching map edge, and every described fixture has a matching object location/scope entry.
- No two distinct object instances share the same functional purpose or are both portable versions of the same item type; duplicate items are either consolidated into one object or explicitly differentiated with distinct descriptions, properties, and puzzle roles.

## Reference Sources
- `skills/source_zil_text_adventure_agents.md`: section 1, sections 2.3-2.4, section 5.3
- `skills/source_writing_adventures.md`: Working Materials section
