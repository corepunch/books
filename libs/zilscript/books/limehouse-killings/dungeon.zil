<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT>
<VERSION ZIP>
<CONSTANT RELEASEID 1>

; === GLOBAL FLAGS ===

<GLOBAL GAME-WON <>>
<GLOBAL GAME-LOST <>>
<GLOBAL GAME-ENDED <>>
<GLOBAL STUDY-UNLOCKED <>>
<GLOBAL SECRET-PASSAGE-FOUND <>>
<GLOBAL SECRET-PASSAGE-OPEN <>>
<GLOBAL CIPHER-SOLVED <>>
<GLOBAL CIPHER-STAGE 0>
<GLOBAL POISON-IDENTIFIED <>>
<GLOBAL KILLER-ACCUSED <>>
<GLOBAL CORRECT-ACCUSATION <>>
<GLOBAL INSPECTOR-PRESENT <>>
<GLOBAL EVIDENCE-FOUND 0>
<GLOBAL SUSPECTS-INTERVIEWED 0>
<GLOBAL HUDSON-INTERVIEWED <>>
<GLOBAL LADY-INTERVIEWED <>>
<GLOBAL MORIARTY-INTERVIEWED <>>
<GLOBAL HUDSON-KEY-GIVEN <>>
<GLOBAL HUDSON-MOTIVE-REVEALED <>>
<GLOBAL LADY-ALIBI-CLAIMED <>>
<GLOBAL MORIARTY-POISON-KNOWN <>>
<GLOBAL DEAD-LETTER-FOUND <>>
<GLOBAL KNIFE-FOUND <>>
<GLOBAL LOCKED-BOX-OPENED <>>
<GLOBAL POISON-BOTTLE-FOUND <>>
<GLOBAL SECRET-LEDGER-FOUND <>>
<GLOBAL BANK-STATEMENT-FOUND <>>
<GLOBAL PLAYER-HEALTH 3>
<GLOBAL CASE-ACT 1>
<GLOBAL HUDSON-CONFRONTED <>>
<GLOBAL LADY-CONFRONTED <>>
<GLOBAL MORIARTY-CONFRONTED <>>
<GLOBAL BOX-CLUE-SEEN <>>
<GLOBAL LETTER-PRESENTED <>>
<GLOBAL POISON-PRESENTED <>>
<GLOBAL MOTIVE-PRESENTED <>>
<GLOBAL FOOTPRINT-DETAIL-FOUND <>>
<GLOBAL CABINET-CLUE-SEEN <>>
<GLOBAL WRONG-ATTEMPTS 0>
<GLOBAL BELL-WIRE-PULLED <>>
<GLOBAL GATE-SEEN <>>
<GLOBAL HALL-SEEN <>>
<GLOBAL STUDY-SEEN <>>
<GLOBAL LIBRARY-SEEN <>>
<GLOBAL GARDEN-SEEN <>>
<GLOBAL DINING-SEEN <>>
<GLOBAL KITCHEN-SEEN <>>
<GLOBAL GREENHOUSE-SEEN <>>
<GLOBAL SERVANTS-SEEN <>>
<GLOBAL PASSAGE-SEEN <>>
<GLOBAL PANTRY-SEEN <>>
<GLOBAL SCORE-MAX 65>
<GLOBAL RANKINGS
    <LTABLE "Bystander"
         "Witness"
         "Investigator"
         "Detective"
         "Master Detective">>

; === ROOMS ===

<ROOM ASHWORTH-MANOR-GATE
      (IN ROOMS)
      (DESC "Ashworth Manor Gate")
      (ACTION GATE-FCN)
      (NORTH TO ASHWORTH-ENTRANCE-HALL)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL FOG GATES PATH)>

<ROOM ASHWORTH-ENTRANCE-HALL
      (IN ROOMS)
      (DESC "Ashworth Manor Entrance Hall")
      (ACTION ENTRANCE-HALL-FCN)
      (NORTH TO STUDY IF STUDY-DOOR IS OPEN ELSE "The study door is closed.")
      (SOUTH TO ASHWORTH-MANOR-GATE)
      (EAST TO LIBRARY)
      (WEST TO DINING-ROOM)
      (DOWN TO KITCHEN)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL CHANDELIER PORTRAITS RUG STUDY-DOOR BELL-WIRE FOG)>

