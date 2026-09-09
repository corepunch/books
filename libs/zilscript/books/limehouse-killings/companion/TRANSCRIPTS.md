# The Limehouse Killings — Companion Transcripts

## Evidence Status

This is a manually assembled golden-path draft, not executor-generated
validation evidence. The referenced `--choices 6` mode is not supported:
`main.lua` accepts limits from 1 through 5, and `llm.lua` does not yet implement
`--choices` or `--choose`. Individual excerpts remain useful as a route and
wording reference, but they do not prove that every card was visible and
executed from the matching state.

Future validation should be captured as structured JSONL by a persistent runner,
then rendered into this document. Each record should name the state family,
setup checkpoint, mode, complete visible ID set, selected stable ID, hidden
command, exact output assertion, postcondition, and pass/fail result. This avoids
hand transcription, repeated route replay, unsupported option drift, and token
cost spent reformatting deterministic evidence.

## Draft Golden Path Transcript

This draft preserves the original six-card mockups as route-planning material.
Regenerate it under the supported limit of five before treating it as execution
evidence.

### Act I: Exploration

**Step 1: Gate — Read Telegram**
```
Scene: Wet iron bars divide the river fog into pale strips.
Choices:
  1. Read the creased telegram [investigate, 100]
  2. Listen to the river sounds beyond the fog [investigate, 40]
  3. Examine the iron gates [investigate, 35]
  4. Read the creased telegram [fallback, 25]
  5. Go to Ashworth Manor Entrance Hall [return, 30]

Selected: 1 → read telegram
Result: (Taken) Lady Ashworth's message reads: 'Begin with what the locked room could not hide...'
```

**Step 2: Gate — Enter Manor**
```
Choices:
  1. Listen to the river sounds [investigate, 40]
  2. Examine the iron gates [investigate, 35]
  3. Follow the gravel path to Ashworth Manor [progress, 95]

Selected: 3 → north
Result: Ashworth Manor Entrance Hall
```

**Step 3: Entrance Hall — Try Study Door**
```
Choices:
  1. Try the study door to the north [investigate, 90]
  2. Examine the family portraits [interact, 35]
  3. Take the magnifying glass [investigate, 80]
  4. Step into the library [progress, 95]
  5. Enter the dining room [progress, 85]
  6. Go down the stairs to the kitchen [progress, 75]

Selected: 1 → north
Result: The study door is closed.
```

**Step 4: Entrance Hall — Take Magnifying Glass**
```
Choices:
  1. Take the magnifying glass [investigate, 80]
  2. Examine the family portraits [interact, 35]
  3. Pull the servant-bell wire [experiment, 30]
  4. Step into the library [progress, 95]
  5. Enter the dining room [progress, 85]
  6. Go down the stairs to the kitchen [progress, 75]

Selected: 1 → take magnifying glass
Result: You take the magnifying glass.
```

**Step 5: Entrance Hall — Go to Library**
```
Selected: 4 → east
Result: Library — Dr. Moriarty waits by the scientific folios.
```

**Step 6: Library — Take Torn Page**
```
Choices:
  1. Take the torn page [progress, 100]
  2. Ask Dr. Moriarty about poison [investigate, 85]
  3. Ask Dr. Moriarty about experiments [interact, 80]
  4. Take the secret ledger [progress, 90]
  5. Examine the colored markers [investigate, 85]

Selected: 1 → take torn-page
Result: You take the torn page.
```

**Step 7: Library — Take Secret Ledger**
```
Selected: 1 → take secret-ledger
Result: You take the secret ledger.
```

**Step 8: Library — Read Torn Page**
```
Selected: 2 → read torn-page
Result: 'Among the marked books, follow the rainbow order: red, yellow, green, blue.'
```

**Step 9: Library — Ask Moriarty About Experiments**
```
Selected: 3 → ask moriarty about experiments
Result: My experiments concern medicinal plants. Lord Ashworth financed some of the work.
```

**Step 10: Library — Ask Moriarty About Poison**
```
Selected: 4 → ask moriarty about poison
Result: Wolfsbane? Aconitum? I keep some for research. That proves nothing.
```

**Step 11: Library — Examine Markers**
```
Selected: 5 → examine colored-markers
Result: RED on shelf 1, BLUE on shelf 3, GREEN on shelf 4, YELLOW on shelf 2.
```

### Cipher Puzzle

**Step 12-15: Push Books in Rainbow Order**
```
Push red book → clicks into place
Push yellow book → clicks into place
Push green book → clicks into place
Push blue book → The wall slides open, revealing a secret passage.
                   The investigation has changed.
```

### Act II: Reconstruction

**Step 16: Library — Enter Secret Passage**
```
Selected: Step through the opened bookshelf → east
Result: Secret Passage — narrow stone, cobwebs, moisture
```

**Step 17: Secret Passage — Go to Study**
```
Selected: Follow the passage east → east
Result: Study — chalk outline, cold ash, locked box
```

**Step 18-20: Study — Collect Evidence**
```
Take dead-letter → You take the unsent letter.
Take poison-bottle → You take the poison bottle.
Read dead-letter → 'My dear Dr. Moriarty, I know what you did...'
```

**Step 21: Study — Open Door**
```
Selected: Open the study door → open study door
Result: You draw back the interior bolt and open the study door.
```

### Act II: Evidence Gathering

**Step 22-28: Kitchen → Garden → Greenhouse → Servants**
```
Go to kitchen → open drawer → take lockpick set
Go to garden → examine hedges → take blood-stained knife → take footprint cast
Go to greenhouse → examine labels → use poison-bottle on plants (identify poison)
Go to servants' quarters → ask Hudson about master/alibi/key → show dead-letter
```

**Step 29-32: Back to Manor → Dining Room**
```
Return to kitchen → return to entrance hall
Go to dining room → take wax-seal → ask lady about marriage/alibi
Show dead-letter to lady → 'My husband meant to expose Moriarty tonight.'
```

### Act III: Confrontation

**Step 33-35: Present Evidence to Lestrade**
```
Show dead-letter to inspector → 'Intent and opportunity. First link.'
Show poison-bottle to inspector → 'A poison he admits keeping. Second link.'
Show bank-statement to inspector → 'The same five hundred pounds. Chain complete.'
```

**Step 36: Accuse Moriarty**
```
Accuse moriarty → 'Which proof leads the charge?'
Accuse moriarty with letter → Dr. Moriarty is arrested.
```

**Result: THE LIMEHOUSE KILLINGS — SOLVED**

## Interface

`--companion` displays every eligible scene and movement choice and also
accepts typed parser commands.

## Recommendations

1. Keep every displayed choice distinct and useful.
2. The cipher puzzle requires multiple turns due to sequential book pushes.
3. The study companion guides players through prerequisites before box opening.
4. Act III companion prioritizes evidence presentation to Lestrade.
