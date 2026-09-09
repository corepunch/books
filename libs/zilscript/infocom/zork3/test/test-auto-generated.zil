"TEST-zork3.ZIL - Auto-generated test from transcript"

<SETG ZORK-NUMBER 3>

<INSERT-FILE "infocom/zork3/gglobals">
<INSERT-FILE "infocom/zork3/gclock">
<INSERT-FILE "infocom/zork3/gparser">
<INSERT-FILE "infocom/zork3/gverbs">
<INSERT-FILE "infocom/zork3/gsyntax">
<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND CROSS ENTER>
<INSERT-FILE "infocom/zork3/3actions">
<INSERT-FILE "infocom/zork3/3dungeon">
<INSERT-FILE "infocom/zork3/gmain">
<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<TELL "Testing zork3 transcript..." CR>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET LAMP">>
	<ASSERT-TEXT "pitch black" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "The lamp is now on." <CO-RESUME ,CO " LIGHT LAMP">>
	<ASSERT-TEXT "End of Rainbow" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "On a Rainbow" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET BREAD">>
	<ASSERT-TEXT "On a Rainbow" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "End of Rainbow" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Junction" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Engravings Room" <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "Old Man's Room" <CO-RESUME ,CO " SE">>
	<ASSERT-TEXT "Old Man's Room" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "The old man wakes up, stretches, and yawns. \"Oh! Hello there. I must have dozed ..." <CO-RESUME ,CO " WAKE UP OLD MAN">>
	<ASSERT-TEXT "The old man takes the bread and eats it. \"Thank you, my friend. You are kind.\" H..." <CO-RESUME ,CO " GIVE BREAD TO OLD MAN">>
	<ASSERT-TEXT "Secret Door" <CO-RESUME ,CO " SW">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Beam Room" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Button Room" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "The lamp is now off." <CO-RESUME ,CO " TURN OFF LAMP">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO " DROP LAMP">>
	<ASSERT-TEXT "You dive gracefully into the water." <CO-RESUME ,CO " JUMP LAKE">>
	<ASSERT-TEXT "Underwater" <CO-RESUME ,CO " D">>
	<ASSERT-TEXT "The amulet is too slippery to grasp. You release it." <CO-RESUME ,CO " GET AMULET">>
	<ASSERT-TEXT "You feel the amulet slip from your grasp." <CO-RESUME ,CO " GET AMULET">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET AMULET">>
	<ASSERT-TEXT "On the Shore" <CO-RESUME ,CO " U">>
	<ASSERT-TEXT "West Shore" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Scenic Vista" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET TORCH">>
	<ASSERT-TEXT "..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "In a flash of light, you are transported." <CO-RESUME ,CO " TOUCH TABLE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET CAN">>
	<ASSERT-TEXT "In a flash of light, you are transported back." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The table's indicator flickers and reads 'III'." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "In a flash of light, you are transported." <CO-RESUME ,CO " TOUCH TABLE">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO " DROP TORCH">>
	<ASSERT-TEXT "In a flash of light, you are transported back." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "West Shore" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You dive gracefully into the water." <CO-RESUME ,CO " JUMP LAKE">>
	<ASSERT-TEXT "Underwater" <CO-RESUME ,CO " D">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET CAN">>
	<ASSERT-TEXT "On the Shore" <CO-RESUME ,CO " U">>
	<ASSERT-TEXT "Southern Shore" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Dark Room" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Dark Room" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You feel a thin, oily film cover your skin." <CO-RESUME ,CO " SPRAY REPELLANT ON MYSELF">>
	<ASSERT-TEXT "Dark Room" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Key Room" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET KEY">>
	<ASSERT-TEXT "You move the manhole cover aside." <CO-RESUME ,CO " MOVE COVER">>
	<ASSERT-TEXT "Aqueduct" <CO-RESUME ,CO " D">>
	<ASSERT-TEXT "High Arch" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Damp Passage" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "High Arch" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Damp Passage" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET TORCH">>
	<ASSERT-TEXT "West Corridor" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Old Man's Room" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Secret Door" <CO-RESUME ,CO " D">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "A man has arrived and asks you to attach the rope to the chest." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You tie the chest to the rope." <CO-RESUME ,CO " TIE CHEST TO ROPE">>
	<ASSERT-TEXT "The man pulls the rope up." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "He has attached a wooden staff to the rope and lowers it down." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The rope is lowered again." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You grab the rope." <CO-RESUME ,CO " GRAB ROPE">>
	<ASSERT-TEXT "The man takes the chest, opens it, and gives you a wooden staff." <CO-RESUME ,CO " GET CHEST">>
	<ASSERT-TEXT "Junction" <CO-RESUME ,CO " D">>
	<ASSERT-TEXT "Endless Stair" <CO-RESUME ,CO " D">>
	<ASSERT-TEXT "Lake Shore" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "A ship sails past and the sailor throws you a vial." <CO-RESUME ,CO " HELLO SAILOR">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET VIAL">>
	<ASSERT-TEXT "Land of Shadow" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "The figure approaches." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The figure staggers." <CO-RESUME ,CO " KILL FIGURE WITH SWORD">>
	<ASSERT-TEXT "The figure is badly hurt and defenseless." <CO-RESUME ,CO " KILL FIGURE WITH SWORD">>
	<ASSERT-TEXT "You remove the hood. It is your older self! He vanishes in a flash of light." <CO-RESUME ,CO " REMOVE HOOD">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO " DROP SWORD">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET CLOAK">>
	<ASSERT-TEXT "West Corridor" <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Button Room" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Beam Room" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Chasm Room" <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You open the door." <CO-RESUME ,CO " OPEN DOOR">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Beam Room" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Dropped. The chest blocks the beam." <CO-RESUME ,CO " DROP CHEST">>
	<ASSERT-TEXT "Button Room" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " SW">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Button Room" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Beam Room" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Chasm Room" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Museum" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Technology Museum" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You push the golden machine southward." <CO-RESUME ,CO " PUSH GOLDEN MACHINE SOUTH">>
	<ASSERT-TEXT "You open the stone door." <CO-RESUME ,CO " OPEN STONE DOOR">>
	<ASSERT-TEXT "You push the golden machine eastward." <CO-RESUME ,CO " PUSH GOLDEN MACHINE EAST">>
	<ASSERT-TEXT "The dial is set to 948." <CO-RESUME ,CO " EXAMINE MACHINE">>
	<ASSERT-TEXT "The Crown Jewel room was finished in 777." <CO-RESUME ,CO " READ PLAQUE">>
	<ASSERT-TEXT "You sit down on the golden machine's seat." <CO-RESUME ,CO " GET IN MACHINE">>
	<ASSERT-TEXT "You turn the dial to 776." <CO-RESUME ,CO " SET DIAL TO 776">>
	<ASSERT-TEXT "There is a flash of light. All the items around you have vanished. The security ..." <CO-RESUME ,CO " PRESS BUTTON">>
	<ASSERT-TEXT "The guards march away." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET RING">>
	<ASSERT-TEXT "You open the door." <CO-RESUME ,CO " OPEN DOOR">>
	<ASSERT-TEXT "Museum Entrance" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You open the wooden door." <CO-RESUME ,CO " OPEN WOODEN DOOR">>
	<ASSERT-TEXT "Golden Machine Room" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You lift the seat of the golden machine." <CO-RESUME ,CO " LIFT SEAT">>
	<ASSERT-TEXT "You place the ring under the seat." <CO-RESUME ,CO " HIDE RING UNDER SEAT">>
	<ASSERT-TEXT "You sit down on the golden machine's seat." <CO-RESUME ,CO " GET IN GOLDEN MACHINE">>
	<ASSERT-TEXT "You turn the dial to 948." <CO-RESUME ,CO " SET DIAL TO 948">>
	<ASSERT-TEXT "There is a flash of light. You are back in the present." <CO-RESUME ,CO " PRESS BUTTON">>
	<ASSERT-TEXT "You stand up." <CO-RESUME ,CO " GET OUT OF GOLDEN MACHINE">>
	<ASSERT-TEXT "Under the seat you find the golden ring." <CO-RESUME ,CO " LIFT SEAT">>
	<ASSERT-TEXT "You open the door." <CO-RESUME ,CO " OPEN WOODEN DOOR">>
	<ASSERT-TEXT "Museum Entrance" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You open the stone door." <CO-RESUME ,CO " OPEN STONE DOOR">>
	<ASSERT-TEXT "Technology Museum" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You pick up all your items." <CO-RESUME ,CO " GET ALL">>
	<ASSERT-TEXT "Royal Museum" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " D">>
	<ASSERT-TEXT "The south wall slides away." <CO-RESUME ,CO " PRESS SOUTH WALL">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "The south wall slides away." <CO-RESUME ,CO " PRESS SOUTH WALL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GET BOOK">>
	<ASSERT-TEXT "The south wall slides away." <CO-RESUME ,CO " PRESS SOUTH WALL">>
	<ASSERT-TEXT "The west wall slides away." <CO-RESUME ,CO " PRESS WEST WALL">>
	<ASSERT-TEXT "The west wall slides away." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "The east wall slides away." <CO-RESUME ,CO " PRESS EAST WALL">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "The west wall slides away." <CO-RESUME ,CO " PRESS WEST WALL">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "The south wall slides away." <CO-RESUME ,CO " PRESS SOUTH WALL">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "The east wall slides away." <CO-RESUME ,CO " PRESS EAST WALL">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "The east wall slides away." <CO-RESUME ,CO " PRESS EAST WALL">>
	<ASSERT-TEXT "The east wall slides away." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "The east wall slides away." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "The south wall slides away." <CO-RESUME ,CO " PRESS SOUTH WALL">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "The south wall slides away." <CO-RESUME ,CO " PRESS SOUTH WALL">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "The west wall slides away." <CO-RESUME ,CO " PRESS WEST WALL">>
	<ASSERT-TEXT "The west wall slides away." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "The north wall slides away." <CO-RESUME ,CO " PRESS NORTH WALL">>
	<ASSERT-TEXT "The north wall slides away." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "The north wall slides away." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Royal Puzzle" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Technology Museum" <CO-RESUME ,CO " U">>
	<ASSERT-TEXT "Golden Machine Room" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Museum Entrance" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Old Man's Room" <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "Engravings Room" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Old Man's Room" <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "The mirror rotates and opens, revealing a passage." <CO-RESUME ,CO " PRESS BUTTON">>
	<ASSERT-TEXT "North Corridor" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Mirror Room" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Room of Mirrors" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You raise the short pole." <CO-RESUME ,CO " RAISE SHORT POLE">>
	<ASSERT-TEXT "The compass needle points to the north." <CO-RESUME ,CO " PRESS WHITE PANEL">>
	<ASSERT-TEXT "The compass needle points to the south." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "You lower the short pole." <CO-RESUME ,CO " LOWER SHORT POLE">>
	<ASSERT-TEXT "You push the pine panel." <CO-RESUME ,CO " PUSH PINE PANEL">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You open the vial." <CO-RESUME ,CO " OPEN VIAL">>
	<ASSERT-TEXT "You drink the liquid. You become invisible." <CO-RESUME ,CO " DRINK LIQUID">>
	<ASSERT-TEXT "Guardians of Zork" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Narrow Corridor" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "The door opens. The Dungeon Master is standing inside." <CO-RESUME ,CO " KNOCK ON DOOR">>
	<ASSERT-TEXT "Dungeon Master's Lair" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Dungeon Master's Lair" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "South Corridor" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "Parapet" <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "It says that around the Parapet are 8 identical rooms. One has a bronze door lea..." <CO-RESUME ,CO " READ BOOK">>
	<ASSERT-TEXT "You turn the dial to 4." <CO-RESUME ,CO " TURN DIAL TO 4">>
	<ASSERT-TEXT "The parapet shifts and transports you." <CO-RESUME ,CO " PRESS BUTTON">>
	<ASSERT-TEXT "The Dungeon Master waits." <CO-RESUME ,CO " SAY TO DUNGEON MASTER \"WAIT\"">>
	<ASSERT-TEXT "Cell" <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You open the cell door." <CO-RESUME ,CO " OPEN CELL DOOR">>
	<ASSERT-TEXT "You can see a bronze door nearby." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "The Dungeon Master nods and obeys. The parapet shifts." <CO-RESUME ,CO " SAY TO DUNGEON MASTER \"TURN DIAL TO 8 AND PRESS BUTTON\"">>
	<ASSERT-TEXT "The key shapes itself to fit the lock. The bronze door unlocks." <CO-RESUME ,CO " UNLOCK BRONZE DOOR WITH KEY">>
	<ASSERT-TEXT "You open the bronze door." <CO-RESUME ,CO " OPEN IT">>
	<ASSERT-TEXT "Treasury of Zork" <CO-RESUME ,CO " S">>
	<TELL CR "zork3 transcript test completed!" CR>>
