# Adventure Skills Reference

This folder contains reference source materials for the stage-specific skills located under `.opencode/skills/`.

## Source Mirrors

These preserve the full canonical source material used by the individual skills:

- `source_zil_text_adventure_agents.md` — Full design & implementation reference (830 lines)
- `source_writing_adventures.md` — Full craft + technical manual (1911 lines)
- `source_design_lessons.md` — Design lessons and principles

## Skill Pipeline

The staged adventure-building guidance lives in `.opencode/skills/`. Each skill folder contains a `SKILL.md` with detailed instructions for that stage. Load a skill with:

```
skill <name>
```

Available skills:

| Skill | Covers |
|-------|--------|
| `foundation-and-premise` | Premise, tone, design doc |
| `working-materials` | MAP, OBJECTS, PUZZLES, STORY_STATE, TRANSCRIPT_TESTS |
| `world-model` | Puzzle fairness, parser vocabulary, simulation checks |
| `content-writing` | Prose craft, NPC depth, artistic quality patterns |
| `zil-implementation` | ZIL syntax, critical rules, clock daemons, patterns |
| `testing` | Transcript execution, bug categorization, walkthrough hardening |
| `workflow-hints` | Review passes, hint UX, iteration planning |
| `packaging` | Release artifacts, definition of done |
| `playtesting` | Blind functional play sessions and parser regressions |
| `artistic-review` | Narrative architecture, genre craft, pacing, contrast, and ending quality |
| `accessibility-testing` | Target-audience usability and accessibility persona sessions |
| `quality-assurance` | Independent technical, functional, artistic, and accessibility release passes |
| `bug-fixing` | Fixing technical and functional ZIL defects |

## Adventure Folder Structure

All adventures should follow this directory organization:

```
adventure-name/
├── DESIGN.md              # Stage 1: Premise, tone, win/lose
├── PLAN.md                # Implementation plan (optional)
├── dungeon.zil            # Stage 5: Rooms, objects, world data
├── actions.zil            # Stage 5: Routines, puzzle logic, NPCs
├── work/                  # Stages 2-4, 7: Working materials
│   ├── MAP.md             # Room graph and navigation
│   ├── OBJECTS.md         # Object registry with flags
│   ├── PUZZLES.md         # Puzzle design with solutions
│   ├── STORY_STATE.md     # Game state variables
│   ├── TRANSCRIPT_TESTS.md # Test transcript plans
│   ├── PROSE.md           # Room/object descriptions, NPC topics
│   ├── ILLUSTRATION_PLAN.md # Selected dramatic beats and composition briefs
│   ├── HINTS.md           # Progressive hint system
│   └── ITERATION.md       # Development roadmap
├── test/                  # Stage 6: Testing materials
│   ├── TESTING.md         # Regression tests, bug ledger
│   ├── QUALITY.md         # Stage 9: Consolidated specialist QA ledger
│   └── walkthrough.zil    # Golden path test file
└── package/               # Stage 8: Packaging & release
    ├── COVER.md           # Visual description
    ├── TAGLINE.md         # Marketing taglines
    ├── SYNOPSIS.md        # Story summaries
    ├── REVIEWS.md         # Critical reviews
    └── METADATA.md        # Technical details
```

Illustrated adventures may also add `ARTSTYLE.zil` and
`CHARACTER_DESIGN_BIBLE.md` at the adventure root, plus host-specific image
assets and a logical-key manifest. Follow
[`docs/ILLUSTRATING_ADVENTURES.md`](../docs/ILLUSTRATING_ADVENTURES.md); do not
infer illustration coverage from rooms alone.

## Non-Negotiable: Play As You Build

Do not write the whole adventure and wait for Stage 6 to play it. Build vertical slices:

