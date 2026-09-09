;"State-aware intent cards for The Limehouse Killings.

  This file adds a curated choice layer over the Victorian murder mystery.
  Labels describe narrative intentions; commands are ordinary parser input.
  The runtime evaluates SUGGEST-ACTIONS only while the game is waiting at READ."

;" NOTE: SUGGEST-ACTIONS and SUGGEST-SCENE must be defined after all
  room-specific helper routines because the ZIL-to-Lua compiler produces
  local functions, which cannot be forward-referenced. "

;" === Gate === "

<ROUTINE SUGGEST-GATE ()
  <COND
    (<IN? ,TELEGRAM ,ASHWORTH-MANOR-GATE>
     <CHOICE "gate.read-telegram"
             "Read the creased telegram"
             "read telegram"
             ,CHOICE-INVESTIGATE
             100>
     <CHOICE-DETAILS "subject" ,TELEGRAM
                     "once" T
                     "learns" "telegram.read">)
    (<NOT ,STUDY-UNLOCKED>
     <CHOICE "gate.enter-manor"
             "Follow the gravel path to Ashworth Manor"
             "north"
             ,CHOICE-PROGRESS
             95>
     <CHOICE-DETAILS "group" "move">)
    (T
     <CHOICE "gate.return-manor"
             "Return to Ashworth Manor"
             "north"
             ,CHOICE-RETURN
             70>
     <CHOICE-DETAILS "group" "move">)>

  <CHOICE "gate.examine-fog"
          "Listen to the river sounds beyond the fog"
          "listen"
          ,CHOICE-INVESTIGATE
          40>

  <CHOICE "gate.examine-gates"
          "Examine the iron gates"
          "examine gates"
          ,CHOICE-INVESTIGATE
          35>>


;" === Entrance Hall === "

<ROUTINE SUGGEST-HALL-ACT1 ()
  ;"Study door is locked. Player needs the key or the library cipher."
  <CHOICE "hall.try-study-door"
          "Try the study door to the north"
          "north"
          ,CHOICE-INVESTIGATE
          90>
  <CHOICE-DETAILS "once" T
                  "learns" "study-door.locked">

  <CHOICE "hall.go-library"
          "Step into the library to the east"
          "east"
          ,CHOICE-PROGRESS
          95>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.go-dining"
          "Enter the dining room to the west"
          "west"
          ,CHOICE-PROGRESS
          85>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.take-magnifier"
          "Take the magnifying glass from the hall table"
          "take magnifying glass"
          ,CHOICE-INVESTIGATE
          80>
  <CHOICE-DETAILS "subject" ,MAGNIFYING-GLASS
                  "once" T
                  "group" "scene">

  <CHOICE "hall.go-kitchen"
          "Go down the stairs to the kitchen"
          "down"
          ,CHOICE-PROGRESS
          75>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.go-gate"
          "Step back out to the iron gate"
          "south"
          ,CHOICE-RETURN
          40>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.examine-portraits"
          "Examine the family portraits on the walls"
          "examine portraits"
          ,CHOICE-INTERACT
          35>

  <CHOICE "hall.pull-bell-wire"
          "Pull the servant-bell wire"
          "pull bell wire"
          ,CHOICE-EXPERIMENT
          30>>

<ROUTINE SUGGEST-HALL-STUDY-OPEN ()
  ;"Study door is open but may not have been entered yet."
  <CHOICE "hall.enter-study"
          "Step through the open study door"
          "north"
          ,CHOICE-PROGRESS
          95>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.go-library"
          "Step into the library to the east"
          "east"
          ,CHOICE-PROGRESS
          85>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.go-dining"
          "Enter the dining room to the west"
          "west"
          ,CHOICE-PROGRESS
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.go-kitchen"
          "Go down the stairs to the kitchen"
          "down"
          ,CHOICE-PROGRESS
          75>
  <CHOICE-DETAILS "group" "move">

  <COND
    (<NOT <IN? ,MAGNIFYING-GLASS ,WINNER>>
     <CHOICE "hall.take-magnifier"
             "Take the magnifying glass from the hall table"
             "take magnifying glass"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE-DETAILS "subject" ,MAGNIFYING-GLASS
                     "once" T>)>

  <CHOICE "hall.go-gate"
          "Step back out to the iron gate"
          "south"
          ,CHOICE-RETURN
          40>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-HALL-ACT2 ()
  ;"Cipher solved. Bell wire quivers. Focus shifts to evidence gathering."
  <CHOICE "hall.enter-study"
          "Step through the open study door"
          "north"
          ,CHOICE-PROGRESS
          90>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.go-library"
          "Return to the library"
          "east"
          ,CHOICE-RETURN
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.go-dining"
          "Visit the dining room"
          "west"
          ,CHOICE-RETURN
          75>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.go-kitchen"
          "Go down to the kitchen"
          "down"
          ,CHOICE-RETURN
          70>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.pull-bell-wire"
          "Pull the servant-bell wire"
          "pull bell wire"
          ,CHOICE-EXPERIMENT
          45>

  <CHOICE "hall.examine-bell-wire"
          "Examine the servant-bell wire"
          "examine bell wire"
          ,CHOICE-INVESTIGATE
          40>>

