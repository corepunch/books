# Wondertown — Map

## Room Graph

```
                   ┌──────────────┐
                   │  TOLLIVER-   │
                   │  STUDY       │
                   │  (Upstairs)  │
                   └──────┬───────┘
                          │ down (via clock stairs, endgame only)
                          │
    ┌─────────────────────┼─────────────────────┐
    │                     │                     │
┌───┴──────────┐   ┌──────┴───────┐   ┌────────┴────────┐
│  STORAGE-    │   │  WORKSHOP-   │   │   COUNTERTOP    │
│  LOFT        │   │  FLOOR       │   │   (Toy Display) │
│  (Act 1)     │   │  (Start)     │   │   (Act 1)       │
└──────────────┘   └──────┬───────┘   └────────┬────────┘
                          │ PET-DOOR              │ climb down
                          │ (to Act 2)            │
                          │                       │
    ┌─────────────────────┼───────────────────────┘
    │                     │
┌───┴──────────┐   ┌──────┴───────┐
│  SNOWY-      │   │  CLOCK-      │
│  ALLEY       │   │  SQUARE      │
│  (Act 2)     │   │  (Act 2)     │
└──────┬───────┘   └──────┬───────┘
       │                  │
       │         ┌────────┴────────┐
       │         │  MAILBOX-       │
       │         │  CORNER         │
       │         │  (Act 2)        │
       │         └────────┬────────┘
       │                  │
       └────────┬─────────┘
                │
         ┌──────┴───────┐
         │  SCRAP-      │
         │  YARD        │
         │  (Act 2)     │
         └──────┬───────┘
                │
         ┌──────┴───────┐
         │  FOX-        │
         │  DEN         │
         │  (Act 2/3)   │
         └──────────────┘
```

## Room Descriptions & Roles

### WORKSHOP-FLOOR (Start Room)
- **Role:** Tutorial hub, Act 1 base
- **Landmark:** The key hook (empty, still ticking faintly)
- **Visible:** Workbench to climb, sawdust piles, pet door, cuckoo clock on wall, Bertrand in corner
- **Blocked:** Pet door (can fit through — Pip is small), Countertop (too high to climb)
- **First reward:** Oil can under workbench (teaches TAKE, EXAMINE)
- **Exits:** UP (raise and climb the folding loft ladder to STORAGE-LOFT, needs OIL), EAST (to TOOL-BENCH), OUT (pet door to SNOWY-ALLEY)

