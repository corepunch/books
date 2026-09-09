# Wondertown (The Last Toymaker's Apprentice) - Bug Report

**Test Date:** 2026-07-18
**Tested By:** Game Tester Agent

## Summary

| Category | Count |
|----------|-------|
| Critical Bugs | 0 |
| High Severity | 0 |
| Medium Severity | 1 |
| Low Severity | 3 |
| Test Infrastructure | 3 |

### Previous Bug Report Status

The previous report (2026-07-17) identified 2 Critical, 1 High, 2 Medium, and 3 Low bugs. After re-testing:

- **Bug 1 (TAKE broken)** — **FIXED**. TAKE, DROP, and all default verb behaviors work correctly.
- **Bug 2 (ASSERT short-circuit)** — **FALSE ALARM**. The `ASSERT` function in `run-zil-test.lua` already iterates all varargs and fails if any is falsy.
- **Bug 3 (MAILBOX-CORNER east exit description)** — **FIXED**. Description now says "west" instead of "east".
- **Bug 4 (ASK/TELL topic objects not in scope)** — **FALSE ALARM**. Topic objects (`TOPIC-TOLLIVER`, `TOPIC-KEY`, etc.) are correctly listed in each room's `GLOBAL` property. `ask nutcracker about tolliver` works.
- **Bug 5 (Container interactions for mailbox)** — **FIXED**. `look in mailbox`, `open mailbox`, `close mailbox` all produce correct output.
- **Bug 6 (CLIMB workbench)** — **STILL PRESENT** (see Low #1 below).
- **Bug 7 ("bundle" not recognized)** — **FALSE ALARM**. "bundle" IS registered as a synonym for MAILBOX-LETTERS in `dungeon.zil`.
- **Bug 8 (SPOOL-STAIRS wrong room)** — **FALSE ALARM**. SPOOL-STAIRS is correctly defined `(IN TOOL-BENCH)`.

---

## Medium Severity Bugs

### Bug 1: "oil can" Two-Word Form Fails — OIL Synonym/Adjective Conflict

- **Description:** The OIL-CAN object has `(SYNONYM CAN OIL OILCAN OIL-CAN)` and `(ADJECTIVE TINY COPPER OIL)`. When the player types `take oil can`, the parser treats "oil" as the noun (since it's listed as a synonym) and fails to match the two-word phrase. However, `take copper oil can` or `take tiny oil can` work because "copper"/"tiny" are unambiguous adjectives that help the parser identify the noun as "can".
- **Command:** `take oil can`
- **Output:** `You can't see any oil can here!`
- **Expected:** `Taken.` — The object is described as "a tiny copper oil can" and the player would naturally try this form.
- **Reproduction:** Start game, type `take oil can` from Workshop Floor.
- **Workaround:** Use `take copper oil can`, `take tiny oil can`, `take can`, `take oilcan`, or `take oil-can`.
- **Root Cause:** "OIL" appears in both SYNONYM and ADJECTIVE lists. The parser tries "oil" as a noun first (since it's a synonym), can't find a standalone "oil" object, and the phrase resolution fails.
- **Fix:** Remove "OIL" from the SYNONYM list. Keep it only in ADJECTIVE. This way `take oil can` would parse as adjective+noun ("oil" modifies "can") and match correctly.
- **Regression Test:** `books/wondertown/test/test-oil-can-phrase.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/wondertown/test/test-oil-can-phrase`
- **Regression Status:** RED — reproduces the bug
- **Severity:** Medium

---

## Low Severity Bugs

### Bug 2: `climb workbench` Fails — Missing CLIMBBIT

- **Description:** `climb workbench` returns "The enormous workbench doesn't lead upward." but `climb up workbench` works correctly. The WORKBENCH object has `(FLAGS SURFACEBIT CONTBIT OPENBIT SEARCHBIT)` but lacks `CLIMBBIT`, so the parser's `CLIMB OBJECT (FIND CLIMBBIT)` syntax doesn't match. The `WORKBENCH-F` handler does handle `CLIMB` and `CLIMB-UP` verbs, but the parser intercepts before reaching it.
- **Command:** `climb workbench`
- **Output:** `The enormous workbench doesn't lead upward.`
- **Expected:** `You scramble up the workbench leg...` (same as `climb up workbench`)
- **Reproduction:** In Workshop Floor, type `climb workbench`.
- **Fix:** Add `CLIMBBIT` to the WORKBENCH flags, or change the parser-level CLIMB syntax to not require CLIMBBIT.
- **Regression Test:** `books/wondertown/test/test-climb-workbench.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/wondertown/test/test-climb-workbench`
- **Regression Status:** RED — reproduces the bug
- **Severity:** Low

### Bug 3: `examine pet door` Fails — "pet" Treated as Noun

- **Description:** The PET-DOOR object has `(ADJECTIVE PET SMALL WOODEN)` but `examine pet door` fails with "You can't see any pet door here!" while `examine wooden door` and `examine small door` work. The parser treats "pet" as a noun (since it's a common English word) rather than as an adjective modifying "door".
- **Command:** `examine pet door`
- **Output:** `You can't see any pet door here!`
- **Expected:** Should describe the pet door (same as `examine door`).
- **Reproduction:** In Workshop Floor, type `examine pet door`.
- **Workaround:** Use `examine door`, `examine wooden door`, or `examine small door`.
- **Severity:** Low

### Bug 4: "bakery" Not Recognized as a Word

- **Description:** The Clock Square room description mentions "a bakery" but `examine bakery` returns "I don't know the word 'bakery'." The word isn't registered anywhere in the game's vocabulary.
- **Command:** `examine bakery`
- **Output:** `I don't know the word "bakery".`
- **Expected:** Either describe the bakery or give a generic "You can't see any bakery here" response. Room descriptions should not mention nouns that the parser doesn't recognize.
- **Reproduction:** Go to Clock Square, type `examine bakery`.
- **Severity:** Low (cosmetic — doesn't block progress)

---

## Test Infrastructure Issues

### Issue 5: test-debug FAILS — Wrong OIL-CAN Location Assertion

- **Description:** The test asserts `<==? <LOC ,OIL-CAN> ,WORKBENCH>` but OIL-CAN is defined `(IN WORKSHOP-FLOOR)` in `dungeon.zil`, not in the WORKBENCH object. The test is incorrect.
- **Test File:** `books/wondertown/test/test-debug.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/wondertown/test/test-debug`
- **Output:** `[FAIL] Oil-can exists`
- **Status:** FIXED — Changed assertion to `<==? <LOC ,OIL-CAN> ,WORKSHOP-FLOOR>` and updated the TAKE command to use `take copper oil can`.
- **Severity:** Test bug (fixed)

### Issue 6: test-doll3 CRASHES — ASSERT-TEXT Receives Nil

- **Description:** The test crashes with `attempt to index a nil value (local 'actual')` when `ASSERT-TEXT "button" <CO-RESUME ,CO "examine doll" T>` is called. The `T` parameter to CO-RESUME means "only return success flag", suppressing the output text that ASSERT-TEXT needs.
- **Test File:** `books/wondertown/test/test-doll3.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/wondertown/test/test-doll3`
- **Output:** Runtime crash in ASSERT_TEXT
- **Status:** FIXED — Removed the `T` parameter so CO-RESUME returns both ok and actual text.
- **Severity:** Test bug (fixed)

### Issue 7: test-string2 CRASHES — Undefined ASSERT-EQUAL

- **Description:** The test uses `ASSERT-EQUAL` which is not defined in `run-zil-test.lua`. Only `ASSERT`, `ASSERT_TEXT`, and `ASSERT_NOT_TEXT` are available.
- **Test File:** `books/wondertown/test/test-string2.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/wondertown/test/test-string2`
- **Output:** `attempt to call a nil value (global 'ASSERT_EQUAL')`
- **Status:** FIXED — Replaced `ASSERT-EQUAL` with `ASSERT-TEXT`.
- **Severity:** Test bug (fixed)

---

## Verified Working

The following features were tested and work correctly:

- **TAKE/DROP** — All items can be picked up and dropped.
- **EXAMINE** — All objects respond to examination.
- **OPEN/CLOSE containers** — Display case, mailbox, toy box all work.
- **LOOK-IN containers** — Mailbox shows letters inside.
- **ASK/TELL NPCs about topics** — Nutmeg, Bertrand, Marzipan all respond to topic questions.
- **GIVE items to NPCs** — Button→Marzipan, Scarf→Nutmeg, Yarn→Nutmeg all work.
- **WIND mechanics** — Bertrand, Clock Tower, Old Tick, Heart all wind correctly.
- **OIL mechanics** — Ladder mechanism oils with correct syntax.
- **POSITION companions** — Soldier, Music Box, Doll Arm can be placed at heart.
- **HINT system** — Progressive hints work from relevant rooms.
- **Game completion** — Full walkthrough succeeds with correct ending text.
- **Dynamic descriptions** — Bertrand, Marzipan, Old Tick, Scrap Cart, Nutmeg all update correctly.
- **Disambiguation** — "letter" correctly asks which one; "key" asks which key.
- **Mailbox NPC** — Responds to ASK/TELL about fox and footprints.

---

## Recommendations

1. **Remove "OIL" from OIL-CAN SYNONYM list** — Keep it only in ADJECTIVE. This fixes the `take oil can` usability issue.
2. **Add CLIMBBIT to WORKBENCH** — So `climb workbench` works without "up".
3. **Add "bakery" to vocabulary** — Either register it as a noun or handle it in the parser.
4. **Fix test-doll3** — Already fixed: removed T flag from CO-RESUME in ASSERT-TEXT call.
5. **Fix test-string2** — Already fixed: replaced ASSERT-EQUAL with ASSERT-TEXT.
6. **Fix test-debug** — Already fixed: corrected OIL-CAN location assertion.

---

*Report generated by game tester agent*
