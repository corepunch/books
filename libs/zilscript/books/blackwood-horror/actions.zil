; === PSEUDO ROUTINES (scenery words for RECEPTION-ROOM) ===

<ROUTINE NEST-PSEUDO ()
    <COND (<VERB? EXAMINE>
           <TELL "An old bird's nest tucked into the fireplace grate. Long abandoned -- like everything else here." CR>)>
    <RTRUE>>

<ROUTINE ASHES-PSEUDO ()
    <COND (<VERB? EXAMINE>
           <TELL "Cold grey ashes. Nothing of value." CR>)
          (<VERB? SEARCH>
           <TELL "You sift through the ashes. Just soot and old char." CR>)>
    <RTRUE>>

; === ROOM ACTION ROUTINES (Dynamic Descriptions) ===

<ROUTINE RECEPTION-ROOM-FCN (RARG)
    <COND (<EQUAL? .RARG ,M-LOOK>
           <TELL "This cramped room once served as the sanitarium's reception. Filing cabinets line the opposite wall, their drawers hanging open like gaping mouths.">
           <COND (<IN? ,BRASS-KEY ,RECEPTION-ROOM>
                  <TELL " Something glints among the papers scattered on the floor.">)>
           <TELL " A doorway to the east opens back to the entrance hall." CR>)>>

<ROUTINE PATIENT-WARD-FCN (RARG)
    <COND (<EQUAL? .RARG ,M-LOOK>
           <TELL "A long corridor with tattered curtains hanging between areas, offering the ghost of privacy. The floor is littered with patient records and broken glass.">
           <COND (,CHAINS-CUT-FLAG
                  <TELL " To the north, a heavy door stands open, revealing darkness beyond.">)
                 (T
                  <TELL " At the far end, a heavy door sealed with chains blocks further passage.">)>
           <TELL CR "A doorway leads west back to the entrance hall." CR>)>>

<ROUTINE BASEMENT-CORRIDOR-FCN (RARG)
    <COND (<EQUAL? .RARG ,M-LOOK>
           <TELL "The basement corridor is pitch black, stretching into shadow. Stone stairs climb upward into darkness.">
           <COND (,VALVE-TURNED-FLAG
                  <TELL " Steam hisses from the pipes overhead, filling the corridor with an acrid mist.">)>
           <TELL " To the east, a passage leads toward the sound of dripping water. West lies what might have been storage. North, another corridor descends toward deeper chambers." CR>)>>

<ROUTINE BOILER-ROOM-FCN (RARG)
    <COND (<EQUAL? .RARG ,M-LOOK>
           <TELL "Coal dust softens every edge in this low brick chamber.">
           <TELL " A narrow doorway leads west." CR>)>>

<ROUTINE IRON-BOILER-DESC-F (RARG)
    <COND (<EQUAL? .RARG ,M-OBJDESC>
           <COND (,BOILER-LIT
                  <TELL "The massive iron boiler is awake now: fire mutters behind its door and the pipes knock with gathering heat." CR>)
                 (,BOILER-FUELED
                  <TELL "The massive iron boiler crouches in the darkness with fresh coal waiting in its firebox." CR>)
                 (T
                  <TELL "The room's centerpiece is a massive iron boiler, cold and silent as a tomb." CR>)>
           <RTRUE>)>>

<ROUTINE HYDROTHERAPY-ROOM-FCN (RARG)
    <COND (<EQUAL? .RARG ,M-LOOK>
           <TELL "Rubber hoses dangle from fixtures above cracked porcelain tubs. A doorway west opens into the flooded chamber.">
           <COND (,CABINET-THAWED
                  <TELL " Water beads on the medicine cabinet where its coat of frost has melted.">)
                 (T
                  <TELL " A medicine cabinet on the far wall is sealed beneath thick white frost.">)>
           <TELL CR>)>>

<ROUTINE FLOODING-CHAMBER-FCN (RARG)
    <COND (<EQUAL? .RARG ,M-LOOK>
           <TELL "The chamber is vast and dark, with arched stone ceilings disappearing into shadow.">
           <COND (,STEAM-DOOR-OPEN
                  <TELL " To the east, a door stands open, steam wisping from its edges.">)
                 (T
                  <TELL " A sealed metal door to the east is corroded shut.">)>
           <TELL CR "To the north, a narrow passage disappears into darkness. The corridor lies to the south." CR>)>>

<ROUTINE OVERGROWN-GARDEN-FCN (RARG)
    <COND (<EQUAL? .RARG ,M-LOOK>
           <TELL "Broken benches lie among the overgrowth. A stone path, barely visible, leads to a small chapel to the north.">
           <COND (,CHAPEL-UNLOCKED
                  <TELL " The chapel door stands open, darkness visible beyond.">)
                 (T
                  <TELL " The chapel door is secured with a heavy iron lock.">)>
           <COND (<IN? ,PATIENT-189 ,OVERGROWN-GARDEN>
                  <TELL " Patient 189 stands among the dead roses, head tilted toward the chapel.">)>
           <TELL CR "South returns to the cafeteria." CR>)>>

<ROUTINE DIRECTORS-OFFICE-FCN (RARG)
    <COND (<EQUAL? .RARG ,M-LOOK>
           <TELL "A large office with wood paneling. Bookshelves line the walls.">
           <COND (<FSET? ,WALL-SAFE ,OPENBIT>
                  <TELL " A wall safe is visible behind a moved painting.">)
                 (<FSET? ,MORDECAI-PORTRAIT ,TOUCHBIT>
                  <TELL " A portrait of Dr. Mordecai hangs slightly askew on the wall.">)>
           <TELL CR>)>>

; === ACTION HANDLERS ===

<SYNTAX SAY HELLO = V-SAY-HELLO>
<SYNTAX HINT = V-HINTS>
<SYNONYM HINT HINTS>
<SYNTAX SCRAPE OBJECT = V-SCRAPE>
<SYNTAX SCRAPE OBJECT WITH OBJECT = V-SCRAPE>
<SYNTAX INJECT OBJECT WITH OBJECT = V-INJECT>
<SYNTAX KINDLE OBJECT WITH OBJECT = V-IGNITE>
<SYNTAX TURN OBJECT (FIND TURNBIT) (HELD CARRIED ON-GROUND IN-ROOM) = V-TURN-BARE>
<SYNTAX LISTEN = V-LISTEN-AROUND>
<SYNTAX SMELL = V-SMELL-AROUND>
<SYNTAX SITDOWN = V-SIT-DOWN>
<SYNTAX GREET = V-BARE-HELLO>
<SYNTAX GREET OBJECT = V-GREET-OBJECT>

<ROUTINE BRASS-PLAQUE-F ()
         <COND (<VERB? TAKE PULL>
                <TELL "The plaque is bolted firmly to the iron gate." CR>
                <RTRUE>)>>

<ROUTINE CHILD-DRAWING-F ()
         <COND (<VERB? EXAMINE READ>
                <TELL "A child's crayon drawing is pinned to the bedframe: a yellow sun above a stick figure with outstretched arms, and the word 'HOME' pressed so hard into the paper that the crayon tore through in places." CR>
                <RTRUE>)
               (<VERB? TAKE PULL>
                <TELL "The brittle paper would crumble if you tried to remove it from the rusted pin." CR>
                <RTRUE>)>>

<ROUTINE FILING-CABINETS-F ()
         <COND (<VERB? EXAMINE SEARCH LOOK-INSIDE OPEN>
                <COND (<EQUAL? ,HERE ,RECEPTION-ROOM>
                       <TELL "The reception cabinets stand open and empty. Their labels have faded, and damp has fused the remaining scraps of paper into gray pulp." CR>)
                      (T
                       <TELL "The overturned cabinets have been emptied. Bent drawers gape open among waterlogged administrative forms." CR>)>
                <RTRUE>)>>

<ROUTINE DESK-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "The desk has three drawers. The top two are broken and empty. The bottom drawer is intact but locked." CR>
                <RTRUE>)>>

<ROUTINE PATIENT-FILE-F ()
         <COND (<VERB? READ EXAMINE>
                <COND (<NOT ,PATIENT-FILE-LORE>
                       <SETG PATIENT-FILE-LORE T>
                       <SETG PATIENT-LORE <+ ,PATIENT-LORE 1>>)>
                <TELL "A file folder labeled 'Patient 189 - CONFIDENTIAL'. Inside are medical records and notes. 'Subject shows extraordinary resistance to pain. Mental state deteriorating. Recommending transfer to isolation wing. Dr. Mordecai has expressed personal interest in this case. Update: Patient transferred to chapel for experimental treatment. Nov 1, 1952.'" CR>
                <RTRUE>)>>

<ROUTINE CABINET-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "The cabinet's glass doors are cracked but still intact. Inside, you can see various medical instruments">
                <COND (<OR <IN? ,SCALPEL ,METAL-CABINET> <IN? ,ETHER-BOTTLE ,METAL-CABINET>>
                       <TELL ", including">
                       <COND (<IN? ,SCALPEL ,METAL-CABINET> <TELL " a scalpel">)>
                       <COND (<AND <IN? ,SCALPEL ,METAL-CABINET> <IN? ,ETHER-BOTTLE ,METAL-CABINET>> <TELL " and">)>
                       <COND (<IN? ,ETHER-BOTTLE ,METAL-CABINET> <TELL " a bottle">)>)>
                <TELL "." CR>
                <RTRUE>)>>