<ROUTINE SUGGEST-HALL-ACT3 ()
  ;"Lestrade and Moriarty present. Time to present the case."
  <COND
    (<AND <NOT ,LETTER-PRESENTED>
          <IN? ,DEAD-LETTER ,WINNER>>
     <CHOICE "hall.show-letter-lestrade"
             "Show the unsent letter to Inspector Lestrade"
             "show dead-letter to inspector"
             ,CHOICE-PROGRESS
             110>
     <CHOICE-DETAILS "subject" ,INSPECTOR>)
    (<AND <NOT ,POISON-PRESENTED>
          <IN? ,POISON-BOTTLE ,WINNER>
          ,POISON-IDENTIFIED>
     <CHOICE "hall.show-bottle-lestrade"
             "Show the poison bottle to Inspector Lestrade"
             "show poison-bottle to inspector"
             ,CHOICE-PROGRESS
             110>
     <CHOICE-DETAILS "subject" ,INSPECTOR>)
    (<AND <NOT ,MOTIVE-PRESENTED>
          <IN? ,BANK-STATEMENT ,WINNER>>
     <CHOICE "hall.show-statement-lestrade"
             "Show the bank statement to Inspector Lestrade"
             "show bank-statement to inspector"
             ,CHOICE-PROGRESS
             110>
     <CHOICE-DETAILS "subject" ,INSPECTOR>)>

  <COND
    (<AND ,LETTER-PRESENTED ,POISON-PRESENTED ,MOTIVE-PRESENTED
          <NOT ,KILLER-ACCUSED>>
     <CHOICE "hall.accuse-moriarty"
             "Accuse Dr. Moriarty of the murder"
             "accuse moriarty"
             ,CHOICE-PROGRESS
             120>
     <CHOICE-DETAILS "subject" ,DR-MORIARTY>)>

  <CHOICE "hall.ask-lestrade-case"
          "Ask Inspector Lestrade about the case"
          "ask inspector about case"
          ,CHOICE-INVESTIGATE
          85>
  <CHOICE-DETAILS "subject" ,INSPECTOR>

  <CHOICE "hall.examine-lestrade"
          "Examine Inspector Lestrade"
          "examine inspector"
          ,CHOICE-INVESTIGATE
          70>
  <CHOICE-DETAILS "subject" ,INSPECTOR>

  <CHOICE "hall.examine-moriarty"
          "Examine Dr. Moriarty"
          "examine moriarty"
          ,CHOICE-INVESTIGATE
          70>
  <CHOICE-DETAILS "subject" ,DR-MORIARTY>

  <CHOICE "hall.go-study"
          "Go to the study"
          "south"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "hall.go-dining"
          "Visit the dining room"
          "west"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-ENTRANCE-HALL ()
  <COND
    ;"Act III: Inspector and Moriarty present"
    (<==? ,CASE-ACT 3>
     <SUGGEST-HALL-ACT3>)
    ;"Act II: cipher solved, passage open"
    (<==? ,CASE-ACT 2>
     <SUGGEST-HALL-ACT2>)
    ;"Act I: study door locked"
    (<NOT ,STUDY-UNLOCKED>
     <SUGGEST-HALL-ACT1>)
    ;"Act I: study door unlocked but not yet entered"
    (T
     <SUGGEST-HALL-STUDY-OPEN>)>>


;" === Study === "

