# Generating `companion.zil`

## A Repeatable Authoring and Validation Process

This document explains how to add a companion choice layer to an existing ZIL
adventure. It covers discovery, play, choice design, implementation, validation,
and release evidence.

The companion API and file format are specified in
[COMPANION-ZIL.md](COMPANION-ZIL.md). This document answers a different
question: how do we produce a complete and trustworthy `companion.zil` for a
particular adventure?

For agent-assisted generation, invoke:

```text
@companion-author Generate, validate, and document complete full-game companion coverage for <game-name>.
```

The agent definition is in
[`../.opencode/agents/companion-author.md`](../.opencode/agents/companion-author.md).

## The Short Version

Generating a companion is not a source-to-source conversion and not a single
playthrough. It is a coverage exercise:

1. Locate the adventure's entry point, sources, tests, walkthroughs, and load
   path.
2. Inventory **every declared room**, exit, object, puzzle state, NPC phase,
   hazard, and ending; classify every room as reachable, unreachable, or exempt.
3. Play a clean golden path one parser command at a time.
4. Divide the adventure into **state families**: situations in which the useful
   choices are materially different.
5. Design candidate cards for every reachable room and state family.
6. Implement those cards in `companion.zil`, one vertical slice at a time.
7. Restore or construct each matching state and execute every card's hidden
   command through the real parser.
8. Replay the complete game using only numbered choices in companion mode,
   including backtracking and at least one non-golden branch.
9. Test save/restore, restart, query purity, grouping, and fallback behavior.
10. Publish a machine-readable state-family manifest, a human-readable coverage
    report, and transcript evidence with the companion.

The shipped `companion.zil` is deterministic ZIL. An agent can help author and
test it, but no model, network call, or generated text is required at runtime.

## What Generation Produces

The preferred output is:

```text
<adventure-directory>/
├── companion.zil
├── companion/
│   ├── COVERAGE.json
│   ├── COVERAGE.md
│   └── TRANSCRIPTS.md
└── test/
    └── <repository-specific companion regression>
```

Use the repository's established test location and naming convention if it
differs. The five deliverables have distinct purposes:

| Deliverable | Purpose |
|---|---|
| `companion.zil` | The deterministic, state-aware candidate generator |
| `COVERAGE.json` | Machine-readable room/state-family setups, expectations, and status |
| `COVERAGE.md` | Generated or synchronized human-readable coverage summary |
| `TRANSCRIPTS.md` | Exact commands, observed output, and choice-driven routes |
| Regression test | Automated checks for important visibility and transition rules |

Do not treat the implementation alone as proof of coverage. A plausible command
can still be unrecognized, ambiguous, blocked in the relevant state, or produce
misleading results.

A generated companion is complete only when every reachable room has authored
support, every material state family is validated, and the game can be completed
in companion mode without typed commands. Automatic fallback is a
runtime safety net, not releasable authored coverage. `FALLBACK-REVIEWED` and
`NOT-COVERED` are valid interim statuses but fail the completion gate for
reachable gameplay.

## Current Repository Baseline

As audited on 2026-07-28:

- `llm.lua` registers multiple playable games. Zork I and The Limehouse
  Killings have a `companion.zil`; the remaining registered games rely on
  fallback behavior.
- Zork I declares 110 rooms. Its current companion contains 110 authored cards
  and explicit `SUGGEST-ACTIONS` routing for 32 rooms, leaving 78 declarations
  without explicit room routing.
- The Zork I companion regression exercises the opening card route only, ending
  on arrival in the Cellar; it does not validate all newer underground cards.
- Zork I has no committed `companion/COVERAGE.json`, `COVERAGE.md`, or
  `TRANSCRIPTS.md`.
- The Limehouse Killings declares 11 rooms and its companion contains 122
  `CHOICE` call sites representing 100 distinct IDs. Its focused regression
  passes 12 assertions, but five assertions inspect source text and none
  exhaustively executes every emitted command from a matching state.
- The Limehouse manifest reports zero validated state families. The original
  commit summary said 11 state families while its per-room entries summed to 19;
  this audit corrected the count to 19. The transcript described `--choices 6`,
  although `main.lua` accepts only 1 through 5 and `llm.lua` has no
  companion-choice interface. Treat these artifacts as authored coverage and a
  useful retrospective, not release-grade validation evidence.
