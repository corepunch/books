;"State-aware intent cards for Zork I.

  This file is intentionally separate from the imported adventure source.
  Labels describe narrative intentions; commands are ordinary Zork parser input.
  The runtime evaluates SUGGEST-ACTIONS only while the game is waiting at READ."


<ROUTINE SUGGEST-WEST-OF-HOUSE ()
  <COND
    (<NOT <FSET? ,MAILBOX ,OPENBIT>>
     <CHOICE "west-house.open-mailbox"
             "Open the little mailbox"
             "open mailbox"
             ,CHOICE-INVESTIGATE
             100>)
    (<IN? ,ADVERTISEMENT ,MAILBOX>
     <CHOICE "west-house.take-leaflet"
             "Take the leaflet from the mailbox"
             "take leaflet"
             ,CHOICE-INVESTIGATE
             100>)
    (<IN? ,ADVERTISEMENT ,WINNER>
     <CHOICE "west-house.read-leaflet"
             "Read the leaflet"
             "read leaflet"
             ,CHOICE-INVESTIGATE
             85>)>

  <CHOICE "west-house.try-front-door"
          "Try the boarded front door"
          "open front door"
          ,CHOICE-INVESTIGATE
          75>
  <CHOICE-DETAILS "once" T>

  <CHOICE "west-house.go-north"
          "Walk around the north side of the house"
          "north"
          ,CHOICE-PROGRESS
          90>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "west-house.go-south"
          "Walk around the south side of the house"
          "south"
          ,CHOICE-RETURN
          65>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "west-house.enter-forest"
          "Follow the field west into the forest"
          "west"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-NORTH-OF-HOUSE ()
  <CHOICE "north-house.go-behind"
          "Walk around to the back of the house"
          "east"
          ,CHOICE-PROGRESS
          100>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "north-house.examine-window"
          "Examine the boarded windows"
          "examine boarded window"
          ,CHOICE-INVESTIGATE
          75>
  <CHOICE-DETAILS "once" T>

  <CHOICE "north-house.follow-path"
          "Follow the narrow path into the trees"
          "north"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "north-house.return-front"
          "Return to the front of the house"
          "west"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-SOUTH-OF-HOUSE ()
  <CHOICE "south-house.go-behind"
          "Walk around to the back of the house"
          "east"
          ,CHOICE-PROGRESS
          100>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "south-house.examine-window"
          "Examine the boarded windows"
          "examine boarded window"
          ,CHOICE-INVESTIGATE
          75>
  <CHOICE-DETAILS "once" T>

  <CHOICE "south-house.enter-forest"
          "Follow the trees south into the forest"
          "south"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "south-house.return-front"
          "Return to the front of the house"
          "west"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-EAST-OF-HOUSE ()
  <COND
    (<FSET? ,KITCHEN-WINDOW ,OPENBIT>
     <CHOICE "east-house.enter-window"
             "Climb through the open kitchen window"
             "enter window"
             ,CHOICE-PROGRESS
             115>
     <CHOICE-DETAILS "group" "move">)
    (T
     <CHOICE "east-house.open-window"
             "Open the slightly ajar kitchen window"
             "open kitchen window"
             ,CHOICE-PROGRESS
             110>)>

  <CHOICE "east-house.examine-window"
          "Look through the small kitchen window"
          "examine kitchen window"
          ,CHOICE-INVESTIGATE
          80>

  <CHOICE "east-house.enter-clearing"
          "Follow the path into the forest clearing"
          "east"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "east-house.go-north"
          "Walk around the north side of the house"
          "north"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "east-house.go-south"
          "Walk around the south side of the house"
          "south"
          ,CHOICE-RETURN
          45>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-KITCHEN ()
  <CHOICE "kitchen.enter-living-room"
          "Go into the living room"
          "west"
          ,CHOICE-PROGRESS
          105>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "kitchen.climb-stairs"
          "Climb the dark stairs to the attic"
          "up"
          ,CHOICE-EXPERIMENT
          65>
  <CHOICE-DETAILS "group" "move">

  <COND
    (<IN? ,SANDWICH-BAG ,KITCHEN-TABLE>
     <CHOICE "kitchen.take-sack"
             "Take the brown sack from the table"
             "take brown sack"
             ,CHOICE-INVESTIGATE
             80>)>

  <COND
    (<IN? ,BOTTLE ,KITCHEN-TABLE>
     <CHOICE "kitchen.take-bottle"
             "Take the glass bottle"
             "take bottle"
             ,CHOICE-INVESTIGATE
             70>)>

  <COND
    (<FSET? ,KITCHEN-WINDOW ,OPENBIT>
     <CHOICE "kitchen.return-yard"
             "Climb back through the kitchen window"
             "east"
             ,CHOICE-RETURN
             45>
     <CHOICE-DETAILS "group" "move">)>>

<ROUTINE SUGGEST-LIVING-ROOM ()
  <COND
    (<IN? ,LAMP ,LIVING-ROOM>
     <CHOICE "living-room.take-lamp"
             "Take the brass lantern"
             "take lamp"
             ,CHOICE-PROGRESS
             115>)>

  <COND
    (<IN? ,SWORD ,LIVING-ROOM>
     <CHOICE "living-room.take-sword"
             "Take the elvish sword"
             "take sword"
             ,CHOICE-PROGRESS
             105>)>

  <COND
    (<AND <IN? ,LAMP ,WINNER>
          <NOT <FSET? ,LAMP ,ONBIT>>>
     <CHOICE "living-room.light-lamp"
             "Turn on the brass lantern"
             "turn on lamp"
             ,CHOICE-PROGRESS
             100>)>

  <CHOICE "living-room.examine-case"
          "Examine the trophy case"
          "examine trophy case"
          ,CHOICE-INVESTIGATE
          85>

  <COND
    (<FSET? ,TRAP-DOOR ,INVISIBLE>
     <CHOICE "living-room.move-rug"
             "Move the large rug aside"
             "move rug"
             ,CHOICE-PROGRESS
             100>)
    (<NOT <FSET? ,TRAP-DOOR ,OPENBIT>>
     <CHOICE "living-room.open-trap-door"
             "Open the trap door"
             "open trap door"
             ,CHOICE-PROGRESS
             100>)
    (<FSET? ,LAMP ,ONBIT>
     <CHOICE "living-room.descend"
             "Descend the stairs beneath the trap door"
             "down"
             ,CHOICE-PROGRESS
             110>
     <CHOICE-DETAILS "group" "move">)>

  <CHOICE "living-room.return-kitchen"
          "Return to the kitchen"
          "east"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-ATTIC ()
  <COND
    (<IN? ,ROPE ,ATTIC>
     <CHOICE "attic.take-rope"
             "Take the coil of rope"
             "take rope"
             ,CHOICE-PROGRESS
             100>)>

  <COND
    (<FIRST? ,ATTIC-TABLE>
     <CHOICE "attic.examine-table"
             "Examine what is on the table"
             "examine table"
             ,CHOICE-INVESTIGATE
             70>)>

  <CHOICE "attic.return-kitchen"
          "Go back down to the kitchen"
          "down"
          ,CHOICE-RETURN
          85>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-CELLAR ()
  <CHOICE "cellar.go-troll-room"
          "Go north toward the troll room"
          "north"
          ,CHOICE-PROGRESS
          105>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "cellar.go-east-chasm"
          "Go south toward the east of the chasm"
          "south"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "cellar.go-upstairs"
          "Climb back up to the living room"
          "up"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-TROLL-ROOM ()
  <COND
    (<AND <FSET? ,TROLL ,ONBIT> <NOT <EQUAL? ,HERE ,TROLL-ROOM>>>
     <CHOICE "troll-room.fight-troll"
             "Deal with the fierce troll"
             "attack troll"
             ,CHOICE-PROGRESS
             115>)
    (<IN? ,AXE ,TROLL-ROOM>
     <CHOICE "troll-room.take-axe"
             "Take the axe"
             "take axe"
             ,CHOICE-INVESTIGATE
             100>)>

  <CHOICE "troll-room.go-cellars"
          "Return south to the cellar"
          "south"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "troll-room.go-west"
          "Go west into the maze"
          "west"
          ,CHOICE-PROGRESS
          95>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "troll-room.go-east"
          "Go east toward the east-west passage"
          "east"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-MAZE ()
  <CHOICE "maze.explore"
          "Look around the maze"
          "look"
          ,CHOICE-INVESTIGATE
          50>

  <CHOICE "maze.go-north"
          "Go north"
          "north"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "maze.go-south"
          "Go south"
          "south"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "maze.go-east"
          "Go east"
          "east"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "maze.go-west"
          "Go west"
          "west"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "maze.go-up"
          "Go up"
          "up"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "maze.go-down"
          "Go down"
          "down"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-MAZE-5 ()
  <COND
    (<IN? ,BAG-OF-COINS ,MAZE-5>
     <CHOICE "maze5.take-bag"
             "Take the bag of coins"
             "take bag"
             ,CHOICE-INVESTIGATE
             100>)>
  <COND
    (<IN? ,KEYS ,MAZE-5>
     <CHOICE "maze5.take-keys"
             "Take the skeleton keys"
             "take keys"
             ,CHOICE-PROGRESS
             100>)>
  <COND
    (<IN? ,BURNED-OUT-LANTERN ,MAZE-5>
     <CHOICE "maze5.take-lantern"
             "Take the burned-out lantern"
             "take lantern"
             ,CHOICE-INVESTIGATE
              60>)>
  <COND
    (<IN? ,RUSTY-KNIFE ,MAZE-5>
     <CHOICE "maze5.take-knife"
             "Take the rusty knife"
             "take knife"
             ,CHOICE-INVESTIGATE
              70>)>
  <COND
    (<IN? ,BONES ,MAZE-5>
     <CHOICE "maze5.examine-bones"
             "Examine the skeleton"
             "examine skeleton"
             ,CHOICE-INVESTIGATE
              75>)>>