<ROUTINE SUGGEST-STUDY-EXPLORE ()
  <COND
    (<NOT ,DEAD-LETTER-FOUND>
     <CHOICE "study.take-letter"
             "Take the unsent letter from the desk"
             "take dead-letter"
             ,CHOICE-PROGRESS
             100>
     <CHOICE-DETAILS "subject" ,DEAD-LETTER
                     "once" T
                     "learns" "letter.threat">)
    (<NOT <IN? ,DEAD-LETTER ,WINNER>>
     <CHOICE "study.take-letter"
             "Take the unsent letter from the desk"
             "take dead-letter"
             ,CHOICE-PROGRESS
             95>
     <CHOICE-DETAILS "subject" ,DEAD-LETTER>)>

  <COND
    (<NOT ,POISON-BOTTLE-FOUND>
     <CHOICE "study.take-poison"
             "Take the poison bottle from the mantelpiece"
             "take poison-bottle"
             ,CHOICE-PROGRESS
             95>
     <CHOICE-DETAILS "subject" ,POISON-BOTTLE
                     "once" T>)
    (<NOT <IN? ,POISON-BOTTLE ,WINNER>>
     <CHOICE "study.take-poison"
             "Take the poison bottle from the mantelpiece"
             "take poison-bottle"
             ,CHOICE-PROGRESS
             90>
     <CHOICE-DETAILS "subject" ,POISON-BOTTLE>)>

  <CHOICE "study.examine-box"
          "Examine the locked box in the fireplace"
          "examine locked-box"
          ,CHOICE-INVESTIGATE
          90>
  <CHOICE-DETAILS "subject" ,LOCKED-BOX
                  "once" T>

  <CHOICE "study.examine-chalk"
          "Look closely at the chalk outline"
          "examine chalk-outline"
          ,CHOICE-INVESTIGATE
          70>

  <CHOICE "study.examine-desk"
          "Examine the mahogany desk"
          "examine desk"
          ,CHOICE-INVESTIGATE
          65>
  <CHOICE-DETAILS "subject" ,DESK>

  <CHOICE "study.examine-window"
          "Examine the window looking out to the garden"
          "examine window"
          ,CHOICE-INVESTIGATE
          60>
  <CHOICE-DETAILS "subject" ,WINDOW>

  <CHOICE "study.go-hall"
          "Return to the entrance hall"
          "south"
          ,CHOICE-RETURN
          75>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-STUDY-BOX ()
  ;"Box not opened yet. Guide toward prerequisites."
  <SUGGEST-STUDY-EXPLORE>

  <COND
    (<AND <NOT <KNOWS? "box.moriarty-connected">>
          ,DEAD-LETTER-FOUND ,POISON-IDENTIFIED ,SECRET-LEDGER-FOUND>
     <CHOICE "study.turn-box-moriarty"
             "Turn the name dial to MORIARTY"
             "turn locked box to moriarty"
             ,CHOICE-PROGRESS
             110>
     <CHOICE-DETAILS "subject" ,LOCKED-BOX>)
    (<AND <NOT ,DEAD-LETTER-FOUND>>
     <CHOICE "study.read-letter"
             "Read the unsent letter"
             "read dead-letter"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE-DETAILS "subject" ,DEAD-LETTER>)
    (<AND ,DEAD-LETTER-FOUND
          <NOT ,POISON-IDENTIFIED>>
     <CHOICE "study.open-door-before-nav"
             "Open the study door to reach the entrance hall"
             "open study door"
             ,CHOICE-PROGRESS
             85>
     <CHOICE-DETAILS "group" "move">)
    (<AND ,DEAD-LETTER-FOUND
          ,POISON-IDENTIFIED
          <NOT ,SECRET-LEDGER-FOUND>>
     <CHOICE "study.open-door-before-nav"
             "Open the study door to reach the entrance hall"
             "open study door"
             ,CHOICE-PROGRESS
             85>
     <CHOICE-DETAILS "group" "move">)>

  <CHOICE "study.go-hall"
          "Return to the entrance hall"
          "south"
          ,CHOICE-RETURN
          50>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "study.try-window"
          "Try the window latch"
          "open window"
          ,CHOICE-EXPERIMENT
          40>
  <CHOICE-DETAILS "subject" ,WINDOW>

  <CHOICE "study.smell-room"
          "Listen to the quiet of the sealed room"
          "listen"
          ,CHOICE-INTERACT
          30>>

<ROUTINE SUGGEST-STUDY-COMPLETE ()
  ;"All study evidence collected. Focus on the hall and accusation."
  <CHOICE "study.go-hall"
          "Return to the entrance hall with your evidence"
          "south"
          ,CHOICE-PROGRESS
          95>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "study.re-examine-letter"
          "Re-read the unsent letter"
          "read dead-letter"
          ,CHOICE-INVESTIGATE
          60>
  <CHOICE-DETAILS "subject" ,DEAD-LETTER>

  <CHOICE "study.re-examine-statement"
          "Re-read the bank statement"
          "read bank-statement"
          ,CHOICE-INVESTIGATE
          55>
  <CHOICE-DETAILS "subject" ,BANK-STATEMENT>>