<ROOM STUDY
      (IN ROOMS)
      (DESC "Study")
      (ACTION STUDY-FCN)
      (SOUTH TO ASHWORTH-ENTRANCE-HALL IF STUDY-DOOR IS OPEN ELSE "The study door is closed.")
      (WEST TO GARDEN IF WINDOW IS OPEN ELSE "The window is closed.")
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL DESK FIREPLACE WINDOW CHALK-OUTLINE STUDY-DOOR FOG)>

<ROOM LIBRARY
      (IN ROOMS)
      (DESC "Library")
      (ACTION LIBRARY-FCN)
      (WEST TO ASHWORTH-ENTRANCE-HALL)
      (EAST TO SECRET-PASSAGE IF CIPHER-SOLVED)
      (SOUTH TO SECRET-PASSAGE IF CIPHER-SOLVED)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL BOOKSHELF READING-DESK FIREPLACE COLORED-MARKERS FOG)>

<ROOM DINING-ROOM
      (IN ROOMS)
      (DESC "Dining Room")
      (ACTION DINING-ROOM-FCN)
      (EAST TO ASHWORTH-ENTRANCE-HALL)
      (NORTH TO PANTRY)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL TABLE PORTRAITS WINE-CABINET FOG)>

<ROOM KITCHEN
      (IN ROOMS)
      (DESC "Kitchen")
      (ACTION KITCHEN-FCN)
      (UP TO ASHWORTH-ENTRANCE-HALL)
      (WEST TO GARDEN)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL POTS HEARTH SERVANT-BELL DRAWER KETTLE FOG)>

<ROOM GARDEN
      (IN ROOMS)
      (DESC "Garden")
      (ACTION GARDEN-FCN)
      (EAST TO KITCHEN)
      (NORTH TO GREENHOUSE)
      (SOUTH TO SERVANTS-QUARTERS)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL FOUNTAIN HEDGES BLOOD-STAINED-KNIFE FOG)>

<ROOM GREENHOUSE
      (IN ROOMS)
      (DESC "Greenhouse")
      (ACTION GREENHOUSE-FCN)
      (SOUTH TO GARDEN)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL PLANTS LABELS BENCH FOG)>

<ROOM SERVANTS-QUARTERS
      (IN ROOMS)
      (DESC "Servants' Quarters")
      (ACTION SERVANTS-QUARTERS-FCN)
      (NORTH TO GARDEN)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL BEDS TRUNK UNIFORMS MR-HUDSON FOG)>

<ROOM SECRET-PASSAGE
      (IN ROOMS)
      (DESC "Secret Passage")
      (ACTION SECRET-PASSAGE-FCN)
      (WEST TO LIBRARY)
      (EAST TO STUDY)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL STONE-WALLS COBWEBS DUST FOG)>

<ROOM PANTRY
      (IN ROOMS)
      (DESC "Pantry")
      (ACTION PANTRY-FCN)
      (SOUTH TO DINING-ROOM)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL SHELVES FOXGLOVE CHARCOAL FOG)>

; === OBJECTS ===

<OBJECT TELEGRAM
      (IN ASHWORTH-MANOR-GATE)
      (DESC "creased telegram")
      (FDESC "A creased telegram has been pinned beneath a stone beside the open gate.")
      (LDESC "The rain-spotted telegram bears Lady Ashworth's hand and a hurried postscript.")
      (SYNONYM TELEGRAM MESSAGE WIRE)
      (ADJECTIVE CREASED RAIN-SPOTTED)
      (FLAGS TAKEBIT READBIT)
      (ACTION TELEGRAM-F)>

<OBJECT STUDY-DOOR
      (IN LOCAL-GLOBALS)
      (DESC "study door")
      (LDESC "A solid oak door separates the entrance hall from the study. Its brass lock is old but substantial.")
      (SYNONYM DOOR ENTRANCE)
      (ADJECTIVE STUDY OAK SOUTH)
      (FLAGS DOORBIT NDESCBIT)
      (ACTION STUDY-DOOR-F)>

