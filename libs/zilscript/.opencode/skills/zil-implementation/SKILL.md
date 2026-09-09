---
name: zil-implementation
description: Implement game logic in ZIL with clean dungeon.zil / actions.zil split, clock daemons, and the critical rules that prevent compilation and gameplay bugs
---

Implement game logic in ZIL with clean split between world data and routines.

## Inputs
- All prior stage outputs

## Required Actions
1. Implement `dungeon.zil` for rooms, objects, and declarative world data.
2. Implement `actions.zil` for routines, daemon/clock behavior, and `GO`.
3. Implement an executable walkthrough entry.
4. Use the engine include chain consistently.
5. Apply advanced ZIL patterns where needed (GLOBAL objects, PSEUDO, FDESC/LDESC, PER exits, dynamic descriptions, transformations, daemons).
6. Implement one playable vertical slice at a time. After each room, object, puzzle, or NPC interaction, play its exact transcript through `llm.lua` before adding the next slice.
7. Grow a parser-driven walkthrough test alongside implementation.

## Outputs
- `dungeon.zil`
- `actions.zil`
- `walkthrough.zil`
- Parser-driven walkthrough test under `tests/`

## Acceptance Checks
- Parser/object/room routines compile and run.
- Puzzle state changes are explicit and traceable.
- Dynamic text and clock events are deterministic enough to test.
- Exact transcript noun phrases parse before and after a save/reload boundary.
- Each completed slice is reachable from a fresh game.

## Critical Implementation Rules

### 0. Never redefine V-LOOK or standard SYNTAX
The substrate (`infocom/zork1/`) provides V-LOOK and the standard SYNTAX definitions.

### 0a. Make parser vocabulary explicit
Object IDs and `DESC` strings are not automatically usable nouns. Every player-reachable object needs explicit SYNONYM and ADJECTIVE entries.

### 0b. Make containers reveal reachable contents
A printed "open" response is not enough. The world model must change — set `OPENBIT`, move contents inside.

### 0c. Guard one-time story progress
If TAKE, READ, and EXAMINE can all reveal a clue, route them through one guarded transition.

### 0d. Implement ASK/TELL topics for this substrate
`ASK ACTOR ABOUT TOPIC` and `TELL ACTOR ABOUT TOPIC` both reach the actor with `PRSA = V?TELL`. Test `<VERB? TELL>` and inspect `PRSI`.

### 0e. Never redispatch the same action from its default verb routine
`PERFORM` already dispatches. A default routine must produce the fallback, not call PERFORM again.

### 0f. Audit parser registration separately from action routines
A `V-USE` routine does not make the typed verb parse. Add SYNTAX declarations for genuinely new verbs.

### 0g. Keep puzzle instructions, implementation, and tests identical
For every ordered puzzle, maintain one canonical sequence and copy it exactly into clues, hints, and walkthrough.

### 0h. Treat titles as modifiers in multiword NPC names
Put the head noun in SYNONYM and titles in ADJECTIVE.

### 0i. Represent physical world state with objects, not flag-only scenery
Doors, windows, drawers, switches, ropes, vehicles, gates, and containers must be real objects.

### 0m. Prefer real OBJECTs over PSEUDO for scenery nouns
Every concrete noun in prose must resolve through the parser. The most robust way is a real `OBJECT` with `(FLAGS NDESCBIT ...)` — this makes the noun parseable without adding clutter to the automatic room listing. Give scenery `OBJECT`s generous `SYNONYM` and `ADJECTIVE` coverage, and an `ACTION` routine covering `EXAMINE` plus any verbs the prose implies (e.g. `RUB`, `SIT`, `SMELL`, `LISTEN`, `READ`).

Use `PSEUDO` only for trivial one-word scenery where the handler does nothing beyond `EXAMINE` and the word would never need synonyms, adjectives, or state (e.g. "ASHES" → "Cold grey ashes."). Reserve `PSEUDO` for words that would be confusing as standalone `OBJECT` names (atmospheric debris, abstract stains, minor surface details). For any scenery noun a player might ask about with a compound phrase ("rusty iron bars"), prefer a real `OBJECT` — PSEUDO handlers cannot match multi-word descriptions natively and require fragile `VOC-EXACT` wiring.

`NDESCBIT` suppresses automatic LDESC listing without hiding the object from the parser. This is the correct pattern for scenery: a parseable noun that does not occupy a room-listing line.

### 0j. Object ACTION routines must fall through for unhandled verbs
An object `ACTION` routine is a selective override, not a blanket handler. Return true only inside a branch that actually handles the current verb. Never put an unconditional trailing `<RTRUE>` after the routine's `<COND>`: it swallows substrate defaults such as TAKE, DROP, OPEN, CLOSE, LOOK-IN, and SEARCH and can produce silent no-ops. Let unmatched verbs return false so the default verb routine runs. After adding or editing an object action, smoke-test at least EXAMINE plus every applicable generic operation (TAKE/DROP for portable objects; OPEN/CLOSE/LOOK-IN for containers).