<ROUTINE SUGGEST-STUDY ()
  <COND
    ;"All evidence gathered and box opened"
    (<AND ,LOCKED-BOX-OPENED ,DEAD-LETTER-FOUND ,POISON-BOTTLE-FOUND>
     <SUGGEST-STUDY-COMPLETE>)
    ;"Box not yet opened - need letter + poison + ledger"
    (<NOT ,LOCKED-BOX-OPENED>
     <SUGGEST-STUDY-BOX>)
    ;"Partial progress"
    (T
     <SUGGEST-STUDY-EXPLORE>)>>


;" === Library === "

<ROUTINE SUGGEST-LIBRARY-ACT1 ()
  <COND
    (<NOT <IN? ,TORN-PAGE ,WINNER>>
     <CHOICE "lib.take-torn-page"
             "Take the torn page from the reading desk"
             "take torn-page"
             ,CHOICE-PROGRESS
             100>
     <CHOICE-DETAILS "subject" ,TORN-PAGE
                     "once" T>)
    (<NOT <KNOWS? "cipher.rainbow-order">>
     <CHOICE "lib.read-torn-page"
             "Read the torn page"
             "read torn-page"
             ,CHOICE-INVESTIGATE
             95>
     <CHOICE-DETAILS "subject" ,TORN-PAGE
                     "once" T
                     "learns" "cipher.rainbow-order">)>

  <COND
    (<NOT ,CIPHER-SOLVED>
     <CHOICE "lib.examine-markers"
             "Examine the colored markers on the shelves"
             "examine colored-markers"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE-DETAILS "subject" ,COLORED-MARKERS
                     "once" T>)>

  <COND
    (<NOT <IN? ,SECRET-LEDGER ,WINNER>>
     <CHOICE "lib.take-ledger"
             "Take the secret ledger from the reading desk"
             "take secret-ledger"
             ,CHOICE-PROGRESS
             90>
     <CHOICE-DETAILS "subject" ,SECRET-LEDGER
                     "once" T
                     "learns" "ledger.moriarty-debt">)>

  <COND
    (<IN? ,DR-MORIARTY ,LIBRARY>
     <CHOICE "lib.ask-moriarty-experiments"
             "Ask Dr. Moriarty about his experiments"
             "ask moriarty about experiments"
             ,CHOICE-INTERACT
             80>
     <CHOICE-DETAILS "subject" ,DR-MORIARTY>
     <CHOICE "lib.ask-moriarty-poison"
             "Ask Dr. Moriarty about poison"
             "ask moriarty about poison"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE-DETAILS "subject" ,DR-MORIARTY>)>

  <COND
    (<NOT ,CIPHER-SOLVED>
      <CHOICE "lib.push-red"
              "Push the red-marked book"
              "push red book"
              ,CHOICE-EXPERIMENT
              75>
      <CHOICE-DETAILS "subject" ,RED-BOOK>
      <CHOICE "lib.push-yellow"
              "Push the yellow-marked book"
              "push yellow book"
              ,CHOICE-EXPERIMENT
              73>
      <CHOICE-DETAILS "subject" ,YELLOW-BOOK>
      <CHOICE "lib.push-green"
              "Push the green-marked book"
              "push green book"
              ,CHOICE-EXPERIMENT
              72>
      <CHOICE-DETAILS "subject" ,GREEN-BOOK>
      <CHOICE "lib.push-blue"
              "Push the blue-marked book"
              "push blue book"
              ,CHOICE-EXPERIMENT
              70>
      <CHOICE-DETAILS "subject" ,BLUE-BOOK>)>

  <CHOICE "lib.examine-bookshelf"
          "Examine the bookshelf arrangement"
          "examine bookshelf"
          ,CHOICE-INVESTIGATE
          65>
  <CHOICE-DETAILS "subject" ,BOOKSHELF>

  <CHOICE "lib.go-hall"
          "Return to the entrance hall"
          "west"
          ,CHOICE-RETURN
          55>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-LIBRARY-ACT2 ()
  ;"Cipher solved. Passage open. Focus on evidence and navigation."
  <CHOICE "lib.enter-passage"
          "Step through the opened bookshelf into the secret passage"
          "east"
          ,CHOICE-PROGRESS
          100>
  <CHOICE-DETAILS "group" "move">

  <COND
    (<NOT <IN? ,SECRET-LEDGER ,WINNER>>
     <CHOICE "lib.take-ledger"
             "Take the secret ledger"
             "take secret-ledger"
             ,CHOICE-PROGRESS
             90>
     <CHOICE-DETAILS "subject" ,SECRET-LEDGER
                     "once" T>)>

  <CHOICE "lib.go-hall"
          "Return to the entrance hall"
          "west"
          ,CHOICE-RETURN
          70>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-LIBRARY ()
  <COND
    ;"Act II+: cipher solved"
    (<==? ,CASE-ACT 2>
     <SUGGEST-LIBRARY-ACT2>)
    ;"Act I: cipher unsolved"
    (T
     <SUGGEST-LIBRARY-ACT1>)>>