<ROUTINE SUGGEST-GRATING-CLEARING ()
  <COND
    (<NOT <FSET? ,GRATE ,OPENBIT>>
     <CHOICE "clearing.open-grate"
             "Open the heavy iron grate"
             "open grate"
             ,CHOICE-PROGRESS
             110>)
    (T
     <CHOICE "clearing.descend-grate"
             "Descend through the open grate"
             "down"
             ,CHOICE-PROGRESS
             105>
     <CHOICE-DETAILS "group" "move">)>

  <CHOICE "clearing.go-west"
          "Return west toward the house"
          "west"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "clearing.go-east"
          "Go east into the forest"
          "east"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-GRATING-ROOM ()
  <COND
    (<NOT <FSET? ,GRATE ,OPENBIT>>
     <CHOICE "grating-room.open-grate"
             "Open the grate above"
             "open grate"
             ,CHOICE-PROGRESS
             105>)
    (T
     <CHOICE "grating-room.climb-grate"
             "Climb up through the grate"
             "up"
             ,CHOICE-PROGRESS
             100>
     <CHOICE-DETAILS "group" "move">)>

  <CHOICE "grating-room.explore-maze"
          "Explore deeper into the maze"
          "east"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-CYCLOPS-ROOM ()
  <COND
    (<AND <FSET? ,CYCLOPS ,ONBIT> <IN? ,CYCLOPS ,CYCLOPS-ROOM>>
     <CHOICE "cyclops-room.confront-cyclops"
             "Confront the giant cyclops"
             "attack cyclops"
             ,CHOICE-PROGRESS
             110>)>

  <CHOICE "cyclops-room.go-strange-passage"
          "Go through the strange passage"
          "east"
          ,CHOICE-EXPERIMENT
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "cyclops-room.go-treasure-room"
          "Climb up to the treasure room"
          "up"
          ,CHOICE-PROGRESS
          95>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "cyclops-room.return-maze"
          "Return west into the maze"
          "west"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-TREASURE-ROOM ()
  <COND
    (<IN? ,CHALICE ,TREASURE-ROOM>
     <CHOICE "treasure-room.take-chalice"
             "Take the silver chalice"
             "take chalice"
             ,CHOICE-PROGRESS
             105>)>

  <CHOICE "treasure-room.return-cyclops"
          "Go back down to the cyclops room"
          "down"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-RESERVOIR ()
  <COND
    (<IN? ,TRUNK ,RESERVOIR>
     <COND
       (<NOT <FSET? ,TRUNK ,OPENBIT>>
        <CHOICE "reservoir.open-trunk"
                "Open the trunk"
                "open trunk"
                ,CHOICE-INVESTIGATE
                95>)
       (T
        <CHOICE "reservoir.take-treasures"
                "Take the jewels from the trunk"
                "take jewels"
                ,CHOICE-PROGRESS
                100>)>)>
  <COND
    (<IN? ,PUMP ,RESERVOIR-NORTH>
     <CHOICE "reservoir.take-pump"
             "Take the air pump"
             "take pump"
             ,CHOICE-PROGRESS
             105>)>

  <CHOICE "reservoir.go-stream-view"
          "Go toward the stream view"
          "north"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-DAM-LOBBY ()
  <COND
    (<IN? ,MATCH ,DAM-LOBBY>
     <CHOICE "dam-lobby.take-matches"
             "Take the matchbook"
             "take matchbook"
             ,CHOICE-INVESTIGATE
             105>)>
  <COND
    (<IN? ,GUIDE ,DAM-LOBBY>
     <CHOICE "dam-lobby.take-guide"
             "Take the tour guidebook"
             "take guide"
             ,CHOICE-INVESTIGATE
              80>)>

  <CHOICE "dam-lobby.go-dam"
          "Go into the main dam room"
          "north"
          ,CHOICE-PROGRESS
          95>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-MAINTENANCE-ROOM ()
  <COND
    (<IN? ,SCREWDRIVER ,MAINTENANCE-ROOM>
     <CHOICE "maint.take-screwdriver"
             "Take the screwdriver"
             "take screwdriver"
             ,CHOICE-INVESTIGATE
             105>)>
  <COND
    (<IN? ,WRENCH ,MAINTENANCE-ROOM>
     <CHOICE "maint.take-wrench"
             "Take the wrench"
             "take wrench"
             ,CHOICE-INVESTIGATE
             100>)>
  <COND
    (<IN? ,TUBE ,MAINTENANCE-ROOM>
     <CHOICE "maint.take-putty"
             "Take the tube of putty"
             "take tube"
             ,CHOICE-INVESTIGATE
              90>)>
  <COND
    (<IN? ,YELLOW-BUTTON ,MAINTENANCE-ROOM>
     <CHOICE "maint.push-button"
             "Push the yellow button"
             "push yellow button"
             ,CHOICE-EXPERIMENT
              85>)>>

