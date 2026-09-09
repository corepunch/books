;"State-aware intent cards for The Last Toymaker's Apprentice.

  This file is intentionally separate from the adventure source.
  Labels describe narrative intentions; commands are ordinary parser input.
  The runtime evaluates SUGGEST-ACTIONS only while the game is waiting at READ."

;"=== Helper: Movement choice ==="

<ROUTINE MOVE-CHOICE (ID LABEL COMMAND KIND PRIORITY)
  <CHOICE .ID .LABEL .COMMAND .KIND .PRIORITY>
  <CHOICE-DETAILS "group" "move">>

;"=== Main dispatch ==="

<ROUTINE SUGGEST-ACTIONS ()
  <COND
    (<EQUAL? ,HERE ,WORKSHOP-FLOOR>
     <SUGGEST-WORKSHOP-FLOOR>)
    (<EQUAL? ,HERE ,WORKBENCH-TOP>
     <SUGGEST-WORKBENCH-TOP>)
    (<EQUAL? ,HERE ,TOOL-BENCH>
     <SUGGEST-TOOL-BENCH>)
    (<EQUAL? ,HERE ,COUNTERTOP>
     <SUGGEST-COUNTERTOP>)
    (<EQUAL? ,HERE ,STORAGE-LOFT>
     <SUGGEST-STORAGE-LOFT>)
    (<EQUAL? ,HERE ,SNOWY-ALLEY>
     <SUGGEST-SNOWY-ALLEY>)
    (<EQUAL? ,HERE ,CLOCK-SQUARE>
     <SUGGEST-CLOCK-SQUARE>)
    (<EQUAL? ,HERE ,MAILBOX-CORNER>
     <SUGGEST-MAILBOX-CORNER>)
    (<EQUAL? ,HERE ,SCRAP-YARD>
     <SUGGEST-SCRAP-YARD>)
    (<EQUAL? ,HERE ,FOX-DEN>
     <SUGGEST-FOX-DEN>)
    (<EQUAL? ,HERE ,TOLLIVER-STUDY>
     <SUGGEST-TOLLIVER-STUDY>)
    (<EQUAL? ,HERE ,WORKSHOP-HEART>
     <SUGGEST-WORKSHOP-HEART>)
    (T
     <SUGGEST-GENERIC>)>>

;"=== WORKSHOP-FLOOR ==="

