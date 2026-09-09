"TEST-planetfall.ZIL - Auto-generated test from transcript"

<INSERT-FILE "infocom/planetfall/globals">
<INSERT-FILE "infocom/planetfall/parser">
<INSERT-FILE "infocom/planetfall/verbs">
<INSERT-FILE "infocom/planetfall/syntax">
<INSERT-FILE "infocom/planetfall/planetfall">
<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<TELL "Testing planetfall transcript..." CR>
	<ASSERT-TEXT "Start of a transcript of PLANETFALL." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in the living quarters of a small vessel. There is a webbing here, bolte..." <CO-RESUME ,CO " GET INTO WEBBING">>
	<ASSERT-TEXT "You strap yourself into the webbing." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " GET OUT OF WEBBING">>
	<ASSERT-TEXT "You remove yourself from the webbing." <CO-RESUME ,CO " TAKE ALL">>
	<ASSERT-TEXT "webbing: Already have that." <CO-RESUME ,CO " OPEN DOOR">>
	<ASSERT-TEXT "You open the door, revealing a closet. The door swings shut again." <CO-RESUME ,CO " U">>
	<ASSERT-TEXT "You are in a narrow shaft. A ladder runs up and down. There is a narrow opening ..." <CO-RESUME ,CO " U">>
	<ASSERT-TEXT "You are in a wide shaft. A ladder runs up and down. There is a wide opening to t..." <CO-RESUME ,CO " U">>
	<ASSERT-TEXT "You are in a wide shaft. A ladder runs up and down. There is a wide opening to t..." <CO-RESUME ,CO " U">>
	<ASSERT-TEXT "You are in a wide shaft. A ladder runs up and down. There is a wide opening to t..." <CO-RESUME ,CO " U">>
	<ASSERT-TEXT "You are in a wide shaft. A ladder runs up and down. There is a wide opening to t..." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south, north, and northeast." <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "You are in a corridor. Passages lead southwest and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " TAKE ID CARD">>
	<ASSERT-TEXT "ID card: Already have that." <CO-RESUME ,CO " DROP ALL EXCEPT KIT">>
	<ASSERT-TEXT "kit: (keeping)" <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a storage room. Passages lead west and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a storage room. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a storage room. Passages lead north and southwest." <CO-RESUME ,CO " SW">>
	<ASSERT-TEXT "You are in a storage room. Passages lead northeast and south." <CO-RESUME ,CO " TAKE ALL">>
	<ASSERT-TEXT "battery: Taken." <CO-RESUME ,CO " DROP BATTERY">>
	<ASSERT-TEXT "battery: Dropped." <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "You are in a storage room. Passages lead southwest and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " PUT BAR OVER CREVICE">>
	<ASSERT-TEXT "You can't see any such thing." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a storage room. Passages lead west and south." <CO-RESUME ,CO " DROP ALL EXCEPT KEY">>
	<ASSERT-TEXT "key: (keeping)" <CO-RESUME ,CO " PRESS BLUE BUTTON">>
	<ASSERT-TEXT "You press the blue button on the kit." <CO-RESUME ,CO " PRESS RED BUTTON">>
	<ASSERT-TEXT "You press the red button on the kit." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " UNLOCK PADLOCK WITH KEY">>
	<ASSERT-TEXT "You unlock the padlock." <CO-RESUME ,CO " TAKE PADLOCK">>
	<ASSERT-TEXT "padlock: Taken." <CO-RESUME ,CO " OPEN DOOR">>
	<ASSERT-TEXT "You open the door." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a storage closet." <CO-RESUME ,CO " DROP KEY AND PADLOCK">>
	<ASSERT-TEXT "key: Dropped." <CO-RESUME ,CO " TAKE LADDER">>
	<ASSERT-TEXT "ladder: Taken." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " DROP LADDER">>
	<ASSERT-TEXT "ladder: Dropped." <CO-RESUME ,CO " EXTEND LADDER">>
	<ASSERT-TEXT "You extend the ladder to its full length." <CO-RESUME ,CO " PUT LADDER OVER RIFT">>
	<ASSERT-TEXT "You place the ladder over the rift." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are on a ledge. A ladder leads south over a rift. To the north is a small op..." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a small room. A desk is against the wall. There is a small drawer in ..." <CO-RESUME ,CO " OPEN DESK">>
	<ASSERT-TEXT "You open the desk. There is a card here." <CO-RESUME ,CO " PUT KITCHEN CARD AND UPPER CARD INTO POCKET">>
	<ASSERT-TEXT "kitchen card: You put the kitchen card into your pocket." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a small room. A desk is against the wall. There is a small drawer in ..." <CO-RESUME ,CO " OPEN DESK">>
	<ASSERT-TEXT "You open the desk. There is a card here." <CO-RESUME ,CO " PUT SHUTTLE CARD INTO POCKET">>
	<ASSERT-TEXT "shuttle card: You put the shuttle card into your pocket." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a small room. A desk is against the wall." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are on a ledge. A ladder leads south over a rift." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a storage room. Passages lead west and south." <CO-RESUME ,CO " TAKE KIT AND FLASK">>
	<ASSERT-TEXT "kit: Taken." <CO-RESUME ,CO " OPEN KIT">>
	<ASSERT-TEXT "You open the kit." <CO-RESUME ,CO " EAT RED GOO">>
	<ASSERT-TEXT "You eat the red goo. It tastes like strawberry." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and southeast." <CO-RESUME ,CO " SE">>
	<ASSERT-TEXT "You are in a robot repair shop. There is a robot here." <CO-RESUME ,CO " OPEN ROBOT">>
	<ASSERT-TEXT "You open the robot." <CO-RESUME ,CO " CLOSE ROBOT">>
	<ASSERT-TEXT "You close the robot." <CO-RESUME ,CO " TURN ON ROBOT">>
	<ASSERT-TEXT "You turn on the robot. The robot says, \"Hello. I am Feldspar, model XR-32. How c..." <CO-RESUME ,CO " NW">>
	<ASSERT-TEXT "You are in a corridor. Passages lead southeast and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a storage room. Passages lead west and south." <CO-RESUME ,CO " TAKE BEDISTOR">>
	<ASSERT-TEXT "bedistor: Taken." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a storage room. Passages lead west and south." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " SLIDE UPPER CARD THROUGH SLOT">>
	<ASSERT-TEXT "You slide the upper card through the slot." <CO-RESUME ,CO " PRESS UP BUTTON">>
	<ASSERT-TEXT "You press the up button." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The elevator arrives." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and northeast." <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "You are in a corridor. Passages lead southwest and south." <CO-RESUME ,CO " SW">>
	<ASSERT-TEXT "You are in a corridor. Passages lead northeast and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " PRESS DOWN BUTTON">>
	<ASSERT-TEXT "You press the down button." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The elevator arrives." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " PUT FLASK UNDER SPOOT">>
	<ASSERT-TEXT "You put the flask under the spout." <CO-RESUME ,CO " PRESS GREEN BUTTON">>
	<ASSERT-TEXT "You press the green button on the wall." <CO-RESUME ,CO " TAKE FLASK">>
	<ASSERT-TEXT "flask: Taken." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " SLIDE UPPER CARD THROUGH SLOT">>
	<ASSERT-TEXT "You slide the upper card through the slot." <CO-RESUME ,CO " PRESS UP BUTTON">>
	<ASSERT-TEXT "You press the up button." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The elevator arrives." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and northeast." <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "You are in a corridor. Passages lead southwest and south." <CO-RESUME ,CO " POUR LIQUID INTO FUNNEL">>
	<ASSERT-TEXT "You pour the liquid into the funnel. The enunciator panel goes dark." <CO-RESUME ,CO " SW">>
	<ASSERT-TEXT "You are in a corridor. Passages lead northeast and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " PRESS DOWN BUTTON">>
	<ASSERT-TEXT "You press the down button." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The elevator arrives." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and south." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " GET IN BED">>
	<ASSERT-TEXT "You get into the bed." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " GET UP">>
	<ASSERT-TEXT "You get out of the bed." <CO-RESUME ,CO " TAKE ALL">>
	<ASSERT-TEXT "bed: (keeping)" <CO-RESUME ,CO " EAT GREEN GOO">>
	<ASSERT-TEXT "You eat the green goo. It tastes like lime." <CO-RESUME ,CO " DROP KIT">>
	<ASSERT-TEXT "kit: Dropped." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " TAKE CANTEEN">>
	<ASSERT-TEXT "canteen: Taken." <CO-RESUME ,CO " SLIDE KITCHEN CARD THROUGH SLOT">>
	<ASSERT-TEXT "You slide the kitchen card through the slot." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " OPEN CANTEEN">>
	<ASSERT-TEXT "You open the canteen." <CO-RESUME ,CO " PUT CANTEEN INTO NICHE">>
	<ASSERT-TEXT "You put the canteen into the niche." <CO-RESUME ,CO " PRESS BUTTON">>
	<ASSERT-TEXT "You press the button. The canteen begins to fill with liquid." <CO-RESUME ,CO " TAKE CANTEEN">>
	<ASSERT-TEXT "canteen: Taken." <CO-RESUME ,CO " CLOSE CANTEEN">>
	<ASSERT-TEXT "You close the canteen." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " DROP KITCHEN CARD">>
	<ASSERT-TEXT "kitchen card: Dropped." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " DROP FLASK AND UPPER CARD">>
	<ASSERT-TEXT "flask: Dropped." <CO-RESUME ,CO " TAKE LASER AND PLIERS">>
	<ASSERT-TEXT "laser: Taken." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " SLIDE LOWER CARD THROUGH SLOT">>
	<ASSERT-TEXT "You slide the lower card through the slot." <CO-RESUME ,CO " PRESS DOWN BUTTON">>
	<ASSERT-TEXT "You press the down button." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "The elevator arrives." <CO-RESUME ,CO " DROP LOWER CARD">>
	<ASSERT-TEXT "lower card: Dropped." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " SLIDE SHUTTLE CARD THROUGH SLOT">>
	<ASSERT-TEXT "You slide the shuttle card through the slot." <CO-RESUME ,CO " PUSH LEVER UP">>
	<ASSERT-TEXT "You push the lever up." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " PULL LEVER DOWN">>
	<ASSERT-TEXT "You pull the lever down." <CO-RESUME ,CO " PULL LEVER DOWN">>
	<ASSERT-TEXT "You pull the lever down." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " DROP SHUTTLE CARD">>
	<ASSERT-TEXT "shuttle card: Dropped." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "You are in a corridor. Passages lead southwest and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and east." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " OPEN LID">>
	<ASSERT-TEXT "You open the lid." <CO-RESUME ,CO " TAKE FUSED BEDISTOR WITH PLIERS">>
	<ASSERT-TEXT "You take the fused bedistor with the pliers." <CO-RESUME ,CO " PUT GOOD BEDISTOR INTO CUBE">>
	<ASSERT-TEXT "You put the good bedistor into the cube." <CO-RESUME ,CO " CLOSE CUBE">>
	<ASSERT-TEXT "You close the cube." <CO-RESUME ,CO " OPEN CANTEEN">>
	<ASSERT-TEXT "You open the canteen." <CO-RESUME ,CO " DRINK LIQUID">>
	<ASSERT-TEXT "You drink the liquid. It tastes like water." <CO-RESUME ,CO " DROP PLIERS AND FUSED BEDISTOR AND CANTEEN">>
	<ASSERT-TEXT "pliers: Dropped." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " FLOYD, GO N">>
	<ASSERT-TEXT "Floyd says, \"Okay!\" Floyd goes north." <CO-RESUME ,CO " FLOYD, GET SHINY FROMITZ BOARD">>
	<ASSERT-TEXT "Floyd says, \"Okay!\" Floyd takes the shiny fromitz board." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and south." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " OPEN PANEL">>
	<ASSERT-TEXT "You open the panel." <CO-RESUME ,CO " TAKE SECOND BOARD">>
	<ASSERT-TEXT "second board: Taken." <CO-RESUME ,CO " PUT SHINY BOARD INTO SOCKET">>
	<ASSERT-TEXT "You put the shiny board into the socket." <CO-RESUME ,CO " CLOSE PANEL">>
	<ASSERT-TEXT "You close the panel." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and southeast." <CO-RESUME ,CO " NE">>
	<ASSERT-TEXT "You are in a corridor. Passages lead southwest and south." <CO-RESUME ,CO " OPEN BIO-LAB DOOR">>
	<ASSERT-TEXT "You open the bio-lab door." <CO-RESUME ,CO " SE">>
	<ASSERT-TEXT "You are in a corridor. Passages lead northwest and east." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in the biology lab. A large window looks south." <CO-RESUME ,CO " LOOK THROUGH WINDOW">>
	<ASSERT-TEXT "Through the window, you can see another room. There appears to be a speck on the..." <CO-RESUME ,CO " OPEN DOOR">>
	<ASSERT-TEXT "You open the door." <CO-RESUME ,CO " CLOSE DOOR">>
	<ASSERT-TEXT "You close the door." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " OPEN DOOR">>
	<ASSERT-TEXT "You open the door." <CO-RESUME ,CO " CLOSE DOOR">>
	<ASSERT-TEXT "You close the door." <CO-RESUME ,CO " PUT MINI CARD INTO POCKET">>
	<ASSERT-TEXT "mini card: You put the mini card into your pocket." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " OPEN DOOR">>
	<ASSERT-TEXT "You open the door." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " PUT BATTERY INTO LASER">>
	<ASSERT-TEXT "You put the battery into the laser." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and northeast." <CO-RESUME ,CO " SW">>
	<ASSERT-TEXT "You are in a corridor. Passages lead northeast and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " SLIDE MINI CARD THROUGH SLOT">>
	<ASSERT-TEXT "You slide the mini card through the slot." <CO-RESUME ,CO " TYPE 384">>
	<ASSERT-TEXT "You type 384 on the keyboard." <CO-RESUME ,CO " E">>
	<ASSERT-TEXT "You are in a corridor. Passages lead west and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " TURN DIAL TO 1">>
	<ASSERT-TEXT "You turn the dial to 1." <CO-RESUME ,CO " FIRE LASER AT SPECK">>
	<ASSERT-TEXT "You fire the laser at the speck. The speck begins to glow." <CO-RESUME ,CO " TURN DIAL TO 6">>
	<ASSERT-TEXT "You turn the dial to 6." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " FIRE LASER AT MICROBE">>
	<ASSERT-TEXT "You fire the laser at the microbe. The microbe writhes." <CO-RESUME ,CO " FIRE LASER AT MICROBE">>
	<ASSERT-TEXT "You fire the laser at the microbe. The microbe writhes." <CO-RESUME ,CO " FIRE LASER AT MICROBE">>
	<ASSERT-TEXT "You fire the laser at the microbe. The microbe writhes." <CO-RESUME ,CO " FIRE LASER AT MICROBE">>
	<ASSERT-TEXT "You fire the laser at the microbe. The microbe writhes." <CO-RESUME ,CO " FIRE LASER AT MICROBE">>
	<ASSERT-TEXT "You fire the laser at the microbe. The microbe writhes." <CO-RESUME ,CO " FIRE LASER AT MICROBE">>
	<ASSERT-TEXT "You fire the laser at the microbe. The laser is very warm." <CO-RESUME ,CO " THROW LASER OVER EDGE">>
	<ASSERT-TEXT "You throw the laser over the edge." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and north." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " OPEN DESK">>
	<ASSERT-TEXT "You open the desk. There is a gas mask here." <CO-RESUME ,CO " WEAR GAS MASK">>
	<ASSERT-TEXT "You wear the gas mask." <CO-RESUME ,CO " PRESS WHITE BUTTON">>
	<ASSERT-TEXT "You press the white button on the wall." <CO-RESUME ,CO " PRESS RED BUTTON">>
	<ASSERT-TEXT "You press the red button on the wall." <CO-RESUME ,CO " OPEN OFFICE DOOR">>
	<ASSERT-TEXT "You open the office door." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " OPEN LAB DOOR">>
	<ASSERT-TEXT "You open the lab door." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " OPEN DOOR">>
	<ASSERT-TEXT "You open the door." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " W">>
	<ASSERT-TEXT "You are in a corridor. Passages lead east and west." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " S">>
	<ASSERT-TEXT "You are in a corridor. Passages lead north and south." <CO-RESUME ,CO " PRESS BUTTON">>
	<ASSERT-TEXT "You press the button." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " WAIT">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO " N">>
	<ASSERT-TEXT "You are in a corridor. Passages lead south and north." <CO-RESUME ,CO " QUIT">>
	<ASSERT-TEXT "Would you like to end the transcript? (Y/N)" <CO-RESUME ,CO " Y">>
	<TELL CR "planetfall transcript test completed!" CR>>
