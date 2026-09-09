# Wondertown — Progressive Hints

## Hint System Design

In-game HINT command provides progressive hints. Each time the player types HINT, the next level of hint is revealed for their current puzzle stage. Hints are gated by puzzle progress — the system detects what the player needs based on state flags.

---

## Hint Levels by Puzzle

### Getting Started (no puzzles solved)
| Level | Text |
|-------|------|
| 1 | "The workshop feels different tonight. Check the key hook on the wall." |
| 2 | "The key is gone. Look around the workshop for clues — try examining things." |
| 3 | "There's an oil can under the workbench. Oil might help with the rusty loft-ladder mechanism." |
| 4 | "LOOK UNDER WORKBENCH, then TAKE OIL CAN, then OIL MECHANISM." |

### Bertrand (at TOOL-BENCH, Bertrand not wound)
| Level | Text |
|-------|------|
| 1 | "That nutcracker is blocking the way upstairs. He looks... stuck." |
| 2 | "Examine the nutcracker closely. He has something in his back." |
| 3 | "Take the winding key from his back, then wind him up." |
| 4 | "TAKE KEY, then WIND NUTCRACKER." |

### Ladder/Mechanism (ladder not oiled, player has oil can)
| Level | Text |
|-------|------|
| 1 | "The folding loft ladder won't rise. Something's rusted." |
| 2 | "The lifting mechanism needs oil. You have an oil can." |
| 3 | "OIL the mechanism or ladder with the oil can." |
| 4 | "OIL MECHANISM." |

### Marzipan's Clues (at COUNTERTOP, haven't learned about fox/scrap-yard)
| Level | Text |
|-------|------|
| 1 | "The rag doll is singing. Try listening — or asking her something." |
| 2 | "Ask Marzipan about the key, the fox, or Tolliver." |
| 3 | "Her song mentions a fox who went through the door with a key. The pet door, perhaps?" |
| 4 | "ASK DOLL ABOUT KEY, then go through the pet door to the snowy alley." |

### Finding Nutmeg (in Act 2, haven't found FOX-DEN)
| Level | Text |
|-------|------|
| 1 | "Fox footprints lead east from the alley. Follow them." |
| 2 | "Through the clock square, past the mailbox, toward the scrap-yard." |
| 3 | "The tracks lead to the scrap-yard. Something is blocking the way east." |
| 4 | "Examine the scrap cart. It's not your enemy — it's collecting broken toys. Help it." |

### Scrap Cart (at SCRAP-YARD, cart not moved)
| Level | Text |
|-------|------|
| 1 | "The cart isn't hostile. Look at it more carefully." |
| 2 | "The cart carries broken toys. One doll is missing its head. There's a doll head nearby." |
| 3 | "Give the doll head to the cart. Show compassion, not force." |
| 4 | "TAKE DOLL HEAD, then GIVE HEAD TO CART." |

### Nutmeg (at FOX-DEN, key not obtained)
| Level | Text |
|-------|------|
| 1 | "The fox has been alone a very long time. She needs kindness, not demands." |
| 2 | "Try giving her something — the red scarf from the mailbox, or tell her about Tolliver." |
| 3 | "Gifts and kind words build trust. She needs to know someone cares." |
| 4 | "GIVE SCARF TO FOX, TELL FOX ABOUT TOLLIVER, then ask for the key." |

### Old Tick / Study Access (have key, haven't accessed study)
| Level | Text |
|-------|------|
| 1 | "Now that you have the key, the cuckoo clock seems different. Try interacting with it." |
| 2 | "Old Tick said something about what lies behind the clock." |
| 3 | "Wind Old Tick. He'll tell you how to access the hidden stair." |
| 4 | "WIND CLOCK, then GO BEHIND CLOCK." |

### Workshop Heart (have diagram, haven't wound heart)
| Level | Text |
|-------|------|
| 1 | "The diagram shows a hidden chamber behind the workshop. That's where the heart is." |
| 2 | "Go behind the clock to access the heart. Then use the key." |
| 3 | "Insert the key into the heart's mechanism and wind it." |
| 4 | "GO BEHIND CLOCK, then WIND HEART WITH KEY." |

### Final Rewind (at heart, need companions)
| Level | Text |
|-------|------|
| 1 | "The heart is turning, but too slowly. It needs more than mechanical power." |
| 2 | "The toys you've helped along the way can lend their strength." |
| 3 | "Place your companions around the heart. Each one adds their love to the magic." |
| 4 | "PLACE SOLDIER. PLACE MUSIC BOX. Nutmeg and Bertrand will help if you were kind to them." |

---

## Hint State Machine

The hint system checks state flags in priority order:
1. If key not found and in FOX-DEN → Nutmeg hints
2. If in SCRAP-YARD and cart not moved → Cart hints
3. If in Act 2 and haven't found Nutmeg → Finding hints
4. If have key and haven't accessed study → Old Tick hints
5. If in heart room → Final rewind hints
6. If haven't wound Bertrand → Bertrand hints
7. If haven't oiled ladder → Ladder hints
8. Default → Getting started hints

Each hint call increments a per-puzzle counter. Level 1-4 for each puzzle.