<ROUTINE SUGGEST-MACHINE-ROOM ()
  <COND
    (<NOT <FSET? ,MACHINE ,ONBIT>>
     <CHOICE "machine.turn-on"
             "Turn on the machine"
             "turn on machine"
             ,CHOICE-EXPERIMENT
             95>)
    (T
     <CHOICE "machine.turn-off"
             "Turn off the machine"
             "turn off machine"
             ,CHOICE-EXPERIMENT
              50>)>

  <CHOICE "machine.return-mine"
          "Go back into the coal mine"
          "west"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-ROUND-ROOM ()
  <CHOICE "round-room.go-ew-passage"
          "Go east into the east-west passage"
          "east"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "round-room.go-damp-cave"
          "Go west toward the damp cave"
          "west"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "round-room.go-loud-room"
          "Go north to the loud room"
          "north"
          ,CHOICE-PROGRESS
          95>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "round-room.go-chasm"
          "Go south toward the chasm room"
          "south"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-LOUD-ROOM ()
  <COND
    (<IN? ,BAR ,LOUD-ROOM>
     <CHOICE "loud-room.take-bar"
             "Take the platinum bar"
             "take bar"
             ,CHOICE-PROGRESS
             100>)>

  <CHOICE "loud-room.return-round"
          "Return to the round room"
          "south"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-NORTH-TEMPLE ()
  <COND
    (<IN? ,BELL ,NORTH-TEMPLE>
     <CHOICE "temple.take-bell"
             "Take the brass bell"
             "take bell"
             ,CHOICE-PROGRESS
             100>)>
  <COND
    (<NOT <IN? ,BELL ,WINNER>>
     <CHOICE "temple.read-prayer"
             "Read the prayer inscription"
             "read prayer"
             ,CHOICE-INVESTIGATE
              85>)>

  <CHOICE "temple.go-altar"
          "Go south to the altar"
          "south"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "temple.go-dome"
          "Go east to the dome room"
          "east"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-SOUTH-TEMPLE ()
  <COND
    (<AND <IN? ,CANDLES ,SOUTH-TEMPLE> <FSET? ,CANDLES ,ONBIT>>
     <CHOICE "altar.take-candles"
             "Take the candles"
             "take candles"
             ,CHOICE-INVESTIGATE
              85>)>
  <COND
    (<IN? ,BOOK ,ALTAR>
     <CHOICE "altar.take-book"
             "Take the book from the altar"
             "take book"
             ,CHOICE-INVESTIGATE
             100>)>

  <CHOICE "altar.return-temple"
          "Return north to the temple"
          "north"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-EGYPT-ROOM ()
  <COND
    (<IN? ,COFFIN ,EGYPT-ROOM>
     <COND
       (<NOT <FSET? ,COFFIN ,OPENBIT>>
        <CHOICE "egypt.open-coffin"
                "Open the gold coffin"
                "open coffin"
                ,CHOICE-PROGRESS
                105>)
       (T
        <CHOICE "egypt.take-sceptre"
                "Take the sceptre from the coffin"
                "take sceptre"
                ,CHOICE-PROGRESS
                100>)>)>

  <CHOICE "egypt.go-temple"
          "Go to the temple entrance"
          "west"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-BAT-ROOM ()
  <COND
    (<IN? ,JADE ,BAT-ROOM>
     <COND
       (<NOT <FSET? ,BAT ,MOVED>>
        <CHOICE "bat-room.get-jade"
                "Find a way past the bat to reach the jade figurine"
                "get jade"
                ,CHOICE-PROGRESS
                100>)
       (T
        <CHOICE "bat-room.take-jade"
                "Take the jade figurine"
                "take jade"
                ,CHOICE-INVESTIGATE
                100>)>)>

  <CHOICE "bat-room.go-mine"
          "Return to the mine entrance"
          "west"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-HADES ()
  <COND
    (<IN? ,SKULL ,LAND-OF-LIVING-DEAD>
     <CHOICE "hades.take-skull"
             "Take the crystal skull"
             "take skull"
             ,CHOICE-PROGRESS
             105>)>

  <CHOICE "hades.go-temple"
          "Return through the temple passage"
          "west"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-ATLANTIS-ROOM ()
  <COND
    (<IN? ,TRIDENT ,ATLANTIS-ROOM>
     <CHOICE "atlantis.take-trident"
             "Take the crystal trident"
             "take trident"
             ,CHOICE-PROGRESS
             105>)>

  <CHOICE "atlantis.go-mirror"
          "Return through the mirror rooms"
          "west"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-TORCH-ROOM ()
  <COND
    (<AND <IN? ,PEDESTAL ,TORCH-ROOM> <FIRST? ,PEDESTAL>>
     <CHOICE "torch-room.take-torch"
             "Take the torch from the pedestal"
             "take torch"
             ,CHOICE-PROGRESS
             100>)>

  <CHOICE "torch-room.go-dome"
          "Go to the dome room"
          "south"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-GALLERY ()
  <COND
    (<IN? ,PAINTING ,GALLERY>
     <CHOICE "gallery.take-painting"
             "Take the painting"
             "take painting"
             ,CHOICE-PROGRESS
             100>)>

  <CHOICE "gallery.go-studio"
          "Go north to the studio"
          "north"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "gallery.return-chasm"
          "Return south to the chasm"
          "south"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-STUDIO ()
  <COND
    (<IN? ,OWNERS-MANUAL ,STUDIO>
     <CHOICE "studio.read-manual"
             "Read the owner's manual"
             "read manual"
             ,CHOICE-INVESTIGATE
             100>)>

  <CHOICE "studio.return-gallery"
          "Return to the gallery"
          "south"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-ARAGAIN-FALLS ()
  <COND
    (<NOT <IN? ,POT-OF-GOLD ,WINNER>>
     <COND
       (<IN? ,POT-OF-GOLD ,END-OF-RAINBOW>
        <CHOICE "rainbow.climb-rainbow"
                "Climb the rainbow to the pot of gold"
                "climb rainbow"
                ,CHOICE-PROGRESS
                115>)>)>
  <CHOICE "falls.go-beach"
          "Go to the sandy beach"
          "south"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "falls.go-canyon"
          "Go toward the canyon bottom"
          "north"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-FOREST ()
  <CHOICE "forest.explore"
          "Look around the forest"
          "look"
          ,CHOICE-INVESTIGATE
          60>

  <CHOICE "forest.go-north"
          "Go north through the trees"
          "north"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "forest.go-east"
          "Head east toward the sunlight"
          "east"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "forest.go-south"
          "Go south through the forest"
          "south"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "forest.go-west"
          "Go west into the deeper forest"
          "west"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-PATH ()
  <CHOICE "path.climb-tree"
          "Climb the large tree"
          "climb tree"
          ,CHOICE-EXPERIMENT
          80>

  <CHOICE "path.go-north"
          "Follow the path north"
          "north"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "path.go-south"
          "Follow the path south"
          "south"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "path.go-east"
          "Go east into the forest"
          "east"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "path.go-west"
          "Go west into the forest"
          "west"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-UP-A-TREE ()
  <CHOICE "tree.go-down"
          "Climb back down to the path"
          "down"
          ,CHOICE-RETURN
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "tree.look-around"
          "Look around from the treetop"
          "look"
          ,CHOICE-INVESTIGATE
          70>>

