<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>
<VERSION ZIP>
<CONSTANT RELEASEID 1>

; === GLOBAL FLAGS ===

<GLOBAL VALVE-TURNED-FLAG <>>
<GLOBAL STEAM-DOOR-OPEN <>>
<GLOBAL LANTERN-LIT-FLAG <>>
<GLOBAL CHAPEL-UNLOCKED <>>
<GLOBAL CHAINS-CUT-FLAG <>>
<GLOBAL GAME-WON <>>
<GLOBAL PATIENT-STATE 0> ;"0=absent, 1=aware, 2=twitching, 3=liberated"
<GLOBAL PATIENT-LORE 0> ;"count of distinct lore discoveries and first-time topics"
<GLOBAL PATIENT-FILE-LORE <>>
<GLOBAL WALL-SCRATCHES-LORE <>>
<GLOBAL STRAITJACKET-LORE <>>
<GLOBAL BOILER-FUELED <>>
<GLOBAL BOILER-LIT <>>
<GLOBAL BOILER-HEAT 0>
<GLOBAL CABINET-THAWED <>>
<GLOBAL COLD-EXPOSURE 0>
<GLOBAL HINT-KEY 0>
<GLOBAL HINT-LEVEL 0>
<GLOBAL SCORE-MAX 68>
<GLOBAL RANKINGS
    <LTABLE 0
         "Confused Patient"
         "Curious Inmate"
         "Asylum Explorer"
         "Sanitarium Survivor">>
<GLOBAL WHISPER-TABLE
    <LTABLE 0
        "A voice, barely audible, rasps: 'help... me...'"
        "You hear your name whispered -- impossible, you never told anyone you were coming."
        "A child's voice whispers something in a language you don't recognize."
        "The walls seem to breathe a single word: 'run.'">>

; === ROOMS ===

<ROOM SANITARIUM-GATE
      (IN ROOMS)
      (DESC "Sanitarium Gate")
      (LDESC "The rusted iron gates of the abandoned sanitarium stand open, their bars red with rust. The structure looms against the darkening sky, its windows like hollow eye sockets. A gravel path leads north to the entrance.")
      (NORTH TO SANITARIUM-ENTRANCE)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL SANITARIUM-BUILDING DEAD-OAK-TREE)>

<ROOM SANITARIUM-ENTRANCE
      (IN ROOMS)
      (DESC "Sanitarium Entrance Hall")
      (LDESC "The entrance hall reeks of mildew and decay. A grand staircase ascends to darkness in the east. To the west, a doorway leads to what might have been a reception area. A narrow staircase descends into the basement.")
      (SOUTH TO SANITARIUM-GATE)
      (WEST TO RECEPTION-ROOM)
      (NORTH TO OPERATING-THEATER)
      (EAST TO PATIENT-WARD)
      (DOWN TO BASEMENT-STAIRS)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL SANITARIUM-BUILDING DEAD-OAK-TREE)>

<ROOM RECEPTION-ROOM
      (IN ROOMS)
      (DESC "Reception Room")
      (ACTION RECEPTION-ROOM-FCN)
      (LDESC "This cramped room once served as the sanitarium's reception. Filing cabinets line the opposite wall, their drawers hanging open like gaping mouths. A doorway to the east opens back to the entrance hall.")
      (EAST TO SANITARIUM-ENTRANCE)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL FILING-CABINETS)>

<ROOM OPERATING-THEATER
      (IN ROOMS)
      (DESC "Operating Theater")
      (LDESC "The circular theater rises in tiers where students once observed procedures. The air is motionless; even your sleeve brushing the door sounds indecently loud.")
      (SOUTH TO SANITARIUM-ENTRANCE)
      (FLAGS RLANDBIT ONBIT)>

<ROOM PATIENT-WARD
      (IN ROOMS)
      (DESC "Patient Ward")
      (ACTION PATIENT-WARD-FCN)
      (LDESC "A long corridor with tattered curtains hanging between areas, offering the ghost of privacy. The floor is littered with patient records and broken glass.")
      (WEST TO SANITARIUM-ENTRANCE)
      (NORTH TO MORGUE IF CHAINS-CUT-FLAG)
      (FLAGS RLANDBIT ONBIT)>

<ROOM MORGUE
      (IN ROOMS)
      (DESC "Morgue")
      (LDESC "The temperature drops as you enter the morgue. Medical instruments hang on the wall, and condensation beads on drawer handles untouched by your breath. The only exit is a passage leading south to the patient ward.")
      (SOUTH TO PATIENT-WARD)
      (FLAGS RLANDBIT ONBIT)
      (VALUE 10)>

<ROOM BASEMENT-STAIRS
      (IN ROOMS)
      (DESC "Basement Stairs")
      (LDESC "A narrow stone staircase descends into darkness. The air grows colder with each step. Moisture drips from the ceiling, and the walls are slick with condensation. The stairs lead down into the basement, while the entrance hall lies up the stairs.")
      (UP TO SANITARIUM-ENTRANCE)
      (DOWN TO BASEMENT-CORRIDOR)
      (FLAGS RLANDBIT ONBIT)>

<ROOM BASEMENT-CORRIDOR
      (IN ROOMS)
      (DESC "Basement Corridor")
      (ACTION BASEMENT-CORRIDOR-FCN)
      (LDESC "The basement corridor is pitch black, stretching into shadow. Stone stairs climb upward into darkness. To the east, a passage leads toward the sound of dripping water. West lies what might have been storage. North, another corridor descends toward deeper chambers.")
      (UP TO BASEMENT-STAIRS)
      (EAST TO BOILER-ROOM)
      (WEST TO STORAGE-ROOM)
      (NORTH TO FLOODING-CHAMBER)
      (FLAGS RLANDBIT ONBIT)>

<ROOM BOILER-ROOM
      (IN ROOMS)
      (DESC "Boiler Room")
      (ACTION BOILER-ROOM-FCN)
      (WEST TO BASEMENT-CORRIDOR)
      (FLAGS RLANDBIT ONBIT)>

