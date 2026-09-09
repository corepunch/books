<CONSTANT RELEASEID 1>

<OBJECT ADVENTURER
        (DESC "you")
        (SYNONYM ADVENTURER ME SELF)
        (FLAGS)>

<ROOM TESTROOM
      (IN ROOMS)
      (DESC "Test Room")
      (LDESC "A test room.")
      (FLAGS RLANDBIT ONBIT)>

<OBJECT APPLE
        (IN TESTROOM)
        (SYNONYM APPLE)
        (DESC "apple")
        (FLAGS TAKEBIT)>

<ROUTINE RUN-TEST ()
    <TELL "Testing ASSERT function..." CR CR>
    
    ;"Basic assertions using ASSERT"
    <ASSERT "Basic true assertion" T>
    <ASSERT "Basic false assertion" <NOT <>>
    <ASSERT "Numbers are equal" <==? 5 5>>
    <ASSERT "Numbers are not equal" <N==? 3 5>>
    
    ;"Test object location"
    <SETG HERE ,TESTROOM>
    <SETG WINNER ,ADVENTURER>
    <MOVE ,ADVENTURER ,HERE>
    
    <ASSERT "Adventurer at test room" <==? <LOC ,ADVENTURER> ,TESTROOM>>
    <ASSERT "HERE is test room" <==? ,HERE ,TESTROOM>>
    
    ;"Test flag"
    <ASSERT "Apple has TAKEBIT" <FSET? ,APPLE ,TAKEBIT>>
    
    ;"Test inventory"
    <MOVE ,APPLE ,ADVENTURER>
    <ASSERT "Apple in inventory" <==? <LOC ,APPLE> ,ADVENTURER>>
    
    <TELL CR "All tests completed!" CR>>