; --- Evidence Objects ---

<OBJECT DEAD-LETTER
      (IN STUDY)
      (DESC "unsent letter")
      (FDESC "A yellowed envelope lies among the papers on the desk, addressed in a shaking hand.")
      (LDESC "An unsent letter, its paper yellowed with age. The ink is faded but legible, the words a threat from one man to another. The seal is broken, the wax still bearing the initial 'M.'")
      (SYNONYM LETTER NOTE PAPER DEAD-LETTER)
      (ADJECTIVE DEAD UNSENT)
      (FLAGS TAKEBIT READBIT)
      (ACTION DEAD-LETTER-F)>

<OBJECT BLOOD-STAINED-KNIFE
      (IN GARDEN)
      (DESC "blood-stained knife")
      (FDESC "Something glints in the branches near the fountain -- a knife, its blade dark with dried blood.")
      (LDESC "A sharp blade, its edge stained with dried blood. The handle bears the mark of a surgical instrument, the kind used by doctors and scientists.")
      (SYNONYM KNIFE BLADE WEAPON BLOOD-STAINED-KNIFE)
      (ADJECTIVE BLOOD STAINED)
      (FLAGS TAKEBIT WEAPONBIT)
      (ACTION BLOOD-STAINED-KNIFE-F)>

<OBJECT LOCKED-BOX
      (IN STUDY)
      (DESC "locked box")
      (DESCFCN LOCKED-BOX-DESC-F)
      (SYNONYM BOX CONTAINER)
      (ADJECTIVE LOCKED)
      (FLAGS CONTBIT SEARCHBIT TURNBIT)
      (ACTION LOCKED-BOX-F)>

<OBJECT POISON-BOTTLE
      (IN STUDY)
      (DESC "poison bottle")
      (FDESC "A small glass bottle with a faded label sits on the mantelpiece, its contents clear and deadly.")
      (LDESC "A small glass bottle, its label reading 'Aconitum - Wolfsbane. Highly poisonous.' The liquid inside is clear, its lethality hidden in plain sight.")
      (SYNONYM BOTTLE VIAL POISON-BOTTLE)
      (ADJECTIVE POISON)
      (FLAGS TAKEBIT READBIT)
      (ACTION POISON-BOTTLE-F)>

<OBJECT SECRET-LEDGER
      (IN LIBRARY)
      (DESC "secret ledger")
      (FDESC "A leather-bound ledger lies open on the reading desk, its pages filled with coded entries.")
      (LDESC "A leather-bound book, its pages filled with numbers and names. Financial records that tell a story of debt and desperation.")
      (SYNONYM LEDGER BOOK ACCOUNT)
      (ADJECTIVE SECRET)
      (FLAGS TAKEBIT READBIT)
      (ACTION SECRET-LEDGER-F)>

; --- Tool Objects ---

<OBJECT MAGNIFYING-GLASS
      (IN ASHWORTH-ENTRANCE-HALL)
      (DESC "magnifying glass")
      (FDESC "A magnifying glass rests on the hall table, its brass handle worn smooth.")
      (LDESC "A brass magnifying glass, its lens clear and strong. Useful for examining small details that the naked eye might miss.")
      (SYNONYM GLASS LENS MAGNIFIER)
      (ADJECTIVE MAGNIFYING)
      (FLAGS TAKEBIT)
      (ACTION MAGNIFYING-GLASS-F)>

<OBJECT LEATHER-ROLL
      (IN DRAWER)
      (DESC "leather roll")
      (FDESC "A leather roll lies in the open drawer, its contents glinting steel.")
      (LDESC "A roll of soft leather, neatly tied. Something metallic shifts inside.")
      (SYNONYM ROLL WRAP)
      (ADJECTIVE LEATHER)
      (FLAGS CONTBIT TAKEBIT)
      (CAPACITY 5)
      (SIZE 3)>

<OBJECT LOCKPICK-SET
      (IN LEATHER-ROLL)
      (DESC "lockpick set")
      (LDESC "A set of metal picks, their tips worn from use. Tools of the trade for those who need to open locked doors.")
      (SYNONYM SET PICKS TOOLS LOCKPICK LOCKPICK-SET)
      (ADJECTIVE LOCKPICK BURGLAR BURGLARS)
      (FLAGS TAKEBIT TOOLBIT)
      (ACTION LOCKPICK-SET-F)>