<ROOM STORAGE-ROOM
      (IN ROOMS)
      (DESC "Storage Room")
      (LDESC "This dark storage room is filled with old linens, rusted equipment, and unidentifiable containers in every space. A sour smell permeates the air. The exit lies to the east.")
      (EAST TO BASEMENT-CORRIDOR)
      (FLAGS RLANDBIT ONBIT)>

<ROOM FLOODING-CHAMBER
      (IN ROOMS)
      (DESC "Flooded Chamber")
      (ACTION FLOODING-CHAMBER-FCN)
      (LDESC "The chamber is vast and dark, with arched stone ceilings disappearing into shadow. To the north, a narrow passage disappears into darkness. The corridor lies to the south.")
      (SOUTH TO BASEMENT-CORRIDOR)
      (NORTH TO ISOLATION-WARD)
      (EAST TO HYDROTHERAPY-ROOM IF STEAM-DOOR-OPEN)
      (FLAGS RLANDBIT)>

<ROOM HYDROTHERAPY-ROOM
      (IN ROOMS)
      (DESC "Hydrotherapy Room")
      (ACTION HYDROTHERAPY-ROOM-FCN)
      (WEST TO FLOODING-CHAMBER)
      (FLAGS RLANDBIT)>

<ROOM ISOLATION-WARD
      (IN ROOMS)
      (DESC "Isolation Ward")
      (LDESC "Small cells line both sides of a narrow corridor. Scratches cover the walls—thousands of them, as if someone counted the days. The corridor continues north to the electroshock theater.")
      (SOUTH TO FLOODING-CHAMBER)
      (NORTH TO ELECTROSHOCK-THEATER)
      (FLAGS RLANDBIT)
      (VALUE 5)>

<ROOM ELECTROSHOCK-THEATER
      (IN ROOMS)
      (DESC "Electroshock Theater")
      (LDESC "A concrete room. The walls are scorched in places. A viewing window overlooks the room from above. To the east, a stairway climbs upward. A passage to the south leads out to the isolation ward.")
      (SOUTH TO ISOLATION-WARD)
      (EAST TO OBSERVATION-DECK)
      (WEST TO PADDED-CELL)
      (FLAGS RLANDBIT)
      (VALUE 8)>

<ROOM PADDED-CELL
      (IN ROOMS)
      (DESC "Padded Cell")
      (LDESC "The small room reeks of decay. Something has been written on the walls in what looks like dried blood.")
      (EAST TO ELECTROSHOCK-THEATER)
      (FLAGS RLANDBIT)
      (VALUE 5)>

<ROOM OBSERVATION-DECK
      (IN ROOMS)
      (DESC "Observation Deck")
      (LDESC "A small room with chairs facing a window. This is where doctors watched their experiments. Stairs lead down to the west.")
      (WEST TO ELECTROSHOCK-THEATER)
      (NORTH TO ADMINISTRATIVE-WING)
      (FLAGS RLANDBIT ONBIT)>

<ROOM ADMINISTRATIVE-WING
      (IN ROOMS)
      (DESC "Administrative Wing")
      (LDESC "Offices line a carpeted corridor. Most doors hang open, revealing ransacked rooms. Filing cabinets are overturned. To the east lies the director's office. North leads to the staff quarters. South returns to the observation deck.")
      (SOUTH TO OBSERVATION-DECK)
      (EAST TO DIRECTORS-OFFICE)
      (NORTH TO STAFF-QUARTERS)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL FILING-CABINETS)>

<ROOM DIRECTORS-OFFICE
      (IN ROOMS)
      (DESC "Director's Office")
      (ACTION DIRECTORS-OFFICE-FCN)
      (LDESC "A large office with wood paneling. Bookshelves line the walls, filled with medical texts and journals.")
      (WEST TO ADMINISTRATIVE-WING)
      (FLAGS RLANDBIT ONBIT)>

<ROOM STAFF-QUARTERS
      (IN ROOMS)
      (DESC "Staff Quarters")
      (LDESC "A dormitory with rows of narrow beds. The air smells of mildew and abandonment. To the west is the cafeteria. South returns to the administrative wing.")
      (SOUTH TO ADMINISTRATIVE-WING)
      (WEST TO CAFETERIA)
      (FLAGS RLANDBIT ONBIT)>

