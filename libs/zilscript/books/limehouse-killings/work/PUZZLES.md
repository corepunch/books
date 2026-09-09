# The Limehouse Killings - Puzzle Architecture

The central design rule is that deduction, not possession, gates progress. Keys and lockpicks may offer optional physical routes, but at least two major gates must require understanding the fiction.

## Puzzle Overview

| Puzzle | Act | Challenge type | Fictional inference | Canonical command |
|---|---:|---|---|---|
| Library passage | I → II | Observation and sequence | Torn-page instruction + colored books | Push red, yellow, green, blue books |
| Greenhouse comparison | II | Cross-location identification | Aconitum on vial = wolfsbane plant | `USE VIAL ON PLANTS` |
| Ashworth name dial | II | Culprit connection | Letter + purple flower + debt all point to Moriarty | `TURN LOCKED BOX TO MORIARTY` |
| Lestrade case chain | III | Argument and choice | Threat + method + motive form a case | Show three links, then accuse with letter or poison |

The locked study door is an optional physical obstacle, not a required major puzzle. The fiction-led library passage provides a complete alternate route into the study.

## Puzzle 1 — Library Passage

Goal: discover how someone crossed into the sealed study and enter Act II.

Discoverable information:

- The reading desk exposes a torn page naming “rainbow order.”
- Colored ribbons and four distinct marked books make the manipulable nouns visible.
- Each correct push clicks; a wrong push resets the sequence explicitly.

Solution:

```text
READ TORN PAGE
EXAMINE COLORED MARKERS
PUSH RED BOOK
PUSH YELLOW BOOK
PUSH GREEN BOOK
PUSH BLUE BOOK
```

Consequences:

- `CIPHER-SOLVED`, `SECRET-PASSAGE-FOUND`, and `SECRET-PASSAGE-OPEN` become true.
- `CASE-ACT` becomes 2.
- Library and Entrance Hall descriptions change.
- Secret Passage becomes persistently traversable to the Study.

Fair-failure responses:

- Wrong book: it springs back and the sequence resets.
- Generic bookshelf push: points toward an order.
- Repeating after success: acknowledges the passage is already open.

## Puzzle 2 — Greenhouse Poison

Goal: prove that the study vial and greenhouse plant are the same poison source.

Required understanding:

- The vial label says “Aconitum — Wolfsbane.”
- The purple plant's label uses the same two names.
- Moriarty admits keeping wolfsbane for research.

Canonical solution:

```text
EXAMINE VIAL
EXAMINE PLANTS
EXAMINE LABELS
USE VIAL ON PLANTS
```

Consequences:

- `POISON-IDENTIFIED` becomes true.
- The fact becomes the method link in the final case.
- The clue satisfies the purple-flower engraving on the name dial.

This puzzle must never require taking foxglove or charcoal. Those objects are optional until a separate antidote consequence is designed.

## Puzzle 3 — Ashworth Name Dial

Goal: open the fireplace box by identifying the person connecting its engravings.

Examine text presents three engravings:

1. Sealed letter → Ashworth threatened to expose Moriarty.
2. Purple flower → wolfsbane/Aconitum from Moriarty's research.
3. Columns of debt → secret ledger records Moriarty's £500 debt.

Required state:

- `DEAD-LETTER-FOUND`
- `POISON-IDENTIFIED`
- `SECRET-LEDGER-FOUND`

Canonical solution:

```text
EXAMINE LOCKED BOX
TURN LOCKED BOX TO MORIARTY
```

Consequences:

- `LOCKED-BOX-OPENED` becomes true.
- Box gains `OPENBIT` and reveals the bank statement.
- Reading the statement independently records the motive corroboration.

Fair-failure responses:

- `OPEN BOX` or `UNLOCK BOX`: explains there is no keyhole and teaches `TURN BOX TO a name`.
- Correct name too early: names the three unresolved clue categories without revealing their answer.
- Wrong name: dial returns to blank.
- Keyring/lockpick: must not bypass the deduction.

## Puzzle 4 — Lestrade's Case Chain

Goal: transform discoveries into an argument and choose how to present it.

Act III arrival threshold:

- `EVIDENCE-FOUND > 2`
- `SUSPECTS-INTERVIEWED = 3`
- Lestrade has not already arrived

Lestrade requests three links:

| Link | Item shown | Meaning | State flag |
|---|---|---|---|
| Threat | Unsent letter | Ashworth intended to expose Moriarty | `LETTER-PRESENTED` |
| Method | Poison bottle | Wolfsbane connects sealed study to greenhouse/research | `POISON-PRESENTED` |
| Motive | Bank statement | Corroborates the ledger's debt and blackmail | `MOTIVE-PRESENTED` |

Canonical sequence:

```text
ASK INSPECTOR ABOUT CASE
SHOW LETTER TO INSPECTOR
SHOW BOTTLE TO INSPECTOR
SHOW STATEMENT TO INSPECTOR
ACCUSE MORIARTY
```

The bare accusation prompts a final choice:

- `ACCUSE MORIARTY WITH LETTER` leads with Ashworth's voice and draws confirming testimony from Hudson and Lady Ashworth.
- `ACCUSE MORIARTY WITH POISON` leads with physical evidence and provokes Moriarty into revealing knowledge he should not possess.

Both endings must reference at least two earlier discoveries and imply the next case rather than ending at a numeric victory message.

## Dependency Graph

```text
Opening telegram
      |
Library observations ──> Library sequence ──> Act II / secret route / study
                                                   |
                         letter ────────────────────┤
study vial ──> greenhouse comparison ──────────────┼──> name dial ──> statement
library ledger ────────────────────────────────────┘

Hudson alibi + Lady alibi + Moriarty poison interview
                         + 3 discoveries ──> Act III / Lestrade arrives

letter + identified poison + statement ──> present case ──> chosen-proof accusation
```

## Likely Command Matrix

| Attempt | Authored result required |
|---|---|
| `OPEN STUDY DOOR` | State-aware locked/unlocked/open response |
| `UNLOCK STUDY DOOR WITH KEYRING` | Optional physical route succeeds |
| `PUSH BOOKSHELF` | Teaches that individual books and an order matter |
| Wrong colored book | Resets sequence with explicit feedback |
| `USE VIAL ON PLANTS` | Identifies poison |
| `TASTE VIAL` | Telegraphs danger and applies recoverable health loss |
| `OPEN LOCKED BOX` | Teaches name-dial interaction |
| `TURN BOX TO HUDSON/LADY` | Rejects wrong connection in-world |
| `TURN BOX TO MORIARTY` early | Identifies missing categories without opening |
| `ASK NPC` without topic | Prompts for a topic; never crashes |
| `ASK INSPECTOR ABOUT CASE` | Explains threat/method/motive presentation |
| `ACCUSE MORIARTY` early | Explains missing chain or absent Lestrade |
| Bare final accusation | Offers letter/poison choice |

## Softlock Rules

- Cipher can be retried indefinitely.
- All evidence counters are one-time guarded transitions.
- Name dial cannot consume or destroy clues.
- Wrong accusations do not end the game.
- Lestrade arrival is checked after both evidence and interview changes.
- Moriarty and Lestrade are physically co-located in the final hub.
- Both final choices use evidence already required by the case chain.
