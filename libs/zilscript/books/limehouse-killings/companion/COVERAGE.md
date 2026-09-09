# The Limehouse Killings — Companion Coverage

## Summary

| Metric | Count |
|--------|-------|
| Declared rooms | 11 |
| Reachable rooms | 11 |
| Unreachable rooms | 0 |
| State families identified | 19 |
| State families authored | 19 |
| State families validated | 0 |
| Unique choice IDs | 100 |
| Total CHOICE calls | 122 |

The companion has authored routing for every declared room. This report does
not establish complete validated coverage: the manifest records zero validated
state families, and the focused regression does not execute every emitted card
from an isolated matching state.

## Room Coverage

| Room | Routine | Choices | State Families | Status |
|------|---------|---------|----------------|--------|
| Gate | `SUGGEST-GATE` | 5 | 2 | AUTHORED |
| Entrance Hall | `SUGGEST-ENTRANCE-HALL` | 32 | 4 | AUTHORED |
| Study | `SUGGEST-STUDY` | 20 | 3 | AUTHORED |
| Library | `SUGGEST-LIBRARY` | 18 | 2 | AUTHORED |
| Dining Room | `SUGGEST-DINING-ROOM` | 14 | 2 | AUTHORED |
| Kitchen | `SUGGEST-KITCHEN` | 6 | 1 | AUTHORED |
| Garden | `SUGGEST-GARDEN` | 10 | 1 | AUTHORED |
| Greenhouse | `SUGGEST-GREENHOUSE` | 5 | 1 | AUTHORED |
| Servants' Quarters | `SUGGEST-SERVANTS-QUARTERS` | 10 | 1 | AUTHORED |
| Secret Passage | `SUGGEST-SECRET-PASSAGE` | 4 | 1 | AUTHORED |
| Pantry | `SUGGEST-PANTRY` | 4 | 1 | AUTHORED |

## Choice Kinds

| Kind | Count | Description |
|------|-------|-------------|
| `CHOICE-PROGRESS` | 42 | Actions that advance the investigation |
| `CHOICE-INVESTIGATE` | 35 | Examination, reading, observation |
| `CHOICE-INTERACT` | 18 | NPC conversation, sensory exploration |
| `CHOICE-EXPERIMENT` | 12 | Cipher pushes, pulling wires, trying mechanisms |
| `CHOICE-RETURN` | 15 | Navigation back to previous rooms |

## State-Aware Behavior

### Entrance Hall (4 state families)
- **Act I (study locked)**: Shows study door attempt, library, dining, kitchen, magnifier
- **Act I (study open)**: Shows study entry, library, dining, kitchen, magnifier
- **Act II (cipher solved)**: Shows study, library, dining, kitchen, bell wire
- **Act III (Lestrade present)**: Shows evidence presentation, accusation, NPC interaction

### Study (3 state families)
- **Exploration**: Take letter, poison, examine box/chalk/desk/window
- **Box puzzle**: Guide toward prerequisites (letter, poison ID, ledger)
- **Complete**: Focus on returning to hall with evidence

### Library (2 state families)
- **Act I (cipher unsolved)**: Take items, read page, ask Moriarty, push books
- **Act II (cipher solved)**: Enter secret passage, take ledger, return to hall

### Dining Room (2 state families)
- **Acts I-II**: Take seal, interview Lady Ashworth, examine cabinet
- **Act III**: Show evidence to Lady Ashworth, navigate to pantry/hall

## Known Limitations

1. **Cipher puzzle**: Requires 4 sequential book pushes
   (red→yellow→green→blue).
2. **Evidence depth**: Five of the 12 focused tests inspect source strings.
   There is no exhaustive matching-state command executor yet.

## Authoring Optimization Retrospective

This companion is a useful stress test for the authoring workflow:

- The 1,133-line source repeats common hall navigation and return cards across
  act routines. Emit invariant choices once outside state branches or use a
  small movement helper to centralize `group = move`.
- Keep only meaningfully distinct choices. One hundred IDs for 11 rooms
  increased validation work without proving coverage.
- Build state-family counts from the room records. The original commit summary
  said 11 while the room entries totaled 19; this audit corrected the summary
  to 19.
- Replace repeated fresh-process companion runs with one in-process runner and
  named checkpoints at the gate, hall, cipher, study, evidence, and accusation
  milestones.
- Have that runner execute every visible ID from an isolated checkpoint and
  emit JSONL containing the state-family ID, mode, visible set, selected ID,
  command, output assertion, and postcondition.
- Generate this report and factual transcript excerpts from the manifest and
  JSONL. Hand-maintained counts and copied transcripts should not be release
  evidence.
- Add a preflight linter for malformed forms, duplicated adjacent calls,
  ID/command drift, missing move groups, manifest/source mismatches, and
  unsupported CLI limits before any playthrough begins.
- The current source gives that linter real cases: repeated/orphaned
  `CHOICE-DETAILS`, a duplicated `sp.examine-walls` form, and an Act III
  “Go to the study” card whose hidden `south` command conflicts with the
  entrance hall's northward study exit.

## Architecture Notes

- `SUGGEST-ACTIONS` dispatches to room-specific routines based on `HERE`
- `SUGGEST-SCENE` provides atmospheric descriptions for each room
- Helper routines (`SUGGEST-HALL-ACT1`, etc.) handle act-specific logic
- All helper routines are defined BEFORE `SUGGEST-ACTIONS`/`SUGGEST-SCENE` to avoid ZIL forward-reference issues
- `CHOICE-DETAILS` attaches metadata: `subject`, `once`, `learns`, `group`
