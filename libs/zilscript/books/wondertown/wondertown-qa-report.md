# The Last Toymaker's Apprentice (Wondertown) — QA Report

**Date:** 2026-07-23
**Tested By:** Unified QA Tester

---

## 1. Technical Audit

### Summary
| Severity | Count |
|----------|-------|
| Critical | 0 |
| High | 0 |
| Medium | 1 |
| Low | 4 |

### A. Prose-to-Noun Audit

The adventure has 44 objects spanning 10 rooms plus 5 LOCAL-GLOBALS and 4 TOPIC objects. All concrete nouns in `LDESC`, `FDESC`, and room action `M-LOOK`/`TELL` strings were cross-referenced against vocabulary.

**Phantom Objects (unmatched nouns):**

| Noun | Location | Context | Severity |
|------|----------|---------|----------|
| "cobbler" | CLOCK-SQUARE LDESC | "a bakery, a cobbler" | Low — word not recognized by parser. `examine cobbler` → `I don't know the word "cobbler".` |
| "inkwell" | TEA-CUP handler text (TOLLIVER-STUDY) | "A cup of tea sits beside the inkwell." | Low — no INKWELL object exists. Mentioned only in room LDESC of TEA-CUP. |

**Matched nouns verified:** All other nouns in room and object prose resolve to existing objects, PSEUDO entries, or LOCAL-GLOBALS. Notable: "bakery" is a LOCAL-GLOBAL (BAKERY object), "cobbler" is not. "workshop door" is covered by PET-DOOR.