;" === Dining Room === "

<ROUTINE SUGGEST-DINING-ACT12 ()
  <COND
    (<NOT <IN? ,WAX-SEAL ,WINNER>>
     <CHOICE "dining.take-seal"
             "Take the crimson wax seal from the table"
             "take wax-seal"
             ,CHOICE-PROGRESS
             90>
     <CHOICE-DETAILS "subject" ,WAX-SEAL
                     "once" T>)>

  <CHOICE "dining.ask-lady-marriage"
          "Ask Lady Ashworth about her marriage"
          "ask lady about marriage"
          ,CHOICE-INTERACT
          85>
  <CHOICE-DETAILS "subject" ,LADY-ASHWORTH>

  <CHOICE "dining.ask-lady-alibi"
          "Ask Lady Ashworth about her alibi"
          "ask lady about alibi"
          ,CHOICE-INVESTIGATE
          90>
  <CHOICE-DETAILS "subject" ,LADY-ASHWORTH
                  "learns" "lady.alibi">

  <COND
    (<IN? ,DEAD-LETTER ,WINNER>
     <CHOICE "dining.show-letter-lady"
             "Show the unsent letter to Lady Ashworth"
             "show dead-letter to lady"
             ,CHOICE-PROGRESS
             85>
     <CHOICE-DETAILS "subject" ,LADY-ASHWORTH>)>

  <CHOICE "dining.examine-cabinet"
          "Examine the wine cabinet"
          "examine wine cabinet"
          ,CHOICE-INVESTIGATE
          70>
  <CHOICE-DETAILS "subject" ,WINE-CABINET
                  "once" T>

  <CHOICE "dining.examine-table"
          "Examine the dining table"
          "examine table"
          ,CHOICE-INVESTIGATE
          60>
  <CHOICE-DETAILS "subject" ,TABLE>

  <CHOICE "dining.go-pantry"
          "Step into the pantry to the north"
          "north"
          ,CHOICE-PROGRESS
          75>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "dining.go-hall"
          "Return to the entrance hall"
          "east"
          ,CHOICE-RETURN
          65>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-DINING-ACT3 ()
  <CHOICE "dining.ask-lady-alibi"
          "Ask Lady Ashworth about her alibi"
          "ask lady about alibi"
          ,CHOICE-INVESTIGATE
          85>
  <CHOICE-DETAILS "subject" ,LADY-ASHWORTH>

  <COND
    (<IN? ,DEAD-LETTER ,WINNER>
     <CHOICE "dining.show-letter-lady"
             "Show the unsent letter to Lady Ashworth"
             "show dead-letter to lady"
             ,CHOICE-PROGRESS
             85>
     <CHOICE-DETAILS "subject" ,LADY-ASHWORTH>)>

  <CHOICE "dining.examine-lady"
          "Examine Lady Ashworth"
          "examine lady"
          ,CHOICE-INVESTIGATE
          70>
  <CHOICE-DETAILS "subject" ,LADY-ASHWORTH>

  <CHOICE "dining.go-hall"
          "Return to the entrance hall"
          "east"
          ,CHOICE-RETURN
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "dining.go-pantry"
          "Check the pantry"
          "north"
          ,CHOICE-RETURN
          60>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-DINING-ROOM ()
  <COND
    (<==? ,CASE-ACT 3>
     <SUGGEST-DINING-ACT3>)
    (T
     <SUGGEST-DINING-ACT12>)>>


;" === Kitchen === "

<ROUTINE SUGGEST-KITCHEN ()
  <COND
    (<NOT <FSET? ,DRAWER ,OPENBIT>>
     <CHOICE "kitchen.open-drawer"
             "Open the drawer in the counter"
             "open drawer"
             ,CHOICE-INVESTIGATE
             95>
     <CHOICE-DETAILS "subject" ,DRAWER
                     "once" T>)
    (<NOT <IN? ,LOCKPICK-SET ,WINNER>>
     <CHOICE "kitchen.take-lockpicks"
             "Take the lockpick set from the leather roll"
             "take lockpick set"
             ,CHOICE-PROGRESS
             100>
     <CHOICE-DETAILS "subject" ,LOCKPICK-SET
                     "once" T>)>

  <CHOICE "kitchen.examine-kettle"
          "Examine the blue kettle"
          "examine kettle"
          ,CHOICE-INTERACT
          65>
  <CHOICE-DETAILS "subject" ,KETTLE>

  <CHOICE "kitchen.pull-bell"
          "Pull the servant bell rope"
          "pull servant bell"
          ,CHOICE-EXPERIMENT
          55>
  <CHOICE-DETAILS "subject" ,SERVANT-BELL>

  <CHOICE "kitchen.go-garden"
          "Step out to the garden"
          "west"
          ,CHOICE-PROGRESS
          85>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "kitchen.go-hall"
          "Climb back up to the entrance hall"
          "up"
          ,CHOICE-RETURN
          70>
  <CHOICE-DETAILS "group" "move">>