<ROUTINE HEAVYDOOR-F ()
         <COND (<AND <VERB? EXAMINE>
                     <NOT ,CHAINS-CUT-FLAG>>
                <TELL "The heavy door is secured with thick chains and a rusted padlock. Deep scratches cover its surface, made by fingernails. A tarnished plaque reads 'MORGUE'." CR>
                <RTRUE>)
               (<AND <VERB? EXAMINE>
                     ,CHAINS-CUT-FLAG>
                <TELL "The door stands open, chains lying in a heap on the floor. Beyond lies darkness." CR>
                <RTRUE>)
               (<AND <VERB? OPEN>
                     <NOT ,CHAINS-CUT-FLAG>>
                <TELL "The door is secured with heavy chains. You need to cut through them." CR>
                <RTRUE>)
               (<VERB? KNOCK>
                <TELL "You knock on the door. The sound echoes hollowly. No response comes from within." CR>
                <RTRUE>)
               (<VERB? LISTEN>
                <TELL "You press your ear to the door. From beyond comes an eerie silence—too complete, too absolute." CR>
                <RTRUE>)>>

<ROUTINE CHAINS-F ()
         <COND (<AND <VERB? EXAMINE>
                     <NOT ,CHAINS-CUT-FLAG>>
                <TELL "Thick iron chains wrap around the door handles, secured with a massive rusted padlock. The chains look old but still strong." CR>
                <RTRUE>)
               (<AND <VERB? ATTACK CUT>
                     <NOT ,CHAINS-CUT-FLAG>
                     <NOT <IN? ,SCALPEL ,WINNER>>>
                <TELL "The chains are too strong to break with your bare hands. You need a sharp tool." CR>
                <RTRUE>)
               (<AND <VERB? ATTACK CUT>
                     <NOT ,CHAINS-CUT-FLAG>
                     <IN? ,SCALPEL ,WINNER>>
                <TELL "You saw through the rusty chains with the " D ,SCALPEL ". It takes several minutes of effort, but finally they fall away with a crash. The heavy door creaks open, revealing a passage north into darkness." CR>
                <SETG CHAINS-CUT-FLAG T>
                <REMOVE ,CHAINS>
                <RTRUE>)>>

<ROUTINE DRAWERS-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "The refrigeration units line both walls. Most drawers are empty or contain only bones.">
                <COND (<IN? ,STRANGE-SERUM ,REFRIGERATED-DRAWERS>
                       <TELL " One drawer is slightly ajar, a faint luminescent glow emanating from within.">)>
                <TELL CR>
                <RTRUE>)>>

<ROUTINE DISTABLE-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "The dissection table is made of stainless steel with drainage channels carved into its surface. Dark stains pool in the grooves. A canvas-wrapped bundle lies upon it." CR>
                <RTRUE>)>>

<ROUTINE JOURNAL-F ()
         <COND (<VERB? READ EXAMINE>
                <TELL "Dr. Mordecai's personal journal. The final entry is dated October 31, 1952. The handwriting becomes increasingly erratic: 'The subject showed remarkable resilience. But the serum... it changed something fundamental. Patient 237 died on the table, yet I swear I saw movement hours later. The eyes... the eyes opened. I have made a terrible mistake. God forgive me, I must seal this place.'" CR>
                <RTRUE>)>>

<ROUTINE PIPES-F ()
         <COND (<VERB? EXAMINE>
                <TELL "The pipes are ancient and corroded. Water drips steadily from cracks in the metal. One pipe has a valve." CR>
                <RTRUE>)>>

<ROUTINE VALVE-F ()
         <COND (<AND <VERB? TURN TURN-BARE>
                     <NOT ,VALVE-TURNED-FLAG>>
                <TELL "You grip the " D ,VALVE " and turn with all your strength. It resists, then suddenly gives way with a shriek of metal. Steam hisses from somewhere below." CR>
                <SETG VALVE-TURNED-FLAG T>
                <RTRUE>)
               (<AND <VERB? TURN TURN-BARE>
                     ,VALVE-TURNED-FLAG>
                <TELL "The " D ,VALVE " is already open. Steam continues to hiss somewhere in the basement." CR>
                <RTRUE>)
               (<VERB? EXAMINE>
                <TELL "A large wheel valve covered in rust and grime." CR>
                <RTRUE>)>>

<ROUTINE V-TURN-BARE ()
    <TELL "Turning " THE ,PRSO " has no effect." CR>
    <RTRUE>>

<ROUTINE BOILER-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <COND (,BOILER-LIT
                       <TELL "The boiler roars with renewed life. Its pressure needle trembles in the yellow band, and heat pulses through the pipes toward the flooded wing." CR>)
                      (,BOILER-FUELED
                       <TELL "The boiler's open firebox contains fresh coal. It needs a steady flame to catch." CR>)
                      (T
                       <TELL "The boiler is a hulking iron beast. Its open firebox is black with soot and empty of usable fuel." CR>)>
                <RTRUE>)
               (<AND <VERB? BURN>
                     ,BOILER-LIT>
                <TELL "The boiler is already burning steadily." CR>
                <RTRUE>)
               (<AND <VERB? BURN>
                     <NOT ,BOILER-FUELED>>
                <TELL "A flame alone will not wake it. The firebox needs coal." CR>
                <RTRUE>)
               (<AND <VERB? BURN>
                     <NOT <EQUAL? ,PRSI ,OIL-LANTERN>>>
                <TELL "You need a sustained flame, not a momentary spark." CR>
                <RTRUE>)
               (<AND <VERB? BURN>
                     <NOT ,LANTERN-LIT-FLAG>>
                <TELL "The lantern must be lit before it can kindle the coal." CR>
                <RTRUE>)
               (<VERB? BURN>
                <TELL "You hold the lantern flame to the coal. Smoke rolls from the firebox; then orange light catches underneath. The boiler answers with a deep metallic thud as water begins moving through long-dead pipes." CR>
                <SETG BOILER-LIT T>
                <SETG BOILER-HEAT 0>
                <RTRUE>)
               (<VERB? LAMP-ON>
                <TELL "The boiler has no switch. It must be fueled and lit with a flame." CR>
                <RTRUE>)>>

<ROUTINE COAL-BIN-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE SEARCH>
                <COND (<IN? ,LUMP-OF-COAL ,COAL-BIN>
                       <TELL "Most of the coal has collapsed into wet black dust, but one solid lump could still burn. A shovel would keep the filthy slack off your hands." CR>)
                      (T
                       <TELL "Only damp coal dust remains in the bin." CR>)>
                <RTRUE>)>>

<ROUTINE COAL-F ()
         <COND (<AND <VERB? TAKE>
                     <NOT <IN? ,COAL-SHOVEL ,WINNER>>>
                <TELL "The coal lies beneath wet, oily slack. You need something broad enough to scoop it free." CR>
                <RTRUE>)
               (<VERB? TAKE>
                <TELL "Using the shovel, you pry a solid lump from the compacted coal and take it." CR>
                <MOVE ,LUMP-OF-COAL ,WINNER>
                <RTRUE>)
               (<AND <VERB? PUT>
                     <EQUAL? ,PRSI ,IRON-BOILER>>
                <COND (,BOILER-FUELED
                       <TELL "The firebox already has enough coal." CR>)
                      (T
                       <TELL "You place the coal in the boiler's firebox." CR>
                       <SETG BOILER-FUELED T>
                       <MOVE ,LUMP-OF-COAL ,IRON-BOILER>)>
                <RTRUE>)
               (<VERB? EXAMINE>
                <TELL "A dense lump of old bituminous coal, dirty but dry at its center." CR>
                <RTRUE>)>>

<ROUTINE WORKBENCH-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "The workbench is covered with ancient tools: hammers, wrenches, screwdrivers. Most are rusted solid.">
                <COND (<IN? ,FLASHLIGHT ,WORKBENCH>
                       <TELL " A flashlight lies among them.">)>
                <TELL CR>
                <RTRUE>)>>

<ROUTINE SHELVES-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE SEARCH>
                <TELL "You search through the shelves. Most items are ruined by time and moisture.">
                <COND (<OR <IN? ,OIL-LANTERN ,SHELVES> <IN? ,MEDICAL-BAG ,SHELVES> <IN? ,MEDICAL-RECORDS ,SHELVES>>
                       <TELL " Among the debris, you find">
                       <COND (<IN? ,OIL-LANTERN ,SHELVES> <TELL " a lantern">)>
                       <COND (<AND <IN? ,OIL-LANTERN ,SHELVES> <IN? ,MEDICAL-BAG ,SHELVES>> <TELL " and">)>
                       <COND (<IN? ,MEDICAL-BAG ,SHELVES> <TELL " a medical bag">)>
                       <COND (<AND <OR <IN? ,OIL-LANTERN ,SHELVES> <IN? ,MEDICAL-BAG ,SHELVES>> <IN? ,MEDICAL-RECORDS ,SHELVES>> <TELL " and">)>
                       <COND (<IN? ,MEDICAL-RECORDS ,SHELVES> <TELL " some old medical records">)>
                       <TELL ".">)>
                <TELL CR>
                <RTRUE>)>>

<ROUTINE MEDICAL-BAG-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "An old leather doctor's bag, cracked and worn.">
                <COND (<FSET? ,MEDICAL-BAG ,OPENBIT>
                       <TELL " Looking inside, you can see">
                       <COND (<IN? ,BANDAGES ,MEDICAL-BAG>
                              <TELL " some bandages">)>
                       <COND (<AND <IN? ,MORPHINE-VIAL ,MEDICAL-BAG>
                                   <IN? ,BANDAGES ,MEDICAL-BAG>>
                              <TELL " and">)>
                       <COND (<IN? ,MORPHINE-VIAL ,MEDICAL-BAG>
                              <TELL " a vial">)>
                       <TELL ".">)>
                <CRLF>
                <RTRUE>)>>

<ROUTINE BANDAGES-F ()
         <COND (<VERB? EXAMINE>
                <TELL "Yellowed cloth bandages, surprisingly clean despite their age. They might still be useful." CR>
                <RTRUE>)>>

<ROUTINE MORPHINE-VIAL-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A small glass vial labeled 'Morphine Sulfate - 10mg'. The seal is intact." CR>
                <RTRUE>)
               (<VERB? DRINK>
                <TELL "You're not desperate enough to start taking random drugs from an abandoned sanitarium." CR>
                <RTRUE>)>>

