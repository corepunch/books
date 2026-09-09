# Wondertown — Duplicate / Conflicting Object Audit

**Test Date:** 2026-07-22
**Tested By:** Game Tester Agent (duplicate-object audit)

## Summary

| Category | Count |
|----------|-------|
| Critical Bugs | 0 |
| High Severity | 2 |
| Medium Severity | 1 |
| Low Severity | 4 |
| Storytelling Inconsistencies | 3 |

This audit specifically looked for the patterns recently fixed in blackwood-horror:
- PSEUDO words overlapping with real takeable objects
- Container descriptions that always list items regardless of whether they've been taken
- Objects described in room LDESC or action text that conflict with actual game state

---

## High Severity Bugs

### Bug 1: DISPLAY-CASE always lists soldier and music box even after they are taken

- **Description:** The `DISPLAY-CASE-F` handler's EXAMINE branch always hardcodes "a brave tin soldier and a silver music box" regardless of whether those items are still inside the case. After taking both items, `examine display case` still says "Inside, you can see a brave tin soldier and a silver music box." Meanwhile, `look in display case` correctly says "The dusty glass display case is empty." — proving the container logic knows the items are gone, but the EXAMINE handler doesn't check.
- **Command:** `examine display case` (after taking soldier and music box)
- **Output:** `The glass display case is open. Inside, you can see a brave tin soldier and a silver music box.`
- **Expected:** Should describe the case as empty or only list items actually present.
- **File:** `books/wondertown/actions.zil`, lines 460–465
- **Problematic text:** `"Inside, you can see a brave tin soldier and a silver music box."` (line 463) and `"Through the glass, you can see a tin soldier and a silver music box."` (line 465)
- **Root Cause:** The handler checks `OPENBIT` but never checks `<IN? ,TIN-SOLDIER ,DISPLAY-CASE>` or `<IN? ,MUSIC-BOX ,DISPLAY-CASE>`. Compare with `TOY-BOX-F` (line 517–530) which correctly uses `<IN? ,DOLL-ARM ,TOY-BOX>` before listing contents.
- **Reproduction:** Start game → go east → take key → wind nutcracker → up → open case → take soldier → take music box → examine display case.
- **Regression Test:** `books/wondertown/test/test-display-case-stale.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/wondertown/test/test-display-case-stale`
- **Regression Status:** `RED — reproduces the bug`
- **Severity:** High

### Bug 2: STUDY-DESK always mentions journal and diagram even after they are taken

- **Description:** The `STUDY-DESK-F` handler's EXAMINE branch always says "An open journal lies among them, alongside a hand-drawn winding diagram" regardless of whether those items are still on the desk. After taking both items, `examine desk` still describes them as present.
- **Command:** `examine desk` (after taking diagram and journal)
- **Output:** `A cluttered wooden desk. Papers are spread across its surface -- diagrams, notes, a half-finished sketch of the workshop heart. An open journal lies among them, alongside a hand-drawn winding diagram.`
- **Expected:** Should describe the desk without mentioning items that have been removed.
- **File:** `books/wondertown/actions.zil`, lines 757–759
- **Problematic text:** `"An open journal lies among them, alongside a hand-drawn winding diagram."` (line 759)
- **Root Cause:** The handler unconditionally lists items without checking `<IN? ,DIAGRAM ,STUDY-DESK>` or `<IN? ,STUDY-JOURNAL ,STUDY-DESK>`.
- **Reproduction:** Reach Tolliver's Study → take diagram → take journal → examine desk.
- **Regression Test:** `books/wondertown/test/test-study-desk-stale.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/wondertown/test/test-study-desk-stale`
- **Regression Status:** `RED — reproduces the bug`
- **Severity:** High

---

## Medium Severity Bugs

### Bug 3: SCRAP-CART EXAMINE text mentions "a three-legged horse" as being collected, but TOY-HORSE is in the room, not the cart

