# Wondertown — Objects

## Object Registry

Every concrete noun must have a parser object. Format:
`OBJECT-ID | Head noun | Adjectives | Location | Flags | Roles | Discovery`

---

### Act 1 — Workshop Interior

#### WORKSHOP-FLOOR

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| KEY-HOOK | hook | key brass empty | WORKSHOP-FLOOR | NDESCBIT | Worldbuilding, blocker (empty) | "A brass key hook on the wall." — visible in room desc |
| WORKBENCH | workbench | wooden giant | WORKSHOP-FLOOR | SURFACEBIT CONTBIT OPENBIT | Practical (surface), clue | "The enormous workbench towers above you." |
| OIL-CAN | can oil | tiny copper | Under workbench (WORKBENCH) | TAKEBIT | Tool (OIL things) | LOOK UNDER WORKBENCH or SEARCH WORKBENCH |
| SAWDUST | sawdust | soft | WORKSHOP-FLOOR | NDESCBIT | Worldbuilding, light puzzle | "Soft sawdust covers the floor." |
| PET-DOOR | door | pet wooden small | WORKSHOP-FLOOR | NDESCBIT | Exit to Act 2 | "A small pet door is cut into the bottom of the main door." |
| LOFT-LADDER | ladder stairs | folding loft wooden | WORKSHOP-FLOOR | NDESCBIT | Climbable to STORAGE-LOFT | "A folding wooden ladder leads toward the storage loft." |
| SWEEP-BROOM | broom | tiny brush | WORKSHOP-FLOOR | TAKEBIT | Practical (sweep sawdust) | "Your tiny broom leans against the workbench." |
| CLOCK-FACE | clock cuckoo | old wooden | WORKSHOP-FLOOR | NDESCBIT | Hint system (Old Tick), worldbuilding | "An old cuckoo clock hangs on the wall." |
| KEY-STRING | string | frayed | KEY-HOOK | TAKEBIT | Clue (key was here) | "A frayed string dangles from the empty hook." |

#### TOOL-BENCH

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| BERTRAND | nutcracker | pompous painted | TOOL-BENCH | ACTORBIT | NPC, guardian | "A painted wooden nutcracker stands at attention, frozen mid-stride." |
| BERTRAND-KEY | key | winding tiny brass | TOOL-BENCH (on BERTRAND) | TAKEBIT | Tool (wind Bertrand) | EXAMINE BERTRAND → "There's a tiny winding key in his back." |
| VARNISH-POT | pot | varnish sticky | TOOL-BENCH | CONTBIT OPENBIT SURFACEBIT | Risk (sticky), worldbuilding | "A pot of varnish sits open, its contents gone tacky." |
| MAKESHIFT-STEPS | steps crate chair books | makeshift repair broad | TOOL-BENCH | NDESCBIT CLIMBBIT | Climbable to COUNTERTOP | "A low crate, old chair, and three broad repair books form a stable route upward." |
| TOOL-RACK | rack tools | wooden | TOOL-BENCH | CONTBIT OPENBIT | Worldbuilding | "A rack of tools — chisels, files, tiny hammers." |

#### COUNTERTOP

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| MARZIPAN | doll rag | one-eyed patched | COUNTERTOP | ACTORBIT | NPC, hint-giver | "A rag doll with one button eye sits against the window, humming." |
| DISPLAY-CASE | case display | glass dusty | COUNTERTOP | CONTBIT OPENBIT TRANSBIT | Worldbuilding, container | "A dusty glass display case holds forgotten treasures." |
| TIN-SOLDIER | soldier | tin | DISPLAY-CASE | TAKEBIT | Companion option, trade item | "A brave tin soldier, slightly rusted but still standing." |
| MUSIC-BOX | box music | silver | DISPLAY-CASE | TAKEBIT TURNBIT | Puzzle item | "A silver music box with a tiny crank." |
| SHOP-WINDOW | window | frosted glass | COUNTERTOP | NDESCBIT | Worldbuilding, clue (view of clock square) | "Through the frosted window, you can see the snowy street outside." |
| BUTTON | button | spare | COUNTERTOP | TAKEBIT | Repair item for Marzipan | "A spare button. Just the right size for a doll's eye." |

