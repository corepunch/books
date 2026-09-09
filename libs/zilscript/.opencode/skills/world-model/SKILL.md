---
name: world-model
description: Translate design docs into a coherent simulation plan — validate puzzle fairness, audit parser vocabulary, and prevent softlocks before writing ZIL
---

Translate design docs into a coherent simulation plan before full implementation.

## Inputs
- `MAP.md`
- `OBJECTS.md`
- `PUZZLES.md`
- `STORY_STATE.md`
- Existing `companion.zil` and `companion/COVERAGE.json` when generating or
  reviewing companion choices

## Required Actions
1. Define parser-facing action model (verb, direct object, indirect object).
2. Validate object/room checklist coverage.
3. Validate puzzle fairness:
   - clear goal
   - discoverable information
   - guessable command vocabulary
4. Validate dependency graph and prevent softlocks.
5. Define default response strategy and custom overrides for likely wrong attempts.
6. Audit every planned noun phrase before implementation:
   - object identifiers and `DESC` do not automatically make words parseable;
   - the head noun belongs in `SYNONYM`;
   - modifiers belong in `ADJECTIVE`;
   - exact hyphenated transcript spellings belong in `SYNONYM` when supported;
   - two in-scope objects sharing a noun need distinguishing adjectives.
7. Define container visibility transitions: where contents begin, which action sets `OPENBIT`, and which flags let the parser search inside.
8. Define each one-time counter as `event flag -> guarded increment`, including which verbs can discover the same clue.
9. Audit physical nouns against the object registry. Every described fixture or obstacle that affords player actions must be a real object with vocabulary, scope, flags, and behavior; do not substitute a global Boolean for a door, window, container, switch, vehicle, or similar world entity.
10. Cross-audit prose against mechanics before implementation:
   - every directional claim in room prose matches a declared exit and destination;
   - intended return routes are present or explicitly documented as one-way;
   - every object described as present is in that room's parser scope;
   - every noun phrase used in prose, including collective nouns such as "bundle," appears in parser vocabulary.
11. Verify bidirectional exit consistency before implementation:
   - for every `<ROOM A ... (DIR TO B ...)>`, room B must have a matching `<ROOM B ... (OPPOSITE-DIR TO A ...)>` (or the asymmetry must be documented);
   - no two rooms should form a unidirectional loop (e.g. A NORTH → B and B NORTH → A);
   - conditional exits (`IF X IS OPEN`) must have the reverse exit in the destination room with the same or compatible condition;
   - room descriptions that name a location ("looks out to the garden," "door to the kitchen") must have a matching exit property pointing there.
12. Build a parser-reachability row for each authored interaction: exact command, syntax form, required `FIND` flag, object/topic scope, and expected handler/default routine. Do not assume an object action can compensate for syntax or scope that prevents parser resolution.
13. For every NPC conversation matrix, list the topic objects and every room where the exchange can occur; those rooms must expose the topics through `GLOBAL` or another proven scope mechanism.
14. **Audit for duplicate objects across the world.** Scan `OBJECTS.md` for functionally identical items (e.g. two knives, two keys, two ropes) placed in different locations. Each portable item type must be unique; consolidate duplicates or explicitly differentiate them with distinct descriptions, states, and puzzle roles. Document any intentional duplicates (e.g. a knife in a museum display vs. a functional knife) and verify only one is interactive.
15. **Build complete companion state coverage when a companion is in scope.**
    - Enumerate every source `<ROOM ...>` declaration and classify it as
      reachable, conditionally reachable, unreachable, terminal, or exempt.
    - Require the classified-room count to equal the declared-room count.
    - Give every reachable room at least one state family.
    - Split families when inventory, player knowledge, puzzle milestone, NPC
      phase, clock/hazard state, or entry route materially changes useful or
      honest choices.
    - Include optional rooms, mazes, return and recovery routes, deaths, and
      alternate endings; absence from the golden path is not an exemption.
    - Record a reproducible checkpoint or exact parser command setup for every
      reachable family in `companion/COVERAGE.json`.

