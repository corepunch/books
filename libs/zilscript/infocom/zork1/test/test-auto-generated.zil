"TEST-zork1.ZIL - Auto-generated test from transcript"

<INSERT-FILE "infocom/zork1/globals">
<INSERT-FILE "infocom/zork1/clock">
<INSERT-FILE "infocom/zork1/parser">
<INSERT-FILE "infocom/zork1/verbs">
<INSERT-FILE "infocom/zork1/actions">
<INSERT-FILE "infocom/zork1/syntax">
<INSERT-FILE "infocom/zork1/dungeon">
<INSERT-FILE "infocom/zork1/main">
<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<TELL "Testing zork1 transcript..." CR>
	<ASSERT-TEXT "Opening the small mailbox reveals a leaflet." <CO-RESUME ,CO "open mailbox">>
	<ASSERT-TEXT "(Taken)" <CO-RESUME ,CO "read leaflet">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop leaflet">>
	<ASSERT-TEXT "South of House" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Behind House" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "With great effort, you open the window far enough to allow entry." <CO-RESUME ,CO "open window">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "enter house">>
	<ASSERT-TEXT "Living Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take lamp">>
	<ASSERT-TEXT "With a great effort, the rug is moved to one side of the room, revealing the dus..." <CO-RESUME ,CO "move rug">>
	<ASSERT-TEXT "The door reluctantly opens to reveal a rickety staircase descending into darknes..." <CO-RESUME ,CO "open trap door">>
	<ASSERT-TEXT "The brass lantern is now on." <CO-RESUME ,CO "turn on lamp">>
	<ASSERT-TEXT "The trap door crashes shut, and you hear someone barring it." <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "East of Chasm" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Gallery" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take painting">>
	<ASSERT-TEXT "Studio" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "go up chimney">>
	<ASSERT-TEXT "Attic" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take knife">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take rope">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Living Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Opened." <CO-RESUME ,CO "open case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put painting inside case">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop knife">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take sword">>
	<ASSERT-TEXT "The door reluctantly opens to reveal a rickety staircase descending into darknes..." <CO-RESUME ,CO "open trap door">>
	<ASSERT-TEXT "The trap door crashes shut, and you hear someone barring it." <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "The Troll Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "You are still recovering from that last blow, so your attack is ineffective." <CO-RESUME ,CO "kill troll with sword">>
	<ASSERT-TEXT "Clang! Crash! The troll parries." <CO-RESUME ,CO "kill troll with sword">>
	<ASSERT-TEXT "The troll is confused and can't fight back." <CO-RESUME ,CO "kill troll with sword">>
	<ASSERT-TEXT "The troll is knocked out!" <CO-RESUME ,CO "kill troll with sword">>
	<ASSERT-TEXT "The unarmed troll cannot defend himself: He dies." <CO-RESUME ,CO "kill troll with sword">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop sword">>
	<ASSERT-TEXT "East-West Passage" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Round Room" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Engravings Cave" <CO-RESUME ,CO "go southeast">>
	<ASSERT-TEXT "Dome Room" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "The rope drops over the side and comes within ten feet of the floor." <CO-RESUME ,CO "tie rope to railing">>
	<ASSERT-TEXT "Torch Room" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Temple" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Egyptian Room" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take coffin">>
	<ASSERT-TEXT "Temple" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Altar" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Forest" <CO-RESUME ,CO "pray">>
	<ASSERT-TEXT "The brass lantern is now off." <CO-RESUME ,CO "turn off lamp">>
	<ASSERT-TEXT "Forest" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Clearing" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Canyon View" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Rocky Ledge" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Canyon Bottom" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "End of Rainbow" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop coffin">>
	<ASSERT-TEXT "The gold coffin opens." <CO-RESUME ,CO "open coffin">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take sceptre">>
	<ASSERT-TEXT "Suddenly, the rainbow appears to become solid and, I venture, walkable (I think ..." <CO-RESUME ,CO "wave sceptre">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take gold">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take coffin">>
	<ASSERT-TEXT "Canyon Bottom" <CO-RESUME ,CO "go southwest">>
	<ASSERT-TEXT "Rocky Ledge" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Canyon View" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Clearing" <CO-RESUME ,CO "go northwest">>
	<ASSERT-TEXT "Behind House" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "enter house">>
	<ASSERT-TEXT "Opening the brown sack reveals a lunch, and a clove of garlic." <CO-RESUME ,CO "open bag">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take garlic">>
	<ASSERT-TEXT "Living Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put coffin in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put gold in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put sceptre in case">>
	<ASSERT-TEXT "The door reluctantly opens to reveal a rickety staircase descending into darknes..." <CO-RESUME ,CO "open trap door">>
	<ASSERT-TEXT "The brass lantern is now on." <CO-RESUME ,CO "turn on lamp">>
	<ASSERT-TEXT "Cellar" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "The Troll Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "East-West Passage" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Chasm" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Reservoir South" <CO-RESUME ,CO "go northeast">>
	<ASSERT-TEXT "Dam" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Dam Lobby" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take matches">>
	<ASSERT-TEXT "Maintenance Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take wrench">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take screwdriver">>
	<ASSERT-TEXT "Click." <CO-RESUME ,CO "push yellow button">>
	<ASSERT-TEXT "Dam Lobby" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Dam" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "The sluice gates open and water pours through the dam." <CO-RESUME ,CO "turn bolt with wrench">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop wrench">>
	<ASSERT-TEXT "Deep Canyon" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Loud Room" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Engravings Cave" <CO-RESUME ,CO "go southeast">>
	<ASSERT-TEXT "Dome Room" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Torch Room" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take torch">>
	<ASSERT-TEXT "The brass lantern is now off." <CO-RESUME ,CO "turn off lamp">>
	<ASSERT-TEXT "Temple" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take bell">>
	<ASSERT-TEXT "Altar" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take candles">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take book">>
	<ASSERT-TEXT "Cave" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Entrance to Hades" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "The bell suddenly becomes red hot and falls to the ground. The wraiths, as if pa..." <CO-RESUME ,CO "ring bell">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take candles">>
	<ASSERT-TEXT "One of the matches starts to burn." <CO-RESUME ,CO "light match">>
	<ASSERT-TEXT "The candles are lit." <CO-RESUME ,CO "light candles with match">>
	<ASSERT-TEXT "Each word of the prayer reverberates through the hall in a deafening confusion. ..." <CO-RESUME ,CO "read book">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop book">>
	<ASSERT-TEXT "Land of the Dead" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take skull">>
	<ASSERT-TEXT "Entrance to Hades" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Cave" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Mirror Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "There is a rumble from deep within the earth and the room shakes." <CO-RESUME ,CO "rub mirror">>
	<ASSERT-TEXT "Cold Passage" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Slide Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Mine Entrance" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Squeaky Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "You are carrying:" <CO-RESUME ,CO "inventory">>
	<ASSERT-TEXT "Bat Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Shaft Room" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put torch in basket">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put screwdriver in basket">>
	<ASSERT-TEXT "The brass lantern is now on." <CO-RESUME ,CO "turn on lamp">>
	<ASSERT-TEXT "Smelly Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Gas Room" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go northeast">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go southeast">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go southwest">>
	<ASSERT-TEXT "Ladder Top" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Ladder Bottom" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Dead End" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take coal">>
	<ASSERT-TEXT "Ladder Bottom" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Ladder Top" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Gas Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Smelly Room" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Shaft Room" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put coal in basket">>
	<ASSERT-TEXT "The basket is lowered to the bottom of the shaft." <CO-RESUME ,CO "lower basket">>
	<ASSERT-TEXT "Smelly Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Gas Room" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go northeast">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go southeast">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go southwest">>
	<ASSERT-TEXT "Ladder Top" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Ladder Bottom" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Timber Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "crystal skull: Dropped." <CO-RESUME ,CO "drop all">>
	<ASSERT-TEXT "Drafty Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take coal">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take screwdriver">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take torch">>
	<ASSERT-TEXT "Machine Room" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "The lid opens." <CO-RESUME ,CO "open lid">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put coal in machine">>
	<ASSERT-TEXT "The lid closes." <CO-RESUME ,CO "close lid">>
	<ASSERT-TEXT "The machine comes to life (figuratively) with a dazzling display of colored ligh..." <CO-RESUME ,CO "turn switch with screwdriver">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop screwdriver">>
	<ASSERT-TEXT "The lid opens, revealing a huge diamond." <CO-RESUME ,CO "open lid">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take diamond">>
	<ASSERT-TEXT "Drafty Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put torch in basket">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put diamond in basket">>
	<ASSERT-TEXT "Timber Room" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take skull">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take lamp">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take garlic">>
	<ASSERT-TEXT "Ladder Bottom" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Ladder Top" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Coal Mine" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Gas Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take bracelet">>
	<ASSERT-TEXT "Smelly Room" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Shaft Room" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "The basket is raised to the top of the shaft." <CO-RESUME ,CO "raise basket">>
	<ASSERT-TEXT "The basket contains:" <CO-RESUME ,CO "look in basket">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take diamond">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take torch">>
	<ASSERT-TEXT "The brass lantern is now off." <CO-RESUME ,CO "turn off lamp">>
	<ASSERT-TEXT "Bat Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take jade">>
	<ASSERT-TEXT "Squeaky Room" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Mine Entrance" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Slide Room" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Cellar" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Living Room" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "You are carrying:" <CO-RESUME ,CO "inventory">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put jade in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put diamond in case">>
	<ASSERT-TEXT "The brass lantern is now on." <CO-RESUME ,CO "turn on lamp">>
	<ASSERT-TEXT "Cellar" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "The Troll Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "East-West Passage" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Chasm" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Reservoir South" <CO-RESUME ,CO "go northeast">>
	<ASSERT-TEXT "Reservoir" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take trunk">>
	<ASSERT-TEXT "Reservoir North" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take pump">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take pump">>
	<ASSERT-TEXT "Atlantis Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Your load is too heavy." <CO-RESUME ,CO "take trident">>
	<ASSERT-TEXT "You are carrying:" <CO-RESUME ,CO "inventory">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop torch">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take trident">>
	<ASSERT-TEXT "Reservoir North" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Reservoir" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Reservoir South" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Dam" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Dam Base" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "The boat inflates and appears seaworthy." <CO-RESUME ,CO "inflate plastic with pump">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop pump">>
	<ASSERT-TEXT "You are now in the magic boat." <CO-RESUME ,CO "go inside boat">>
	<ASSERT-TEXT "(magic boat)" <CO-RESUME ,CO "launch">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "Time passes..." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take buoy">>
	<ASSERT-TEXT "The magic boat comes to a rest on the shore." <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "You are on your own feet again." <CO-RESUME ,CO "leave boat">>
	<ASSERT-TEXT "Your load is too heavy." <CO-RESUME ,CO "take shovel">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop garlic">>
	<ASSERT-TEXT "Your load is too heavy." <CO-RESUME ,CO "take shovel">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop buoy">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take shovel">>
	<ASSERT-TEXT "Sandy Cave" <CO-RESUME ,CO "go northeast">>
	<ASSERT-TEXT "What do you want to dig in?" <CO-RESUME ,CO "dig">>
	<ASSERT-TEXT "(with the shovel)" <CO-RESUME ,CO "sand">>
	<ASSERT-TEXT "(with the shovel)" <CO-RESUME ,CO "dig sand">>
	<ASSERT-TEXT "(with the shovel)" <CO-RESUME ,CO "dig sand">>
	<ASSERT-TEXT "(with the shovel)" <CO-RESUME ,CO "dig sand">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take scarab">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop shovel">>
	<ASSERT-TEXT "Sandy Beach" <CO-RESUME ,CO "go southwest">>
	<ASSERT-TEXT "Opening the red buoy reveals a large emerald." <CO-RESUME ,CO "open buoy">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take emerald">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take garlic">>
	<ASSERT-TEXT "Shore" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Aragain Falls" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "End of Rainbow" <CO-RESUME ,CO "cross rainbow">>
	<ASSERT-TEXT "The brass lantern is now off." <CO-RESUME ,CO "turn off lamp">>
	<ASSERT-TEXT "Canyon Bottom" <CO-RESUME ,CO "go southwest">>
	<ASSERT-TEXT "Rocky Ledge" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Canyon View" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Clearing" <CO-RESUME ,CO "go northwest">>
	<ASSERT-TEXT "Behind House" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "enter house">>
	<ASSERT-TEXT "Living Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "You are carrying:" <CO-RESUME ,CO "inventory">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put emerald in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put scarab in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put trident in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put jewels in case">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Behind House" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "North of House" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Forest Path" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Up a Tree" <CO-RESUME ,CO "climb tree">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take egg">>
	<ASSERT-TEXT "(down the tree)" <CO-RESUME ,CO "climb down">>
	<ASSERT-TEXT "North of House" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Behind House" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "enter house">>
	<ASSERT-TEXT "Living Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "The brass lantern is now on." <CO-RESUME ,CO "turn on lamp">>
	<ASSERT-TEXT "Cellar" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "The Troll Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take coins">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take key">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go southwest">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Cyclops Room" <CO-RESUME ,CO "go southeast">>
	<ASSERT-TEXT "The cyclops, hearing the name of his father's deadly nemesis, flees the room by ..." <CO-RESUME ,CO "Ulysses">>
	<ASSERT-TEXT "The thief is taken aback by your unexpected generosity, but accepts the jewel-en..." <CO-RESUME ,CO "give egg to thief">>
	<ASSERT-TEXT "Cyclops Room" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Strange Passage" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Living Room" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put coins in case">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take knife">>
	<ASSERT-TEXT "Strange Passage" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Cyclops Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "You hear a scream of anguish as you violate the robber's hideaway. Using passage..." <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "The thief is disarmed by a subtle feint past his guard." <CO-RESUME ,CO "kill thief with knife">>
	<ASSERT-TEXT "You dodge as the thief comes in low." <CO-RESUME ,CO "kill thief with knife">>
	<ASSERT-TEXT "It's curtains for the thief as your nasty knife removes his head." <CO-RESUME ,CO "kill thief with knife">>
	<ASSERT-TEXT "stiletto: Taken." <CO-RESUME ,CO "take all">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop stiletto">>
	<ASSERT-TEXT "You're holding too many things already!" <CO-RESUME ,CO "take chalice">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop torch">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take chalice">>
	<ASSERT-TEXT "Cyclops Room" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go northwest">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Maze" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "You won't be able to get back up to the tunnel you are going through when it get..." <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "Grating Room" <CO-RESUME ,CO "go northeast">>
	<ASSERT-TEXT "(with the skeleton key)" <CO-RESUME ,CO "unlock grate">>
	<ASSERT-TEXT "The grating opens to reveal trees above you." <CO-RESUME ,CO "open grate">>
	<ASSERT-TEXT "Clearing" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Forest Path" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Up a Tree" <CO-RESUME ,CO "climb tree">>
	<ASSERT-TEXT "The canary chirps, slightly off-key, an aria from a forgotten opera. From out of..." <CO-RESUME ,CO "wind up canary">>
	<ASSERT-TEXT "Forest Path" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "You're holding too many things already!" <CO-RESUME ,CO "take bauble">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop knife">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take bauble">>
	<ASSERT-TEXT "North of House" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Behind House" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "enter house">>
	<ASSERT-TEXT "Living Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put bauble in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put chalice in case">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take canary from egg">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put canary in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put egg in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put bracelet in case">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put skull in case">>
	<ASSERT-TEXT "Cellar" <CO-RESUME ,CO "go down">>
	<ASSERT-TEXT "The Troll Room" <CO-RESUME ,CO "go north">>
	<ASSERT-TEXT "East-West Passage" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Round Room" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "Loud Room" <CO-RESUME ,CO "go east">>
	<ASSERT-TEXT "The acoustics of the room change subtly." <CO-RESUME ,CO "echo">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take bar">>
	<ASSERT-TEXT "Round Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "East-West Passage" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "The Troll Room" <CO-RESUME ,CO "go west">>
	<ASSERT-TEXT "Cellar" <CO-RESUME ,CO "go south">>
	<ASSERT-TEXT "Living Room" <CO-RESUME ,CO "go up">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "put bar in case">>
	<TELL CR "zork1 transcript test completed!" CR>>
