<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>
<VERSION ZIP>
<CONSTANT RELEASEID 1>

; === GLOBAL FLAGS ===

<GLOBAL TICK-COUNT 200>
<GLOBAL CLOCK-SLOWED <>>
<GLOBAL KEY-FOUND <>>
<GLOBAL KEY-WOUND <>>
<GLOBAL BERTRAND-WOUND <>>
<GLOBAL BERTRAND-POLITE <>>
<GLOBAL MARZIPAN-BUTTON <>>
<GLOBAL OLD-TICK-HEARD <>>
<GLOBAL OLD-TICK-RIDDLES 0>
<GLOBAL NUTMEG-TRUST 0>
<GLOBAL NUTMEG-GIFTS 0>
<GLOBAL LADDER-OILED <>>
<GLOBAL CART-MOVED <>>
<GLOBAL CART-HELPED <>>
<GLOBAL TOWER-WOUND <>>
<GLOBAL STUDY-ACCESS <>>
<GLOBAL HEART-ACCESS <>>
<GLOBAL JOURNAL-READ <>>
<GLOBAL LETTER-READ <>>
<GLOBAL DIAGRAM-READ <>>
<GLOBAL STUDY-JOURNAL-READ <>>
<GLOBAL REPAIR-BOOK-OPEN <>>
<GLOBAL GAME-WON <>>
<GLOBAL ENDING-TIER 0>
<GLOBAL COMPANION-COUNT 0>
<GLOBAL NUTMEG-SAVED <>>
<GLOBAL HINT-KEY 0>
<GLOBAL HINT-LEVEL 0>
<GLOBAL NUTMEG-KEY-METHOD 0>
<GLOBAL PUZZLES-SOLVED 0>
<GLOBAL LORE-DISCOVERED 0>
<GLOBAL SCORE-MAX 100>
<GLOBAL TIMER-ACTIVE T>
<GLOBAL RANKINGS
    <LTABLE "Toymaker's Apprentice"
         "Journeyman Toymaker"
         "Master Toymaker"
         "Grand Artificer"
         "The Last Toymaker">>

; === ROOMS ===

<ROOM WORKSHOP-FLOOR
      (IN ROOMS)
      (DESC "Workshop Floor")
      (LDESC "Grandfather Tolliver's workshop. Sawdust covers the floor like a golden blanket. The brass key hook on the wall is empty — only a frayed string hangs from it. A pet door glows with moonlight to the north.")
      (EAST TO TOOL-BENCH)
      (NORTH TO SNOWY-ALLEY)
      (UP TO STORAGE-LOFT IF LADDER-OILED)
      (IN TO TOLLIVER-STUDY IF STUDY-ACCESS)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL WORKSHOP-BUILDING TOPIC-TOLLIVER TOPIC-KEY TOPIC-HEART)>

<ROOM WORKBENCH-TOP
      (IN ROOMS)
      (DESC "Workbench Top")
      (ACTION WORKBENCH-TOP-FCN)
      (LDESC "The top of Grandfather Tolliver's workbench is a landscape of half-finished toys, curled wood shavings, and tiny tools. His enormous illustrated repair book rests near the edge.")
      (DOWN PER WORKBENCH-DOWN-EXIT)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL WORKBENCH TOPIC-TOLLIVER TOPIC-HEART)>

<ROOM TOOL-BENCH
      (IN ROOMS)
      (DESC "Tool Bench")
      (ACTION TOOL-BENCH-FCN)
      (LDESC "The tool bench stretches away, a landscape of enormous chisels and planes. A low crate, an old chair, and three broad repair books form a makeshift route to the countertop.")
      (WEST TO WORKSHOP-FLOOR)
      (UP TO COUNTERTOP IF BERTRAND-WOUND)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL TOPIC-TOLLIVER TOPIC-KEY)>

<ROOM COUNTERTOP
      (IN ROOMS)
      (DESC "Countertop")
      (ACTION COUNTERTOP-FCN)
      (LDESC "You are on the countertop — the toy display. A dusty glass case holds forgotten treasures, and through the frosted shop window you can see the snowy street outside, the clock tower visible in the distance.")
      (DOWN TO TOOL-BENCH)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL WORKSHOP-BUILDING TOPIC-TOLLIVER TOPIC-KEY TOPIC-FOX)>

<ROOM STORAGE-LOFT
      (IN ROOMS)
      (DESC "Storage Loft")
      (ACTION STORAGE-LOFT-FCN)
      (LDESC "The storage loft is dusty and dim, cobwebs draping the rafters like grey curtains. A cardboard box labelled 'Broken - For Repair' sits in the corner. This was where Tolliver kept toys he meant to fix.")
      (DOWN TO WORKSHOP-FLOOR)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL TOPIC-TOLLIVER)>

