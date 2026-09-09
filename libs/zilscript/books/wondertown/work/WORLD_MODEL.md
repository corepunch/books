# Wondertown — World Model

## Puzzle Dependency Graph

```
START (WORKSHOP-FLOOR)
  │
  ├─► OIL-CAN (under workbench) ──► OIL LADDER ──► STORAGE-LOFT
  │                                                    │
  │                                              Old Tick + Journal
  │
  ├─► TOOL-BENCH ──► TAKE BERTRAND-KEY ──► WIND BERTRAND
  │                                                │
  │                                          COUNTERTOP
  │                                                │
  │                                          Marzipan (song → clues)
  │                                          Tin Soldier + Music Box
  │
  └─► PET DOOR ──► SNOWY-ALLEY ──► CLOCK-SQUARE
                                        │
                              ┌─────────┼─────────┐
                              │         │         │
                        MAILBOX     WIND TOWER  (shortcut)
                        CORNER     (optional)
                              │
                        Letter + Scarf
                              │
                        SCRAP-YARD
                              │
                    ┌─────────┼─────────┐
                    │                   │
              HELP CART          BYPASS (if Nutmeg trusts)
              (compassion)       (alternate path)
                    │                   │
                    └─────────┬─────────┘
                              │
                          FOX-DEN
                              │
                    ┌─────────┼─────────┐
                    │                   │
              BEFRIEND NUTMEG    FORCE KEY
              (trust path)       (lesser ending)
                    │                   │
                    └─────────┬─────────┘
                              │
                        WORKSHOP KEY
                              │
                    RETURN TO WORKSHOP
                              │
                    ┌─────────┼─────────┐
                    │                   │
              OLD TICK +         TIN SOLDIER
              NUTMEG HELPS      (alternate)
                    │                   │
                    └─────────┬─────────┘
                              │
                        TOLLIVER'S STUDY
                              │
                        Diagram + Journal
                              │
                        WORKSHOP HEART
                              │
                        FINAL REWIND
                              │
                    ┌─────────┼─────────┐
                    │         │         │
                3+ COMP    1-2 COMP   KEY ONLY
                (best)    (bittersweet) (minimal)
```

## Verb/Object Response Matrix

### Core Actions vs. Key Objects

| Verb | Bertrand | Old Tick | Marzipan | Nutmeg | Scrap Cart | Key Hook | Clock Tower |
|------|----------|----------|----------|--------|------------|----------|-------------|
| EXAMINE | frozen pose, key in back | dusty, five to midnight | one eye, humming | patchy fur, key on neck | carrying broken toys | empty, string dangling | giant, winding mechanism |
| WIND | wakes him | chimes riddle | N/A | "I don't need winding" | N/A | N/A | slows tick rate |
| OIL | N/A | N/A | N/A | N/A | N/A | N/A | N/A |
| ASK | about key/tolliver | about riddles | about key/tolliver/fox | about key/tolliver | N/A | N/A | N/A |
| TAKE | too heavy (key OK) | too heavy | too heavy | key (if trust) | too heavy | string only | N/A |
| GIVE | N/A | N/A | button accepted | scarf/ball accepted | doll head accepted | N/A | N/A |
| PUSH | too heavy | N/A | N/A | she recoils | rumbles warning | N/A | too huge |
| ATTACK | strong jaw | N/A | N/A | flinches (trust lost) | ignores | N/A | N/A |
| LISTEN | N/A | chimes on hour | humming song | whimpers | creaks | N/A | ticking |

## Default Response Strategy

Every object that doesn't have a specific handler should respond to:
- EXAMINE: Generic description from LDESC/TEXT
- TAKE: If TAKEBIT set, allow. Otherwise: "You can't take that."
- PUSH/PULL: "That doesn't accomplish anything."
- OPEN/CLOSE: If OPENABLEBIT set, handle. Otherwise: "You can't open that."
- WIND: "There's nothing to wind there."
- OIL: "That doesn't need oiling."

## Softlock Mitigation List

