<INSERT-FILE "infocom/zork1/globals">
<INSERT-FILE "infocom/zork1/clock">
<INSERT-FILE "infocom/zork1/parser">
<INSERT-FILE "infocom/zork1/verbs">
<INSERT-FILE "infocom/zork1/syntax">
<INSERT-FILE "infocom/zork1/main">

<DIRECTIONS NORTH SOUTH EAST WEST UP DOWN IN OUT>
<CONSTANT RELEASEID 1>

<ROOM STARTROOM
      (IN ROOMS)
      (DESC "Start Room")
      (LDESC "A test room for directions.")
      (NORTH TO HALLWAY)
      (IN TO HALLWAY)
      (FLAGS RLANDBIT ONBIT)>

<ROOM HALLWAY
      (IN ROOMS)
      (DESC "Hallway")
      (LDESC "A long hallway.")
      (NORTH TO CLOSET)
      (SOUTH TO STARTROOM)
      (IN TO CLOSET)
      (OUT TO STARTROOM)
      (FLAGS RLANDBIT ONBIT)>

<ROOM CLOSET
      (IN ROOMS)
      (DESC "Closet")
      (LDESC "A small closet.")
      (SOUTH TO HALLWAY)
      (OUT TO HALLWAY)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT APPLE
        (IN STARTROOM)
        (SYNONYM APPLE FRUIT)
        (DESC "apple")
        (FLAGS TAKEBIT VOWELBIT)>

<ROUTINE GO ()
    <SETG HERE ,STARTROOM>
    <SETG LIT T>
    <SETG WINNER ,ADVENTURER>
    <SETG PLAYER ,WINNER>
    <MOVE ,WINNER ,HERE>
    <V-LOOK>
    <MAIN-LOOP>
    <AGAIN>>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    <ASSERT "Look at starting room" <CO-RESUME ,CO "look" T> <==? ,HERE ,STARTROOM>>
    <ASSERT "Move north to hallway" <CO-RESUME ,CO "north" T> <==? ,HERE ,HALLWAY>>
    <CO-RESUME ,CO "look">
    <ASSERT "Move north again to closet" <CO-RESUME ,CO "north" T> <==? ,HERE ,CLOSET>>
    <CO-RESUME ,CO "look">
    <ASSERT "Move south back to hallway" <CO-RESUME ,CO "south" T> <==? ,HERE ,HALLWAY>>
    <ASSERT "Move south to start room" <CO-RESUME ,CO "south" T> <==? ,HERE ,STARTROOM>>
    <ASSERT "Use IN direction" <CO-RESUME ,CO "in" T> <==? ,HERE ,HALLWAY>>
    <ASSERT "Use OUT direction" <CO-RESUME ,CO "out" T> <==? ,HERE ,STARTROOM>>
    <TELL CR "All tests completed!" CR>>