<ROUTINE STANDING-WATER-F ()
         <COND (<VERB? EXAMINE>
                <TELL "The water is cold and murky. You can't see the bottom through the darkness." CR>
                <RTRUE>)
               (<VERB? DRINK>
                <TELL "The water smells foul. You decide against it." CR>
                <RTRUE>)>>

<ROUTINE SEALED-DOOR-F ()
         <COND (<AND <VERB? EXAMINE>
                     <NOT ,STEAM-DOOR-OPEN>>
                <TELL "The " D ,SEALED-DOOR " is sealed shut, corroded in place. Steam might loosen it." CR>
                <RTRUE>)
               (<AND <VERB? EXAMINE>
                     ,STEAM-DOOR-OPEN>
                <TELL "The " D ,SEALED-DOOR " stands open, steam still wisping from its edges." CR>
                <RTRUE>)
               (<AND <VERB? OPEN>
                     <NOT ,STEAM-DOOR-OPEN>
                     <NOT ,VALVE-TURNED-FLAG>>
                <TELL "The " D ,SEALED-DOOR " won't budge. It's corroded shut." CR>
                <RTRUE>)
               (<AND <VERB? OPEN>
                     <NOT ,STEAM-DOOR-OPEN>
                     ,VALVE-TURNED-FLAG>
                <TELL "The steam from the opened " D ,VALVE " has loosened the corrosion. With effort, you wrench the " D ,SEALED-DOOR " open. It leads to a hydrotherapy room." CR>
                <SETG STEAM-DOOR-OPEN T>
                <RTRUE>)>>

<ROUTINE TUBS-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "The tubs are large enough to immerse a full-grown person. Leather restraints are bolted to the sides. Dark stains ring the waterline. One tub contains a soggy notebook." CR>
                <RTRUE>)>>

<ROUTINE MEDICINE-CABINET-F ()
         <COND (<AND <VERB? EXAMINE LOOK-INSIDE>
                     <NOT ,CABINET-THAWED>>
                <TELL "Frost has welded the medicine cabinet shut. Through the clouded glass you can just make out a syringe. Scraping removes only powder before the ice hardens again; the pipes behind the wall would have to warm." CR>
                <RTRUE>)
               (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "Meltwater runs down the cabinet door. Inside, among ruined dressings, a glass syringe remains usable." CR>
                <RTRUE>)
               (<AND <VERB? OPEN>
                     <NOT ,CABINET-THAWED>>
                <TELL "The frost holds the door more firmly than any lock." CR>
                <RTRUE>)
               (<AND <VERB? OPEN>
                     ,CABINET-THAWED
                     <NOT <FSET? ,MEDICINE-CABINET ,OPENBIT>>>
                <TELL "You pull the thawed cabinet open. Meltwater patters onto the tile." CR>
                <FSET ,MEDICINE-CABINET ,OPENBIT>
                <RTRUE>)>>

<ROUTINE CELL-DOORS-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "Each door is solid metal with a small barred window. The cells beyond are empty save for scratches covering every surface. Someone marked time here, day after agonizing day." CR>
                <RTRUE>)>>

<ROUTINE WALL-SCRATCHES-F ()
         <COND (<VERB? EXAMINE COUNT>
                <TELL "The scratches are too numerous to count. They cover every inch of the cell walls. Some form words: 'HELP ME' 'NO MORE' 'PLEASE'. One message is larger than the rest: 'PATIENT 189 STILL ALIVE IN THE CHAPEL'." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "You run your fingers over the scratches. They're deep—gouged by fingernails over years of desperation." CR>
                <RTRUE>)
               (<VERB? READ>
                <TELL "Among the chaos of scratches, you can make out words: 'HELP ME' 'NO MORE' 'PLEASE'. The largest message reads: 'PATIENT 189 STILL ALIVE IN THE CHAPEL'.">
                <TELL " And then, in a corner, smaller and more recent: the date '1947' and a single word—'remember'—carved with unusual precision." CR>
                <COND (<NOT ,WALL-SCRATCHES-LORE>
                       <SETG WALL-SCRATCHES-LORE T>
                       <SETG PATIENT-LORE <+ ,PATIENT-LORE 1>>)>
                <RTRUE>)>>

<ROUTINE SHOCK-CHAIR-F ()
         <COND (<VERB? EXAMINE>
                <TELL "The chair is bolted to the floor. Leather restraints hang from the arms and legs, polished smooth where wrists and ankles fought them. Electrodes wait at temple height; beneath one, the metal has been bitten through." CR>
                <RTRUE>)
               (<VERB? BOARD>
                <TELL "You have no desire to sit in that terrible chair." CR>
                <RTRUE>)
               (<VERB? SIT>
                <TELL "You have no desire to sit in that terrible chair." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "You touch the cold metal armrest. The leather restraints feel disturbingly well-worn. You pull your hand away quickly." CR>
                <RTRUE>)
               (<VERB? PUSH PULL>
                <TELL "The chair is bolted firmly to the floor. It doesn't budge." CR>
                <RTRUE>)>>

<ROUTINE SHOCK-MACHINE-F ()
         <COND (<VERB? EXAMINE>
                <TELL "The machine has various dials and switches. Labels indicate voltage levels up to dangerous levels. The electrodes are stained dark." CR>
                <RTRUE>)
               (<VERB? TURN SWITCH-ON>
                <COND (<IN? ,WINNER ,SHOCK-CHAIR>
                       <JIGS-UP "The switch closes with a hard ceramic snap. White fire crosses the electrodes, and the room vanishes before you can scream.">)
                      (T
                       <TELL "You throw the switch. A blue arc cracks between the empty electrodes, filling the room with the smell of scorched dust. You shut it off before the ancient wiring can do worse." CR>)>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "You touch one of the electrodes. It's cold and stained with something dark. You feel a faint tingle and quickly pull your hand away." CR>
                <RTRUE>)>>

<ROUTINE PADDING-F ()
         <COND (<VERB? EXAMINE READ>
                <TELL "The padding is torn and moldering. On one wall, written in what appears to be dried blood, are the words: 'THE CHAPEL BEYOND THE GARDEN. HE WAITS THERE. PATIENT 189.'." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "You touch the rotting padding. It's damp and spongy, falling apart at the slightest pressure." CR>
                <RTRUE>)
               (<VERB? SMELL>
                <TELL "The padding reeks of mildew, decay, and something else—the sour smell of old fear." CR>
                <RTRUE>)
               (<VERB? PULL>
                <TELL "The padding tears away in chunks when you pull it, but there's nothing behind it but more rot." CR>
                <RTRUE>)>>

<ROUTINE STRAITJACKET-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A heavy canvas straitjacket with multiple leather buckles and straps. Dark stains cover the fabric. On the collar—a name tag, the ink nearly faded.">
                <COND (<NOT ,STRAITJACKET-LORE>
                       <SETG STRAITJACKET-LORE T>
                       <SETG PATIENT-LORE <+ ,PATIENT-LORE 1>>
                       <TELL " You can make out a few letters, a date. The handwriting seems... familiar.">)
                      (T
                       <TELL " The name on the tag is illegible now, but the date is clear: 1947.">)>
                <TELL CR>
                <RTRUE>)
               (<VERB? READ>
                <TELL "The tag reads a name—the ink is smeared, but the date is unmistakable. 1947. Five years before the sanitarium closed. You stare at it longer than you meant to." CR>
                <RTRUE>)
               (<VERB? WEAR>
                <TELL "You'd rather not." CR>
                <RTRUE>)
               (<VERB? SMELL>
                <TELL "The straitjacket smells of sweat, fear, and something metallic—perhaps old blood." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "The canvas is rough and stiff. The stains feel crusty under your fingers." CR>
                <RTRUE>)>>

<ROUTINE MIRROR-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <COND (<G? ,PATIENT-LORE 0>
                       <TELL "Through the mirror, you can see the electroshock theater below. The shock chair sits in the center.">
                       <TELL " In the glass, your reflection is barely visible—a dark shape that seems to shift when you try to focus on it. You look away." CR>)
                      (T
                       <TELL "Through the mirror, you can see the electroshock theater below. The shock chair sits in the center like a throne of suffering." CR>)>
                <RTRUE>)>>

<ROUTINE OBSERVATION-LOGBOOK-F ()
         <COND (<VERB? READ EXAMINE>
                <TELL "The logbook contains clinical observations of treatments. One entry stands out: 'Session 47 - Patient 189. Subject required maximum voltage. Seizure lasted 4 minutes. Memory loss total. Subject claims to be someone else now. Dr. Mordecai pleased with results. Proceeding to next phase.'" CR>
                <RTRUE>)>>

<ROUTINE SCATTERED-PAPERS-F ()
         <COND (<VERB? EXAMINE READ SEARCH>
                <TELL "You sort through the papers. Most are mundane: supply orders, staff schedules, building maintenance. One memo catches your eye: 'All staff reminded - Subject 189 is NOT to be released under any circumstances. Chapel is OFF LIMITS.'." CR>
                <RTRUE>)>>

<ROUTINE MASSIVE-DESK-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "The desk is made of dark wood, highly polished. The drawers contain mostly empty folders and pens." CR>
                <RTRUE>)>>

<ROUTINE HOLLOW-BOOK-F ()
         <COND (<AND <VERB? EXAMINE>
                     <NOT <FSET? ,HOLLOW-BOOK ,OPENBIT>>>
                <TELL "A red leather tome with a blank spine where all others are labeled. It has a small brass latch on the edge, not a proper binding." CR>
                <RTRUE>)
               (<AND <VERB? EXAMINE>
                     <FSET? ,HOLLOW-BOOK ,OPENBIT>>
                <TELL "The book is open, its pages glued together to form a hollow cavity. " <COND (<IN? ,SAFE-KEY ,HOLLOW-BOOK> <TELL "Inside rests a small key.">)(<ELSE> <TELL "The cavity is empty.">)> CR>
                <RTRUE>)
               (<AND <VERB? OPEN>
                     <NOT <FSET? ,HOLLOW-BOOK ,OPENBIT>>>
                <TELL "You flip the brass latch and open the book. The pages are glued solid—it's not a book at all, but a hollow hiding place. Inside you find a small key." CR>
                <FSET ,HOLLOW-BOOK ,OPENBIT>
                <RTRUE>)
               (<VERB? READ>
                <TELL "The pages are glued together. It's a hollow hiding place, not a real book." CR>
                <RTRUE>)>>