<ROUTINE SUGGEST-CLEARING ()
  <CHOICE "clearing.go-east"
          "Follow the path east"
          "east"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "clearing.go-north"
          "Go north into the forest"
          "north"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "clearing.go-south"
          "Go south into the forest"
          "south"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "clearing.go-west"
          "Return west toward the house"
          "west"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-MOUNTAINS ()
  <CHOICE "mountains.explore"
          "Look at the mountains"
          "look"
          ,CHOICE-INVESTIGATE
          50>

  <CHOICE "mountains.go-north"
          "Go back north"
          "north"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mountains.go-south"
          "Go back south"
          "south"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-STONE-BARROW ()
  <CHOICE "barrow.enter"
          "Enter the stone barrow"
          "in"
          ,CHOICE-PROGRESS
          90>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "barrow.go-northeast"
          "Return northeast to the house"
          "ne"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-CANYON-VIEW ()
  <CHOICE "canyon-view.climb-down"
          "Climb down into the canyon"
          "down"
          ,CHOICE-EXPERIMENT
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "canyon-view.go-east"
          "Climb east down the cliff"
          "east"
          ,CHOICE-EXPERIMENT
          65>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "canyon-view.go-northwest"
          "Follow the path northwest"
          "nw"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "canyon-view.go-west"
          "Go west into the forest"
          "west"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-CANYON-BOTTOM ()
  <CHOICE "canyon-bottom.climb-up"
          "Climb up the cliff"
          "up"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "canyon-bottom.go-north"
          "Go north to the end of the rainbow"
          "north"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-CLIFF-MIDDLE ()
  <CHOICE "cliff-middle.climb-up"
          "Climb higher up the cliff"
          "up"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "cliff-middle.climb-down"
          "Climb down to the canyon bottom"
          "down"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-EAST-OF-CHASM ()
  <CHOICE "east-chasm.go-gallery"
          "Go east to the art gallery"
          "east"
          ,CHOICE-PROGRESS
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "east-chasm.go-cellar"
          "Go north to the cellar"
          "north"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-STRANGE-PASSAGE ()
  <CHOICE "strange-passage.go-west"
          "Go west through the cyclops opening"
          "west"
          ,CHOICE-EXPERIMENT
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "strange-passage.go-east"
          "Go east through the wooden door"
          "east"
          ,CHOICE-PROGRESS
          80>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-MIRROR-ROOM ()
  <CHOICE "mirror-room.explore"
          "Look at the mirrors"
          "look"
          ,CHOICE-INVESTIGATE
          60>

  <CHOICE "mirror-room.go-north"
          "Go north"
          "north"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mirror-room.go-west"
          "Go west"
          "west"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mirror-room.go-east"
          "Go east"
          "east"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-SMALL-CAVE ()
  <CHOICE "small-cave.go-north"
          "Go north to the mirror room"
          "north"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "small-cave.go-down"
          "Descend into Atlantis"
          "down"
          ,CHOICE-PROGRESS
          75>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-TINY-CAVE ()
  <CHOICE "tiny-cave.go-north"
          "Go north to the mirror room"
          "north"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "tiny-cave.go-west"
          "Go west through the winding passage"
          "west"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "tiny-cave.go-down"
          "Descend toward Hades"
          "down"
          ,CHOICE-EXPERIMENT
          65>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-COLD-PASSAGE ()
  <CHOICE "cold-passage.go-west"
          "Go west to the slide room"
          "west"
          ,CHOICE-PROGRESS
          65>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "cold-passage.go-south"
          "Go south to the mirror room"
          "south"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-NARROW-PASSAGE ()
  <CHOICE "narrow-passage.go-north"
          "Go north to the round room"
          "north"
          ,CHOICE-RETURN
          65>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "narrow-passage.go-south"
          "Go south to the mirror room"
          "south"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-WINDING-PASSAGE ()
  <CHOICE "winding-passage.go-north"
          "Go north to the mirror room"
          "north"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "winding-passage.go-east"
          "Go east to the tiny cave"
          "east"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-TWISTING-PASSAGE ()
  <CHOICE "twisting-passage.go-north"
          "Go north to the mirror room"
          "north"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "twisting-passage.go-east"
          "Go east to the small cave"
          "east"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-ENGRAVINGS-CAVE ()
  <CHOICE "engravings.go-northwest"
          "Go northwest to the round room"
          "nw"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "engravings.go-east"
          "Go east to the dome room"
          "east"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-DOME-ROOM ()
  <COND
    (<FSET? ,DOME-FLAG ,ONBIT>
     <CHOICE "dome.go-down"
             "Descend the rope to the torch room"
             "down"
             ,CHOICE-PROGRESS
             100>
     <CHOICE-DETAILS "group" "move">)
    (T
     <CHOICE "dome.tie-rope"
             "Tie the rope to the railing"
             "tie rope to railing"
             ,CHOICE-PROGRESS
             95>)>

  <CHOICE "dome.go-west"
          "Go west to the engravings cave"
          "west"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-EW-PASSAGE ()
  <CHOICE "ew-passage.go-east"
          "Go east to the round room"
          "east"
          ,CHOICE-EXPERIMENT
          65>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "ew-passage.go-west"
          "Go west to the troll room"
          "west"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "ew-passage.go-north"
          "Go north to the chasm"
          "north"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-DEEP-CANYON ()
  <CHOICE "deep-canyon.go-east"
          "Go east to the dam"
          "east"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "deep-canyon.go-down"
          "Descend to the loud room"
          "down"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "deep-canyon.go-northwest"
          "Go northwest to the reservoir"
          "nw"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-DAMP-CAVE ()
  <CHOICE "damp-cave.go-west"
          "Go west to the loud room"
          "west"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "damp-cave.go-east"
          "Go east to the white cliffs"
          "east"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-NS-PASSAGE ()
  <CHOICE "ns-passage.go-north"
          "Go north to the chasm"
          "north"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "ns-passage.go-northeast"
          "Go northeast to the deep canyon"
          "ne"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "ns-passage.go-south"
          "Go south to the round room"
          "south"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-CHASM-ROOM ()
  <CHOICE "chasm-room.go-northeast"
          "Go northeast to the reservoir"
          "ne"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "chasm-room.go-southwest"
          "Go southwest to the east-west passage"
          "sw"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "chasm-room.go-south"
          "Go south to the north-south passage"
          "south"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-RESERVOIR-SOUTH ()
  <COND
    (<FSET? ,LOW-TIDE ,ONBIT>
     <CHOICE "reservoir-south.go-north"
             "Cross the dry reservoir north"
             "north"
             ,CHOICE-PROGRESS
             80>
     <CHOICE-DETAILS "group" "move">)
    (T
     <CHOICE "reservoir-south.look-water"
             "Look at the reservoir water"
             "examine water"
             ,CHOICE-INVESTIGATE
             60>)>

  <CHOICE "reservoir-south.go-east"
          "Go east to the dam"
          "east"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "reservoir-south.go-southeast"
          "Go southeast to the deep canyon"
          "se"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-IN-STREAM ()
  <CHOICE "in-stream.land"
          "Land on the beach"
          "land"
          ,CHOICE-PROGRESS
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "in-stream.go-down"
          "Float downstream"
          "down"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-STREAM-VIEW ()
  <CHOICE "stream-view.go-east"
          "Follow the stream east"
          "east"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-DAM-ROOM ()
  <CHOICE "dam-room.go-north"
          "Go north to the dam lobby"
          "north"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "dam-room.go-down"
          "Descend to the dam base"
          "down"
          ,CHOICE-EXPERIMENT
          65>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "dam-room.go-west"
          "Go west to the reservoir"
          "west"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "dam-room.go-south"
          "Go south to the deep canyon"
          "south"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-DAM-BASE ()
  <CHOICE "dam-base.go-north"
          "Climb up to the dam"
          "north"
          ,CHOICE-RETURN
          70>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-RIVER ()
  <CHOICE "river.go-down"
          "Float downstream"
          "down"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "river.land"
          "Try to land"
          "land"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-WHITE-CLIFFS ()
  <COND
    (<FSET? ,DEFLATE ,ONBIT>
     <CHOICE "cliffs.go-south"
             "Go south along the beach"
             "south"
             ,CHOICE-EXPERIMENT
             65>
     <CHOICE-DETAILS "group" "move">

     <CHOICE "cliffs.go-west"
             "Go west into the damp cave"
             "west"
             ,CHOICE-PROGRESS
             70>
     <CHOICE-DETAILS "group" "move">)
    (T
     <CHOICE "cliffs.look-path"
             "Look at the narrow path"
             "examine path"
             ,CHOICE-INVESTIGATE
              50>)>>