<ROOM SNOWY-ALLEY
      (IN ROOMS)
      (DESC "Snowy Alley")
      (LDESC "You emerge into the snowy alley behind the workshop. Fresh snow blankets the cobblestones, and the winter moon casts long blue shadows. Tiny fox footprints — unmistakably toy-sized — lead east through the snow. A streetlamp flickers overhead. It is not a real streetlamp — it is a toy lantern, repurposed and mounted on a pole. The workshop door looms behind you, the pet door at its base.")
      (SOUTH TO WORKSHOP-FLOOR)
      (EAST TO CLOCK-SQUARE)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL WORKSHOP-BUILDING MOON TOPIC-FOX)>

<ROOM CLOCK-SQUARE
      (IN ROOMS)
      (DESC "Clock Square")
      (LDESC "Abandoned shopfronts line the square — a bakery, a cobbler — each window displaying a toy frozen in its work. Tin toy lamps dot the cobblestones, their light weak and flickering.")
      (WEST TO SNOWY-ALLEY)
      (EAST TO MAILBOX-CORNER)
      (SOUTH TO SCRAP-YARD)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL MOON TOPIC-FOX TOPIC-TOLLIVER BAKERY)>

<ROOM MAILBOX-CORNER
      (IN ROOMS)
      (DESC "Mailbox Corner")
      (LDESC "Snow has drifted against the buildings at this quiet corner. Fox footprints lead back west toward the clock square; a fresher set seems to double back before veering south.")
      (WEST TO CLOCK-SQUARE)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL MOON TOPIC-FOX TOPIC-TOLLIVER FOOTPRINTS CLOCK-TOWER)>

<ROOM SCRAP-YARD
      (IN ROOMS)
      (DESC "Scrap-Yard")
      (ACTION SCRAP-YARD-FCN)
      (LDESC "The scrap-yard is a sad place. Broken toys are piled everywhere — a headless porcelain doll, a three-legged horse, toys that someone loved once and then discarded. Behind the cart, an iron gate leads east.")
      (NORTH TO CLOCK-SQUARE)
      (EAST TO FOX-DEN IF CART-MOVED)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL MOON TOPIC-FOX)>

<ROOM FOX-DEN
      (IN ROOMS)
      (DESC "Fox Den")
      (ACTION FOX-DEN-FCN)
      (LDESC "A cosy den made of rags and twigs, tucked between old crates. A tiny toy candle burns inside, casting warm shadows. This is a place someone made into a home.")
      (WEST TO SCRAP-YARD)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL TOPIC-TOLLIVER TOPIC-KEY TOPIC-FOX TOPIC-HEART)>

<ROOM TOLLIVER-STUDY
      (IN ROOMS)
      (DESC "Tolliver's Study")
      (LDESC "Grandfather Tolliver's private study smells of wood shavings, old paper, and a faint trace of magic. Stairs lead back down to the workshop, while a narrow passage descends deeper toward a rhythmic, mechanical sound.")
      (OUT TO WORKSHOP-FLOOR)
      (DOWN TO WORKSHOP-HEART)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL TOPIC-TOLLIVER TOPIC-KEY TOPIC-HEART)>

<ROOM WORKSHOP-HEART
      (IN ROOMS)
      (DESC "Workshop Heart")
      (LDESC "You are in a vast chamber hidden behind the workshop clock. The air holds the expectant stillness of a machine waiting to wake.")
      (UP TO TOLLIVER-STUDY)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL TOPIC-HEART TOPIC-TOLLIVER)>

; === OBJECTS: WORKSHOP-FLOOR ===

<OBJECT KEY-HOOK
        (IN WORKSHOP-FLOOR)
        (SYNONYM HOOK)
        (ADJECTIVE KEY BRASS EMPTY)
        (DESC "brass key hook")
        (LDESC "A brass key hook on the wall hangs empty. A frayed string dangles from it.")
        (FLAGS NDESCBIT)
        (ACTION KEY-HOOK-F)>

<OBJECT WORKBENCH
        (IN WORKSHOP-FLOOR)
        (SYNONYM BENCH WORKBENCH TABLE)
        (ADJECTIVE ENORMOUS WOODEN WORK GIANT CLUTTERED)
        (DESC "enormous workbench")
        (FDESC "The enormous workbench towers above your tiny frame. Its surface is cluttered with tools and half-finished toys.")
        (LDESC "The enormous workbench towers above you, its surface cluttered with tools.")
        (FLAGS SURFACEBIT CONTBIT OPENBIT SEARCHBIT CLIMBBIT)
        (ACTION WORKBENCH-F)>

<OBJECT OIL-CAN
        (IN WORKSHOP-FLOOR)
        (SYNONYM CAN OILCAN OIL-CAN)
        (ADJECTIVE TINY COPPER OIL)
        (DESC "tiny copper oil can")
        (LDESC "A tiny copper oil can, still half full, sits in the shadows beneath the workbench.")
        (FLAGS TAKEBIT)
        (SIZE 3)
        (ACTION OIL-CAN-F)>