- `llm.lua` does not yet implement `--choices` or `--choose`; exhaustive tests
  must currently use an adventure-specific Lua runner around
  `COMPANION_QUERY` and `COMPANION_SELECT`.
- `zork1-companion-qa-report.md` describes an older seven-room version and is
  not current full-game coverage evidence.

This is a snapshot, not a substitute for regenerating the declared-room and
coverage counts. The release tooling must calculate them from the current
source and manifest.

## Fast, Token-Efficient Authoring Path

The full workflow is intentionally thorough, but it should not require an agent
to repeatedly reread the adventure, replay common route prefixes, or hand-copy
the same facts into three reports. Use this order:

1. **Extract before interpreting.** Use narrow searches or a small deterministic
   inventory script to list rooms, exits, objects, globals, routines, syntax,
   walkthrough commands, and existing tests. Give the authoring model compact
   extracts grouped by puzzle or room instead of whole source files.
2. **Make `COVERAGE.json` the work queue.** Add room classifications, state
   families, setup commands, candidate drafts, and expected results once.
   Generate counts and human-readable tables from that file.
3. **Reuse route prefixes.** Build a checkpoint tree from the walkthrough:
   opening, pre-puzzle, post-puzzle, hazard, and endgame. Reach each prefix once,
   then clone or restore it for sibling states and candidate executions.
4. **Ship a minimum viable vertical slice first.** For each state, begin with
   the essential progress or safety action, useful investigation, and movement
   actions. Add optional texture only when it remains meaningfully distinct.
5. **Lint before playing.** Reject duplicate or drifting IDs, malformed forms,
   missing movement groups, unsupported CLI options, manifest count mismatches,
   unclassified rooms, and commands absent from the worksheet before spending
   turns on parser validation.
6. **Validate in one persistent runner.** Load the game once, restore isolated
   checkpoints in process, query companion mode, select by stable ID, and write
   structured JSONL evidence. Avoid starting a new shell process and replaying
   the opening for every assertion.
7. **Generate prose evidence last.** Derive `COVERAGE.md` and the factual parts
   of `TRANSCRIPTS.md` from the manifest and JSONL results. Use model tokens only
   for state-family judgment, label quality, spoiler review, and blind play.

The practical allocation is:

| Work | Best owner | Durable output |
|---|---|---|
| Room, exit, ID, and count inventory | Deterministic script | Manifest skeleton |
| Walkthrough prefix reuse | Checkpoint runner | Named saves or state fixtures |
| State-family boundaries | Authoring model or human | Manifest rows |
| Labels and priorities | Authoring model or human | Candidate worksheet |
| Parser acceptance and postconditions | Deterministic runner | JSONL evidence |
| Coverage tables and test totals | Report generator | Markdown |
| Clarity, tone, spoilers, and loops | Human or blind model | Short review notes |

Candidate count is not a coverage metric. Every extra candidate creates another
condition to review and another matching-state parser execution. Prefer a
a smaller distinct pool of useful choices over a large pool of repetitive or
low-value choices.

### Limehouse retrospective

The Limehouse commit demonstrates both the value and cost of broad first-pass
authoring:

- 11 rooms produced 1,133 lines of companion source, 100 distinct IDs, 122
  `CHOICE` call sites, and two separately maintained Markdown reports.
- Common hall and return choices were repeated across act routines. Shared
  emitters or common unconditional tails would make the source shorter and
  reduce ID/command drift.
- The regression launches fresh companion-mode processes and replays common prefixes
  several times. An in-process checkpoint runner would be faster and would make
  isolated per-card execution practical.
- Five of 12 tests prove that strings or routine names exist in the source, not
  that choices are eligible, visible, selectable, parseable, or truthful.
- Repeated/orphaned metadata and a duplicated `sp.examine-walls` form survived
  the load-focused regression. The Act III “Go to the study” card also sends
  `south`, while the room definition places the study to the north. These are
  concrete examples of why structural lint and per-card execution should happen
  before prose reporting.
- Counts diverged between summary and room entries, and an unsupported
  `--choices 6` setting reached the transcript. This audit corrected both; a
  cheap preflight linter should catch them automatically next time.