<ROUTINE SUGGEST-SHORE ()
  <CHOICE "shore.go-north"
          "Go north to the sandy beach"
          "north"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "shore.go-south"
          "Go south to Aragain Falls"
          "south"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-SANDY-BEACH ()
  <CHOICE "sandy-beach.go-northeast"
          "Enter the sandy cave"
          "ne"
          ,CHOICE-EXPERIMENT
          65>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "sandy-beach.go-south"
          "Go south along the shore"
          "south"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-SANDY-CAVE ()
  <CHOICE "sandy-cave.go-southwest"
          "Return to the sandy beach"
          "sw"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-ON-RAINBOW ()
  <CHOICE "rainbow.go-west"
          "Walk west along the rainbow"
          "west"
          ,CHOICE-PROGRESS
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "rainbow.go-east"
          "Walk east along the rainbow"
          "east"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-END-OF-RAINBOW ()
  <COND
    (<IN? ,POT-OF-GOLD ,END-OF-RAINBOW>
     <CHOICE "end-rainbow.take-gold"
             "Take the pot of gold"
             "take pot"
             ,CHOICE-PROGRESS
             110>)>

  <CHOICE "end-rainbow.go-northeast"
          "Climb the rainbow"
          "ne"
          ,CHOICE-EXPERIMENT
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "end-rainbow.go-southwest"
          "Go southwest to the canyon bottom"
          "sw"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-MINE-ENTRANCE ()
  <CHOICE "mine-entrance.go-west"
          "Enter the squeaky room"
          "west"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mine-entrance.go-south"
          "Go south to the slide room"
          "south"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-SQUEEKY-ROOM ()
  <CHOICE "squeeky.go-north"
          "Go north to the bat room"
          "north"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "squeeky.go-east"
          "Return east to the mine entrance"
          "east"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-SHAFT-ROOM ()
  <CHOICE "shaft.go-west"
          "Go west to the bat room"
          "west"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "shaft.go-north"
          "Go north to the smelly room"
          "north"
          ,CHOICE-EXPERIMENT
          65>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-SMELLY-ROOM ()
  <CHOICE "smelly.go-down"
          "Descend to the gas room"
          "down"
          ,CHOICE-EXPERIMENT
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "smelly.go-south"
          "Return south to the shaft room"
          "south"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-GAS-ROOM ()
  <CHOICE "gas.go-up"
          "Climb back up to the smelly room"
          "up"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "gas.go-east"
          "Go east into the coal mine"
          "east"
          ,CHOICE-EXPERIMENT
          65>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-LADDER-TOP ()
  <CHOICE "ladder-top.go-down"
          "Descend the rickety ladder"
          "down"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "ladder-top.go-up"
          "Climb up to the coal mine"
          "up"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-LADDER-BOTTOM ()
  <CHOICE "ladder-bottom.go-west"
          "Go west to the timber room"
          "west"
          ,CHOICE-PROGRESS
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "ladder-bottom.go-south"
          "Go south to the dead end"
          "south"
          ,CHOICE-EXPERIMENT
          45>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "ladder-bottom.go-up"
          "Climb back up the ladder"
          "up"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-TIMBER-ROOM ()
  <COND
    (<NOT ,HANDS-FULL>
     <CHOICE "timber.go-west"
             "Squeeze west through the narrow passage"
             "west"
             ,CHOICE-PROGRESS
             75>
     <CHOICE-DETAILS "group" "move">)
    (T
     <CHOICE "timber.drop-items"
             "Drop some items to fit through"
             "drop all"
             ,CHOICE-PROGRESS
             60>)>

  <CHOICE "timber.go-east"
          "Return east to the ladder bottom"
          "east"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-LOWER-SHAFT ()
  <COND
    (<NOT ,HANDS-FULL>
     <CHOICE "lower-shaft.go-south"
             "Go south to the machine room"
             "south"
             ,CHOICE-PROGRESS
             70>
     <CHOICE-DETAILS "group" "move">

     <CHOICE "lower-shaft.go-east"
             "Return east through the narrow passage"
             "east"
             ,CHOICE-RETURN
             55>
     <CHOICE-DETAILS "group" "move">)>>