- **Description:** The SCRAP-CART's non-moved EXAMINE text says it is "collecting broken toys into its bed -- a headless doll, a three-legged horse." However, `TOY-HORSE` is defined `(IN SCRAP-YARD)`, not `(IN SCRAP-CART)`. Only `HEADLESS-DOLL` is actually in the cart. The text implies the horse is in the cart when it is physically in the same room but outside the cart.
- **Command:** `examine cart` (before cart is moved)
- **Output:** `A scrap-metal cart on rusted wheels. It creaks along a track, collecting broken toys into its bed -- a headless doll, a three-legged horse.`
- **Expected:** The cart description should only list items actually in the cart, or use less specific language (e.g., "broken toys" without naming the horse specifically).
- **File:** `books/wondertown/actions.zil`, line 632
- **Problematic text:** `"a headless doll, a three-legged horse"`
- **Root Cause:** The text names specific toys that aren't all in the cart. `HEADLESS-DOLL` is correctly `(IN SCRAP-CART)`, but `TOY-HORSE` is `(IN SCRAP-YARD)`.
- **Reproduction:** Go to Scrap-Yard → examine cart.
- **Regression Test:** `books/wondertown/test/test-scrap-cart-text.zil` (documents the inconsistency)
- **Test Command:** `lua5.4 run-zil-test.lua books/wondertown/test/test-scrap-cart-text`
- **Regression Status:** `PASS — documents current behavior (text is present, location mismatch confirmed)`
- **Severity:** Medium

---

## Low Severity Issues

### Issue 4: STUDY-DESK LDESC also mentions items statically

- **Description:** The `STUDY-DESK` LDESC property (dungeon.zil line 638) says "A wooden desk is cluttered with papers, diagrams, and an open journal." This is shown on first room visit. After taking items, re-`look` uses the room's LDESC which still mentions them. However, this is less severe because LDESC is typically only shown on first visit, and the dynamic STUDY-DESK-F handler takes over for subsequent examines.
- **File:** `books/wondertown/dungeon.zil`, line 638
- **Severity:** Low

### Issue 5: Room descriptions mention objects that were never implemented

Several room LDESC texts reference objects that exist in the `work/OBJECTS.md` design doc but were never coded as ZIL objects:

| Room | Mentioned Object | Status |
|------|-----------------|--------|
| SNOWY-ALLEY | "workshop door" | No object; design doc listed `WORKSHOP-DOOR (PSEUDO)` |
| SNOWY-ALLEY | (implied) snow scenery | No object; design doc listed `SNOW-SCENERY` |
| CLOCK-SQUARE | "a cobbler" | No object at all |
| SCRAP-YARD | "toys that someone loved" (piles) | No object; design doc listed `BROKEN-TOYS` |
| STORAGE-LOFT | (implied) trapdoor down | No object; design doc listed `LOFT-HATCH` |
| TOLLIVER-STUDY | "inkwell" (in TEA-CUP handler text) | No object |

These are all cosmetic — the player can't interact with them, but the parser doesn't reject them as unknown words because they're embedded in descriptive text, not registered as vocabulary.