- The manifest correctly leaves validation at zero. Future work should retain
  that honesty and generate any stronger claim only from executor results.

The lesson is not to reduce the quality bar. It is to move repetition, counting,
checkpoint restoration, command execution, and report synchronization out of
the model-driven portion of the task.

## Core Concepts

### Candidate, selected card, and parser action

`companion.zil` emits a pool of **candidates**. The `--companion` interface
shows every eligible candidate and accepts either a numbered selection or a
typed parser command.

When a player selects a card, its hidden `COMMAND` is sent through the original
game parser. The parser and world model remain authoritative.

### State family

A room alone is not an adequate unit of coverage. Useful choices often change
after acquiring an item, learning a fact, moving an object, changing an NPC's
attitude, or starting a timed threat.

A practical state-family key is:

```text
room
+ story or puzzle milestone
+ relevant inventory
+ player knowledge
+ hazard or NPC phase
```

Only include distinctions that materially change the visible choices. For
example:

```text
Workshop door / unopened / no key / lock not diagnosed
Workshop door / known locked / no key or lockpick
Workshop door / known locked / lockpick carried
Workshop door / open
```

These are four useful state families even if the player stands in the same
room throughout.

### Authored coverage and fallback coverage

Automatic fallback suggestions keep an uncovered game operable. They do not
prove that the companion offers good narrative guidance or recognizes the
adventure's puzzle state.

Use these coverage statuses:

| Status | Meaning |
|---|---|
| `AUTHORED` | Explicit state-aware candidates exist |
| `VALIDATED` | Every important emitted command was executed in the matching state |
| `FALLBACK-REVIEWED` | No authored cards, but fallback output was inspected and accepted |
| `NOT-COVERED` | Reachable state needs companion work |
| `UNREACHABLE` | Source state cannot occur in normal play |
| `EXEMPT` | Deliberately omitted, with a recorded reason |

“The UI displayed something” is not equivalent to authored or validated
coverage.

For final release, every reachable state family must be `VALIDATED`. `EXEMPT`
may be used only for genuinely unreachable engine/debug rooms or terminal states
where the game no longer accepts input. Optional rooms, mazes, recovery routes,
death approaches, and alternate endings are not exemptions merely because they
are absent from the golden path.

## Before Starting

Read:

1. [`../ARCHITECTURE.md`](../ARCHITECTURE.md)
2. [`../PLAYING.md`](../PLAYING.md)
3. [`COMPANION-ZIL.md`](COMPANION-ZIL.md)
4. The target adventure's source, tests, walkthrough, and design materials

Record:

- Adventure name and directory
- Module passed to `--game`
- Game entry file and load order
- Existing `companion.zil`, if any
- Test runner and smallest relevant test target
- Known walkthroughs or transcript tests
- Save-file location used during exploration

Start from a clean game and keep generation saves outside committed content
unless they are intentional test fixtures.

## Stage 1: Resolve the Load Path

Before authoring choices, establish exactly how the adventure starts and how a
companion file is loaded.

Confirm:

1. The game runs in ordinary text mode.
2. Companion mode starts without an error.
3. The game module selected by `--game` is the expected module.
4. The companion file is loaded after the game objects and globals it reads.
5. An absent companion falls back cleanly instead of breaking startup.

Capture the opening output in `TRANSCRIPTS.md`. This gives later failures a
known-good baseline.

If the game does not currently load, stop companion authoring and report the
underlying adventure or loader defect separately.

## Stage 2: Build a Static World Inventory

Source inspection finds branches that one walkthrough will miss. Inventory the
adventure before drafting cards.

### Rooms and exits

For each room, record:

- Its exact source identifier and declaration location
- Whether it is reachable in ordinary play, conditionally reachable,
  unreachable, or terminal
- Normal exits
- Conditional exits
- Door-backed exits
- One-way travel
- Vehicle or transport transitions
- Returns from special scenes
- Endgame or death transitions

Compare the inventory mechanically against all `<ROOM ...>` declarations. The
number of classified rooms must equal the number of declared rooms. A missing
room is a generation failure even when fallback would produce movement cards.

### Objects and parser vocabulary

Record:

- Portable objects
- Containers and supporters
- Doors, switches, mechanisms, and readable objects
- Scenery that implies useful investigation
- Object synonyms and adjectives needed by hidden commands
- Objects whose availability or location changes

### State

Find the globals, flags, properties, and object locations that represent:

- Puzzle milestones
- Facts learned by the player
- Scores or chapter transitions
- NPC attitude, dialogue, or schedule phases
- Hazards and clocks
- Door, container, light, and power state
- Consumable resources
- Death, victory, and alternate endings

### Existing evidence

Collect:

- Walkthrough commands
- Transcript assertions
- Design puzzle dependencies
- Map and object documentation
- Known bugs and intentional parser limitations

This inventory is not yet the companion design. It defines the state space that
the design must account for.

Store the inventory in machine-readable form so later validation can distinguish
“not visited” from “inspected and unreachable.” Markdown alone is not a reliable
source of truth for automated completeness checks.

## Stage 3: Play and Checkpoint a Golden Path

Use `llm.lua` as documented in [`../PLAYING.md`](../PLAYING.md). Send one
command per invocation so every observation has an exact preceding action.

Typical setup:

```bash
lua5.4 llm.lua \
  --game <game-name> \
  --new-game \
  --save /tmp/<game-name>-companion.sav

lua5.4 llm.lua \
  --game <game-name> \
  --action "look" \
  --save /tmp/<game-name>-companion.sav
```

During play:

- Use `look` after significant transitions.
- Use `inventory` after acquiring or losing an item.
- Examine objects named in prose.
- Attempt blocked actions before satisfying their condition.
- Preserve checkpoints before puzzle branches, hazards, and irreversible acts.
- Record the exact output that establishes knowledge.

The goal is not merely to finish. The golden path identifies the normal order
of discovery, the vocabulary that actually works, and useful places to branch
state-family testing.

## Stage 4: Create the State-Family Manifest and Matrix

Turn the static inventory and play transcript into
`companion/COVERAGE.json`, then generate or synchronize
`companion/COVERAGE.md` from it. The machine-readable manifest is authoritative.

Each state-family record should contain:

- Stable state-family ID
- Room identifier
- Reachability classification
- Reproducible setup checkpoint or exact parser command sequence
- Relevant inventory, flags, globals, knowledge, NPC, and hazard state
- Required and forbidden candidate IDs in companion mode
- Expected hidden command, output pattern, and postcondition for each card
- Validation status and evidence reference

A useful table is:

| Area | State family | Entry evidence | Desired support | Status | Validation |
|---|---|---|---|---|---|
| West of House | mailbox closed | new game | inspect, open, move | `AUTHORED` | transcript §1 |
| West of House | mailbox open, leaflet present | open mailbox | take/read, move | `VALIDATED` | test X |
| Cellar | dark, lamp absent | enter cellar | safety, retreat | `NOT-COVERED` | — |

For each row, answer:

1. How can the player enter this state?
2. What can the player reasonably know?
3. What immediate progress actions exist?
4. What investigation action reveals the next missing fact?
5. What movement actions should remain available?
6. Is there a danger or recovery action that must outrank everything else?
7. Can the state persist across save/restore?

Avoid a Cartesian explosion. Merge states whose candidate set and priority
would be the same. Split states whenever the useful or honest choice changes.

Before implementation begins, assert that:

1. Every declared room has a manifest classification.
2. Every reachable room has at least one state family.
3. Every ordinary entry into and return from a room belongs to a state family.
4. Every mandatory puzzle transition has before, blocked/failed where
   meaningful, and after-success families.

## Stage 5: Design the Candidate Worksheet

Draft candidates before encoding large routines. Each row should include:

| Field | Question |
|---|---|
| ID | Is it stable, unique, and specific? |
| Label | Does it express player intent in natural language? |
| Command | Does the parser accept this exact text? |
| Kind | Is it progress, investigation, interaction, experiment, return, or safety? |
| Group | Is it a scene action or movement? |
| Priority | Should it survive selection when the pool is crowded? |
| Condition | Is it true only when the action is relevant and honest? |
| Once/history | Should it remain visible after selection? |
| Learns | Does executing it establish player knowledge? |
| Expected result | What output or state transition validates it? |

Example:

| ID | Label | Command | Kind | Group | Condition |
|---|---|---|---|---|---|
| `yard.try-door` | Try the workshop door | `open workshop door` | investigate | scene | door untried |
| `yard.pick-lock` | Unlock it with the lockpick | `unlock workshop door with lockpick` | progress | scene | locked and lockpick carried |
| `yard.go-garden` | Follow the path into the garden | `north` | return/progress | move | north exit available |

### Labels and commands serve different audiences

The label is for the player:

```text
Listen at the workshop door
```

The command is for the parser:

```text
listen to workshop door
```

Do not expose parser awkwardness in the label. Do not put prose in the hidden
command.

### Scene actions and movement

Use two groups:

- `scene`: examine, manipulate, converse, read, wait, use inventory, and take
  context-specific action.
- `move`: traverse an exit, return to another area, enter or leave a scene.

This split keeps navigation from crowding out interaction while preserving an
escape route from exhausted scenes. Mark movement explicitly:

```zil
<CHOICE "yard.go-garden"
        "Follow the path into the garden"
        "north"
        ,CHOICE-RETURN
        40>
<CHOICE-DETAILS "group" "move">
```

Do not classify “open the door” as movement merely because it enables travel.
The actual traversal card belongs in `move`.

### Candidate richness

Author every distinct candidate that is useful in the current state. A healthy
companion state often has:

- One likely progress action
- One investigation or information action
- One optional interaction or experiment
- One or two useful movements
- A safety action when danger is immediate

Every eligible card is visible, so keep the set useful rather than padding it.
Each card still costs authoring, validation, and maintenance effort; remove
cards that do not represent a meaningfully distinct intention.

### Spoiler control

A card must not use knowledge the player has not acquired. Prefer:

```text
Try the brass key
```

over:

```text
Use the workshop key
```

until the game has established what the key opens.

Failure can be a useful information action. Offering “Try the door” before the
player knows it is locked lets the game reveal the obstacle in its own voice.
Afterward, the card can change to “Look for another way inside.”

## Stage 6: Implement One Vertical Slice at a Time

Start with the opening room and the first small puzzle. For each slice:

1. Add state predicates.
2. Emit scene candidates.
3. Emit movement candidates.
4. Start the game in that state.
5. Inspect the complete visible companion set.
6. Select every card.
7. Add or update tests.
8. Mark the coverage row only after validation.

Then advance to the next room or milestone.

Vertical slices expose errors in API use, ranking, conditions, and hidden
commands before those errors are copied throughout the adventure.

Keep companion routines observational during candidate generation. They may
read game state and emit temporary candidate metadata, but must not advance
clocks, move objects, set story flags, or consume random numbers merely because
the UI refreshed.

## Stage 7: Validate Every Hidden Command

Never approve a command by inspection alone.

For every candidate:

1. Reach the exact state in which the card appears.
2. Save or clone that state before executing any candidate.
3. Restore an independent copy for each eligible card so one result cannot
   contaminate another card's test.
4. Select the card through companion mode.
5. Capture the parser output and relevant before/after state.
6. Confirm the expected state transition or information.
7. Run `look` or `inventory` when needed to observe the result.
8. Verify the card disappears, changes, or remains appropriately afterward.

Record failures such as:

- Parser does not recognize the verb or noun
- Command becomes ambiguous
- Object is not visible in this state
- Action succeeds but the label promises something else
- Action reveals a spoiler
- Card persists after becoming irrelevant
- State changes correctly but the next useful card never appears

If the parser itself has a genuine defect, report and test it separately. Do
not silently modify the original adventure merely to make a proposed card work
when a valid existing command would suffice.

The exhaustive executor should be deterministic code. It must enumerate all
eligible cards from each manifest state, execute them from isolated restores,
and emit structured failures. A language model may judge label honesty,
spoilers, tone, and confusing outcomes, but should not be the mechanism that
decides whether every enumerated card was run.

## Stage 8: Run a Choice-Only Playthrough

The defining accessibility test is whether a player can make meaningful
progress without typing.

Run at least:

### Companion route

- Fresh game
- `--companion`
- Numeric input only
- Verify exactly the available numbered choices are accepted
- Visit every reachable room or prove it belongs only to a separately validated
  alternate route
- Reach a valid ending
- Confirm no puzzle requires free text

### Mixed companion route