<OBJECT LANTERN
      (IN SERVANTS-QUARTERS)
      (DESC "lantern")
      (FDESC "An oil lantern sits on the trunk, its glass clean and fuel full.")
      (LDESC "A brass lantern kept scrupulously clean and full. Hudson has etched each former servant's initial beneath its base.")
      (SYNONYM LAMP LIGHT LANTERN)
      (ADJECTIVE OIL BRASS)
      (FLAGS TAKEBIT LIGHTBIT)
      (ACTION LANTERN-F)>

<OBJECT KEYRING
      (IN MR-HUDSON)
      (DESC "keyring")
      (LDESC "A ring of keys, each one opening a different lock. The study key hangs among them, waiting to be used.")
      (SYNONYM KEYRING KEYS KEY)
      (FLAGS TAKEBIT TOOLBIT)
      (ACTION KEYRING-F)>

; --- Clue Objects ---

<OBJECT TORN-PAGE
      (IN LIBRARY)
      (DESC "torn page")
      (FDESC "A torn page lies on the reading desk, covered in handwritten notes.")
      (LDESC "A fragment of paper, its edges ragged. The text reads: 'Among the marked books, follow the rainbow order: red, yellow, green, blue. Only then will the way open.'")
      (SYNONYM PAGE FRAGMENT TORN-PAGE)
      (ADJECTIVE TORN)
      (FLAGS TAKEBIT READBIT)
      (ACTION TORN-PAGE-F)>

<OBJECT COLORED-MARKERS
      (IN LIBRARY)
      (DESC "colored markers")
      (LDESC "Small ribbons of color, tied to the bookshelves. Red, blue, green, and yellow markers suggest an organizational system.")
      (SYNONYM MARKERS RIBBONS TAGS)
      (ADJECTIVE COLORED COLOURED)
      (FLAGS NDESCBIT)
      (ACTION COLORED-MARKERS-F)>

<OBJECT FOOTPRINT-CAST
      (IN GARDEN)
      (DESC "footprint cast")
      (FDESC "A plaster cast of a footprint sits near the fountain, preserving the evidence.")
      (LDESC "A plaster cast of a boot print, size 10. Too large for Lady Ashworth, too small for Mr. Hudson.")
      (SYNONYM FOOTPRINT-CAST CAST MOLD FOOTPRINT IMPRESSION)
      (ADJECTIVE FOOTPRINT PLASTER)
      (FLAGS TAKEBIT)
      (ACTION FOOTPRINT-CAST-F)>

<OBJECT WAX-SEAL
      (IN DINING-ROOM)
      (DESC "wax seal")
      (FDESC "A crimson wax seal rests on the dining table, pressed with an unknown sigil.")
      (LDESC "A broken wax seal, its surface bearing the initial 'M.' The mark of Dr. Moriarty.")
      (SYNONYM SEAL STAMP WAX-SEAL)
      (ADJECTIVE WAX)
      (FLAGS TAKEBIT)
      (ACTION WAX-SEAL-F)>

<OBJECT BANK-STATEMENT
      (IN LOCKED-BOX)
      (DESC "bank statement")
      (FDESC "A bank statement rests inside the opened box.")
      (LDESC "A financial statement showing Dr. Moriarty's account overdrawn. A large withdrawal for 'experimental supplies' catches your eye.")
      (SYNONYM STATEMENT RECEIPT BANK-STATEMENT)
      (ADJECTIVE BANK)
      (FLAGS TAKEBIT READBIT)
      (ACTION BANK-STATEMENT-F)>

; --- Furniture/Scenery Objects ---

<OBJECT DESK
      (IN STUDY)
      (DESC "mahogany desk")
      (LDESC "A mahogany desk, its surface scarred with use. Three drawers, one locked, contain the remnants of Lord Ashworth's work.")
      (SYNONYM DESK)
      (ADJECTIVE MAHOGANY)
      (FLAGS NDESCBIT)
      (ACTION DESK-F)>

