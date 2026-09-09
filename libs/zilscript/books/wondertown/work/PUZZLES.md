# Wondertown — Puzzles

## Puzzle 1: Wake Bertrand (WIND tutorial)

**Location:** TOOL-BENCH
**Goal:** Get past Bertrand to reach COUNTERTOP.
**Difficulty:** Easy (tutorial)

### Clue Chain
1. Room description: "A painted wooden nutcracker stands at attention, frozen mid-stride."
2. EXAMINE BERTRAND → "He's frozen mid-step. There's a tiny winding key in his back."
3. EXAMINE BERTRAND's back / TAKE KEY → "You take the tiny brass winding key."
4. WIND BERTRAND → "You insert the key and wind. Bertrand's jaw snaps shut with a CLACK. 'At last! A proper winding! I've been stuck in this ridiculous pose for hours.' He steps aside."

### Wrong Attempts
- PUSH BERTRAND → "He's far too heavy. And you'd never want to be rude to a nutcracker."
- TALK TO BERTRAND → "His painted mouth stays clamped shut. He looks rather affronted."
- ATTACK BERTRAND → "You wouldn't dare. He has a very strong jaw."

### Hints (via Old Tick if player is stuck)
1. "Some soldiers need winding before they'll march."
2. "Look closely at the nutcracker's back."
3. "TAKE KEY then WIND BERTRAND."

### Softlock Prevention
- Bertrand-key cannot be lost or dropped somewhere inaccessible (always stays on BERTRAND or in inventory).
- If player drops key on floor, it remains findable (in TOOL-BENCH room).

---

## Puzzle 2: Oil the Ladder (OIL tutorial)

**Location:** WORKSHOP-FLOOR → STORAGE-LOFT
**Goal:** Reach the storage loft where Old Tick and Tolliver's journal are.
**Difficulty:** Easy (tutorial)

### Clue Chain
1. Room description: "A staircase made of giant wooden spools leads upward, its mechanism rusted."
2. EXAMINE SPOOL-STAIRS / MECHANISM → "The lifting mechanism is rusted solid. It needs oil."
3. Player needs OIL-CAN (under WORKBENCH).
4. OIL LADDER or OIL MECHANISM → "You work oil into the rusty joints. With a satisfying creak, the mechanism loosens. The stairs are climbable now."

### Wrong Attempts
- CLIMB SPOOLS (before oil) → "The mechanism groans but won't budge. It's rusted solid."
- PUSH MECHANISM → "You strain against it, but it's rusted tight."
- WIND MECHANISM → "There's nothing to wind here. It needs oil."

### Hints
1. (Marzipan, if asked): "Squeaky soldiers need oiling, tra-la! Squeaky stairs too, fancy that!"
2. "Something under the workbench might help."
3. "OIL MECHANISM with the oil can."

### Softlock Prevention
- Oil can is in an obvious location. If somehow lost, Marzipan can mention "Pip's oil can fell behind the spools" and respawn it.

---

## Puzzle 3: Marzipan's Song (Information puzzle)

**Location:** COUNTERTOP
**Goal:** Get directions to find Nutmeg and learn about the key.
**Difficulty:** Moderate (attention-based)

### Clue Chain
1. Marzipan sings constantly: "Fox feet, fox feet, left the shop / Through the door with a hop and a hop / Key round neck and heart so sore / Find her where the broken toys snore."
2. EXAMINE MARZIPAN → "Her one button eye fixes on you. She hums a little tune, her stitched mouth smiling."
3. Ask/Tell Marzipan about key, Tolliver, or fox — she responds in song couplets with real info.
4. Song contents: fox went through pet door (north), key is around her neck, she's in a place with broken toys (scrap-yard).

### Wrong Attempts
- TAKE MARZIPAN → "She's far too big to carry, and she seems quite happy here."
- GIVE BUTTON TO MARZIPAN → "She looks at the button. 'For me?' Her stitched face seems to brighten. She sews it on as a second eye." (Rewards player with extra song verse containing a secret.)

### Hints
1. "Marzipan's songs aren't just nonsense. Listen carefully."
2. "Ask her about the key or the fox."
3. The song explicitly says "through the door" (pet door) and "broken toys" (scrap-yard).