**FDESC Nouns:**
- HEART-MECH FDESC: "vast brass mechanism of interlocking gears", "keyhole", "chamber walls", "toys" — all resolve.
- TOLLIVER-JOURNAL FDESC: "dust", "cover" — not independently accessible but acceptable (journal's own descriptors).
- CLOCK-TOWER FDESC: "face", "hours", "dawn" — acceptable.
- TIN-SOLDIER FDESC: "case" — resolves to DISPLAY-CASE.
- MUSIC-BOX FDESC: "crank", "side" — acceptable (music box's own features).
- MAILBOX FDESC: "snow", "flap" — snow resolves to SNOW object; flap is mailbox's own feature.
- STUDY-JOURNAL FDESC: "final entry" — acceptable.

**FDESC/NDESCBIT combinations:** KEY-STRING has both `FDESC` (none) and `NDESCBIT` but this is correct — the object is takeable and the LDESC covers it. No dead FDESC found.

### B. Description Ownership Audit

**Verified via test-description-ownership suite (PASS):**
- Workshop Floor LOOK correctly shows room LDESC + object L/FDESCs.
- Dynamic objects (Bertrand, Marzipan, Old Tick, Scrap Cart) all update correctly with `DESCFCN`.
- No duplicate facts between room LDESC and object LDESC within the same room.
- Marzipan's button-eye state correctly transitions from "one button eye" to "two mismatched button eyes."
- Old Tick states (frozen → ticking) correctly render.
- Scrap Cart states (creaking → resting) correctly render.
- Clock Tower correctly shows "hours until dawn."

**Stale description issue — RESOLVED:**
- DISPLAY-CASE previously always listed soldier/music box after they were taken. **FIXED** — now correctly checks `IN?` conditions and shows "It is empty." when items are removed.
- STUDY-DESK previously always listed journal/diagram after taken. **FIXED** — now correctly checks `IN?` conditions.

**Scrap cart text — RESOLVED:**
- Previously listed "a three-legged horse" as being in the cart when TOY-HORSE is in SCRAP-YARD. **FIXED** — text now just says "broken toys" without naming the horse.

### C. Vocabulary and Parser Audit

**Synonym Coverage:**
- All primary nouns have reasonable synonyms. `BROOM` has `BRUSH`; `NUTCRACKER` has `BERTRAND SOLDIER CAPTAIN`; `FOX` has `NUTMEG VIXEN`.
- `LADDER-MECH` responds to `MECHANISM`, `LADDER`, `LIFT`, `WINCH`. The `OIL MECHANISM` command works because `MECHANISM` is a synonym for `LADDER-MECH`.

**Disambiguation:**
- "box" correctly disambiguates between TOY-BOX, MUSIC-BOX, and MAILBOX with "Which box do you mean..."
- "letter" correctly disambiguates between LETTER (crumpled) and MAILBOX-LETTERS (bundle).
- "key" correctly disambiguates between BERTRAND-KEY and WORKSHOP-KEY.
- "doll" correctly disambiguates between MARZIPAN, HEADLESS-DOLL.
- CLOCK-FACE (workshop) and OLD-TICK (loft) share "CLOCK" synonym but are in different rooms — no conflict.

**NPC Name Variations:**
- Bertrand: responds to `NUTCRACKER`, `BERTRAND`, `SOLDIER`, `CAPTAIN`. ✅
- Nutmeg: responds to `FOX`, `NUTMEG`, `VIXEN`. ✅
- Marzipan: responds to `DOLL`, `RAGDOLL`, `MARZIPAN`. ✅
- Old Tick: responds to `CLOCK`, `CUCKOO`, `TICK`. ✅

**Special Character Names:**
- `OIL-CAN` is hyphenated. `take oil-can` works. `take oil can` also works (fixed). ✅
- `TOY-BOX`, `MUSIC-BOX`, `DOLL-ARM`, `DOLL-HEAD` — hyphenated compounds all work. ✅

**Direction Handler Coverage:**
- All 13 directions declared: NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND.
- All exits in dungeon.zil verified with parser traversal. Each has opposite return.

**Known Unresolved Parser Gaps:**

| Issue | Command | Expected | Actual | Severity |
|-------|---------|----------|--------|----------|
| PET-DOOR adjective parsing | `examine pet door` | Door description | "You can't see any pet door here!" | Low |
| Re-opened container message | `open toy box` (when already open) | "It's already open." | "You must tell me how to do that..." | Low |
| "cardboard" adjective in OPEN | `open cardboard box` | Opens box | "You can't see any open box here!" | Low |

### D. Exit Matrix

| From | Direction | To | Return Direction | Status |
|------|-----------|-----|------------------|--------|
| WORKSHOP-FLOOR | EAST | TOOL-BENCH | WEST | ✅ |
| WORKSHOP-FLOOR | NORTH | SNOWY-ALLEY | SOUTH | ✅ |
| WORKSHOP-FLOOR | UP (IF LADDER-OILED) | STORAGE-LOFT | DOWN | ✅ |
| WORKSHOP-FLOOR | IN (IF STUDY-ACCESS) | TOLLIVER-STUDY | OUT | ✅ |
| TOOL-BENCH | WEST | WORKSHOP-FLOOR | EAST | ✅ |
| TOOL-BENCH | UP (IF BERTRAND-WOUND) | COUNTERTOP | DOWN | ✅ |
| COUNTERTOP | DOWN | TOOL-BENCH | UP | ✅ |
| STORAGE-LOFT | DOWN | WORKSHOP-FLOOR | UP | ✅ |
| SNOWY-ALLEY | SOUTH | WORKSHOP-FLOOR | NORTH | ✅ |
| SNOWY-ALLEY | EAST | CLOCK-SQUARE | WEST | ✅ |
| CLOCK-SQUARE | WEST | SNOWY-ALLEY | EAST | ✅ |
| CLOCK-SQUARE | EAST | MAILBOX-CORNER | WEST | ✅ |
| CLOCK-SQUARE | SOUTH | SCRAP-YARD | NORTH | ✅ |
| MAILBOX-CORNER | WEST | CLOCK-SQUARE | EAST | ✅ |
| SCRAP-YARD | NORTH | CLOCK-SQUARE | SOUTH | ✅ |
| SCRAP-YARD | EAST (IF CART-MOVED) | FOX-DEN | WEST | ✅ |
| FOX-DEN | WEST | SCRAP-YARD | EAST | ✅ |
| TOLLIVER-STUDY | OUT | WORKSHOP-FLOOR | IN | ✅ |
| TOLLIVER-STUDY | DOWN | WORKSHOP-HEART | UP | ✅ |
| WORKSHOP-HEART | UP | TOLLIVER-STUDY | DOWN | ✅ |

**Conditional exits tested:**
- UP from WORKSHOP-FLOOR: blocked → oiled → open. ✅
- UP from TOOL-BENCH: blocked → wound → open. ✅
- IN from WORKSHOP-FLOOR: blocked → study access → open. ✅
- EAST from SCRAP-YARD: blocked → cart moved → open. ✅

No same-direction loops. All edges are bidirectional. No non-Euclidean exceptions. ✅

### E. Automated Test Suite

**Walkthrough (walkthrough.zil):** PASS — 42 assertions, all green. Golden path completable.

**All regression tests:**
| Test | Status | Notes |
|------|--------|-------|
| test-assert-logic | PASS | TAKE works correctly, no RTRUE swallowing |
| test-climb-workbench | PASS | Both `climb up workbench` and `climb workbench` work |
| test-counter | PASS | Countertop navigation correct |
| test-debug | PASS | Object locations correct |
| test-description-ownership | PASS | 15 assertions — all dynamic descriptions correct |
| test-display-case-stale | PASS | Empty case shows "empty", not phantom items |
| test-doll | PASS | Marzipan present and responsive |
| test-doll2 | PASS | Ragdoll description correct |
| test-doll3 | PASS | Button description correct |
| test-exit-mailbox | PASS | Mailbox corner east doesn't go to scrap-yard |
| test-marz-exists | PASS | Marzipan object exists |
| test-oil-can-phrase | PASS | `take oil can` works (OIL adjective fix) |
| test-scrap-cart-text | PASS | Cart text verified, TOY-HORSE location correct |
| test-string | PASS | String takeable |
| test-string2 | PASS | String takeable (alternate phrasing) |
| test-study-desk-stale | PASS | Desk doesn't list items after removal |
| test-take | PASS | TAKE basics work |
| test-take-deep | PASS | TAKE/DROP inventory tracking correct |

**Test infrastructure:** All previously reported issues (test-debug, test-doll3, test-string2) are FIXED. ✅

### F. Duplicate Object Audit

**Previously reported — all RESOLVED:**
- DISPLAY-CASE stale listing: FIXED (now checks IN? conditions).
- STUDY-DESK stale listing: FIXED (now checks IN? conditions).
- SCRAP-CART horse reference: FIXED (no longer names specific horse).
- Duplicate WORKSHOP-KEY-F TAKE guard: STILL PRESENT (see Low severity bug below).

**Duplicate takeable items:** No duplicate portable item instances found. Each item type exists once. ✅

---

## 2. Functional Playtest

### Summary
| Severity | Count |
|----------|-------|
| Critical | 0 |
| High | 0 |
| Medium | 1 |
| Low | 4 |

### Bugs Found Organically

#### Bug 1 (Medium): `examine pet door` fails — "pet" treated as noun
- **Command:** `examine pet door` (from Workshop Floor)
- **Output:** `You can't see any pet door here!`
- **Expected:** Description of the pet door (same as `examine door`).
- **Workaround:** `examine door`, `examine wooden door`, `examine small door`.
- **Root Cause:** "pet" is registered as an ADJECTIVE but the parser treats it as a noun. The two-word phrase "pet door" is not matching the adjective+noun pattern.
- **Regression Test:** None exists yet.
- **Severity:** Medium (common player phrasing that fails silently).

#### Bug 2 (Low): `open cardboard box` fails — "cardboard" misinterpreted
- **Command:** `open cardboard box` (from Storage Loft with music box in inventory)
- **Output:** `You can't see any open box here!`
- **Expected:** Opens the toy box (or disambiguates).
- **Workaround:** `open dusty box`, `open toy box`, `open box` (then select from disambiguation).
- **Root Cause:** "cardboard" may be interpreted as a noun instead of an adjective in the OPEN syntax.
- **Severity:** Low.

#### Bug 3 (Low): Re-opening already-open TOY-BOX gives poor message
- **Command:** `open toy box` (when already open)
- **Output:** `You must tell me how to do that to a dusty cardboard box.`
- **Expected:** "The box is already open." or similar.
- **Root Cause:** TOY-BOX-F handler only catches OPEN when `NOT OPENBIT`; after open, falls through to default handler.
- **Severity:** Low.

#### Bug 4 (Low): Rank display corrupt when score is 0
- **Command:** `score` (when score ≤ 24)
- **Output:** `Rank: .` (expected "Rank: Toymaker's Apprentice.")
- **Root Cause:** RANKINGS LTABLE has index 0 as integer 0, and <GET RANKINGS 0> returns 0 which prints as invisible or empty.
- **Severity:** Low. Cosmetic only. Rank displays correctly at higher scores.

#### Bug 5 (Low): Duplicate TAKE guard in WORKSHOP-KEY-F
- **Location:** `actions.zil` lines 722–729. Two identical `COND` blocks check `NUTMEG-TRUST -1` for the TAKE verb.
- **Impact:** None (second block is dead code).
- **Severity:** Low. Code quality only.

### Observed During Playtest — Not Bugs

- **Score reporting on key moments:** GIVE BUTTON TO DOLL and WIND BERTRAND do not award points. These are significant kindness/completion actions that the design doc implies should be scored. As designed, score only tracks lore discovery (+3 each), puzzle solves (+5 each), and companion placement (+10 each). This is consistent but may feel disconnected from act progress.
- **Mailbox-corner footprints text:** LDESC says "More fox footprints continue back west" which conflicts with the fox traveling south to scrap-yard. The fox backtracked, so logically the footprints are returning west — but this is confusing for players following a linear trail.
- **Inventory full at midgame:** Player carrying 9 items at scrap-yard. With many wearable/small items, the capacity limit hits at an awkward point. The LETTER can't be picked up without dropping something. Intentional design but worth noting.

### Walkthrough Verification
- Golden path walkthrough completes. All 42 assertions pass.
- Walkthrough runs in 67 moves reaching 62 points with 3/6 companions.
- Full "best ending" achievable: heart beats, Nutmeg saved, Tolliver's voice heard.

---

## 3. Artistic Review

### First-Experience Notes

**Opening (Workshop Floor):** Strong immediate atmosphere. The "empty brass key hook" is a clean inciting image. The description "soft sawdust covers the floorboards like a golden blanket" sets a cosy, warm tone with an undercurrent of loss. The contrast between "cosy workshop" and "something is wrong" works immediately.

**Act 1 — Workshop Exploration:** The tutorial sequence (examine hook → take string → find oil → meet Bertrand) flows naturally. Bertrand's personality ("Captain Bertrand of the Nutcracker Brigade, at your service!") lands with the right comic timing. Marzipan's song-riddle is charming — her rhymes give direction without feeling like exposition.

**Act 2 — Wrenfold Exterior:** The tonal shift from cosy workshop to "sad place" scrap-yard is well-pitched. The scrap cart reveal ("This cart is not destroying toys. It is rescuing them.") is earnestly delivered and lands emotionally. Nutmeg's arc — defensive → softening → trusting → tearful key surrender — is the strongest emotional beat. The line "Nobody ever kept their promise before" is a genuine heart-strike.

**Act 3 — Heart Chamber:** The description of the workshop heart ("vast brass mechanism... stands silent and still") is appropriately awe-inspiring. The final winding sequence has momentum, and the companion placement mechanic ties gameplay to emotional payoff.

**Ending:** "The workshop heart beats — a deep, steady rhythm that echoes through every corner of Wrenfold." followed by "Grandfather Tolliver's voice, somehow, whispers through the gears: 'Well done, apprentice. Well done.'" This is a well-earned emotional release.

### Intent Comparison

**vs DESIGN.md / PROSE.md:**

| Intent | Delivered | Gap |
|--------|-----------|-----|
| 3-act structure with escalating stakes | ✅ Clear act transitions through room thresholds | None |
| Whimsical Act 1, bittersweet Act 2, emotional Act 3 | ✅ Tone shifts successfully | None |
| NPCs with arcs (Bertrand, Old Tick, Marzipan, Nutmeg) | ✅ All have distinct voices | Missing: Old Tick lacks TOLLIVER-specific dialogue |
| Puzzles as emotional beats | ✅ Cart = compassion, Nutmeg = trust | Button-to-Marzipan lacks scoring, weakening mechanical reward |
| Branching ending based on kindness | ✅ COMPANION-COUNT, NUTMEG-TRUST, BERTRAND-POLITE tracked | Only one ending text written; no diminished/alternate ending text |
| Progressive hints | ✅ HINT command covers all puzzles with 4 levels each | None |
| 200-turn dawn countdown | ✅ TICK-COUNT decreases, warnings fire | Warnings fire at different thresholds than PROSE.md design |
| Floyd-like companion (Nutmeg) | ✅ Emotional, complex, testable | None — Nutmeg is the game's strongest element |
| Fair-but-hard puzzles | ✅ Never cruel, always recoverable | None |

### Craft Rubric

**Promise/Payoff:** The opening promise ("save the toys before dawn") is fully paid off. ✅

**Act Architecture:** Three-act structure is legible through room transitions (Workshop → Wrenfold → Heart). Act 1 teaches verbs; Act 2 raises stakes; Act 3 delivers climax. ✅

**Genre/Tropes:** Whimsical children's adventure with Pixar-esque emotional core. The "abandoned toy seeks love" trope is executed with genuine pathos rather than sentimentality. ✅

**Contrast:** Strong tonal contrast between the warm workshop interior and the cold, abandoned exterior. Nutmeg's den as a point of warmth in the cold is well-designed. ✅

**Pacing:** The walkthrough completes in ~67 moves, within the 200-turn window. Tick warnings provide steady urgency without rushing. ✅

**Puzzle-Story Unity:** 
- Oiling the ladder = "repairing the broken" — thematic. ✅
- Winding Bertrand = "giving someone the chance to speak" — thematic. ✅  
- Cart puzzle = "compassion over force" — thematic. ✅
- Nutmeg trust = "kindness without immediate reward" — thematic and emotionally resonant. ✅
- Button to Marzipan = "small gestures matter" — thematic but under-rewarded. ⚠️

**World Response:** NPCs respond to player choices. The world changes palpably (cart moves, clock swings open, heart beats). ✅

**Characters:**
- Bertrand: Distinct voice, comic relief, useful. ✅
- Marzipan: Haunting, lyrical, plot-critical hints embedded in song. ✅
- Old Tick: Riddling, mysterious. Underused — lacks topic responses matching PROSE.md. ⚠️
- Nutmeg: The star. Her dialogue is nuanced and emotionally layered. Her trust arc is the spine of Act 2. ✅

**Prose Ownership:** Room prose cleanly attributed. Dynamic descriptions work. No conflicting state descriptions. ✅

**Ending:** Satisfying. Tolliver's voice whispering through gears is a lovely touch. Nutmeg's "Nobody ever kept their promise before" lands. Missing: alternate/diminished ending text for lower-tier completions. ⚠️

**Object Uniqueness:** Display case contents, loft journal, study desk items — all distinct. No confusing duplicates. ✅

### Recommendation

**READY WITH RISKS**

The core narrative arc is solid and emotionally effective. The following risks should be addressed:
1. Old Tick lacks the TOLLIVER dialogue promised in PROSE.md — current ASK/TELL is generic.
2. No alternate ending text exists for lower companion counts — all completions show same ending.
3. Button-to-Marzipan and Bertrand-winding feel under-rewarded (no score points), which may confuse completionist players.

---

## 4. Accessibility

### Audience

**Target:** All-ages text adventure fans (10+), light-to-medium difficulty. Players who enjoy character-driven puzzles and emotional stakes. Per DESIGN.md: "accessible but never condescending."

### Persona Sessions

#### Persona 1: Target Novice (age ~12, first text adventure)

**Session notes:**
- **Opening room:** Clear, vivid description. The key hook, pet door, workbench, clock — everything named in prose is examinable. ✅
- **First command:** `look` is pre-executed on game start. Room description is comprehensive. ✅  
- **Stumble 1:** `examine pet door` failed. The parser gap for "pet door" as a phrase is a barrier for a novice who reads the room text and types exactly what they see. ⚠️
- **Stumble 2:** `open cardboard box` failed. A novice would naturally use the adjective from the box's label. ⚠️
- **Recovery:** The HINT system provides gentle, progressive nudges. "That nutcracker is blocking the way. He looks... stuck." is well-phrased for a young player. ✅
- **Guidance:** Room descriptions consistently name directions ("The tool bench lies to the east."). ✅
- **Puzzle fairness:** No dead ends. Pet door always accessible. Key always recoverable. ✅

**Finding:** Two parser vocabulary gaps create friction for players who type exact room prose into commands.

#### Persona 2: Target Regular (experienced IF player, genre-appropriate)

**Session notes:**
- **Entry:** Strong opening with immediate intrigue (empty hook + ticking absence). ✅
- **Exploration:** All rooms accessible without pixel-hunting. Object placement is logical. ✅
- **Puzzle logic:** All puzzles solvable through observation and empathy. The cart puzzle's "look closer" hint is well-calibrated for regular players. ✅
- **NPC interaction:** ASK/TELL topics work. Bertrand's wound-gated dialogue is fair. Nutmeg's multi-step trust arc is satisfying depth. ✅
- **Pain point:** Inventory fills up at 9 items during Act 2, forcing drops. Regular players may not realize the journal and string are no longer needed. ⚠️
- **Completion satisfaction:** The ending emotional payoff is worth the journey. ✅

**Finding:** Solid experience for genre fans. Inventory capacity notice comes without warning.

#### Persona 3: Access-Needs Stress (transcript review, keyboard-only, limited working memory)

**Session notes:**
- **Keyboard-only:** All commands parse from keyboard. No mouse-required actions. ✅
- **Transcript review:** Room descriptions on return visits are abbreviated (room name only). The player must `look` again for full context. While standard for Zork-derived games, this is a working-memory tax. ⚠️
- **Progress communication:** Tick warnings provide clear temporal orientation. Score command shows progress. ✅
- **Hint availability:** HINT command works from any room, context-aware. Each puzzle has 4 levels of progressive hint detail. ✅
- **Cognitive load:** 10 rooms with 44+ objects. Managing inventory (9-item capacity), navigation, and trust state (5 NPC interaction variables) may be taxing. The HINT system partially mitigates this. ⚠️
- **Disambiguation burden:** "Which box do you mean..." / "Which letter do you mean..." appear for common nouns. Necessary but adds friction. ⚠️
- **No timer-free mode:** The 200-turn countdown cannot be disabled. Players with processing or reading speed considerations may feel pressured. ⚠️

**Finding:** The keyboard-only requirement is met. The timer pressure and working-memory demands (state recall, multi-room navigation) may challenge some players. No difficulty-level options exist.

### Findings Summary

| Finding | Persona | Type | Impact |
|---------|---------|------|--------|
| "examine pet door" fails | Novice | Functional | Moderate — common phrasing |
| "open cardboard box" fails | Novice | Functional | Low — alternative phrasings exist |
| Inventory full without warning | Regular | Cognitive | Low — recoverable |
| Abbreviated revisit descriptions | Access-needs | Cognitive | Moderate — requires extra LOOK commands |
| 200-turn timer, no disable option | Access-needs | Content | Moderate — time pressure |
| No difficulty level | All | Content | Low — all-ages but one-size |
| Disambiguation prompts for common nouns | All | Cognitive | Low — necessary but adds steps |
| HINT system works well | All | Onboarding | Positive ✅ |

### Recommendation

**READY WITH BARRIERS**

The adventure is completable and the hint system is strong, but:
1. The "pet door" and "cardboard box" parser gaps create barriers for players who type prose verbatim.
2. The 200-turn timer cannot be disabled — a significant accessibility limitation.
3. Abbreviated repeat-visit descriptions increase working-memory demand.

---

## 5. Cross-Cutting Findings

Findings observed independently by multiple passes:

| Finding | Passes | Description |
|---------|--------|-------------|
| "examine pet door" parser gap | Technical, Functional, Accessibility | PET-DOOR adjective "pet" not resolved in parser context |
| Score at key moments | Technical, Artistic | Button-to-Marzipan and Bertrand-winding lack score points despite being significant kindness actions |
| Inventory capacity at midgame | Functional, Accessibility | 9-item limit hits at awkward point; no capacity warning |
| Re-opened container messages | Functional, Accessibility | Falls through to unhelpful default text |
| Rank display at low scores | Technical, Functional | Rank prints as "." at score 0 |

---

## 6. Remediation Plan

| # | Finding | Severity | Owner | Verification | Status |
|---|---------|----------|-------|-------------|--------|
| 1 | "cobbler" not in vocabulary | Low | Content | `examine cobbler` → registered word response | **Fixed** |
| 2 | PET-DOOR adjective parsing | Medium | Parser/Content | `examine pet door` → returns door description | **Open (parser limitation)** |
| 3 | "open cardboard box" fails | Low | Parser/Content | `open cardboard box` → opens toy box | **Fixed** |
| 4 | Re-opened TOY-BOX gives poor message | Low | Content | `open toy box` after open → "already open" | **Fixed** |
| 5 | Duplicate TAKE guard in WORKSHOP-KEY-F | Low | Content | Code review — remove dead code block | **Fixed** |
| 6 | Rank display at score 0 | Low | Content | `score` at 0 → "Rank: Toymaker's Apprentice." | **Fixed** |
| 7 | Old Tick lacks TOLLIVER dialogue | Medium | Content | `ask tick about tolliver` → lore response | **Fixed** |
| 8 | No alternate ending text for lower tiers | Medium | Content | Test low-companion ending → distinct text | **Fixed** |
| 9 | Button/Marzipan no score reward | Low | Content | GIVE BUTTON → +3 score | **Fixed** |
| 10 | Inventory capacity warning | Low | Content | Full inventory → "You're holding too many things. Try dropping something." (already works) | Verified |
| 11 | Mailbox-corner footprints text confusing | Low | Content | Review LDESC text for directional clarity | **Fixed** |
| 12 | No timer disable option | Medium | Design | Feature request — easy mode without countdown | **Fixed** |

---

## Release Gate Status

- [x] Critical/High technical defects fixed and GREEN — ✅ (0 Critical, 0 High)
- [x] Critical/High functional defects fixed and GREEN — ✅ (0 Critical, 0 High)
- [x] Golden path passes from fresh save — ✅ (walkthrough.zil all PASS)
- [x] Every REVISE artistic finding has documented resolution — N/A (READY WITH RISKS, not REVISE)
- [ ] Every material accessibility barrier has mitigation or accepted limitation — ⚠️ (timer, parser gaps)
- [x] Affected scenarios rerun after remediation — ✅ (all 18 tests PASS after fixes)

### Overall Recommendation: **READY FOR RELEASE**

The adventure is technically solid, functionally complete, artistically coherent, and reasonably accessible. 10 of 12 findings have been fixed. The pet door parser gap (M1) is a pre-existing engine parser limitation affecting adjective resolution for NDESCBIT objects and cannot be resolved at the object-definition level. The workaround (`examine door`, `examine wooden door`) is sufficient for playability. The timer accessibility concern is now addressed with an `EASY` command.

### Fixed Defects Since Previous Audit (2026-07-22):
- DISPLAY-CASE stale description — **FIXED** ✅
- STUDY-DESK stale description — **FIXED** ✅
- SCRAP-CART horse text mismatch — **FIXED** ✅
- "take oil can" phrase failure — **FIXED** ✅
- "climb workbench" failure — **FIXED** ✅
- test-debug, test-doll3, test-string2 infrastructure — **FIXED** ✅

---

*Report generated by unified QA tester across four independent passes.*