<OBJECT SAWDUST
        (IN WORKSHOP-FLOOR)
        (SYNONYM SAWDUST DUST FLOOR)
        (ADJECTIVE SOFT GOLDEN)
        (DESC "soft sawdust")
        (LDESC "Soft sawdust covers the floorboards like a golden blanket.")
        (FLAGS NDESCBIT)
        (ACTION SAWDUST-F)>

<OBJECT PET-DOOR
        (IN WORKSHOP-FLOOR)
        (SYNONYM DOOR PET)
        (ADJECTIVE PET SMALL WOODEN)
        (DESC "small pet door")
        (LDESC "A small pet door is cut into the bottom of the workshop's main door.")
        (FLAGS NDESCBIT)
        (ACTION PET-DOOR-F)>

<OBJECT SWEEP-BROOM
        (IN WORKSHOP-FLOOR)
        (SYNONYM BROOM BRUSH)
        (ADJECTIVE TINY SWEEP)
        (DESC "tiny broom")
        (LDESC "Your tiny broom leans against the workbench.")
        (FLAGS TAKEBIT)
        (SIZE 4)
        (ACTION SWEEP-BROOM-F)>

<OBJECT CLOCK-FACE
        (IN WORKSHOP-FLOOR)
        (SYNONYM CLOCK CUCKOO)
        (ADJECTIVE OLD WOODEN WALL)
        (DESC "old cuckoo clock")
        (LDESC "An old cuckoo clock hangs on the wall, ticking softly.")
        (FLAGS NDESCBIT)
        (ACTION CLOCK-FACE-F)>

<OBJECT KEY-STRING
        (IN WORKSHOP-FLOOR)
        (SYNONYM STRING CORD THREAD TWINE)
        (ADJECTIVE FRAYED DANGLING)
        (DESC "frayed string")
        (LDESC "A frayed string dangles from the empty key hook.")
        (FLAGS TAKEBIT NDESCBIT)
        (SIZE 1)
        (ACTION KEY-STRING-F)>

<OBJECT LOFT-LADDER
        (IN WORKSHOP-FLOOR)
        (SYNONYM LADDER STAIRS STAIRCASE)
        (ADJECTIVE FOLDING LOFT WOODEN)
        (DESC "folding loft ladder")
        (LDESC "A folding wooden ladder leads toward the storage loft. Its iron lifting mechanism is rusted solid.")
        (FLAGS NDESCBIT)
        (ACTION LOFT-LADDER-F)>

<OBJECT LADDER-MECH
        (IN WORKSHOP-FLOOR)
        (SYNONYM MECHANISM LADDER LIFT WINCH)
        (ADJECTIVE RUSTY IRON LIFTING)
        (DESC "rusty ladder mechanism")
        (LDESC "The rusty iron lifting mechanism that raises the folding loft ladder is frozen solid.")
        (FLAGS TURNBIT NDESCBIT)
        (ACTION LADDER-MECH-F)>

; === OBJECTS: TOOL-BENCH ===

<OBJECT BERTRAND
        (IN TOOL-BENCH)
        (SYNONYM NUTCRACKER BERTRAND SOLDIER CAPTAIN)
        (ADJECTIVE PAINTED POMPOUS WOODEN)
        (DESC "painted wooden nutcracker")
        (LDESC "A painted wooden nutcracker stands at attention, frozen mid-stride.")
        (DESCFCN BERTRAND-DESC-F)
        (FLAGS ACTORBIT)
        (ACTION BERTRAND-F)>

<OBJECT BERTRAND-KEY
        (IN TOOL-BENCH)
        (SYNONYM KEY)
        (ADJECTIVE WINDING TINY BRASS)
        (DESC "tiny brass winding key")
        (LDESC "There is a tiny brass winding key on the nutcracker's back.")
        (FLAGS TAKEBIT NDESCBIT)
        (SIZE 2)
        (ACTION BERTRAND-KEY-F)>

<OBJECT VARNISH-POT
        (IN TOOL-BENCH)
        (SYNONYM POT VARNISH)
        (ADJECTIVE STICKY VARNISH UNSETTLED)
        (DESC "pot of varnish")
        (LDESC "A pot of varnish sits open, its contents gone tacky.")
        (FLAGS CONTBIT OPENBIT SURFACEBIT)
        (ACTION VARNISH-POT-F)>

<OBJECT TOOL-RACK
        (IN TOOL-BENCH)
        (SYNONYM RACK TOOLS)
        (ADJECTIVE WOODEN TOOL)
        (DESC "tool rack")
        (LDESC "A wooden rack of tools hangs on the wall — chisels, files, tiny hammers.")
        (FLAGS NDESCBIT)
        (ACTION TOOL-RACK-F)>