### Softlock Prevention
- Song always repeats. Player can ask multiple times.

---

## Puzzle 4: The Clock Tower (Tick slowing)

**Location:** CLOCK-SQUARE
**Goal:** Slow the tick rate to buy more time for Act 3.
**Difficulty:** Moderate

### Clue Chain
1. Room description: "The clock tower dominates the square, its face showing the hours until dawn."
2. EXAMINE CLOCK-TOWER → "The clock face reads 3 hours until dawn. A brass winding mechanism sits at the tower's base."
3. Player must have something to stand on — the winding mechanism is too high for tiny Pip.
4. Solution: Move a toy or box beneath, or climb the mechanism itself.
5. WIND CLOCK → "You turn the brass mechanism. The clock's ticking slows to a deep, ponderous beat. Time stretches."

### Wrong Attempts
- WIND CLOCK (without reaching it) → "The winding mechanism is just out of reach."
- PUSH CLOCK → "The tower is impossibly huge."
- OIL CLOCK → "The mechanism isn't rusted — it's just unwound."

### Effect
- Tick rate changes: every move now costs 1 tick instead of 2. Dawn is further away.

### Hints
1. "Time itself can be stretched, if you can reach the key."
2. "You'll need something to stand on."
3. "The tin soldier from the display case is tall enough to boost you."

### Softlock Prevention
- If player never winds clock, game is still winnable (just tighter). Clock winding is a mercy, not a requirement.

---

## Puzzle 5: The Scrap Cart (Compassion misdirection)

**Location:** SCRAP-YARD
**Goal:** Get past the scrap cart by understanding its true nature.
**Difficulty:** Moderate (misdirection)

### Clue Chain
1. Room description: "A scrap-metal cart creaks along, blocking the path east. It moves with an eerie, mechanical purpose."
2. EXAMINE CART → "The cart is old and rusted, but someone has lovingly repaired its wheels. It carries broken toys — not to destroy them, but to shelter them. A headless doll, a three-legged horse — the cart's collection."
3. The cart seems menacing but is actually rescuing broken toys. Attacking or pushing it fails.
4. GIVE DOLL-HEAD TO CART or GIVE DOLL-HEAD TO HEADLESS-DOLL near cart → "The cart pauses. A mechanical arm gently takes the doll head. It places it beside the headless body. The cart rumbles softly — a sound almost like gratitude — and rolls aside, revealing a path east."

### Wrong Attempts
- PUSH CART → "The cart is too heavy. It rumbles warningly."
- ATTACK CART → "The cart doesn't fight back. It simply continues its work, ignoring you."
- WIND CART → "The cart doesn't have a winding mechanism. It seems to move by some other force."

### Hints
1. (From Marzipan): "The cart that creaks is not your foe / It gathers toys with nowhere to go."
2. "Examine the cart closely."
3. "The headless doll in the cart needs its head. There's one in the scrap piles."

### Softlock Prevention
- The doll head is findable in the same room (SCRAP-YARD). If player loses it, another head can be found.
- Cart puzzle can be bypassed if Nutmeg trusts Pip — she'll open the gate from her side.

### Alternate Solution
- If Nutmeg already trusts Pip (from direct interaction in FOX-DEN via another path), she pushes the gate open herself. The cart still reveals lore if the player investigates.

---

## Puzzle 6: Befriending Nutmeg (Emotional interaction)

**Location:** FOX-DEN
**Goal:** Earn Nutmeg's trust and get the workshop key.
**Difficulty:** Hard (emotional intelligence)

### Clue Chain
1. Nutmeg starts defensive: "A fox-shaped toy with patchy fur curls in a den of rags. Her button eyes watch you warily. The workshop key hangs from a string around her neck."
2. TAKE KEY (without trust) → "Nutmeg snatches the key back. 'No! It's mine! It's the only thing that's ever been mine!'"
3. ASK NUTMEG ABOUT KEY → "She hugs the key close. 'Why should I give it back? Nobody ever gave me anything.'"
4. TELL NUTMEG ABOUT TOLLIVER → "Her ears droop. 'The old man... he fixed me once. Before... before he stopped coming.'"
5. GIVE SCARF TO NUTMEG or GIVE STRING-BALL → "She looks at the gift. 'For... for me?' Her voice cracks. 'Nobody ever gave me anything before.'"
6. After enough kindness (2+ gifts or kind words), Nutmeg offers the key: "She paws the key off her neck and places it before you. 'Take it. But... but promise you'll come back. Please.'"