<ROUTINE SUGGEST-WORKSHOP-FLOOR ()
  <COND
    ;"State: Key wound — endgame"
    (,KEY-WOUND
     <CHOICE "workshop-floor.return-study"
             "Return to Tolliver's study"
             "in"
             ,CHOICE-RETURN
             80>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Key found, study accessed"
    (<AND ,KEY-FOUND ,STUDY-ACCESS>
     <CHOICE "workshop-floor.enter-study"
             "Enter Tolliver's study through the clock"
             "in"
             ,CHOICE-PROGRESS
             100>
     <CHOICE-DETAILS "group" "move">
     <CHOICE "workshop-floor.go-outside"
             "Slip through the pet door into the snowy alley"
             "north"
             ,CHOICE-PROGRESS
             60>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Key found, study not accessed"
    (<AND ,KEY-FOUND <NOT ,STUDY-ACCESS>>
     <CHOICE "workshop-floor.wind-clock"
             "Wind the cuckoo clock on the wall"
             "wind clock"
             ,CHOICE-PROGRESS
             100>
     <CHOICE "workshop-floor.climb-loft"
             "Raise the folding ladder and climb to the storage loft"
             "up"
             ,CHOICE-PROGRESS
             85>
     <CHOICE-DETAILS "group" "move">
     <CHOICE "workshop-floor.go-outside"
             "Slip through the pet door into the snowy alley"
             "north"
             ,CHOICE-PROGRESS
             60>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Ladder oiled, can reach loft"
    (<AND ,LADDER-OILED <NOT ,KEY-FOUND>>
     <CHOICE "workshop-floor.climb-loft"
             "Climb the folding ladder to the storage loft"
             "up"
             ,CHOICE-PROGRESS
             90>
     <CHOICE-DETAILS "group" "move">
     <CHOICE "workshop-floor.go-outside"
             "Slip through the pet door into the snowy alley"
             "north"
             ,CHOICE-PROGRESS
             70>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Have oil can, ladder not oiled"
    (<AND <IN? ,OIL-CAN ,WINNER> <NOT ,LADDER-OILED> <NOT ,KEY-FOUND>>
     <CHOICE "workshop-floor.oil-ladder"
             "Oil the rusty lifting mechanism"
             "lubricate mechanism with oil can"
             ,CHOICE-PROGRESS
             100>
     <CHOICE "workshop-floor.examine-workbench"
             "Examine the enormous workbench"
             "examine workbench"
             ,CHOICE-INVESTIGATE
             80>
     <CHOICE "workshop-floor.climb-workbench"
             "Climb the workbench for a better view"
             "climb workbench"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE-DETAILS "image-key" "workshop-floor.climb-workbench">)

    ;"State: Initial"
    (<NOT ,KEY-FOUND>
     <CHOICE "workshop-floor.examine-workbench"
             "Examine the enormous workbench"
             "examine workbench"
             ,CHOICE-INVESTIGATE
             90>
     <CHOICE "workshop-floor.examine-hook"
             "Look at the empty key hook"
             "examine hook"
             ,CHOICE-INVESTIGATE
             80>
     <CHOICE-DETAILS "image-key" "workshop-floor.examine-hook">
     <CHOICE "workshop-floor.climb-workbench"
             "Climb the giant workbench"
             "climb workbench"
             ,CHOICE-INVESTIGATE
             88>
     <CHOICE-DETAILS "image-key" "workshop-floor.climb-workbench">
     <CHOICE "workshop-floor.take-oil-can"
             "Pull the tiny copper oil can from under the workbench"
             "take oil can"
             ,CHOICE-PROGRESS
             85>
     <CHOICE-DETAILS "image-key" "workshop-floor.take-oil-can">)>
   <COND
     (<FSET? ,TOOL-BENCH ,TOUCHBIT>
      <CHOICE "workshop-floor.go-toolbench"
              "Walk back to the tool bench"
              "east"
              ,CHOICE-RETURN
              75>
      <CHOICE-DETAILS "group" "move">)
     (T
      <CHOICE "workshop-floor.go-toolbench"
              "Walk to the tool bench"
              "east"
              ,CHOICE-PROGRESS
              75>
      <CHOICE-DETAILS "group" "move">)>>

;"=== WORKBENCH TOP ==="

<ROUTINE SUGGEST-WORKBENCH-TOP ()
  <COND
    (,REPAIR-BOOK-OPEN
     <CHOICE "workbench-top.read-repair-book"
             "Study Grandfather's paper workshop"
             "read illustrated book"
             ,CHOICE-INVESTIGATE
             90>
     <CHOICE "workbench-top.close-repair-book"
             "Close the illustrated repair book"
             "close illustrated book"
             ,CHOICE-PROGRESS
             110>
     <CHOICE-DETAILS "image-key" "workbench-top.close-repair-book">)
    (T
     <CHOICE "workbench-top.open-repair-book"
             "Open Grandfather's illustrated repair book"
             "open illustrated book"
             ,CHOICE-PROGRESS
             110>
     <CHOICE-DETAILS "image-key" "workbench-top.open-repair-book">
     <CHOICE "workbench-top.examine-toys"
             "Look over Grandfather's half-finished toys"
             "examine toys"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE "workbench-top.go-down"
             "Climb back down to the workshop floor"
             "down"
             ,CHOICE-RETURN
             60>
     <CHOICE-DETAILS "group" "move">)>>

;"=== TOOL-BENCH ==="

<ROUTINE SUGGEST-TOOL-BENCH ()
  <COND
    ;"State: Bertrand wound"
    (,BERTRAND-WOUND
     <CHOICE "tool-bench.climb-countertop"
             "Climb the crate, chair, and stacked books to the countertop"
             "up"
             ,CHOICE-PROGRESS
             90>
     <CHOICE-DETAILS "group" "move">
     <CHOICE "tool-bench.ask-bertrand"
             "Ask Bertrand about Grandfather Tolliver"
             "ask nutcracker about tolliver"
             ,CHOICE-INTERACT
             70>
     <CHOICE "tool-bench.go-workshop"
             "Return to the workshop floor"
             "west"
             ,CHOICE-RETURN
             60>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Bertrand not wound, have key"
    (<AND <NOT ,BERTRAND-WOUND> <IN? ,BERTRAND-KEY ,WINNER>>
     <CHOICE "tool-bench.wind-bertrand"
             "Wind the nutcracker with his key"
             "wind nutcracker"
             ,CHOICE-PROGRESS
             100>
     <CHOICE-DETAILS "image-key" "tool-bench.wind-bertrand">
     <CHOICE "tool-bench.examine-bertrand"
             "Examine Bertrand closely"
             "examine nutcracker"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE "tool-bench.go-workshop"
             "Return to the workshop floor"
             "west"
             ,CHOICE-RETURN
             55>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Bertrand not wound, no key"
    (<NOT ,BERTRAND-WOUND>
     <CHOICE "tool-bench.take-key"
             "Take the winding key from Bertrand's back"
             "take key"
             ,CHOICE-PROGRESS
             100>
     <CHOICE "tool-bench.examine-bertrand"
             "Examine Bertrand closely"
             "examine nutcracker"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE "tool-bench.go-workshop"
             "Return to the workshop floor"
             "west"
             ,CHOICE-RETURN
             55>
     <CHOICE-DETAILS "group" "move">)>>

;"=== COUNTERTOP ==="

<ROUTINE SUGGEST-COUNTERTOP ()
  <COND
    ;"State: Marzipan has button"
    (,MARZIPAN-BUTTON
     <CHOICE "countertop.ask-fox"
             "Ask Marzipan about the fox"
             "ask doll about fox"
             ,CHOICE-INVESTIGATE
             90>
     <CHOICE "countertop.ask-key"
             "Ask Marzipan about the workshop key"
             "ask doll about key"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE "countertop.go-down"
             "Climb back down to the tool bench"
             "down"
             ,CHOICE-RETURN
             60>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Case open, items remaining"
    (<AND <FSET? ,DISPLAY-CASE ,OPENBIT>
          <OR <IN? ,TIN-SOLDIER ,DISPLAY-CASE>
              <IN? ,MUSIC-BOX ,DISPLAY-CASE>>>
     <CHOICE "countertop.take-soldier"
             "Take the tin soldier from the display case"
             "take soldier"
             ,CHOICE-PROGRESS
             90>
     <CHOICE "countertop.take-music-box"
             "Take the silver music box"
             "take music box"
             ,CHOICE-PROGRESS
             85>
     <CHOICE "countertop.take-button"
             "Take the spare button near the doll"
             "take button"
             ,CHOICE-INVESTIGATE
             75>
     <CHOICE "countertop.give-button"
             "Give the button to the rag doll"
             "give button to doll"
             ,CHOICE-INTERACT
             80>
     <CHOICE "countertop.go-down"
             "Climb back down to the tool bench"
             "down"
             ,CHOICE-RETURN
             55>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Case open, empty — button still on surface"
    (<AND <FSET? ,DISPLAY-CASE ,OPENBIT>
          <NOT <IN? ,TIN-SOLDIER ,DISPLAY-CASE>>
          <NOT <IN? ,MUSIC-BOX ,DISPLAY-CASE>>>
     <CHOICE "countertop.take-button"
             "Take the spare button near the doll"
             "take button"
             ,CHOICE-PROGRESS
             90>
     <CHOICE "countertop.give-button"
             "Give the button to the rag doll"
             "give button to doll"
             ,CHOICE-INTERACT
             85>
     <CHOICE "countertop.ask-fox"
             "Ask Marzipan about the fox"
             "ask doll about fox"
             ,CHOICE-INVESTIGATE
             75>
     <CHOICE "countertop.go-down"
             "Climb back down to the tool bench"
             "down"
             ,CHOICE-RETURN
             60>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Case closed"
    (<NOT <FSET? ,DISPLAY-CASE ,OPENBIT>>
     <CHOICE "countertop.open-case"
             "Open the dusty glass display case"
             "open case"
             ,CHOICE-INVESTIGATE
             90>
     <CHOICE "countertop.ask-marzipan"
             "Ask Marzipan about Grandfather Tolliver"
             "ask doll about tolliver"
             ,CHOICE-INTERACT
             75>
     <CHOICE "countertop.go-down"
             "Climb back down to the tool bench"
             "down"
             ,CHOICE-RETURN
             55>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Default"
    (T
     <CHOICE "countertop.ask-fox"
             "Ask Marzipan about the fox"
             "ask doll about fox"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE "countertop.ask-key"
             "Ask Marzipan about the workshop key"
             "ask doll about key"
             ,CHOICE-INVESTIGATE
             80>
     <CHOICE "countertop.give-button"
             "Give the button to the rag doll"
             "give button to doll"
             ,CHOICE-INTERACT
             75>
     <CHOICE "countertop.go-down"
             "Climb back down to the tool bench"
             "down"
             ,CHOICE-RETURN
             60>
     <CHOICE-DETAILS "group" "move">)>>

;"=== STORAGE-LOFT ==="

<ROUTINE SUGGEST-STORAGE-LOFT ()
  <COND
    ;"State: Toy box open, doll arm inside"
    (<AND <FSET? ,TOY-BOX ,OPENBIT> <IN? ,DOLL-ARM ,TOY-BOX>>
     <CHOICE "loft.take-doll-arm"
             "Take the porcelain doll arm from the box"
             "take arm"
             ,CHOICE-PROGRESS
             90>
     <CHOICE "loft.read-journal"
             "Read Tolliver's leather journal"
             "read journal"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE "loft.wind-old-tick"
             "Wind the old cuckoo clock"
             "wind clock"
             ,CHOICE-INVESTIGATE
             75>
     <CHOICE "loft.go-down"
             "Climb back down to the workshop"
             "down"
             ,CHOICE-RETURN
             60>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Toy box closed"
    (<NOT <FSET? ,TOY-BOX ,OPENBIT>>
     <CHOICE "loft.open-box"
             "Open the dusty cardboard box"
             "open cardboard box"
             ,CHOICE-INVESTIGATE
             90>
     <CHOICE "loft.wind-old-tick"
             "Wind the old cuckoo clock"
             "wind clock"
             ,CHOICE-INVESTIGATE
             80>
     <CHOICE "loft.read-journal"
             "Read Tolliver's leather journal"
             "read journal"
             ,CHOICE-INVESTIGATE
             75>
     <CHOICE "loft.go-down"
             "Climb back down to the workshop"
             "down"
             ,CHOICE-RETURN
             55>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Old Tick heard"
    (,OLD-TICK-HEARD
     <CHOICE "loft.ask-tick-tolliver"
             "Ask Old Tick about Grandfather Tolliver"
             "ask clock about tolliver"
             ,CHOICE-INTERACT
             85>
     <CHOICE "loft.read-journal"
             "Read Tolliver's leather journal"
             "read journal"
             ,CHOICE-INVESTIGATE
             80>
     <CHOICE "loft.wind-old-tick"
             "Wind Old Tick again"
             "wind clock"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE "loft.go-down"
             "Climb back down to the workshop"
             "down"
             ,CHOICE-RETURN
             60>
     <CHOICE-DETAILS "group" "move">)

    ;"State: Default"
    (T
     <CHOICE "loft.wind-old-tick"
             "Wind the old cuckoo clock"
             "wind clock"
             ,CHOICE-PROGRESS
             90>
     <CHOICE "loft.read-journal"
             "Read Tolliver's leather journal"
             "read journal"
             ,CHOICE-INVESTIGATE
             80>
     <CHOICE "loft.open-box"
             "Open the dusty cardboard box"
             "open cardboard box"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE "loft.go-down"
             "Climb back down to the workshop"
             "down"
             ,CHOICE-RETURN
             55>
     <CHOICE-DETAILS "group" "move">)>>

;"=== SNOWY-ALLEY ==="

<ROUTINE SUGGEST-SNOWY-ALLEY ()
  <CHOICE "alley.examine-footprints"
          "Examine the tiny fox footprints"
          "examine footprints"
          ,CHOICE-INVESTIGATE
          90>
  <CHOICE "alley.examine-snow"
          "Look at the fresh snow"
          "examine snow"
          ,CHOICE-INVESTIGATE
          60>
  <MOVE-CHOICE "alley.go-clock-square"
               "Follow the footprints east to the clock square"
               "east"
               ,CHOICE-PROGRESS
               85>
  <MOVE-CHOICE "alley.go-workshop"
               "Return to the workshop through the pet door"
               "south"
               ,CHOICE-RETURN
               55>>

;"=== CLOCK-SQUARE ==="

<ROUTINE SUGGEST-CLOCK-SQUARE ()
  <COND
    ;"State: Tower wound"
    (,TOWER-WOUND
     <CHOICE "square.examine-tower"
             "Examine the clock tower"
             "examine tower"
             ,CHOICE-INVESTIGATE
             75>
     <MOVE-CHOICE "square.go-alley"
                  "Return to the snowy alley"
                  "west"
                  ,CHOICE-RETURN
                  65>
     <MOVE-CHOICE "square.go-mailbox"
                  "Walk east to the mailbox corner"
                  "east"
                  ,CHOICE-PROGRESS
                  70>
     <MOVE-CHOICE "square.go-scrap-yard"
                  "Head south to the scrap-yard"
                  "south"
                  ,CHOICE-PROGRESS
                  70>)

    ;"State: Tower not wound, have soldier"
    (<AND <NOT ,TOWER-WOUND> <IN? ,TIN-SOLDIER ,WINNER>>
     <CHOICE "square.wind-tower"
             "Wind the clock tower's mechanism"
             "wind mechanism"
             ,CHOICE-PROGRESS
             100>
     <CHOICE "square.examine-tower"
             "Examine the clock tower"
             "examine tower"
             ,CHOICE-INVESTIGATE
             70>
     <MOVE-CHOICE "square.go-alley"
                  "Return to the snowy alley"
                  "west"
                  ,CHOICE-RETURN
                  55>
     <MOVE-CHOICE "square.go-mailbox"
                  "Walk east to the mailbox corner"
                  "east"
                  ,CHOICE-PROGRESS
                  65>
     <MOVE-CHOICE "square.go-scrap-yard"
                  "Head south to the scrap-yard"
                  "south"
                  ,CHOICE-PROGRESS
                  65>)

    ;"State: Tower not wound"
    (T
     <CHOICE "square.examine-tower"
             "Examine the clock tower"
             "examine tower"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE "square.examine-winding"
             "Look at the winding mechanism at the base"
             "examine mechanism"
             ,CHOICE-INVESTIGATE
             75>
     <MOVE-CHOICE "square.go-alley"
                  "Return to the snowy alley"
                  "west"
                  ,CHOICE-RETURN
                  60>
     <MOVE-CHOICE "square.go-mailbox"
                  "Walk east to the mailbox corner"
                  "east"
                  ,CHOICE-PROGRESS
                  70>
     <MOVE-CHOICE "square.go-scrap-yard"
                  "Head south to the scrap-yard"
                  "south"
                  ,CHOICE-PROGRESS
                  70>)>>

;"=== MAILBOX-CORNER ==="

<ROUTINE SUGGEST-MAILBOX-CORNER ()
  <COND
    ;"State: Scarf not taken"
    (<NOT <IN? ,SCARF ,WINNER>>
     <CHOICE "mailbox.take-scarf"
             "Pick up the red wool scarf from the snow"
             "take scarf"
             ,CHOICE-PROGRESS
             95>
     <CHOICE "mailbox.ask-fox"
             "Ask the mailbox about the fox"
             "ask mailbox about fox"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE "mailbox.read-letter"
             "Read the crumpled letter in the snow"
             "read letter"
             ,CHOICE-INVESTIGATE
             80>
     <MOVE-CHOICE "mailbox.go-square"
                  "Return to the clock square"
                  "west"
                  ,CHOICE-RETURN
                  60>)

    ;"State: Scarf taken"
    (T
     <CHOICE "mailbox.ask-fox"
             "Ask the mailbox about the fox"
             "ask mailbox about fox"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE "mailbox.read-letter"
             "Read the crumpled letter"
             "read letter"
             ,CHOICE-INVESTIGATE
             75>
     <CHOICE "mailbox.examine-letters"
             "Look at the letters inside the mailbox"
             "examine letters"
             ,CHOICE-INVESTIGATE
             65>
     <MOVE-CHOICE "mailbox.go-square"
                  "Return to the clock square"
                  "west"
                  ,CHOICE-RETURN
                  60>)>>

;"=== SCRAP-YARD ==="

<ROUTINE SUGGEST-SCRAP-YARD ()
  <COND
    ;"State: Cart moved"
    (,CART-MOVED
     <MOVE-CHOICE "yard.go-fox-den"
                  "Follow the path east to the fox den"
                  "east"
                  ,CHOICE-PROGRESS
                  90>
     <CHOICE "yard.examine-cart"
             "Examine the scrap cart"
             "examine cart"
             ,CHOICE-INVESTIGATE
             65>
     <MOVE-CHOICE "yard.go-square"
                  "Return to the clock square"
                  "north"
                  ,CHOICE-RETURN
                  60>)

    ;"State: Cart blocking, have doll head"
    (<AND <NOT ,CART-MOVED> <IN? ,DOLL-HEAD ,WINNER>>
     <CHOICE "yard.give-head"
             "Give the doll head to the scrap cart"
             "give head to cart"
             ,CHOICE-PROGRESS
             100>
     <CHOICE "yard.examine-cart"
             "Examine the scrap cart more closely"
             "examine cart"
             ,CHOICE-INVESTIGATE
             70>
     <MOVE-CHOICE "yard.go-square"
                  "Return to the clock square"
                  "north"
                  ,CHOICE-RETURN
                  55>)

    ;"State: Cart blocking"
    (<NOT ,CART-MOVED>
     <CHOICE "yard.examine-cart"
             "Examine the scrap cart"
             "examine cart"
             ,CHOICE-INVESTIGATE
             90>
     <CHOICE "yard.take-head"
             "Take the porcelain doll head from the scrap"
             "take head"
             ,CHOICE-PROGRESS
             85>
     <CHOICE "yard.examine-doll"
             "Look at the headless doll in the cart"
             "examine doll"
             ,CHOICE-INVESTIGATE
             70>
     <MOVE-CHOICE "yard.go-square"
                  "Return to the clock square"
                  "north"
                  ,CHOICE-RETURN
                  55>)>>

;"=== FOX-DEN ==="

<ROUTINE SUGGEST-FOX-DEN ()
  <COND
    ;"State: Trust -1 (hostile)"
    (<EQUAL? ,NUTMEG-TRUST -1>
     <CHOICE "den.examine-nutmeg"
             "Look at Nutmeg from a distance"
             "examine fox"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE "den.examine-candle"
             "Watch the toy candle flicker"
             "examine candle"
             ,CHOICE-INVESTIGATE
             55>
     <MOVE-CHOICE "den.go-scrap-yard"
                  "Leave the den and return to the scrap-yard"
                  "west"
                  ,CHOICE-RETURN
                  65>)

    ;"State: Trust 3+ (trusting) — key available"
    (<G? ,NUTMEG-TRUST 2>
     <CHOICE "den.take-key"
             "Take the workshop key from Nutmeg"
             "take key"
             ,CHOICE-PROGRESS
             100>
     <CHOICE "den.ask-key"
             "Ask Nutmeg about the workshop key"
             "ask fox about key"
             ,CHOICE-INTERACT
             80>
     <CHOICE "den.tell-tolliver"
             "Tell Nutmeg about Grandfather Tolliver"
             "tell fox about tolliver"
             ,CHOICE-INTERACT
             75>
     <MOVE-CHOICE "den.go-scrap-yard"
                  "Leave the den and return to the scrap-yard"
                  "west"
                  ,CHOICE-RETURN
                  55>)

    ;"State: Trust 2 (softening) — key available"
    (<EQUAL? ,NUTMEG-TRUST 2>
     <CHOICE "den.take-key"
             "Take the workshop key from Nutmeg"
             "take key"
             ,CHOICE-PROGRESS
             95>
     <CHOICE "den.tell-tolliver"
             "Tell Nutmeg about Grandfather Tolliver"
             "tell fox about tolliver"
             ,CHOICE-PROGRESS
             90>
     <CHOICE "den.ask-key"
             "Ask Nutmeg about the workshop key"
             "ask fox about key"
             ,CHOICE-INVESTIGATE
             80>
     <CHOICE "den.give-string"
             "Offer Nutmeg the ball of yarn"
             "give ball to fox"
             ,CHOICE-INTERACT
             75>
     <MOVE-CHOICE "den.go-scrap-yard"
                  "Leave the den and return to the scrap-yard"
                  "west"
                  ,CHOICE-RETURN
                  55>)

    ;"State: Trust 1 (wary) — key available"
    (<EQUAL? ,NUTMEG-TRUST 1>
     <CHOICE "den.take-key"
             "Take the workshop key from Nutmeg"
             "take key"
             ,CHOICE-PROGRESS
             90>
     <CHOICE "den.give-string"
             "Offer Nutmeg the ball of yarn"
             "give ball to fox"
             ,CHOICE-PROGRESS
             85>
     <CHOICE "den.tell-tolliver"
             "Tell Nutmeg about Grandfather Tolliver"
             "tell fox about tolliver"
             ,CHOICE-PROGRESS
             80>
     <CHOICE "den.ask-key"
             "Ask Nutmeg about the workshop key"
             "ask fox about key"
             ,CHOICE-INVESTIGATE
             70>
     <MOVE-CHOICE "den.go-scrap-yard"
                  "Leave the den and return to the scrap-yard"
                  "west"
                  ,CHOICE-RETURN
                  55>)

    ;"State: Trust 0 (initial)"
    (T
     <CHOICE "den.examine-nutmeg"
             "Look at the fox toy in the corner"
             "examine fox"
             ,CHOICE-INVESTIGATE
             90>
     <CHOICE "den.give-scarf"
             "Give Nutmeg the red wool scarf"
             "give scarf to fox"
             ,CHOICE-PROGRESS
             85>
     <CHOICE "den.tell-tolliver"
             "Tell Nutmeg about Grandfather Tolliver"
             "tell fox about tolliver"
             ,CHOICE-INTERACT
             75>
     <MOVE-CHOICE "den.go-scrap-yard"
                  "Leave the den and return to the scrap-yard"
                  "west"
                  ,CHOICE-RETURN
                  60>)>>

;"=== TOLLIVER-STUDY ==="

<ROUTINE SUGGEST-TOLLIVER-STUDY ()
  <COND
    ;"State: Both read"
    (<AND ,STUDY-JOURNAL-READ ,DIAGRAM-READ>
     <CHOICE "study.examine-desk"
             "Look at the cluttered desk"
             "examine desk"
             ,CHOICE-INVESTIGATE
             65>
     <CHOICE "study.examine-coat"
             "Examine Tolliver's worn coat"
             "examine coat"
             ,CHOICE-INVESTIGATE
             55>
     <MOVE-CHOICE "study.go-heart"
                  "Descend to the workshop heart"
                  "down"
                  ,CHOICE-PROGRESS
                  95>
     <MOVE-CHOICE "study.go-workshop"
                  "Return to the workshop floor"
                  "out"
                  ,CHOICE-RETURN
                  60>)

    ;"State: Diagram not read"
    (<NOT ,DIAGRAM-READ>
     <CHOICE "study.read-diagram"
             "Read the hand-drawn winding diagram"
             "read diagram"
             ,CHOICE-PROGRESS
             100>
     <CHOICE "study.read-journal"
             "Read Tolliver's final journal entry"
             "read journal"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE "study.examine-desk"
             "Examine the cluttered desk"
             "examine desk"
             ,CHOICE-INVESTIGATE
             65>
     <MOVE-CHOICE "study.go-workshop"
                  "Return to the workshop floor"
                  "out"
                  ,CHOICE-RETURN
                  55>)

    ;"State: Journal not read"
    (<NOT ,STUDY-JOURNAL-READ>
     <CHOICE "study.read-journal"
             "Read Tolliver's final journal entry"
             "read journal"
             ,CHOICE-PROGRESS
             95>
     <CHOICE "study.read-diagram"
             "Read the hand-drawn winding diagram"
             "read diagram"
             ,CHOICE-INVESTIGATE
             85>
     <CHOICE "study.examine-desk"
             "Examine the cluttered desk"
             "examine desk"
             ,CHOICE-INVESTIGATE
             65>
     <MOVE-CHOICE "study.go-heart"
                  "Descend to the workshop heart"
                  "down"
                  ,CHOICE-PROGRESS
                  80>
     <MOVE-CHOICE "study.go-workshop"
                  "Return to the workshop floor"
                  "out"
                  ,CHOICE-RETURN
                  55>)

    ;"State: Default"
    (T
     <CHOICE "study.read-diagram"
             "Read the winding diagram"
             "read diagram"
             ,CHOICE-PROGRESS
             90>
     <CHOICE "study.read-journal"
             "Read the journal"
             "read journal"
             ,CHOICE-INVESTIGATE
             85>
     <MOVE-CHOICE "study.go-heart"
                  "Descend to the workshop heart"
                  "down"
                  ,CHOICE-PROGRESS
                  80>
     <MOVE-CHOICE "study.go-workshop"
                  "Return to the workshop floor"
                  "out"
                  ,CHOICE-RETURN
                  55>)>>

;"=== WORKSHOP-HEART ==="

<ROUTINE SUGGEST-WORKSHOP-HEART ()
  <COND
    ;"State: Game won"
    (,GAME-WON
     <CHOICE "heart.examine-toys"
             "Watch the toys stirring to life"
             "examine toys"
             ,CHOICE-INTERACT
             70>
     <CHOICE "heart.listen"
             "Listen to the heart beating"
             "listen to mechanism"
             ,CHOICE-INTERACT
             65>)

    ;"State: Key wound"
    (<AND ,KEY-WOUND <NOT ,GAME-WON>>
     <COND (<AND <IN? ,TIN-SOLDIER ,WINNER>
                  <NOT <IN? ,TIN-SOLDIER ,WORKSHOP-HEART>>>
            <CHOICE "heart.place-soldier"
                    "Place the tin soldier beside the heart"
                    "position soldier"
                    ,CHOICE-PROGRESS
                    95>)>
     <COND (<AND <IN? ,MUSIC-BOX ,WINNER>
                  <NOT <IN? ,MUSIC-BOX ,WORKSHOP-HEART>>>
            <CHOICE "heart.place-music-box"
                    "Place the music box near the heart"
                    "position music box"
                    ,CHOICE-PROGRESS
                    90>)>
     <COND (<AND <IN? ,DOLL-ARM ,WINNER>
                  <NOT <IN? ,DOLL-ARM ,WORKSHOP-HEART>>>
            <CHOICE "heart.place-doll-arm"
                    "Place the doll arm beside the heart"
                    "position arm"
                    ,CHOICE-PROGRESS
                    80>)>
     <COND (<AND <IN? ,BUTTON ,WINNER>
                  <NOT <IN? ,BUTTON ,WORKSHOP-HEART>>>
            <CHOICE "heart.place-button"
                    "Place the spare button at the heart's base"
                    "position button"
                    ,CHOICE-PROGRESS
                    75>)>
     <CHOICE "heart.examine-heart"
             "Examine the workshop heart"
             "examine mechanism"
             ,CHOICE-INVESTIGATE
             70>
     <CHOICE "heart.listen"
             "Listen to the heart's ticking"
             "listen to mechanism"
             ,CHOICE-INVESTIGATE
             60>
     <MOVE-CHOICE "heart.go-study"
                  "Return to Tolliver's study"
                  "up"
                  ,CHOICE-RETURN
                  55>)

    ;"State: Key not wound"
    (<NOT ,KEY-WOUND>
     <COND (<IN? ,WORKSHOP-KEY ,WINNER>
            <CHOICE "heart.wind-heart"
                    "Insert the workshop key and wind the heart"
                    "wind heart"
                    ,CHOICE-PROGRESS
                    100>)>
     <CHOICE "heart.examine-heart"
             "Examine the silent heart mechanism"
             "examine mechanism"
             ,CHOICE-INVESTIGATE
             75>
     <CHOICE "heart.examine-slot"
             "Look at the brass keyhole at the heart's centre"
             "examine keyhole"
             ,CHOICE-INVESTIGATE
             70>
     <MOVE-CHOICE "heart.go-study"
                  "Return to Tolliver's study"
                  "up"
                  ,CHOICE-RETURN
                  60>)>>

;"=== GENERIC FALLBACK ==="

<ROUTINE SUGGEST-GENERIC ()
  <CHOICE "generic.look"
          "Look around"
          "look"
          ,CHOICE-INVESTIGATE
          80>
  <CHOICE "generic.inventory"
          "Check what you are carrying"
          "inventory"
          ,CHOICE-INVESTIGATE
          60>>

;"=== SCENE ROUTINE ==="

<ROUTINE SUGGEST-SCENE ()
  <COND
    (<EQUAL? ,HERE ,WORKSHOP-FLOOR>
     <COND (,KEY-WOUND
            <SCENE "workshop.floor-endgame"
                   "The workshop floor, warm with returning magic.">)
           (,STUDY-ACCESS
            <SCENE "workshop.floor-study-open"
                   "The workshop with the clock swung open.">)
           (,LADDER-OILED
            <SCENE "workshop.floor-oiled"
                   "The workshop with the folding loft ladder raised.">)
           (T
            <SCENE "workshop.floor-initial"
                   "Grandfather Tolliver's workshop, sawdust on the floorboards.">)>)

    (<EQUAL? ,HERE ,WORKBENCH-TOP>
     <COND (,REPAIR-BOOK-OPEN
            <SCENE "workbench.top-open"
                   "The workbench top with Tolliver's paper workshop rising from the open repair book.">)
           (T
            <SCENE "workbench.top-closed"
                   "The workbench top with Tolliver's closed illustrated repair book among half-finished toys.">)>)

    (<EQUAL? ,HERE ,TOOL-BENCH>
     <COND (,BERTRAND-WOUND
            <SCENE "toolbench.bertrand-wound"
                   "The tool bench with Bertrand standing proudly aside.">)
           (T
            <SCENE "toolbench.bertrand-frozen"
                   "The tool bench with a frozen nutcracker blocking the way up.">)>)

    (<EQUAL? ,HERE ,COUNTERTOP>
     <COND (,MARZIPAN-BUTTON
            <SCENE "countertop.marzipan-happy"
                   "The countertop display with Marzipan humming warmly.">)
           (T
            <SCENE "countertop.initial"
                   "The dusty countertop display, Marzipan singing softly.">)>)

    (<EQUAL? ,HERE ,STORAGE-LOFT>
     <SCENE "storage-loft.dusty"
            "A dusty loft with cobwebs and old toy parts.">)

    (<EQUAL? ,HERE ,SNOWY-ALLEY>
     <SCENE "snowy-alley.night"
            "A snowy alley with tiny fox footprints in the moonlight.">)

    (<EQUAL? ,HERE ,CLOCK-SQUARE>
     <SCENE "clock-square.dominant"
            "The clock tower dominating a quiet square of toy shopfronts.">)

    (<EQUAL? ,HERE ,MAILBOX-CORNER>
     <SCENE "mailbox-corner.snowy"
            "A quiet corner with a red tin mailbox tilted in the snow.">)

    (<EQUAL? ,HERE ,SCRAP-YARD>
     <COND (,CART-MOVED
            <SCENE "scrap-yard.open"
                   "The scrap-yard with the iron gate standing open.">)
           (T
            <SCENE "scrap-yard.blocked"
                   "The scrap-yard with broken toys and a cart blocking the way.">)>)

    (<EQUAL? ,HERE ,FOX-DEN>
     <COND (<G? ,NUTMEG-TRUST 2>
            <SCENE "fox-den.trusting"
                   "A cosy den with Nutmeg watching you with soft, trusting eyes.">)
           (<EQUAL? ,NUTMEG-TRUST -1>
            <SCENE "fox-den.hostile"
                   "A dim den with Nutmeg turned away in the corner.">)
           (T
            <SCENE "fox-den.initial"
                   "A cosy den of rags with a fox toy watching warily.">)>)

    (<EQUAL? ,HERE ,TOLLIVER-STUDY>
     <SCENE "study.cluttered"
            "Grandfather Tolliver's private study, smelling of wood shavings.">)

    (<EQUAL? ,HERE ,WORKSHOP-HEART>
     <COND (,KEY-WOUND
            <SCENE "heart.beating"
                   "The workshop heart, gears turning with renewed life.">)
           (T
            <SCENE "heart.silent"
                   "The vast silent heart chamber, toys waiting in the shadows.">)>)>>