## Infocom-Quality Simulation Checks
- Build a command matrix for each major puzzle with at least ten likely player attempts; implement useful responses for the top attempts.
- Ensure common parser verbs and synonyms are covered (`look`, `examine`, `open`, `close`, `take/get`, `drop`, `read`, `put`, `unlock`, `attack`, `listen`, `smell`, `wait`, `again`, inventory shortcuts).
- Keep the puzzle challenge in idea-space, not wording-space; avoid single exact-verb bottlenecks.
- Ensure world state is physical and persistent (object movement, room state changes, blocked/unblocked routes, timed hazards).
- Prefer object state (`OPENBIT`, containment, location, visibility) over parallel global state. Use globals for abstract facts and milestones, or to supplement a real object when the substrate lacks a specific state such as `LOCKEDBIT`.
- Preserve challenge while reducing accidental cruelty (telegraphed danger, recoverable mistakes, explicit unwinnable-risk handling).
- Prefer meaningful mazes over filler mazes; if maze-like areas exist, provide landmarks or distinct mechanics.
- Support optional mastery with alternate/risky/clever solutions where feasible.

## Outputs
- Updated puzzle dependency graph
- Object/verb response matrix
- Softlock mitigation list
- Complete room classification and state-family manifest when companion work is
  in scope

## Puzzle Artistry: Good vs. Bad Patterns

### 1. Puzzles Should Be the Story, Not Reskinned Item Gates
Replace "find key → unlock door" with: performing a ritual, understanding a character's history, arranging objects in a pattern, choosing the right moment, or demonstrating a quality the story values.

### 2. Narrative Arc: Three Escalating Acts
Structure your game in three acts with clear threshold moments. Each act should have a different dominant challenge type (exploration → deduction → confrontation).

### 3. Room Cohesion: A Real Place, Not a Trope Checklist
Every room must either (a) subvert its apparent function, or (b) be visible/audible from at least one other room.

### 4. World State Must Change After Thresholds
Every major story event must change at least 2 existing rooms — either through updated dynamic descriptions (ACTION + M-LOOK), changed object states (FCLEAR flags), or new objects appearing.

### 5. NPC Autonomy: Characters That Move Through the World
An ACTORBIT object must have at least one autonomous behavior (movement, approach, state change) driven by a clock daemon.

### 6. Object Interaction Depth: Tool Chains and System Combinations
At least 2 major puzzles must require chaining 3+ objects or considering an object's state (hot/cold, charged/drained, wet/dry) as a puzzle variable.

### 7. Clock-Driven Mechanical Depth: Systems That Simulate, Not Just Decorate
Every clock daemon must do at least one of: (a) advance a numerical state that has gameplay consequences, (b) cause autonomous NPC behavior, or (c) modify object state that another system reads.

## Acceptance Checks
- No puzzle depends on inaccessible prerequisites.
- Reasonable command attempts have authored responses.
- Defaults are overridden where narrative/puzzle intent requires.
- Navigation model supports player mapping and repeat travel without confusion.
- At least one long-loop puzzle requires carrying knowledge or objects between distant locations.
- The first vertical slice can be played with the exact planned commands before the next slice is implemented.
- Repeating TAKE/READ/EXAMINE or opening an already-open object cannot duplicate progress or strand contents.
- Every physical noun named in room prose or a blocked-exit message resolves to an object in scope and supports the obvious generic verbs.
- No two object instances serve the same functional purpose; duplicates are consolidated or explicitly differentiated with distinct descriptions and puzzle roles.
- Every direction stated in prose is traversable as stated, or the prose clearly identifies why it is blocked.
- Every declared exit has a matching reverse exit in the destination room (or the asymmetry is documented as intentional).
- No two rooms form a unidirectional compass-direction loop.
- Bare and prepositional variants promised by the design (for example, `CLIMB BENCH` and `CLIMB UP BENCH`) both reach an intentional response.
- For companion work, every declared room is classified exactly once, every
  reachable room has authored state families, and no reachable room is declared
  complete with fallback-only support.

## Reference Sources
- `skills/source_zil_text_adventure_agents.md`: sections 3, 4, 5
- `skills/source_writing_adventures.md`: Part I sections 2, 3, Suggested Build Order
