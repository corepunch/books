# Limehouse Killings — Duplicate & Conflicting Object Audit

**Test Date:** July 22, 2026  
**Tested By:** Game Tester Agent  
**Focus:** Duplicate/conflicting objects, static container descriptions, text-vs-state mismatches

---

## Summary

| Category | Count |
|----------|-------|
| Medium Severity | 3 |
| Low Severity | 1 |

The game does **not** use any PSEUDO objects, so the "PSEUDO overlapping with real objects" pattern from blackwood-horror does not apply. However, **three medium-severity static-text bugs** remain where container/surface descriptions always advertise items even after they've been taken — the same class of bug that was fixed in blackwood-horror's SCALPELS, trunk, and gate.

---

## Medium Severity Bugs

### Bug 1: PANTRY Room Description Always Lists Foxglove & Charcoal (Even After Taking)

- **Room:** Pantry
- **File:** `dungeon.zil`, line 615 (`PANTRY-FCN`)
- **Problematic Text:** `"The shelves hold preserves, a warning-labeled bottle of foxglove, and powdered charcoal for swallowed poisons."`
- **Conflict:** The PANTRY-FCN room description uses a static string that names the takeable FOXGLOVE and CHARCOAL objects. After both are taken, the room description **still claims they are on the shelves**.
- **Command:** `take foxglove`, `take charcoal`, then `look`
- **Actual Output:**
  ```
  Pantry
  Cool, dry air smells of apples and charcoal dust. The shelves hold preserves, a warning-labeled bottle of foxglove, and powdered charcoal for swallowed poisons. The dining room lies south.
  ```
- **Expected:** After both items are taken, the description should omit the foxglove and charcoal (e.g. "The shelves hold preserves and spices.").
- **Root Cause:** The `PANTRY-FCN` routine (line 610-615) writes static text without checking `<IN? ,FOXGLOVE ,PANTRY>` or `<IN? ,CHARCOAL ,PANTRY>`.

---

### Bug 2: SHELVES-F Always Describes Foxglove & Charcoal (Even After Taking)

- **Room:** Pantry
- **File:** `actions.zil`, line 465 (`SHELVES-F`)
- **Problematic Text:** `"The shelves hold preserves, spices, dried foxglove with a poison warning, and powdered charcoal labeled for swallowed poisons."`
- **Conflict:** The `SHELVES-F` examine handler uses a static string that names the takeable FOXGLOVE and CHARCOAL. After both are taken, `examine shelves` **still lists them as present**.
- **Command:** `take foxglove`, `take charcoal`, then `examine shelves`
- **Actual Output:**
  ```
  The shelves hold preserves, spices, dried foxglove with a poison warning, and powdered charcoal labeled for swallowed poisons.
  ```
- **Expected:** After both items are taken, the shelves should describe only remaining items (e.g. "The shelves hold preserves and spices.").
- **Root Cause:** `SHELVES-F` (actions.zil line 463-466) writes a static string without checking whether the takeable items are still in the pantry.

---

### Bug 3: TABLE-F Always Mentions Wax Seal (Even After Taking)

- **Room:** Dining Room
- **File:** `actions.zil`, line 327 (`TABLE-F`)
- **Problematic Text:** `"The dining table is set for two, but only one place was used. A wax seal lies near the empty plate."`
- **Conflict:** The `TABLE-F` examine handler uses a static string that names the takeable WAX-SEAL. After the seal is taken, `examine table` **still claims it lies near the plate**.
- **Command:** `take wax seal`, then `examine table`
- **Actual Output:**
  ```
  The dining table is set for two, but only one place was used. A wax seal lies near the empty plate.
  ```
- **Expected:** After the seal is taken, the description should omit it (e.g. "The dining table is set for two, but only one place was used.").
- **Note:** The room description (`DINING-ROOM-FCN`) correctly omits the WAX-SEAL's FDESC after it's taken (the FDESC is not listed on `look`). Only the `examine table` handler has the stale text.
- **Root Cause:** `TABLE-F` (actions.zil line 325-328) writes a static string without checking `<IN? ,WAX-SEAL ,DINING-ROOM>`.

---

## Low Severity Bugs