;" === Garden === "

<ROUTINE SUGGEST-GARDEN ()
  <COND
    (<NOT ,KNIFE-FOUND>
     <CHOICE "garden.examine-hedges"
             "Look closely at the hedges"
             "examine hedges"
             ,CHOICE-INVESTIGATE
             90>
     <CHOICE-DETAILS "subject" ,HEDGES
                     "once" T
                     "learns" "knife.in-hedges">)
    (<NOT <IN? ,BLOOD-STAINED-KNIFE ,WINNER>>
     <CHOICE "garden.take-knife"
             "Take the blood-stained knife"
             "take blood-stained-knife"
             ,CHOICE-PROGRESS
             95>
     <CHOICE-DETAILS "subject" ,BLOOD-STAINED-KNIFE>)>

  <COND
    (<NOT <IN? ,FOOTPRINT-CAST ,WINNER>>
     <CHOICE "garden.take-cast"
             "Take the footprint cast from near the fountain"
             "take footprint cast"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE-DETAILS "subject" ,FOOTPRINT-CAST
                     "once" T>)>

  <COND
    (<IN? ,FOOTPRINT-CAST ,WINNER>
     <COND
       (<IN? ,MAGNIFYING-GLASS ,WINNER>
        <CHOICE "garden.use-magnifier-cast"
                "Use the magnifying glass on the footprint cast"
                "use magnifying glass on footprint cast"
                ,CHOICE-PROGRESS
                90>
        <CHOICE-DETAILS "subject" ,FOOTPRINT-CAST>)>)>

  <CHOICE "garden.examine-fountain"
          "Examine the dry fountain"
          "examine fountain"
          ,CHOICE-INVESTIGATE
          60>
  <CHOICE-DETAILS "subject" ,FOUNTAIN>

  <CHOICE "garden.smell"
          "Listen to the rain on leaves"
          "listen"
          ,CHOICE-INTERACT
          35>

  <CHOICE "garden.go-greenhouse"
          "Step into the greenhouse to the north"
          "north"
          ,CHOICE-PROGRESS
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "garden.go-servants"
          "Visit the servants' quarters to the south"
          "south"
          ,CHOICE-PROGRESS
          75>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "garden.go-kitchen"
          "Go back inside to the kitchen"
          "east"
          ,CHOICE-RETURN
          70>
  <CHOICE-DETAILS "group" "move">>


;" === Greenhouse === "

<ROUTINE SUGGEST-GREENHOUSE ()
  <COND
    (<AND <IN? ,POISON-BOTTLE ,WINNER>
          <NOT ,POISON-IDENTIFIED>>
     <CHOICE "gh.identify-poison"
             "Compare the poison bottle with the wolfsbane plants"
             "use poison-bottle on plants"
             ,CHOICE-PROGRESS
             110>
     <CHOICE-DETAILS "subject" ,PLANTS
                     "once" T
                     "learns" "poison.greenhouse-source">)>

  <CHOICE "gh.examine-plants"
          "Examine the exotic plants"
          "examine plants"
          ,CHOICE-INVESTIGATE
          80>
  <CHOICE-DETAILS "subject" ,PLANTS>

  <CHOICE "gh.examine-labels"
          "Read the plant labels"
          "examine labels"
          ,CHOICE-INVESTIGATE
          85>
  <CHOICE-DETAILS "subject" ,LABELS
                  "once" T>

  <CHOICE "gh.smell-plants"
          "Smell the greenhouse air"
          "smell"
          ,CHOICE-INTERACT
          40>

  <CHOICE "gh.go-garden"
          "Return to the garden"
          "south"
          ,CHOICE-RETURN
          70>
  <CHOICE-DETAILS "group" "move">>


;" === Servants' Quarters === "