#### STORAGE-LOFT

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| OLD-TICK | clock cuckoo | old dusty | STORAGE-LOFT | ACTORBIT | NPC, riddle-hints | "An old cuckoo clock, dusty and still. Its hands read five to midnight." |
| TOY-BOX | box toy | dusty cardboard | STORAGE-LOFT | CONTBIT OPENBIT | Worldbuilding, minor items | "A cardboard box labelled 'Broken — For Repair'." |
| DOLL-ARM | arm doll | porcelain | TOY-BOX | TAKEBIT | Clue item (for scrap-yard) | "A delicate porcelain doll arm." |
| TOLLIVER-JOURNAL | journal diary | leather old | STORAGE-LOFT | TAKEBIT READBIT | Lore (Act 1) | "An old leather journal with Tolliver's name on the cover." |
| COBWEBS | cobwebs webs | dusty | STORAGE-LOFT | NDESCBIT | Atmosphere | "Dusty cobwebs drape the rafters." |
| LADDER-MECH | mechanism ladder | rusty iron | WORKSHOP-FLOOR | TURNBIT | Blocker (needs OIL) | "The ladder mechanism is rusted solid." |
| LOFT-HATCH | hatch trapdoor | wooden | STORAGE-LOFT | NDESCBIT | Exit down | "A wooden trapdoor leads back down to the workshop floor." |

---

### Act 2 — Wrenfold By Night

