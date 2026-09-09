# Wondertown — Story State

## Global State Variables

### Tick/Counter State
| Global | Type | Initial | Description |
|--------|------|---------|-------------|
| TICK-COUNT | Integer | 200 | Turns until dawn. Decrements each action. At 0, game over. |
| CLOCK-SLOWED | Boolean | <> | True after winding clock tower (tick rate halved) |
| CLOCK-WOUND-COUNT | Integer | 0 | How many times clock tower was wound (affects tick rate) |

### Key State
| Global | Type | Initial | Description |
|--------|------|---------|-------------|
| KEY-FOUND | Boolean | <> | True when player recovers workshop key from Nutmeg |
| KEY-WOUND | Boolean | <> | True when key is inserted into workshop heart |
| NUTMEG-KEY-METHOD | Integer | 0 | 0=not obtained, 1=trust, 2=taken while asleep, 3=taken by force |

### NPC Trust/State
| Global | Type | Initial | Description |
|--------|------|---------|-------------|
| BERTRAND-WOUND | Boolean | <> | Bertrand has been wound |
| BERTRAND-POLITE | Boolean | <> | Player addressed Bertrand properly (CAPTAIN/SIR) |
| MARZIPAN-BUTTON | Boolean | <> | Player gave Marzipan her spare button |
| OLD-TICK-HEARD | Boolean | <> | Player listened to Old Tick on the hour |
| OLD-TICK-RIDDLES | Integer | 0 | Number of riddles heard from Old Tick |
| NUTMEG-TRUST | Integer | 0 | 0=hostile, 1=wary, 2=softening, 3=trusting, -1=betrayed |
| NUTMEG-GIFTS | Integer | 0 | Count of gifts given to Nutmeg |

### Puzzle Completion
| Global | Type | Initial | Description |
|--------|------|---------|-------------|
| LADDER-OILED | Boolean | <> | Ladder mechanism has been oiled |
| CART-MOVED | Boolean | <> | Scrap cart has moved aside |
| CART-HELPED | Boolean | <> | Player helped the cart (gave doll head) |
| TOWER-WOUND | Boolean | <> | Clock tower was wound at least once |
| STUDY-ACCESS | Boolean | <> | Player accessed Tolliver's study |
| HEART-ACCESS | Boolean | <> | Player accessed workshop heart |

### Lore Discovered
| Global | Type | Initial | Description |
|--------|------|---------|-------------|
| JOURNAL-READ | Boolean | <> | Player read Tolliver's journal in loft |
| LETTER-READ | Boolean | <> | Player read Tolliver's letter at mailbox |
| DIAGRAM-READ | Boolean | <> | Player read winding diagram in study |
| STUDY-JOURNAL-READ | Boolean | <> | Player read final journal entry |

### Ending State
| Global | Type | Initial | Description |
|--------|------|---------|-------------|
| GAME-WON | Boolean | <> | Game has been won |
| ENDING-TIER | Integer | 0 | 0=none, 1=key only, 2=some companions, 3=all companions |
| COMPANION-COUNT | Integer | 0 | Number of companions at heart for final rewind |
| NUTMEG-SAVED | Boolean | <> | Nutmeg was part of the final rewind |


## Progress Milestones

### Chapter 1: "The Nightly Rounds" (Ticks 200-150)
- [ ] Start: WORKSHOP-FLOOR, examine key hook (empty)
- [ ] Find oil can under workbench
- [ ] Meet Bertrand at TOOL-BENCH
- [ ] WIND BERTRAND (first puzzle)
- [ ] Reach COUNTERTOP, meet Marzipan
- [ ] OIL LADDER (second puzzle)
- [ ] Reach STORAGE-LOFT, meet Old Tick
- [ ] Read Tolliver's journal in loft
- [ ] Go through pet door to SNOWY-ALLEY

### Chapter 2: "Wrenfold By Night" (Ticks 150-80)
- [ ] Enter SNOWY-ALLEY, find footprints
- [ ] Reach CLOCK-SQUARE
- [ ] Visit MAILBOX-CORNER, read Tolliver's letter
- [ ] Reach SCRAP-YARD
- [ ] Help scrap cart (or bypass)
- [ ] Enter FOX-DEN, meet Nutmeg
- [ ] Befriend Nutmeg (or force key)
- [ ] Obtain workshop key

### Chapter 3: "What the Clockwork Remembers" (Ticks 80-0)
- [ ] Return to workshop with key
- [ ] Access Tolliver's study (Old Tick + Nutmeg help)
- [ ] Read diagram and final journal
- [ ] Access workshop heart
- [ ] Wind heart with key
- [ ] Choose companions / place toys
- [ ] Final rewind — ending

### Scoring (optional, for replayability)
- **Score** = companions saved × 10 + puzzles solved × 5 + lore discovered × 3
- **Max score:** ~100


## Tick Mechanics Detail

### Baseline
- Each player action = 1 tick (movement, examining, taking)
- Complex actions (winding, oiling, giving) = 2 ticks

### Clock Tower Effect
- Winding tower once: tick cost halved (movement = 0.5, rounded up = 1 per 2 moves)
- Winding tower twice: tick cost quartered (effective)

### Dawn Warnings
| Ticks Left | Message |
|-----------|---------|
| 100 | "The sky outside the window is still dark. You have time." |
| 50 | "Through the frosted window, the sky shows the first grey of approaching dawn." |
| 25 | "The eastern sky is pale now. Dawn is not far." |
| 10 | "Golden light creeps at the horizon. You have minutes, not hours." |
| 5 | "Sunlight touches the rooftops. Hurry!" |
| 0 | Game over: "The sun rises. The last tick fades. The workshop is still." |


## Unwinnable State Prevention

### Guaranteed Recoverability
- All puzzle-critical items respawn or are never lost
- Oil can: if dropped in unreachable location, reappears under workbench after 10 turns
- Workshop key: never droppable once obtained (or if dropped, Nutmeg returns it)
- Bertrand key: always on Bertrand or in TOOL-BENCH
- Journal entries: readable in-place if dropped
- Diagram: readable in-place if dropped

### No Dead Ends
- Tick timer is the only permanent fail state
- Player can always return to workshop through pet door
- Nutmeg can be circumvented (not required for key — alternative path exists)
- All exits are bi-directional where possible

### Save-Friendly
- Tick counter is saved/restored correctly
- All globals are saved/restored
- NPC locations save correctly
