# Blackwood Horror — Regression Test Report

**Test Date:** July 16, 2026  
**Tested By:** Game Tester Agent  
**Build:** Commit 62de65c ("fix: address game-tester findings across Blackwood Horror and Limehouse Killings")  
**Source:** `books/blackwood-horror/`

---

## Summary

| Category | Count |
|----------|-------|
| Previously Fixed Bugs Verified | 12/12 PASS |
| New/Remaining Bugs Found | 2 |
| Walkthrough Completion | Full completion achieved (all puzzles solved, ending reached) |
| Regression Test Suite | 17/17 PASS |

---

## Previously Fixed Bugs — Verification Results

All 12 previously reported bugs have been verified as fixed:

| # | Bug | Status | Evidence |
|---|-----|--------|----------|
| Bug 1 | PSEUDO scenery words non-functional | **FIXED** | `examine instruments` → "Rusty forceps, scalpels, and clamps..."; `examine nest` → "An old bird's nest..."; `search ashes` → "Just soot and old char." |
| Bug 2 | TURN VALVE requires preposition | **FIXED** | `turn valve` → "You grip the metal valve and turn with all your strength..." |
| Bug 4 | Post-win atmospheric events fire | **FIXED** | After game won, `wait` produces only "Time passes..." with no whispers, footsteps, or cold drafts |
| Bug 5 | CHAPEL-DOOR LDESC doesn't update | **FIXED** | NDESCBIT added to CHAPEL-DOOR; door no longer shows outdated LDESC in room listing. `examine door` correctly describes open/unlocked state. |
| Bug 6 | GREEN-CANDLES LDESC after win | **FIXED** | NDESCBIT added to GREEN-CANDLES; candles not listed in room inventory after win. Post-win examine: "The candles are cold and dark now, their green glow extinguished forever." |
| Bug 7 | BELL ringing is location-invariant | **FIXED** | Bell now says "The tinny sound echoes through the {room name}. No one comes." (e.g., "the Cafeteria", room-specific via `THE ,HERE`) |
| Bug 10 | CLIMB TREE generic response | **FIXED** | `climb tree` → "The lower branches are too high to reach, and you have no desire to scramble up a dead tree..." |
| Bug 11 | LISTEN verb unhandled | **FIXED** | `listen` at gate → "The crows make no sound. Far off, branches scrape against stone." Post-win: "For the first time, the building is quiet..." |
| Bug 12 | SMELL verb unhandled | **FIXED** | `smell` at gate → "The air smells of damp stone, dust, and something antiseptic..." |
| Bug 13 | SIT without object awkward | **FIXED** | `sit` → "You lower yourself for a moment, then decide this is no place to become comfortable." Chapel-specific: "You sit briefly on a pew; the carved wood is cold enough to drive you back to your feet." |
| Bug 14 | HELLO triggers game quit | **FIXED** | `hello` → "Your greeting receives no answer, but at least the building does not mistake it for a farewell. If you mean to address someone, try SAY HELLO." |
| Issue 7 | Scenery items invisible to parser | **FIXED** | `examine gate` → "The rusted iron gates stand open..."; `examine staircase` → "The grand staircase climbs toward a collapsed landing..."; `examine dust` (boiler room) → "Fine coal dust coats the brick..." |

---

## Regression Test Suite — 17/17 PASS

All tests in `books/blackwood-horror/test/test-report-regressions.zil` pass:

| # | Test | Result |
|---|------|--------|
| 1 | `examine nest` → "bird's nest" | ✅ |
| 2 | `search ashes` → "soot and old char" | ✅ |
| 3 | `examine instruments` → "Rusty forceps" | ✅ |
| 4 | `examine scalpels` → "Rusty forceps" | ✅ |
| 5 | `examine tiers` → "wooden benches" | ✅ |
| 6 | Canvas bundle remains on dissection table | ✅ |
| 7 | `examine bundle` → "Patient 237" | ✅ |
| 8 | `turn valve` → "turn with all your strength" | ✅ |
| 9 | `listen` → "sanitarium answers" | ✅ |
| 10 | `smell` → "damp stone" | ✅ |
| 11 | `sit` → "no place to become comfortable" | ✅ |
| 12 | `climb tree` → "lower branches are too high" | ✅ |
| 13 | `examine gate` → "rusted iron gates" | ✅ |
| 14 | `hello` → "does not mistake it for a farewell" | ✅ |
| 15 | Post-win `listen` → "quiet" | ✅ |
| 16 | Post-win `look` → NOT "green flame" | ✅ |
| 17 | `ask patient about identity` → "remember" | ✅ |

---