<OBJECT FIREPLACE
      (IN STUDY)
      (DESC "fireplace")
      (LDESC "A stone fireplace, its hearth cold. Ashes and a locked box remain from the last fire.")
      (SYNONYM FIREPLACE HEARTH)
      (FLAGS NDESCBIT)
      (ACTION FIREPLACE-F)>

<OBJECT WINDOW
      (IN STUDY)
      (DESC "window")
      (LDESC "A tall window, its glass clouded with age. The latch is rusted but intact, looking out to the garden.")
      (SYNONYM WINDOW GLASS LATCH)
      (FLAGS NDESCBIT)
      (ACTION WINDOW-F)>

<OBJECT BOOKSHELF
      (IN LIBRARY)
      (DESC "bookshelf")
      (LDESC "Floor-to-ceiling shelves, filled with books of every description. Colored markers dot the spines, suggesting a hidden pattern.")
      (SYNONYM BOOKSHELF SHELVES)
      (FLAGS NDESCBIT)
      (ACTION BOOKSHELF-F)>

<OBJECT READING-DESK
      (IN LIBRARY)
      (DESC "reading desk")
      (LDESC "A wooden desk, its surface scattered with papers. A torn page lies among them, its message waiting to be read.")
      (SYNONYM DESK)
      (ADJECTIVE READING)
      (FLAGS NDESCBIT)
      (ACTION READING-DESK-F)>

; Distinct marked books let the parser track the documented color sequence.
<OBJECT RED-BOOK
      (IN LIBRARY)
      (DESC "red-marked book")
      (SYNONYM BOOK)
      (ADJECTIVE RED)
      (FLAGS NDESCBIT)
      (ACTION CIPHER-BOOK-F)>

<OBJECT BLUE-BOOK
      (IN LIBRARY)
      (DESC "blue-marked book")
      (SYNONYM BOOK)
      (ADJECTIVE BLUE)
      (FLAGS NDESCBIT)
      (ACTION CIPHER-BOOK-F)>

<OBJECT GREEN-BOOK
      (IN LIBRARY)
      (DESC "green-marked book")
      (SYNONYM BOOK)
      (ADJECTIVE GREEN)
      (FLAGS NDESCBIT)
      (ACTION CIPHER-BOOK-F)>

<OBJECT YELLOW-BOOK
      (IN LIBRARY)
      (DESC "yellow-marked book")
      (SYNONYM BOOK)
      (ADJECTIVE YELLOW)
      (FLAGS NDESCBIT)
      (ACTION CIPHER-BOOK-F)>

<OBJECT TABLE
      (IN DINING-ROOM)
      (DESC "dining table")
      (LDESC "A long dining table, set for two but used by only one. Wax seals and place settings tell a story of interrupted meals.")
      (SYNONYM TABLE)
      (ADJECTIVE DINING)
      (FLAGS NDESCBIT)
      (ACTION TABLE-F)>

<OBJECT WINE-CABINET
      (IN DINING-ROOM)
      (DESC "wine cabinet")
      (LDESC "A glass-fronted cabinet stands unlatched. One bottle-shaped gap interrupts the dust on its medicinal-wine shelf.")
      (SYNONYM CABINET WINE-CABINET)
      (ADJECTIVE WINE)
      (FLAGS NDESCBIT CONTBIT SEARCHBIT)
      (ACTION WINE-CABINET-F)>

<OBJECT POTS
      (IN KITCHEN)
      (DESC "copper pots")
      (LDESC "Copper pots, tarnished with age, hang from the kitchen ceiling. They have cooked many meals, but none recently.")
      (SYNONYM POTS)
      (ADJECTIVE COPPER)
      (FLAGS NDESCBIT)
      (ACTION POTS-F)>

<OBJECT HEARTH
      (IN KITCHEN)
      (DESC "cold hearth")
      (LDESC "A stone hearth, cold and empty. The last fire burned long ago.")
      (SYNONYM HEARTH)
      (ADJECTIVE COLD)
      (FLAGS NDESCBIT)
      (ACTION HEARTH-F)>

