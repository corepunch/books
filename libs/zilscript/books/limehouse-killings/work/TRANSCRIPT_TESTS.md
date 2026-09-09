# The Limehouse Killings - Canonical Transcript Plan

Literal parser coverage lives in `tests/test_limehouse_walkthrough.lua`. This document records the human-readable intent of those commands and is the source for future `.zil` refactor transcripts.

## Golden Path

### Opening and blocker

```text
READ TELEGRAM
GO NORTH
GO SOUTH
OPEN STUDY DOOR
```

Expected signals:

- Telegram is visible at game start and rewards immediate interaction.
- Entrance Hall is north of the gate.
- South movement is blocked while the study door is closed.
- Opening the locked door suggests key/lockpick without claiming they are the only route.
- `EXAMINE INSPECTOR` here reports that no inspector is present.

### Act I threshold: library sequence

```text
GO EAST
EXAMINE READING DESK
TAKE TORN PAGE
READ TORN PAGE
EXAMINE COLORED MARKERS
PUSH RED BOOK
PUSH YELLOW BOOK
PUSH GREEN BOOK
PUSH BLUE BOOK
```

Expected signals:

- Each correct push clicks.
- Blue completes the sequence and opens the concealed wall.
- `CASE-ACT` becomes 2.
- Library exposes a passage route and Entrance Hall gains bell-wire aftermath.

### Locked-room reconstruction

```text
GO SOUTH
GO EAST
EXAMINE CHALK OUTLINE
EXAMINE DESK
TAKE DEAD LETTER
READ DEAD LETTER
TAKE POISON BOTTLE
EXAMINE POISON BOTTLE
OPEN STUDY DOOR
```

Expected signals:

- Passage leads into Study without key or lockpick.
- Letter records threat once; vial records method clue once.
- Opening door from inside releases the interior bolt and opens the physical door.

### Environmental evidence and optional tools

```text
GO NORTH
GO WEST
EXAMINE TABLE
TAKE WAX SEAL
GO NORTH
EXAMINE SHELVES
TAKE FOXGLOVE
TAKE CHARCOAL
GO SOUTH
GO EAST
GO DOWN
EXAMINE DRAWER
OPEN DRAWER
EXAMINE DRAWER
EXAMINE LEATHER ROLL
OPEN LEATHER ROLL
TAKE LOCKPICK SET
GO WEST
EXAMINE HEDGES
TAKE BLOOD-STAINED KNIFE
TAKE FOOTPRINT CAST
```

Expected signals:

- Container state is physical and persistent.
- Spaced compound nouns parse.
- Knife increments evidence once; footprint is corroboration rather than a required counter item.
- Foxglove, charcoal, and lockpick remain optional; they do not solve the central deductions.

### Poison comparison

```text
GO NORTH
EXAMINE PLANTS
EXAMINE LABELS
USE VIAL ON PLANTS
```

Expected signal: `POISON-IDENTIFIED` becomes true and output explicitly matches Aconitum/wolfsbane between vial and greenhouse.

### Interviews and visible behavior

```text
GO SOUTH
GO SOUTH
ASK HUDSON
ASK HUDSON ABOUT MASTER
ASK HUDSON ABOUT ALIBI
ASK HUDSON ABOUT KEY
ASK HUDSON ABOUT MORIARTY

GO NORTH
GO EAST
GO UP
GO WEST
ASK LADY
ASK LADY ABOUT MARRIAGE
ASK LADY ABOUT ALIBI

GO EAST
GO EAST
ASK MORIARTY
ASK MORIARTY ABOUT EXPERIMENTS
ASK MORIARTY ABOUT POISON
```

Expected signals:

- Each topicless `ASK` asks what topic the player intends and never crashes.
- Only each suspect's designated interview topic increments `SUSPECTS-INTERVIEWED`.
- Moriarty admits poison access, changes behavior, and moves toward the hall.
- With at least three discoveries and all interviews, `CASE-ACT` becomes 3 and Lestrade arrives.

Intermediate-state coverage:

```text
SHOW LETTER TO HUDSON
SHOW LETTER TO LADY
SHOW LETTER TO MORIARTY
EXAMINE <NPC>
```

Run each on a branch before Act III and assert the player-changed description/dialogue.

The automated golden path also magnifies the footprint cast, checks the wine-cabinet delivery clue, tastes and recovers from the vial with charcoal, and shows the detailed cast to Lestrade.

### Name-dial deduction

