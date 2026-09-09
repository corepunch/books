<INSERT-FILE "infocom/zork1/globals">
<INSERT-FILE "infocom/zork1/clock">
<INSERT-FILE "infocom/zork1/parser">
<INSERT-FILE "infocom/zork1/verbs">
<INSERT-FILE "infocom/zork1/actions">
<INSERT-FILE "infocom/zork1/syntax">
<INSERT-FILE "infocom/zork1/dungeon">
<INSERT-FILE "infocom/zork1/main">

<DIRECTIONS NORTH SOUTH>
<CONSTANT RELEASEID 1>

<ROOM TESTROOM
      (IN ROOMS)
      (DESC "Test Room")
      (LDESC "A test room for clock system testing.")
      (FLAGS RLANDBIT ONBIT)>

<ROUTINE TEST-INTERRUPT ()
  <TELL "Interrupt fired!" CR>
  T>

<ROUTINE TEST-DEMON ()
  <TELL "Demon fired!" CR>
  T>

<ROUTINE GO ()
    <SETG HERE ,TESTROOM>
    <SETG LIT T>
    <SETG WINNER ,ADVENTURER>
    <SETG PLAYER ,WINNER>
    <MOVE ,WINNER ,HERE>
    <V-LOOK>
    <MAIN-LOOP>
    <AGAIN>>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    <ASSERT "C_TABLE is defined" ,C-TABLE>
    <ASSERT "C_TABLELEN is defined" ,C-TABLELEN>
    <ASSERT "C_DEMONS is defined" ,C-DEMONS>
    <ASSERT "C_INTS is defined" ,C-INTS>
    <ASSERT "MOVES is defined" <OR <0? ,MOVES> <G? ,MOVES -1>>>
    <TELL CR "All tests completed!" CR>>