<ROUTINE SUGGEST-SERVANTS-QUARTERS ()
  <CHOICE "sq.ask-hudson-master"
          "Ask Mr. Hudson about Lord Ashworth"
          "ask hudson about master"
          ,CHOICE-INTERACT
          85>
  <CHOICE-DETAILS "subject" ,MR-HUDSON>

  <CHOICE "sq.ask-hudson-alibi"
          "Ask Mr. Hudson about his alibi"
          "ask hudson about alibi"
          ,CHOICE-INVESTIGATE
          90>
  <CHOICE-DETAILS "subject" ,MR-HUDSON
                  "learns" "hudson.alibi">

  <CHOICE "sq.ask-hudson-key"
          "Ask Mr. Hudson about the study key"
          "ask hudson about key"
          ,CHOICE-PROGRESS
          95>
  <CHOICE-DETAILS "subject" ,MR-HUDSON
                  "once" T
                  "learns" "hudson.has-key">

  <COND
    (<NOT ,HUDSON-INTERVIEWED>
     <CHOICE "sq.ask-hudson-moriarty"
             "Ask Mr. Hudson about Dr. Moriarty"
             "ask hudson about moriarty"
             ,CHOICE-INVESTIGATE
             80>
     <CHOICE-DETAILS "subject" ,MR-HUDSON>)>

  <COND
    (<IN? ,DEAD-LETTER ,WINNER>
     <CHOICE "sq.show-letter-hudson"
             "Show the unsent letter to Mr. Hudson"
             "show dead-letter to hudson"
             ,CHOICE-PROGRESS
             85>
     <CHOICE-DETAILS "subject" ,MR-HUDSON>)>

  <CHOICE "sq.examine-trunk"
          "Examine the wooden trunk"
          "examine trunk"
          ,CHOICE-INVESTIGATE
          70>
  <CHOICE-DETAILS "subject" ,TRUNK>

  <COND
    (<IN? ,TRUNK-LETTER ,TRUNK>
     <CHOICE "sq.take-trunk-letter"
             "Take the folded note from the trunk"
             "take trunk-letter"
             ,CHOICE-INVESTIGATE
             75>
     <CHOICE-DETAILS "subject" ,TRUNK-LETTER>)>

  <COND
    (<NOT <IN? ,LANTERN ,WINNER>>
     <CHOICE "sq.take-lantern"
             "Take the oil lantern"
             "take lantern"
             ,CHOICE-INVESTIGATE
             65>
     <CHOICE-DETAILS "subject" ,LANTERN
                     "once" T>)>

  <CHOICE "sq.examine-hudson"
          "Examine Mr. Hudson"
          "examine hudson"
          ,CHOICE-INTERACT
          60>
  <CHOICE-DETAILS "subject" ,MR-HUDSON>

  <CHOICE "sq.go-garden"
          "Return to the garden"
          "north"
          ,CHOICE-RETURN
          70>
  <CHOICE-DETAILS "group" "move">>


;" === Secret Passage === "

<ROUTINE SUGGEST-SECRET-PASSAGE ()
  <CHOICE "sp.go-study"
          "Follow the passage east to the study"
          "east"
          ,CHOICE-PROGRESS
          100>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "sp.go-library"
          "Return west to the library"
          "west"
          ,CHOICE-RETURN
          80>
  <CHOICE-DETAILS "group" "move">

  <CHOICE "sp.examine-walls"
          "Examine the wet stone walls"
          "examine stone walls"
          ,CHOICE-INVESTIGATE
          50>
  <CHOICE-DETAILS "subject" ,STONE-WALLS>

  <CHOICE "sp.smell"
          "Listen to the passage"
          "listen"
          ,CHOICE-INTERACT
          35>>


;" === Pantry === "

<ROUTINE SUGGEST-PANTRY ()
  <COND
    (<NOT <IN? ,FOXGLOVE ,WINNER>>
     <CHOICE "pantry.take-foxglove"
             "Take the foxglove"
             "take foxglove"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE-DETAILS "subject" ,FOXGLOVE
                     "once" T>)>

  <COND
    (<NOT <IN? ,CHARCOAL ,WINNER>>
     <CHOICE "pantry.take-charcoal"
             "Take the powdered charcoal"
             "take charcoal"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE-DETAILS "subject" ,CHARCOAL
                     "once" T>)>

  <CHOICE "pantry.examine-shelves"
          "Examine the pantry shelves"
          "examine shelves"
          ,CHOICE-INVESTIGATE
          65>
  <CHOICE-DETAILS "subject" ,SHELVES>

  <CHOICE "pantry.go-dining"
          "Return to the dining room"
          "south"
          ,CHOICE-RETURN
          80>
  <CHOICE-DETAILS "group" "move">>


;" === Generic fallback === "

<ROUTINE SUGGEST-GENERIC ()
  <CHOICE "generic.look"
          "Look around"
          "look"
          ,CHOICE-INVESTIGATE
          50>
  <CHOICE "generic.inventory"
          "Check what you are carrying"
          "inventory"
          ,CHOICE-INVESTIGATE
          45>
  <CHOICE "generic.hints"
          "Ask for a hint"
          "hints"
          ,CHOICE-INVESTIGATE
          40>>