<ROUTINE PORTRAIT-F ()
         <COND (<VERB? EXAMINE>
                <TELL "The portrait shows Dr. Mordecai, a gaunt man with piercing eyes and a cruel mouth. The nameplate reads: 'Dr. Heinrich Mordecai - Director 1935-1952'. His eyes seem to follow you around the room." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "You reach out to touch the portrait. The paint feels oddly warm. You could swear the eyes moved." CR>
                <RTRUE>)
               (<VERB? TAKE>
                <TELL "The portrait is securely fastened to the wall. Besides, you have no desire to carry that man's visage with you." CR>
                <RTRUE>)
               (<VERB? ATTACK>
                <TELL "You consider defacing the portrait, but something stops you. Those painted eyes seem to dare you to try." CR>
                <RTRUE>)>>

<ROUTINE WALL-SAFE-F ()
         <COND (<AND <VERB? EXAMINE>
                     <FSET? ,WALL-SAFE ,OPENBIT>>
                <TELL "The safe is open. Inside you can see its contents." CR>
                <RTRUE>)
               (<AND <VERB? EXAMINE>
                     <NOT <FSET? ,WALL-SAFE ,OPENBIT>>>
                <TELL "The safe is locked. It requires a key." CR>
                <RTRUE>)
               (<AND <VERB? OPEN UNLOCK>
                     <FSET? ,WALL-SAFE ,OPENBIT>>
                <TELL "The safe is already open." CR>
                <RTRUE>)
               (<AND <VERB? OPEN UNLOCK>
                     <NOT <FSET? ,WALL-SAFE ,OPENBIT>>
                     <NOT <IN? ,SAFE-KEY ,WINNER>>>
                <TELL "The safe is locked. You need the key." CR>
                <RTRUE>)
               (<AND <VERB? OPEN UNLOCK>
                     <NOT <FSET? ,WALL-SAFE ,OPENBIT>>
                     <IN? ,SAFE-KEY ,WINNER>>
                <TELL "You unlock the " D ,WALL-SAFE " with the " D ,SAFE-KEY ". Inside are Dr. Mordecai's private notes and a " D ,CHAPEL-KEY "." CR>
                <FSET ,WALL-SAFE ,OPENBIT>
                <RTRUE>)>>

<ROUTINE SAFE-KEY-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A small brass key with a tag reading 'S-001'. It looks like a safe key." CR>
                <RTRUE>)>>

<ROUTINE MORDECAI-NOTES-F ()
         <COND (<VERB? READ EXAMINE>
                <TELL "The notes are written in a shaking hand: 'October 30, 1952 - The experiment succeeded beyond my wildest expectations. Patient 189 has transcended death itself. But the cost... the screaming never stops. I hear it in my sleep. The others want to shut down the sanitarium. Fools! They don't understand what we've achieved. The chapel must remain locked. What I've created must never escape.'" CR>
                <RTRUE>)>>

<ROUTINE CHAPEL-KEY-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A heavy iron key with a cross engraved on its head. The key feels unnaturally cold." CR>
                <RTRUE>)>>

<ROUTINE LOCKERS-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE SEARCH>
                <TELL "Most lockers are empty or contain rotted clothing. One locker holds a nurse's uniform and a photograph." CR>
                <RTRUE>)>>

<ROUTINE PHOTOGRAPH-F ()
         <COND (<VERB? EXAMINE>
                <TELL "The photograph shows the sanitarium staff posed outside the building. Dr. Mordecai stands in the center, unsmiling. Written on the back: 'Staff photo 1950. Two years before they closed us down. Two years before everything went wrong.'" CR>
                <RTRUE>)>>

<ROUTINE COUNTER-F ()
         <COND (<VERB? EXAMINE LOOK-INSIDE>
                <TELL "The serving counter is thick with dust. Old menus are still posted on the wall: 'Monday - Mystery Meat'. A bell for summoning kitchen staff sits on the counter." CR>
                <RTRUE>)>>

<ROUTINE BELL-F ()
         <COND (<VERB? RING>
                <TELL "You ring the bell. The tinny sound echoes through " THE ,HERE ". No one comes." CR>
                <RTRUE>)
               (<VERB? EXAMINE>
                <TELL "A small brass bell with a button on top. It still works." CR>
                <RTRUE>)
               (<VERB? LISTEN>
                <TELL "The bell makes a clear ringing sound when struck." CR>
                <RTRUE>)
               (<VERB? SHAKE>
                <TELL "You shake the bell. It rings with a cheerful tone that seems out of place in this dead building." CR>
                <RTRUE>)>>

<ROUTINE DEAD-GARDEN-F ()
         <COND (<VERB? EXAMINE SEARCH>
                <TELL "The garden has been dead for decades. Thorny vines choke what remains of flower beds. Among the weeds, you can see broken stone benches and a crumbling fountain." CR>
                <RTRUE>)
               (<AND <VERB? DIG>
                     <IN? ,COAL-SHOVEL ,WINNER>>
                <TELL "You dig into the dead earth with the shovel. The soil is dry and lifeless. After a few moments, you give up—nothing but rocks and roots here." CR>
                <RTRUE>)
               (<AND <VERB? DIG>
                     <NOT <IN? ,COAL-SHOVEL ,WINNER>>>
                <TELL "You'd need a shovel or similar tool to dig here." CR>
                <RTRUE>)
               (<VERB? SMELL>
                <TELL "The garden smells of decay and rot, with an underlying odor of something else—something chemical and wrong." CR>
                <RTRUE>)>>

<ROUTINE CHAPEL-DOOR-F ()
         <COND (<AND <VERB? EXAMINE>
                     <NOT ,CHAPEL-UNLOCKED>>
                <TELL "The door is made of thick oak bound with iron straps. A large iron lock secures it. Above the door, carved words read: 'HE WHO ENTERS ABANDONS HOPE'." CR>
                <RTRUE>)
               (<AND <VERB? EXAMINE>
                     ,CHAPEL-UNLOCKED>
                <TELL "The door stands open, darkness visible beyond." CR>
                <RTRUE>)
               (<AND <VERB? OPEN UNLOCK>
                     <NOT ,CHAPEL-UNLOCKED>
                     <NOT <IN? ,CHAPEL-KEY ,WINNER>>>
                <TELL "The door is locked. You need the " D ,CHAPEL-KEY "." CR>
                <RTRUE>)
               (<AND <VERB? OPEN UNLOCK>
                     <NOT ,CHAPEL-UNLOCKED>
                     <IN? ,CHAPEL-KEY ,WINNER>>
                <TELL "You insert the " D ,CHAPEL-KEY " into the lock. It turns with a heavy clunk. The door swings open slowly, revealing darkness beyond. A foul wind rushes out, carrying the scent of decay." CR>
                <SETG CHAPEL-UNLOCKED T>
                <RTRUE>)
               (<VERB? READ>
                <TELL "The words carved above the door read: 'HE WHO ENTERS ABANDONS HOPE'." CR>
                <RTRUE>)
               (<VERB? KNOCK>
                <TELL "You knock on the heavy oak door. The sound echoes dully, and you think you hear something shift on the other side." CR>
                <RTRUE>)
               (<VERB? LISTEN>
                <TELL "You press your ear against the door. From within comes a faint sound—breathing? Or just the wind?" CR>
                <RTRUE>)>>

<ROUTINE PATIENT-189-RESOLUTION-F ()
    <COND (<AND <IN? ,ANCIENT-RELIC ,WINNER>
                <IN? ,STRANGE-SERUM ,WINNER>
                <IN? ,SYRINGE ,WINNER>>
           <TELL "You hold out the relic. Patient 189 stills completely. You draw the serum into the syringe and step forward—every instinct screaming—and inject it." CR>
           <TELL "The green light in its eyes gutters. Patient 189 shudders, mouth opening in a soundless cry. The green flames around the chapel gutter and die." CR>
           <TELL "Then it speaks, in a voice like someone remembering how: 'I remember... who I was.'" CR>
           <COND (<G? ,PATIENT-LORE 4>
                  <TELL " It looks into you, and the missing years return—not as a story you learned, but as your own memory: the straps, Mordecai's voice, the name Patient 189 replacing yours. The figure is not your double. It is the pain they cut away from you and locked here. When you take its hand, it folds into your shadow, and for the first time since 1947 you are whole." CR>)
                 (<G? ,PATIENT-LORE 2>
                  <TELL " It looks at you with recognition—not as a stranger, but as someone who understands what it endured." CR>)
                 (T
                  <TELL " Its eyes pass over you without recognition. You freed it, but it never knew you." CR>)>
           <TELL "It crumbles to ash. The candles go out. The air suddenly smells like rain and grass—ordinary, living air. You're free." CR>
           <SETG GAME-WON T>
           <SETG PATIENT-STATE 3>
           <SCORE-UPD 6>
           <REMOVE ,PATIENT-189>
           <RTRUE>)
          (<IN? ,ANCIENT-RELIC ,WINNER>
           <TELL "The relic glows warm. Patient 189 shivers, eyes flickering. But something still binds it. The serum—if returned to its source..." CR>
           <RTRUE>)
          (<G? ,PATIENT-STATE 1>
           <TELL "Patient 189 acknowledges you—a slight inclination of the head. But words alone won't end this. You need the means to free it." CR>
           <RTRUE>)
          (T
           <TELL "Patient 189 tilts its head. Green light flares in its eyes. Something cold reaches into your chest. You are not ready." CR>
           <RTRUE>)>>