- Fresh game
- `--companion`
- Alternate typed commands with selected cards
- Confirm typed exploration does not put companion logic into an unhandled
  state

Test at least one non-golden branch: wrong turn, optional object order,
backtracking, or a failed puzzle attempt. Companion support that works only
after the canonical walkthrough is too brittle.

### Weak-model blind route

A relatively weak model is useful as an independent player because it sees only
three or five curated intentions. Give it labels and game output, not source,
hidden commands, puzzle solutions, or the coverage manifest. Measure:

- Completion or point of stall
- Repeated-choice loops
- Misleading or indistinguishable labels
- Missing recovery or return choices
- Unexpected spoilers
- Rooms and state families actually visited

This is an accessibility and editorial test, not a completeness proof. A weak
model cannot report a card or state that was never presented; exhaustive
manifest and parser validation remain mandatory.

## Stage 9: Persistence, Purity, and Edge Cases

### Save and restore

Save in states where choices depend on:

- Inventory
- An opened or moved object
- Learned information
- A selected-once card
- An NPC or clock phase

Restore and verify the same relevant candidate set appears.

### Restart

Restart must clear choice history and game-dependent companion state. Opening
cards should behave as they do in a brand-new process.

### Query purity

Refresh or query choices repeatedly without acting. Confirm:

- No turns pass
- No clocks fire
- No random outcome changes
- No object moves
- No score or story flag changes
- The returned set is stable for unchanged state

### Danger and dead ends

In timed or dangerous states:

- Safety choices outrank flavor.
- A retreat or recovery route remains visible when one exists.
- The card does not imply a safe action when the parser outcome is fatal.
- Unavoidable death or ending states are documented rather than disguised.

### Fallback boundaries

Temporarily inspect states without authored candidates:

- Are fallback moves valid?
- Is a useful scene action present?
- Does fallback expose internal object names or nonsensical verbs?
- Is the gap acceptable, exempt, or still `NOT-COVERED`?

## Stage 10: Editorial and Accessibility Review

After functional correctness, review the visible experience.

### Narrative quality

- Labels describe intentions, not parser syntax.
- Cards do not repeat the room prose verbatim.
- Choices vary in rhythm and purpose.
- Optional actions add atmosphere or character without displacing progress.
- Failure cards teach something or create a deliberate dramatic beat.

### Choice clarity

- Labels are distinguishable at a glance.
- Pronouns have an obvious referent.
- The outcome is not falsely guaranteed.
- Vocabulary suits the target age.
- Essential actions do not depend on subtle color, order, or prior parser
  knowledge.

### Group balance

- Scene and movement headings match the action type.
- A room with interesting content is not reduced to a list of exits.
- A room with exhausted content still offers useful movement.
- Every visible companion choice adds meaningful richness rather than duplication.

### Spoilers and knowledge

- Labels use only established facts.
- A solution appears only after the intended clue or experimentation.
- Repeated failed actions evolve into a better hint where appropriate.
- A companion player receives enough support without the card narrating the
  entire solution in advance.

## Automated Testing Strategy

Automated tests should target logic that is costly or fragile to recheck
manually.

Run a static preflight before parser execution. It should calculate rather than
trust:

- Declared and classified room counts
- State-family totals from the actual room records
- `CHOICE` call-site and distinct-ID counts
- Duplicate IDs whose commands or meanings drift between branches
- Movement choices missing `group = move`
- Manifest choices with no source definition and source choices with no
  manifest expectation
- Commands and options unsupported by the documented host

Static source-presence assertions are useful only as lint. They must not be
reported as runtime coverage.

Recommended assertions:

- Every declared room is classified exactly once.
- Every reachable room has authored candidates and at least one validated state
  family.
- No reachable state family finishes with `FALLBACK-REVIEWED` or
  `NOT-COVERED`.
- A key card appears when its condition becomes true.
- It does not appear before the player can know or perform it.
- It disappears or changes after success.
- Movement cards carry the `move` group.
- Every eligible action appears in the companion set.
- Repeated choice queries do not mutate adventure state.
- Save/restore preserves relevant visibility and history.
- Restart resets companion history.
- A choice executes the exact parser command expected.
- Every eligible card is executed from an isolated restore of its matching
  state.
