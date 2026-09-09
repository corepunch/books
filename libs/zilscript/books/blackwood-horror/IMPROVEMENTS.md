# Horror.zil Improvement Plan

## Problem Statement

The current adventure is structurally sound (22 rooms, 57 objects, working puzzles) but lacks the richness that makes Infocom games memorable. It reads like a haunted house tour — go room to room, read static descriptions, collect keys. The twist (Patient 189) is hinted but never lands. Most objects are inert red herrings. No scoring, no randomization, no dynamic descriptions.

---

## Planned Improvements

### 1. GLOBAL Objects (Shared Scenery)

**Why:** The player can see the sanitarium from outside and from the garden, but it's invisible to the parser. Same for the dead oak tree mentioned nowhere but implied by the setting.

**What:**
- `SANITARIUM-BUILDING` in `LOCAL-GLOBALS` — visible from SANITARIUM-GATE, OVERGROWN-GARDEN. EXAMINE produces different text depending on whether CHAPEL-UNLOCKED (the building "feels" different once you've been deep inside).
- `DEAD-OAK-TREE` in `LOCAL-GLOBALS` — visible from SANITARIUM-GATE, OVERGROWN-GARDEN, SANITARIUM-ENTRANCE. EXAMINE, CLIMB (can't), LISTEN (crows).

Add `(GLOBAL SANITARIUM-BUILDING DEAD-OAK-TREE)` to those rooms.

---

### 2. FDESC Discovery Moments

**Why:** FDESC fires only the first time. This creates memorable "wow" moments for key objects.

**What:**
- `IRON-BOILER` FDESC: "The room's centerpiece is a massive iron boiler, cold and silent as a tomb. Its hulking form crouches in the darkness like some dormant beast."
- `SHOCK-CHAIR` FDESC: "In the center of the room, bolted to the floor, sits the chair. Leather restraints dangle from every joint. You know immediately what this is, and your stomach turns."
- `PATIENT-189` FDESC: "Something is standing at the altar. It doesn't move. It doesn't breathe. But somehow, horribly, you know it knows you're here."

---

### 3. PICK-ONE Randomized Atmosphere

**Why:** The same whisper firing every 8 turns becomes wallpaper. Variety keeps dread alive.

**What:**
```zil
<GLOBAL WHISPER-TABLE
    <LTABLE 0
        "A voice, barely audible, rasps: 'help... me...'"
        "You hear your name whispered — impossible, you never told anyone you were coming."
        "A child's voice whispers something in a language you don't recognize."
        "The walls seem to breathe a single word: 'run.'">>
```
Replace I-WHISPER body with `<TELL <PICK-ONE ,WHISPER-TABLE> CR>`.

---

### 4. The Identity Twist — You Are Patient 189

**Why:** The game hints at Patient 189's identity but never delivers the twist. The straitjacket in the padded cell is the perfect vehicle — it has a name tag.

**What:**
- STRAITJACKET EXAMINE: "A heavy canvas straitjacket. Stiff buckles, dark stains. And on the collar — a name tag. Your name. YOUR name is on this straitjacket."
- STRAITJACKET gets READBIT. TEXT/READ: "The tag reads a name you know. Your name. Dated 1947. Five years before the sanitarium closed."
- WALL-SCRATCHES READ: append below existing messages: "'YOU ARE 189. YOU ALWAYS WERE.' — scratched in handwriting that looks disturbingly like your own."

This doesn't change the game's mechanics — it recontextualizes the player's motivation.

---

### 5. Earned Ending — Serum + Syringe + Relic

**Why:** A bare `HELLO` action as the win trigger is anticlimactic and collides with Zork's generic greeting behavior. The game has STRANGE-SERUM, SYRINGE, and ANCIENT-RELIC as objects but no purpose for two of them.

**What:**
Use the explicit `SAY HELLO` phrase for the win condition, leaving the standard `HELLO` action unchanged:
- If player lacks ANCIENT-RELIC: "Patient 189 tilts its head. Green light flares in its eyes. Something cold reaches into your chest. You are not ready."
- If player has relic but not serum+syringe: "The relic glows warm. Patient 189 shivers, eyes flickering. But something still binds it. The serum — if returned to its source..."
- If player has all three: Multi-line victory text. Inject the serum. The green light dies. Patient 189 looks at you with human eyes and whispers 'I remember who I was.' It crumbles to ash. The candles go out. You're free.

Add `<GLOBAL GAME-WON <>>`, set on victory, `<REMOVE ,PATIENT-189>`.

---

### 6. Hide the Safe Key Better

**Why:** Currently SAFE-KEY sits on top of MASSIVE-DESK. Trivial. The director's office has bookshelves described but not interactive.

**What:**
- Remove SAFE-KEY from MASSIVE-DESK.
- Add HOLLOW-BOOK object in DIRECTORS-OFFICE:
  - FDESC: "Among the medical texts, one book stands out — a red leather tome, its spine blank where all others are labeled."
  - Requires OPEN (it has a latch, not pages). Inside: SAFE-KEY.
  - READ: "The pages are glued together. It's a hollow hiding place, not a real book."
- MASSIVE-DESK-F examine text: remove mention of hidden compartment with key.

---

### 7. Room VALUE Scoring

**Why:** Gives a sense of progress. Rewarding exploration of the darkest rooms.

**What:**
| Room | VALUE | Rationale |
|------|-------|-----------|
| MORGUE | 10 | First corpse discovery |
| ISOLATION-WARD | 5 | Deep basement exploration |
| PADDED-CELL | 5 | The identity twist room |
| ELECTROSHOCK-THEATER | 8 | Horror set-piece |
| CHAPEL | 15 | Final confrontation |

---

### 8. PSEUDO Objects (Scenery Words)

**Why:** The fireplace description mentions "a bird's nest." If the player types `examine nest`, nothing happens. PSEUDO fixes this cheaply.

**What:**
- RECEPTION-ROOM gets `(PSEUDO "NEST" NEST-PSEUDO "ASHES" ASHES-PSEUDO)`
- NEST-PSEUDO: "An old bird's nest tucked into the fireplace grate. Long abandoned — like everything else here."
- ASHES-PSEUDO: "Cold grey ashes. Nothing of value."

---

### 9. Dynamic Room Description for CHAPEL (M-LOOK)

**Why:** After winning, the chapel description should change. Static LDESC can't do this.

**What:**
- Remove LDESC from CHAPEL, add `(ACTION CHAPEL-FCN)`.
- CHAPEL-FCN handles M-LOOK:
  - Before win: "The chapel is small and suffocating. Cold green light from unnatural candles makes everything look like a corpse. At the far end, before the altar, something stands perfectly still."
  - After win (GAME-WON): "The chapel is just a room now. The candles are dark. The altar is bare. Whatever was here is gone — and so is whatever held you."

---

### 10. Additional Clock Routine

**Why:** More atmospheric variety, especially for the mid-game exploration phase.

**What:**
```zil
<ROUTINE I-CREAKING ()
    <COND (<EQUAL? ,HERE ,OPERATING-THEATER ,PATIENT-WARD ,ELECTROSHOCK-THEATER>
           <TELL "The building settles with a deep structural groan, as if exhaling." CR>)>
    <RTRUE>>
```
Queue in GO: `<QUEUE I-CREAKING 9>`.

---

## Challenges in Writing ZIL Adventures

### Challenge 1: Tracking World State Across 1000+ Lines

As the file grows, it's hard to remember what objects exist, where they are, what flags they have, and how puzzles interlock.

**Solution:** ZIL file + grep is sufficient. Key queries:
- `grep "IN " horror.zil` — object locations
- `grep "GLOBAL " horror.zil` — all state flags
- `grep "VERB?" horror.zil` — all handled verbs
- `grep "IF " horror.zil` — conditional exits and their gate flags
- `grep "SETG " horror.zil` — where state changes happen

A summary tool would add overhead without adding signal. The file IS the source of truth — grep gives instant answers.

### Challenge 2: Puzzle Dependency Chains

It's easy to create dead ends where the player needs object X to reach area Y, but object X is IN area Y.

**Solution:** Draw the dependency graph mentally:
```
brass-key (RECEPTION floor) → desk-drawer → patient-file (clue only)
scalpel (OPERATING cabinet) → chains (PATIENT-WARD) → MORGUE access
valve (BASEMENT-CORRIDOR) → steam-door (FLOODING) → HYDROTHERAPY
safe-key (DIRECTORS-OFFICE book) → wall-safe → chapel-key → CHAPEL
serum (MORGUE drawers) + syringe (HYDROTHERAPY) + relic (CHAPEL box) → WIN
```
Rule: every key must be reachable BEFORE its gate. Verify with a topological sort of the dependency edges.

### Challenge 3: Verb Coverage

Players try everything. If a description says "blood-stained", they'll try SMELL. If it says "heavy", they'll try PUSH. Missing responses break immersion.

**Solution:** After writing each object's ACTION routine, re-read its LDESC and TEXT. Every adjective/noun implies verbs:
- "heavy" → PUSH, PULL, TAKE (with rejection message)
- "liquid" → DRINK, POUR
- "written" → READ
- "locked" → OPEN, UNLOCK
- "stained" → SMELL, RUB

### Challenge 4: Keeping the File Parseable

ZIL is parenthesis-heavy. One missing `)` or `>` breaks parsing silently.

**Solution:** Run the test after every batch of changes:
```bash
lua5.4 run-zil-test.lua books.blackwood-horror.walkthrough
```
The parser will report the first syntax error with a line number.

---

---

### 11. Parser Depth — Pronouns, Disambiguation, GWIM, OOPS

**Why:** The substrate handles basic TAKE/OPEN/LOOK, but players who type `TAKE ALL`, `DROP IT`, or mistype a word will hit unhandled responses. The Lurking Horror has 1700 lines of custom parser code handling pronouns (IT/HIM), GWIM defaults, OOPS correction, ALL/EXCEPT clauses, and disambiguation prompts.

**What:**
- Add pronoun tracking in action routines using `THIS-IS-IT`: after any `TELL` mentioning an object, bind `IT` to it: `<THIS-IS-IT ,OBJECT-NAME>`
- Support `ALL` and `ALL EXCEPT` for TAKE/DROP in the current room
- Add GWIM handlers for common missing-object scenarios (EXAMINE with no object → default to room's most interesting feature)
- Handle `OOPS` corrections with a global buffer of the last typed command
- Add disambiguation: when two objects in scope share a synonym, prompt the player to clarify

**Implementation** (example pronoun binding):
```zil
<ROUTINE LENS-F ()
    <COND (<VERB? EXAMINE>
           <TELL "The lens is magnificent but dark." CR>
           <THIS-IS-IT ,FRESNEL-LENS>   ; now "take it" works
           <RTRUE>)>>
```

---

### 12. NPC Autonomy — Movement, Dialogue Trees, Behavior Loops

**Why:** Patient 189 is static — never moves, never changes behavior autonomously. The Lurking Horror's hacker wanders, helps, and gets corrupted; its urchin uses A*-like pathfinding across the entire map; its flier approaches in 5 escalating stages. These NPCs feel alive because they act independently.

**What:**
- Give Patient 189 a movement routine that patrols the chapel area
- Add a multi-stage help/awareness sequence (stage 1: unaware, stage 2: curious, stage 3: responsive, stage 4: hostile or grateful based on player actions)
- Implement topic-based dialogue with ASK/TELL (not just EXAMINE and win): backstory, fear, the sanitarium, Mordecai
- Add a corruption arc: if the player brings the relic too early or attacks Patient 189, it changes behavior

**Implementation** (autonomous NPC movement):
```zil
<ROUTINE I-PATIENT-MOVE ()
    <COND (<EQUAL? ,HERE ,CHAPEL ,CHAPEL-ANTECHAMBER ,GARDEN>
           ; 30% chance to move to adjacent room
           <COND (<==? <RANDOM 3> 1>
                  <COND (<EQUAL? <LOC ,PATIENT-189> ,CHAPEL>
                         <MOVE ,PATIENT-189 ,CHAPEL-ANTECHAMBER>)
                        (T
                         <MOVE ,PATIENT-189 ,CHAPEL>)>)>)>
    <RTRUE>>
```
Queue at interval 5 in GO.

---

### 13. Sound System — Audio Events for Key Moments

**Why:** The Lurking Horror has 14 distinct sound IDs with volume control — footsteps, slime, wind, the flier's approach. Sound is a critical horror tool. Blackwood has none.

**What:**
- Add sound constants for key atmospheric moments
- Trigger sounds on room entry, clock events, puzzle solutions, and NPC encounters
- Room descriptions should imply sounds the player "hears" through text

**Implementation additions:**
```lua
-- Sound IDs (added to engine if not present):
SOUND_WIND = 1
SOUND_FOOTSTEPS = 2
SOUND_WHISPER = 3
SOUND_HEARTBEAT = 4
```
Queue audio triggers alongside atmospheric text:
```zil
<ROUTINE I-FOOTSTEPS ()
    <COND (<EQUAL? ,HERE ,OPERATING-THEATER ,PATIENT-WARD ,ELECTROSHOCK-THEATER>
           <TELL "Slow footsteps echo from somewhere above." CR>
           ; <PLAY-SOUND ,SOUND-FOOTSTEPS>  ; engine extension needed
           )>
    <RTRUE>>
```

---

### 14. Unique Death Messages — Every Death a Discovery

**Why:** The Lurking Horror has unique death text for every fatality — freezing, electrocution, slime, the flier, the urchin, the mass, the FROB. Each is a piece of characterful writing. Blackwood has no death system at all — the game simply ends when the player wins.

**What:**
- Add death states for environmental hazards: falling into the flooded pit, freezing in the morgue, being attacked by Patient 189
- Each death gets unique, evocative text
- Add a death clock: staying in the morgue too long, touching certain objects without protection, failing the serum injection

**Examples:**
- Freezing in morgue: "The cold seeps through your clothes, your skin, your bones. The tiles feel almost warm now. That's how you know it's too late."
- Patient-189 attack: "Its hands close around your throat. Up close, you see your own eyes reflected in its. They're the last thing you see."
- Flooded basement: "The water is black and cold. You gasp, swallow, and the boiler room ceiling fades above you."

---

### 15. Progressive Hints — Tiered Attention/Direction/Action/Command

**Why:** The current `V-HINTS` outputs a single state-dependent message. The Lurking Horror doesn't have in-game hints, but Infocom's InvisiClues used a 4-tier system that let players choose how much help to receive. Modern games should do better.

**What:**
- Expand V-HINTS to a tiered system using a counter: first `HINTS` call → attention nudge, second → direction, third → specific action, fourth → exact command
- Track which puzzles are unsolved and serve hints in priority order
- Allow `HINTS <TOPIC>` for topic-specific guidance

**Implementation:**
```zil
<GLOBAL HINT-LEVEL <>>
<GLOBAL HINT-INDEX <>>

<ROUTINE V-HINTS ()
    <COND (<NOT ,STUDY-UNLOCKED>
           <GET-HINT "study" 0
               "The study door seems important."
               "Mr. Hudson may know how to open it."
               "Ask Hudson about the study key."
               "ASK HUDSON ABOUT KEY")>
          (<NOT ,CIPHER-SOLVED>
           <GET-HINT "cipher" 1
               "The library has a pattern to decode."
               "Compare the torn page with the colored markers."
               "Push the marked books in rainbow order."
               "PUSH RED BOOK then YELLOW then GREEN then BLUE")>
          ...)>
```

---

### 16. Prose Tonal Range — Humor, Beauty, and Warmth in Horror

**Why:** The Lurking Horror shifts between academic comedy ("Now you know why few technical schools make it to the Rose Bowl"), cosmic awe (the Yuggoth sequence), and body horror. Blackwood is uniformly grim — every room "reeks of decay," the walls are "covered in black mold," nothing is beautiful or funny. Without contrast, the horror desensitizes.

**What:**
- Add one moment of dark humor: a sardonic narrator comment, a silly object (a rubber chicken in the cafeteria, a "Employee of the Month" photo with increasingly deranged captions)
- Add one moment of beauty: a moonlit view from the observation deck, a single wildflower growing through a crack in the boiler room floor
- Add one moment of warmth (made hollow by context): a preserved staff photograph showing happy people, a child's drawing pinned to a wall
- Remove at least half of the "reek of decay" / "oppressive dread" / "feels wrong" phrases and replace with concrete sensory detail

**Examples:**

> (Beauty) "Through the grime-caked window, moonlight paints the garden in silver. A single white rose has forced its way through a crack in the stone wall."
>
> (Dark humor) "A yellowed certificate reads 'Gordon Ashworth — Employee of the Month, March 1952.' Someone has drawn a mustache on every face with what appears to be dried blood."
>
> (Warmth) "A child's crayon drawing is taped to the wall — a crude house with a smiling figure labeled 'DR ASHWORTH' and another labeled 'ME.' It would be sweet if you didn't know what happened here."

---

### 17. Clock-Driven Gameplay — Mechanical Systems, Not Just Atmosphere

**Why:** The Lurking Horror's clock system drives real mechanical consequences: the flashlight dims across 5 stages (FRESH, DIM, VERY-DIM, ALMOST-GONE, OUT), the Chinese food cools and becomes less appealing, the player freezes if outside too long, NPCs move on schedules. Blackwood's clock routines (I-WHISPER, I-CREAKING) are purely cosmetic — they fire flavor text that never interacts with game state.

**What:**
- Add a mechanical cold system: staying in the morgue or basement too long progressively impairs the player, with early warnings before death
- Add a light-source drain: if the player finds a flashlight or lantern, it runs out of battery after N turns
- Add an NPC scheduling system: Patient 189 moves between CHAPEL, GARDEN, and CHAPEL-ANTECHAMBER on a timer, changing which rooms are accessible
- Add object temperature tracking: the boiler can be lit to warm surrounding rooms, affecting the cold system

**Implementation** (cold system):
```zil
<GLOBAL COLD-TIMER 0>
<GLOBAL PLAYER-SHIMMERING <>>

<ROUTINE I-COLD ()
    <COND (<EQUAL? ,HERE ,MORGUE ,BASEMENT-CORRIDOR ,BOILER-ROOM ,FLOODED-CHAMBER>
           <SETG COLD-TIMER <+ ,COLD-TIMER 1>>
           <COND (<EQUAL? ,COLD-TIMER 3>
                  <TELL "You shiver. It's getting colder." CR>)
                 (<EQUAL? ,COLD-TIMER 6>
                  <TELL "Your teeth chatter uncontrollably. Your fingers are going numb." CR>)
                 (<EQUAL? ,COLD-TIMER 9>
                  <TELL "The cold is unbearable. Your vision blurs." CR>)
                 (<EQUAL? ,COLD-TIMER 12>
                  <TELL "You collapse. The cold takes you." CR>
                  ; death sequence
                  )>)>
    <RTRUE>>
```

---

### 18. Object Interaction Depth — Tool Chains and State Combinations

**Why:** In the Lurking Horror, puzzles require chaining multiple objects in specific ways: use liquid nitrogen to freeze slime → shatter frozen slime → reveal ancient door. Or: find Chinese food → heat in microwave (2 min, HIGH) → give to hacker → get master key. Blackwood's puzzles max out at "use scalpel on chains" and "use key on door."

**What:**
- Add at least one multi-step tool chain: e.g., find empty bottle → fill at water fountain → pour on floor → freeze room with open window → slip across to unreachable area
- Add object state combinations: e.g., turn on boiler → heats radiator in hydrotherapy room → thaws frozen drawer → reveals second serum vial
- Add object-with-object puzzles that require correct ordering: e.g., mix cleaning fluid (find cabinet) + combine with powder (find storage) → create acid → dissolve chapel lock

**Example** (boiler chain):
```zil
<ROUTINE BOILER-F ()
    <COND (<VERB? LAMP-ON TURN>
           <COND (<FSET? ,BOILER ,ONBIT>
                  <TELL "The boiler is already roaring." CR>)
                 (<NOT <IN? ,COAL-SCOOP ,WINNER>>
                  <TELL "You need fuel to light the boiler." CR>)
                 (T
                  <TELL "You shovel coal into the boiler and light it. Soon a deep rumble fills the room." CR>
                  <FSET ,BOILER ,ONBIT>
                  <SETG BOILER-MINUTES 0>)>
           <RTRUE>)>>

; Clock daemon: boiler heats adjacent rooms
<ROUTINE I-BOILER-HEAT ()
    <COND (<AND <FSET? ,BOILER ,ONBIT>
                 <EQUAL? ,HERE ,BASEMENT-CORRIDOR ,HYDROTHERAPY>>
           <SETG BOILER-MINUTES <+ ,BOILER-MINUTES 1>>
           <COND (<AND <EQUAL? ,BOILER-MINUTES 3>
                       <NOT ,RADIATOR-WARM>>
                  <TELL "A pipe clanks. Warmth radiates from the wall." CR>
                  <SETG RADIATOR-WARM T>)>)>
    <RTRUE>>
```

---

### 19. Verb Coverage — Expanding Beyond Standard Zork1 Verbs

**Why:** The Lurking Horror defines 130+ verb syntaxes, including specialized actions like DIG, COMPARE, THROUGH, and TELL-ME-ABOUT. Blackwood uses only standard Zork1 verbs (~20). When the room description says "the safe is covered in frost" and the player types `SCRAPE FROST`, there's no response.

**What:**
- Add custom SYNTAX entries for verbs specific to the sanitarium setting: SCRAPE, INJECT, PUT-ON, PULL (as V-MOVE)
- Add responses for verbs implied by object descriptions: SMELL for "reeking", POUR for "liquid", PUSH for "heavy", RUB for "stained"
- Add at least 5-8 non-standard verb handlers that produce in-world responses rather than generic failures

**Implementation:**
```zil
<SYNTAX SCRAPE OBJECT = V-SCRAPE>
<SYNTAX INJECT OBJECT WITH OBJECT (FIND TOOLBIT) = V-INJECT>

<ROUTINE V-SCRAPE ()
    <TELL "You scrape at the surface. Nothing yields." CR>
    <RTRUE>>

<ROUTINE V-INJECT ()
    <COND (<AND <EQUAL? ,PRSI ,SYRINGE>
                <EQUAL? ,PRSO ,PATIENT-189>
                <IN? ,STRANGE-SERUM ,WINNER>>
           ... injection logic ...
           <RTRUE>)>>
```

---

## Implementation Order

1. Add GLOBAL GAME-WON and WHISPER-TABLE globals
2. Add LOCAL-GLOBALS objects (SANITARIUM-BUILDING, DEAD-OAK-TREE)
3. Add GLOBAL property to rooms that reference them
4. Add FDESC to IRON-BOILER, SHOCK-CHAIR, PATIENT-189
5. Replace I-WHISPER with PICK-ONE version
6. Add I-CREAKING routine and queue it in GO
7. Modify STRAITJACKET (READBIT, new EXAMINE/READ text)
8. Modify WALL-SCRATCHES (extended READ response)
9. Rewrite PATIENT-189-F for earned ending
10. Create HOLLOW-BOOK, move SAFE-KEY into it, update MASSIVE-DESK-F
11. Add PSEUDO to RECEPTION-ROOM
12. Add VALUE to rooms (MORGUE, ISOLATION-WARD, PADDED-CELL, ELECTROSHOCK-THEATER, CHAPEL)
13. Replace CHAPEL LDESC with ACTION CHAPEL-FCN + M-LOOK handler
14. Add pronoun tracking (THIS-IS-IT) to key object routines (Section 11)
15. Add I-PATIENT-MOVE clock routine for NPC autonomy (Section 12)
16. Add unique death states and I-COLD mechanical clock (Sections 14, 17)
17. Add multi-step tool chain (boiler → heat → thaw drawer) (Section 18)
18. Add custom SYNTAX entries for SCRAPE, INJECT, and other specialized verbs (Section 19)
19. Revise prose across 5-8 rooms for tonal range (Section 16)
20. Expand V-HINTS to tiered progressive system (Section 15)
21. Update walkthrough test to match new win condition
22. Run test, fix any parse/logic errors