1. Write the exact player commands for one room or puzzle in `TRANSCRIPT_TESTS.md`.
2. Implement only that slice.
3. Start a fresh game and execute those commands through `llm.lua`, one saved invocation per command.
4. Test the obvious noun variants, wrong order, repeated action, inventory, and save/reload boundary.
5. Add the successful commands to the automated parser-driven walkthrough.
6. Continue only when the slice passes.

The walkthrough grows with the game. At every commit-sized milestone, all implemented slices must still be playable from a fresh game.

## Critical Rules (from Real Bugs)

**These caused broken games. Read before implementing.**

1. **No `<SYNTAX ...>` in dungeon.zil and no redefinition of standard syntax** — standard SYNTAX comes from substrate (`infocom/zork1/syntax.zil`). A genuinely new verb may add one narrow declaration in `actions.zil`.
2. **No `<ROUTINE V-LOOK ...>` in actions.zil** — V-LOOK comes from substrate. Redefining it breaks room descriptions.
3. **Room descriptions use `P?LDESC` not `P?DESC`** — `P?DESC` is the room name, `P?LDESC` is the full description.
4. **Every `<TELL>` must close with `>`** — unclosed TELL swallows subsequent code.
5. **GO must exist in actions.zil** — entry point for the game.
6. **Assign one visible description owner** — focal/portable objects usually own `FDESC`/`LDESC`/`DESCFCN`; permanent or stateful scenery may be room-owned and backed by `NDESCBIT` objects or pseudos. Test rendered `LOOK` output for duplication, dead `FDESC`, and stale state.
7. **Never freeze mutable state into `LDESC`** — follow Zork I's `EAST-HOUSE` pattern.
8. **Object IDs and DESC text are not parser vocabulary** — every reachable object needs explicit `SYNONYM` nouns and `ADJECTIVE` modifiers.
9. **Opening a container must make contents reachable** — use container/search flags, set `OPENBIT`.
10. **Evidence and milestone counters must be idempotent** — guard one-time increments with per-clue flags.
11. **Default verb routines never redispatch themselves** — `PERFORM` already visits object actions before the default.
12. **Parser syntax and action routines are separate deliverables** — a `V-*` routine does not register a typed verb.
13. **ASK uses the TELL action and `PRSI` topic** — NPC routines test `<VERB? TELL>` and compare the topic in `PRSI`.
14. **Puzzle clues and executable sequences must agree** — reconcile prose, hints, object availability, implementation order, and the parser-driven walkthrough before shipping.
15. **FDESC/LDESC text is the parser vocabulary contract** — every concrete noun in description text that a player might reasonably type must resolve to that object or another object in scope.
16. **ACTION routine text must match game objects** — when a TELL inside an ACTION routine mentions an object by name, that object must exist in the game world.
17. **Don't override EXAMINE on containers** — the Zork engine automatically lists contents via `V-LOOK-INSIDE` → `PRINT-CONT`.
18. **Physical nouns are objects, not Boolean shortcuts** — if prose says there is a door, window, switch, drawer, rope, vehicle, or other thing, create an `OBJECT` for it.
19. **Custom V-GO routines must mirror every conditional exit** — every conditional exit declared on rooms must be replicated inside the matching V-GO routine.
20. **NPCs and key objects need generous, overlap-tested vocabulary** — give every NPC role-based synonyms, title adjectives, and `ARTICLEBIT`.
21. **No two objects in overlapping scope may share DESC or SYNONYM sets** — identical `DESC` strings on objects that can be in scope together cause disambiguation loops.
22. **Dynamic room text must faithfully reflect object state** — every state-dependent phrase must be paired with the exact flag check that produces it.
23. **NPC-given items must guard against early TAKE** — if an NPC carries an item meant to be given during conversation, the item's TAKE handler must check the relevant global.

See `skills/source_writing_adventures.md` and `skills/source_zil_text_adventure_agents.md` for full details, or load `skill zil-implementation` for the critical implementation rules.

## Room and Object Flags

See the individual skills under `.opencode/skills/` for flag reference tables.