<ROUTINE SHOW-HINT (KEY ATTENTION DIRECTION ACTION COMMAND)
    <COND (<EQUAL? ,HINT-KEY .KEY>
           <COND (<L? ,HINT-LEVEL 4>
                  <SETG HINT-LEVEL <+ ,HINT-LEVEL 1>>)>)
          (T
           <SETG HINT-KEY .KEY>
           <SETG HINT-LEVEL 1>)>
    <COND (<EQUAL? ,HINT-LEVEL 1> <TELL .ATTENTION CR>)
          (<EQUAL? ,HINT-LEVEL 2> <TELL .DIRECTION CR>)
          (<EQUAL? ,HINT-LEVEL 3> <TELL .ACTION CR>)
          (T <TELL .COMMAND CR>)>
    <RTRUE>>

<ROUTINE V-HINTS ()
    <COND (<NOT ,CHAINS-CUT-FLAG>
           <SHOW-HINT 1
              "The chained morgue door is meant to be opened."
              "The operating theater contains a cutting instrument."
              "Take the scalpel and use it on the chains."
              "ATTACK CHAINS WITH SCALPEL">)
          (<NOT ,VALVE-TURNED-FLAG>
           <SHOW-HINT 2
              "The sealed eastern door needs more than muscle."
              "Follow the basement pipes back toward their valve."
              "Open the valve in the basement corridor to release steam."
              "TURN VALVE">)
          (<NOT ,CABINET-THAWED>
           <SHOW-HINT 3
              "The syringe is visible, but the frozen cabinet will not open."
              "The boiler-room pipes run toward hydrotherapy."
              "Use the shovel to recover coal, put it in the boiler, then kindle it with the lit lantern."
              "TAKE SHOVEL; TAKE COAL; PUT COAL IN BOILER; LIGHT LANTERN; KINDLE BOILER WITH LANTERN; WAIT">)
          (<NOT ,CHAPEL-UNLOCKED>
           <SHOW-HINT 4
              "The chapel key was kept somewhere only Mordecai could reach."
              "Search the director's office carefully."
              "A conspicuous book hides the safe key; the safe contains the chapel key."
              "OPEN BOOK; TAKE SAFE KEY; UNLOCK SAFE WITH SAFE KEY; TAKE CHAPEL KEY">)
          (<NOT <FSET? ,WOODEN-BOX ,OPENBIT>>
           <SHOW-HINT 5
              "Patient 189 keeps looking toward the altar."
              "Examine the wooden box beneath it."
              "The scalpel can pry the rusted clasp apart."
              "OPEN BOX">)
          (<NOT ,GAME-WON>
           <SHOW-HINT 6
              "Three objects connect Mordecai's experiment to Patient 189."
              "You need the relic, the serum, and the syringe."
              "Carry all three to Patient 189 and use the syringe."
              "INJECT PATIENT WITH SYRINGE">)
          (T
           <TELL "The ordinary night air is answer enough." CR>)>>

<ROUTINE V-SCRAPE ()
    <COND (<EQUAL? ,PRSO ,MEDICINE-CABINET>
           <COND (,CABINET-THAWED
                  <TELL "The remaining frost wipes away beneath your fingers." CR>)
                 (T
                  <TELL "You scrape away a patch of frost, but new crystals creep across the exposed metal almost immediately. The cabinet needs sustained heat." CR>)>)
          (T
           <TELL "Scraping it accomplishes nothing." CR>)>
    <RTRUE>>

<ROUTINE V-INJECT ()
    <COND (<NOT <EQUAL? ,PRSI ,SYRINGE>>
           <TELL "That is not suitable for an injection." CR>)
          (<EQUAL? ,PRSO ,WINNER>
           <JIGS-UP "The serum enters your vein like ice. For one lucid instant you remember the chapel from inside its locked door; then a green light opens behind your eyes and never closes.">)
          (<NOT <EQUAL? ,PRSO ,PATIENT-189>>
           <TELL "You have no reason to inject " THE ,PRSO "." CR>)
          (<NOT <IN? ,SYRINGE ,WINNER>>
           <TELL "You need to be holding the syringe." CR>)
          (T
           <PATIENT-189-RESOLUTION-F>)>
    <RTRUE>>

<ROUTINE V-IGNITE ()
    <COND (<NOT <EQUAL? ,PRSO ,IRON-BOILER>>
           <TELL "You cannot safely ignite " THE ,PRSO "." CR>)
          (<NOT <EQUAL? ,PRSI ,OIL-LANTERN>>
           <TELL "That will not provide a steady flame." CR>)
          (<NOT <OR ,BOILER-FUELED <IN? ,LUMP-OF-COAL ,IRON-BOILER>>>
           <TELL "The boiler's firebox needs coal first." CR>)
          (<NOT ,LANTERN-LIT-FLAG>
           <TELL "The lantern must be lit first." CR>)
          (,BOILER-LIT
           <TELL "The boiler is already burning steadily." CR>)
          (T
           <TELL "You hold the lantern flame to the coal. Smoke rolls from the firebox; then orange light catches underneath. The boiler answers with a deep metallic thud as water begins moving through long-dead pipes." CR>
           <SETG BOILER-FUELED T>
           <SETG BOILER-LIT T>
           <SETG BOILER-HEAT 0>)>
    <RTRUE>>

<ROUTINE V-SAY-HELLO ()
    <COND (<AND <EQUAL? ,HERE ,CHAPEL>
                <IN? ,PATIENT-189 ,CHAPEL>>
           <PATIENT-189-RESOLUTION-F>)
          (T
           <TELL "Your greeting receives no answer, but at least the building does not mistake it for a farewell." CR>)>>

<ROUTINE V-HELLO ()
    <V-SAY-HELLO>>

<ROUTINE V-BARE-HELLO ()
    <TELL "Your greeting receives no answer, but at least the building does not mistake it for a farewell. If you mean to address someone, try SAY HELLO." CR>
    <RTRUE>>

<ROUTINE V-GREET-OBJECT ()
    <COND (<FSET? ,PRSO ,ACTORBIT>
           <TELL THE ,PRSO " bows his head to you in greeting." CR>)
          (T
           <TELL "Your greeting is wasted on " THE ,PRSO "." CR>)>
    <RTRUE>>

<ROUTINE V-LISTEN-AROUND ()
    <COND (,GAME-WON
           <TELL "For the first time, the building is quiet: no whispers, no footsteps, only wind moving through broken glass." CR>)
          (<EQUAL? ,HERE ,BOILER-ROOM>
           <TELL "Water ticks in the pipes and coal shifts softly in the bin." CR>)
          (<EQUAL? ,HERE ,OVERGROWN-GARDEN ,SANITARIUM-GATE>
           <TELL "The crows make no sound. Far off, branches scrape against stone." CR>)
          (T
           <TELL "Beyond your breathing, the sanitarium answers with a distant creak and something that might be a footstep." CR>)>
    <RTRUE>>

<ROUTINE V-SMELL-AROUND ()
    <COND (,GAME-WON
           <TELL "Rain, wet stone, and grass—the ordinary smells of a night outside." CR>)
          (<EQUAL? ,HERE ,SANITARIUM-ENTRANCE>
           <TELL "Mildew, wet plaster, and the mineral chill of a long-sealed building." CR>)
          (<EQUAL? ,HERE ,STORAGE-ROOM>
           <TELL "Moldy linen and a sour medicinal residue catch at the back of your throat." CR>)
          (<EQUAL? ,HERE ,PADDED-CELL>
           <TELL "Wet padding, rust, and the copper trace of old blood." CR>)
          (T
           <TELL "The air smells of damp stone, dust, and something antiseptic that decades have not erased." CR>)>
    <RTRUE>>

<ROUTINE V-SIT-DOWN ()
    <COND (<EQUAL? ,HERE ,CHAPEL>
           <TELL "You sit briefly on a pew; the carved wood is cold enough to drive you back to your feet." CR>)
          (T
           <TELL "You lower yourself for a moment, then decide this is no place to become comfortable." CR>)>
    <RTRUE>>

<ROUTINE CHAPEL-FCN (RARG)
    <COND (<EQUAL? .RARG ,M-LOOK>
           <COND (,GAME-WON
                  <TELL "The chapel is just a room now. The candles are dark. The altar is bare. Whatever was here is gone -- and so is whatever held you." CR>)
                 (T
                   <TELL "The chapel is small and suffocating. Cold green light from unnatural candles makes everything look like a corpse.">
                  <COND (<NOT ,PATIENT-STATE>
                         <SETG PATIENT-STATE 1>)>
                  <TELL CR>)>
           <RTRUE>)>>

<ROUTINE PEWS-F ()
         <COND (<VERB? EXAMINE>
                <TELL "The PEWS are ancient and rotting. Strange symbols are carved into the wood—symbols that hurt to look at." CR>
                <RTRUE>)
               (<VERB? BOARD SIT>
                <TELL "You sit on one of the pews. The wood is cold and uncomfortable. The symbols carved into it seem to pulse beneath your hands, and you quickly stand back up." CR>
                <RTRUE>)
               (<VERB? PRAY>
                <TELL "You bow your head and try to pray, but the words die in your throat. This place mocks faith." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "You run your fingers over the carved symbols. They're strangely warm to the touch, and you quickly pull your hand away." CR>
                <RTRUE>)>>

