; === WALKTHROUGH TEST FILE ===
; The Limehouse Killings - Golden Path Test

<VERSION ZIP>

; === TEST START ===

<ROUTINE GO ()
    <TELL "=== THE LIMEHOUSE KILLINGS - GOLDEN PATH TEST ===" CR>
    <TELL CR "Starting at Ashworth Manor Gate..." CR>
    <TELL CR>

    ; Test 1: Enter manor
    <TELL "Test 1: Enter manor" CR>
    <PERFORM ,V?GO-NORTH ,ROOMS>
    <ASSERT <==? ,HERE ,ASHWORTH-ENTRANCE-HALL> "Should be in entrance hall">

    ; Test 2: Examine room
    <TELL CR "Test 2: Examine entrance hall" CR>
    <PERFORM ,V?LOOK ,ROOMS>
    <ASSERT <==? ,HERE ,ASHWORTH-ENTRANCE-HALL> "Should still be in entrance hall">

    ; Test 3: Try locked study door
    <TELL CR "Test 3: Try locked study door" CR>
    <PERFORM ,V?GO-NORTH ,ROOMS>
    <ASSERT <NOT ,STUDY-UNLOCKED> "Study should be locked">
    <ASSERT <NOT <FSET? ,STUDY-DOOR ,OPENBIT>> "Study door should be closed">
    <ASSERT <==? ,HERE ,ASHWORTH-ENTRANCE-HALL> "Locked study exit should keep player in entrance hall">

    ; Test 4: Go to library
    <TELL CR "Test 4: Go to library" CR>
    <PERFORM ,V?GO-EAST ,ROOMS>
    <ASSERT <==? ,HERE ,LIBRARY> "Should be in library">

    ; Test 5: Examine bookshelf
    <TELL CR "Test 5: Examine bookshelf" CR>
    <PERFORM ,V?EXAMINE ,BOOKSHELF>
    <ASSERT <NOT ,CIPHER-SOLVED> "Cipher should not be solved yet">

    ; Test 6: Find torn page
    <TELL CR "Test 6: Find torn page" CR>
    <PERFORM ,V?EXAMINE ,READING-DESK>
    <PERFORM ,V?TAKE ,TORN-PAGE>
    <ASSERT <IN? ,TORN-PAGE ,WINNER> "Should have torn page">

    ; Test 7: Read torn page
    <TELL CR "Test 7: Read torn page" CR>
    <PERFORM ,V?READ ,TORN-PAGE>
    <ASSERT <IN? ,TORN-PAGE ,WINNER> "Should still have torn page">

    ; Test 8: Examine colored markers
    <TELL CR "Test 8: Examine colored markers" CR>
    <PERFORM ,V?EXAMINE ,COLORED-MARKERS>
    <ASSERT <NOT ,CIPHER-SOLVED> "Cipher should not be solved yet">

    ; Test 9: Solve cipher
    <TELL CR "Test 9: Solve cipher" CR>
    <SOLVE-CIPHER>
    <ASSERT ,CIPHER-SOLVED "Cipher should be solved">
    <ASSERT ,SECRET-PASSAGE-FOUND "Secret passage should be found">

    ; Test 10: Enter secret passage
    <TELL CR "Test 10: Enter secret passage" CR>
    <PERFORM ,V?GO-SOUTH ,ROOMS>
    <ASSERT <==? ,HERE ,SECRET-PASSAGE> "Should be in secret passage">

    ; Test 11: Go to study via secret passage
    <TELL CR "Test 11: Go to study via secret passage" CR>
    <PERFORM ,V?GO-EAST ,ROOMS>
    <ASSERT <==? ,HERE ,STUDY> "Should be in study">

    ; Test 12: Examine study
    <TELL CR "Test 12: Examine study" CR>
    <PERFORM ,V?LOOK ,ROOMS>
    <ASSERT <==? ,HERE ,STUDY> "Should still be in study">

    ; Test 13: Take evidence
    <TELL CR "Test 13: Take evidence" CR>
    <PERFORM ,V?TAKE ,DEAD-LETTER>
    <PERFORM ,V?TAKE ,POISON-BOTTLE>
    <ASSERT <IN? ,DEAD-LETTER ,WINNER> "Should have dead letter">
    <ASSERT <IN? ,POISON-BOTTLE ,WINNER> "Should have poison bottle">
    <ASSERT <==? ,EVIDENCE-FOUND 2> "Should have 2 evidence items">

    ; Test 14: Read dead letter
    <TELL CR "Test 14: Read dead letter" CR>
    <PERFORM ,V?READ ,DEAD-LETTER>
    <ASSERT <IN? ,DEAD-LETTER ,WINNER> "Should still have dead letter">

    ; Test 15: Examine poison bottle
    <TELL CR "Test 15: Examine poison bottle" CR>
    <PERFORM ,V?EXAMINE ,POISON-BOTTLE>
    <ASSERT <IN? ,POISON-BOTTLE ,WINNER> "Should still have poison bottle">

    ; Test 16: Go to dining room
    <TELL CR "Test 16: Go to dining room" CR>
    <PERFORM ,V?OPEN ,STUDY-DOOR>
    <ASSERT ,STUDY-UNLOCKED "Opening the study door from inside should release its bolt">
    <ASSERT <FSET? ,STUDY-DOOR ,OPENBIT> "Study door should be open">
    <PERFORM ,V?GO-SOUTH ,ROOMS>
    <PERFORM ,V?GO-WEST ,ROOMS>
    <ASSERT <==? ,HERE ,DINING-ROOM> "Should be in dining room">

    ; Test 17: Take wax seal
    <TELL CR "Test 17: Take wax seal" CR>
    <PERFORM ,V?TAKE ,WAX-SEAL>
    <ASSERT <IN? ,WAX-SEAL ,WINNER> "Should have wax seal">

    ; Test 18: Go to kitchen
    <TELL CR "Test 18: Go to kitchen" CR>
    <PERFORM ,V?GO-EAST ,ROOMS>
    <PERFORM ,V?GO-DOWN ,ROOMS>
    <ASSERT <==? ,HERE ,KITCHEN> "Should be in kitchen">

    ; Test 19: Take lockpick set
    <TELL CR "Test 19: Take lockpick set" CR>
    <PERFORM ,V?EXAMINE ,DRAWER>
    <PERFORM ,V?TAKE ,LOCKPICK-SET>
    <ASSERT <IN? ,LOCKPICK-SET ,WINNER> "Should have lockpick set">

    ; Test 20: Go to garden
    <TELL CR "Test 20: Go to garden" CR>
    <PERFORM ,V?GO-WEST ,ROOMS>
    <ASSERT <==? ,HERE ,GARDEN> "Should be in garden">

    ; Test 21: Take knife
    <TELL CR "Test 21: Take knife" CR>
    <PERFORM ,V?EXAMINE ,HEDGES>
    <PERFORM ,V?TAKE ,BLOOD-STAINED-KNIFE>
    <ASSERT <IN? ,BLOOD-STAINED-KNIFE ,WINNER> "Should have knife">
    <ASSERT <==? ,EVIDENCE-FOUND 3> "Should have 3 evidence items">

    ; Test 22: Take footprint cast
    <TELL CR "Test 22: Take footprint cast" CR>
    <PERFORM ,V?TAKE ,FOOTPRINT-CAST>
    <ASSERT <IN? ,FOOTPRINT-CAST ,WINNER> "Should have footprint cast">

    ; Test 23: Go to greenhouse
    <TELL CR "Test 23: Go to greenhouse" CR>
    <PERFORM ,V?GO-NORTH ,ROOMS>
    <ASSERT <==? ,HERE ,GREENHOUSE> "Should be in greenhouse">

    ; Test 24: Identify poison
    <TELL CR "Test 24: Identify poison" CR>
    <IDENTIFY-POISON>
    <ASSERT ,POISON-IDENTIFIED "Poison should be identified">

    ; Test 25: Go to servants quarters
    <TELL CR "Test 25: Go to servants quarters" CR>
    <PERFORM ,V?GO-SOUTH ,ROOMS>
    <PERFORM ,V?GO-SOUTH ,ROOMS>
    <ASSERT <==? ,HERE ,SERVANTS-QUARTERS> "Should be in servants quarters">

    ; Test 26: Interview Mr. Hudson
    <TELL CR "Test 26: Interview Mr. Hudson" CR>
    <PERFORM ,V?ASK ,MR-HUDSON ,MASTER>
    <PERFORM ,V?ASK ,MR-HUDSON ,ALIBI>
    <PERFORM ,V?ASK ,MR-HUDSON ,KEY>
    <ASSERT ,HUDSON-KEY-GIVEN "Hudson should have given key">
    <ASSERT <IN? ,KEYRING ,WINNER> "Should have keyring">

    ; Test 27: Take letter from trunk
    <TELL CR "Test 27: Take letter from trunk" CR>
    <PERFORM ,V?EXAMINE ,TRUNK>
    <ASSERT <NOT ,HUDSON-INTERVIEWED> "Hudson should not be interviewed yet">

    ; Test 28: Go to pantry
    <TELL CR "Test 28: Go to pantry" CR>
    <PERFORM ,V?GO-NORTH ,ROOMS>
    <PERFORM ,V?GO-EAST ,ROOMS>
    <PERFORM ,V?GO-NORTH ,ROOMS>
    <ASSERT <==? ,HERE ,PANTRY> "Should be in pantry">

    ; Test 29: Take antidote ingredients
    <TELL CR "Test 29: Take antidote ingredients" CR>
    <PERFORM ,V?TAKE ,FOXGLOVE>
    <PERFORM ,V?TAKE ,CHARCOAL>
    <ASSERT <IN? ,FOXGLOVE ,WINNER> "Should have foxglove">
    <ASSERT <IN? ,CHARCOAL ,WINNER> "Should have charcoal">

    ; Test 30: Go to entrance hall
    <TELL CR "Test 30: Go to entrance hall" CR>
    <PERFORM ,V?GO-SOUTH ,ROOMS>
    <PERFORM ,V?GO-EAST ,ROOMS>
    <PERFORM ,V?GO-UP ,ROOMS>
    <ASSERT <==? ,HERE ,ASHWORTH-ENTRANCE-HALL> "Should be in entrance hall">

    ; Test 31: Interview Lady Ashworth
    <TELL CR "Test 31: Interview Lady Ashworth" CR>
    <PERFORM ,V?GO-WEST ,ROOMS>
    <ASSERT <==? ,HERE ,DINING-ROOM> "Should be in dining room">
    <PERFORM ,V?ASK ,LADY-ASHWORTH ,MARRIAGE>
    <PERFORM ,V?ASK ,LADY-ASHWORTH ,ALIBI>
    <ASSERT ,LADY-ALIBI-CLAIMED "Lady should have claimed alibi">

    ; Test 32: Go to library
    <TELL CR "Test 32: Go to library" CR>
    <PERFORM ,V?GO-EAST ,ROOMS>
    <PERFORM ,V?GO-EAST ,ROOMS>
    <ASSERT <==? ,HERE ,LIBRARY> "Should be in library">

    ; Test 33: Interview Dr. Moriarty
    <TELL CR "Test 33: Interview Dr. Moriarty" CR>
    <PERFORM ,V?ASK ,DR-MORIARTY ,EXPERIMENTS>
    <PERFORM ,V?ASK ,DR-MORIARTY ,POISON>
    <ASSERT ,MORIARTY-POISON-KNOWN "Should know Moriarty has poison">

    ; Test 34: Find secret ledger
    <TELL CR "Test 34: Find secret ledger" CR>
    <PERFORM ,V?TAKE ,SECRET-LEDGER>
    <ASSERT <IN? ,SECRET-LEDGER ,WINNER> "Should have secret ledger">
    <ASSERT <==? ,EVIDENCE-FOUND 4> "Should have 4 evidence items">

    ; Test 35: Use lockpick on locked box
    <TELL CR "Test 35: Use lockpick on locked box" CR>
    <PERFORM ,V?GO-WEST ,ROOMS>
    <PERFORM ,V?GO-NORTH ,ROOMS>
    <PERFORM ,V?GO-EAST ,ROOMS>
    <ASSERT <==? ,HERE ,STUDY> "Should be in study">
    <PERFORM ,V?TURN ,LOCKED-BOX ,MORIARTY-TOPIC>
    <ASSERT ,LOCKED-BOX-OPENED "Box should be opened">

    ; Test 36: Take bank statement
    <TELL CR "Test 36: Take bank statement" CR>
    <PERFORM ,V?TAKE ,BANK-STATEMENT>
    <ASSERT <IN? ,BANK-STATEMENT ,WINNER> "Should have bank statement">
    <ASSERT <==? ,EVIDENCE-FOUND 5> "Should have 5 evidence items">

    ; Test 37: Check score
    <TELL CR "Test 37: Check score" CR>
    <PERFORM ,V?SCORE ,ROOMS>

    ; Test 38: Accuse Dr. Moriarty
    <TELL CR "Test 38: Accuse Dr. Moriarty" CR>
    <PERFORM ,V?SHOW ,DEAD-LETTER ,INSPECTOR>
    <PERFORM ,V?SHOW ,POISON-BOTTLE ,INSPECTOR>
    <PERFORM ,V?SHOW ,BANK-STATEMENT ,INSPECTOR>
    <PERFORM ,V?ACCUSE ,DR-MORIARTY ,DEAD-LETTER>
    <ASSERT ,KILLER-ACCUSED "Killer should be accused">
    <ASSERT ,CORRECT-ACCUSATION "Accusation should be correct">
    <ASSERT ,GAME-WON "Game should be won">

    <TELL CR "=== ALL TESTS PASSED ===" CR>
    <QUIT>>