<OBJECT MAKESHIFT-STEPS
        (IN TOOL-BENCH)
        (SYNONYM STEPS STAIRCASE CRATE CHAIR BOOK BOOKS STACK ROUTE)
        (ADJECTIVE MAKESHIFT LOW OLD REPAIR BROAD CLIMBING)
        (DESC "makeshift climbing steps")
        (LDESC "A low crate leads to an old chair, where three broad repair books make the final steps to the countertop.")
        (FLAGS NDESCBIT CLIMBBIT)
        (ACTION MAKESHIFT-STEPS-F)>
; === OBJECTS: WORKBENCH TOP ===

<OBJECT REPAIR-BOOK
        (IN WORKBENCH-TOP)
        (SYNONYM BOOK MANUAL GUIDE ALBUM)
        (ADJECTIVE REPAIR ILLUSTRATED TOLLIVER LEATHER GREEN)
        (DESC "illustrated repair book")
        (LDESC "Tolliver's enormous green leather repair book rests closed beside a toy sailboat.")
        (FLAGS CONTBIT OPENABLEBIT READBIT NDESCBIT)
        (ACTION REPAIR-BOOK-F)>

<OBJECT HALF-FINISHED-TOYS
        (IN WORKBENCH-TOP)
        (SYNONYM TOYS SAILBOAT BOAT TRAIN DUCK)
        (ADJECTIVE HALF-FINISHED WOODEN TOY)
        (DESC "half-finished toys")
        (LDESC "A half-rigged sailboat, a wooden train, and a duck with only one wheel wait beneath the work lamp.")
        (FLAGS NDESCBIT)
        (ACTION HALF-FINISHED-TOYS-F)>
; === OBJECTS: COUNTERTOP ===

<OBJECT MARZIPAN
        (IN COUNTERTOP)
        (SYNONYM DOLL RAGDOLL MARZIPAN)
        (ADJECTIVE RAG ONE-EYED PATCHED)
        (DESC "one-eyed rag doll")
        (LDESC "A rag doll with one button eye sits against the window, humming softly.")
        (DESCFCN MARZIPAN-DESC-F)
        (FLAGS ACTORBIT)
        (ACTION MARZIPAN-F)>

<OBJECT DISPLAY-CASE
        (IN COUNTERTOP)
        (SYNONYM CASE DISPLAY CABINET)
        (ADJECTIVE DUSTY GLASS DISPLAY)
        (DESC "dusty glass display case")
        (LDESC "A dusty glass display case holds forgotten treasures.")
        (FLAGS CONTBIT OPENABLEBIT TRANSBIT)
        (ACTION DISPLAY-CASE-F)>

<OBJECT TIN-SOLDIER
        (IN DISPLAY-CASE)
        (SYNONYM SOLDIER TIN-FIGURE FIGURE)
        (ADJECTIVE TIN BRAVE RUSTED)
        (DESC "tin soldier")
        (FDESC "A brave tin soldier stands inside the case, slightly rusted but still at attention.")
        (LDESC "A brave tin soldier, slightly rusted but still standing.")
        (FLAGS TAKEBIT)
        (SIZE 5)
        (ACTION TIN-SOLDIER-F)>

<OBJECT MUSIC-BOX
        (IN DISPLAY-CASE)
        (SYNONYM BOX)
        (ADJECTIVE MUSIC SILVER TINY)
        (DESC "silver music box")
        (FDESC "A small silver music box with a tiny crank on its side.")
        (LDESC "A silver music box with a tiny crank.")
        (FLAGS TAKEBIT TURNBIT)
        (SIZE 4)
        (ACTION MUSIC-BOX-F)>

<OBJECT SHOP-WINDOW
        (IN COUNTERTOP)
        (SYNONYM WINDOW)
        (ADJECTIVE FROSTED GLASS SHOP)
        (DESC "frosted shop window")
        (LDESC "Through the frosted window, you can see the snowy street outside.")
        (FLAGS NDESCBIT)
        (ACTION SHOP-WINDOW-F)>

<OBJECT BUTTON
        (IN COUNTERTOP)
        (SYNONYM BUTTON)
        (ADJECTIVE SPARE BLACK)
        (DESC "spare button")
        (LDESC "A spare button lies near the rag doll. It would make a perfect second eye.")
        (FLAGS TAKEBIT)
        (SIZE 1)
        (ACTION TOY-BUTTON-F)>

; === OBJECTS: STORAGE-LOFT ===

<OBJECT OLD-TICK
        (IN STORAGE-LOFT)
        (SYNONYM CLOCK CUCKOO TICK)
        (ADJECTIVE OLD DUSTY)
        (DESC "old cuckoo clock")
        (LDESC "An old cuckoo clock, dusty and still, its hands frozen at five to midnight.")
        (DESCFCN OLD-TICK-DESC-F)
        (FLAGS ACTORBIT)
        (ACTION OLD-TICK-F)>

