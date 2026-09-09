<DIRECTIONS NORTH SOUTH>
<CONSTANT RELEASEID 1>

<OBJECT ADVENTURER
        (DESC "you")
        (SYNONYM ADVENTURER ME SELF)
        (FLAGS)>

<ROOM STARTROOM
      (IN ROOMS)
      (DESC "Start Room")
      (LDESC "A test room.")
      (NORTH TO SECONDROOM)
      (FLAGS RLANDBIT ONBIT)>

<ROOM SECONDROOM
      (IN ROOMS)
      (DESC "Second Room")
      (LDESC "Another test room.")
      (FLAGS RLANDBIT ONBIT)>

<OBJECT APPLE
        (IN STARTROOM)
        (SYNONYM APPLE)
        (DESC "apple")
        (FLAGS TAKEBIT)>

<OBJECT LAMP
        (IN STARTROOM)
        (SYNONYM LAMP)
        (DESC "lamp")
        (FLAGS TAKEBIT)>

<OBJECT BOX
        (IN SECONDROOM)
        (SYNONYM BOX)
        (DESC "box")
        (FLAGS CONTBIT OPENBIT)>

<GLOBAL TEST-SCORE 0>
<GLOBAL TEST-MOVES 0>
<GLOBAL TEST-FLAG <>>

