<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<ASSERT "Start at Sanitarium Gate" <CO-RESUME ,CO "look" T> <==? ,HERE ,,SANITARIUM-GATE>>
	<ASSERT-TEXT "blackwood" <CO-RESUME ,CO "examine plaque">> ;"Learn about Blackwood Sanitarium"
	<ASSERT-TEXT "bolted firmly" <CO-RESUME ,CO "take plaque">> ;"Plaque is fixed to the gate"
	<ASSERT "Brass plaque remains on the gate" <==? <LOC ,BRASS-PLAQUE> ,SANITARIUM-GATE>>
	<ASSERT "Enter Sanitarium Entrance Hall" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,SANITARIUM-ENTRANCE>>
	<ASSERT-TEXT "victorian" <CO-RESUME ,CO "examine wallpaper">> ;"Notice the Victorian-era decay"
	<ASSERT "Go to Reception Room" <CO-RESUME ,CO "walk west" T> <==? ,HERE ,RECEPTION-ROOM>>
	<ASSERT "Take brass key from scattered papers" <CO-RESUME ,CO "take key" T> <==? <LOC ,BRASS-KEY> ,ADVENTURER>>
	<ASSERT "Drop key (optional for this walkthrough)" <CO-RESUME ,CO "drop key" T> <N==? <LOC ,BRASS-KEY> ,ADVENTURER>>
	<ASSERT "Return to Entrance Hall" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,SANITARIUM-ENTRANCE>>
	<ASSERT "Go to Operating Theater" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,OPERATING-THEATER>>
	<ASSERT-TEXT "restraints" <CO-RESUME ,CO "examine table">> ;"See the gruesome operating table"
	<ASSERT-TEXT "scalpel" <CO-RESUME ,CO "examine cabinet">> ;"Notice the medical cabinet"
	<ASSERT "Take scalpel - important tool" <CO-RESUME ,CO "take scalpel" T> <==? <LOC ,SCALPEL> ,ADVENTURER>>
	<ASSERT "Take ether bottle" <CO-RESUME ,CO "take bottle" T> <==? <LOC ,ETHER-BOTTLE> ,ADVENTURER>>
	<ASSERT "Drop ether bottle (not needed)" <CO-RESUME ,CO "drop bottle" T> <N==? <LOC ,ETHER-BOTTLE> ,ADVENTURER>>
	<ASSERT "Return to Entrance Hall" <CO-RESUME ,CO "walk south" T> <==? ,HERE ,SANITARIUM-ENTRANCE>>
	<ASSERT "Go to Patient Ward" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,PATIENT-WARD>>
	<ASSERT-TEXT "frames" <CO-RESUME ,CO "examine beds">> ;"See the deteriorated ward"
	<ASSERT-TEXT "chains" <CO-RESUME ,CO "examine door">> ;"Notice chains blocking morgue"
	<ASSERT "Cut through chains with scalpel" <CO-RESUME ,CO "attack chains"> ,CHAINS-CUT-FLAG>
	<ASSERT "Enter Morgue" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,MORGUE>>
	<ASSERT-TEXT "drawers" <CO-RESUME ,CO "examine drawers">> ;"Find glowing contents"
	<ASSERT "Take strange glowing serum (Compound 237)" <CO-RESUME ,CO "take serum" T> <==? <LOC ,STRANGE-SERUM> ,ADVENTURER>>
	<ASSERT-TEXT "patient 237" <CO-RESUME ,CO "examine bundle">> ;"See canvas-wrapped body"
	<ASSERT "Take Dr. Mordecai's journal" <CO-RESUME ,CO "take journal" T> <==? <LOC ,MORDECAI-JOURNAL> ,ADVENTURER>>
	<ASSERT-TEXT "mistake" <CO-RESUME ,CO "read journal">> ;"Learn about the terrible experiment"
	<ASSERT "Free hands by dropping journal" <CO-RESUME ,CO "drop journal" T> <N==? <LOC ,MORDECAI-JOURNAL> ,ADVENTURER>>
	<ASSERT "Return to Patient Ward" <CO-RESUME ,CO "walk south" T> <==? ,HERE ,PATIENT-WARD>>
	<ASSERT "Return to Entrance Hall" <CO-RESUME ,CO "walk west" T> <==? ,HERE ,SANITARIUM-ENTRANCE>>
	<ASSERT "Descend to Basement Stairs" <CO-RESUME ,CO "walk down" T> <==? ,HERE ,BASEMENT-STAIRS>>
	<ASSERT "Continue to Basement Corridor" <CO-RESUME ,CO "walk down" T> <==? ,HERE ,BASEMENT-CORRIDOR>>
	<ASSERT-TEXT "valve" <CO-RESUME ,CO "examine pipes">> ;"Notice the valve"
	<ASSERT "Release steam - important for later" <CO-RESUME ,CO "turn valve with bare hands"> ,VALVE-TURNED-FLAG>
	<ASSERT "Enter Boiler Room" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,BOILER-ROOM>>
	<ASSERT-TEXT "iron" <CO-RESUME ,CO "examine boiler">> ;"See the massive iron furnace"
	<ASSERT "Open the boiler" <CO-RESUME ,CO "open boiler"> <FSET? ,IRON-BOILER ,OPENBIT>>
	<ASSERT "Take coal shovel" <CO-RESUME ,CO "take shovel" T> <==? <LOC ,COAL-SHOVEL> ,ADVENTURER>>
	<ASSERT-TEXT "flashlight" <CO-RESUME ,CO "examine workbench">> ;"Find tools"
	<ASSERT "Take flashlight (dead batteries)" <CO-RESUME ,CO "take flashlight" T> <==? <LOC ,FLASHLIGHT> ,ADVENTURER>>
	<ASSERT "Drop dead flashlight" <CO-RESUME ,CO "drop flashlight" T> <N==? <LOC ,FLASHLIGHT> ,ADVENTURER>>
	<ASSERT "Return to Basement Corridor" <CO-RESUME ,CO "walk west" T> <==? ,HERE ,BASEMENT-CORRIDOR>>
	<ASSERT "Enter Storage Room" <CO-RESUME ,CO "walk west" T> <==? ,HERE ,STORAGE-ROOM>>
	<ASSERT-TEXT "bag" <CO-RESUME ,CO "examine shelves">> ;"Find supplies including medical bag"
	<ASSERT "Take medical bag" <CO-RESUME ,CO "take bag" T> <==? <LOC ,MEDICAL-BAG> ,ADVENTURER>>
	<ASSERT "Open medical bag (already open)" <CO-RESUME ,CO "open bag"> <FSET? ,MEDICAL-BAG ,OPENBIT>>
	<ASSERT "Take bandages from bag" <CO-RESUME ,CO "take bandages" T> <==? <LOC ,BANDAGES> ,ADVENTURER>>
	<ASSERT "Take morphine vial from bag" <CO-RESUME ,CO "take morphine" T> <==? <LOC ,MORPHINE-VIAL> ,ADVENTURER>>
	<ASSERT "Drop bandages (optional item)" <CO-RESUME ,CO "drop bandages" T> <N==? <LOC ,BANDAGES> ,ADVENTURER>>
	<ASSERT "Drop morphine vial (optional item)" <CO-RESUME ,CO "drop morphine" T> <N==? <LOC ,MORPHINE-VIAL> ,ADVENTURER>>
	<ASSERT "Drop medical bag (no longer needed)" <CO-RESUME ,CO "drop bag" T> <N==? <LOC ,MEDICAL-BAG> ,ADVENTURER>>
	<ASSERT "Take oil lantern - working light" <CO-RESUME ,CO "take lantern" T> <==? <LOC ,OIL-LANTERN> ,ADVENTURER>>
	<ASSERT "Illuminate the darkness" <CO-RESUME ,CO "light lantern"> <FSET? ,OIL-LANTERN ,ONBIT>>
	<ASSERT "Take medical records" <CO-RESUME ,CO "take records" T> <==? <LOC ,MEDICAL-RECORDS> ,ADVENTURER>>
	<ASSERT-TEXT "patient 189" <CO-RESUME ,CO "read records">> ;"Learn about Patient 189"
	<ASSERT "Drop medical records (no longer needed)" <CO-RESUME ,CO "drop records" T> <N==? <LOC ,MEDICAL-RECORDS> ,ADVENTURER>>
	<ASSERT "Return to Basement Corridor" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,BASEMENT-CORRIDOR>>
	<ASSERT "Return to Boiler Room with shovel and lantern" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,BOILER-ROOM>>
	<ASSERT "Recover usable coal with the shovel" <CO-RESUME ,CO "take coal" T> <==? <LOC ,LUMP-OF-COAL> ,ADVENTURER>>
	<ASSERT-TEXT "place the coal" <CO-RESUME ,CO "put coal in boiler">>
	<ASSERT-TEXT "deep metallic thud" <CO-RESUME ,CO "kindle boiler with lantern">>
	<ASSERT "Boiler is lit" ,BOILER-LIT>
	<CO-RESUME ,CO "wait">
	<ASSERT "Boiler heat thaws the remote medicine cabinet" ,CABINET-THAWED>
	<ASSERT "Drop shovel after fueling boiler" <CO-RESUME ,CO "drop shovel" T> <N==? <LOC ,COAL-SHOVEL> ,ADVENTURER>>
	<ASSERT "Return to Basement Corridor after lighting boiler" <CO-RESUME ,CO "walk west" T> <==? ,HERE ,BASEMENT-CORRIDOR>>
	<ASSERT "Enter Flooding Chamber" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,FLOODING-CHAMBER>>
	<ASSERT-TEXT "cold" <CO-RESUME ,CO "examine water">> ;"Cold ankle-deep water"
	<ASSERT-TEXT "steam" <CO-RESUME ,CO "examine door">> ;"Sealed door to east - needs steam"
	<ASSERT "Steam has loosened it - access Hydrotherapy" <CO-RESUME ,CO "open door"> ,STEAM-DOOR-OPEN>
	<ASSERT "Enter Hydrotherapy Room" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,HYDROTHERAPY-ROOM>>
	<ASSERT-TEXT "notebook" <CO-RESUME ,CO "examine tubs">> ;"Find notebook"
	<ASSERT "Take soggy notebook" <CO-RESUME ,CO "take notebook" T> <==? <LOC ,SOGGY-NOTEBOOK> ,ADVENTURER>>
	<ASSERT-TEXT "water" <CO-RESUME ,CO "read notebook">> ;"Learn about water torture"
	<ASSERT "Drop soggy notebook (no longer needed)" <CO-RESUME ,CO "drop notebook" T> <N==? <LOC ,SOGGY-NOTEBOOK> ,ADVENTURER>>
	<ASSERT-TEXT "syringe" <CO-RESUME ,CO "examine cabinet">> ;"Thawed medicine cabinet"
	<ASSERT-TEXT "pull the thawed cabinet open" <CO-RESUME ,CO "open cabinet">>
	<ASSERT-TEXT "taken" <CO-RESUME ,CO "take syringe">>
	<ASSERT "Return to Flooding Chamber" <CO-RESUME ,CO "walk west" T> <==? ,HERE ,FLOODING-CHAMBER>>
	<ASSERT "Enter Isolation Ward" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,ISOLATION-WARD>>
	<ASSERT-TEXT "metal" <CO-RESUME ,CO "examine doors">> ;"See the cell doors"
	<ASSERT-TEXT "chapel" <CO-RESUME ,CO "examine scratches">> ;"Critical clue: PATIENT 189 STILL ALIVE IN THE CHAPEL"
	<ASSERT "Enter Electroshock Theater" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,ELECTROSHOCK-THEATER>>
	<ASSERT-TEXT "restraints" <CO-RESUME ,CO "examine chair">> ;"The terrible shock chair"
	<ASSERT-TEXT "voltage" <CO-RESUME ,CO "examine machine">> ;"Electroshock equipment"
	<ASSERT "Enter Padded Cell" <CO-RESUME ,CO "walk west" T> <==? ,HERE ,PADDED-CELL>>
	<ASSERT-TEXT "189" <CO-RESUME ,CO "examine padding">> ;"Blood message about chapel and Patient 189"
	<ASSERT "Take straitjacket" <CO-RESUME ,CO "take jacket" T> <==? <LOC ,STRAITJACKET> ,ADVENTURER>>
	<ASSERT-TEXT "name tag" <CO-RESUME ,CO "examine jacket">> ;"Identity twist -- name tag with familiar handwriting"
	<ASSERT-TEXT "1947" <CO-RESUME ,CO "read jacket">> ;"Tag dated 1947, five years before closure"
	<ASSERT "Drop straitjacket (no longer needed)" <CO-RESUME ,CO "drop jacket" T> <N==? <LOC ,STRAITJACKET> ,ADVENTURER>>
	<ASSERT "Return to Electroshock Theater" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,ELECTROSHOCK-THEATER>>
	<ASSERT "Climb to Observation Deck" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,OBSERVATION-DECK>>
	<ASSERT-TEXT "theater" <CO-RESUME ,CO "examine mirror">> ;"One-way mirror overlooking theater"
	<ASSERT "Take observation logbook" <CO-RESUME ,CO "take logbook" T> <==? <LOC ,OBSERVATION-LOGBOOK> ,ADVENTURER>>
	<ASSERT-TEXT "189" <CO-RESUME ,CO "read logbook">> ;"Learn about Patient 189's treatment"
	<ASSERT "Drop observation logbook (no longer needed)" <CO-RESUME ,CO "drop logbook" T> <N==? <LOC ,OBSERVATION-LOGBOOK> ,ADVENTURER>>
	<ASSERT "Enter Administrative Wing" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,ADMINISTRATIVE-WING>>
	<ASSERT-TEXT "189" <CO-RESUME ,CO "examine papers">> ;"Find memo about Patient 189 and chapel"
	<ASSERT "Enter Director's Office" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,DIRECTORS-OFFICE>>
	<ASSERT-TEXT "mordecai" <CO-RESUME ,CO "examine portrait">> ;"See Dr. Heinrich Mordecai's portrait"
	<ASSERT-TEXT "blank" <CO-RESUME ,CO "examine book">> ;"Notice the red leather book with blank spine"
	<ASSERT "Open hollow book to reveal safe key" <CO-RESUME ,CO "open book"> <FSET? ,HOLLOW-BOOK ,OPENBIT>>
	<ASSERT "Take safe key from hollow book" <CO-RESUME ,CO "take key" T> <==? <LOC ,SAFE-KEY> ,ADVENTURER>>
	<ASSERT-TEXT "locked" <CO-RESUME ,CO "examine safe">> ;"Notice wall safe"
	<ASSERT "Open safe with safe key" <CO-RESUME ,CO "unlock safe with key"> <FSET? ,WALL-SAFE ,OPENBIT>>
	<ASSERT "Drop safe key (no longer needed)" <CO-RESUME ,CO "drop key" T> <N==? <LOC ,SAFE-KEY> ,ADVENTURER>>
	<ASSERT "Take Dr. Mordecai's private notes" <CO-RESUME ,CO "take notes" T> <==? <LOC ,MORDECAI-NOTES> ,ADVENTURER>>
	<ASSERT-TEXT "transcended" <CO-RESUME ,CO "read notes">> ;"Learn Patient 189 transcended death"
	<ASSERT "Drop Dr. Mordecai's notes (no longer needed)" <CO-RESUME ,CO "drop notes" T> <N==? <LOC ,MORDECAI-NOTES> ,ADVENTURER>>
	<ASSERT "Take chapel key (iron key with cross)" <CO-RESUME ,CO "take chapel key" T> <==? <LOC ,CHAPEL-KEY> ,ADVENTURER>>
	<ASSERT "Return to Administrative Wing" <CO-RESUME ,CO "walk west" T> <==? ,HERE ,ADMINISTRATIVE-WING>>
	<ASSERT "Enter Staff Quarters" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,STAFF-QUARTERS>>
	<ASSERT-TEXT "photograph" <CO-RESUME ,CO "examine lockers">> ;"Find personal items"
	<ASSERT "Take staff photo from 1950" <CO-RESUME ,CO "take photograph" T> <==? <LOC ,PHOTOGRAPH> ,ADVENTURER>>
	<ASSERT-TEXT "1950" <CO-RESUME ,CO "examine photograph">> ;"See the sanitarium staff"
	<ASSERT "Drop staff photograph (no longer needed)" <CO-RESUME ,CO "drop photograph" T> <N==? <LOC ,PHOTOGRAPH> ,ADVENTURER>>
	<ASSERT "Enter Cafeteria" <CO-RESUME ,CO "walk west" T> <==? ,HERE ,CAFETERIA>>
	<ASSERT-TEXT "bell" <CO-RESUME ,CO "examine counter">> ;"Old service area"
	<ASSERT "Take service bell (optional)" <CO-RESUME ,CO "take bell" T> <==? <LOC ,BELL> ,ADVENTURER>>
	<ASSERT "Drop service bell (optional item, not needed)" <CO-RESUME ,CO "drop bell" T> <N==? <LOC ,BELL> ,ADVENTURER>>
	<ASSERT "Enter Overgrown Garden" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,OVERGROWN-GARDEN>>
	<ASSERT-TEXT "dead" <CO-RESUME ,CO "examine garden">> ;"Wild tangle of dead plants"
	<ASSERT-TEXT "hope" <CO-RESUME ,CO "examine door">> ;"Chapel door with ominous message"
	<ASSERT "Use chapel key to unlock final area" <CO-RESUME ,CO "unlock door with key"> ,CHAPEL-UNLOCKED>
	<ASSERT "Drop chapel key after unlocking" <CO-RESUME ,CO "drop key" T> <N==? <LOC ,CHAPEL-KEY> ,ADVENTURER>>
	<ASSERT "Enter Chapel - Final Location" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,CHAPEL>>
	<ASSERT-TEXT "symbols" <CO-RESUME ,CO "examine pews">> ;"Strange carved symbols"
	<ASSERT-TEXT "green" <CO-RESUME ,CO "examine candles">> ;"Unnatural green flames"
	<ASSERT-TEXT "altar" <CO-RESUME ,CO "examine box">> ;"Wooden box beneath altar"
	<ASSERT "Pry open box with scalpel" <CO-RESUME ,CO "open box"> <FSET? ,WOODEN-BOX ,OPENBIT>>
	<ASSERT "Take ancient silver relic from box" <CO-RESUME ,CO "take relic" T> <==? <LOC ,ANCIENT-RELIC> ,ADVENTURER>>
	<ASSERT-TEXT "symbols" <CO-RESUME ,CO "examine relic">> ;"Cross with writhing symbols, keep it"
	<ASSERT-TEXT "189" <CO-RESUME ,CO "examine patient">> ;"Patient 189 - Dr. Mordecai's achievement"
	<ASSERT-TEXT "glowing" <CO-RESUME ,CO "examine serum">> ;"Confirm serum still accessible"
	<ASSERT-TEXT "needle" <CO-RESUME ,CO "examine syringe">> ;"Confirm syringe still accessible"
	<ASSERT "Relic is carried before SAY HELLO" <==? <LOC ,ANCIENT-RELIC> ,ADVENTURER>>
	<ASSERT "Serum is carried before SAY HELLO" <==? <LOC ,STRANGE-SERUM> ,ADVENTURER>>
	<ASSERT "Syringe is carried before SAY HELLO" <==? <LOC ,SYRINGE> ,ADVENTURER>>
	<ASSERT-TEXT "I remember... who I was" <CO-RESUME ,CO "say hello">>
	<ASSERT "WIN - freed with relic and serum and syringe" ,GAME-WON>
>
