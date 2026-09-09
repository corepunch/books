"TEST-spellbreaker.ZIL - Auto-generated test from transcript"

<INSERT-FILE "infocom/spellbreaker/globals">
<INSERT-FILE "infocom/spellbreaker/parser">
<INSERT-FILE "infocom/spellbreaker/verbs">
<INSERT-FILE "infocom/spellbreaker/actions">
<INSERT-FILE "infocom/spellbreaker/syntax">
<INSERT-FILE "infocom/spellbreaker/z6">
<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<TELL "Testing spellbreaker transcript..." CR>
	<ASSERT-TEXT "Start of a transcript of SPELLBREAKER." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait as the others around you are transformed into amphibians. The room grow..." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You enter a small chamber. A piece of bread lies on the floor." <CO-RESUME ,CO " TAKE BREAD">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You enter another room. An orange cloud swirls before you." <CO-RESUME ,CO " LESOCH">>
	<ASSERT-TEXT "You have learned the LESOCH spell. The orange cloud dissipates." <CO-RESUME ,CO " CAST LESOCH">>
	<ASSERT-TEXT "The orange cloud dissipates." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken. This is a small metal cube." <CO-RESUME ,CO " WRITE 1 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"1\" on the cube." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 1">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " FROTZ BURIN">>
	<ASSERT-TEXT "Your burin now glows with a soft light." <CO-RESUME ,CO " SAVE">>
	<ASSERT-TEXT "Saved." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You climb down." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You climb further down." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "A roc swoops down and catches you in its talons! It carries you away to its nest..." <CO-RESUME ,CO " TAKE STAINED SCROLL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " EXAMINE STAINED SCROLL">>
	<ASSERT-TEXT "The stained scroll contains some magical writing." <CO-RESUME ,CO " GNUSTO CASKLY">>
	<ASSERT-TEXT "You have learned the CASKLY spell." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 1">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You enter a room with strange markings on the walls." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You enter the Ruins Room. Remember this place - the details will be important la..." <CO-RESUME ,CO " TAKE ZIPPER">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " OPEN ZIPPER">>
	<ASSERT-TEXT "Opened." <CO-RESUME ,CO " LOOK INTO ZIPPER">>
	<ASSERT-TEXT "Inside the zipper you see a dark void." <CO-RESUME ,CO " REACH INTO ZIPPER">>
	<ASSERT-TEXT "You reach into the zipper." <CO-RESUME ,CO " LOOK INTO ZIPPER">>
	<ASSERT-TEXT "Inside the zipper you see a flimsy scroll." <CO-RESUME ,CO " TAKE FLIMSY SCROLL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " READ FLIMSY SCROLL">>
	<ASSERT-TEXT "The flimsy scroll contains the very long GIRGOL spell." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 1">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You enter another room." <CO-RESUME ,CO " TAKE DIRTY SCROLL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " READ DIRTY SCROLL">>
	<ASSERT-TEXT "The dirty scroll contains some magical writing." <CO-RESUME ,CO " GNUSTO THROCK">>
	<ASSERT-TEXT "You have learned the THROCK spell." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The ground begins to shake. An avalanche has started!" <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The avalanche intensifies." <CO-RESUME ,CO " GIRGOL">>
	<ASSERT-TEXT "You cast GIRGOL. The avalanche stops." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " TAKE COIN">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " EXAMINE COIN">>
	<ASSERT-TEXT "The coin is old and tarnished." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You find a stone hut." <CO-RESUME ,CO " CASKLY">>
	<ASSERT-TEXT "You have learned the CASKLY spell." <CO-RESUME ,CO " CASKLY HUT">>
	<ASSERT-TEXT "The stone hut is now in perfect condition." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You move east." <CO-RESUME ,CO " PUT COIN, BREAD AND KNIFE IN ZIPPER">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO " WRITE 2 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"2\" on the cube." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 2">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You enter a room with a strange weed growing from the floor." <CO-RESUME ,CO " PULL WEED">>
	<ASSERT-TEXT "You pull at the weed." <CO-RESUME ,CO " PULL WEED">>
	<ASSERT-TEXT "The weed comes free from the ground." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 1">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You move west." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You find an ogre who is sneezing repeatedly." <CO-RESUME ,CO " YOMIN">>
	<ASSERT-TEXT "You have learned the YOMIN spell." <CO-RESUME ,CO " YOMIN OGRE">>
	<ASSERT-TEXT "The ogre has hay fever." <CO-RESUME ,CO " PLANT WEED">>
	<ASSERT-TEXT "You plant the weed in the ground." <CO-RESUME ,CO " THROCK">>
	<ASSERT-TEXT "You have learned the THROCK spell." <CO-RESUME ,CO " THROCK WEED">>
	<ASSERT-TEXT "You cast THROCK on the weed. It begins to grow rapidly." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You climb down." <CO-RESUME ,CO " TAKE DUSTY SCROLL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " TAKE GOLD BOX">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You move south." <CO-RESUME ,CO " READ DUSTY SCROLL">>
	<ASSERT-TEXT "The dusty scroll contains some magical writing." <CO-RESUME ,CO " GNUSTO ESPNIS">>
	<ASSERT-TEXT "You have learned the ESPNIS spell." <CO-RESUME ,CO " OPEN BOX">>
	<ASSERT-TEXT "You open the gold box. Inside is a cube." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " PUT BOX IN ZIPPER">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO " WRITE 3 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"3\" on the cube." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 3">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " TAKE BREAD">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " DROP ALL EXCEPT BREAD">>
	<ASSERT-TEXT "You drop everything except the bread." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You enter a room with water." <CO-RESUME ,CO " DROP BREAD">>
	<ASSERT-TEXT "You drop the bread." <CO-RESUME ,CO " TAKE 3">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " TAKE BOTTLE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " BLORPLE 3">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " OPEN BOTTLE">>
	<ASSERT-TEXT "You open the bottle. Inside is a damp scroll." <CO-RESUME ,CO " LOOK INTO BOTTLE">>
	<ASSERT-TEXT "Inside the bottle you see a damp scroll." <CO-RESUME ,CO " TAKE DAMP SCROLL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " READ DAMP SCROLL">>
	<ASSERT-TEXT "The damp scroll contains the LISKON spell." <CO-RESUME ,CO " GNUSTO LISKON">>
	<ASSERT-TEXT "You have learned the LISKON spell." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " LISKON ME">>
	<ASSERT-TEXT "You cast LISKON on yourself. You feel lighter." <CO-RESUME ,CO " FROTZ BOTTLE">>
	<ASSERT-TEXT "The bottle now glows with a soft light." <CO-RESUME ,CO " DROP ALL EXCEPT BOTTLE AND 3">>
	<ASSERT-TEXT "You drop everything except the bottle and cube." <CO-RESUME ,CO " ENTER OUTFLOW PIPE">>
	<ASSERT-TEXT "You enter the outflow pipe." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You move west." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You move west." <CO-RESUME ,CO " CLIMB OUT OF PIPE">>
	<ASSERT-TEXT "You climb out of the pipe." <CO-RESUME ,CO " BLORPLE 3">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " TAKE ALL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WRITE 4 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"4\" on the cube." <CO-RESUME ,CO " PUT BOTTLE IN ZIPPER">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 1">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You move east." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " LISKON SNAKE">>
	<ASSERT-TEXT "You cast LISKON on the snake. It becomes lighter." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " MALYON IDOL">>
	<ASSERT-TEXT "You have learned the MALYON spell. You cast MALYON on the idol." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The idol comes to life." <CO-RESUME ,CO " ESPNIS IDOL">>
	<ASSERT-TEXT "You cast ESPNIS on the idol. It falls asleep." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The idol is now asleep." <CO-RESUME ,CO " CLIMB IDOL">>
	<ASSERT-TEXT "You climb onto the idol." <CO-RESUME ,CO " LOOK INTO MOUTH">>
	<ASSERT-TEXT "Inside the idol's mouth you see a cube." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You climb down." <CO-RESUME ,CO " WRITE 5 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"5\" on the cube." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 5">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " TAKE WHITE SCROLL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 5">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You move west." <CO-RESUME ,CO " EXAMINE WHITE SCROLL">>
	<ASSERT-TEXT "The white scroll contains the TINSOT spell." <CO-RESUME ,CO " GNUSTO TINSOT">>
	<ASSERT-TEXT "You have learned the TINSOT spell." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You move east." <CO-RESUME ,CO " EXAMINE BLUE CARPET">>
	<ASSERT-TEXT "The blue carpet is expensive." <CO-RESUME ,CO " TAKE BLUE CARPET">>
	<ASSERT-TEXT "You take the blue carpet." <CO-RESUME ,CO " POINT AT BLUE CARPET">>
	<ASSERT-TEXT "You point at the blue carpet." <CO-RESUME ,CO " BUY BLUE CARPET">>
	<ASSERT-TEXT "How much will you offer?" <CO-RESUME ,CO " OFFER 300">>
	<ASSERT-TEXT "Too low." <CO-RESUME ,CO " OFFER 400">>
	<ASSERT-TEXT "Still too low." <CO-RESUME ,CO " OFFER 500">>
	<ASSERT-TEXT "The merchant agrees!" <CO-RESUME ,CO " INVENTORY">>
	<ASSERT-TEXT "You are carrying: blue carpet, cube, and other items." <CO-RESUME ,CO " TAKE BLUE CARPET">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 3">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " TINSOT CHANNEL">>
	<ASSERT-TEXT "You cast TINSOT on the channel. It freezes." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "You cast TINSOT again." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "You cast TINSOT again." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " TINSOT WATER">>
	<ASSERT-TEXT "You cast TINSOT on the water. It freezes into an ice floe." <CO-RESUME ,CO " CLIMB ICE FLOE">>
	<ASSERT-TEXT "You climb onto the ice floe." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " OPEN ZIPPER">>
	<ASSERT-TEXT "You open the zipper." <CO-RESUME ,CO " TAKE BOOK">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WRITE 6 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"6\" on the cube." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You move east." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " REZROV CABINET">>
	<ASSERT-TEXT "You cast REZROV on the cabinet. It opens." <CO-RESUME ,CO " TAKE MOLDY BOOK">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " CASKLY MOLDY BOOK">>
	<ASSERT-TEXT "You cast CASKLY on the moldy book. It is now in perfect condition." <CO-RESUME ,CO " READ MOLDY BOOK">>
	<ASSERT-TEXT "The book contains some magical writing." <CO-RESUME ,CO " GNUSTO SNAVIG">>
	<ASSERT-TEXT "You have learned the SNAVIG spell." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You move south." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You move west." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " DROP CARPET">>
	<ASSERT-TEXT "You drop the carpet." <CO-RESUME ,CO " SIT ON CARPET">>
	<ASSERT-TEXT "You sit on the carpet." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "The carpet floats up." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You fly west." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You fly west." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You fly west." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You fly west." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "The carpet descends." <CO-RESUME ,CO " GET OFF CARPET">>
	<ASSERT-TEXT "You get off the carpet." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " SIT ON CARPET">>
	<ASSERT-TEXT "You sit on the carpet." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "The carpet floats up." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You fly east." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You fly east." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You fly east." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You fly east." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "The carpet descends." <CO-RESUME ,CO " GET OFF CARPET">>
	<ASSERT-TEXT "You get off the carpet." <CO-RESUME ,CO " TAKE CARPET">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You climb down." <CO-RESUME ,CO " WRITE 7 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"7\" on the cube." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 3">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " SNAVIG">>
	<ASSERT-TEXT "You have learned the SNAVIG spell." <CO-RESUME ,CO " DROP ALL">>
	<ASSERT-TEXT "You drop everything." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You move south." <CO-RESUME ,CO " TAKE 3">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " SNAVIG GROUPER">>
	<ASSERT-TEXT "You cast SNAVIG on the grouper. You become the grouper." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You swim down as the grouper." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " TAKE ALL">>
	<ASSERT-TEXT "Taken. You transform back." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You swim up." <CO-RESUME ,CO " BLORPLE 3">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " TAKE ALL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WRITE 8 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"8\" on the cube." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 8">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You move west." <CO-RESUME ,CO " TINSOT FRAGMENT">>
	<ASSERT-TEXT "You cast TINSOT on the fragment." <CO-RESUME ,CO " TAKE FRAGMENT">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " PUT ALL IN ZIPPER EXCEPT BOOK">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO " TAKE 4">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " BLORPLE 4">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " TAKE COMPASS ROSE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 4">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You move west." <CO-RESUME ,CO " PUT ROSE IN CARVING">>
	<ASSERT-TEXT "You put the compass rose in the carving." <CO-RESUME ,CO " TAKE ROSE">>
	<ASSERT-TEXT "You take the compass rose." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " TOUCH NW RUNE WITH ROSE">>
	<ASSERT-TEXT "You touch the northwest rune with the rose." <CO-RESUME ,CO " NORTHWEST">>
	<ASSERT-TEXT "You move northwest." <CO-RESUME ,CO " TOUCH W RUNE WITH ROSE">>
	<ASSERT-TEXT "You touch the west rune with the rose." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You move west." <CO-RESUME ,CO " TOUCH NE RUNE WITH ROSE">>
	<ASSERT-TEXT "You touch the northeast rune with the rose." <CO-RESUME ,CO " NORTHEAST">>
	<ASSERT-TEXT "You move northeast." <CO-RESUME ,CO " REZROV ALABASTER">>
	<ASSERT-TEXT "You cast REZROV on the alabaster. It opens." <CO-RESUME ,CO " WEST">>
	<ASSERT-TEXT "You move west." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " TAKE BURIN">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WRITE 9 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"9\" on the cube." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 9">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You move south." <CO-RESUME ,CO " SIT ON GREEN ROCK">>
	<ASSERT-TEXT "You sit on the green rock." <CO-RESUME ,CO " TAKE FRAGMENT">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " GIVE FRAGMENT TO GREEN ROCK">>
	<ASSERT-TEXT "You give the fragment to the green rock." <CO-RESUME ,CO " SIT ON GREEN ROCK">>
	<ASSERT-TEXT "You sit on the green rock." <CO-RESUME ,CO " LOOK">>
	<ASSERT-TEXT "You see a brown rock nearby." <CO-RESUME ,CO " JUMP ON BROWN ROCK">>
	<ASSERT-TEXT "You jump on the brown rock." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WRITE 10 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"10\" on the cube." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 10">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You climb down." <CO-RESUME ,CO " SNAVIG">>
	<ASSERT-TEXT "You have learned the SNAVIG spell." <CO-RESUME ,CO " DROP ALL">>
	<ASSERT-TEXT "You drop everything." <CO-RESUME ,CO " TAKE 10">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " TAKE BOOK">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You move down." <CO-RESUME ,CO " SNAVIG GRUE">>
	<ASSERT-TEXT "You cast SNAVIG on the grue. You become the grue." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You move down as the grue." <CO-RESUME ,CO " CLIMB ON PILLAR">>
	<ASSERT-TEXT "You climb on the pillar. You transform back." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 10">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You climb down." <CO-RESUME ,CO " TAKE ALL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WRITE 11 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"11\" on the cube." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 11">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " TAKE BOX">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " EXAMINE BOX">>
	<ASSERT-TEXT "The box is small and wooden." <CO-RESUME ,CO " PUT 10 IN BOX">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO " TAKE 10">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " THROW BOX AT OUTCROPPING">>
	<ASSERT-TEXT "You throw the box at the outcropping. It shatters." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 10">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " TAKE BOX">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " TAKE CUBE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WRITE 12 ON CUBE">>
	<ASSERT-TEXT "You carefully inscribe \"12\" on the cube." <CO-RESUME ,CO " PUT ALL IN ZIPPER">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO " TAKE 7">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " TAKE BOOK">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " BLORPLE 7">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " SOUTH">>
	<ASSERT-TEXT "You move south." <CO-RESUME ,CO " ASK BELBOZ ABOUT ME">>
	<ASSERT-TEXT "You ask Belboz about yourself. He answers a question correctly from the enchante..." <CO-RESUME ,CO " ASK ABOUT CUBE">>
	<ASSERT-TEXT "You ask Belboz about the cube." <CO-RESUME ,CO " ASK ABOUT FIGURE">>
	<ASSERT-TEXT "You ask Belboz about the figure." <CO-RESUME ,CO " BLORPLE">>
	<ASSERT-TEXT "You have learned the BLORPLE spell." <CO-RESUME ,CO " TAKE 9">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " BLORPLE 9">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You move east." <CO-RESUME ,CO " REZROV DOOR">>
	<ASSERT-TEXT "You cast REZROV on the door. It opens." <CO-RESUME ,CO " PUT ALL IN ZIPPER">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO " TAKE BOOK">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " NORTH">>
	<ASSERT-TEXT "You move north." <CO-RESUME ,CO " DOWN">>
	<ASSERT-TEXT "You climb down." <CO-RESUME ,CO " TAKE KEY">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " UNLOCK CABINET WITH KEY">>
	<ASSERT-TEXT "You unlock the cabinet with the key." <CO-RESUME ,CO " OPEN CABINET">>
	<ASSERT-TEXT "You open the cabinet." <CO-RESUME ,CO " TAKE VELLUM SCROLL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " EXAMINE VELLUM SCROLL">>
	<ASSERT-TEXT "The vellum scroll contains some magical writing." <CO-RESUME ,CO " LEARN ALL SPELLS">>
	<ASSERT-TEXT "You learn all the spells from the scroll." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "You learn more spells." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "You learn more spells." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "You learn more spells." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "You learn more spells." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "You learn more spells." <CO-RESUME ,CO " AGAIN">>
	<ASSERT-TEXT "You learn more spells." <CO-RESUME ,CO " PUT BOOK IN CABINET">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO " CLOSE CABINET">>
	<ASSERT-TEXT "You close the cabinet." <CO-RESUME ,CO " LOCK CABINET WITH KEY">>
	<ASSERT-TEXT "You lock the cabinet with the key." <CO-RESUME ,CO " REZROV DOOR">>
	<ASSERT-TEXT "You cast REZROV on the door. It opens." <CO-RESUME ,CO " BLORPLE POWERFUL CUBE">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " UP">>
	<ASSERT-TEXT "You climb up." <CO-RESUME ,CO " OPEN SACK">>
	<ASSERT-TEXT "You open the sack." <CO-RESUME ,CO " TAKE FLIMSY SCROLL">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " TAKE BURIN">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " COPY FLIMSY ON VELLUM">>
	<ASSERT-TEXT "You copy the flimsy scroll onto the vellum." <CO-RESUME ,CO " TAKE SACK">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " EMPTY ZIPPER IN SACK">>
	<ASSERT-TEXT "You empty the contents of the zipper into the sack." <CO-RESUME ,CO " PUT FLIMSY IN ZIPPER">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO " CLOSE ZIPPER">>
	<ASSERT-TEXT "You close the zipper." <CO-RESUME ,CO " DROP ZIPPER">>
	<ASSERT-TEXT "You drop the zipper." <CO-RESUME ,CO " TAKE 12">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " BLORPLE 12">>
	<ASSERT-TEXT "The cube glows with a strange light." <CO-RESUME ,CO " EAST">>
	<ASSERT-TEXT "You move east." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " TAKE KNIFE">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "You wait." <CO-RESUME ,CO " GIRGOL">>
	<ASSERT-TEXT "You cast GIRGOL." <CO-RESUME ,CO " TAKE 11">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " PUT SACK IN TESSERACT">>
	<ASSERT-TEXT "You put the sack in the tesseract." <CO-RESUME ,CO " WAIT">>
	<TELL CR "spellbreaker transcript test completed!" CR>>