```text
TAKE SECRET LEDGER
READ SECRET LEDGER
GO WEST
GO SOUTH
GO EAST
EXAMINE LOCKED BOX
TURN LOCKED BOX TO MORIARTY
TAKE BANK STATEMENT
READ BANK STATEMENT
```

Expected signals:

- Box examine states that there is no keyhole and names three engravings.
- Keyring/lockpick are irrelevant to this box.
- Successful dial output explicitly connects letter, flower, and debt.
- Statement becomes reachable only after `OPENBIT` is set.
- Score reaches five counted discoveries.

### Case assembly and chosen-proof ending

```text
GO NORTH
ASK INSPECTOR
ASK INSPECTOR ABOUT CASE
SHOW LETTER TO INSPECTOR
SHOW BOTTLE TO INSPECTOR
SHOW STATEMENT TO INSPECTOR
ACCUSE MORIARTY
ACCUSE MORIARTY WITH LETTER
```

Expected signals:

- Topicless Inspector conversation is safe.
- Lestrade describes threat, method, and motive rather than “five items.”
- Each accepted link changes a specific presentation flag.
- Bare accusation asks the player to choose letter or poison.
- Letter-led ending references witness confirmation, greenhouse/vial, ledger/statement/name dial, footprint/knife, dawn, tea, and a future case.

Alternate ending branch:

```text
ACCUSE MORIARTY WITH POISON
```

Expected difference: Moriarty exposes guilty specialized knowledge of the vial before the common arrest/consequence sequence.

## Required Failure and Recovery Transcripts

### Topicless conversation

Run against Hudson, Lady Ashworth, Moriarty, and Lestrade when present:

```text
ASK <NPC>
TELL <NPC>
```

Expected: prompt for a topic; no runtime error, nil text, or generic manual response.

### Compound nouns

```text
TAKE LOCKPICK SET
TAKE FOOTPRINT CAST
```

Expected: both resolve despite `SET` and `CAST` having verb senses.

### Inspector timing

```text
[Act I] EXAMINE INSPECTOR
```

Expected: not in scope.

After Act III threshold:

```text
LOOK
EXAMINE INSPECTOR
ASK INSPECTOR ABOUT CASE
```

Expected: room lists Lestrade, examine works, case topic works.

### Cipher recovery

```text
PUSH RED BOOK
PUSH BLUE BOOK
```

Expected: reset, then the complete correct sequence remains available.

### Name dial recovery

```text
OPEN LOCKED BOX
TURN LOCKED BOX TO HUDSON
TURN LOCKED BOX TO MORIARTY    [before prerequisites]
```

Expected: teach dial syntax; reject wrong name; identify unresolved clue categories. None consumes evidence or blocks retry.

### Early/weak accusation

```text
ACCUSE MORIARTY                [before Lestrade]
ACCUSE MORIARTY                [before presentations]
ACCUSE MORIARTY WITH KNIFE     [after presentations]
```

Expected: absent-authority response; missing-chain response; irrelevant-lead-proof response. All allow recovery.

### Dangerous action

```text
TASTE VIAL
```

Expected: clear warning/consequence, `PLAYER-HEALTH` decremented, game continues until health reaches zero.

## Room and NPC State Checks

| Milestone | Revisit | Required changed observation |
|---|---|---|
| Cipher solved | Library | Passage visibly open |
| Cipher solved | Entrance Hall | Bell wire quivers |
| Act III reached | Entrance Hall | Lestrade and Moriarty visible |
| Act III reached | Servants' Quarters | Hudson's packed bag/coat |
| Act III reached | Dining Room | Lady's removed ribbon/listening behavior |
| Act III reached | Moriarty examine | Muddy heel/doorward behavior |
| Box solved | Study | Box lies open |

## Automation Commands

```text
make test-limehouse-walkthrough
lua5.4 scripts/check-vocab.lua books/limehouse-killings/dungeon.zil
make test-pure-zil
```

Current baseline at the time of this document update: 531/531 Limehouse parser assertions passing, vocabulary audit clean, and full pure-ZIL suite passing.

## Documentation Drift Guard

Reject future transcript edits that use:

- `MATCH POISON-BOTTLE TO LABEL`
- `FIND WOLFSBANE`
- `USE LOCKPICK ON LOCKED-BOX`
- accusation before evidence presentation
- Inspector present from game start
- “gather five held items to win”

Those phrases describe the superseded item-gate design, not the current story model.