#### SNOWY-ALLEY

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| FOOTPRINTS | footprints tracks | fox tiny muddy | SNOWY-ALLEY | NDESCBIT | Clue (Nutmeg's trail) | "Tiny fox footprints lead east through the fresh snow." |
| STREETLAMP | streetlamp lamp | flickering toy | SNOWY-ALLEY | LIGHTBIT | Worldbuilding, helper | "A streetlamp — actually a repurposed toy lantern on a pole — flickers weakly." |
| SNOW | snow | fresh deep | SNOWY-ALLEY | NDESCBIT | Atmosphere | "Fresh snow blankets the cobblestones." |
| WORKSHOP-DOOR | door | workshop | SNOWY-ALLEY | NDESCBIT | Return to Act 1 | "The workshop door looms behind you, the pet door at its base." |

#### CLOCK-SQUARE

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| CLOCK-TOWER | tower clock | giant stone | CLOCK-SQUARE | NDESCBIT | Tick display, winding puzzle | "The clock tower dominates the square, its face showing the hours until dawn." |
| CLOCK-WINDING | mechanism winding | brass | CLOCK-TOWER | TURNBIT | WIND puzzle | "A brass winding mechanism at the tower's base." |
| BAKER-TOY | baker toy | wooden | CLOCK-SQUARE | NDESCBIT | Worldbuilding | "A wooden baker toy stands in the shop window, frozen mid-knead." |
| TOY-LAMPS | lamps toys | tin | CLOCK-SQUARE | LIGHTBIT | Atmosphere | "Tin toy lamps line the square, their lights dim." |
| BAKERY-DOOR | door bakery | glass | CLOCK-SQUARE | NDESCBIT | Disabled exit (too heavy for Pip) | "The bakery door is far too heavy for you to budge." |

#### MAILBOX-CORNER

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| MAILBOX | mailbox | talking tin | MAILBOX-CORNER | CONTBIT OPENBIT ACTORBIT | NPC, container | "A tin mailbox, painted red. Its flap moves like a mouth." |
| LETTER | letter envelope | crumpled | MAILBOX-CORNER (loose) | TAKEBIT READBIT | Lore, Tolliver's last note | "A crumpled envelope lies in the snow." |
| SCARF | scarf | red wool | MAILBOX-CORNER | TAKEBIT | Gift for Nutmeg | "A red wool scarf, dropped in the snow." |
| MAILBOX-LETTERS | letters mail | unsent | MAILBOX | TAKEBIT READBIT | Worldbuilding | "A bundle of unsent letters inside the mailbox." |

#### SCRAP-YARD

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| SCRAP-CART | cart | scrap metal | SCRAP-YARD | CONTBIT OPENBIT | Puzzle (compassion test) | "A scrap-metal cart creaks along, collecting broken toys." |
| BROKEN-TOYS | toys | broken discarded | SCRAP-YARD | NDESCBIT | Emotional worldbuilding | "Piles of broken toys — a headless doll, a three-legged horse." |
| HEADLESS-DOLL | doll headless | porcelain | SCRAP-YARD | TAKEBIT | Gift for Nutmeg / cart test | "A headless porcelain doll." |
| DOLL-HEAD | head doll | porcelain | SCRAP-YARD | TAKEBIT | Repair item | "A porcelain doll head with painted eyes. It matches the arm." |
| TOY-HORSE | horse toy | three-legged | SCRAP-YARD | TAKEBIT | Atmosphere | "A toy horse, one leg missing." |
| YARD-GATE | gate | iron east | SCRAP-YARD | NDESCBIT | Blocked exit | "An iron gate, wedged shut by a fallen beam." |

#### FOX-DEN

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| NUTMEG | fox | patchy stuffed | FOX-DEN | ACTORBIT | NPC, key holder, emotional arc | "A fox-shaped toy with patchy fur, curled in a den of rags." |
| WORKSHOP-KEY | key workshop | brass ticking | FOX-DEN (on NUTMEG) | TAKEBIT | Central MacGuffin | "The workshop key hangs from a string around the fox's neck. It ticks faintly." |
| RAG-BED | bed | rag cosy | FOX-DEN | CONTBIT OPENBIT SURFACEBIT | Worldbuilding | "A cosy bed made from rags and twigs." |
| TOY-CANDLE | candle | toy wax | FOX-DEN | LIGHTBIT FLAMEBIT | Warmth, light | "A tiny toy candle burns with a warm, steady flame." |
| STRING-BALL | ball string | yarn | FOX-DEN | TAKEBIT | Gift for Nutmeg | "A ball of red yarn string, perfect for a fox to chase." |

---

### Act 3 — Resolution

#### TOLLIVER-STUDY

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| TOLLIVER-COAT | coat jacket | worn | TOLLIVER-STUDY | TAKEBIT | Lore item | "Grandfather Tolliver's worn coat hangs on the chair." |
| TEA-CUP | cup tea | cold | TOLLIVER-STUDY | TAKEBIT | Worldbuilding | "A cup of tea, long gone cold." |
| STUDY-DESK | desk | wooden cluttered | TOLLIVER-STUDY | SURFACEBIT CONTBIT OPENBIT | Surface, container | "A cluttered wooden desk." |
| DIAGRAM | diagram drawing | winding | STUDY-DESK | TAKEBIT READBIT | Final puzzle clue | "A hand-drawn diagram showing how to wind the workshop heart." |
| STUDY-JOURNAL | journal diary | final | STUDY-DESK | TAKEBIT READBIT | Final lore | "Tolliver's journal, open to the last entry." |
| CHAIR | chair | wooden old | TOLLIVER-STUDY | NDESCBIT | Worldbuilding | "An old wooden chair, pushed back from the desk." |

#### WORKSHOP-HEART (Hidden)

| ID | Head | Adjectives | Location | Flags | Roles | Discovery |
|----|------|-----------|----------|-------|-------|-----------|
| HEART-MECH | mechanism heart | clockwork giant | WORKSHOP-HEART | NDESCBIT | Final puzzle | "The workshop's heart — a giant clockwork mechanism, still and silent." |
| KEY-SLOT | slot keyhole | brass | HEART-MECH | NDESCBIT | Key insertion point | "A brass keyhole at the mechanism's center." |
| SILENT-TOYS | toys silent | motionless | WORKSHOP-HEART | NDESCBIT | Emotional weight | "Dozens of toys stand motionless around the heart, waiting." |

---

### Local-Globals (visible from multiple rooms)

| ID | Head | Adjectives | Rooms | Flags | Roles |
|----|------|-----------|-------|-------|-------|
| WORKSHOP-BUILDING | building workshop shop | old cosy | SNOWY-ALLEY | NDESCBIT | Worldbuilding |
| MOON | moon | winter bright | SNOWY-ALLEY, CLOCK-SQUARE, MAILBOX-CORNER, SCRAP-YARD | NDESCBIT | Atmosphere |
| SNOW-SCENERY | snow | deep cold | All exterior | NDESCBIT | Atmosphere |

---

## Opening Slice Vocabulary Audit

From the starting room description, every noun must be parseable:

> You are in Grandfather Tolliver's workshop. The **workbench** towers above you, its surface cluttered with **tools**. A brass **key hook** on the wall hangs empty, a frayed **string** still dangling from it. Your tiny **broom** leans nearby. Soft **sawdust** covers the floor. A **pet door** is cut into the workshop's main **door** to the north. An old **cuckoo clock** ticks softly on the wall. A folding loft **ladder** leads upward, its **mechanism** rusted.

| Word | Has Object? | Object ID |
|------|------------|-----------|
| workshop | Yes | WORKSHOP-BUILDING (local-global) |
| workbench | Yes | WORKBENCH |
| tools | Yes | TOOL-RACK (PSEUDO) |
| key hook | Yes | KEY-HOOK |
| string | Yes | KEY-STRING |
| broom | Yes | SWEEP-BROOM |
| sawdust | Yes | SAWDUST |
| pet door | Yes | PET-DOOR |
| door | Yes | WORKSHOP-DOOR (PSEUDO) |
| cuckoo clock | Yes | CLOCK-FACE |
| ladder | Yes | LOFT-LADDER |
| mechanism | Yes | LADDER-MECH |