<ROUTINE GREEN-CANDLES-F ()
         <COND (,GAME-WON
                <COND (<VERB? EXAMINE>
                       <TELL "The candles are cold and dark now, their green glow extinguished forever. Ordinary wax, nothing more." CR>
                       <RTRUE>)
                      (<VERB? LAMP-OFF BLOW>
                       <TELL "The candles are already dark. There's nothing to extinguish." CR>
                       <RTRUE>)
                      (<VERB? LAMP-ON>
                       <TELL "The candles will never burn again." CR>
                       <RTRUE>)>)
               (<VERB? EXAMINE>
                <TELL "The CANDLES burn with green flames that give off no heat. The light makes everything look diseased." CR>
                <RTRUE>)
               (<VERB? LAMP-OFF>
                <TELL "You try to extinguish the candles, but the green flames resist. No amount of blowing can put them out. They burn with an unnatural persistence." CR>
                <RTRUE>)
               (<VERB? BLOW>
                <TELL "You try to blow out the candles, but the green flames refuse to be extinguished." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "You reach toward the flame, expecting heat. Instead, you feel only cold—a deep, bone-chilling cold that makes you recoil." CR>
                <RTRUE>)
               (<VERB? TAKE>
                <TELL "The candles seem fixed in place, as if welded to their holders. They won't budge." CR>
                <RTRUE>)>>

<ROUTINE WOODEN-BOX-F ()
         <COND (<AND <VERB? EXAMINE>
                     <NOT <FSET? ,WOODEN-BOX ,OPENBIT>>>
                <TELL "A small wooden box sits beneath the altar. It's locked tight with an iron clasp." CR>
                <RTRUE>)
               (<AND <VERB? EXAMINE>
                     <FSET? ,WOODEN-BOX ,OPENBIT>>
                <TELL "The box is now open. " <COND (<IN? ,ANCIENT-RELIC ,WOODEN-BOX> <TELL "Inside is an ancient relic.">)(<ELSE> <TELL "It's empty.">)> CR>
                <RTRUE>)
               (<AND <VERB? OPEN>
                     <NOT <FSET? ,WOODEN-BOX ,OPENBIT>>
                     <NOT <IN? ,SCALPEL ,WINNER>>>
                <TELL "The lock is rusted but holds fast. You need something to pry it open." CR>
                <RTRUE>)
               (<AND <VERB? OPEN>
                     <NOT <FSET? ,WOODEN-BOX ,OPENBIT>>
                     <IN? ,SCALPEL ,WINNER>>
                <TELL "You use the scalpel to pry open the rusted clasp. The box opens with a creak, revealing an ancient relic inside." CR>
                <FSET ,WOODEN-BOX ,OPENBIT>
                <RTRUE>)>>

<ROUTINE ANCIENT-RELIC-F ()
         <COND (<VERB? EXAMINE>
                <TELL "An ancient silver cross, tarnished black with age. Strange symbols are etched into its surface—symbols that seem to writhe when you look directly at them. Despite its age, it radiates a strange warmth." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "The cross feels unnaturally warm in your hand. The symbols seem to pulse under your touch." CR>
                <RTRUE>)
               (<VERB? PRAY>
                <TELL "You clutch the cross and try to pray. The symbols grow warmer, almost hot, as if responding to your faith—or mocking it." CR>
                <RTRUE>)
               (<VERB? THROW>
                <TELL "The cross seems too important to discard." CR>
                <RTRUE>)
               (<VERB? GIVE>
                <COND (<EQUAL? ,PRSI ,PATIENT-189>
                       <RFALSE>)
                      (T
                       <TELL "The cross seems too important to give away." CR>
                       <RTRUE>)>)>>

<ROUTINE PATIENT-189-F ()
         <COND (<VERB? EXAMINE>
                <TELL "PATIENT 189 stands impossibly still. Its skin is pale as death, its eyes glowing faintly green.">
                <COND (<G? ,PATIENT-STATE 1>
                       <TELL " Its gaze follows you now, tracking your movements with a terrible patience.">)
                      (T
                       <TELL " It watches you with an intelligence that is distinctly not human.">)>
                <TELL CR>
                <RTRUE>)
               (<AND <VERB? TELL>
                     <EQUAL? ,PRSI ,TOPIC-MORDECAI>>
                <COND (<NOT <FSET? ,TOPIC-MORDECAI ,TOUCHBIT>>
                       <FSET ,TOPIC-MORDECAI ,TOUCHBIT>
                       <TELL "You speak the name. Patient 189's eyes flare, the green intensifying. Its jaw works soundlessly, as if trying to form words long forgotten." CR>
                       <SETG PATIENT-LORE <+ ,PATIENT-LORE 1>>)
                      (T
                       <TELL "Patient 189 responds to the name again—a spasm, quickly suppressed, as if even remembering is painful." CR>)>
                <SETG PATIENT-STATE 2>
                <RTRUE>)
               (<AND <VERB? TELL>
                     <EQUAL? ,PRSI ,TOPIC-TREATMENT>>
                <COND (<NOT <FSET? ,TOPIC-TREATMENT ,TOUCHBIT>>
                       <FSET ,TOPIC-TREATMENT ,TOUCHBIT>
                       <TELL "At the word, Patient 189 shudders. Its hands—claw-like, translucent—rise to its temples. You realize it is miming the electrode placement. A memory. A very bad one." CR>
                       <SETG PATIENT-LORE <+ ,PATIENT-LORE 1>>)
                      (T
                       <TELL "Patient 189 lowers its hands slowly. Its expression never changes, but something in the tilt of its head conveys a bottomless weariness." CR>)>
                <SETG PATIENT-STATE 2>
                <RTRUE>)
               (<AND <VERB? TELL>
                     <EQUAL? ,PRSI ,TOPIC-IDENTITY>>
                <COND (<NOT <FSET? ,TOPIC-IDENTITY ,TOUCHBIT>>
                       <FSET ,TOPIC-IDENTITY ,TOUCHBIT>
                       <TELL "Patient 189 stills completely. Its lips part. A sound emerges—not a word, but a tone, a single note held impossibly long like a tuning fork. It fades. Then, almost inaudibly: '...remember...'" CR>
                       <SETG PATIENT-LORE <+ ,PATIENT-LORE 1>>)
                      (T
                       <TELL "Patient 189 watches you silently. Whatever it might have said is gone now, lost in years of isolation." CR>)>
                <SETG PATIENT-STATE 2>
                <RTRUE>)
               (<AND <VERB? TELL>
                     <EQUAL? ,PRSI ,TOPIC-SANITARIUM>>
                <COND (<NOT <FSET? ,TOPIC-SANITARIUM ,TOUCHBIT>>
                       <FSET ,TOPIC-SANITARIUM ,TOUCHBIT>
                       <TELL "Patient 189 tilts its head toward the chapel ceiling, toward the building above. When it looks back at you, there is something new in those green eyes—a plea, perhaps. Or an accusation." CR>
                       <SETG PATIENT-LORE <+ ,PATIENT-LORE 1>>)
                      (T
                       <TELL "Patient 189's gaze drifts upward, then returns to you. The silent exchange is complete: you both know what this place is." CR>)>
                <SETG PATIENT-STATE 2>
                <RTRUE>)
               (<AND <VERB? TELL>
                     <EQUAL? ,PRSI ,TOPIC-CHAPEL>>
                <COND (<NOT <FSET? ,TOPIC-CHAPEL ,TOUCHBIT>>
                       <FSET ,TOPIC-CHAPEL ,TOUCHBIT>
                       <TELL "Patient 189 gestures—the first real movement you've seen—toward the altar, toward the wooden box beneath it. The meaning is clear: what lies in that box matters." CR>
                       <SETG PATIENT-LORE <+ ,PATIENT-LORE 1>>)
                      (T
                       <TELL "Patient 189's eyes return to the altar. Whatever waits there, it has waited a very long time." CR>)>
                <SETG PATIENT-STATE 2>
                <RTRUE>)
               (<AND <VERB? ATTACK KILL MUNG>
                     <NOT ,GAME-WON>>
                <TELL "You cannot bring yourself to approach it. Some primal instinct holds you back." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "You reach toward Patient 189, but stop yourself. The air around it feels wrong—cold and electric." CR>
                <RTRUE>)
               (<VERB? GIVE>
                <COND (<EQUAL? ,PRSO ,ANCIENT-RELIC>
                       <PATIENT-189-RESOLUTION-F>)
                      (T
                       <TELL "Patient 189 shows no interest in that. It simply watches you with those glowing eyes." CR>
                       <RTRUE>)>)>>

<ROUTINE DRAWER-F ()
         <COND (<AND <VERB? EXAMINE>
                     <NOT <FSET? ,BOTTOM-DRAWER ,OPENBIT>>>
                <TELL "The bottom drawer of the desk is locked. The keyhole has the number '3' engraved beside it." CR>
                <RTRUE>)
               (<AND <VERB? EXAMINE>
                     <FSET? ,BOTTOM-DRAWER ,OPENBIT>>
                <TELL "The drawer is open. Inside you can see a leather-bound ledger and a patient file." CR>
                <RTRUE>)
               (<AND <VERB? OPEN>
                     <FSET? ,BOTTOM-DRAWER ,OPENBIT>>
                <TELL "The drawer is already open." CR>
                <RTRUE>)
               (<AND <VERB? OPEN UNLOCK>
                     <NOT <FSET? ,BOTTOM-DRAWER ,OPENBIT>>
                     <NOT <IN? ,BRASS-KEY ,WINNER>>>
                <TELL "The drawer is locked. You need a key." CR>
                <RTRUE>)
               (<AND <VERB? OPEN UNLOCK>
                     <NOT <FSET? ,BOTTOM-DRAWER ,OPENBIT>>
                     <IN? ,BRASS-KEY ,WINNER>>
                <TELL "You insert the brass key into the lock. It turns smoothly. The drawer slides open, revealing a leather-bound ledger and a patient file inside." CR>
                <FCLEAR ,BOTTOM-DRAWER ,NDESCBIT>
                <FSET ,BOTTOM-DRAWER ,OPENBIT>
                <RTRUE>)>>

<ROUTINE LEDGER-F ()
         <COND (<VERB? READ EXAMINE>
                <TELL "The ledger contains patient records spanning decades. The entries become more disturbing toward the end. The final entry reads: 'Patient 237 - Treatment discontinued. Subject expired during procedure. Dr. Mordecai. May God have mercy on us all.'" CR>
                <RTRUE>)>>