### TOOL-BENCH
- **Role:** Tutorial expansion, Bertrand's post
- **Landmark:** Enormous tools, a crate-chair-book climb, varnish pot
- **Visible:** Bertrand (nutcracker), stable makeshift steps up to COUNTERTOP, tiny winding key for Bertrand
- **Blocked:** Chair and book steps guarded by Bertrand (he's frozen on the seat, needs WIND)
- **Puzzle:** WIND BERTRAND → he moves aside, allows access to COUNTERTOP
- **Exits:** WEST (to WORKSHOP-FLOOR), UP (to COUNTERTOP, blocked by Bertrand)

### COUNTERTOP
- **Role:** Toy display, Marzipan's perch, view outside
- **Landmark:** Glass display case, street-facing window, Marzipan (rag doll)
- **Visible:** Marzipan singing, street visible through snow-frosted window, clock square visible in distance
- **Puzzle:** ASK MARZIPAN ABOUT TOLLIVER → she sings a riddle-song giving directions
- **Exits:** DOWN (to TOOL-BENCH)

### STORAGE-LOFT
- **Role:** Exploration, old toy parts, lore
- **Landmark:** Cobwebby rafters, boxes of broken toys, Tolliver's old repair journal
- **Visible:** Old Tick (cuckoo clock — only answers on the hour), dusty boxes
- **Puzzle:** LISTEN to Old Tick on the hour for hints; find journal with lore about the key
- **Exits:** DOWN (to WORKSHOP-FLOOR, needs OIL on rusty ladder mechanism)

### SNOWY-ALLEY
- **Role:** Transition to Act 2, footprints discovery
- **Landmark:** Fresh snow, tiny fox footprints, streetlamp-toy flickering
- **Visible:** Footprints leading east, streetlamp-toy (can be spoken to), workshop behind
- **Puzzle:** EXAMINE FOOTPRINTS → learn they belong to a fox-shaped toy
- **Exits:** EAST (to CLOCK-SQUARE), IN (back to WORKSHOP-FLOOR through pet door)

### CLOCK-SQUARE
- **Role:** Central hub of Wrenfold, time pressure visible
- **Landmark:** Giant clock tower (shows remaining ticks as hour), shopfronts (toy shops)
- **Visible:** Clock tower, baker-toy in shop window, lamp-post toys
- **Puzzle:** WIND CLOCK → slows tick rate (tick decrements every 2 turns instead of 1)
- **Exits:** WEST (to SNOWY-ALLEY), EAST (to MAILBOX-CORNER), SOUTH (to SCRAP-YARD)

### MAILBOX-CORNER
- **Role:** Worldbuilding, Nutmeg clue, letter from Tolliver
- **Landmark:** Mailbox-toy with mouth-flap, scattered letters, streetlamp
- **Visible:** Letters in snow, mailbox that talks, fox footprints continue east
- **Puzzle:** READ LETTER → Tolliver's last note: "Gone to mend the heart. Take care of them."; ASK MAILBOX ABOUT FOX → points toward scrap-yard
- **Exits:** WEST (to CLOCK-SQUARE)

### SCRAP-YARD
- **Role:** Emotional turning point, broken toys, scrap cart puzzle
- **Landmark:** Piles of broken toys, scrap-metal cart that moves, Nutmeg's footprints
- **Visible:** Scrap cart (seems threatening, actually rescuing toys), broken doll parts
- **Puzzle:** The scrap cart is not hostile — EXAMINE reveals it's carrying broken toys to safety. SHOW compassion (GIVE doll part to cart) → cart reveals path to Fox Den
- **Exits:** NORTH (to CLOCK-SQUARE), EAST (to FOX-DEN, initially blocked by cart)

### FOX-DEN
- **Role:** Nutmeg encounter, Act 2 climax
- **Landmark:** Cosy den made of rags and twigs, warm glow from within
- **Visible:** Nutmeg (fox toy, defensive), workshop key (on a string around her neck), small fire (toy candle)
- **Puzzle:** Multi-step — Nutmeg requires empathy. ASK NUTMEG ABOUT KEY → she gets angry. GIVE food/oil to her → she softens. TELL NUTMEG ABOUT TOLLIVER → she reveals guilt. Final test: she offers the key if you promise to save the other toys too.
- **Exits:** WEST (to SCRAP-YARD)

### TOLLIVER-STUDY (Endgame)
- **Role:** Revelation, final lore
- **Landmark:** Desk, chair, open journal, cup of cold tea
- **Visible:** Journal with final entry, grandfather's coat on chair, winding mechanism diagram
- **Puzzle:** READ JOURNAL → reveals Tolliver went to rewind the workshop heart but didn't return. Diagram shows how to rewind the heart.
- **Exits:** DOWN (to WORKSHOP-FLOOR, via clock stairs — only accessible after Nutmeg gives key)

### WORKSHOP-HEART (Hidden)
- **Role:** Final puzzle, ending scene
- **Landmark:** Giant clockwork mechanism, the pulsing heart of the workshop
- **Visible:** Central winding mechanism, slots for key, dozens of silent toy-figures around
- **Puzzle:** WIND HEART WITH KEY → triggers ending. Player must choose which toys to rewind (inventory choice). Even if they can't save all, saving any is rewarded.
- **Access:** Accessed through a hidden door behind Old Tick's clock in WORKSHOP-FLOOR. Only opens when key is fully wound and Nutmeg helps push the mechanism.

## Hubs & Landmarks

- **Hub:** WORKSHOP-FLOOR (Act 1), CLOCK-SQUARE (Act 2)
- **Landmarks:** Key hook (empty), Clock Tower (tick display), Giant workbench
- **Non-Euclidean:** None (fully Euclidian, standard compass directions)

## Blocked Exits

| Exit | Blocker | Solution |
|------|---------|----------|
| UP from TOOL-BENCH | Bertrand stuck mid-stride | WIND BERTRAND |
| UP from WORKSHOP-FLOOR (to STORAGE-LOFT) | Rusty ladder mechanism | OIL LADDER |
| EAST from SCRAP-YARD | Scrap cart blocking path | Show compassion / GIVE doll part |
| DOWN from TOLLIVER-STUDY (clock stairs) | Hidden behind Old Tick | Nutmeg helps after befriending |
| WORKSHOP-HEART access | Hidden door behind clock | Key wound + Nutmeg's help |
| Pet door (for larger toys) | Size restriction | Pip is small enough; Nutmeg can't follow |
