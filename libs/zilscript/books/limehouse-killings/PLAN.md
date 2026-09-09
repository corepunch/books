# Implementation Plan: The Limehouse Killings

## Overview

**Title:** The Limehouse Killings  
**Setting:** Victorian London, 1888  
**Player Role:** Private detective hired to investigate the murder of Lord Ashworth  
**Tone:** Dark, atmospheric, investigative noir  
**Win Condition:** Identify the murderer and present evidence to Scotland Yard  
**Lose Conditions:** Accuse the wrong person, miss critical evidence, or get killed investigating

## Design Decisions

- **No timer:** Player explores at own pace
- **Medium scope:** 10 rooms, 4 major puzzles, ~2.5 hour playtime
- **Multiple solution paths:** Some clues can be found in different orders
- **Fair play:** All clues discoverable through exploration and conversation

## File Organization

```
limehouse-killings/
├── DESIGN.md              # Foundation: premise, tone, win/lose
├── PLAN.md                # This file: implementation plan
├── dungeon.zil            # ZIL: rooms, objects, world data
├── actions.zil            # ZIL: routines, puzzle logic, NPCs
├── work/                  # Working materials & design docs
│   ├── MAP.md             # Room graph and navigation
│   ├── OBJECTS.md         # Object registry with flags
│   ├── PUZZLES.md         # Puzzle design with solutions
│   ├── STORY_STATE.md     # Game state variables
│   ├── TRANSCRIPT_TESTS.md # Test transcript plans
│   ├── PROSE.md           # Room/object descriptions, NPC topics
│   ├── HINTS.md           # Progressive hint system
│   └── ITERATION.md       # Development roadmap
├── test/                  # Testing materials
│   ├── TESTING.md         # Regression tests, bug ledger
│   └── walkthrough.zil    # Golden path test file
└── package/               # Packaging & release materials
    ├── COVER.md           # Visual description
    ├── TAGLINE.md         # Marketing taglines
    ├── SYNOPSIS.md        # Story summaries
    ├── REVIEWS.md         # Critical reviews
    └── METADATA.md        # Technical details
```

## Room Map

```
ASHWORTH-MANOR-GATE
  ↓
ASHWORTH-ENTRANCE-HALL
  ├→ STUDY (locked until evidence found)
  ├→ LIBRARY
  ├→ DINING-ROOM
  ├→ KITCHEN
  └→ GARDEN
      ├→ GREENHOUSE
      └→ SERVANTS-QUARTERS

LIBRARY → SECRET-PASSAGE (hidden, requires solving book puzzle)
SECRET-PASSAGE → STUDY (alternate entrance)

DINING-ROOM → PANTRY
```

## Puzzle Architecture

### Puzzle 1: Study Entry
- **Goal:** Enter the locked study where the body was found
- **Solution:** Find key from butler OR use lockpick on window
- **Clues:** Butler mentions key, window latch visible from garden
- **Dependencies:** None (can be solved first)

### Puzzle 2: Library Cipher
- **Goal:** Decode hidden message in bookshelf arrangement
- **Solution:** Arrange books by spine color to reveal message
- **Clues:** Torn page mentions "rainbow order", colored markers on shelves
- **Dependencies:** None (parallel to Puzzle 1)

### Puzzle 3: Greenhouse Poison
- **Goal:** Identify poison type and find antidote ingredients
- **Solution:** Match poison bottle label to plant species
- **Clues:** Victim's symptoms described in medical report, poison bottle in study
- **Dependencies:** Requires access to study (Puzzle 1)

### Puzzle 4: Final Confrontation
- **Goal:** Present correct evidence to accuse the killer
- **Solution:** Gather all 5 key pieces of evidence, present to Inspector
- **Clues:** Each suspect has motive, means, opportunity - evidence points to one
- **Dependencies:** Requires all prior puzzles solved

## Evidence Collection (5 Key Items)

1. **DEAD-LETTER** - Unsent letter from victim threatening to expose killer
2. **BLOOD-STAINED-KNIFE** - Murder weapon found in garden
3. **LOCKED-BOX** - Contains damning correspondence
4. **POISON-BOTTLE** - Rare poison only available to certain suspects
5. **SECRET-LEDGER** - Financial records showing motive

## NPCs

### Mr. Hudson (Butler)
- **Topics:** Master, household, staff, evening of murder
- **Key Info:** Has study key, saw someone near study door
- **Demeanor:** Nervous, evasive about certain topics

### Lady Ashworth (Wife)
- **Topics:** Marriage, husband's work, enemies, alibi
- **Key Info:** Claims to be in drawing room all evening
- **Demeanor:** Cold, calculating, too composed

### Dr. Moriarty (Scientist)
- **Topics:** Experiments, poison, relationship with victim
- **Key Info:** Specializes in rare poisons, owed money by victim
- **Demeanor:** Brilliant, arrogant, slipshod alibi

## Game State Variables

- `MURDER-SOLVED` (boolean)
- `EVIDENCE-FOUND` (counter, 0-5)
- `SUSPECTS-INTERVIEWED` (counter, 0-3)
- `STUDY-UNLOCKED` (boolean)
- `SECRET-PASSAGE-FOUND` (boolean)
- `ACCUSED-SUSPECT` (name or false)

## Implementation Stages

### Stage 1: Foundation & Premise
- [x] Write DESIGN.md

### Stage 2: Working Materials & Design Docs
- [x] Write MAP.md
- [x] Write OBJECTS.md
- [x] Write PUZZLES.md
- [x] Write STORY_STATE.md
- [x] Write TRANSCRIPT_TESTS.md

### Stage 3: World Model & Puzzle Architecture
- [x] Update PUZZLES.md with dependency graph
- [x] Create verb/object response matrix
- [x] Create softlock prevention notes

### Stage 4: Content Writing & NPC Layer
- [x] Write room descriptions (PROSE.md)
- [x] Write object descriptions (PROSE.md)
- [x] Create NPC topic tables (PROSE.md)
- [x] Create hint tiers (PROSE.md, HINTS.md)

### Stage 5: ZIL Implementation
- [x] Write dungeon.zil
- [x] Write actions.zil
- [x] Write walkthrough.zil

### Stage 6: Testing & Debugging
- [x] Create regression transcripts (TESTING.md)
- [x] Create bug ledger (TESTING.md)
- [x] Create fix changelog (TESTING.md)

### Stage 7: Workflow & Hint UX
- [x] Create hint panel content (HINTS.md)
- [x] Create iteration plan (ITERATION.md)

### Stage 8: Packaging & Release
- [x] Write COVER.md
- [x] Write TAGLINE.md
- [x] Write SYNOPSIS.md
- [x] Write REVIEWS.md
- [x] Write METADATA.md

## Verification Strategy

- Run `make test-pure-zil` after ZIL implementation
- Execute walkthrough.zil for golden path verification
- Test wrong-attempt transcripts
- Verify no softlocks through systematic playtesting
- Check all objects are reachable and takeable (where appropriate)