<ROUTINE SCALPEL-F ()
         <COND (<VERB? EXAMINE>
                <TELL "The scalpel's blade is rusty but still razor-sharp along one edge. The handle is stained with something dark." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "You carefully touch the blade. It's still very sharp—sharp enough to cut." CR>
                <RTRUE>)
               (<VERB? THROW>
                <TELL "You're not about to throw away a potentially useful tool." CR>
                <RTRUE>)>>

<ROUTINE ETHER-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A glass bottle with a faded label reading 'Ether - Handle with Care'. About a quarter of the liquid remains." CR>
                <RTRUE>)
               (<VERB? DRINK>
                <TELL "That would be an extremely bad idea." CR>
                <RTRUE>)
               (<VERB? SMELL>
                <TELL "You carefully sniff the bottle. The sweet, sickly smell of ether makes your head spin. You quickly cap it again." CR>
                <RTRUE>)
               (<VERB? OPEN>
                <TELL "You carefully uncap the bottle. The smell of ether wafts out." CR>
                <RTRUE>)>>

<ROUTINE BUNDLE-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A human-shaped bundle wrapped in stained canvas. The fabric is rotted and discolored. You'd rather not investigate further, though part of you wonders if this is Patient 237." CR>
                <RTRUE>)
               (<VERB? OPEN>
                <TELL "You have no desire to see what lies within. Some mysteries are better left undisturbed." CR>
                <RTRUE>)
               (<VERB? TAKE>
                <TELL "You can't bring yourself to touch it." CR>
                <RTRUE>)
               (<VERB? SMELL>
                <TELL "Even from here, the smell of decay is overwhelming. You step back, fighting nausea." CR>
                <RTRUE>)
               (<VERB? RUB>
                <TELL "Your hand stops inches from the bundle. Every instinct screams at you not to touch it." CR>
                <RTRUE>)
               (<VERB? PUSH>
                <TELL "You cannot bring yourself to push the bundle. The thought of touching it fills you with dread." CR>
                <RTRUE>)>>

<ROUTINE SERUM-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A glass vial containing a faintly glowing liquid. The label reads 'Compound 237 - DO NOT USE'. The serum pulses with an unnatural light." CR>
                <RTRUE>)
               (<VERB? DRINK>
                <TELL "You bring the vial to your lips but your survival instinct stops you. This substance killed Patient 237. You lower the vial, hands trembling." CR>
                <RTRUE>)>>

<ROUTINE SHOVEL-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A heavy coal shovel with a wooden handle. The blade is caked with ancient coal dust." CR>
                <RTRUE>)
               (<VERB? SWING>
                <TELL "You swing the shovel experimentally. It's heavy but well-balanced—could work as a weapon if needed." CR>
                <RTRUE>)
               (<VERB? DIG>
                <TELL "You'd need to specify what you want to dig. The shovel is ready." CR>
                <RTRUE>)>>

<ROUTINE FLASHLIGHT-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A heavy metal flashlight. The switch clicks but produces no light. The batteries are long dead." CR>
                <RTRUE>)
               (<VERB? LAMP-ON>
                <TELL "The batteries are dead. The flashlight doesn't work." CR>
                <RTRUE>)>>

<ROUTINE LANTERN-F ()
         <COND (<AND <VERB? LAMP-ON>
                     <NOT ,LANTERN-LIT-FLAG>>
                <TELL "You light the " D ,OIL-LANTERN ". A warm glow pushes back the darkness." CR>
                <SETG LANTERN-LIT-FLAG T>
                <FSET ,OIL-LANTERN ,ONBIT>
                <RTRUE>)
               (<AND <VERB? LAMP-ON>
                     ,LANTERN-LIT-FLAG>
                <TELL "The " D ,OIL-LANTERN " is already lit." CR>
                <RTRUE>)
               (<AND <VERB? LAMP-OFF>
                     ,LANTERN-LIT-FLAG>
                <TELL "You extinguish the " D ,OIL-LANTERN "." CR>
                <SETG LANTERN-LIT-FLAG <>>
                <FCLEAR ,OIL-LANTERN ,ONBIT>
                <RTRUE>)
               (<VERB? EXAMINE>
                <TELL "A brass oil lantern with a glass chimney. It still contains fuel." CR>
                <RTRUE>)
               (<VERB? SHAKE>
                <TELL "You shake the lantern gently. You can hear oil sloshing inside." CR>
                <RTRUE>)>>

<ROUTINE RECORDS-F ()
         <COND (<VERB? READ EXAMINE>
                <TELL "You flip through the water-damaged records. Most are illegible, but one file remains clear: 'Patient 189 - Subject shows unusual resistance to sedation. Violent episodes increasing. Transferred to isolation ward for observation. Dr. Mordecai supervising.'" CR>
                <RTRUE>)>>

<ROUTINE SOGGY-NOTEBOOK-F ()
         <COND (<VERB? READ EXAMINE>
                <TELL "The notebook is badly water-damaged. You can make out fragments: '...water treatment...patients submerged for hours...screaming finally stopped...Dr. M approved extended sessions...'" CR>
                <RTRUE>)>>

<ROUTINE SYRINGE-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A medical syringe with a sharp steel needle. The glass chamber is empty." CR>
                <RTRUE>)>>

; === NEW DOOR ACTION HANDLERS ===

<ROUTINE THEATER-DOOR-F ()
         <COND (<VERB? EXAMINE>
                <TELL "The door to the operating theater is half-open. Faint metallic sounds drift from beyond." CR>
                <RTRUE>)
               (<VERB? OPEN>
                <TELL "The door is already half-open. You can walk through to the north." CR>
                <RTRUE>)
               (<VERB? CLOSE>
                <TELL "You leave it half-open." CR>
                <RTRUE>)>>

<ROUTINE PADCELL-DOOR-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A heavy steel door, its frame reinforced. It stands ajar, and you can make out a padded cell beyond." CR>
                <RTRUE>)
               (<VERB? OPEN>
                <TELL "The door is already open. The padded cell lies to the west." CR>
                <RTRUE>)
               (<VERB? CLOSE>
                <TELL "You leave it open." CR>
                <RTRUE>)>>

<ROUTINE CORRIDOR-DOOR-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A heavy wooden door leading to the administrative wing. It hangs open, as if someone left in a hurry." CR>
                <RTRUE>)
               (<VERB? OPEN>
                <TELL "The door is already open. The administrative wing lies to the north." CR>
                <RTRUE>)
               (<VERB? CLOSE>
                <TELL "You leave it open." CR>
                <RTRUE>)>>

<ROUTINE OFFICE-DOOR-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A heavy office door leading back to the administrative wing corridor." CR>
                <RTRUE>)
               (<VERB? OPEN>
                <TELL "The door is already open. The corridor lies to the west." CR>
                <RTRUE>)
               (<VERB? CLOSE>
                <TELL "You leave it open." CR>
                <RTRUE>)>>

<ROUTINE GARDEN-DOOR-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A wooden door with a cracked window pane. Through it you can see the overgrown garden beyond." CR>
                <RTRUE>)
               (<VERB? OPEN>
                <TELL "The door swings open. The garden lies to the north." CR>
                <RTRUE>)
               (<VERB? CLOSE>
                <TELL "You leave it open." CR>
                <RTRUE>)>>

<ROUTINE ESCAPE-DOOR-F ()
         <COND (<VERB? EXAMINE>
                <TELL "A heavy door, solid and imposing from this side. It's the only way out of this cell." CR>
                <RTRUE>)
               (<VERB? OPEN>
                <TELL "The door is already open. The electroshock theater lies to the east." CR>
                <RTRUE>)
               (<VERB? CLOSE>
                <TELL "You'd rather not trap yourself in here." CR>
                <RTRUE>)>>

<ROUTINE INSTRUMENTS-PSEUDO ()
    <COND (<VERB? EXAMINE>
           <TELL "Rusty forceps and clamps lie scattered across trays. Long abandoned, like everything else here." CR>)>
    <RTRUE>>

<ROUTINE TRAYS-PSEUDO ()
    <COND (<VERB? EXAMINE>
           <TELL "Cold metal instrument trays sit on carts, their contents rusted and useless." CR>)>
    <RTRUE>>

<ROUTINE BENCHES-PSEUDO ()
    <COND (<VERB? EXAMINE SIT>
           <TELL "Tiers of wooden benches circle the operating theater, where students once observed procedures. The wood is dark with age and moisture." CR>)>
    <RTRUE>>

<ROUTINE GARDEN-BENCHES-F ()
    <COND (<VERB? EXAMINE SIT>
           <TELL "Broken stone benches, half-consumed by ivy and moss. Whatever respite this garden once offered ended decades ago." CR>)>
    <RTRUE>>

; === LOCAL-GLOBALS ACTION HANDLERS ===

<ROUTINE SANITARIUM-BUILDING-F ()
    <COND (<VERB? EXAMINE>
           <COND (,CHAPEL-UNLOCKED
                  <TELL "The sanitarium looms against the darkened sky. Now that you've been deep inside -- seen what lurks in the chapel -- the building feels different. Less abandoned. More watchful." CR>)
                 (T
                  <TELL "The sanitarium's Victorian facade is crumbling but still imposing. Rows of broken windows stare down like hollow eye sockets. Whatever happened here, the building seems reluctant to forget it." CR>)>
           <RTRUE>)>>

<ROUTINE DEAD-OAK-TREE-F ()
    <COND (<VERB? EXAMINE>
           <TELL "A massive dead oak, leafless and grey, its bark bleached to bone. Its branches claw at the sky like desperate hands. Crows shift silently in the upper reaches." CR>
           <RTRUE>)
          (<VERB? CLIMB CLIMB-FOO CLIMB-UP>
           <TELL "The lower branches are too high to reach, and you have no desire to scramble up a dead tree in an abandoned sanitarium grounds." CR>
           <RTRUE>)
          (<VERB? LISTEN>
           <TELL "The crows in the upper branches are utterly silent. They watch you." CR>
           <RTRUE>)>>

