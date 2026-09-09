# Wondertown — Transcript Tests

## Golden Path Walkthrough

This is the exact command sequence that completes the game with the best ending (all companions). Every command is literal player input.

### Act 1 — "The Nightly Rounds"

| # | Command | Expected Output (key text) | State Change |
|---|---------|---------------------------|--------------|
| 1 | `look` | "Grandfather Tolliver's workshop" / "key hook" / "workbench towers" / "pet door" / "cuckoo clock" | HERE = WORKSHOP-FLOOR |
| 2 | `examine hook` | "brass key hook" / "empty" / "frayed string" | — |
| 3 | `take string` | "taken" | KEY-STRING in inventory |
| 4 | `examine workbench` | "enormous workbench" / "cluttered" | — |
| 5 | `look under workbench` | "tiny copper oil can" | OIL-CAN visible |
| 6 | `take oil can` | "taken" | OIL-CAN in inventory |
| 7 | `examine clock` | "old cuckoo clock" / "ticking softly" | — |
| 8 | `examine pet door` | "small pet door" / "cut into" / "workshop door" | — |
| 9 | `walk east` | "tool bench" / "nutcracker stands at attention" / "frozen mid-stride" | HERE = TOOL-BENCH |
| 10 | `examine nutcracker` | "painted wooden nutcracker" / "frozen" / "winding key in his back" | — |
| 11 | `take key` | "tiny brass winding key" / "taken" | BERTRAND-KEY in inventory |
| 12 | `wind nutcracker` | "CLACK" / "At last!" / "steps aside" | BERTRAND-WOUND = T, access to COUNTERTOP |
| 13 | `climb spool` | "countertop" / "display case" / "rag doll" / "humming" | HERE = COUNTERTOP |
| 14 | `examine doll` | "rag doll with one button eye" / "humming" | — |
| 15 | `ask doll about tolliver` | sings / "Fox feet" / "through the door" / "broken toys" | — |
| 16 | `examine display case` | "dusty glass display case" / "tin soldier" / "music box" | — |
| 17 | `open case` | "opened" | DISPLAY-CASE open |
| 18 | `take soldier` | "tin soldier" / "taken" | TIN-SOLDIER in inventory |
| 19 | `take music box` | "silver music box" / "taken" | MUSIC-BOX in inventory |
| 20 | `take button` | "spare button" / "taken" | BUTTON in inventory |
| 21 | `give button to doll` | "For me?" / "sews it on" / "second eye" | MARZIPAN-BUTTON = T |
| 22 | `climb down` | "tool bench" | HERE = TOOL-BENCH |
| 23 | `walk west` | "workshop" | HERE = WORKSHOP-FLOOR |
| 24 | `examine mechanism` | "rusty iron mechanism" / "rusted solid" | — |
| 25 | `oil mechanism` | "satisfying creak" / "loosens" / "climbable" | LADDER-OILED = T |
| 26 | `climb spool stairs` | "storage loft" / "cobwebs" / "cuckoo clock" / "dusty" | HERE = STORAGE-LOFT |
| 27 | `examine clock` | "old cuckoo clock" / "dusty" / "five to midnight" | — |
| 28 | `listen` | (Old Tick chimes and speaks a riddle) | OLD-TICK-HEARD = T |
| 29 | `examine toy box` | "cardboard box" / "broken" | — |
| 30 | `open box` | "opened" / "porcelain doll arm" | TOY-BOX open |
| 31 | `take arm` | "porcelain doll arm" / "taken" | DOLL-ARM in inventory |
| 32 | `take journal` | "leather journal" / "taken" | TOLLIVER-JOURNAL in inventory |
| 33 | `read journal` | (Tolliver's notes about the key, the heart, the magic) | JOURNAL-READ = T |
| 34 | `climb down` | "workshop" | HERE = WORKSHOP-FLOOR |
| 35 | `go through pet door` | "snowy alley" / "fresh snow" / "footprints" / "streetlamp flickering" | HERE = SNOWY-ALLEY |

### Act 2 — "Wrenfold By Night"

| # | Command | Expected Output (key text) | State Change |
|---|---------|---------------------------|--------------|
| 36 | `examine footprints` | "tiny fox footprints" / "lead east" | — |
| 37 | `walk east` | "clock square" / "clock tower" / "face showing hours" | HERE = CLOCK-SQUARE |
| 38 | `examine tower` | "clock tower" / "brass winding mechanism" / "base" | — |
| 39 | `walk east` | "mailbox corner" / "red mailbox" / "crumpled letter" / "snow" | HERE = MAILBOX-CORNER |
| 40 | `take letter` | "crumpled envelope" / "taken" | LETTER in inventory |
| 41 | `read letter` | "Gone to mend the heart" / "Take care of them" | LETTER-READ = T |
| 42 | `take scarf` | "red wool scarf" / "taken" | SCARF in inventory |
| 43 | `examine mailbox` | "tin mailbox" / "flap moves like a mouth" | — |
| 44 | `ask mailbox about fox` | "scrap-yard" / "east of the square" | — |
| 45 | `walk west` | "clock square" | HERE = CLOCK-SQUARE |
| 46 | `walk south` | "scrap-yard" / "broken toys" / "scrap cart creaking" | HERE = SCRAP-YARD |
| 47 | `examine cart` | "scrap-metal cart" / "lovingly repaired" / "broken toys" / "not to destroy" | — |
| 48 | `take doll head` | "porcelain doll head" / "taken" | DOLL-HEAD in inventory |
| 49 | `give head to cart` | "mechanical arm" / "gently takes" / "gratitude" / "rolls aside" / "path east" | CART-MOVED = T, CART-HELPED = T |
| 50 | `walk east` | "fox den" / "patchy fur" / "key around her neck" / "warms herself" | HERE = FOX-DEN |
| 51 | `examine fox` | "fox-shaped toy" / "button eyes" / "key hangs" / "string" | — |
| 52 | `ask fox about key` | "hugs the key" / "never been mine" | NUTMEG-TRUST = 1 |
| 53 | `give scarf to fox` | "For me?" / "voice cracks" | NUTMEG-TRUST = 2, NUTMEG-GIFTS = 1 |
| 54 | `tell fox about tolliver` | "ears droop" / "he fixed me once" | NUTMEG-TRUST = 3 |
| 55 | `take key` | "paws the key off" / "promise you'll come back" | KEY-FOUND = T, WORKSHOP-KEY in inventory |
| 56 | `walk west` | "scrap-yard" | HERE = SCRAP-YARD |
| 57 | `walk north` | "clock square" | HERE = CLOCK-SQUARE |
| 58 | `walk west` | "snowy alley" | HERE = SNOWY-ALLEY |
| 59 | `go through pet door` | "workshop" | HERE = WORKSHOP-FLOOR |

### Act 3 — "What the Clockwork Remembers"

| # | Command | Expected Output (key text) | State Change |
|---|---------|---------------------------|--------------|
| 60 | `examine clock` | "old cuckoo clock" / "chimes" / "deep resonant gong" | — |
| 61 | `wind clock` | "The hour of reckoning comes" / (Nutmeg pushes latch) | STUDY-ACCESS = T |
| 62 | `go behind clock` | "Tolliver's study" / "desk" / "coat on chair" / "cold tea" | HERE = TOLLIVER-STUDY |
| 63 | `examine desk` | "cluttered wooden desk" / "diagram" / "journal" | — |
| 64 | `take diagram` | "hand-drawn diagram" / "taken" | DIAGRAM in inventory |
| 65 | `read diagram` | (winding instructions for workshop heart) | DIAGRAM-READ = T |
| 66 | `read journal` | (Tolliver's final entry — he tried to wind the heart but couldn't alone) | STUDY-JOURNAL-READ = T |
| 67 | `climb down` | "workshop" | HERE = WORKSHOP-FLOOR |
| 68 | `wind heart with key` | (heart begins turning) / "need more power" | HEART-ACCESS = T |
| 69 | `place soldier` | "tin soldier" / "stands guard" / "heart beats stronger" | COMPANION-COUNT = 1 |
| 70 | `place music box` | "silver music box" / "plays soft tune" / "heart glows" | COMPANION-COUNT = 2 |
| 71 | `turn crank on music box` | (music box plays, heart strengthens further) | — |
| 72 | (Nutmeg volunteers) | "Let me help" / "curls beside the heart" | NUTMEG-SAVED = T, COMPANION-COUNT = 3 |
| 73 | (Final rewind triggers) | "heart beats strong" / "magic flows" / "Wrenfold wakes" / ending text | GAME-WON = T, ENDING-TIER = 3 |

### Expected Ending Text (Best Ending)
> The workshop heart beats — a deep, steady rhythm that echoes through every corner of Wrenfold. The clock tower chimes. Toys stir in shop windows. The streetlamps flicker to full brightness. Grandfather Tolliver's voice, somehow, whispers: "Well done, apprentice."

> Nutmeg curls at your feet, her patchy fur warm. "You kept your promise," she says. "Nobody ever kept their promise before."

> The sun rises over Wrenfold, and every toy in town is awake to see it.


## Failure Path Tests

### Test 1: Attempting to force key from Nutmeg
```
> attack fox
"She flinches. 'I knew it. You're just like the others.' She retreats deeper into her den, key clutched tight."
(NUTMEG-TRUST = -1)
```
After this, `take key` → "Nutmeg growls. The key is around her neck, and she won't let you near it."
**Alternate:** Wait 20 turns → Nutmeg falls asleep → `take key` works but NUTMEG-KEY-METHOD = 2 (lesser ending).

### Test 2: Missing Bertrand politeness
```
> push nutcracker
"He's far too heavy. And you'd never want to be rude to a nutcracker."
> attack nutcracker
"You wouldn't dare. He has a very strong jaw."
```
Even without politeness, `wind nutcracker` still works — Bertrand just makes a snide remark about manners.

### Test 3: Attempting climb before oiling
```
> climb spool stairs
"The mechanism groans but won't budge. It's rusted solid."
```

### Test 4: Ignoring scrap cart
```
> push cart
"The cart is too heavy. It rumbles warningly."
> attack cart
"The cart doesn't fight back. It simply continues its work, ignoring you."
```
Valid bypass: If Nutmeg already trusts player (reached FOX-DEN through alternate path), the gate opens from the other side.

### Test 5: Wrong order — trying to go outside before Act 1 complete
```
> go through pet door
(Works fine — player can come and go freely)
```
No softlock: pet door is always accessible both ways.


## Alternate Wording Tests (Parser robustness)

| Canonical Command | Alternate Wording | Should Match? |
|-------------------|-------------------|---------------|
| `wind nutcracker` | `wind bertrand` | Yes |
| `oil mechanism` | `oil ladder` / `oil spool stairs` | Yes |
| `climb spool` | `climb stairs` / `go up` | Yes |
| `go through pet door` | `go out` / `go north` / `crawl through door` | Yes |
| `give scarf to fox` | `give scarf to nutmeg` | Yes |
| `give head to cart` | `give doll head to cart` | Yes |
| `examine nutcracker` | `look at nutcracker` / `look at bertrand` | Yes |
| `ask doll about tolliver` | `tell doll about tolliver` / `ask marzipan about key` | Yes |