<OBJECT TOY-BOX
        (IN STORAGE-LOFT)
        (SYNONYM BOX CARTON)
        (ADJECTIVE DUSTY CARDBOARD TOY)
        (DESC "dusty cardboard box")
        (LDESC "A cardboard box labelled 'Broken - For Repair' sits in the corner.")
        (FLAGS CONTBIT OPENABLEBIT)
        (ACTION TOY-BOX-F)>

<OBJECT DOLL-ARM
        (IN TOY-BOX)
        (SYNONYM ARM DOLL-ARM LIMB)
        (ADJECTIVE PORCELAIN DOLL DELICATE)
        (DESC "porcelain doll arm")
        (FDESC "A delicate porcelain doll arm, separated from its owner.")
        (LDESC "A delicate porcelain doll arm rests among the broken toys.")
        (FLAGS TAKEBIT)
        (SIZE 2)
        (ACTION DOLL-ARM-F)>

<OBJECT TOLLIVER-JOURNAL
        (IN STORAGE-LOFT)
        (SYNONYM JOURNAL DIARY BOOK NOTEBOOK)
        (ADJECTIVE LEATHER OLD TOLLIVER)
        (DESC "leather journal")
        (FDESC "An old leather journal lies among the dust, Grandfather Tolliver's name embossed on the cover.")
        (LDESC "An old leather journal with Tolliver's name on the cover lies in the dust.")
        (FLAGS TAKEBIT READBIT)
        (SIZE 5)
        (TEXT "October 14th — The workshop key grows weaker. I must wind it more often now. The magic in this town depends on it. October 20th — Old Tick tells me the heart of the workshop needs attention. I will attend to it tonight. October 21st — I could not reach the heart alone. Something blocks the way. I must find another path. The toys need me. Pip needs me.")
        (ACTION TOLLIVER-JOURNAL-F)>

<OBJECT COBWEBS
        (IN STORAGE-LOFT)
        (SYNONYM COBWEBS WEBS DUST)
        (ADJECTIVE DUSTY GREY)
        (DESC "dusty cobwebs")
        (LDESC "Dusty cobwebs drape the rafters like grey curtains.")
        (FLAGS NDESCBIT)
        (ACTION COBWEBS-F)>

; === OBJECTS: SNOWY-ALLEY ===

<OBJECT FOOTPRINTS
        (IN SNOWY-ALLEY)
        (SYNONYM FOOTPRINTS PRINTS TRACKS PAWPRINTS)
        (ADJECTIVE FOX TINY MUDDY)
        (DESC "tiny fox footprints")
        (LDESC "Tiny fox footprints lead east through the fresh snow. They are unmistakeably toy-sized.")
        (FLAGS NDESCBIT)
        (ACTION FOOTPRINTS-F)>

<OBJECT STREETLAMP
        (IN SNOWY-ALLEY)
        (SYNONYM STREETLAMP LAMP LIGHT LANTERN)
        (ADJECTIVE FLICKERING TOY)
        (DESC "toy streetlamp")
        (LDESC "A streetlamp — actually a repurposed toy lantern — flickers overhead on a pole.")
        (FLAGS LIGHTBIT NDESCBIT)
        (ACTION STREETLAMP-F)>

<OBJECT SNOW
        (IN SNOWY-ALLEY)
        (SYNONYM SNOW BLANKET)
        (ADJECTIVE FRESH DEEP COLD)
        (DESC "fresh snow")
        (LDESC "Fresh snow blankets the cobblestones. It sparkles in the moonlight.")
        (FLAGS NDESCBIT)
        (ACTION SNOW-F)>

; === OBJECTS: CLOCK-SQUARE ===

<OBJECT CLOCK-TOWER
        (IN CLOCK-SQUARE)
        (SYNONYM TOWER CLOCK BUILDING)
        (ADJECTIVE GIANT STONE CLOCK)
        (DESC "giant clock tower")
        (FDESC "The clock tower dominates the square, its great face showing the hours until dawn with unnerving clarity.")
        (LDESC "The clock tower dominates the square, its great face tracking the approach of dawn.")
        (ACTION CLOCK-TOWER-F)>

<OBJECT CLOCK-WINDING
        (IN CLOCK-SQUARE)
        (SYNONYM MECHANISM WINDING KEYHOLE)
        (ADJECTIVE BRASS)
        (DESC "brass winding mechanism")
        (LDESC "A brass winding mechanism sits at the clock tower's base, just out of reach.")
        (FLAGS TURNBIT)
        (ACTION CLOCK-WINDING-F)>