- A companion numeric-only route reaches an ending.

Prefer parser-level transcript assertions plus separate state assertions. A
successful coroutine or function call alone does not prove the intended world
change occurred.

### Required companion CLI

Agent-driven and exhaustive testing require a persistent, structured host path.
`llm.lua` should support:

```bash
lua5.4 llm.lua --choices --save /tmp/game.sav
lua5.4 llm.lua --choose <stable-choice-id> --save /tmp/game.sav
```

The query result should include the room, scene, visible IDs, labels, kinds,
groups, and priorities. Debug validation may include the hidden command and a
state fingerprint. Selection should return parser output, the resulting room,
and enough state evidence to check the declared postcondition.

Until those operations exist, an adventure-specific Lua test may call
`COMPANION_QUERY` and `COMPANION_SELECT` directly, but it must provide equivalent
checkpoint isolation and structured evidence. Interactive `main.lua` transcripts
alone are not sufficient for exhaustive validation.

Use the smallest adventure-specific test target while iterating, then run the
broader relevant gates:

```bash
lua5.4 tests/test_companion.lua
make test-unit
make test-pure-zil
git diff --check
```

Not every adventure requires every broad target for a documentation-only
change, but a completed companion should exercise its own regressions and the
ordinary adventure tests.

## Machine-Readable Coverage Manifest Template

Create `companion/COVERAGE.json` first. Keep it valid JSON so deterministic
tools can calculate coverage without interpreting prose. A minimal shape is:

```json
{
  "adventure": "<Adventure>",
  "gameModule": "<module>",
  "declaredRoomCount": 0,
  "rooms": [
    {
      "id": "OPENING-ROOM",
      "source": "dungeon.zil",
      "reachability": "reachable",
      "stateFamilies": [
        {
          "id": "opening.initial",
          "setup": {
            "newGame": true,
            "commands": []
          },
          "requiredChoices": [
            "opening.inspect",
            "opening.progress"
          ],
          "forbiddenChoices": [],
          "candidateExpectations": [
            {
              "id": "opening.inspect",
              "command": "examine door",
              "outputContains": "door",
              "postcondition": "knowledge.door-observed"
            }
          ],
          "status": "NOT-COVERED",
          "evidence": null
        }
      ]
    }
  ]
}
```

Projects may extend this structure, but must preserve stable room and
state-family IDs, reproducible setup, required/forbidden choices, candidate
postconditions, validation status, and evidence. Generated reports must fail
when `declaredRoomCount` differs from the number of classified source rooms.

## Coverage Report Template

Create `companion/COVERAGE.md` from this template:

```markdown
# <Adventure> Companion Coverage

## Summary

| Metric | Count |
|---|---:|
| Declared rooms | 0 |
| Classified rooms | 0 |
| Reachable rooms | 0 |
| State families | 0 |
| Authored | 0 |
| Validated | 0 |
| Fallback-reviewed | 0 |
| Not covered | 0 |
| Exempt | 0 |

## Matrix

| Room | Reachability | State family | Entry evidence | Desired support | Status | Evidence |
|---|---|---|---|---|---|---|
| Opening | Reachable | Initial state | New game | investigate, progress, movement | NOT-COVERED | — |

## Full-game route evidence

- Child numeric-only ending:
- Story numeric-only ending:
- Mixed typed-and-choice ending:
- Weak-model blind route:

## Known Gaps

- None, or list each reachable unsupported state and its player impact.

## Exemptions

- None, or explain why each state does not need authored support.
```

Counts make incomplete work visible. Descriptions make it resumable by another
author or agent. `Declared rooms` and `Classified rooms` must match. At release,
every reachable state family must be validated and both fallback-reviewed and
not-covered counts must be zero.

## Transcript Evidence Template

Create `companion/TRANSCRIPTS.md` from this template:

```markdown
# <Adventure> Companion Validation Transcripts

## Environment

- Date:
- Revision:
- Lua version:
- Game module:
- Mode:

## Scenario: <name>

### Prerequisite state

Exact commands used to reach the state.

### Visible cards

1. Label — hidden command — group
2. Label — hidden command — group

### Selection

Selected card:

Observed output:

Expected output or state:

Follow-up observation:

Result: PASS / FAIL
```