<ROUTINE SUGGEST-MINE ()
  <CHOICE "mine.explore"
          "Look around the coal mine"
          "look"
          ,CHOICE-INVESTIGATE
          50>

  <CHOICE "mine.go-north"
          "Go north"
          "north"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mine.go-east"
          "Go east"
          "east"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mine.go-northeast"
          "Go northeast"
          "ne"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mine.go-south"
          "Go south"
          "south"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mine.go-southeast"
          "Go southeast"
          "se"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mine.go-southwest"
          "Go southwest"
          "sw"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mine.go-west"
          "Go west"
          "west"
          ,CHOICE-EXPERIMENT
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "mine.go-down"
          "Go down"
          "down"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-SLIDE-ROOM ()
  <CHOICE "slide.go-down"
          "Slide down to the cellar"
          "down"
          ,CHOICE-PROGRESS
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "slide.go-east"
          "Go east to the cold passage"
          "east"
          ,CHOICE-EXPERIMENT
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "slide.go-north"
          "Go north to the mine entrance"
          "north"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-DEAD-END ()
  <CHOICE "dead-end.explore"
          "Look for another way out"
          "look"
          ,CHOICE-INVESTIGATE
          50>

  <CHOICE "dead-end.go-back"
          "Go back the way you came"
          "south"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-ACTIONS ()
  <COND
    ;"Surface rooms"
    (<EQUAL? ,HERE ,WEST-OF-HOUSE>
     <SUGGEST-WEST-OF-HOUSE>)
    (<EQUAL? ,HERE ,NORTH-OF-HOUSE>
     <SUGGEST-NORTH-OF-HOUSE>)
    (<EQUAL? ,HERE ,SOUTH-OF-HOUSE>
     <SUGGEST-SOUTH-OF-HOUSE>)
    (<EQUAL? ,HERE ,EAST-OF-HOUSE>
     <SUGGEST-EAST-OF-HOUSE>)
    (<EQUAL? ,HERE ,FOREST-1>
     <SUGGEST-FOREST>)
    (<EQUAL? ,HERE ,FOREST-2>
     <SUGGEST-FOREST>)
    (<EQUAL? ,HERE ,FOREST-3>
     <SUGGEST-FOREST>)
    (<EQUAL? ,HERE ,MOUNTAINS>
     <SUGGEST-MOUNTAINS>)
    (<EQUAL? ,HERE ,PATH>
     <SUGGEST-PATH>)
    (<EQUAL? ,HERE ,UP-A-TREE>
     <SUGGEST-UP-A-TREE>)
    (<EQUAL? ,HERE ,GRATING-CLEARING>
     <SUGGEST-GRATING-CLEARING>)
    (<EQUAL? ,HERE ,CLEARING>
     <SUGGEST-CLEARING>)
    (<EQUAL? ,HERE ,STONE-BARROW>
     <SUGGEST-STONE-BARROW>)
    (<EQUAL? ,HERE ,CANYON-VIEW>
     <SUGGEST-CANYON-VIEW>)
    (<EQUAL? ,HERE ,CANYON-BOTTOM>
     <SUGGEST-CANYON-BOTTOM>)
    (<EQUAL? ,HERE ,CLIFF-MIDDLE>
     <SUGGEST-CLIFF-MIDDLE>)
    ;"House interior"
    (<EQUAL? ,HERE ,KITCHEN>
     <SUGGEST-KITCHEN>)
    (<EQUAL? ,HERE ,LIVING-ROOM>
     <SUGGEST-LIVING-ROOM>)
    (<EQUAL? ,HERE ,ATTIC>
     <SUGGEST-ATTIC>)
    ;"Cellar and vicinity"
    (<EQUAL? ,HERE ,CELLAR>
     <SUGGEST-CELLAR>)
    (<EQUAL? ,HERE ,TROLL-ROOM>
     <SUGGEST-TROLL-ROOM>)
    (<EQUAL? ,HERE ,EAST-OF-CHASM>
     <SUGGEST-EAST-OF-CHASM>)
    (<EQUAL? ,HERE ,STRANGE-PASSAGE>
     <SUGGEST-STRANGE-PASSAGE>)
    (<EQUAL? ,HERE ,GALLERY>
     <SUGGEST-GALLERY>)
    (<EQUAL? ,HERE ,STUDIO>
     <SUGGEST-STUDIO>)
    ;"Maze"
    (<EQUAL? ,HERE ,MAZE-1>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-2>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-3>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-4>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-5>
     <SUGGEST-MAZE-5>)
    (<EQUAL? ,HERE ,MAZE-6>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-7>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-8>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-9>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-10>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-11>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-12>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-13>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-14>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,MAZE-15>
     <SUGGEST-MAZE>)
    (<EQUAL? ,HERE ,DEAD-END-1>
     <SUGGEST-DEAD-END>)
    (<EQUAL? ,HERE ,DEAD-END-2>
     <SUGGEST-DEAD-END>)
    (<EQUAL? ,HERE ,DEAD-END-3>
     <SUGGEST-DEAD-END>)
    (<EQUAL? ,HERE ,DEAD-END-4>
     <SUGGEST-DEAD-END>)
    (<EQUAL? ,HERE ,DEAD-END-5>
     <SUGGEST-DEAD-END>)
    (<EQUAL? ,HERE ,GRATING-ROOM>
     <SUGGEST-GRATING-ROOM>)
    ;"Cyclops and treasure"
    (<EQUAL? ,HERE ,CYCLOPS-ROOM>
     <SUGGEST-CYCLOPS-ROOM>)
    (<EQUAL? ,HERE ,TREASURE-ROOM>
     <SUGGEST-TREASURE-ROOM>)
    ;"Mirror rooms and vicinity"
    (<EQUAL? ,HERE ,MIRROR-ROOM-1>
     <SUGGEST-MIRROR-ROOM>)
    (<EQUAL? ,HERE ,MIRROR-ROOM-2>
     <SUGGEST-MIRROR-ROOM>)
    (<EQUAL? ,HERE ,SMALL-CAVE>
     <SUGGEST-SMALL-CAVE>)
    (<EQUAL? ,HERE ,TINY-CAVE>
     <SUGGEST-TINY-CAVE>)
    (<EQUAL? ,HERE ,COLD-PASSAGE>
     <SUGGEST-COLD-PASSAGE>)
    (<EQUAL? ,HERE ,NARROW-PASSAGE>
     <SUGGEST-NARROW-PASSAGE>)
    (<EQUAL? ,HERE ,WINDING-PASSAGE>
     <SUGGEST-WINDING-PASSAGE>)
    (<EQUAL? ,HERE ,TWISTING-PASSAGE>
     <SUGGEST-TWISTING-PASSAGE>)
    (<EQUAL? ,HERE ,ATLANTIS-ROOM>
     <SUGGEST-ATLANTIS-ROOM>)
    ;"Round room and vicinity"
    (<EQUAL? ,HERE ,EW-PASSAGE>
     <SUGGEST-EW-PASSAGE>)
    (<EQUAL? ,HERE ,ROUND-ROOM>
     <SUGGEST-ROUND-ROOM>)
    (<EQUAL? ,HERE ,DEEP-CANYON>
     <SUGGEST-DEEP-CANYON>)
    (<EQUAL? ,HERE ,DAMP-CAVE>
     <SUGGEST-DAMP-CAVE>)
    (<EQUAL? ,HERE ,LOUD-ROOM>
     <SUGGEST-LOUD-ROOM>)
    (<EQUAL? ,HERE ,NS-PASSAGE>
     <SUGGEST-NS-PASSAGE>)
    (<EQUAL? ,HERE ,CHASM-ROOM>
     <SUGGEST-CHASM-ROOM>)
    (<EQUAL? ,HERE ,ENGRAVINGS-CAVE>
     <SUGGEST-ENGRAVINGS-CAVE>)
    (<EQUAL? ,HERE ,DOME-ROOM>
     <SUGGEST-DOME-ROOM>)
    (<EQUAL? ,HERE ,TORCH-ROOM>
     <SUGGEST-TORCH-ROOM>)
    ;"Temple and Egypt"
    (<EQUAL? ,HERE ,NORTH-TEMPLE>
     <SUGGEST-NORTH-TEMPLE>)
    (<EQUAL? ,HERE ,SOUTH-TEMPLE>
     <SUGGEST-SOUTH-TEMPLE>)
    (<EQUAL? ,HERE ,EGYPT-ROOM>
     <SUGGEST-EGYPT-ROOM>)
    ;"Hades"
    (<EQUAL? ,HERE ,ENTRANCE-TO-HADES>
     <SUGGEST-HADES>)
    (<EQUAL? ,HERE ,LAND-OF-LIVING-DEAD>
     <SUGGEST-HADES>)
    ;"Reservoir area"
    (<EQUAL? ,HERE ,RESERVOIR-SOUTH>
     <SUGGEST-RESERVOIR-SOUTH>)
    (<EQUAL? ,HERE ,RESERVOIR>
     <SUGGEST-RESERVOIR>)
    (<EQUAL? ,HERE ,RESERVOIR-NORTH>
     <SUGGEST-RESERVOIR>)
    (<EQUAL? ,HERE ,STREAM-VIEW>
     <SUGGEST-STREAM-VIEW>)
    (<EQUAL? ,HERE ,IN-STREAM>
     <SUGGEST-IN-STREAM>)
    ;"Dam area"
    (<EQUAL? ,HERE ,DAM-ROOM>
     <SUGGEST-DAM-ROOM>)
    (<EQUAL? ,HERE ,DAM-LOBBY>
     <SUGGEST-DAM-LOBBY>)
    (<EQUAL? ,HERE ,MAINTENANCE-ROOM>
     <SUGGEST-MAINTENANCE-ROOM>)
    (<EQUAL? ,HERE ,MACHINE-ROOM>
     <SUGGEST-MACHINE-ROOM>)
    (<EQUAL? ,HERE ,DAM-BASE>
     <SUGGEST-DAM-BASE>)
    ;"River and shore"
    (<EQUAL? ,HERE ,RIVER-1>
     <SUGGEST-RIVER>)
    (<EQUAL? ,HERE ,RIVER-2>
     <SUGGEST-RIVER>)
    (<EQUAL? ,HERE ,RIVER-3>
     <SUGGEST-RIVER>)
    (<EQUAL? ,HERE ,RIVER-4>
     <SUGGEST-RIVER>)
    (<EQUAL? ,HERE ,RIVER-5>
     <SUGGEST-RIVER>)
    (<EQUAL? ,HERE ,WHITE-CLIFFS-NORTH>
     <SUGGEST-WHITE-CLIFFS>)
    (<EQUAL? ,HERE ,WHITE-CLIFFS-SOUTH>
     <SUGGEST-WHITE-CLIFFS>)
    (<EQUAL? ,HERE ,SHORE>
     <SUGGEST-SHORE>)
    (<EQUAL? ,HERE ,SANDY-BEACH>
     <SUGGEST-SANDY-BEACH>)
    (<EQUAL? ,HERE ,SANDY-CAVE>
     <SUGGEST-SANDY-CAVE>)
    (<EQUAL? ,HERE ,ARAGAIN-FALLS>
     <SUGGEST-ARAGAIN-FALLS>)
    (<EQUAL? ,HERE ,ON-RAINBOW>
     <SUGGEST-ON-RAINBOW>)
    (<EQUAL? ,HERE ,END-OF-RAINBOW>
     <SUGGEST-END-OF-RAINBOW>)
    ;"Coal mine"
    (<EQUAL? ,HERE ,MINE-ENTRANCE>
     <SUGGEST-MINE-ENTRANCE>)
    (<EQUAL? ,HERE ,SQUEEKY-ROOM>
     <SUGGEST-SQUEEKY-ROOM>)
    (<EQUAL? ,HERE ,BAT-ROOM>
     <SUGGEST-BAT-ROOM>)
    (<EQUAL? ,HERE ,SHAFT-ROOM>
     <SUGGEST-SHAFT-ROOM>)
    (<EQUAL? ,HERE ,SMELLY-ROOM>
     <SUGGEST-SMELLY-ROOM>)
    (<EQUAL? ,HERE ,GAS-ROOM>
     <SUGGEST-GAS-ROOM>)
    (<EQUAL? ,HERE ,LADDER-TOP>
     <SUGGEST-LADDER-TOP>)
    (<EQUAL? ,HERE ,LADDER-BOTTOM>
     <SUGGEST-LADDER-BOTTOM>)
    (<EQUAL? ,HERE ,TIMBER-ROOM>
     <SUGGEST-TIMBER-ROOM>)
    (<EQUAL? ,HERE ,LOWER-SHAFT>
     <SUGGEST-LOWER-SHAFT>)
    (<EQUAL? ,HERE ,MINE-1>
     <SUGGEST-MINE>)
    (<EQUAL? ,HERE ,MINE-2>
     <SUGGEST-MINE>)
    (<EQUAL? ,HERE ,MINE-3>
     <SUGGEST-MINE>)
    (<EQUAL? ,HERE ,MINE-4>
     <SUGGEST-MINE>)
    (<EQUAL? ,HERE ,SLIDE-ROOM>
     <SUGGEST-SLIDE-ROOM>)>>