## New/Remaining Bugs Found

### Bug A: Shock Chair Death State Is Unreachable (Regression from Fix)

- **Description:** The fix added a death state to the SHOCK-MACHINE-F handler: when the player is IN the shock chair and turns the switch on, they die via JIGS-UP. However, both the SIT and BOARD verb handlers in SHOCK-CHAIR-F block the player from ever being in the chair:

  ```
  (<VERB? BOARD>
   <TELL "You have no desire to sit in that terrible chair." CR>
   <RTRUE>)
  (<VERB? SIT>
   <TELL "You have no desire to sit in that terrible chair." CR>
   <RTRUE>)
  ```

  Additionally, SHOCK-CHAIR does not have the `VEHBIT` flag, which is required for vehicles/rideable objects in ZIL. The `<IN? ,WINNER ,SHOCK-CHAIR>` check in SHOCK-MACHINE-F at line 418 can never evaluate to true through normal gameplay.

- **Commands:** `sit in chair`, `board chair`, `sit on chair`
- **Actual output:** "You have no desire to sit in that terrible chair."
- **Expected:** Player should be able to sit in the chair (perhaps with a warning), enabling the death state when the switch is turned. Alternatively, the death check code in SHOCK-MACHINE-F is dead code and should be removed or reconnected to a reachable path.
- **Root cause:** The fix added the death check (commit 62de65c, SHOCK-MACHINE-F lines 417-419) without modifying the SIT/BOARD handlers in SHOCK-CHAIR-F (lines 400-405) to actually allow entering the chair.
- **Severity:** Medium (dead code that advertises a death state that cannot be reached)
- **Fix:** Either (a) update SHOCK-CHAIR-F SIT handler to move the player into the chair, (b) add `VEHBIT` to SHOCK-CHAIR and use appropriate BOARD mechanics, or (c) remove the unreachable death check.

### Bug B: Possible Self-Injection Death Unreachable via "MYSELF" Pronoun

- **Description:** The V-INJECT routine checks `<EQUAL? ,PRSO ,WINNER>` to detect self-injection. However, when using `inject myself with syringe` or `inject me with syringe`, the PRSO resolves to an object with DESC "cretin" that is NOT the same object as WINNER. The error message says "You have no reason to inject the cretin" instead of triggering the JIGS-UP death state. This suggests the `me`/`myself` pronoun resolves to a different object instance than `,WINNER`.

  The Zork1 parser defines the PLAYER object with SYNONYM MYSELF/ME/SELF and DESC "cretin" (in `infocom/zork1/globals.zil`). It's possible that the parser creates a copy or the WINNER global points to a different object than the parser-resolved PRSO.

- **Command:** `inject myself with syringe` (while holding syringe and serum)
- **Actual output:** "You have no reason to inject the cretin."
- **Expected:** Self-injection death: "The serum enters your vein like ice..."
- **Reproduction:** Requires full playthrough to obtain syringe (from hydrotherapy cabinet) and serum (from morgue drawer). Could not fully test in isolation due to prerequisite items.
- **Severity:** Medium (new feature death state may be unreachable)
- **Note:** Further investigation needed. The issue may be related to pronoun resolution in the parser, or the save state being post-win. A clean pre-win save with necessary items should be tested.

---

## Walkthrough Completion

The full walkthrough was followed step-by-step and completed successfully:

- All keys found and used (brass key → drawer, safe key → safe, chapel key → chapel door)
- All puzzles solved (chain cutting, steam valve, boiler lighting, safe opening, box opening)
- All three required items obtained (relic, serum, syringe) and used to win via `say hello`
- Ending reached with mid-tier identity twist (PATIENT-LORE > 2, < 4): "It looks at you with recognition—not as a stranger, but as someone who understands what it endured."

**Note:** The highest-tier identity twist ending (PATIENT-LORE >= 4, entity merges with player via "the missing years return") could not be verified through normal play without modifying game state. All available lore clues were discovered but may not have produced the required lore count.

---

## Overall Assessment

| Aspect | Status |
|--------|--------|
| **Game is completable?** | ✅ YES |
| **All fixed bugs verified?** | ✅ YES (12/12) |
| **Regression tests pass?** | ✅ YES (17/17) |
| **No critical regressions?** | ✅ YES |
| **New bugs found?** | ⚠️ 2 (Medium severity: shock chair death unreachable, self-injection pronoun resolution) |

The game is fully playable and winnable. The fixes for all previously reported bugs are working correctly. Two new issues were identified with newly-added death state features (shock chair and self-injection), where the death states may not be reachable through normal gameplay commands.

---

*Report generated by game tester agent*