Preserve exact parser text for failures. Summaries are useful for navigation,
but they cannot replace evidence.

## Handling Large Adventures

For a large imported adventure, full coverage may require several passes.
Partition by a stable player-facing boundary:

- Region or chapter
- Major puzzle chain
- NPC arc
- Pre- and post-milestone world state
- Endgame

Each pass should still be a vertical slice: discover, implement, validate, and
document that partition before moving on.

Recommended order:

1. Opening and onboarding
2. Mandatory golden-path rooms
3. Required puzzle branches
4. Recovery and backtracking states
5. Optional content
6. Rare hazards, deaths, and alternate endings

Never report “complete” when only the walkthrough corridor is covered. Report
the exact matrix status instead. Intermediate passes may be merged as partial
work, but the resulting released companion must cover every reachable room,
optional region, backtracking route, material hazard state, and ending path.

## What the Agent May Infer

An authoring agent may infer:

- Likely useful actions from room prose and object state
- Candidate labels from observed parser outcomes
- State-family boundaries from source flags and walkthrough transitions
- Reasonable priority and diversity
- Missing coverage from the world inventory

It must validate, not merely infer:

- That a command parses
- That the referenced object is in scope
- That a transition succeeds in the claimed state
- That the player has learned facts used by the label
- That a card remains correct after typed detours
- That save/restore and restart preserve the intended behavior

Source inspection and play complement one another. Source alone misses the
experienced narrative order; play alone misses unvisited branches.

Use models according to the evidence they can reliably produce:

- A capable authoring model or human inventories state families and drafts
  conditions and labels.
- Deterministic tooling enumerates rooms, restores checkpoints, executes every
  card, and calculates coverage.
- A relatively weak model performs blind companion play and reports
  comprehensibility, loops, and misleading choices.

No model's successful playthrough proves completeness.

## Change Boundaries

The companion layer should preserve the original adventure:

- Do not rewrite puzzle logic to simplify companion generation.
- Do not bypass the parser with direct object mutations.
- Do not encode an alternate branching story in the companion.
- Do not use an online model at runtime.
- Do not hide a parser defect by claiming an untested command works.

An underlying defect discovered during generation may be fixed as a separate,
focused change with its own regression. Record it explicitly in the completion
report.

## Release Gate

A companion is ready when:

- [ ] The adventure and companion load together.
- [ ] Every declared room is classified as reachable, unreachable, terminal, or
      explicitly exempt, and the classified count equals the source count.
- [ ] Every reachable room has authored companion support; fallback is not the
      only support in any reachable room.
- [ ] Materially distinct puzzle, inventory, knowledge, NPC, and hazard states
      are represented as state families.
- [ ] Every reachable state family is `VALIDATED`; `FALLBACK-REVIEWED` and
      `NOT-COVERED` counts are zero.
- [ ] Every emitted hidden command has matching-state parser evidence from an
      isolated checkpoint.
- [ ] A fresh companion run reaches an ending using numbered choices only.
- [ ] A mixed typed-and-choice companion run does not expose stale assumptions.
- [ ] Optional rooms, alternate routes, recovery states, and alternate endings
      have route or state-family evidence.
- [ ] An independent weak-model blind route was run and its stalls or loops were
      fixed or explicitly recorded as failures.
- [ ] Scene and movement cards are grouped correctly.
- [ ] Every eligible essential choice appears in companion mode.
- [ ] Save/restore and restart behavior is validated.
- [ ] Repeated choice queries are observational.
- [ ] Spoilers, labels, diversity, and audience clarity received editorial
      review.
- [ ] Adventure-specific companion regressions pass.
- [ ] Exempt and unreachable states have evidence; no reachable uncovered state
      remains.

## Completion Report

The author or agent should finish with:

- Adventure and module
- Files created or changed
- Declared, classified, reachable, unreachable, terminal, and exempt room counts
- Reachable rooms inventoried
- State families identified
- State families authored and validated
- Candidate commands emitted and executed
- Child, story, mixed, and weak-model blind routes completed
- Tests run and their results
- Underlying adventure defects found
- Exempt and unreachable states with evidence
- Confirmation that reachable fallback-reviewed and uncovered counts are zero
- Known limitations

This makes companion generation repeatable, reviewable, and honest about its
coverage.
