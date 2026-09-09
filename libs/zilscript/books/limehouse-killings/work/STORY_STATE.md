# The Limehouse Killings - Story State Contract

This file documents the implemented state machine and the transitions future `.zil` refactors must preserve.

## Act State

| Variable | Initial | Meaning |
|---|---:|---|
| `CASE-ACT` | 1 | 1 = exploration, 2 = reconstruction, 3 = confrontation |
| `INSPECTOR-PRESENT` | false | Lestrade has moved into the Entrance Hall |

Transitions:

```text
CASE-ACT 1
  -- solve library cipher --> CASE-ACT 2

CASE-ACT 2
  -- EVIDENCE-FOUND > 2 and SUSPECTS-INTERVIEWED = 3 --> CASE-ACT 3
                                                           INSPECTOR-PRESENT = true
                                                           MOVE INSPECTOR to hall
```

Act transitions are monotonic and must alter visible world text in at least two places.

## Investigation State

| Variable | Initial | Guarded trigger |
|---|---:|---|
| `EVIDENCE-FOUND` | 0 | Increment once per counted discovery flag |
| `SUSPECTS-INTERVIEWED` | 0 | Increment once for Hudson alibi, Lady alibi, and Moriarty poison interview |
| `DEAD-LETTER-FOUND` | false | First meaningful read/examine/discovery of letter |
| `KNIFE-FOUND` | false | First take/examine discovery of knife |
| `POISON-BOTTLE-FOUND` | false | First meaningful read/examine of vial |
| `SECRET-LEDGER-FOUND` | false | First meaningful read/examine of ledger |
| `BANK-STATEMENT-FOUND` | false | First meaningful read/examine of statement |

The physical box is not itself counted evidence. Its statement is the corroborating discovery.

## Route and Puzzle State

| Variable/object state | Initial | Transition |
|---|---:|---|
| `STUDY-UNLOCKED` | false | Interior bolt, keyring, or lockpick unlocks door |
| `STUDY-DOOR OPENBIT` | clear | `OPEN STUDY DOOR` after unlock, or opening from Study |
| `CIPHER-STAGE` | 0 | Correct book advances 0→1→2→3; wrong book resets |
| `CIPHER-SOLVED` | false | Blue book after red-yellow-green sequence |
| `SECRET-PASSAGE-FOUND` | false | Set with cipher success |
| `SECRET-PASSAGE-OPEN` | false | Set with cipher success |
| `POISON-IDENTIFIED` | false | `USE VIAL ON PLANTS` in Greenhouse |
| `BOX-CLUE-SEEN` | false | Examine name-dial box |
| `FOOTPRINT-DETAIL-FOUND` | false | Use magnifying glass on footprint cast |
| `CABINET-CLUE-SEEN` | false | Examine/open wine cabinet |
| `LOCKED-BOX-OPENED` | false | Turn dial to Moriarty after three prerequisite facts |
| `LOCKED-BOX OPENBIT` | clear | Set with successful dial solution |

## NPC State Matrices

Each principal NPC must expose three discoverable behavior states: initial, changed by direct player action, and changed by story progress elsewhere.

### Hudson

| State | Trigger | Observable behavior |
|---|---|---|
| Initial | Act I/II, not confronted | Re-polishes one spoon; cloth squeaks as his hand tightens |
| Confronted | Show dead letter before Act III | Stops polishing and admits carrying the letter to the study |
| Late case | `CASE-ACT = 3` | Packed carpetbag and wrongly buttoned coat reveal fear/relief |

Flags: `HUDSON-INTERVIEWED`, `HUDSON-KEY-GIVEN`, `HUDSON-CONFRONTED`.

### Lady Ashworth

| State | Trigger | Observable behavior |
|---|---|---|
| Initial | Act I/II, not confronted | Untouched filmed soup and precisely aligned knife |
| Confronted | Show dead letter before Act III | Ring/paper tremor; admits burning an earlier draft |
| Late case | `CASE-ACT = 3` | Removes mourning ribbon and listens for Lestrade |

Flags: `LADY-INTERVIEWED`, `LADY-ALIBI-CLAIMED`, `LADY-CONFRONTED`.

### Moriarty

| State | Trigger | Observable behavior |
|---|---|---|
| Initial | Act I/II, not confronted | Controlled four-beat tapping by scientific folios |
| Confronted | Show letter or ask about poison before Act III | Sweat, pocketed gloved hand, counting exits |
| Late case | `CASE-ACT = 3` | Moves to hall; muddy heel matches footprint cast |

Flags: `MORIARTY-INTERVIEWED`, `MORIARTY-POISON-KNOWN`, `MORIARTY-CONFRONTED`.

### Lestrade

| State | Trigger | Observable behavior |
|---|---|---|
| Offstage | Acts I–II | Cannot be examined or addressed |
| Receiving case | Act III | Blank notebook page; asks for threat/method/motive |
| Case complete | Three presentation flags | Notebook explicitly labels the three links |

## Final Argument State

| Variable | Trigger | Meaning |
|---|---|---|
| `LETTER-PRESENTED` | Show letter to Lestrade | Threat/intent link accepted |
| `POISON-PRESENTED` | Show bottle to Lestrade | Method/access link accepted |
| `MOTIVE-PRESENTED` | Show statement to Lestrade | Debt/blackmail link accepted |
| `KILLER-ACCUSED` | Successful chosen-proof accusation | Accusation made |
| `CORRECT-ACCUSATION` | Moriarty + complete chain + valid lead proof | Correct culprit established |
| `GAME-WON` | Successful ending | Win state |
| `GAME-ENDED` | Successful ending or lethal poison outcome | Session terminates |

Final choice:

```text
complete case + ACCUSE MORIARTY
  -> prompt for lead proof
     -> WITH LETTER: testimony-led resolution
     -> WITH POISON: physical-evidence/confession resolution
```

Both branches converge on arrest but contain distinct player-authored emphasis.

## Safety and Counter Invariants

- Repeating `READ`, `EXAMINE`, or `TAKE` never increments a discovery twice.
- Asking one NPC about Moriarty never marks Moriarty himself interviewed.
- Topicless `ASK/TELL` checks `PRSI` before `IN?` or `EQUAL?`.
- Inspector arrival can fire only once.
- Cipher and box solutions remain solved after revisit/save replay.
- Wrong accusations increase `WRONG-ATTEMPTS` where supported but do not force a loss.
- `TASTE POISON` decrements `PLAYER-HEALTH`; only zero health ends the game.
- `USE CHARCOAL` after tasting poison restores one health point and never exceeds the initial value.

## Golden-Path Assertions

```text
CASE-ACT = 2 after cipher
CIPHER-SOLVED = true
SECRET-PASSAGE-OPEN = true
POISON-IDENTIFIED = true
LOCKED-BOX-OPENED = true
EVIDENCE-FOUND = 5
SUSPECTS-INTERVIEWED = 3
CASE-ACT = 3
INSPECTOR-PRESENT = true
LETTER-PRESENTED = true
POISON-PRESENTED = true
MOTIVE-PRESENTED = true
KILLER-ACCUSED = true
CORRECT-ACCUSATION = true
GAME-WON = true
```

## Save/Replay Requirement

`llm.lua` persists state by replaying action history across processes. Every transition above must therefore be deterministic under a fresh load plus replay, including runtime vocabulary registration for `SET`, `CAST`, and `INSPECTOR`.
