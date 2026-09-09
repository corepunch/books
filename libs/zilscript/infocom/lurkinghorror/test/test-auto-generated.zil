"TEST-lurkinghorror.ZIL - Auto-generated test from transcript"

<INSERT-FILE "infocom/lurkinghorror/globals">
<INSERT-FILE "infocom/lurkinghorror/parser">
<INSERT-FILE "infocom/lurkinghorror/verbs">
<INSERT-FILE "infocom/lurkinghorror/syntax">
<INSERT-FILE "infocom/lurkinghorror/misc">
<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<TELL "Testing lurkinghorror transcript..." CR>
	<ASSERT-TEXT "Start of a transcript of THE LURKING HORROR." <CO-RESUME ,CO "talk to hacker">>
	<ASSERT-TEXT "Hmmm … the hacker waits for you to say something." <CO-RESUME ,CO "hacker, hi">>
	<ASSERT-TEXT "\"Greetingage.\" He turns back to his hacking." <CO-RESUME ,CO "ask hacker about hacking">>
	<ASSERT-TEXT "I don't know the word \"hacking.\"" <CO-RESUME ,CO "examine pc">>
	<ASSERT-TEXT "This is a beyond-state-of-the-art personal computer. It has a 1024 by 1024 pixel..." <CO-RESUME ,CO "turn on pc">>
	<ASSERT-TEXT "The computer powers up, goes through a remarkably fast self-check, and greets yo..." <CO-RESUME ,CO "login">>
	<ASSERT-TEXT "What do you want to login?" <CO-RESUME ,CO "log in to computer">>
	<ASSERT-TEXT "I don't know the word \"log.\"" <CO-RESUME ,CO "type username">>
	<ASSERT-TEXT "The computer responds \"PASSWORD PLEASE:\"" <CO-RESUME ,CO "type password">>
	<ASSERT-TEXT "What do you want to type passwo?" <CO-RESUME ,CO "ask hacker about password">>
	<ASSERT-TEXT "There seems to be a noun missing in that sentence." <CO-RESUME ,CO "type 872325412">>
	<ASSERT-TEXT "The computer responds \"INVALID LOGIN\" and then \"LOGIN PLEASE:\"." <CO-RESUME ,CO "type 872325412">>
	<ASSERT-TEXT "The computer responds \"PASSWORD PLEASE:\"" <CO-RESUME ,CO "type uhlersoth">>
	<ASSERT-TEXT "The computer responds \"Good evening. You're here awfully late.\" It displays a li..." <CO-RESUME ,CO "edit classics paper">>
	<ASSERT-TEXT "The menu box is replaced by the YAK text editor and menu boxes listing the title..." <CO-RESUME ,CO "press help key">>
	<ASSERT-TEXT "You push the friendly-looking HELP key. A spritely little box appears on the scr..." <CO-RESUME ,CO "click urgent box">>
	<ASSERT-TEXT "You click the box for your paper, and the box grows reassuringly until it fills ..." <CO-RESUME ,CO "read paper">>
	;<ASSERT-TEXT "The paper appears to be a facsimile overlaid with occasional typescript. The tex..." <CO-RESUME ,CO "save">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "press more">>
	<ASSERT-TEXT "You touch the MORE box, and a new page appears." <CO-RESUME ,CO "summon visitor">>
	<ASSERT-TEXT "I don't know the word \"summon.\"" <CO-RESUME ,CO "press more">>
	<ASSERT-TEXT "You touch the MORE box, and a new page appears." <CO-RESUME ,CO "press more">>
	<ASSERT-TEXT "You touch the MORE box, and a new page appears." <CO-RESUME ,CO "examine photograph">>
	<ASSERT-TEXT "I don't know the word \"photograph.\"" <CO-RESUME ,CO "x photo">>
	<ASSERT-TEXT "I don't know the word \"photo.\"" <CO-RESUME ,CO "x page">>
	<ASSERT-TEXT "Instead, you find your finger moving towards the MORE box, and you touch it. The..." <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "Basalt Bowl" <CO-RESUME ,CO "forward">>
	<ASSERT-TEXT "I don't know the word \"forward.\"" <CO-RESUME ,CO "x shapes">>
	<ASSERT-TEXT "I don't know the word \"shapes.\"" <CO-RESUME ,CO "x platform">>
	<ASSERT-TEXT "The platform is made of the same rocks as the surrounding terrain. In fact, you ..." <CO-RESUME ,CO "x stone">>
	<ASSERT-TEXT "It's a smooth, shiny piece of what might be obsidian. Scratched on it is a symbo..." <CO-RESUME ,CO "x symbol">>
	<ASSERT-TEXT "The symbol, on close examination, appears to have been carved into the smooth st..." <CO-RESUME ,CO "take stone">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "eat stone">>
	<ASSERT-TEXT "The food here is terrible, but this is ridiculous!" <CO-RESUME ,CO "show stone to creature">>
	<ASSERT-TEXT "The thing is uninterested." <CO-RESUME ,CO "i">>
	<ASSERT-TEXT "You are carrying a smooth stone and an assignment." <CO-RESUME ,CO "x terminal">>
	<ASSERT-TEXT "This is a beyond-state-of-the-art personal computer. It has a 1024 by 1024 pixel..." <CO-RESUME ,CO "read assignment">>
	<ASSERT-TEXT "Laser printed on creamy bond paper, the assignment is due tomorrow. It's from yo..." <CO-RESUME ,CO "cry">>
	<ASSERT-TEXT "I don't know the word \"cry.\"" <CO-RESUME ,CO "x hacker">>
	<ASSERT-TEXT "The hacker is sitting at your terminal, typing furiously. Every so often, he pau..." <CO-RESUME ,CO "show stone to hacker">>
	<ASSERT-TEXT "\"Odd-looking thing. Are you a rock-jock?\"" <CO-RESUME ,CO "take keys">>
	<ASSERT-TEXT "\"Hey! No snarfage, loser!\" You determine that this means, \"Stop!\"" <CO-RESUME ,CO "ask hacker about keys">>
	<ASSERT-TEXT "\"I've accumulated a few keys over the years. I'm a licensed locksmith, which hel..." <CO-RESUME ,CO "ask hacker for master key">>
	;<ASSERT-TEXT "\"Fat chance! This is a master key! What have you done for me lately?\"" <CO-RESUME ,CO "save">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "punch hacker">>
	<ASSERT-TEXT "I don't know the word \"punch.\"" <CO-RESUME ,CO "ask hacker about department of alchemy">>
	<ASSERT-TEXT "You can't see any department of alchemy here." <CO-RESUME ,CO "feed hacker">>
	<ASSERT-TEXT "(to the hacker)" <CO-RESUME ,CO "feed assignment to hacker">>
	<ASSERT-TEXT "\"No thanks, keep it for now.\"" <CO-RESUME ,CO "l">>
	<ASSERT-TEXT "Terminal Room" <CO-RESUME ,CO "x pizza boxes">>
	<ASSERT-TEXT "I beg your pardon?" <CO-RESUME ,CO "read banners">>
	<ASSERT-TEXT "I don't know the word \"pizza.\"" <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "How do you do that with a banners?" <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Second Floor" <CO-RESUME ,CO "x funny bones">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "take funny bones">>
	<ASSERT-TEXT "This is a package of Funny Bones, a snack food made with peanut butter and choco..." <CO-RESUME ,CO "open fridge">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "take all">>
	<ASSERT-TEXT "Opening the refrigerator reveals a two liter bottle of Classic Coke and a cardbo..." <CO-RESUME ,CO "x carton">>
	<ASSERT-TEXT "two liter bottle of Classic Coke: Taken." <CO-RESUME ,CO "x symbol">>
	<ASSERT-TEXT "This is a cardboard carton with an incomprehensible symbol scrawled on the top." <CO-RESUME ,CO "open it">>
	<ASSERT-TEXT "It doesn't look like Chinese, English, or any other language you know. The symbo..." <CO-RESUME ,CO "put carton in microwave">>
	<ASSERT-TEXT "Opening the cardboard carton reveals Chinese food." <CO-RESUME ,CO "open microwave">>
	<ASSERT-TEXT "Inspection reveals that the microwave oven isn't open." <CO-RESUME ,CO "put carton in microwave">>
	<ASSERT-TEXT "The microwave oven is now open." <CO-RESUME ,CO "close fridge">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "close microwave">>
	<ASSERT-TEXT "Closed." <CO-RESUME ,CO "x microwave">>
	<ASSERT-TEXT "Okay, the microwave oven is now closed." <CO-RESUME ,CO "x led readout">>
	<ASSERT-TEXT "The microwave oven hangs over the kitchen counter. It has more complicated contr..." <CO-RESUME ,CO "x controls">>
	;<ASSERT-TEXT "The display is currently displaying the current time and the word \"off.\"" <CO-RESUME ,CO "save">>
	<ASSERT-TEXT "There are controls labelled 0 to 9, WM, LO, MED, HI, START, CLEAR, and STOP. The..." <CO-RESUME ,CO "press hi">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "press start">>
	<ASSERT-TEXT "The bottom of the display now reads \"high.\"" <CO-RESUME ,CO "press 1">>
	<ASSERT-TEXT "Nothing happens, as there's no time set on it yet." <CO-RESUME ,CO "press 0">>
	<ASSERT-TEXT "The timer display now reads 0:01." <CO-RESUME ,CO "press 0">>
	<ASSERT-TEXT "The timer display now reads 0:10." <CO-RESUME ,CO "press start">>
	<ASSERT-TEXT "The timer display now reads 1:00." <CO-RESUME ,CO "open microwave">>
	<ASSERT-TEXT "The microwave starts up. The timer begins counting down." <CO-RESUME ,CO "x carton">>
	<ASSERT-TEXT "The microwave oven is now open." <CO-RESUME ,CO "touch carton">>
	<ASSERT-TEXT "This is a cardboard carton with an incomprehensible symbol scrawled on the top." <CO-RESUME ,CO "open carton">>
	<ASSERT-TEXT "Fiddling with the cardboard carton has no effect." <CO-RESUME ,CO "x chinese food">>
	<ASSERT-TEXT "The cardboard carton is already open." <CO-RESUME ,CO "close microwave">>
	<ASSERT-TEXT "This is a carton of cold Szechuan shrimp. Lovely red peppers poke out of the sau..." <CO-RESUME ,CO "press hi">>
	<ASSERT-TEXT "Okay, the microwave oven is now closed." <CO-RESUME ,CO "press 3">>
	<ASSERT-TEXT "The bottom of the display now reads \"high.\"" <CO-RESUME ,CO "press 0">>
	<ASSERT-TEXT "The timer display now reads 0:03." <CO-RESUME ,CO "press 0">>
	<ASSERT-TEXT "The timer display now reads 0:30." <CO-RESUME ,CO "press start">>
	<ASSERT-TEXT "The timer display now reads 3:00." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "The microwave starts up. The timer begins counting down." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "open microwave">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "x food">>
	<ASSERT-TEXT "The microwave oven is now open." <CO-RESUME ,CO "x chinese food">>
	<ASSERT-TEXT "Which food do you mean, the Chinese food or the package of Funny Bones?" <CO-RESUME ,CO "take carton">>
	<ASSERT-TEXT "This is a carton of hot Szechuan shrimp. Lovely red peppers poke out of the sauc..." <CO-RESUME ,CO "l">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "n">>
	<ASSERT-TEXT "Second Floor" <CO-RESUME ,CO "give chinese food to hacker">>
	<ASSERT-TEXT "Terminal Room" <CO-RESUME ,CO "x chinese food">>
	<ASSERT-TEXT "\"Yuck! This isn't warm enough!\" He thrusts it back into your hands." <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "This is a carton of warm Szechuan shrimp. Lovely red peppers poke out of the sau..." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "Second Floor" <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "open microwave">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "put carton in microwave">>
	<ASSERT-TEXT "The microwave oven is already open." <CO-RESUME ,CO "close microwave">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "press hi">>
	<ASSERT-TEXT "Okay, the microwave oven is now closed." <CO-RESUME ,CO "press 5">>
	<ASSERT-TEXT "The bottom of the display now reads \"high.\"" <CO-RESUME ,CO "press 0">>
	<ASSERT-TEXT "The timer display now reads 0:05." <CO-RESUME ,CO "press 0">>
	<ASSERT-TEXT "The timer display now reads 0:50." <CO-RESUME ,CO "press start">>
	<ASSERT-TEXT "The timer display now reads 5:00." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "The microwave starts up. The timer begins counting down." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "open microwave">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "take container">>
	<ASSERT-TEXT "The microwave oven is now open." <CO-RESUME ,CO "take carton">>
	<ASSERT-TEXT "You can't see any container here." <CO-RESUME ,CO "close carton">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "Closed." <CO-RESUME ,CO "n">>
	<ASSERT-TEXT "Second Floor" <CO-RESUME ,CO "give carton to hacker">>
	<ASSERT-TEXT "Terminal Room" <CO-RESUME ,CO "reload">>
	;<ASSERT-TEXT "\"Ouch! This is ridiculous! You've overcooked it. Look at those poor shrimp! It's..." <CO-RESUME ,CO "restore">>
	<ASSERT-TEXT "I don't know the word \"reload.\"" <CO-RESUME ,CO "l">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "close oven">>
	<ASSERT-TEXT "Kitchen" <CO-RESUME ,CO "open oven">>
	<ASSERT-TEXT "It's already closed." <CO-RESUME ,CO "close carton">>
	<ASSERT-TEXT "The microwave oven is now open." <CO-RESUME ,CO "close oven">>
	<ASSERT-TEXT "Closed." <CO-RESUME ,CO "press hi">>
	<ASSERT-TEXT "Okay, the microwave oven is now closed." <CO-RESUME ,CO "press 4:00">>
	<ASSERT-TEXT "The bottom of the display now reads \"high.\"" <CO-RESUME ,CO "set timer to 4:20">>
	<ASSERT-TEXT "Why don't you try setting the timer to that?" <CO-RESUME ,CO "press start">>
	<ASSERT-TEXT "The timer display now reads 4:20." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "The microwave starts up. The timer begins counting down." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "open microwave">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "take container">>
	<ASSERT-TEXT "The microwave oven is now open." <CO-RESUME ,CO "take carton">>
	<ASSERT-TEXT "You can't see any container here." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "n">>
	<ASSERT-TEXT "Second Floor" <CO-RESUME ,CO "give carton to hacker">>
	<ASSERT-TEXT "Terminal Room" <CO-RESUME ,CO "ask hacker for master key">>
	<ASSERT-TEXT "\"Ah! Serious food!\" He plunges into the food with all the delicacy and table man..." <CO-RESUME ,CO "i">>
	<ASSERT-TEXT "\"Well, I suppose I could loan you the master key for a while. Just don't get int..." <CO-RESUME ,CO "take all">>
	<ASSERT-TEXT "You are carrying a master key, a two liter bottle of Classic Coke, a package of ..." <CO-RESUME ,CO "drop chair">>
	<ASSERT-TEXT "chair: Taken." <CO-RESUME ,CO "take pc">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "drop pc">>
	<ASSERT-TEXT "You take it, turning it off and unplugging it first." <CO-RESUME ,CO "take chair">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "l">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "verbose">>
	<ASSERT-TEXT "Terminal Room" <CO-RESUME ,CO "i">>
	<ASSERT-TEXT "Verbose descriptions." <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "You are carrying a chair, a master key, a two liter bottle of Classic Coke, a pa..." <CO-RESUME ,CO "drop chair">>
	<ASSERT-TEXT "The hacker prevents you. \"You can't walk off with that! It's Tech property!\"" <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "hello">>
	<ASSERT-TEXT "Second Floor" <CO-RESUME ,CO "push call button">>
	<ASSERT-TEXT "Cheery, aren't you?" <CO-RESUME ,CO "push up">>
	<ASSERT-TEXT "Which call button do you mean, the up-arrow or the down-arrow?" <CO-RESUME ,CO "cool">>
	<ASSERT-TEXT "The up-arrow begins to glow." <CO-RESUME ,CO ";cool">>
	<ASSERT-TEXT "I don't know the word \"cool.\"" <CO-RESUME ,CO "say "cool"">>
	<ASSERT-TEXT "I don't know the word \";cool.\"" <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "Talking to yourself is a sign of impending mental collapse." <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "open panel">>
	<ASSERT-TEXT "Elevator" <CO-RESUME ,CO "take flashlight">>
	<ASSERT-TEXT "Opening the access panel reveals a flashlight." <CO-RESUME ,CO "push 3">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "The button for the third floor begins to glow." <CO-RESUME ,CO "x me">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "wait">>
	<ASSERT-TEXT "You are wide awake, and are in good health." <CO-RESUME ,CO "n">>
	<ASSERT-TEXT "Time passes…" <CO-RESUME ,CO "n">>
	<ASSERT-TEXT "Third Floor" <CO-RESUME ,CO "look through glass">>
	<ASSERT-TEXT "There is a glass wall in the way." <CO-RESUME ,CO "x equipment">>
	<ASSERT-TEXT "You see nothing special about it." <CO-RESUME ,CO "u">>
	<ASSERT-TEXT "You see nothing special about it." <CO-RESUME ,CO "x brown building">>
	<ASSERT-TEXT "You push through the door to the roof. You enter the freezing, biting cold of th..." <CO-RESUME ,CO "take snow">>
	<ASSERT-TEXT "I don't know the word \"brown.\"" <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "That would never work!" <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "You push your way into the welcoming warmth inside." <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "Second Floor" <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "Computer Center" <CO-RESUME ,CO "x pipes">>
	<ASSERT-TEXT "Basement" <CO-RESUME ,CO "x channels">>
	<ASSERT-TEXT "You see nothing special about the steam pipes." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "From floor to ceiling run wire channels and steam pipes." <CO-RESUME ,CO "show stone to urchin">>
	<ASSERT-TEXT "Aero Basement" <CO-RESUME ,CO "ask urchin about stone">>
	<ASSERT-TEXT "He makes an unconvincing show of disinterest." <CO-RESUME ,CO "x urchin">>
	;<ASSERT-TEXT "He doesn't reply. He seems very nervous about talking to you." <CO-RESUME ,CO "save">>
	<ASSERT-TEXT "This is an urchin. He's a youngish teenager wearing a ski hat, running shoes, an..." <CO-RESUME ,CO "take parka">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "scare him">>
	<ASSERT-TEXT "\"Hey! Keep off, sucker! You can't scare me!\"" <CO-RESUME ,CO "boo urchin">>
	<ASSERT-TEXT "How do you propose to do that?" <CO-RESUME ,CO "say "BOO"">>
	<ASSERT-TEXT "I don't know the word \"boo.\"" <CO-RESUME ,CO "urchin, boo">>
	<ASSERT-TEXT "You must address the urchin directly." <CO-RESUME ,CO "x forklift">>
	<ASSERT-TEXT "I don't know the word \"boo.\"" <CO-RESUME ,CO "get on forklift">>
	<ASSERT-TEXT "This is a rusty old forklift. It looks like you could control it fairly easily, ..." <CO-RESUME ,CO "operate forklift">>
	<ASSERT-TEXT "You are now in the forklift." <CO-RESUME ,CO "turn on forklift">>
	<ASSERT-TEXT "I don't know the word \"operate.\"" <CO-RESUME ,CO "use forklift on urchin">>
	<ASSERT-TEXT "The forklift sputters to life." <CO-RESUME ,CO "life urchin">>
	<ASSERT-TEXT "I don't know the word \"use.\"" <CO-RESUME ,CO "lift urchin">>
	<ASSERT-TEXT "There was no verb in that sentence!" <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "You can't reach the urchin from within the forklift." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "The forklift won't fit into the stairwell." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "Basement, on the forklift" <CO-RESUME ,CO "take all">>
	<ASSERT-TEXT "Temporary Basement, on the forklift" <CO-RESUME ,CO "exit forklift">>
	<ASSERT-TEXT "pair of electrician's gloves: You can't reach the pair of electrician's gloves f..." <CO-RESUME ,CO "take all">>
	<ASSERT-TEXT "You are now on your feet." <CO-RESUME ,CO "x gloves">>
	<ASSERT-TEXT "pair of electrician's gloves: Taken." <CO-RESUME ,CO "x crowbar">>
	<ASSERT-TEXT "This is a pair of electrician's rubber gloves. They look well used but serviceab..." <CO-RESUME ,CO "put on gloves">>
	<ASSERT-TEXT "You see nothing special about the crowbar." <CO-RESUME ,CO "turn off forklift">>
	<ASSERT-TEXT "You put on the gloves. They're a little big, but not really such a bad fit at al..." <CO-RESUME ,CO "get on forklift">>
	<ASSERT-TEXT "You'll have to get in it first." <CO-RESUME ,CO "turn off forklift">>
	<ASSERT-TEXT "You are now in the forklift." <CO-RESUME ,CO "get of forklift">>
	<ASSERT-TEXT "The forklift coughs once, and dies." <CO-RESUME ,CO "get off forklift">>
	<ASSERT-TEXT "You used the word \"of\" in a way that I don't understand." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "You are now on your feet." <CO-RESUME ,CO "turn on flashlight">>
	<ASSERT-TEXT "It is pitch black." <CO-RESUME ,CO "x pallets">>
	<ASSERT-TEXT "The flashlight clicks on." <CO-RESUME ,CO "search junk">>
	<ASSERT-TEXT "Looking more closely only emphasizes how completely entropy has taken over this ..." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "You find many worthless items of hardware, old discarded memos and papers, but n..." <CO-RESUME ,CO "get on forklift">>
	<ASSERT-TEXT "Temporary Basement" <CO-RESUME ,CO "turn on forklift">>
	<ASSERT-TEXT "You are now in the forklift." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "The forklift sputters to life." <CO-RESUME ,CO "move pallets">>
	<ASSERT-TEXT "Dead Storage, on the forklift" <CO-RESUME ,CO "g">>
	<ASSERT-TEXT "You have a little trouble using the forklift, but it's not really all that hard...." <CO-RESUME ,CO "g">>
	<ASSERT-TEXT "You continue moving junk, becoming more proficient with the forklift." <CO-RESUME ,CO "g">>
	<ASSERT-TEXT "You continue moving junk, becoming more proficient with the forklift." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "You've built a fairly narrow (about one forklift wide) path through the junk. Yo..." <CO-RESUME ,CO "turn off forklift">>
	<ASSERT-TEXT "Ancient Storage, on the forklift" <CO-RESUME ,CO "get off forklift">>
	<ASSERT-TEXT "The forklift coughs once, and dies." <CO-RESUME ,CO "x manhole">>
	<ASSERT-TEXT "You are now on your feet." <CO-RESUME ,CO "open manhole">>
	<ASSERT-TEXT "It's a steel ring set in the floor. It's probably a manhole." <CO-RESUME ,CO "remove cover with crowbar">>
	;<ASSERT-TEXT "The only way would seem to be to remove the manhole cover." <CO-RESUME ,CO "save">>
	<ASSERT-TEXT "You lever the manhole cover aside, and crusted dirt falls into a dark, partly ob..." <CO-RESUME ,CO "x hole">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "It's a manhole. It's very dark inside, but you can see that crude brick handhold..." <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "You push your way through cobwebs, damp fungus, and other obstructions." <CO-RESUME ,CO "u">>
	<ASSERT-TEXT "You make your way along the long tunnel." <CO-RESUME ,CO "open trapdoor">>
	<ASSERT-TEXT "The trapdoor isn't open." <CO-RESUME ,CO "look through trapdoor">>
	<ASSERT-TEXT "It lifts a few inches, but then hits something and goes no further." <CO-RESUME ,CO "open trapdoor with crowbar">>
	<ASSERT-TEXT "Pushing the plate up as far as you can, you can see part of a workroom or lab of..." <CO-RESUME ,CO "i">>
	<ASSERT-TEXT "It lifts a few inches, but then hits something and goes no further." <CO-RESUME ,CO "n">>
	<ASSERT-TEXT "You are carrying a crowbar, a flashlight (providing light), a master key, a two ..." <CO-RESUME ,CO "n">>
	<ASSERT-TEXT "You make your way along the long tunnel." <CO-RESUME ,CO "x slab">>
	<ASSERT-TEXT "You make your way along the long tunnel." <CO-RESUME ,CO "open slab">>
	<ASSERT-TEXT "The slab is roughly circular, made of indifferently dressed New England granite,..." <CO-RESUME ,CO "lay on slab">>
	<ASSERT-TEXT "How do you do that with a slab of granite?" <CO-RESUME ,CO "stand on slab">>
	<ASSERT-TEXT "You aren't holding the slab of granite." <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "That would be a waste of time." <CO-RESUME ,CO "x knife">>
	<ASSERT-TEXT "Before the Altar" <CO-RESUME ,CO "take knife">>
	<ASSERT-TEXT "This small knife is clean, sharp, and has a long, thin blade and a wooden handle..." <CO-RESUME ,CO "x tip">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "x symbols">>
	<ASSERT-TEXT "I don't know the word \"tip.\"" <CO-RESUME ,CO "incised">>
	<ASSERT-TEXT "Which symbols do you mean, the incised symbol or the carved symbol?" <CO-RESUME ,CO "put stone on altar">>
	<ASSERT-TEXT "The symbol appears to be the oldest thing carved on the altar. It is beautifully..." <CO-RESUME ,CO "x carved symbol">>
	<ASSERT-TEXT "Done." <CO-RESUME ,CO "x grate">>
	<ASSERT-TEXT "The symbol, on close examination, appears to have been carved into the smooth st..." <CO-RESUME ,CO "x plate">>
	;<ASSERT-TEXT "I don't know the word \"grate.\"" <CO-RESUME ,CO "save">>
	<ASSERT-TEXT "The plate is iron, about two feet square, and looks like it could be slid open. ..." <CO-RESUME ,CO "take stone">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "open plate">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "x hole">>
	<ASSERT-TEXT "You slide open the panel, revealing a dark pit below. Immediately, there is a re..." <CO-RESUME ,CO "look down hole">>
	<ASSERT-TEXT "The plate is iron, about two feet square, and open. A curious feature of the pla..." <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "You see nothing special about the iron plate." <CO-RESUME ,CO "enter hole">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "drop funny bones in hole">>
	<ASSERT-TEXT "You hit your head against the iron plate as you attempt this feat." <CO-RESUME ,CO "i">>
	<ASSERT-TEXT "Sounds of ghoulish excitement issue from the opening." <CO-RESUME ,CO "undo">>
	;<ASSERT-TEXT "You are carrying a smooth stone, a knife, a crowbar, a flashlight (providing lig..." <CO-RESUME ,CO "restore">>
	<ASSERT-TEXT "I don't know the word \"undo.\"" <CO-RESUME ,CO "look in hole">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "take stone">>
	<ASSERT-TEXT "The iron plate is closed." <CO-RESUME ,CO "trace symbol">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "compare symbols">>
	<ASSERT-TEXT "I don't know the word \"trace.\"" <CO-RESUME ,CO "compare carved and incised">>
	<ASSERT-TEXT "You can only compare two things." <CO-RESUME ,CO "l">>
	<ASSERT-TEXT "Allowing for the different media in which the symbols are executed, they are ide..." <CO-RESUME ,CO "x stains">>
	<ASSERT-TEXT "Before the Altar" <CO-RESUME ,CO "exit">>
	<ASSERT-TEXT "I don't know the word \"stains.\"" <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "Please use compass directions instead." <CO-RESUME ,CO "up">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "Renovated Cave" <CO-RESUME ,CO "u">>
	<ASSERT-TEXT "Brick Tunnel" <CO-RESUME ,CO "verbose">>
	<ASSERT-TEXT "Ancient Storage" <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Verbose descriptions." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Dead Storage" <CO-RESUME ,CO "show funny bones to urchin">>
	<ASSERT-TEXT "Temporary Basement" <CO-RESUME ,CO "show coke to urchin">>
	<ASSERT-TEXT "He makes an unconvincing show of disinterest." <CO-RESUME ,CO "ask urchin about parka">>
	;<ASSERT-TEXT "He makes an unconvincing show of disinterest." <CO-RESUME ,CO "save">>
	<ASSERT-TEXT "He doesn't reply. He seems very nervous about talking to you." <CO-RESUME ,CO "give funny bones to urchin">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "ask urchin about parka">>
	<ASSERT-TEXT "\"My momma said never take nothin' from no stranger.\" He takes the package of Fun..." <CO-RESUME ,CO "show knife to urchin">>
	<ASSERT-TEXT "He doesn't reply. He seems very nervous about talking to you." <CO-RESUME ,CO "give coke to urchin">>
	<ASSERT-TEXT "He makes an unconvincing show of disinterest." <CO-RESUME ,CO "x urchin">>
	<ASSERT-TEXT "\"My momma said never take nothin' from no stranger.\"" <CO-RESUME ,CO "x parka">>
	<ASSERT-TEXT "This is an urchin. He's a youngish teenager wearing a ski hat, running shoes, an..." <CO-RESUME ,CO "x bulges">>
	<ASSERT-TEXT "It bulges in odd places." <CO-RESUME ,CO "u">>
	<ASSERT-TEXT "I don't know the word \"bulges.\"" <CO-RESUME ,CO "x flask">>
	<ASSERT-TEXT "Temporary Lab" <CO-RESUME ,CO "open flask">>
	<ASSERT-TEXT "This is a large metal flask, about the size of a water cooler bottle. The metal ..." <CO-RESUME ,CO "close flask">>
	<ASSERT-TEXT "You open the flask, and a cold, white mist boils out." <CO-RESUME ,CO "take flask">>
	<ASSERT-TEXT "You screw the flask closed." <CO-RESUME ,CO "n">>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "You enter the freezing, biting cold of the blizzard." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Smith Street" <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "Impenetrable snow drifts block the street." <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "You push your way into the welcoming warmth inside." <CO-RESUME ,CO "turn off flashlight">>
	<ASSERT-TEXT "Basement" <CO-RESUME ,CO "drink coke">>
	<ASSERT-TEXT "The flashlight clicks off." <CO-RESUME ,CO "i">>
	<ASSERT-TEXT "Delicious! Contains caffeine, one of the four basic food groups. Too bad they ma..." <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "You are carrying a metal flask, a smooth stone, a knife, a crowbar, a flashlight..." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Aero Basement" <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "Stairway" <CO-RESUME ,CO "x crack">>
	<ASSERT-TEXT "Subbasement" <CO-RESUME ,CO "nw">>
	<ASSERT-TEXT "You used the word \"crack\" in a way that I don't understand." <CO-RESUME ,CO "drop flask">>
	<ASSERT-TEXT "It's too tight a fit carrying the metal flask." <CO-RESUME ,CO "nw">>
	<ASSERT-TEXT "Dropped." <CO-RESUME ,CO "read letters">>
	<ASSERT-TEXT "Tomb" <CO-RESUME ,CO "unlock padlock with key">>
	<ASSERT-TEXT "It reads \"The Tomb of the Unknown Tool.\"" <CO-RESUME ,CO "open hatch">>
	<ASSERT-TEXT "The lock, though rusty and unwilling, opens, releasing the hatch." <CO-RESUME ,CO "turn on flashlight">>
	<ASSERT-TEXT "The hatch is heavy, and its hinges are rusty, but you pull and strain and it ope..." <CO-RESUME ,CO "d">>
	;<ASSERT-TEXT "The flashlight clicks on." <CO-RESUME ,CO "save">>
	<ASSERT-TEXT "Steam Tunnel" <CO-RESUME ,CO "listen">>
	<ASSERT-TEXT "Okay." <CO-RESUME ,CO "yes">>
	<ASSERT-TEXT "You hear the chittering of rats." <CO-RESUME ,CO "am I good or what?">>
	<ASSERT-TEXT "That was a rhetorical question." <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "I don't know the word \"good.\"" <CO-RESUME ,CO "x valve">>
	<ASSERT-TEXT "Steam Tunnel" <CO-RESUME ,CO "open valve">>
	<ASSERT-TEXT "It looks pretty rusty, but appears to be in working order. It's closed." <CO-RESUME ,CO "open valve with crowbar">>
	<ASSERT-TEXT "It's too rusty. You pull and strain, but nothing happens." <CO-RESUME ,CO "again">>
	<ASSERT-TEXT "The valve, with a horrible scream of tortured metal, gives a little, and a small..." <CO-RESUME ,CO "take dead rat">>
	<ASSERT-TEXT "The valve screeches open. A jet spray of live steam issues from it, filling the ..." <CO-RESUME ,CO "close valve with crowbar">>
	<ASSERT-TEXT "As you take the dead rat, it moves, but then you realize that it's only lice and..." <CO-RESUME ,CO "x rat">>
	<ASSERT-TEXT "The valve closes, more easily than it opened." <CO-RESUME ,CO "x symbol">>
	<ASSERT-TEXT "This rat appears to have been stepped on. A small trickle of blood has clotted a..." <CO-RESUME ,CO "compare scarred symbol to carved symbol">>
	<ASSERT-TEXT "The symbol, on close examination, appears to have been scarred into the hide of ..." <CO-RESUME ,CO "compare rat to stone">>
	<ASSERT-TEXT "I don't know the word \"scarred.\"" <CO-RESUME ,CO "compare symbol to symbol">>
	<ASSERT-TEXT "That would be a waste of time." <CO-RESUME ,CO "l">>
	<ASSERT-TEXT "Allowing for the different media in which the symbols are executed, they are ide..." <CO-RESUME ,CO "x cable">>
	<ASSERT-TEXT "Steam Tunnel" <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "The cable runs overhead in a fat bundle. It looks like the kind you've seen conn..." <CO-RESUME ,CO "x mud">>
	<ASSERT-TEXT "Steam Tunnel" <CO-RESUME ,CO "e">>
	<ASSERT-TEXT "I don't know the word \"mud.\"" <CO-RESUME ,CO "x south wall">>
	<ASSERT-TEXT "Steam Tunnel" <CO-RESUME ,CO "break wall with crowbar">>
	<ASSERT-TEXT "The brick wall is in terrible shape. It's aged and crumbling, with grooves betwe..." <CO-RESUME ,CO "g">>
	<ASSERT-TEXT "It doesn't do much but loosen a brick in the wall." <CO-RESUME ,CO "pry brick with crowbar">>
	<ASSERT-TEXT "It doesn't do much but loosen a brick in the wall." <CO-RESUME ,CO "x brick">>
	<ASSERT-TEXT "The wall grudgingly yields to your efforts. A brick, less well mortared than its..." <CO-RESUME ,CO "new">>
	<ASSERT-TEXT "Which brick do you mean, the broken brick or the new brick?" <CO-RESUME ,CO "x broken brick">>
	<ASSERT-TEXT "It's a new brick. It appears to be of relatively recent vintage." <CO-RESUME ,CO "get all">>
	<ASSERT-TEXT "It's a crumbling, broken brick. Little bits of mortar still cling to it." <CO-RESUME ,CO "press new brick">>
	<ASSERT-TEXT "broken brick: Taken." <CO-RESUME ,CO "pry new brick with crowbar">>
	<ASSERT-TEXT "Pushing the new brick has no effect." <CO-RESUME ,CO "x rod">>
	<ASSERT-TEXT "The wall grudgingly yields to your efforts. A brick, less well mortared than its..." <CO-RESUME ,CO "look through hole">>
	<ASSERT-TEXT "It's rusty, obviously didn't help the wall all that much, and runs up and down t..." <CO-RESUME ,CO "s">>
	<ASSERT-TEXT "There is an open space, a small room containing some machinery. You can't see to..." <CO-RESUME ,CO "reach into hole">>
	<ASSERT-TEXT "You are trying to walk through a brick wall." <CO-RESUME ,CO "pull rod">>
	<ASSERT-TEXT "You reach in and touch the reinforcing rod." <CO-RESUME ,CO "pry rod with crowbar">>
	<ASSERT-TEXT "It's pretty solidly mortared in." <CO-RESUME ,CO "i">>
	<ASSERT-TEXT "It's pretty solidly mortared in." <CO-RESUME ,CO "get new brick">>
	<ASSERT-TEXT "You are carrying a broken brick, a dead rat, a smooth stone, a knife, a crowbar,..." <CO-RESUME ,CO "u">>
	<ASSERT-TEXT "You can't see any new brick here." <CO-RESUME ,CO "shine flashlight in hole">>
	<ASSERT-TEXT "You can't go that way." <CO-RESUME ,CO "get cables">>
	<ASSERT-TEXT "I don't know the word \"shine.\"" <CO-RESUME ,CO "x cables">>
	<ASSERT-TEXT "I don't know the word \"cables.\"" <CO-RESUME ,CO "x cable">>
	<ASSERT-TEXT "I don't know the word \"cables.\"" <CO-RESUME ,CO "get cable">>
	<ASSERT-TEXT "The cable runs overhead in a fat bundle. It looks like the kind you've seen conn..." <CO-RESUME ,CO "climb">>
	<ASSERT-TEXT "You can't take that!" <CO-RESUME ,CO "cable">>
	<ASSERT-TEXT "What do you want to climb?" <CO-RESUME ,CO "climb pipe">>
	<ASSERT-TEXT "You leap, grab the damp and moldy bundle of cable, and hang suspended off the fl..." <CO-RESUME ,CO "pour coke on rod">>
	<ASSERT-TEXT "That would be a waste of time." <CO-RESUME ,CO "i">>
	<ASSERT-TEXT "You pour the Coke on the reinforcing rod, wasting it." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "You are carrying a broken brick, a dead rat, a smooth stone, a knife, a crowbar,..." <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Steam Tunnel" <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Steam Tunnel" <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Steam Tunnel" <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Steam Tunnel" <CO-RESUME ,CO "w">>
	<ASSERT-TEXT "Tunnel Entrance" <CO-RESUME ,CO "d">>
	<ASSERT-TEXT "Muddy Tunnel" <CO-RESUME ,CO "x slots">>
	<TELL CR "lurkinghorror transcript test completed!" CR>>