<ROUTINE IRON-GATES-F ()
    <COND (<VERB? EXAMINE>
           <TELL "The rusted iron gates stand open. Flakes of old black paint cling to bars bent by years of weather." CR>)
          (<VERB? OPEN>
           <TELL "The gates are already open." CR>)
          (<VERB? CLOSE>
           <TELL "The hinges resist your weight. You leave the gates as you found them." CR>)>
    <RTRUE>>

<ROUTINE GRAND-STAIRCASE-F ()
    <COND (<VERB? EXAMINE CLIMB>
           <TELL "The grand staircase climbs toward a collapsed landing. The safe routes through the sanitarium lie east, west, north, and down." CR>)>
    <RTRUE>>

<ROUTINE WALLPAPER-F ()
    <COND (<VERB? EXAMINE>
           <TELL "Victorian-era wallpaper depicting pastoral scenes, now grotesquely warped by moisture and black mold." CR>)
          (<VERB? READ>
           <TELL "Victorian-era wallpaper depicting pastoral scenes, now grotesquely warped by moisture and black mold." CR>)>
    <RTRUE>>

<ROUTINE COAL-DUST-F ()
    <COND (<VERB? EXAMINE RUB>
           <TELL "Fine coal dust coats the brick and leaves a black crescent on your fingertip." CR>)
          (<VERB? TAKE>
           <TELL "The damp dust is useless as fuel; the coal bin may hold something better." CR>)>
    <RTRUE>>

; === CLOCK-DRIVEN ATMOSPHERIC ROUTINES ===

<ROUTINE I-WHISPER ()
	<QUEUE I-WHISPER 8>
	<COND (<AND <NOT ,GAME-WON>
	            <EQUAL? ,HERE ,SANITARIUM-ENTRANCE ,PATIENT-WARD ,MORGUE ,CHAPEL>>
	       <TELL <PICK-ONE ,WHISPER-TABLE> CR>)>
	<RTRUE>>

<ROUTINE I-FOOTSTEPS ()
	<QUEUE I-FOOTSTEPS 12>
	<COND (<AND <NOT ,GAME-WON>
	            <EQUAL? ,HERE ,SANITARIUM-ENTRANCE ,RECEPTION-ROOM ,OPERATING-THEATER>>
	       <TELL "Distant footsteps echo from somewhere above you." CR>)>
	<RTRUE>>

<ROUTINE I-FLICKERING ()
	<QUEUE I-FLICKERING 10>
	<COND (<AND <NOT ,GAME-WON>
	            ,LIT
	            <EQUAL? ,HERE ,BASEMENT-STAIRS ,BOILER-ROOM ,MORGUE>>
	       <TELL "The shadows seem to flicker and move of their own accord." CR>)>
	<RTRUE>>

<ROUTINE I-COLD-DRAFT ()
	<QUEUE I-COLD-DRAFT 15>
	<COND (<AND <NOT ,GAME-WON>
	            <EQUAL? ,HERE ,MORGUE ,CHAPEL ,PATIENT-WARD>>
	       <TELL "A cold draft makes you shiver, though there are no open windows." CR>)>
	<RTRUE>>

<ROUTINE I-CREAKING ()
    <QUEUE I-CREAKING 9>
    <COND (<AND <NOT ,GAME-WON>
                <EQUAL? ,HERE ,OPERATING-THEATER ,PATIENT-WARD ,ELECTROSHOCK-THEATER>>
           <TELL "The building settles with a deep structural groan, as if exhaling." CR>)>
    <RTRUE>>

<ROUTINE I-BOILER-HEAT ()
    <QUEUE I-BOILER-HEAT 1>
    <COND (<AND ,BOILER-LIT <L? ,BOILER-HEAT 3>>
           <SETG BOILER-HEAT <+ ,BOILER-HEAT 1>>
           <COND (<EQUAL? ,BOILER-HEAT 1>
                  <COND (<EQUAL? ,HERE ,BOILER-ROOM>
                         <TELL "The boiler gives a rolling cough. One by one, the pipes begin to tick." CR>)>)
                 (<EQUAL? ,BOILER-HEAT 2>
                  <COND (<EQUAL? ,HERE ,BASEMENT-CORRIDOR ,FLOODING-CHAMBER>
                         <TELL "A tremor passes through the pipes. Rust flakes fall as warmth travels east." CR>)>)
                 (<EQUAL? ,BOILER-HEAT 3>
                  <SETG CABINET-THAWED T>
                  <COND (<EQUAL? ,HERE ,HYDROTHERAPY-ROOM>
                         <TELL "Behind the wall, a pipe clangs. Frost slides from the medicine cabinet in translucent sheets." CR>)
                        (<EQUAL? ,HERE ,BOILER-ROOM ,BASEMENT-CORRIDOR ,FLOODING-CHAMBER>
                         <TELL "Farther along the pipework, ice breaks loose with a brittle crash." CR>)>)>)>
    <RTRUE>>

<ROUTINE I-COLD-EXPOSURE ()
    <QUEUE I-COLD-EXPOSURE 1>
    <COND (<AND <EQUAL? ,HERE ,MORGUE ,FLOODING-CHAMBER ,HYDROTHERAPY-ROOM>
                <OR <EQUAL? ,HERE ,MORGUE>
                    <NOT ,CABINET-THAWED>>>
           <SETG COLD-EXPOSURE <+ ,COLD-EXPOSURE 1>>
           <COND (<EQUAL? ,COLD-EXPOSURE 8>
                  <TELL "The cold has worked through your clothes. Your fingers are beginning to stiffen." CR>)
                 (<EQUAL? ,COLD-EXPOSURE 16>
                  <TELL "Your teeth chatter hard enough to hurt. Staying here much longer would be dangerous." CR>)
                 (<G? ,COLD-EXPOSURE 24>
                  <JIGS-UP "The shivering stops. The tiles against your cheek feel almost warm; that is how you know the cold has won.">)>)
          (T
           <COND (<AND <G? ,COLD-EXPOSURE 0>
                       <EQUAL? ,HERE ,BOILER-ROOM>
                       ,BOILER-LIT>
                  <TELL "Heat from the boiler works the numbness from your hands." CR>)>
           <SETG COLD-EXPOSURE 0>)>
    <RTRUE>>

<ROUTINE I-PATIENT-AUTONOMY ()
    <QUEUE I-PATIENT-AUTONOMY 4>
    <COND (<AND <NOT ,GAME-WON>
                <G? ,PATIENT-STATE 0>
                <LOC ,PATIENT-189>>
           <COND (<AND <EQUAL? ,PATIENT-STATE 1>
                       <G? ,PATIENT-LORE 2>>
                  <SETG PATIENT-STATE 2>
                  <COND (<IN? ,PATIENT-189 ,HERE>
                         <TELL "Patient 189's gaze sharpens. Something you uncovered elsewhere has reached it; recognition flickers behind the green light." CR>)>)>
           <COND (<AND <IN? ,PATIENT-189 ,CHAPEL>
                       <EQUAL? ,HERE ,OVERGROWN-GARDEN>>
                  <MOVE ,PATIENT-189 ,OVERGROWN-GARDEN>
                  <TELL "Bare feet whisper over stone behind you. Patient 189 has followed you into the garden." CR>)
                 (<AND <IN? ,PATIENT-189 ,OVERGROWN-GARDEN>
                       <EQUAL? ,HERE ,CHAPEL>>
                  <MOVE ,PATIENT-189 ,CHAPEL>
                  <TELL "Patient 189 glides past you and resumes its place before the altar." CR>)
                 (<AND <IN? ,PATIENT-189 ,OVERGROWN-GARDEN>
                       <NOT <EQUAL? ,HERE ,OVERGROWN-GARDEN ,CHAPEL>>>
                  <MOVE ,PATIENT-189 ,CHAPEL>)>)>
    <RTRUE>>

; === SCORING ===

<ROUTINE SCORE-OBJ (OBJ "AUX" TEMP)
     <COND (<NOT <FSET? .OBJ ,TOUCHBIT>>
           <COND (<G? <SET TEMP <GETP .OBJ ,P?VALUE>> 0>
                 <SCORE-UPD .TEMP>
                 <PUTP .OBJ ,P?VALUE 0>
                 <FSET .OBJ ,TOUCHBIT>)>)>>

<ROUTINE V-SCORE ("OPTIONAL" (ASK? T))
    <TELL "Score: " N ,SCORE " of " N ,SCORE-MAX " points, in " N ,MOVES>
    <COND (<1? ,MOVES> <TELL " move.">) (T <TELL " moves.">)>
    <CRLF>
    <TELL "Rank: " <GET ,RANKINGS </ ,SCORE 20>> "." CR>
    ,SCORE>

; === ENTRY POINT ===

<ROUTINE GO ()
	<SETG HERE ,SANITARIUM-GATE>
	<THIS-IS-IT ,BRASS-PLAQUE>
	<SETG LIT T>
	<SETG WINNER ,ADVENTURER>
	<SETG PLAYER ,WINNER>
	<VOC-EXACT-FIRST "SIT" "SITDOWN">
	<VOC-EXACT-FIRST "HELLO" "GREET">
	<VOC-EXACT "SCALPELS" "INSTRUMENTS">
	<MOVE ,WINNER ,HERE>
	<ENABLE <QUEUE I-WHISPER 8>>
	<ENABLE <QUEUE I-FOOTSTEPS 12>>
	<ENABLE <QUEUE I-FLICKERING 10>>
	<ENABLE <QUEUE I-COLD-DRAFT 15>>
	<ENABLE <QUEUE I-CREAKING 9>>
	<ENABLE <QUEUE I-BOILER-HEAT 1>>
	<ENABLE <QUEUE I-COLD-EXPOSURE 1>>
	<ENABLE <QUEUE I-PATIENT-AUTONOMY 4>>
      <V-LOOK>
      <MAIN-LOOP>
	<AGAIN>>