1. **Oil can loss:** Respawns under workbench after 10 turns if not in inventory/workshop
2. **Bertrand key loss:** Always stays in TOOL-BENCH room (or inventory)
3. **Workshop key loss:** Cannot be dropped once obtained. If Nutmeg reclaims it, she's in FOX-DEN
4. **Pet door:** Always two-way accessible
5. **Nutmeg hostility:** Key still obtainable (falls asleep after 20 turns, can be taken)
6. **Cart bypass:** If Nutmeg trusts player first, she opens gate from den side
7. **Clock stairs access:** If Nutmeg dead/hostile, tin soldier can press latch
8. **Journal/diagram loss:** Readable in-place if dropped (never lost)
9. **Tick timer:** Is generous (200 turns baseline, ~100 with tower wound). Even without tower, winnable
10. **Final heart:** Key alone always works (minimum ending). Companions are bonus

## Container Visibility Transitions

| Container | Initial State | How Opened | Post-Open Visibility |
|-----------|--------------|------------|---------------------|
| WORKBENCH | CONTBIT OPENBIT | Already open | OIL-CAN visible via LOOK UNDER |
| DISPLAY-CASE | CONTBIT OPENABLEBIT | OPEN CASE | TIN-SOLDIER, MUSIC-BOX visible |
| TOY-BOX | CONTBIT OPENABLEBIT | OPEN BOX | DOLL-ARM visible |
| MAILBOX | CONTBIT OPENBIT ACTORBIT | OPEN MAILBOX | MAILBOX-LETTERS visible |
| STUDY-DESK | SURFACEBIT CONTBIT OPENBIT | Already open | DIAGRAM, STUDY-JOURNAL on surface |

## Puzzle Fairness Audit

### Puzzle 1: WIND BERTRAND ✓
- Clear goal: Get past nutcracker blocking stairs
- Discoverable: Room desc mentions "frozen mid-stride" / "winding key in his back"
- Guessable: WIND is a core taught verb; TAKE KEY, WIND NUTCRACKER
- Verdict: FAIR

### Puzzle 2: OIL LADDER ✓
- Clear goal: Reach storage loft
- Discoverable: Room desc says "mechanism rusted" / oil can under workbench
- Guessable: OIL MECHANISM (taught)
- Verdict: FAIR

### Puzzle 3: MARZIPAN'S SONG ✓
- Clear goal: Get directions to Nutmeg
- Discoverable: She sings constantly; ASK/TELL prompts more songs
- Guessable: Standard ASK NPC ABOUT TOPIC
- Verdict: FAIR (song lyrics contain explicit directions)

### Puzzle 4: CLOCK TOWER ✓
- Clear goal: Slow time
- Discoverable: Mechanism visible at base; "too high" message
- Guessable: WIND CLOCK (if reachable)
- Verdict: FAIR (optional, not required)

### Puzzle 5: SCRAP CART ✓
- Clear goal: Get past cart blocking path
- Discoverable: EXAMINE CART reveals it's not hostile
- Guessable: GIVE DOLL-HEAD TO CART (doll head is in same room)
- Alternate: Nutmeg opens from other side
- Verdict: FAIR (slight misdirection, but EXAMINE gives clear info)

### Puzzle 6: BEFRIEND NUTMEG ✓
- Clear goal: Get key from fox
- Discoverable: Fox is defensive; gifts soften her
- Guessable: GIVE SCARF TO FOX, TELL FOX ABOUT TOLLIVER
- Alternate: Force key if hostile (lesser ending)
- Verdict: FAIR (emotional intelligence, multiple paths)

### Puzzle 7: STUDY ACCESS ✓
- Clear goal: Get behind clock
- Discoverable: Old Tick chimes after key obtained; "behind me lies the way"
- Guessable: WIND CLOCK (Old Tick), then GO BEHIND CLOCK
- Alternate: Tin soldier can reach latch
- Verdict: FAIR

### Puzzle 8: FINAL REWIND ✓
- Clear goal: Wind heart before dawn
- Discoverable: Diagram gives instructions
- Guessable: PUT KEY IN SLOT, PLACE companions
- Alternate: Key alone works (minimal ending)
- Verdict: FAIR (emotional choice determines ending quality)