### Wrong Attempts
- ATTACK NUTMEG → "She flinches. 'I knew it. You're just like the others.' She retreats deeper into her den, key clutched tight." (Locks out befriending path)
- SHOUT AT NUTMEG → "Her ears flatten. She turns away."
- WIND NUTMEG → "She flinches at your touch. 'I don't need winding. I need... something else.'"

### Hints
1. (Marzipan): "A fox with fur all patched and thin / Needs kindness first to let you in."
2. "Nutmeg has been alone a long time. She doesn't need fixing — she needs a friend."
3. "Try giving her something. The scarf in the snow, or the ball of string."

### Softlock Prevention
- If player attacks Nutmeg, they lose the "trust" path but can still get the key through a different method (e.g., Nutmeg eventually falls asleep, key is accessible — but this is a lesser ending).
- Key is never permanently inaccessible.

### Alternate Solution
- If player is kind to all toys throughout (Bertrand wound, Marzipan given button, scrap cart helped), Nutmeg notices and says "I've been watching you. You're... different." She gives the key freely.

---

## Puzzle 7: Tolliver's Study Access (Endgame gate)

**Location:** WORKSHOP-FLOOR (hidden door behind Old Tick)
**Goal:** Reach Tolliver's study to find the final lore and diagram.
**Difficulty:** Moderate

### Clue Chain
1. After Nutmeg gives key: "Old Tick's clock begins to chime — not the hour, but a deep, resonant gong."
2. "Old Tick speaks: 'The hour of reckoning comes. Behind me lies the way, but only the fox knows how to open it.'"
3. Nutmeg must be present (either befriended or coerced). She uses her small fox-shape to slip behind the clock and push the hidden latch.

### Requirements
- Workshop key obtained (any method)
- Old Tick has been wound/listened to at least once (shows respect)
- Nutmeg is present and willing (or player has forced/coerced access)

### Hints
1. "Old Tick guards more than riddles."
2. "Only someone small enough can reach behind the clock."

### Softlock Prevention
- If Nutmeg is hostile, player can still access study by using the tin soldier to press the latch (alternate solution).

---

## Puzzle 8: The Final Rewinding (Climax)

**Location:** WORKSHOP-HEART
**Goal:** Wind the workshop heart with the key before dawn.
**Difficulty:** Moderate (resource management + emotional choice)

### Mechanics
1. Insert key into heart mechanism: PUT KEY IN SLOT or WIND HEART WITH KEY
2. The heart begins to turn, but not fast enough: "The heart groans. It's turning, but too slowly. Dawn is close. You need more power — more love — to rewind it fully."
3. Player must choose which toy companions to place around the heart. Each toy companion adds winding power:
   - Tin soldier (carried from countertop)
   - Music box (carried from countertop, if wound first)
   - Any repaired toy (doll with head, etc.)
   - Nutmeg (if befriended — she volunteers)
   - Bertrand (if fully wound and asked politely)
4. More companions = stronger rewind = better ending.

### Branching Endings
- **3+ companions:** All toys are saved. Wrenfold's magic is restored. Nutmeg stays. "You did it, Pip. You really did it."
- **1-2 companions:** The heart rewinds enough to save the workshop, but some toys outside fall silent. Bittersweet.
- **0 companions (key alone):** The workshop is saved, but barely. Many toys go silent. Nutmeg's last line: "At least... at least you tried."
- **Too late / key not wound:** Dawn. Silence. "The last tick fades. The workshop is still. You are alone."

### Hints
1. "The heart needs more than a key. It needs the love the toys carry."
2. "Your companions — those you helped along the way — can lend their strength."
3. "Place the toys you've carried around the heart."

### Softlock Prevention
- At minimum, the key alone saves the workshop (worst good ending). Player can always win.
- Companions are not lost — the game reminds player what they have.