### Bug 4: TRUNK LDESC Implies Closed State, But Trunk Starts Open

- **Room:** Servants' Quarters
- **File:** `dungeon.zil`, line 546
- **Problematic Text:** `(LDESC "A large wooden trunk, its lid heavy.")`
- **Conflict:** The LDESC text says "its lid heavy" (implying the lid is closed/down), but the TRUNK object has `(FLAGS NDESCBIT CONTBIT OPENBIT SEARCHBIT)` — the `OPENBIT` flag means it starts open.
- **Impact:** Low. Because the trunk has `OPENBIT` set from the start, the parser shows its contents instead of the LDESC when examined. The LDESC is never actually displayed to the player. This is a code-quality issue, not a runtime bug.
- **Suggested Fix:** Either change the LDESC to match the open state (e.g. "A large wooden trunk stands open in the corner.") or remove `OPENBIT` and add a flag to open it on first interaction.

---

## Patterns NOT Found (Clean Areas)

The following patterns from the blackwood-horror audit were checked and found to be **clean** in limehouse-killings:

1. **No PSEUDO objects exist** — The game uses only real objects with SYNONYM/ADJECTIVE declarations. No PSEUDO handlers overlap with real takeable objects.

2. **READING-DESK is state-aware** — After taking the torn page, `examine reading desk` correctly says "its surface now bare except for scattered papers and the clean rectangle where the torn page lay." (actions.zil line 317-323)

3. **FOUNTAIN-FCN is state-aware** — After taking the footprint cast, `examine fountain` correctly omits the cast mention. (actions.zil line 403-412)

4. **HEDGES-F is state-aware** — After taking the knife, `examine hedges` correctly says "one cut branch still shows where the knife was lodged." (actions.zil line 414-422)

5. **LOCKED-BOX-DESC-F is state-aware** — The box description dynamically changes from "small locked box" to "box lies open" based on `LOCKED-BOX-OPENED`. (actions.zil line 68-74)

6. **KITCHEN-FCN is state-aware** — The drawer state is dynamically shown ("closed" vs "stands open"). (actions.zil line 540-550)

7. **DRAWER-F is state-aware** — The drawer shows "Inside is a leather roll" when first opened, and "already open" on repeat. (actions.zil line 394-401)

8. **ENTRANCE-HALL-FCN is state-aware** — The magnifying glass FDESC only appears on first visit (before taking), and the room description dynamically shows study door state, inspector presence, and Moriarty position. (actions.zil line 617-635)

9. **DINING-ROOM-FCN is partially state-aware** — The room description dynamically handles `CABINET-CLUE-SEEN`, `CASE-ACT`, and `LADY-CONFRONTED`. Only the TABLE-F handler has the static wax seal issue.

---

## Regression Test Recommendations

Each medium-severity bug should get a focused regression test. Here are the recommended test scenarios:

### Test 1: Pantry items disappear from room description after taking
```zil
<SETG HERE ,PANTRY>
<MOVE ,WINNER ,PANTRY>
<MOVE ,FOXGLOVE ,WINNER>
<MOVE ,CHARCOAL ,WINNER>
<ASSERT-NOT-TEXT "foxglove" <CO-RESUME ,CO "look">>
<ASSERT-NOT-TEXT "charcoal" <CO-RESUME ,CO "look">>
```

### Test 2: Pantry shelves don't list taken items
```zil
<SETG HERE ,PANTRY>
<MOVE ,WINNER ,PANTRY>
<MOVE ,FOXGLOVE ,WINNER>
<MOVE ,CHARCOAL ,WINNER>
<ASSERT-NOT-TEXT "foxglove" <CO-RESUME ,CO "examine shelves">>
<ASSERT-NOT-TEXT "charcoal" <CO-RESUME ,CO "examine shelves">>
```

### Test 3: Dining table doesn't mention taken wax seal
```zil
<SETG HERE ,DINING-ROOM>
<MOVE ,WINNER ,DINING-ROOM>
<MOVE ,WAX-SEAL ,WINNER>
<ASSERT-NOT-TEXT "wax seal" <CO-RESUME ,CO "examine table">>
```

---

*Report generated by game tester agent on July 22, 2026*