- **Severity:** Low (cosmetic — doesn't block progress)

### Issue 6: "cobbler" not in vocabulary

- **Description:** Clock Square LDESC mentions "a bakery, a cobbler" but "cobbler" is not registered as any object's synonym or adjective. The parser would say "I don't know the word 'cobbler'" if the player tries to examine it. The BAKERY local-global handles "bakery" but nothing handles "cobbler".
- **File:** `books/wondertown/dungeon.zil`, line 99
- **Severity:** Low (cosmetic)

### Issue 7: Duplicate take-guard in WORKSHOP-KEY-F

- **Description:** The `WORKSHOP-KEY-F` handler has two identical conditions for the TAKE verb when `NUTMEG-TRUST == -1` (lines 707–713). Both check `<EQUAL? ,NUTMEG-TRUST -1>` and produce the same text. The second block is dead code.
- **File:** `books/wondertown/actions.zil`, lines 706–713
- **Severity:** Low (code quality — no gameplay impact)

---

## Storytelling Inconsistencies

### 1. TEA-CUP handler mentions "inkwell" that doesn't exist

The `TEA-CUP-F` handler (actions.zil line 752) says "A cup of tea, long gone cold. A skin of dust floats on the surface." But the STUDY-DESK-F handler (line 759) says "Papers are spread across its surface -- diagrams, notes, a half-finished sketch of the workshop heart." Neither mentions an inkwell, but the STUDY-DESK LDESC (dungeon.zil line 638) says "A wooden desk is cluttered with papers, diagrams, and an open journal." The tea cup's EXAMINE handler doesn't reference the desk context at all — this is fine, but the STUDY-DESK LDESC doesn't mention an inkwell either. The inkwell reference appears to have been removed from the game but may have been intended.

### 2. SCRAP-CART says "rescued toys" after moving, but doesn't list them

After `CART-MOVED` is true, the cart's EXAMINE says "its bed still full of rescued toys" but doesn't specify which toys. The HEADLESS-DOLL and DOLL-HEAD are in the cart at this point. This is vaguer than the pre-move text but accurate.

### 3. MAILBOX-LETTERS can never be taken (NDESCBIT) but are described as "unsent letters"

The MAILBOX-LETTERS have `(FLAGS NDESCBIT)` so they can never be taken. The mailbox LOOK-INSIDE handler (line 594) always says "a bundle of unsent letters sits waiting." This is consistent because the letters can't be removed — but it's worth noting that the design doc (OBJECTS.md line 89) listed them as `TAKEBIT READBIT`, suggesting they were originally intended to be takeable.

---

## No Issues Found (Patterns Checked)

- **PSEUDO objects overlapping with real objects:** No PSEUDO objects exist in the ZIL code. The design doc mentioned PSEUDO entries for "tools" and "door" but they were never implemented. ✅
- **TOY-BOX container description:** Correctly checks `<IN? ,DOLL-ARM ,TOY-BOX>` before listing contents. ✅
- **MAILBOX container description:** Letters have NDESCBIT and can't be taken, so description is always accurate. ✅
- **VARNISH-POT container description:** Describes the varnish itself (not separate takeable contents). ✅
- **RAG-BED container description:** Describes the bed structure, not contents. ✅
- **Dynamic object descriptions:** Bertrand, Marzipan, Old Tick, Scrap Cart, Nutmeg all have DESCFCN routines that update based on game state. ✅
- **Same-named objects in different rooms:** CLOCK-FACE (Workshop Floor) and OLD-TICK (Storage Loft) share synonyms but are in different rooms — no conflict. ✅

---

## Recommendations

1. **Fix DISPLAY-CASE-F** (actions.zil lines 460–465): Add `<IN? ,TIN-SOLDIER ,DISPLAY-CASE>` and `<IN? ,MUSIC-BOX ,DISPLAY-CASE>` checks before listing items. Follow the pattern used in TOY-BOX-F.
2. **Fix STUDY-DESK-F** (actions.zil lines 757–759): Add `<IN? ,DIAGRAM ,STUDY-DESK>` and `<IN? ,STUDY-JOURNAL ,STUDY-DESK>` checks before listing items.
3. **Fix SCRAP-CART-F** (actions.zil line 632): Either remove "a three-legged horse" from the text, or change it to "broken toys" without naming specific items that aren't in the cart.
4. **Remove dead code** in WORKSHOP-KEY-F (actions.zil lines 711–713): Duplicate TAKE guard for NUTMEG-TRUST -1.
5. **Add missing vocabulary**: Register "cobbler" and "workshop door" as vocabulary even if they're just scenery responses.

---

*Report generated by game tester agent*