<OBJECT SERVANT-BELL
      (IN KITCHEN)
      (DESC "servant bell")
      (LDESC "A servant bell, its rope leading up to the servant's quarters. A pull summons the staff.")
      (SYNONYM BELL ROPE)
      (ADJECTIVE SERVANT)
      (FLAGS NDESCBIT)
      (ACTION SERVANT-BELL-F)>

<OBJECT KETTLE
      (IN LOCAL-GLOBALS)
      (DESC "blue kettle")
      (LDESC "A blue enamel kettle waits on the range, warm enough to mist its spout.")
      (SYNONYM KETTLE POT)
      (ADJECTIVE BLUE ENAMEL)
      (FLAGS NDESCBIT)
      (ACTION KETTLE-F)>

<OBJECT BELL-WIRE
      (IN ASHWORTH-ENTRANCE-HALL)
      (DESC "bell wire")
      (LDESC "A thin servant-bell wire runs beside the study door.")
      (SYNONYM WIRE CORD)
      (ADJECTIVE BELL SERVANT)
      (FLAGS NDESCBIT)
      (ACTION BELL-WIRE-F)>

<OBJECT DRAWER
      (IN KITCHEN)
      (DESC "drawer")
      (LDESC "A drawer in the counter.")
      (SYNONYM DRAWER)
      (FLAGS NDESCBIT CONTBIT SEARCHBIT)
      (CAPACITY 10)
      (ACTION DRAWER-F)>

<OBJECT FOUNTAIN
      (IN GARDEN)
      (DESC "fountain")
      (LDESC "A stone fountain, dry and silent. Coins lie at the bottom, wishes unfulfilled.")
      (SYNONYM FOUNTAIN COINS)
      (FLAGS NDESCBIT)
      (ACTION FOUNTAIN-F)>

<OBJECT HEDGES
      (IN GARDEN)
      (DESC "hedge mazes")
      (LDESC "Tall hedges, their branches thick and tangled. They hide secrets in their shadows.")
      (SYNONYM HEDGES HEDGE BUSHES MAZE MAZES)
      (FLAGS NDESCBIT)
      (ACTION HEDGES-F)>

<OBJECT PLANTS
      (IN GREENHOUSE)
      (DESC "exotic plants")
      (LDESC "Exotic plants from around the world, their leaves and flowers a splash of color in the gray manor.")
      (SYNONYM PLANTS FLOWERS)
      (ADJECTIVE EXOTIC)
      (FLAGS NDESCBIT)
      (ACTION PLANTS-F)>

<OBJECT LABELS
      (IN GREENHOUSE)
      (DESC "plant labels")
      (LDESC "Small labels marking the plants. They identify species and their properties.")
      (SYNONYM LABELS)
      (ADJECTIVE PLANT)
      (FLAGS NDESCBIT)
      (ACTION LABELS-F)>

<OBJECT BENCH
      (IN GREENHOUSE)
      (DESC "potting bench")
      (LDESC "A wooden potting bench, its surface covered in soil and tools. Labels identify the plants it tends.")
      (SYNONYM BENCH)
      (ADJECTIVE POTTING)
      (FLAGS NDESCBIT)
      (ACTION BENCH-F)>

<OBJECT BEDS
      (IN SERVANTS-QUARTERS)
      (DESC "servant beds")
      (LDESC "Simple beds for the household staff, their sheets worn but clean.")
      (SYNONYM BEDS BED)
      (ADJECTIVE SERVANT)
      (FLAGS NDESCBIT)
      (ACTION BEDS-F)>

<OBJECT TRUNK
      (IN SERVANTS-QUARTERS)
      (DESC "trunk")
      (LDESC "A large wooden trunk, its lid heavy.")
      (SYNONYM TRUNK CHEST)
      (FLAGS NDESCBIT CONTBIT OPENBIT SEARCHBIT)
      (CAPACITY 20)>

<OBJECT TRUNK-LETTER
      (IN TRUNK)
      (DESC "folded note")
      (LDESC "A folded letter, its edges worn. The handwriting is small and cramped.")
      (SYNONYM NOTE)
      (ADJECTIVE FOLDED)
      (FLAGS TAKEBIT READBIT)
      (TEXT "The letter is addressed to Mr. Hudson from an unknown sender. It reads: 'The master's experiments have gone too far. If anything happens to me, the evidence is in the study. Burn this after reading.' The signature is illegible.")
      (ACTION TRUNK-LETTER-F)>

