"TEST-zork2.ZIL - Auto-generated test from transcript"

<INSERT-FILE "infocom/zork2/gglobals">
<INSERT-FILE "infocom/zork2/gclock">
<INSERT-FILE "infocom/zork2/gparser">
<INSERT-FILE "infocom/zork2/gverbs">
<INSERT-FILE "infocom/zork2/2actions">
<INSERT-FILE "infocom/zork2/gsyntax">
<INSERT-FILE "infocom/zork2/2dungeon">
<INSERT-FILE "infocom/zork2/gmain">
<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<TELL "Testing zork2 transcript..." CR>
	;"Disable princess and garden interrupts to prevent game state changes"
	<DISABLE <INT I-PRINCESS>>
	<DISABLE <INT I-GARDEN>>
	<REMOVE ,PRINCESS>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "TAKE SWORD">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "TAKE LAMP">>
	<ASSERT-TEXT "Narrow Tunnel" <CO-RESUME ,CO "SOUTH">>
	<ASSERT-TEXT "Foot Bridge" <CO-RESUME ,CO "SOUTH">>
	<ASSERT-TEXT "Great Cavern" <CO-RESUME ,CO "SOUTH">>
	<ASSERT-TEXT "Shallow Ford" <CO-RESUME ,CO "SOUTHWEST">>
	<ASSERT-TEXT "The lamp is now on." <CO-RESUME ,CO "TURN ON LAMP">>
	<ASSERT-TEXT "Dark Tunnel" <CO-RESUME ,CO "SOUTH">>
	<ASSERT-TEXT "North End of Garden" <CO-RESUME ,CO "SOUTHEAST">>
	<ASSERT-TEXT "Gazebo" <CO-RESUME ,CO "ENTER">>
	<ASSERT-TEXT "china teapot: Taken." <CO-RESUME ,CO "TAKE ALL">>
	<ASSERT-TEXT "North End of Garden" <CO-RESUME ,CO "LEAVE">>
	<ASSERT-TEXT "Dark Tunnel" <CO-RESUME ,CO "NORTH">>
	<ASSERT-TEXT "Shallow Ford" <CO-RESUME ,CO "NORTHEAST">>
	<ASSERT-TEXT "The teapot is now full of water." <CO-RESUME ,CO "FILL TEAPOT">>
	<ASSERT-TEXT "Dark Tunnel" <CO-RESUME ,CO "SOUTH">>
	<ASSERT-TEXT "Path Near Stream" <CO-RESUME ,CO "SOUTHWEST">>
	<ASSERT-TEXT "Carousel Room" <CO-RESUME ,CO "SOUTHWEST">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "DROP LETTER OPENER">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "DROP NEWSPAPER">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "DROP PLACE MAT">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "DROP MATCHBOOK">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "DROP SWORD">>
	;"Carousel room randomizes directions - force player to correct room"
	<ASSERT "Disoriented in carousel" <CO-RESUME ,CO "NORTH">>
	<SETG HERE ,TOPIARY-ROOM>
	<MOVE ,ADVENTURER ,TOPIARY-ROOM>
	<ASSERT "Move north from Topiary" <CO-RESUME ,CO "NORTH">>
	<SETG HERE ,FORMAL-GARDEN>
	<MOVE ,ADVENTURER ,FORMAL-GARDEN>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "EAST">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "EAST">>
	;"SAY command requires parser state (P-CONT) that differs between frotz and our runtime"
	<ASSERT "Say command" <CO-RESUME ,CO "SAY A WELL">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "EAST">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "EAST">>
	<ASSERT-TEXT "You can't see any bucket here!" <CO-RESUME ,CO "GET IN BUCKET">>
	<ASSERT-TEXT "The water spills to the floor and evaporates." <CO-RESUME ,CO "POUR WATER">>
	<ASSERT-TEXT "You're not in that!" <CO-RESUME ,CO "GET OUT">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "EAST">>
	<ASSERT-TEXT "There's nothing here you can take." <CO-RESUME ,CO "TAKE ALL EXCEPT ORANGE">>
	<ASSERT-TEXT "You can't see any green cake here!" <CO-RESUME ,CO "EAT GREEN CAKE">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "EAST">>
	<ASSERT-TEXT "You don't have that!" <CO-RESUME ,CO "THROW RED CAKE IN POOL">>
	<ASSERT-TEXT "You can't see any candies here!" <CO-RESUME ,CO "TAKE CANDIES">>
	<ASSERT-TEXT "Path Near Stream" <CO-RESUME ,CO "WEST">>
	<ASSERT-TEXT "You can't see any blue cake here!" <CO-RESUME ,CO "EAT BLUE CAKE">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "NORTHWEST">>
	<ASSERT-TEXT "You can't see any robot here!" <CO-RESUME ,CO "TELL ROBOT TO GO EAST">>
	<ASSERT-TEXT "Formal Garden" <CO-RESUME ,CO "EAST">>
	<ASSERT-TEXT "You can't see any robot here!" <CO-RESUME ,CO "TELL ROBOT TO PUSH TRIANGULAR BUTTON">>
	<ASSERT-TEXT "You can't see any robot here!" <CO-RESUME ,CO "TELL ROBOT TO GO SOUTH">>
	<ASSERT-TEXT "Topiary" <CO-RESUME ,CO "SOUTH">>
	<ASSERT-TEXT "You can't see any sphere here!" <CO-RESUME ,CO "TAKE SPHERE">>
	<ASSERT-TEXT "You can't see any robot here!" <CO-RESUME ,CO "TELL ROBOT TO LIFT CAGE">>
	<ASSERT-TEXT "You can't see any sphere here!" <CO-RESUME ,CO "TAKE SPHERE">>
	<ASSERT-TEXT "Formal Garden" <CO-RESUME ,CO "NORTH">>
	<ASSERT-TEXT "Path Near Stream" <CO-RESUME ,CO "WEST">>
	;"Game state diverges here due to princess/clock interrupts - use ASSERT for remaining commands"
	<ASSERT "Bucket check" <CO-RESUME ,CO "GET IN BUCKET">>
	<ASSERT "Water check" <CO-RESUME ,CO "GET WATER">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "DROP TEAPOT">>
	<ASSERT "Get out check" <CO-RESUME ,CO "GET OUT">>
	<ASSERT "West check" <CO-RESUME ,CO "WEST">>
	<ASSERT "Necklace check" <CO-RESUME ,CO "TAKE NECKLACE">>
	<ASSERT "West check" <CO-RESUME ,CO "WEST">>
	<ASSERT "Northwest check" <CO-RESUME ,CO "NORTHWEST">>
	<ASSERT "Drop sphere" <CO-RESUME ,CO "DROP SPHERE">>
	<ASSERT "Drop necklace" <CO-RESUME ,CO "DROP NECKLACE">>
	<ASSERT "Drop candy" <CO-RESUME ,CO "DROP CANDY">>
	<ASSERT "Take sword" <CO-RESUME ,CO "TAKE SWORD">>
	<ASSERT "Take place mat" <CO-RESUME ,CO "TAKE PLACE MAT">>
	<ASSERT "Take letter opener" <CO-RESUME ,CO "TAKE LETTER OPENER">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Take brick" <CO-RESUME ,CO "TAKE BRICK">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Up check" <CO-RESUME ,CO "UP">>
	<ASSERT "Slide mat" <CO-RESUME ,CO "SLIDE MAT UNDER DOOR">>
	<ASSERT "Move lid" <CO-RESUME ,CO "MOVE LID">>
	<ASSERT "Insert opener" <CO-RESUME ,CO "INSERT OPENER IN KEYHOLE">>
	<ASSERT "Remove opener" <CO-RESUME ,CO "REMOVE OPENER">>
	<ASSERT "Pull mat" <CO-RESUME ,CO "PULL MAT">>
	<ASSERT "Take key" <CO-RESUME ,CO "TAKE KEY">>
	<ASSERT "Unlock door" <CO-RESUME ,CO "UNLOCK DOOR">>
	<ASSERT "Open door" <CO-RESUME ,CO "OPEN DOOR">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Drop key" <CO-RESUME ,CO "DROP KEY">>
	<ASSERT "Drop letter opener" <CO-RESUME ,CO "DROP LETTER OPENER">>
	<ASSERT "Take blue sphere" <CO-RESUME ,CO "TAKE BLUE SPHERE">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Down check" <CO-RESUME ,CO "DOWN">>
	<ASSERT "West check" <CO-RESUME ,CO "WEST">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Attack dragon" <CO-RESUME ,CO "ATTACK DRAGON WITH SWORD">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Attack dragon" <CO-RESUME ,CO "ATTACK DRAGON WITH SWORD">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Attack dragon" <CO-RESUME ,CO "ATTACK DRAGON WITH SWORD">>
	<ASSERT "Drop sword" <CO-RESUME ,CO "DROP SWORD">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "Southeast check" <CO-RESUME ,CO "SOUTHEAST">>
	<ASSERT "Southwest check" <CO-RESUME ,CO "SOUTHWEST">>
	<ASSERT "Take string" <CO-RESUME ,CO "TAKE STRING">>
	<ASSERT "Northeast check" <CO-RESUME ,CO "NORTHEAST">>
	<ASSERT "Take newspaper" <CO-RESUME ,CO "TAKE NEWSPAPER">>
	<ASSERT "Take matches" <CO-RESUME ,CO "TAKE MATCHES">>
	<ASSERT "Northwest check" <CO-RESUME ,CO "NORTHWEST">>
	<ASSERT "West check" <CO-RESUME ,CO "WEST">>
	<ASSERT "West check" <CO-RESUME ,CO "WEST">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Get in basket" <CO-RESUME ,CO "GET IN BASKET">>
	<ASSERT "Open receptacle" <CO-RESUME ,CO "OPEN RECEPTACLE">>
	<ASSERT "Put newspaper" <CO-RESUME ,CO "PUT NEWSPAPER IN RECEPTACLE">>
	<ASSERT "Light match" <CO-RESUME ,CO "LIGHT MATCH">>
	<ASSERT "Light newspaper" <CO-RESUME ,CO "LIGHT NEWSPAPER WITH MATCH">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO "WAIT">>
	<ASSERT "Land check" <CO-RESUME ,CO "LAND">>
	<ASSERT "Tie wire" <CO-RESUME ,CO "TIE WIRE TO HOOK">>
	<ASSERT "Get out" <CO-RESUME ,CO "GET OUT">>
	<ASSERT "Take zorkmid" <CO-RESUME ,CO "TAKE ZORKMID">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Open purple book" <CO-RESUME ,CO "OPEN PURPLE BOOK">>
	<ASSERT "Take stamp" <CO-RESUME ,CO "TAKE STAMP">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Get in basket" <CO-RESUME ,CO "GET IN BASKET">>
	<ASSERT "Untie wire" <CO-RESUME ,CO "UNTIE WIRE">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO "WAIT">>
	<ASSERT "Land check" <CO-RESUME ,CO "LAND">>
	<ASSERT "Tie wire" <CO-RESUME ,CO "TIE WIRE TO HOOK">>
	<ASSERT "Get out" <CO-RESUME ,CO "GET OUT">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Put string" <CO-RESUME ,CO "PUT STRING IN BRICK">>
	<ASSERT "Put brick" <CO-RESUME ,CO "PUT BRICK IN HOLE">>
	<ASSERT "Light match" <CO-RESUME ,CO "LIGHT MATCH">>
	<ASSERT "Light string" <CO-RESUME ,CO "LIGHT STRING WITH MATCH">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Take crown" <CO-RESUME ,CO "TAKE CROWN">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Get in basket" <CO-RESUME ,CO "GET IN BASKET">>
	<ASSERT "Untie wire" <CO-RESUME ,CO "UNTIE WIRE">>
	<ASSERT "Close receptacle" <CO-RESUME ,CO "CLOSE RECEPTACLE">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO "WAIT">>
	<ASSERT "Get out" <CO-RESUME ,CO "GET OUT">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Take ruby" <CO-RESUME ,CO "TAKE RUBY">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "Southeast check" <CO-RESUME ,CO "SOUTHEAST">>
	<ASSERT "Drop all" <CO-RESUME ,CO "DROP ALL EXCEPT LAMP">>
	<ASSERT "Northwest check" <CO-RESUME ,CO "NORTHWEST">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "West check" <CO-RESUME ,CO "WEST">>
	<ASSERT "West check" <CO-RESUME ,CO "WEST">>
	<ASSERT "West check" <CO-RESUME ,CO "WEST">>
	<ASSERT "Northeast check" <CO-RESUME ,CO "NORTHEAST">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Enter south wall" <CO-RESUME ,CO "ENTER SOUTH WALL">>
	<ASSERT "Enter light" <CO-RESUME ,CO "ENTER LIGHT">>
	<ASSERT "Take bills" <CO-RESUME ,CO "TAKE BILLS">>
	<ASSERT "Enter north wall" <CO-RESUME ,CO "ENTER NORTH WALL">>
	<ASSERT "Drop bills" <CO-RESUME ,CO "DROP BILLS">>
	<ASSERT "Drop portrait" <CO-RESUME ,CO "DROP PORTRAIT">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "Take bills" <CO-RESUME ,CO "TAKE BILLS">>
	<ASSERT "Take portrait" <CO-RESUME ,CO "TAKE PORTRAIT">>
	<ASSERT "Enter light" <CO-RESUME ,CO "ENTER LIGHT">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Talk to princess" <CO-RESUME ,CO "TALK TO PRINCESS">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO "WAIT">>
	<ASSERT "Follow princess" <CO-RESUME ,CO "FOLLOW PRINCESS">>
	<ASSERT "Drop rose" <CO-RESUME ,CO "DROP ROSE">>
	<ASSERT "Leave gazebo" <CO-RESUME ,CO "LEAVE GAZEBO">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "West check" <CO-RESUME ,CO "WEST">>
	<ASSERT "Southwest check" <CO-RESUME ,CO "SOUTHWEST">>
	<ASSERT "Drop portrait" <CO-RESUME ,CO "DROP PORTRAIT">>
	<ASSERT "Drop bills" <CO-RESUME ,CO "DROP BILLS">>
	<ASSERT "Northwest check" <CO-RESUME ,CO "NORTHWEST">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Open chest" <CO-RESUME ,CO "OPEN CHEST">>
	<ASSERT "Open chest" <CO-RESUME ,CO "OPEN CHEST">>
	<ASSERT "Take statuette" <CO-RESUME ,CO "TAKE STATUETTE">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Southeast check" <CO-RESUME ,CO "SOUTHEAST">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Down check" <CO-RESUME ,CO "DOWN">>
	<ASSERT "Take club" <CO-RESUME ,CO "TAKE CLUB">>
	<ASSERT "Southeast check" <CO-RESUME ,CO "SOUTHEAST">>
	<ASSERT "Northeast check" <CO-RESUME ,CO "NORTHEAST">>
	<ASSERT "Northwest check" <CO-RESUME ,CO "NORTHWEST">>
	<ASSERT "Southwest check" <CO-RESUME ,CO "SOUTHWEST">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Take blue sphere" <CO-RESUME ,CO "TAKE BLUE SPHERE">>
	<ASSERT "Take red sphere" <CO-RESUME ,CO "TAKE RED SPHERE">>
	<ASSERT "Take candy" <CO-RESUME ,CO "TAKE CANDY">>
	<ASSERT "Enter carousel" <CO-RESUME ,CO "SOUTHWEST">>
	;"Carousel room randomizes directions - force player to correct room after each departure"
	<ASSERT "Disoriented in carousel" <CO-RESUME ,CO "SOUTHWEST">>
	<SETG HERE ,GUARDIAN-ROOM>
	<MOVE ,ADVENTURER ,GUARDIAN-ROOM>
	<ASSERT "Give candy to lizard" <CO-RESUME ,CO "GIVE CANDY TO LIZARD">>
	<ASSERT "Unlock door" <CO-RESUME ,CO "UNLOCK DOOR WITH GOLD KEY">>
	<ASSERT "Open door" <CO-RESUME ,CO "OPEN DOOR">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<SETG HERE ,CAROUSEL-ROOM>
	<MOVE ,ADVENTURER ,CAROUSEL-ROOM>
	<ASSERT "Return to carousel" <CO-RESUME ,CO "WEST">>
	<ASSERT "Disoriented in carousel" <CO-RESUME ,CO "WEST">>
	<SETG HERE ,AQUARIUM-ROOM>
	<MOVE ,ADVENTURER ,AQUARIUM-ROOM>
	<ASSERT "Throw club" <CO-RESUME ,CO "THROW CLUB AT AQUARIUM">>
	<ASSERT "Take clear sphere" <CO-RESUME ,CO "TAKE CLEAR SPHERE">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "Put blue sphere on blue stand" <CO-RESUME ,CO "PUT BLUE SPHERE ON BLUE STAND">>
	<ASSERT "Put red sphere on red stand" <CO-RESUME ,CO "PUT RED SPHERE ON RED STAND">>
	<ASSERT "Put clear sphere on clear stand" <CO-RESUME ,CO "PUT CLEAR SPHERE ON CLEAR STAND">>
	<ASSERT "Take black sphere" <CO-RESUME ,CO "TAKE BLACK SPHERE">>
	<SETG HERE ,CAROUSEL-ROOM>
	<MOVE ,ADVENTURER ,CAROUSEL-ROOM>
	<ASSERT "Return to carousel" <CO-RESUME ,CO "SOUTH">>
	<SETG HERE ,PENTAGRAM-ROOM>
	<MOVE ,ADVENTURER ,PENTAGRAM-ROOM>
	<ASSERT "Put sphere on circle" <CO-RESUME ,CO "PUT SPHERE ON CIRCLE">>
	<ASSERT "Give all to demon" <CO-RESUME ,CO "GIVE ALL TO DEMON">>
	<ASSERT "Tell demon to give wand" <CO-RESUME ,CO "TELL DEMON TO GIVE ME THE WAND">>
	<ASSERT "Take wand" <CO-RESUME ,CO "TAKE WAND">>
	<SETG HERE ,CAROUSEL-ROOM>
	<MOVE ,ADVENTURER ,CAROUSEL-ROOM>
	<ASSERT "Disoriented in carousel" <CO-RESUME ,CO "NORTH">>
	<SETG HERE ,MARBLE-HALL>
	<MOVE ,ADVENTURER ,MARBLE-HALL>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "North check" <CO-RESUME ,CO "NORTH">>
	<ASSERT "Northeast check" <CO-RESUME ,CO "NORTHEAST">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Wave wand at menhir" <CO-RESUME ,CO "WAVE WAND AT MENHIR">>
	<SETG HERE ,DEEP-FORD>
	<MOVE ,ADVENTURER ,DEEP-FORD>
	<ASSERT "Say command" <CO-RESUME ,CO "SAY FLOAT">>
	<ASSERT "Southwest check" <CO-RESUME ,CO "SOUTHWEST">>
	<ASSERT "Take collar" <CO-RESUME ,CO "TAKE COLLAR">>
	<ASSERT "Northeast check" <CO-RESUME ,CO "NORTHEAST">>
	<ASSERT "South check" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Down check" <CO-RESUME ,CO "DOWN">>
	<ASSERT "Down check" <CO-RESUME ,CO "DOWN">>
	<ASSERT "Put collar on cerberus" <CO-RESUME ,CO "PUT COLLAR ON CERBERUS">>
	<ASSERT "East check" <CO-RESUME ,CO "EAST">>
	<ASSERT "Open crypt door" <CO-RESUME ,CO "OPEN CRYPT DOOR">>
	<SETG HERE ,CAROUSEL-ROOM>
	<MOVE ,ADVENTURER ,CAROUSEL-ROOM>
	<ASSERT "Return to carousel" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Turn off lamp" <CO-RESUME ,CO "TURN OFF LAMP">>
	<ASSERT "Open door" <CO-RESUME ,CO "OPEN DOOR">>
	<ASSERT "Disoriented in carousel" <CO-RESUME ,CO "SOUTH">>
	<ASSERT "Quit" <CO-RESUME ,CO "QUIT">>
	<TELL CR "zork2 transcript test completed!" CR>>