<ROUTINE RUN-TEST ()
    <TELL "Testing SAVE and RESTORE..." CR CR>

    ;"=== Test 1: Basic save/restore of globals and object state ==="
    <TELL "--- Test 1: Basic save/restore ---" CR>

    ;"Set up initial state"
    <SETG HERE ,STARTROOM>
    <SETG WINNER ,ADVENTURER>
    <MOVE ,WINNER ,HERE>
    <SETG TEST-SCORE 42>
    <SETG TEST-MOVES 7>
    <SETG TEST-FLAG T>
    <MOVE ,APPLE ,ADVENTURER>
    <FSET ,LAMP ,ONBIT>

    ;"Verify initial state"
    <ASSERT "Initial TEST-SCORE is 42" <==? ,TEST-SCORE 42>>
    <ASSERT "Initial TEST-FLAG is true" ,TEST-FLAG>
    <ASSERT "Apple is in adventurer's inventory" <==? <LOC ,APPLE> ,ADVENTURER>>
    <ASSERT "Lamp has ONBIT set" <FSET? ,LAMP ,ONBIT>>

    ;"Save game state"
    <ASSERT "SAVE returns true" <SAVE "zil-test-save.tmp">>

    ;"Modify state after save"
    <SETG TEST-SCORE 99>
    <SETG TEST-MOVES 100>
    <SETG TEST-FLAG <>>
    <MOVE ,APPLE ,STARTROOM>
    <FCLEAR ,LAMP ,ONBIT>

    ;"Verify modified state"
    <ASSERT "TEST-SCORE changed to 99" <==? ,TEST-SCORE 99>>
    <ASSERT "TEST-FLAG is now false" <NOT ,TEST-FLAG>>
    <ASSERT "Apple moved back to room" <==? <LOC ,APPLE> ,STARTROOM>>
    <ASSERT "Lamp ONBIT cleared" <NOT <FSET? ,LAMP ,ONBIT>>>

    ;"Restore game state"
    <ASSERT "RESTORE returns true" <RESTORE "zil-test-save.tmp">>

    ;"Verify restored state matches original saved state"
    <ASSERT "TEST-SCORE restored to 42" <==? ,TEST-SCORE 42>>
    <ASSERT "TEST-MOVES restored to 7" <==? ,TEST-MOVES 7>>
    <ASSERT "TEST-FLAG restored to true" ,TEST-FLAG>
    <ASSERT "Apple restored to adventurer inventory" <==? <LOC ,APPLE> ,ADVENTURER>>
    <ASSERT "Lamp ONBIT restored" <FSET? ,LAMP ,ONBIT>>

    ;"Test 2: HERE global saved/restored"
    <TELL CR "--- Test 2: HERE global saved/restored ---" CR>

    ;"Move player to SECONDROOM and save"
    <SETG HERE ,SECONDROOM>
    <MOVE ,WINNER ,SECONDROOM>
    <ASSERT "HERE is now SECONDROOM" <==? ,HERE ,SECONDROOM>>
    <ASSERT "SAVE with player in SECONDROOM" <SAVE "zil-test-save2.tmp">>

    ;"Move player back to STARTROOM"
    <SETG HERE ,STARTROOM>
    <MOVE ,WINNER ,STARTROOM>
    <ASSERT "HERE changed back to STARTROOM" <==? ,HERE ,STARTROOM>>

    ;"Restore and verify HERE is SECONDROOM"
    <ASSERT "RESTORE to SECONDROOM state" <RESTORE "zil-test-save2.tmp">>
    <ASSERT "HERE restored to SECONDROOM" <==? ,HERE ,SECONDROOM>>
    <ASSERT "WINNER is in SECONDROOM after restore" <==? <LOC ,WINNER> ,SECONDROOM>>

    ;"Test 3: Object in room saved/restored"
    <TELL CR "--- Test 3: Object in room saved/restored ---" CR>

    ;"Reset: move apple to SECONDROOM"
    <SETG HERE ,STARTROOM>
    <MOVE ,WINNER ,STARTROOM>
    <MOVE ,APPLE ,SECONDROOM>
    <ASSERT "Apple is in SECONDROOM" <==? <LOC ,APPLE> ,SECONDROOM>>
    <ASSERT "SAVE with apple in SECONDROOM" <SAVE "zil-test-save3.tmp">>

    ;"Move apple to STARTROOM"
    <MOVE ,APPLE ,STARTROOM>
    <ASSERT "Apple moved to STARTROOM" <==? <LOC ,APPLE> ,STARTROOM>>

    ;"Restore and verify apple is back in SECONDROOM"
    <ASSERT "RESTORE apple to SECONDROOM" <RESTORE "zil-test-save3.tmp">>
    <ASSERT "Apple restored to SECONDROOM" <==? <LOC ,APPLE> ,SECONDROOM>>

    ;"Test 4: Multiple flags saved/restored"
    <TELL CR "--- Test 4: Multiple flags saved/restored ---" CR>

    ;"Set multiple flags on box"
    <FSET ,BOX ,ONBIT>
    <FSET ,BOX ,TAKEBIT>
    <ASSERT "BOX has ONBIT set" <FSET? ,BOX ,ONBIT>>
    <ASSERT "BOX has TAKEBIT set" <FSET? ,BOX ,TAKEBIT>>
    <ASSERT "SAVE with multiple flags on box" <SAVE "zil-test-save4.tmp">>

    ;"Clear flags"
    <FCLEAR ,BOX ,ONBIT>
    <FCLEAR ,BOX ,TAKEBIT>
    <ASSERT "BOX ONBIT cleared" <NOT <FSET? ,BOX ,ONBIT>>>
    <ASSERT "BOX TAKEBIT cleared" <NOT <FSET? ,BOX ,TAKEBIT>>>

    ;"Restore and verify both flags are back"
    <ASSERT "RESTORE multiple flags" <RESTORE "zil-test-save4.tmp">>
    <ASSERT "BOX ONBIT restored" <FSET? ,BOX ,ONBIT>>
    <ASSERT "BOX TAKEBIT restored" <FSET? ,BOX ,TAKEBIT>>

    ;"Test 5: Multiple independent save files"
    <TELL CR "--- Test 5: Multiple independent save files ---" CR>

    ;"Save state A: score=10, apple in STARTROOM"
    <SETG TEST-SCORE 10>
    <MOVE ,APPLE ,STARTROOM>
    <ASSERT "SAVE state A" <SAVE "zil-test-save-A.tmp">>

    ;"Save state B: score=20, apple with adventurer"
    <SETG TEST-SCORE 20>
    <MOVE ,APPLE ,ADVENTURER>
    <ASSERT "SAVE state B" <SAVE "zil-test-save-B.tmp">>

    ;"Restore state A and verify"
    <ASSERT "RESTORE state A" <RESTORE "zil-test-save-A.tmp">>
    <ASSERT "Score is 10 after restoring A" <==? ,TEST-SCORE 10>>
    <ASSERT "Apple is in STARTROOM after restoring A" <==? <LOC ,APPLE> ,STARTROOM>>

    ;"Restore state B and verify"
    <ASSERT "RESTORE state B" <RESTORE "zil-test-save-B.tmp">>
    <ASSERT "Score is 20 after restoring B" <==? ,TEST-SCORE 20>>
    <ASSERT "Apple is with adventurer after restoring B" <==? <LOC ,APPLE> ,ADVENTURER>>

    ;"Test 6: RESTORE with non-existent file returns false"
    <TELL CR "--- Test 6: RESTORE non-existent file ---" CR>
    <ASSERT "RESTORE non-existent file returns false" <NOT <RESTORE "zil-test-no-such-file.tmp">>>

    ;"Test 7: Default filename (no argument) - success confirmed by RESTORE returning true and value matching"
    <TELL CR "--- Test 7: Default filename ---" CR>
    <SETG TEST-SCORE 77>
    <MOVE ,APPLE ,STARTROOM>
    <ASSERT "SAVE with default filename" <SAVE>>
    <SETG TEST-SCORE 0>
    <ASSERT "RESTORE with default filename returns true" <RESTORE>>
    <ASSERT "TEST-SCORE restored via default filename" <==? ,TEST-SCORE 77>>

    <TELL CR "All save/restore tests passed!" CR>>