<OBJECT UNIFORMS
      (IN TRUNK)
      (DESC "servant uniforms")
      (LDESC "Servant uniforms, their fabric worn from use. They hang on hooks, waiting for their next wearer.")
      (SYNONYM UNIFORMS CLOTHES)
      (ADJECTIVE SERVANT)
      (FLAGS NDESCBIT)
      (ACTION UNIFORMS-F)>

<OBJECT STONE-WALLS
      (IN SECRET-PASSAGE)
      (DESC "stone walls")
      (LDESC "Wet stone walls, slick with moisture. They have stood for centuries.")
      (SYNONYM WALLS WALL)
      (ADJECTIVE STONE)
      (FLAGS NDESCBIT)>

<OBJECT COBWEBS
      (IN SECRET-PASSAGE)
      (DESC "cobwebs")
      (LDESC "Dusty cobwebs fill the air, undisturbed for years.")
      (SYNONYM COBWEBS WEB WEBS)
      (FLAGS NDESCBIT)>

<OBJECT DUST
      (IN SECRET-PASSAGE)
      (DESC "dust")
      (LDESC "A thick layer of dust covers everything. No one has been here in a long time.")
      (SYNONYM DUST)
      (FLAGS NDESCBIT)>

<OBJECT SHELVES
      (IN PANTRY)
      (DESC "pantry shelves")
      (LDESC "Shelves filled with food and wine. Some items are old, others relatively fresh.")
      (SYNONYM SHELVES SHELF)
      (ADJECTIVE PANTRY)
      (FLAGS NDESCBIT)
      (ACTION SHELVES-F)>

<OBJECT FOXGLOVE
      (IN PANTRY)
      (DESC "foxglove")
      (LDESC "A bottle of dried foxglove leaves. The label warns that digitalis may steady a failing heart or stop a healthy one.")
      (SYNONYM FOXGLOVE DIGITALIS)
      (FLAGS TAKEBIT)
      (ACTION FOXGLOVE-F)>

<OBJECT CHARCOAL
      (IN PANTRY)
      (DESC "charcoal")
      (LDESC "A tin of powdered charcoal, labeled for emergency use after swallowed poisons.")
      (SYNONYM CHARCOAL COAL)
      (FLAGS TAKEBIT)
      (ACTION CHARCOAL-F)>

; === GLOBAL OBJECTS ===

<OBJECT FOG
      (IN LOCAL-GLOBALS)
      (DESC "fog")
      (LDESC "Cold river fog curls through the manor gates.")
      (SYNONYM FOG MIST HAZE)
      (FLAGS NDESCBIT)
      (ACTION FOG-F)>

<OBJECT GATES
      (DESC "iron gates")
      (LDESC "The iron gates stand open, their bars red with rust.")
      (SYNONYM GATES GATE BARS)
      (ADJECTIVE IRON)
      (FLAGS NDESCBIT)
      (ACTION GATES-F)>

<OBJECT PATH
      (DESC "gravel path")
      (LDESC "A gravel path leads north through the fog to Ashworth Manor.")
      (SYNONYM PATH WALKWAY DRIVE)
      (ADJECTIVE GRAVEL)
      (FLAGS NDESCBIT)
      (ACTION PATH-F)>

<OBJECT CHANDELIER
      (DESC "chandelier")
      (LDESC "A dusty crystal chandelier hangs above the entrance hall.")
      (SYNONYM CHANDELIER LIGHT CRYSTAL)
      (ADJECTIVE DUSTY)
      (FLAGS NDESCBIT)
      (ACTION CHANDELIER-F)>

<OBJECT PORTRAITS
      (DESC "family portraits")
      (LDESC "Portraits of the Ashworth family line the walls.")
      (SYNONYM PORTRAITS PAINTINGS PICTURES)
      (ADJECTIVE FAMILY)
      (FLAGS NDESCBIT)
      (ACTION PORTRAITS-F)>