### 0k. Parser reachability is a four-part contract
An authored handler is reachable only when vocabulary, syntax, scope, and flags all agree. Before relying on an object-specific branch, verify:
- every concrete noun used in prose is in the object's `SYNONYM` list;
- the standard syntax accepts the intended wording and dispatches the action name tested by the object handler. Trace the exact mapping in `infocom/zork1/syntax.zil`: bare `CLIMB OBJECT` dispatches `V-CLIMB-FOO`, while `CLIMB UP OBJECT` dispatches `V-CLIMB-UP`, so a handler supporting both must test `CLIMB-FOO` and `CLIMB-UP`. Adding `CLIMBBIT` alone does not make `CLIMB-FOO` match a branch that only tests `CLIMB` or `CLIMB-UP`; `FIND` flags guide implicit-object resolution, not action matching for an explicit noun;
- the object is actually in the room, inventory, containment tree, or room `GLOBAL` list where the command is issued;
- conversation topic objects used as `PRSI` are in scope in every room where the NPC can be asked or told about them.

### 0l. Keep prose, topology, and object placement mechanically consistent
Every direction promised by room prose must exist as an exit in that room and lead where the prose claims. Every fixture named as present must be in scope from that room. Audit both sides of every intended two-way connection, and re-check objects mentioned by dynamic room descriptions after moving them.

### 1. Assign one visible description owner
Use a hybrid object model:
- portable, surprising, and focal objects normally own their automatic `FDESC`/`LDESC`/`DESCFCN`;
- permanent architectural scenery and spatial relationships may be described by room `LDESC`/`M-LOOK`, with real, GLOBAL, or PSEUDO objects using `NDESCBIT` for parser affordance;
- stateful prose belongs to one dynamic room action or object `DESCFCN`.

Do not repeat the same facts through room prose and an automatic object description. Do not put `NDESCBIT` on an object whose `FDESC` is expected to replace text removed from the room. A named noun must parse even when its description is room-owned.

On this substrate, untouched objects with `FDESC` are printed directly by `PRINT-CONT` before `DESCFCN` is consulted. For a stateful object whose automatic listing is owned by `DESCFCN`, omit `FDESC`; otherwise the static discovery text shadows the dynamic routine until the object gains `TOUCHBIT`.

### 2. Every `<TELL>` must close with `>` before the next form
Missing `>` is the most common and hardest-to-spot bug.

### 3. Define `ROUTINE GO ()` in actions.zil
The game entry point must exist. Set up HERE, LIT, WINNER, PLAYER, call V-LOOK, call MAIN-LOOP.

### 4. Custom SYNTAX uses `= V-ROUTINE`
Only add syntax for verbs absent from the substrate. Search `infocom/zork1/syntax.zil` first.

### 5. Bracket balance: every `<` needs a matching `>`

### 8. Custom V-GO direction handlers must mirror every conditional exit
Every conditional exit declared on a room must be replicated inside the matching V-GO routine.

### 9. NPCs and named objects need generous, overlap-tested vocabulary
Give every NPC role-based synonyms, title adjectives, and ARTICLEBIT.

### 10. No two objects in overlapping scope may share a DESC
Give every object a unique DESC text and distinct ADJECTIVE.

### 11. Dynamic room descriptions must faithfully reflect object state

This includes geography and scope: a described eastward route needs an east exit, and a described staircase, container, or other fixture must resolve in that room. After every state change, audit both the room-owned text and automatic object listing for stale or contradictory descriptions.

### 12. NPC-given items must not be freely TAKE-able before the NPC offers them

### 13. Pronoun resolution with THIS-IS-IT
After any TELL that names an object, call THIS-IS-IT so the player can refer to it by pronoun.

### 14. Autonomous NPC movement with clock daemons

### 15. Mechanical stateful clock daemons
Every mechanical clock daemon must have visible feedback at each stage threshold and interact with EXAMINE on relevant objects.

### 16. No duplicate portable objects across the world
Each portable item type (knife, key, rope, etc.) must exist as exactly one object instance. Do not implement functionally identical items in multiple locations (e.g. a knife in the kitchen drawer AND a knife in the workshop). If a puzzle requires an item, place it in one reachable location. If the same item type appears in multiple rooms for worldbuilding, either (a) make them distinct objects with different `DESC`, states, and puzzle roles, or (b) use scenery with `NDESCBIT` for non-interactive duplicates and document why only one is interactive.

## Reference Sources
- `skills/source_zil_text_adventure_agents.md`: section 4
- `skills/source_writing_adventures.md`: Game Structure, ZIL Syntax Reference, Advanced Techniques, Complete Example