<OBJECT BAKER-TOY
        (IN CLOCK-SQUARE)
        (SYNONYM BAKER TOY FIGURE)
        (ADJECTIVE WOODEN)
        (DESC "wooden baker toy")
        (LDESC "A wooden baker toy stands in the bakery window, frozen mid-knead.")
        (FLAGS NDESCBIT)
        (ACTION BAKER-TOY-F)>

<OBJECT TOY-LAMPS
        (IN CLOCK-SQUARE)
        (SYNONYM LAMPS LIGHTS)
        (ADJECTIVE TIN TOY DIM)
        (DESC "tin toy lamps")
        (LDESC "Tin toy lamps dot the cobblestones, their light weak and flickering.")
        (FLAGS LIGHTBIT NDESCBIT)
        (ACTION TOY-LAMPS-F)>

; === OBJECTS: MAILBOX-CORNER ===

<OBJECT MAILBOX
        (IN MAILBOX-CORNER)
        (SYNONYM MAILBOX BOX POSTBOX)
        (ADJECTIVE RED TIN TALKING)
        (DESC "red tin mailbox")
        (FDESC "A red tin mailbox tilts slightly into the snow. Its flap hangs open — and every now and then, it seems to shiver.")
        (LDESC "A red tin mailbox tilts into the snow, its flap moving occasionally like a mouth.")
        (FLAGS CONTBIT OPENBIT ACTORBIT)
        (ACTION MAILBOX-F)>

<OBJECT LETTER
        (IN MAILBOX-CORNER)
        (SYNONYM LETTER ENVELOPE NOTE)
        (ADJECTIVE CRUMPLED WHITE)
        (DESC "crumpled letter")
        (LDESC "A crumpled envelope lies half-buried in the snow.")
        (FLAGS TAKEBIT READBIT)
        (SIZE 2)
        (TEXT "My dear Pip — The heart is failing. I must go and mend it myself. Do not worry. Take care of the toys while I am gone. Wind the key at midnight if I do not return. — Grandfather Tolliver")
        (ACTION LETTER-F)>

<OBJECT SCARF
        (IN MAILBOX-CORNER)
        (SYNONYM SCARF)
        (ADJECTIVE RED WOOL WARM)
        (DESC "red wool scarf")
        (LDESC "A red wool scarf lies abandoned in the snow. It looks warm.")
        (FLAGS TAKEBIT)
        (SIZE 3)
        (ACTION SCARF-F)>

<OBJECT MAILBOX-LETTERS
        (IN MAILBOX)
        (SYNONYM LETTERS MAIL BUNDLE)
        (ADJECTIVE UNSENT OLD)
        (DESC "bundle of letters")
        (LDESC "A bundle of unsent letters sits inside the mailbox. They are addressed to toys — invitations to birthday parties, thank-you notes, letters from children long grown up.")
        (FLAGS NDESCBIT)
        (ACTION MAILBOX-LETTERS-F)>

; === OBJECTS: SCRAP-YARD ===

<OBJECT SCRAP-CART
        (IN SCRAP-YARD)
        (SYNONYM CART)
        (ADJECTIVE SCRAP METAL CREAKING)
        (DESC "scrap-metal cart")
        (LDESC "A scrap-metal cart creaks along a track, gathering broken toys into its bed.")
        (DESCFCN SCRAP-CART-DESC-F)
        (FLAGS CONTBIT OPENBIT)
        (ACTION SCRAP-CART-F)>

<OBJECT HEADLESS-DOLL
        (IN SCRAP-CART)
        (SYNONYM DOLL BODY)
        (ADJECTIVE HEADLESS PORCELAIN BROKEN)
        (DESC "headless doll")
        (LDESC "A headless porcelain doll lies in the scrap cart. Its dress is torn, but someone has folded its hands neatly.")
        (FLAGS TAKEBIT)
        (SIZE 4)
        (ACTION HEADLESS-DOLL-F)>

<OBJECT DOLL-HEAD
        (IN SCRAP-YARD)
        (SYNONYM HEAD)
        (ADJECTIVE DOLL PORCELAIN PAINTED)
        (DESC "porcelain doll head")
        (LDESC "A porcelain doll head with painted eyes lies among the scrap. It matches the headless doll.")
        (FLAGS TAKEBIT)
        (SIZE 2)
        (ACTION DOLL-HEAD-F)>

<OBJECT TOY-HORSE
        (IN SCRAP-YARD)
        (SYNONYM HORSE PONY)
        (ADJECTIVE TOY THREE-LEGGED WOODEN)
        (DESC "three-legged horse")
        (LDESC "A toy horse, one leg missing, lies on its side.")
        (FLAGS TAKEBIT)
        (SIZE 6)
        (ACTION TOY-HORSE-F)>

<OBJECT YARD-GATE
        (IN SCRAP-YARD)
        (SYNONYM GATE GATEWAY)
        (ADJECTIVE IRON EAST)
        (DESC "iron gate")
        (LDESC "An iron gate leads east, but the scrap cart blocks the way.")
        (FLAGS NDESCBIT)
        (ACTION YARD-GATE-F)>