;" === Entry routines (must come after all helpers) === "

<ROUTINE SUGGEST-ACTIONS ()
  <COND
    (<EQUAL? ,HERE ,ASHWORTH-MANOR-GATE>
     <SUGGEST-GATE>)
    (<EQUAL? ,HERE ,ASHWORTH-ENTRANCE-HALL>
     <SUGGEST-ENTRANCE-HALL>)
    (<EQUAL? ,HERE ,STUDY>
     <SUGGEST-STUDY>)
    (<EQUAL? ,HERE ,LIBRARY>
     <SUGGEST-LIBRARY>)
    (<EQUAL? ,HERE ,DINING-ROOM>
     <SUGGEST-DINING-ROOM>)
    (<EQUAL? ,HERE ,KITCHEN>
     <SUGGEST-KITCHEN>)
    (<EQUAL? ,HERE ,GARDEN>
     <SUGGEST-GARDEN>)
    (<EQUAL? ,HERE ,GREENHOUSE>
     <SUGGEST-GREENHOUSE>)
    (<EQUAL? ,HERE ,SERVANTS-QUARTERS>
     <SUGGEST-SERVANTS-QUARTERS>)
    (<EQUAL? ,HERE ,SECRET-PASSAGE>
     <SUGGEST-SECRET-PASSAGE>)
    (<EQUAL? ,HERE ,PANTRY>
     <SUGGEST-PANTRY>)
    (T
     <SUGGEST-GENERIC>)>>

<ROUTINE SUGGEST-SCENE ()
  <COND
    (<EQUAL? ,HERE ,ASHWORTH-MANOR-GATE>
     <SCENE "gate.arrival"
            "Wet iron bars divide the river fog into pale strips. A gravel path leads north toward the manor.">)
    (<EQUAL? ,HERE ,ASHWORTH-ENTRANCE-HALL>
     <COND
       (<==? ,CASE-ACT 3>
        <SCENE "hall.confrontation"
               "The entrance hall holds Inspector Lestrade beneath the chandelier, notebook open. Dr. Moriarty watches the fog near the front door.">)
       (<FSET? ,STUDY-DOOR ,OPENBIT>
        <SCENE "hall.study-open"
               "The entrance hall, dust-softened chandelier above. The study door to the north stands open.">)
       (T
        <SCENE "hall.hub"
               "The entrance hall, chandelier crystals dulled by dust. Doorways branch in every direction.">)>)
    (<EQUAL? ,HERE ,STUDY>
     <COND
       (,LOCKED-BOX-OPENED
        <SCENE "study.box-open"
               "The locked room, chalk outline on the carpet. The fireplace box lies open among the ashes.">)
       (T
        <SCENE "study.crime-scene"
               "A chalk outline marks where Lord Ashworth fell. Cold ash grits beneath your shoes.">)>)
    (<EQUAL? ,HERE ,LIBRARY>
     <COND
       (,CIPHER-SOLVED
        <SCENE "library.passage-open"
               "Floor-to-ceiling bookshelves line the walls. The shifted bookcase exposes a stone passage east.">)
       (T
        <SCENE "library.cipher"
               "Lamplight climbs the shelves. Colored ribbons dot the spines, suggesting a hidden pattern.">)>)
    (<EQUAL? ,HERE ,DINING-ROOM>
     <SCENE "dining.interrupted"
            "Two places set at the long table, a skin forming over the soup. Candlelight preserves a dinner interrupted.">)
    (<EQUAL? ,HERE ,KITCHEN>
     <SCENE "kitchen.kettle"
            "The kettle's small thread of steam is the first warm thing you have seen in the house.">)
    (<EQUAL? ,HERE ,GARDEN>
     <SCENE "garden.evidence"
            "Rain beads along overgrown hedges. A dry stone fountain stands at the center.">)
    (<EQUAL? ,HERE ,GREENHOUSE>
     <SCENE "greenhouse.wolfsbane"
            "Purple wolfsbane flowers rise above the potting bench. Humidity beads on every glass pane.">)
    (<EQUAL? ,HERE ,SERVANTS-QUARTERS>
     <SCENE "servants.hudson"
            "Clean but worn linen on narrow beds. Hudson polishes one spoon in short strokes.">)
    (<EQUAL? ,HERE ,SECRET-PASSAGE>
     <SCENE "passage.narrow"
            "A narrow stone passage, cobwebs catching at both sleeves. Moisture slicks the walls.">)
    (<EQUAL? ,HERE ,PANTRY>
     <SCENE "pantry.shelves"
            "Cool, dry air smells of apples and charcoal dust. Shelves hold preserves and medicinal bottles.">)>>
