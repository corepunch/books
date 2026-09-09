# Blackwood Horror — Duplicate/Conflicting Object Audit

**Test Date:** July 22, 2026  
**Tested By:** Game Tester Agent  
**Focus:** Duplicate objects, conflicting descriptions, container/state mismatches

---

## Scalpel Area Fix — CONFIRMED CLEAN ✅

The original bug (OPERATING-THEATER had PSEUDO "SCALPELS" conflicting with real SCALPEL in METAL-CABINET) is fully resolved:

1. **VOC-EXACT alias** (actions.zil line 1379): `SCALPELS` → `INSTRUMENTS` — typing "examine scalpels" now routes to INSTRUMENTS-PSEUDO (scenery instruments), not the real scalpel.
2. **CABINET-F dynamic description** (actions.zil lines 143-152): Cabinet text now checks `<IN? ,SCALPEL ,METAL-CABINET>` and `<IN? ,ETHER-BOTTLE ,METAL-CABINET>` before mentioning items:
   - Before taking: "including a scalpel and a bottle"
   - After taking scalpel: "including a bottle"
   - After taking both: "various medical instruments"
3. **Parser routing verified**: `examine scalpel` → real SCALPEL object; `examine scalpels` → INSTRUMENTS-PSEUDO (scenery). No conflict.

---

## New Issues Found

### Bug 1: MORGUE REFRIGERATED-DRAWERS — Static "glow" Description After Serum Taken

- **Room:** Morgue
- **Object:** REFRIGERATED-DRAWERS (dungeon.zil line 381)
- **Description:** DRAWERS-F routine (actions.zil lines 192-195) always says: *"One drawer is slightly ajar, a faint luminescent glow emanating from within."* — even after the player takes the STRANGE-SERUM.
- **Expected:** After serum is taken, the description should say something like "One drawer is slightly ajar" (no glow mention), or "Most drawers are empty or contain only bones."
- **Reproduction:**
  1. Enter morgue, take serum
  2. Type `examine drawers`
  3. Output still says "a faint luminescent glow emanating from within"
- **Severity:** Medium (misleading — implies serum is still there)
- **Root cause:** DRAWERS-F is a static handler that doesn't check `<IN? ,STRANGE-SERUM ,REFRIGERATED-DRAWERS>`

### Bug 2: STORAGE ROOM SHELVES — Static Item List After Items Taken

- **Room:** Storage Room
- **Object:** SHELVES (dungeon.zil line 508)
- **Description:** SHELVES-F routine (actions.zil lines 299-302) always says: *"Among the debris, you find a lantern, a medical bag, and some old medical records."* — even after taking the bag, lantern, and records.
- **Expected:** After items are taken, the description should either omit taken items or say "The shelves are mostly empty now."
- **Reproduction:**
  1. Enter storage room, take bag, take lantern
  2. Type `examine shelves`
  3. Output still says "you find a lantern, a medical bag, and some old medical records"
- **Severity:** Medium (misleading — implies items are still available)
- **Root cause:** SHELVES-F doesn't check which items remain in the shelves

### Bug 3: BOILER ROOM WORKBENCH — Static "flashlight" Description After Flashlight Taken

- **Room:** Boiler Room
- **Object:** WORKBENCH (dungeon.zil line 489)
- **Description:** WORKBENCH-F routine (actions.zil lines 294-297) always says: *"A flashlight lies among them."* — even after taking the FLASHLIGHT.
- **Expected:** After flashlight is taken, the description should say "The workbench is covered with ancient tools: hammers, wrenches, screwdrivers. Most are rusted solid." (no flashlight mention)
- **Reproduction:**
  1. Enter boiler room, take flashlight
  2. Type `examine workbench`
  3. Output still says "A flashlight lies among them"
- **Severity:** Medium (misleading — implies flashlight is still there)
- **Root cause:** WORKBENCH-F doesn't check `<IN? ,FLASHLIGHT ,WORKBENCH>`

---

## Issues Verified as NOT Bugs

### CHAPEL-DOOR LDESC — Not a Bug ✅

The bug report (Bug 5) claimed CHAPEL-DOOR's LDESC "The chapel door is secured with a heavy lock" contradicts the room's dynamic description after unlocking. However, CHAPEL-DOOR has the `NDESCBIT` flag (dungeon.zil line 873), which suppresses its LDESC from room listings. The room's M-LOOK handler (actions.zil lines 73-82) dynamically shows the correct state. No contradiction appears in gameplay.

### GREEN-CANDLES LDESC — Not a Bug ✅

The bug report (Bug 6) claimed GREEN-CANDLES' LDESC "Candles burn with an unnatural green flame" contradicts the ending. However, GREEN-CANDLES also has `NDESCBIT` (dungeon.zil line 890), so its LDESC never appears in room listings. The EXAMINE handler (actions.zil lines 846-871) correctly returns "The candles are cold and dark now" after GAME-WON. No contradiction in gameplay.

### Dissection Table / Canvas Bundle Redundancy — Minor ✅

The morgue room LDESC says "a dissection table holds what appears to be a canvas-wrapped bundle" and the CANVAS-BUNDLE FDESC says "a human-shaped bundle wrapped in stained canvas awaits examination." These are complementary descriptions (room gives overview, object gives detail), not conflicts.

---

## Summary

| Category | Count |
|----------|-------|
| Scalpel area fix confirmed | ✅ |
| New static-description bugs | 3 |
| False-positive verifications | 2 |

### Recommendations

1. **Fix DRAWERS-F**: Add `<IN? ,STRANGE-SERUM ,REFRIGERATED-DRAWERS>` check to conditionally mention the glow
2. **Fix SHELVES-F**: Add checks for `<IN? ,MEDICAL-BAG ,SHELVES>`, `<IN? ,OIL-LANTERN ,SHELVES>`, `<IN? ,MEDICAL-RECORDS ,SHELVES>` to dynamically list remaining items
3. **Fix WORKBENCH-F**: Add `<IN? ,FLASHLIGHT ,WORKBENCH>` check to conditionally mention the flashlight

---

*Report generated by game tester agent*