; === OBJECTS: FOX-DEN ===

<OBJECT NUTMEG
        (IN FOX-DEN)
        (SYNONYM FOX NUTMEG VIXEN)
        (ADJECTIVE PATCHY STUFFED ORANGE)
        (DESC "patchy fox toy")
        (LDESC "A fox-shaped toy with patchy fur curls in the den, watching you with button eyes.")
        (DESCFCN NUTMEG-DESC-F)
        (FLAGS ACTORBIT)
        (ACTION NUTMEG-F)>

<OBJECT WORKSHOP-KEY
        (IN FOX-DEN)
        (SYNONYM KEY)
        (ADJECTIVE WORKSHOP BRASS TICKING)
        (DESC "workshop key")
        (LDESC "The workshop key hangs from a string around the fox's neck, ticking faintly.")
        (FLAGS TAKEBIT NDESCBIT)
        (SIZE 3)
        (ACTION WORKSHOP-KEY-F)>

<OBJECT RAG-BED
        (IN FOX-DEN)
        (SYNONYM BED NEST RAGS)
        (ADJECTIVE COSY RAG)
        (DESC "cosy rag bed")
        (LDESC "A cosy bed made from rags and twigs fills the centre of the den.")
        (FLAGS CONTBIT OPENBIT SURFACEBIT)
        (ACTION RAG-BED-F)>

<OBJECT TOY-CANDLE
        (IN FOX-DEN)
        (SYNONYM CANDLE FLAME)
        (ADJECTIVE TOY WAX TINY)
        (DESC "toy candle")
        (LDESC "A tiny toy candle burns with a warm, steady flame. It is the only light in the den.")
        (FLAGS LIGHTBIT FLAMEBIT NDESCBIT)
        (ACTION TOY-CANDLE-F)>

<OBJECT STRING-BALL
        (IN FOX-DEN)
        (SYNONYM BALL YARN STRING)
        (ADJECTIVE RED YARN)
        (DESC "ball of yarn")
        (LDESC "A ball of red yarn string sits in the corner. Perfect for a fox to chase.")
        (FLAGS TAKEBIT)
        (SIZE 2)
        (ACTION STRING-BALL-F)>

; === OBJECTS: TOLLIVER-STUDY ===

<OBJECT TOLLIVER-COAT
        (IN TOLLIVER-STUDY)
        (SYNONYM COAT JACKET)
        (ADJECTIVE WORN OLD TOLLIVER)
        (DESC "worn coat")
        (LDESC "Grandfather Tolliver's worn coat hangs on the back of the chair. It still smells like him — wood shavings and old paper.")
        (FLAGS TAKEBIT)
        (SIZE 8)
        (ACTION TOLLIVER-COAT-F)>

<OBJECT TEA-CUP
        (IN TOLLIVER-STUDY)
        (SYNONYM CUP TEA MUG)
        (ADJECTIVE COLD STONE)
        (DESC "cold cup of tea")
        (LDESC "A cup of tea sits beside the inkwell. It is stone cold.")
        (FLAGS TAKEBIT)
        (SIZE 2)
        (ACTION TEA-CUP-F)>

<OBJECT STUDY-DESK
        (IN TOLLIVER-STUDY)
        (SYNONYM DESK TABLE)
        (ADJECTIVE WOODEN CLUTTERED)
        (DESC "cluttered wooden desk")
        (LDESC "A wooden desk is cluttered with papers, diagrams, and an open journal.")
        (FLAGS SURFACEBIT CONTBIT OPENBIT)
        (ACTION STUDY-DESK-F)>

<OBJECT DIAGRAM
        (IN STUDY-DESK)
        (SYNONYM DIAGRAM DRAWING PAPER PLAN)
        (ADJECTIVE WINDING HAND-DRAWN)
        (DESC "winding diagram")
        (FDESC "A hand-drawn diagram of the workshop's inner workings. It shows the hidden heart chamber behind the clock, and instructions for winding it: insert the workshop key, turn clockwise, and if possible, surround the heart with companions whose love the toys remember.")
        (LDESC "A hand-drawn diagram showing the workshop's hidden heart and how to wind it.")
        (FLAGS TAKEBIT READBIT)
        (SIZE 3)
        (ACTION DIAGRAM-F)>