<ROOM CAFETERIA
      (IN ROOMS)
      (DESC "Cafeteria")
      (LDESC "Long tables with attached benches fill the room. Trays and plates lie scattered about, covered in dust. East returns to the staff quarters.")
      (EAST TO STAFF-QUARTERS)
      (NORTH TO OVERGROWN-GARDEN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM OVERGROWN-GARDEN
      (IN ROOMS)
      (DESC "Overgrown Garden")
      (ACTION OVERGROWN-GARDEN-FCN)
      (LDESC "Broken benches lie among the overgrowth. A stone path, barely visible, leads to a small chapel to the north. South returns to the cafeteria.")
      (SOUTH TO CAFETERIA)
      (NORTH TO CHAPEL IF CHAPEL-UNLOCKED)
      (FLAGS RLANDBIT ONBIT)
      (GLOBAL SANITARIUM-BUILDING DEAD-OAK-TREE)>

<ROOM CHAPEL
      (IN ROOMS)
      (DESC "Chapel")
      (ACTION CHAPEL-FCN)
      (SOUTH TO OVERGROWN-GARDEN)
      (FLAGS RLANDBIT ONBIT)
      (VALUE 15)
      (GLOBAL TOPIC-MORDECAI TOPIC-TREATMENT TOPIC-IDENTITY TOPIC-SANITARIUM TOPIC-CHAPEL)>

; === OBJECTS ===

<OBJECT IRON-GATES
        (IN SANITARIUM-GATE)
        (SYNONYM GATE GATES)
        (ADJECTIVE IRON RUSTED)
        (DESC "iron gate")
        (LDESC "The rusted iron gates stand open. Flakes of old black paint cling to bars bent by years of weather.")
        (FLAGS NDESCBIT OPENBIT)
        (ACTION IRON-GATES-F)>

<OBJECT BRASS-PLAQUE
        (IN SANITARIUM-GATE)
        (SYNONYM PLAQUE BRASS SIGN)
        (ADJECTIVE BRASS CORRODED)
        (DESC "brass plaque")
        (LDESC "A corroded brass plaque hangs askew on the gate.")
        (FLAGS READBIT)
        (TEXT "The plaque reads: 'Blackwood Sanitarium - Est. 1898 - Closed by Order 1952'")
        (SIZE 5)
        (ACTION BRASS-PLAQUE-F)>

<OBJECT THEATER-DOOR
        (IN SANITARIUM-ENTRANCE)
        (SYNONYM DOOR)
        (ADJECTIVE HALF-OPEN THEATER OPERATING)
        (DESC "door to the operating theater")
        (LDESC "To the north, a door stands half-open, revealing an operating theater beyond.")
        (ACTION THEATER-DOOR-F)>

<OBJECT OAK-DESK
        (IN RECEPTION-ROOM)
        (SYNONYM DESK)
        (ADJECTIVE HEAVY OAK)
        (DESC "oak desk")
        (LDESC "A heavy oak desk sits against one wall, its surface thick with dust.")
        (FLAGS CONTBIT OPENBIT SURFACEBIT)
        (TEXT "The desk has three drawers. The top two are broken and empty. The bottom drawer appears intact but is locked tight.")
        (ACTION DESK-F)>

<OBJECT PATIENT-FILE
        (IN BOTTOM-DRAWER)
        (SYNONYM FILE FOLDER RECORDS)
        (ADJECTIVE PATIENT CONFIDENTIAL)
        (DESC "patient file")
        (FDESC "A confidential patient file lies open in the drawer, its contents disturbing.")
        (LDESC "A file folder marked 'Patient 189 - CONFIDENTIAL'.")
        (FLAGS TAKEBIT READBIT)
        (SIZE 3)
        (VALUE 2)
        (ACTION PATIENT-FILE-F)>

<OBJECT BRASS-KEY
        (IN RECEPTION-ROOM)
        (SYNONYM KEY)
        (ADJECTIVE BRASS SMALL)
        (DESC "brass key")
        (LDESC "A small brass key lies among the scattered papers on the floor, cold to the touch.")
        (FLAGS TAKEBIT)
        (SIZE 2)
        (TEXT "A small brass key with the number '3' engraved on its head. It's ice cold despite being indoors.")>

<OBJECT OPERATING-TABLE
        (IN OPERATING-THEATER)
        (SYNONYM TABLE)
        (ADJECTIVE OPERATING STAINED)
        (DESC "operating table")
        (FDESC "Tiers of wooden benches circle a central operating table. Cold metal trays sit abandoned on carts. A single overhead lamp, long dead, still points down at the table like an accusation.")
        (LDESC "A stained operating table dominates the center of the room.")
        (FLAGS SURFACEBIT CONTBIT OPENBIT)
        (TEXT "The operating table is covered in dark brown stains that you hope are just rust. Leather restraints dangle from all four corners. Deep gouges mar the metal surface, as if someone struggled violently against the bindings.")>

<OBJECT METAL-CABINET
        (IN OPERATING-THEATER)
        (SYNONYM CABINET)
        (ADJECTIVE METAL MEDICAL)
        (DESC "metal cabinet")
        (LDESC "A metal cabinet stands in the shadows, its door slightly ajar.")
        (FLAGS CONTBIT OPENBIT TRANSBIT)
        (ACTION CABINET-F)>

<OBJECT SCALPEL
        (IN METAL-CABINET)
        (SYNONYM SCALPEL KNIFE BLADE)
        (ADJECTIVE SURGICAL RUSTY)
        (DESC "rusty scalpel")
        (LDESC "A surgical scalpel, its blade dulled by rust but still sharp enough to cut.")
        (FLAGS TAKEBIT WEAPONBIT TOOLBIT)
        (SIZE 3)
        (ACTION SCALPEL-F)>

<OBJECT ETHER-BOTTLE
        (IN METAL-CABINET)
        (SYNONYM BOTTLE ETHER CHLOROFORM)
        (ADJECTIVE GLASS)
        (DESC "bottle of ether")
        (LDESC "A glass bottle labeled 'Ether - Handle with Care'. Some liquid remains inside.")
        (FLAGS TAKEBIT)
        (SIZE 5)
        (ACTION ETHER-F)>

<OBJECT BED-FRAMES
        (IN PATIENT-WARD)
        (SYNONYM BEDS FRAMES BED FRAME)
        (ADJECTIVE RUSTED)
        (DESC "bed frames")
        (FDESC "Dozens of bed frames line the walls. Most mattresses have rotted away, leaving only rusted springs. Among the debris, you notice a child's crayon drawing pinned to one bedframe—a crude sun, a stick figure, the word 'HOME' in wobbly letters.")
        (LDESC "Rusted bed frames line the corridor.")
        (TEXT "Dozens of bed frames line the walls. The mattresses have rotted away, leaving only rusted springs and metal frames. Some still have restraint straps attached.")>

<OBJECT CHILD-DRAWING
        (IN PATIENT-WARD)
        (SYNONYM DRAWING PICTURE CRAYON ART)
        (ADJECTIVE CHILD CRAYON)
        (DESC "child's drawing")
        (FLAGS NDESCBIT READBIT)
        (ACTION CHILD-DRAWING-F)>

<OBJECT HEAVY-DOOR
        (IN PATIENT-WARD)
        (SYNONYM DOOR)
        (ADJECTIVE HEAVY SEALED LOCKED MORGUE)
        (DESC "heavy door")
        (LDESC "At the far end, a heavy door sealed with chains blocks further passage. Scratches cover the door's surface, as if made by desperate fingers.")
        (FLAGS NDESCBIT)
        (ACTION HEAVYDOOR-F)>

<OBJECT CHAINS
        (IN PATIENT-WARD)
        (SYNONYM CHAINS CHAIN PADLOCK)
        (ADJECTIVE THICK)
        (DESC "chains")
        (LDESC "Thick chains secure the heavy door.")
        (VALUE 4)
        (ACTION CHAINS-F)>

<OBJECT REFRIGERATED-DRAWERS
        (IN MORGUE)
        (SYNONYM DRAWERS DRAWER REFRIGERATOR)
        (ADJECTIVE REFRIGERATED METAL)
        (DESC "refrigerated drawers")
        (LDESC "Refrigerated drawers line both walls.")
        (FLAGS CONTBIT OPENBIT)
        (ACTION DRAWERS-F)>

<OBJECT DISSECTION-TABLE
        (IN MORGUE)
        (SYNONYM TABLE)
        (ADJECTIVE DISSECTION AUTOPSY)
        (DESC "dissection table")
        (LDESC "In the center, a dissection table holds what appears to be a canvas-wrapped bundle.")
        (FLAGS SURFACEBIT CONTBIT OPENBIT)
        (ACTION DISTABLE-F)>

<OBJECT CANVAS-BUNDLE
        (IN DISSECTION-TABLE)
        (SYNONYM BUNDLE CANVAS BODY CORPSE)
        (ADJECTIVE WRAPPED)
        (DESC "canvas bundle")
        (FDESC "On the dissection table, a human-shaped bundle wrapped in stained canvas awaits examination.")
        (LDESC "A human-shaped bundle wrapped in stained canvas. You'd rather not investigate further.")
        (FLAGS TAKEBIT)
        (SIZE 50)
        (ACTION BUNDLE-F)>

<OBJECT STRANGE-SERUM
        (IN REFRIGERATED-DRAWERS)
        (SYNONYM SERUM VIAL BOTTLE)
        (ADJECTIVE STRANGE GLOWING)
        (DESC "vial of serum")
        (FDESC "Inside the refrigerated drawer, a glass vial glows with an eerie luminescence.")
        (LDESC "A glass vial containing luminescent liquid. The label reads 'Compound 237 - DO NOT USE'")
        (FLAGS TAKEBIT)
        (SIZE 4)
        (ACTION SERUM-F)>

<OBJECT MORDECAI-JOURNAL
        (IN MORGUE)
        (SYNONYM JOURNAL DIARY NOTEBOOK BOOK)
        (ADJECTIVE DOCTOR MORDECAI)
        (DESC "doctor's journal")
        (FDESC "A personal journal rests on a small desk in the corner, its pages filled with manic handwriting.")
        (LDESC "A journal rests on a small desk in the corner.")
        (FLAGS READBIT TAKEBIT)
        (TEXT "The subject showed remarkable resilience. But the serum... it changed something fundamental. Patient 237 died on the table, yet I swear I saw movement hours later. The eyes... the eyes opened. I have made a terrible mistake. God forgive me, I must seal this place.")
        (SIZE 6)
        (ACTION JOURNAL-F)>

<OBJECT PIPES
        (IN BASEMENT-CORRIDOR)
        (SYNONYM PIPES PIPE CEILING)
        (ADJECTIVE RUSTED DRIPPING)
        (DESC "rusty pipes")
        (LDESC "Pipes run along the ceiling, rusted and dripping.")
        (ACTION PIPES-F)>

<OBJECT VALVE
        (IN BASEMENT-CORRIDOR)
        (SYNONYM VALVE WHEEL)
        (ADJECTIVE PIPE METAL)
        (DESC "metal valve")
        (LDESC "A wheel valve on one of the pipes, crusted with rust.")
        (FLAGS TURNBIT)
        (ACTION VALVE-F)>

<OBJECT IRON-BOILER
        (IN BOILER-ROOM)
        (SYNONYM BOILER FURNACE)
        (ADJECTIVE IRON MASSIVE)
        (DESC "iron boiler")
        (DESCFCN IRON-BOILER-DESC-F)
        (FLAGS CONTBIT OPENBIT LIGHTBIT BURNBIT)
        (CAPACITY 20)
        (ACTION BOILER-F)>

<OBJECT COAL-SHOVEL
        (IN IRON-BOILER)
        (SYNONYM SHOVEL SPADE)
        (ADJECTIVE COAL)
        (DESC "coal shovel")
        (LDESC "A sturdy coal shovel with a wooden handle.")
        (FLAGS TAKEBIT TOOLBIT)
        (SIZE 10)
        (ACTION SHOVEL-F)>

<OBJECT COAL-BIN
        (IN BOILER-ROOM)
        (SYNONYM BIN HOPPER)
        (ADJECTIVE COAL IRON)
        (DESC "coal bin")
        (LDESC "An iron coal bin crouches beside the boiler.")
        (FLAGS CONTBIT OPENBIT)
        (ACTION COAL-BIN-F)>

<OBJECT LUMP-OF-COAL
        (IN COAL-BIN)
        (SYNONYM COAL LUMP FUEL)
        (ADJECTIVE BLACK DUSTY)
        (DESC "lump of coal")
        (LDESC "A usable lump of coal rests among the damp slack.")
        (FLAGS TAKEBIT)
        (SIZE 4)
        (ACTION COAL-F)>

<OBJECT WORKBENCH
        (IN BOILER-ROOM)
        (SYNONYM BENCH TABLE WORKBENCH)
        (ADJECTIVE WORK)
        (DESC "workbench")
        (LDESC "A workbench sits against the far wall, covered with ancient tools.")
        (FLAGS SURFACEBIT CONTBIT OPENBIT)
        (ACTION WORKBENCH-F)>

<OBJECT FLASHLIGHT
        (IN WORKBENCH)
        (SYNONYM FLASHLIGHT LIGHT TORCH)
        (ADJECTIVE ELECTRIC)
        (DESC "flashlight")
        (LDESC "An old-fashioned electric flashlight, surprisingly heavy.")
        (FLAGS TAKEBIT LIGHTBIT)
        (SIZE 5)
        (ACTION FLASHLIGHT-F)>

<OBJECT SHELVES
        (IN STORAGE-ROOM)
        (SYNONYM SHELVES SHELF)
        (ADJECTIVE SAGGING)
        (DESC "shelves")
        (LDESC "Shelves line the walls, sagging under the weight of moldering supplies.")
        (FLAGS CONTBIT OPENBIT)
        (ACTION SHELVES-F)>

<OBJECT MEDICAL-BAG
        (IN SHELVES)
        (SYNONYM BAG SATCHEL)
        (ADJECTIVE MEDICAL LEATHER DOCTOR)
        (DESC "medical bag")
        (LDESC "An old leather medical bag sits on one of the shelves.")
        (FLAGS CONTBIT OPENABLEBIT OPENBIT TAKEBIT)
        (CAPACITY 15)
        (SIZE 10)
        (ACTION MEDICAL-BAG-F)>

<OBJECT BANDAGES
        (IN MEDICAL-BAG)
        (SYNONYM BANDAGES BANDAGE CLOTH)
        (ADJECTIVE YELLOWED CLEAN)
        (DESC "bandages")
        (LDESC "Clean bandages wrapped in yellowed cloth.")
        (FLAGS TAKEBIT)
        (SIZE 3)
        (ACTION BANDAGES-F)>

<OBJECT MORPHINE-VIAL
        (IN MEDICAL-BAG)
        (SYNONYM VIAL MORPHINE BOTTLE)
        (ADJECTIVE GLASS SMALL)
        (DESC "morphine vial")
        (LDESC "A sealed glass vial of morphine.")
        (FLAGS TAKEBIT)
        (SIZE 2)
        (ACTION MORPHINE-VIAL-F)>

<OBJECT OIL-LANTERN
        (IN SHELVES)
        (SYNONYM LANTERN LAMP)
        (ADJECTIVE OIL)
        (DESC "oil lantern")
        (LDESC "An old oil lantern. It still has fuel inside.")
        (FLAGS TAKEBIT LIGHTBIT FLAMEBIT)
        (SIZE 8)
        (ACTION LANTERN-F)>

<OBJECT MEDICAL-RECORDS
        (IN SHELVES)
        (SYNONYM RECORDS FILES PAPERS)
        (ADJECTIVE MEDICAL OLD)
        (DESC "medical records")
        (LDESC "Yellowed files containing patient records from the 1940s.")
        (FLAGS TAKEBIT READBIT)
        (TEXT "Most records are water-damaged, but one file remains legible: Patient 189 - Subject shows unusual resistance to sedation. Transferred to isolation ward for observation.")
        (SIZE 4)
        (ACTION RECORDS-F)>

<OBJECT STANDING-WATER
        (IN FLOODING-CHAMBER)
        (SYNONYM WATER FLOOD PUDDLE)
        (ADJECTIVE STANDING ANKLE)
        (DESC "standing water")
        (LDESC "Cold water covering the floor.")
        (ACTION STANDING-WATER-F)>

<OBJECT SEALED-DOOR
        (IN FLOODING-CHAMBER)
        (SYNONYM DOOR)
        (ADJECTIVE SEALED EAST METAL)
        (DESC "sealed door")
        (LDESC "A door to the east is sealed shut.")
        (FLAGS NDESCBIT)
        (ACTION SEALED-DOOR-F)>

<OBJECT PORCELAIN-TUBS
        (IN HYDROTHERAPY-ROOM)
        (SYNONYM TUBS TUB BATH)
        (ADJECTIVE PORCELAIN)
        (DESC "porcelain tubs")
        (LDESC "Large porcelain tubs line the walls, each fitted with restraints.")
        (FLAGS CONTBIT OPENBIT)
        (ACTION TUBS-F)>

<OBJECT SOGGY-NOTEBOOK
        (IN PORCELAIN-TUBS)
        (SYNONYM NOTEBOOK BOOK DIARY)
        (ADJECTIVE SOGGY WET)
        (DESC "soggy notebook")
        (LDESC "A water-damaged notebook, barely legible.")
        (FLAGS TAKEBIT READBIT)
        (TEXT "...water treatment...hours submerged...screaming stopped...Dr. M approved extended sessions...")
        (SIZE 3)
        (ACTION SOGGY-NOTEBOOK-F)>

<OBJECT MEDICINE-CABINET
        (IN HYDROTHERAPY-ROOM)
        (SYNONYM CABINET CUPBOARD)
        (ADJECTIVE MEDICINE MEDICAL)
        (DESC "medicine cabinet")
        (LDESC "A medicine cabinet is sealed beneath a skin of white frost.")
        (FLAGS CONTBIT OPENABLEBIT)
        (ACTION MEDICINE-CABINET-F)>

<OBJECT SYRINGE
        (IN MEDICINE-CABINET)
        (SYNONYM SYRINGE NEEDLE)
        (ADJECTIVE MEDICAL)
        (DESC "syringe")
        (LDESC "A glass syringe with a steel needle.")
        (FLAGS TAKEBIT)
        (SIZE 2)
        (VALUE 3)
        (ACTION SYRINGE-F)>

<OBJECT CELL-DOORS
        (IN ISOLATION-WARD)
        (SYNONYM DOORS DOOR CELLS)
        (ADJECTIVE CELL HEAVY BARRED)
        (DESC "cell doors")
        (LDESC "Heavy doors with barred windows stand open, revealing bare concrete rooms within.")
        (ACTION CELL-DOORS-F)>

<OBJECT WALL-SCRATCHES
        (IN ISOLATION-WARD)
        (SYNONYM SCRATCHES MARKS TALLIES WRITING WORDS MESSAGE)
        (ADJECTIVE WALL)
        (DESC "wall scratches")
        (LDESC "Thousands of scratch marks covering the cell walls.")
        (VALUE 2)
        (ACTION WALL-SCRATCHES-F)>

<OBJECT SHOCK-CHAIR
        (IN ELECTROSHOCK-THEATER)
        (SYNONYM CHAIR)
        (ADJECTIVE SHOCK ELECTRIC METAL)
        (DESC "electroshock chair")
        (FDESC "In the center of the room, bolted to the floor, sits the chair. Leather restraints dangle from every joint. You know immediately what this is, and your stomach turns.")
        (LDESC "A chair is bolted to the floor in the center of the room.")
        (ACTION SHOCK-CHAIR-F)>

<OBJECT SHOCK-MACHINE
        (IN ELECTROSHOCK-THEATER)
        (SYNONYM MACHINE EQUIPMENT ELECTRODES)
        (ADJECTIVE SHOCK ELECTRIC)
        (DESC "shock machine")
        (LDESC "Electrodes dangle from a machine beside the chair.")
        (ACTION SHOCK-MACHINE-F)>

<OBJECT PADCELL-DOOR
        (IN ELECTROSHOCK-THEATER)
        (SYNONYM DOOR)
        (ADJECTIVE HEAVY WEST PADDED)
        (DESC "heavy door to the padded cell")
        (LDESC "To the west, a heavy door stands ajar, revealing a padded cell beyond.")
        (ACTION PADCELL-DOOR-F)>

<OBJECT PADDING
        (IN PADDED-CELL)
        (SYNONYM PADDING WALLS WRITING WORDS MESSAGE)
        (ADJECTIVE ROTTING TORN BLOOD DRIED)
        (DESC "padded walls")
        (LDESC "Every surface is covered in rotting padding, now torn and hanging in strips.")
        (ACTION PADDING-F)>

<OBJECT STRAITJACKET
        (IN PADDED-CELL)
        (SYNONYM STRAITJACKET JACKET TAG LABEL)
        (ADJECTIVE STRAIT NAME COLLAR)
        (DESC "straitjacket")
        (FDESC "A straitjacket lies in the corner, its straps unbuckled as if someone left in a hurry.")
        (LDESC "A straitjacket lies in the corner.")
        (FLAGS TAKEBIT READBIT)
        (TEXT "The tag reads a name you know. Your name. Dated 1947. Five years before the sanitarium closed.")
        (SIZE 15)
        (VALUE 1)
        (ACTION STRAITJACKET-F)>

<OBJECT ESCAPE-DOOR
        (IN PADDED-CELL)
        (SYNONYM DOOR)
        (ADJECTIVE EAST HEAVY)
        (DESC "door to the electroshock theater")
        (LDESC "To the east, a heavy door leads back to the electroshock theater.")
        (ACTION ESCAPE-DOOR-F)>

<OBJECT ONE-WAY-MIRROR
        (IN OBSERVATION-DECK)
        (SYNONYM MIRROR WINDOW GLASS)
        (ADJECTIVE ONE-WAY)
        (DESC "one-way mirror")
        (LDESC "A one-way mirror overlooks the electroshock theater.")
        (ACTION MIRROR-F)>

<OBJECT OBSERVATION-LOGBOOK
        (IN OBSERVATION-DECK)
        (SYNONYM LOGBOOK LOG BOOK)
        (ADJECTIVE OBSERVATION)
        (DESC "observation logbook")
        (LDESC "A logbook rests on a desk.")
        (FLAGS TAKEBIT READBIT)
        (TEXT "Session 47 - Patient 189. Subject required maximum voltage. Seizure lasted 4 minutes. Memory loss total. Subject claims to be 'someone else' now. Dr. Mordecai pleased with results.")
        (SIZE 7)
        (ACTION OBSERVATION-LOGBOOK-F)>

<OBJECT CORRIDOR-DOOR
        (IN OBSERVATION-DECK)
        (SYNONYM DOOR)
        (ADJECTIVE NORTH ADMINISTRATIVE)
        (DESC "door to the administrative wing")
        (LDESC "To the north, a door opens to the administrative wing.")
        (ACTION CORRIDOR-DOOR-F)>

<OBJECT SCATTERED-PAPERS
        (IN ADMINISTRATIVE-WING)
        (SYNONYM PAPERS FILES DOCUMENTS)
        (ADJECTIVE SCATTERED)
        (DESC "scattered papers")
        (LDESC "Papers are scattered everywhere.")
        (ACTION SCATTERED-PAPERS-F)>

<OBJECT MASSIVE-DESK
        (IN DIRECTORS-OFFICE)
        (SYNONYM DESK)
        (ADJECTIVE MASSIVE WOOD)
        (DESC "massive desk")
        (LDESC "A massive desk dominates the room.")
        (FLAGS CONTBIT OPENBIT SURFACEBIT)
        (ACTION MASSIVE-DESK-F)>

<OBJECT HOLLOW-BOOK
        (IN DIRECTORS-OFFICE)
        (SYNONYM BOOK TOME VOLUME)
        (ADJECTIVE RED LEATHER HOLLOW)
        (DESC "red leather book")
        (FDESC "Among the medical texts, one book stands out -- a red leather tome, its spine blank where all others are labeled.")
        (LDESC "A red leather book with a blank spine sits among the medical volumes.")
        (FLAGS CONTBIT OPENABLEBIT TAKEBIT)
        (CAPACITY 5)
        (SIZE 6)
        (ACTION HOLLOW-BOOK-F)>

<OBJECT MORDECAI-PORTRAIT
        (IN DIRECTORS-OFFICE)
        (SYNONYM PORTRAIT PAINTING PICTURE)
        (ADJECTIVE MORDECAI)
        (DESC "portrait of Dr. Mordecai")
        (LDESC "A portrait of Dr. Mordecai hangs on the wall, his stern eyes seeming to follow you.")
        (ACTION PORTRAIT-F)>

<OBJECT WALL-SAFE
        (IN DIRECTORS-OFFICE)
        (SYNONYM SAFE)
        (ADJECTIVE WALL METAL)
        (DESC "wall safe")
        (LDESC "A safe is visible behind a moved painting.")
        (FLAGS CONTBIT)
        (ACTION WALL-SAFE-F)>

<OBJECT OFFICE-DOOR
        (IN DIRECTORS-OFFICE)
        (SYNONYM DOOR)
        (ADJECTIVE WEST HEAVY)
        (DESC "door to the administrative wing")
        (LDESC "To the west, a door opens back to the administrative wing corridor.")
        (ACTION OFFICE-DOOR-F)>

<OBJECT SAFE-KEY
        (IN HOLLOW-BOOK)
        (SYNONYM KEY)
        (ADJECTIVE SAFE NUMBERED)
        (DESC "safe key")
        (LDESC "A small key with a numbered tag: S-001.")
        (FLAGS TAKEBIT)
        (SIZE 1)
        (VALUE 2)
        (ACTION SAFE-KEY-F)>

<OBJECT MORDECAI-NOTES
        (IN WALL-SAFE)
        (SYNONYM NOTES JOURNAL PAPERS)
        (ADJECTIVE PRIVATE MORDECAI)
        (DESC "Dr. Mordecai's notes")
        (FDESC "Private notes in a tight, obsessive hand detail experiments that should never have been conducted.")
        (LDESC "Personal notes in Dr. Mordecai's handwriting.")
        (FLAGS TAKEBIT READBIT)
        (TEXT "The experiment succeeded beyond expectations. Patient 189 has transcended death itself. But the cost... the screaming never stops. I hear it in my sleep. The chapel must remain locked. What I've created must never escape.")
        (SIZE 5)
        (ACTION MORDECAI-NOTES-F)>

<OBJECT CHAPEL-KEY
        (IN WALL-SAFE)
        (SYNONYM KEY)
        (ADJECTIVE CHAPEL IRON)
        (DESC "chapel key")
        (FDESC "A heavy iron key lies among the safe's contents, its head carved with a cross.")
        (LDESC "A large iron key with a cross engraved on the head.")
        (FLAGS TAKEBIT)
        (SIZE 6)
        (VALUE 3)
        (ACTION CHAPEL-KEY-F)>

<OBJECT LOCKERS
        (IN STAFF-QUARTERS)
        (SYNONYM LOCKERS LOCKER)
        (ADJECTIVE METAL)
        (DESC "lockers")
        (LDESC "Lockers line one wall. Most are open and empty, their contents long gone.")
        (FLAGS CONTBIT OPENBIT)
        (ACTION LOCKERS-F)>

<OBJECT PHOTOGRAPH
        (IN LOCKERS)
        (SYNONYM PHOTOGRAPH PHOTO PICTURE)
        (ADJECTIVE OLD)
        (DESC "photograph")
        (LDESC "A faded photograph of the sanitarium staff.")
        (FLAGS TAKEBIT)
        (SIZE 1)
        (ACTION PHOTOGRAPH-F)>

<OBJECT SERVING-COUNTER
        (IN CAFETERIA)
        (SYNONYM COUNTER)
        (ADJECTIVE SERVING)
        (DESC "serving counter")
        (LDESC "A serving counter separates the dining area from the kitchen beyond.")
        (FLAGS SURFACEBIT CONTBIT OPENBIT)
        (ACTION COUNTER-F)>

<OBJECT BELL
        (IN SERVING-COUNTER)
        (SYNONYM BELL)
        (ADJECTIVE SERVICE COUNTER)
        (DESC "service bell")
        (LDESC "A small brass bell for summoning staff.")
        (FLAGS TAKEBIT)
        (SIZE 2)
        (ACTION BELL-F)>

<OBJECT GARDEN-DOOR
        (IN CAFETERIA)
        (SYNONYM DOOR)
        (ADJECTIVE NORTH WOODEN)
        (DESC "door to the garden")
        (LDESC "To the north, a door leads out to the garden.")
        (ACTION GARDEN-DOOR-F)>

<OBJECT DEAD-GARDEN
        (IN OVERGROWN-GARDEN)
        (SYNONYM GARDEN WEEDS PLANTS)
        (ADJECTIVE DEAD OVERGROWN)
        (DESC "dead garden")
        (LDESC "What was once a therapeutic garden is now a wild tangle of weeds and dead plants.")
        (ACTION DEAD-GARDEN-F)>

<OBJECT CHAPEL-DOOR
        (IN OVERGROWN-GARDEN)
        (SYNONYM DOOR)
        (ADJECTIVE CHAPEL HEAVY LOCKED)
      (DESC "chapel door")
      (FLAGS NDESCBIT)
      (ACTION CHAPEL-DOOR-F)>

<OBJECT PEWS
        (IN CHAPEL)
        (SYNONYM PEWS BENCHES)
        (ADJECTIVE WOODEN)
        (DESC "wooden pews")
        (LDESC "Pews face an altar.")
        (ACTION PEWS-F)>

<OBJECT GREEN-CANDLES
        (IN CHAPEL)
        (SYNONYM CANDLES FLAMES)
        (ADJECTIVE GREEN UNNATURAL)
      (DESC "green candles")
      (FLAGS NDESCBIT)
      (ACTION GREEN-CANDLES-F)>

<OBJECT WOODEN-BOX
        (IN CHAPEL)
        (SYNONYM BOX CASE)
        (ADJECTIVE WOODEN LOCKED SMALL)
        (DESC "wooden box")
        (LDESC "A small wooden box sits beneath the altar, its surface carved with disturbing symbols.")
        (FLAGS CONTBIT OPENABLEBIT TAKEBIT)
        (CAPACITY 10)
        (SIZE 8)
        (ACTION WOODEN-BOX-F)>

<OBJECT ANCIENT-RELIC
        (IN WOODEN-BOX)
        (SYNONYM RELIC CROSS SILVER AMULET)
        (ADJECTIVE ANCIENT SILVER TARNISHED)
        (DESC "ancient relic")
        (FDESC "Inside the wooden box, an ancient silver cross gleams with writhing symbols etched into its surface.")
        (LDESC "An ancient silver cross with writhing symbols etched into its surface.")
        (FLAGS TAKEBIT)
        (SIZE 4)
        (VALUE 3)
        (ACTION ANCIENT-RELIC-F)>

<OBJECT PATIENT-189
        (IN CHAPEL)
        (SYNONYM PATIENT FIGURE BEING MONSTER SOUL GHOST SOMETHING)
        (ADJECTIVE PATIENT 189)
        (DESC "Patient 189")
        (FDESC "Something is standing at the altar. It doesn't move. It doesn't breathe. But somehow, horribly, you know it knows you're here.")
        (LDESC "A figure stands motionless at the altar. It turns to face you—its eyes glow faintly in the darkness.")
        (FLAGS ACTORBIT)
        (ACTION PATIENT-189-F)>

; === FORMER PSEUDO OBJECTS (replaced with real objects) ===

<OBJECT NEST
        (IN RECEPTION-ROOM)
        (SYNONYM NEST)
        (ADJECTIVE BIRD)
        (DESC "bird's nest")
        (FLAGS NDESCBIT)
        (ACTION NEST-PSEUDO)>

<OBJECT ASHES
        (IN RECEPTION-ROOM)
        (SYNONYM ASHES ASH)
        (ADJECTIVE COLD GREY)
        (DESC "ashes")
        (FLAGS NDESCBIT)
        (ACTION ASHES-PSEUDO)>

<OBJECT INSTRUMENTS
        (IN OPERATING-THEATER)
        (SYNONYM INSTRUMENTS)
        (ADJECTIVE MEDICAL SURGICAL)
        (DESC "instruments")
        (FLAGS NDESCBIT)
        (ACTION INSTRUMENTS-PSEUDO)>

<OBJECT TRAYS
        (IN OPERATING-THEATER)
        (SYNONYM TRAYS)
        (ADJECTIVE METAL INSTRUMENT)
        (DESC "trays")
        (FLAGS NDESCBIT)
        (ACTION TRAYS-PSEUDO)>

<OBJECT THEATER-BENCHES
        (IN OPERATING-THEATER)
        (SYNONYM BENCHES BENCH TIERS)
        (ADJECTIVE WOODEN THEATER OPERATING)
        (DESC "wooden benches")
        (FLAGS NDESCBIT)
        (ACTION BENCHES-PSEUDO)>

<OBJECT COAL-DUST
        (IN BOILER-ROOM)
        (SYNONYM DUST SOOT)
        (ADJECTIVE COAL BLACK)
        (DESC "coal dust")
        (FLAGS NDESCBIT)
        (ACTION COAL-DUST-F)>

<OBJECT GARDEN-BENCHES
        (IN OVERGROWN-GARDEN)
        (SYNONYM BENCHES BENCH)
        (ADJECTIVE BROKEN STONE)
        (DESC "stone benches")
        (FLAGS NDESCBIT)
        (ACTION GARDEN-BENCHES-F)>

<OBJECT GRAND-STAIRCASE
        (IN SANITARIUM-ENTRANCE)
        (SYNONYM STAIRCASE STAIRS)
        (ADJECTIVE GRAND)
        (DESC "grand staircase")
        (FLAGS NDESCBIT)
        (ACTION GRAND-STAIRCASE-F)>

<OBJECT WALLPAPER
        (IN SANITARIUM-ENTRANCE)
        (SYNONYM WALLPAPER PAPER PLASTER)
        (ADJECTIVE VICTORIAN PEELING)
        (DESC "wallpaper")
        (FLAGS NDESCBIT)
        (ACTION WALLPAPER-F)>

; === LOCAL-GLOBALS (objects visible from multiple rooms) ===

<OBJECT SANITARIUM-BUILDING
    (IN LOCAL-GLOBALS)
    (SYNONYM BUILDING SANITARIUM STRUCTURE FACADE)
    (ADJECTIVE ABANDONED VICTORIAN SANITARIUM)
    (DESC "sanitarium building")
    (FLAGS NDESCBIT)
    (ACTION SANITARIUM-BUILDING-F)>

<OBJECT DEAD-OAK-TREE
    (IN LOCAL-GLOBALS)
    (SYNONYM TREE OAK CROWS)
    (ADJECTIVE DEAD BARE)
    (DESC "dead oak tree")
    (FLAGS NDESCBIT CLIMBBIT)
    (ACTION DEAD-OAK-TREE-F)>

<OBJECT FILING-CABINETS
    (IN LOCAL-GLOBALS)
    (SYNONYM CABINETS CABINET DRAWERS FILES)
    (ADJECTIVE FILING FILE OVERTURNED)
    (DESC "filing cabinets")
    (FLAGS NDESCBIT)
    (ACTION FILING-CABINETS-F)>

; === TOPIC OBJECTS (ASK/TELL vocabulary for NPC interaction) ===

<OBJECT TOPIC-MORDECAI
    (IN LOCAL-GLOBALS)
    (SYNONYM MORDECAI DIRECTOR DOCTOR)
    (ADJECTIVE HEINRICH)
    (DESC "Dr. Mordecai")
    (FLAGS NDESCBIT)>

<OBJECT TOPIC-TREATMENT
    (IN LOCAL-GLOBALS)
    (SYNONYM TREATMENT EXPERIMENT SERUM THERAPY)
    (ADJECTIVE EXPERIMENTAL)
    (DESC "treatment")
    (FLAGS NDESCBIT)>

<OBJECT TOPIC-IDENTITY
    (IN LOCAL-GLOBALS)
    (SYNONYM NAME IDENTITY MEMORY PAST)
    (DESC "identity")
    (FLAGS NDESCBIT)>

<OBJECT TOPIC-SANITARIUM
    (IN LOCAL-GLOBALS)
    (SYNONYM SANITARIUM HOSPITAL BLACKWOOD)
    (ADJECTIVE BLACKWOOD)
    (DESC "sanitarium")
    (FLAGS NDESCBIT)>

<OBJECT TOPIC-CHAPEL
    (IN LOCAL-GLOBALS)
    (SYNONYM CHAPEL ALTAR)
    (DESC "chapel")
    (FLAGS NDESCBIT)>

<OBJECT BOTTOM-DRAWER
        (IN OAK-DESK)
        (SYNONYM DRAWER)
        (ADJECTIVE BOTTOM)
        (DESC "bottom drawer")
        (LDESC "A sturdy drawer that seems to be locked.")
        (FLAGS CONTBIT SEARCHBIT NDESCBIT)
        (CAPACITY 10)
        (ACTION DRAWER-F)>

<OBJECT PATIENT-LEDGER
        (IN BOTTOM-DRAWER)
        (SYNONYM LEDGER BOOK)
        (ADJECTIVE PATIENT LEATHER)
        (DESC "patient ledger")
        (LDESC "A leather-bound ledger with names and dates. The final entry reads: 'Patient 237 - Treatment discontinued. Subject expired during procedure. Dr. Mordecai.'")
        (FLAGS READBIT TAKEBIT)
        (TEXT "Patient 237 - Treatment discontinued. Subject expired during procedure. Dr. Mordecai.")
        (SIZE 8)
        (ACTION LEDGER-F)>