<OBJECT RUG
      (DESC "Persian rug")
      (LDESC "A faded Persian rug covers the entrance-hall floor.")
      (SYNONYM RUG CARPET MAT)
      (ADJECTIVE PERSIAN FADED)
      (FLAGS NDESCBIT)
      (ACTION RUG-F)>

<OBJECT CHALK-OUTLINE
      (DESC "chalk outline")
      (LDESC "A chalk outline marks the place where Lord Ashworth's body was found.")
      (SYNONYM CHALK-OUTLINE OUTLINE BODY)
      (ADJECTIVE CHALK)
      (FLAGS NDESCBIT)
      (ACTION CHALK-OUTLINE-F)>

; === NPCs ===

<OBJECT MR-HUDSON
      (IN SERVANTS-QUARTERS)
      (DESC "Mr. Hudson")
      (LDESC "Mr. Hudson, the butler, stands nervously in the servants' quarters. His expression is troubled, his hands fidgeting with a keyring.")
      (SYNONYM HUDSON BUTLER MR-HUDSON)
      (ADJECTIVE MR MISTER)
      (FLAGS ACTORBIT)
      (ACTION MR-HUDSON-F)>

<OBJECT LADY-ASHWORTH
      (IN DINING-ROOM)
      (DESC "Lady Ashworth")
      (LDESC "Lady Ashworth sits at the dining table, her expression cold and calculating. She watches you with sharp eyes.")
      (SYNONYM ASHWORTH WIFE LADY-ASHWORTH)
      (ADJECTIVE LADY)
      (FLAGS ACTORBIT)
      (ACTION LADY-ASHWORTH-F)>

<OBJECT DR-MORIARTY
      (IN LIBRARY)
      (DESC "Dr. Moriarty")
      (LDESC "Dr. Moriarty stands by the bookshelf, his expression arrogant and dismissive. He regards you with cool intelligence.")
      (SYNONYM MORIARTY DR-MORIARTY DOCTOR)
      (ADJECTIVE DR DOCTOR)
      (FLAGS ACTORBIT NDESCBIT)
      (ACTION DR-MORIARTY-F)>

<OBJECT INSPECTOR
      (DESC "Inspector Lestrade")
      (LDESC "Inspector Lestrade of Scotland Yard stands in the entrance hall, his expression professional and skeptical. He waits for your evidence.")
      (SYNONYM LESTRADE OFFICER DETECTIVE POLICE SCOTLAND-YARD YARDMAN)
      (ADJECTIVE SCOTLAND)
      (FLAGS ACTORBIT NDESCBIT ARTICLEBIT)
      (ACTION INSPECTOR-F)>

; Conversation topics are global so ASK ... ABOUT ... can resolve them from
; the listener's room without requiring the referenced person or clue nearby.
<OBJECT MASTER-TOPIC
      (IN GLOBAL-OBJECTS)
      (DESC "master")
      (SYNONYM MASTER)>
<OBJECT ALIBI-TOPIC
      (IN GLOBAL-OBJECTS)
      (DESC "alibi")
      (SYNONYM ALIBI)>
<OBJECT KEY-TOPIC
      (IN GLOBAL-OBJECTS)
      (DESC "key")
      (SYNONYM KEY)>
<OBJECT MORIARTY-TOPIC
      (IN GLOBAL-OBJECTS)
      (DESC "Moriarty")
      (SYNONYM MORIARTY)>
<OBJECT MARRIAGE-TOPIC
      (IN GLOBAL-OBJECTS)
      (DESC "marriage")
      (SYNONYM MARRIAGE)>
<OBJECT EXPERIMENTS-TOPIC
      (IN GLOBAL-OBJECTS)
      (DESC "experiments")
      (SYNONYM EXPERIMENTS RESEARCH)>
<OBJECT POISON-TOPIC
      (IN GLOBAL-OBJECTS)
      (DESC "poison")
      (SYNONYM POISON WOLFSBANE)>
<OBJECT CASE-TOPIC
      (IN GLOBAL-OBJECTS)
      (DESC "investigation")
      (SYNONYM CASE MURDER INVESTIGATION CRIME)>

<GLOBAL HERE ASHWORTH-MANOR-GATE>