<OBJECT STUDY-JOURNAL
        (IN STUDY-DESK)
        (SYNONYM JOURNAL DIARY BOOK NOTEBOOK)
        (ADJECTIVE FINAL OPEN TOLLIVER)
        (DESC "open journal")
        (FDESC "Tolliver's journal lies open to its final entry.")
        (LDESC "Tolliver's journal lies open to the final entry.")
        (FLAGS TAKEBIT READBIT)
        (SIZE 5)
        (TEXT "I cannot wind the heart alone. The magic has grown weak, and I am old. But Pip — dear Pip — is still small enough to reach the heart chamber. If the key is found, and if Pip has made friends along the way, then perhaps the heart can beat again. I have left the key in the workshop. I only hope it is enough. — G.T.")
        (ACTION STUDY-JOURNAL-F)>

<OBJECT STUDY-CHR
        (IN TOLLIVER-STUDY)
        (SYNONYM CHAIR SEAT)
        (ADJECTIVE WOODEN OLD)
        (DESC "wooden chair")
        (LDESC "An old wooden chair sits behind the desk. Tolliver's coat hangs on its back.")
        (FLAGS NDESCBIT)
        (ACTION STUDY-CHR-F)>

; === OBJECTS: WORKSHOP-HEART ===

<OBJECT HEART-MECH
        (IN WORKSHOP-HEART)
        (SYNONYM MECHANISM HEART CLOCKWORK GEARS)
        (ADJECTIVE GIANT CENTRAL BRASS CLOCKWORK)
        (DESC "workshop heart")
        (FDESC "The workshop's heart — a vast brass mechanism of interlocking gears — stands silent at the centre of the chamber. At its core, a keyhole waits. Around the chamber walls, dozens of toys stand frozen, as if they came here hoping to be rewound.")
        (LDESC "The workshop's heart — a giant clockwork mechanism — stands silent and still.")
        (ACTION HEART-MECH-F)>

<OBJECT KEY-SLOT
        (IN HEART-MECH)
        (SYNONYM SLOT KEYHOLE HOLE)
        (ADJECTIVE BRASS KEY)
        (DESC "brass keyhole")
        (LDESC "A brass keyhole gleams at the heart mechanism's centre. It is exactly the right size for the workshop key.")
        (FLAGS NDESCBIT)
        (ACTION KEY-SLOT-F)>

<OBJECT SILENT-TOYS
        (IN WORKSHOP-HEART)
        (SYNONYM TOYS FIGURES WITNESSES)
        (ADJECTIVE SILENT MOTIONLESS FROZEN)
        (DESC "silent toys")
        (LDESC "Dozens of toys stand motionless around the heart, waiting for the magic to return.")
        (FLAGS NDESCBIT)
        (ACTION SILENT-TOYS-F)>

; === LOCAL-GLOBALS ===

<OBJECT BAKERY
    (IN LOCAL-GLOBALS)
    (SYNONYM BAKERY SHOP SHOPFRONT)
    (ADJECTIVE ABANDONED OLD)
    (DESC "bakery")
    (FLAGS NDESCBIT)
    (ACTION BAKERY-F)>

<OBJECT WORKSHOP-BUILDING
    (IN LOCAL-GLOBALS)
    (SYNONYM BUILDING WORKSHOP SHOP)
    (ADJECTIVE OLD COSY TOY)
    (DESC "workshop building")
    (FLAGS NDESCBIT)
    (ACTION WORKSHOP-BUILDING-F)>

<OBJECT MOON
    (IN LOCAL-GLOBALS)
    (SYNONYM MOON SKY)
    (ADJECTIVE WINTER BRIGHT)
    (DESC "winter moon")
    (FLAGS NDESCBIT)
    (ACTION MOON-F)>

<OBJECT COBBLER
    (IN LOCAL-GLOBALS)
    (SYNONYM COBBLER SHOP SHOPFRONT)
    (ADJECTIVE OLD ABANDONED)
    (DESC "cobbler's shop")
    (FLAGS NDESCBIT)
    (ACTION COBBLER-F)>

; === TOPIC OBJECTS (for ASK/TELL interaction) ===

<OBJECT TOPIC-TOLLIVER
    (IN LOCAL-GLOBALS)
    (SYNONYM TOLLIVER GRANDFATHER MAKER TOYMAKER)
    (ADJECTIVE OLD KIND)
    (DESC "Grandfather Tolliver")
    (FLAGS NDESCBIT)>

<OBJECT TOPIC-KEY
    (IN LOCAL-GLOBALS)
    (SYNONYM KEY)
    (ADJECTIVE WORKSHOP MAGIC)
    (DESC "workshop key")
    (FLAGS NDESCBIT)>

<OBJECT TOPIC-FOX
    (IN LOCAL-GLOBALS)
    (SYNONYM FOX NUTMEG)
    (ADJECTIVE PATCHY LONELY)
    (DESC "the fox")
    (FLAGS NDESCBIT)>

<OBJECT TOPIC-HEART
    (IN LOCAL-GLOBALS)
    (SYNONYM HEART MAGIC)
    (ADJECTIVE WORKSHOP CLOCKWORK)
    (DESC "workshop heart")
    (FLAGS NDESCBIT)>