<ROUTINE SUGGEST-SCENE ()
  <COND
    ;"Surface rooms"
    (<EQUAL? ,HERE ,WEST-OF-HOUSE>
     <SCENE "zork1.west-of-house"
            "An open field west of a white house with a boarded front door and a small mailbox.">)
    (<EQUAL? ,HERE ,NORTH-OF-HOUSE>
     <SCENE "zork1.north-of-house"
            "The boarded north side of a white house beside a narrow forest path.">)
    (<EQUAL? ,HERE ,SOUTH-OF-HOUSE>
     <SCENE "zork1.south-of-house"
            "The boarded south side of a white house at the edge of the forest.">)
    (<EQUAL? ,HERE ,EAST-OF-HOUSE>
     <COND
       (<FSET? ,KITCHEN-WINDOW ,OPENBIT>
        <SCENE "zork1.behind-house.window-open"
               "Behind the white house, the kitchen window stands open beside a forest path.">)
       (T
        <SCENE "zork1.behind-house"
               "Behind the white house, a small kitchen window sits slightly ajar.">)>)
    (<EQUAL? ,HERE ,FOREST-1>
     <SCENE "zork1.forest"
            "A dense forest with trees in all directions. Sunlight filters through from the east.">)
    (<EQUAL? ,HERE ,FOREST-2>
     <SCENE "zork1.forest"
            "A dimly lit forest with large trees all around.">)
    (<EQUAL? ,HERE ,FOREST-3>
     <SCENE "zork1.forest"
            "A dimly lit forest with large trees all around.">)
    (<EQUAL? ,HERE ,MOUNTAINS>
     <SCENE "zork1.mountains"
            "The forest thins out, revealing impassable mountains.">)
    (<EQUAL? ,HERE ,PATH>
     <SCENE "zork1.path"
            "A path winding through a dimly lit forest with a large tree at the edge.">)
    (<EQUAL? ,HERE ,UP-A-TREE>
     <SCENE "zork1.tree"
            "High in a large tree with a view of the surrounding forest.">)
    (<EQUAL? ,HERE ,GRATING-CLEARING>
     <SCENE "zork1.grating-clearing"
            "A clearing in the forest with a heavy iron grate set into the ground.">)
    (<EQUAL? ,HERE ,CLEARING>
     <SCENE "zork1.clearing"
            "A small clearing in a well-marked forest path extending east and west.">)
    (<EQUAL? ,HERE ,STONE-BARROW>
     <SCENE "zork1.stone-barrow"
            "A massive barrow of stone with a huge open door in the east face.">)
    (<EQUAL? ,HERE ,CANYON-VIEW>
     <SCENE "zork1.canyon-view"
            "The top of the Great Canyon with a marvelous view of the river and falls.">)
    (<EQUAL? ,HERE ,CANYON-BOTTOM>
     <SCENE "zork1.canyon-bottom"
            "Beneath the walls of the river canyon with the falls flowing by below.">)
    (<EQUAL? ,HERE ,CLIFF-MIDDLE>
     <SCENE "zork1.cliff-middle"
            "A ledge halfway up the wall of the river canyon.">)
    ;"House interior"
    (<EQUAL? ,HERE ,KITCHEN>
     <SCENE "zork1.kitchen"
            "The white house kitchen, with a food-laden table, dark stairs, and a small window.">)
    (<EQUAL? ,HERE ,LIVING-ROOM>
     <SCENE "zork1.living-room"
            "A living room containing a trophy case, a brass lantern, and an elvish sword.">)
    (<EQUAL? ,HERE ,ATTIC>
     <SCENE "zork1.attic"
            "A dim attic with a table and a stairway leading back down.">)
    ;"Cellar and vicinity"
    (<EQUAL? ,HERE ,CELLAR>
     <SCENE "zork1.cellar"
            "A damp cellar beneath the living room, with passages leading north and south.">)
    (<EQUAL? ,HERE ,TROLL-ROOM>
     <SCENE "zork1.troll-room"
            "A foul room occupied by a dangerous troll. Passages lead west, east, and south.">)
    (<EQUAL? ,HERE ,EAST-OF-CHASM>
     <SCENE "zork1.east-of-chasm"
            "The east edge of a chasm with passages north and east.">)
    (<EQUAL? ,HERE ,STRANGE-PASSAGE>
     <SCENE "zork1.strange-passage"
            "A long passage with a cyclops-sized opening in an old wooden door.">)
    (<EQUAL? ,HERE ,GALLERY>
     <SCENE "zork1.gallery"
            "An underground art gallery with a painting on the wall.">)
    (<EQUAL? ,HERE ,STUDIO>
     <SCENE "zork1.studio"
            "A dusty studio with an owner's manual on the floor.">)
    ;"Maze"
    (<EQUAL? ,HERE ,MAZE-1>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-2>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-3>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-4>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-5>
     <SCENE "zork1.maze5"
            "A maze chamber littered with the remains of a previous explorer.">)
    (<EQUAL? ,HERE ,MAZE-6>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-7>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-8>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-9>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-10>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-11>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-12>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-13>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-14>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,MAZE-15>
     <SCENE "zork1.maze"
            "A maze of twisty little passages, all alike.">)
    (<EQUAL? ,HERE ,DEAD-END-1>
     <SCENE "zork1.dead-end"
            "A dead end in the maze.">)
    (<EQUAL? ,HERE ,DEAD-END-2>
     <SCENE "zork1.dead-end"
            "A dead end in the maze.">)
    (<EQUAL? ,HERE ,DEAD-END-3>
     <SCENE "zork1.dead-end"
            "A dead end in the maze.">)
    (<EQUAL? ,HERE ,DEAD-END-4>
     <SCENE "zork1.dead-end"
            "A dead end in the maze.">)
    (<EQUAL? ,HERE ,DEAD-END-5>
     <SCENE "zork1.dead-end"
            "A dead end in the mine.">)
    (<EQUAL? ,HERE ,GRATING-ROOM>
     <SCENE "zork1.grating-room"
            "A stone chamber below the grate, at the edge of a twisting maze.">)
    ;"Cyclops and treasure"
    (<EQUAL? ,HERE ,CYCLOPS-ROOM>
     <SCENE "zork1.cyclops-room"
            "A cavern occupied by a fearsome one-eyed cyclops.">)
    (<EQUAL? ,HERE ,TREASURE-ROOM>
     <SCENE "zork1.treasure-room"
            "A small vaulted chamber containing a silver chalice on a pedestal.">)
    ;"Mirror rooms and vicinity"
    (<EQUAL? ,HERE ,MIRROR-ROOM-1>
     <SCENE "zork1.mirror-room"
            "A room with mirrors on the walls and passages in several directions.">)
    (<EQUAL? ,HERE ,MIRROR-ROOM-2>
     <SCENE "zork1.mirror-room"
            "A room with mirrors on the walls and passages in several directions.">)
    (<EQUAL? ,HERE ,SMALL-CAVE>
     <SCENE "zork1.small-cave"
            "A tiny cave with entrances west and north, and a staircase leading down.">)
    (<EQUAL? ,HERE ,TINY-CAVE>
     <SCENE "zork1.tiny-cave"
            "A tiny cave with a dark, forbidding staircase leading down.">)
    (<EQUAL? ,HERE ,COLD-PASSAGE>
     <SCENE "zork1.cold-passage"
            "A cold and damp corridor where a long east-west passageway turns south.">)
    (<EQUAL? ,HERE ,NARROW-PASSAGE>
     <SCENE "zork1.narrow-passage"
            "A long and narrow corridor where a north-south passageway briefly narrows.">)
    (<EQUAL? ,HERE ,WINDING-PASSAGE>
     <SCENE "zork1.winding-passage"
            "A winding passage with exits east and north.">)
    (<EQUAL? ,HERE ,TWISTING-PASSAGE>
     <SCENE "zork1.twisting-passage"
            "A winding passage with exits east and north.">)
    (<EQUAL? ,HERE ,ATLANTIS-ROOM>
     <SCENE "zork1.atlantis-room"
            "An ancient room, long under water, with an exit south and staircase up.">)
    ;"Round room and vicinity"
    (<EQUAL? ,HERE ,EW-PASSAGE>
     <SCENE "zork1.ew-passage"
            "A narrow east-west passageway with a stairway leading down at the north end.">)
    (<EQUAL? ,HERE ,ROUND-ROOM>
     <SCENE "zork1.round-room"
            "A circular stone room with passages in several directions.">)
    (<EQUAL? ,HERE ,DEEP-CANYON>
     <SCENE "zork1.deep-canyon"
            "A deep canyon with passages in several directions.">)
    (<EQUAL? ,HERE ,DAMP-CAVE>
     <SCENE "zork1.damp-cave"
            "A cave with exits west and east, and a damp earth floor.">)
    (<EQUAL? ,HERE ,LOUD-ROOM>
     <SCENE "zork1.loud-room"
            "A thunderously loud cavern with a platinum bar on the floor.">)
    (<EQUAL? ,HERE ,NS-PASSAGE>
     <SCENE "zork1.ns-passage"
            "A high north-south passage that forks to the northeast.">)
    (<EQUAL? ,HERE ,CHASM-ROOM>
     <SCENE "zork1.chasm-room"
            "A chasm running southwest to northeast with a crack into a passage.">)
    (<EQUAL? ,HERE ,ENGRAVINGS-CAVE>
     <SCENE "zork1.engravings-cave"
            "A low cave with passages leading northwest and east.">)
    (<EQUAL? ,HERE ,DOME-ROOM>
     <SCENE "zork1.dome-room"
            "A dome room with a rope tied to the railing.">)
    (<EQUAL? ,HERE ,TORCH-ROOM>
     <SCENE "zork1.torch-room"
            "A small chamber with a pedestal holding a torch.">)
    ;"Temple and Egypt"
    (<EQUAL? ,HERE ,NORTH-TEMPLE>
     <SCENE "zork1.north-temple"
            "The antechamber of an ancient temple, with a brass bell and a prayer inscription.">)
    (<EQUAL? ,HERE ,SOUTH-TEMPLE>
     <SCENE "zork1.south-temple"
            "A solemn altar room with candles and a mysterious book.">)
    (<EQUAL? ,HERE ,EGYPT-ROOM>
     <SCENE "zork1.egypt-room"
            "An Egyptian-themed burial chamber with a gold coffin.">)
    ;"Hades"
    (<EQUAL? ,HERE ,ENTRANCE-TO-HADES>
     <SCENE "zork1.entrance-hades"
            "The eerie entrance to the land of the dead, shrouded in mist.">)
    (<EQUAL? ,HERE ,LAND-OF-LIVING-DEAD>
     <SCENE "zork1.land-dead"
            "A desolate realm where the dead wander, a crystal skull glimmers nearby.">)
    ;"Reservoir area"
    (<EQUAL? ,HERE ,RESERVOIR-SOUTH>
     <SCENE "zork1.reservoir-south"
            "The south side of an underground reservoir with water blocking the way north.">)
    (<EQUAL? ,HERE ,RESERVOIR>
     <SCENE "zork1.reservoir"
            "An underground reservoir with a trunk of jewels at the bottom.">)
    (<EQUAL? ,HERE ,RESERVOIR-NORTH>
     <SCENE "zork1.reservoir-north"
            "The north side of the reservoir with stairs leading up.">)
    (<EQUAL? ,HERE ,STREAM-VIEW>
     <SCENE "zork1.stream-view"
            "A path beside a gently flowing stream.">)
    (<EQUAL? ,HERE ,IN-STREAM>
     <SCENE "zork1.in-stream"
            "On a gently flowing stream with a narrow beach to land on.">)
    ;"Dam area"
    (<EQUAL? ,HERE ,DAM-ROOM>
     <SCENE "zork1.dam-room"
            "Flood Control Dam #3 with a control panel and bolt.">)
    (<EQUAL? ,HERE ,DAM-LOBBY>
     <SCENE "zork1.dam-lobby"
            "The entrance lobby to Flood Control Dam #3, with a tour guidebook.">)
    (<EQUAL? ,HERE ,MAINTENANCE-ROOM>
     <SCENE "zork1.maintenance-room"
            "A well-stocked maintenance room behind the dam.">)
    (<EQUAL? ,HERE ,MACHINE-ROOM>
     <SCENE "zork1.machine-room"
            "A strange room housing an unknown machine with a large switch.">)
    (<EQUAL? ,HERE ,DAM-BASE>
     <SCENE "zork1.dam-base"
            "The base of Flood Control Dam #3 with the Frigid River flowing by.">)
    ;"River and shore"
    (<EQUAL? ,HERE ,RIVER-1>
     <SCENE "zork1.river"
            "The Frigid River near the dam with a landing on the west shore.">)
    (<EQUAL? ,HERE ,RIVER-2>
     <SCENE "zork1.river"
            "The Frigid River turning a corner with White Cliffs on the east.">)
    (<EQUAL? ,HERE ,RIVER-3>
     <SCENE "zork1.river"
            "The Frigid River descending into a valley with a narrow beach below.">)
    (<EQUAL? ,HERE ,RIVER-4>
     <SCENE "zork1.river"
            "The Frigid River running faster with a sandy beach on the east shore.">)
    (<EQUAL? ,HERE ,RIVER-5>
     <SCENE "zork1.river"
            "The Frigid River with rushing water and a large landing area.">)
    (<EQUAL? ,HERE ,WHITE-CLIFFS-NORTH>
     <SCENE "zork1.white-cliffs"
            "A narrow strip of beach at the base of the White Cliffs.">)
    (<EQUAL? ,HERE ,WHITE-CLIFFS-SOUTH>
     <SCENE "zork1.white-cliffs"
            "A rocky, narrow strip of beach beside the Cliffs.">)
    (<EQUAL? ,HERE ,SHORE>
     <SCENE "zork1.shore"
            "The east shore of the river with a path traveling north to south.">)
    (<EQUAL? ,HERE ,SANDY-BEACH>
     <SCENE "zork1.sandy-beach"
            "A large sandy beach on the east shore of the river.">)
    (<EQUAL? ,HERE ,SANDY-CAVE>
     <SCENE "zork1.sandy-cave"
            "A sand-filled cave with an exit to the southwest.">)
    (<EQUAL? ,HERE ,ARAGAIN-FALLS>
     <SCENE "zork1.aragain-falls"
            "The base of Aragain Falls, where a rainbow sometimes appears.">)
    (<EQUAL? ,HERE ,ON-RAINBOW>
     <SCENE "zork1.on-rainbow"
            "On top of a rainbow with a magnificent view of the Falls.">)
    (<EQUAL? ,HERE ,END-OF-RAINBOW>
     <SCENE "zork1.end-of-rainbow"
            "A small, rocky beach on the continuation of the Frigid River past the Falls.">)
    ;"Coal mine"
    (<EQUAL? ,HERE ,MINE-ENTRANCE>
     <SCENE "zork1.mine-entrance"
            "The entrance of a coal mine with a shaft in the west wall.">)
    (<EQUAL? ,HERE ,SQUEEKY-ROOM>
     <SCENE "zork1.squeeky-room"
            "A small room with strange squeaky sounds from the north passage.">)
    (<EQUAL? ,HERE ,BAT-ROOM>
     <SCENE "zork1.bat-room"
            "A dark cavern filled with the squeaking of a vampire bat.">)
    (<EQUAL? ,HERE ,SHAFT-ROOM>
     <SCENE "zork1.shaft-room"
            "A large room with a small shaft descending through the floor.">)
    (<EQUAL? ,HERE ,SMELLY-ROOM>
     <SCENE "zork1.smelly-room"
            "A small nondescript room with a foul odor from a descending staircase.">)
    (<EQUAL? ,HERE ,GAS-ROOM>
     <SCENE "zork1.gas-room"
            "A small room smelling strongly of coal gas.">)
    (<EQUAL? ,HERE ,LADDER-TOP>
     <SCENE "zork1.ladder-top"
            "A very small room with a rickety wooden ladder leading downward.">)
    (<EQUAL? ,HERE ,LADDER-BOTTOM>
     <SCENE "zork1.ladder-bottom"
            "A rather wide room with the bottom of a narrow wooden ladder.">)
    (<EQUAL? ,HERE ,TIMBER-ROOM>
     <SCENE "zork1.timber-room"
            "A long and narrow passage cluttered with broken timbers.">)
    (<EQUAL? ,HERE ,LOWER-SHAFT>
     <SCENE "zork1.lower-shaft"
            "A small drafty room with the bottom of a long shaft.">)
    (<EQUAL? ,HERE ,MINE-1>
     <SCENE "zork1.coal-mine"
            "A nondescript part of a coal mine.">)
    (<EQUAL? ,HERE ,MINE-2>
     <SCENE "zork1.coal-mine"
            "A nondescript part of a coal mine.">)
    (<EQUAL? ,HERE ,MINE-3>
     <SCENE "zork1.coal-mine"
            "A nondescript part of a coal mine.">)
    (<EQUAL? ,HERE ,MINE-4>
     <SCENE "zork1.coal-mine"
            "A nondescript part of a coal mine.">)
    (<EQUAL? ,HERE ,SLIDE-ROOM>
     <SCENE "zork1.slide-room"
            "A small chamber with a steep metal slide twisting downward.">)>
