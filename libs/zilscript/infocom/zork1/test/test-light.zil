<INSERT-FILE "infocom/zork1/globals">
<INSERT-FILE "infocom/zork1/clock">
<INSERT-FILE "infocom/zork1/parser">
<INSERT-FILE "infocom/zork1/verbs">
<INSERT-FILE "infocom/zork1/syntax">
<INSERT-FILE "infocom/zork1/main">

<DIRECTIONS NORTH SOUTH>
<CONSTANT RELEASEID 1>

<ROOM STARTROOM
      (IN ROOMS)
      (DESC "Start Room")
      (LDESC "A dark test room.")
      (NORTH TO LITROOM)>

<ROOM LITROOM
      (IN ROOMS)
      (DESC "Lit Room")
      (LDESC "A naturally lit room.")
      (SOUTH TO STARTROOM)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT FLASHLIGHT
        (IN ADVENTURER)
        (SYNONYM FLASHLIGHT LIGHT TORCH)
        (DESC "flashlight")
        (FLAGS TAKEBIT LIGHTBIT)
        (ACTION FLASHLIGHT-F)>

<ROUTINE FLASHLIGHT-F ()
    <COND (<VERB? LAMP-ON>
           <FSET ,FLASHLIGHT ,ONBIT>
           <TELL "The flashlight is now on." CR>
           <RTRUE>)
          (<VERB? LAMP-OFF>
           <FCLEAR ,FLASHLIGHT ,ONBIT>
           <TELL "The flashlight is now off." CR>
           <RTRUE>)>>

<OBJECT LANTERN
        (IN STARTROOM)
        (SYNONYM LANTERN LAMP)
        (DESC "lantern")
        (FLAGS TAKEBIT LIGHTBIT)
        (ACTION LANTERN-F)>

<ROUTINE LANTERN-F ()
    <COND (<VERB? LAMP-ON>
           <FSET ,LANTERN ,ONBIT>
           <TELL "The lantern is now lit." CR>
           <RTRUE>)
          (<VERB? LAMP-OFF>
           <FCLEAR ,LANTERN ,ONBIT>
           <TELL "The lantern is now dark." CR>
           <RTRUE>)>>

<OBJECT ROCK
        (IN ADVENTURER)
        (SYNONYM ROCK STONE)
        (DESC "rock")
        (FLAGS TAKEBIT)>

<OBJECT CANDLE
        (IN ADVENTURER)
        (SYNONYM CANDLE)
        (DESC "candle")
        (FLAGS TAKEBIT LIGHTBIT)>

<ROUTINE GO ()
    <SETG HERE ,STARTROOM>
    <SETG WINNER ,ADVENTURER>
    <SETG PLAYER ,WINNER>
    <MOVE ,WINNER ,HERE>
    <FCLEAR ,FLASHLIGHT ,ONBIT>
    <FCLEAR ,LANTERN ,ONBIT>
    <FCLEAR ,CANDLE ,ONBIT>
    <V-LOOK>
    <MAIN-LOOP>
    <AGAIN>>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"--- Basic light source tests (LIGHT/EXTINGUISH verbs) ---"
    <ASSERT-TEXT "pitch black" <CO-RESUME ,CO "look">>
    <ASSERT "Light flashlight" <CO-RESUME ,CO "light flashlight" T> <FSET? ,FLASHLIGHT ,ONBIT>>
    <ASSERT "Look with light on" <CO-RESUME ,CO "look" T> <==? ,HERE ,STARTROOM>>
    <ASSERT "Extinguish flashlight" <CO-RESUME ,CO "extinguish flashlight" T> <NOT <FSET? ,FLASHLIGHT ,ONBIT>>>
    <ASSERT-TEXT "pitch black" <CO-RESUME ,CO "look">>
    <ASSERT "Light flashlight again" <CO-RESUME ,CO "light flashlight" T> <FSET? ,FLASHLIGHT ,ONBIT>>
    <ASSERT "Take the lantern" <CO-RESUME ,CO "take lantern" T> <==? <LOC ,LANTERN> ,ADVENTURER>>
    <ASSERT "Check inventory for flashlight" <CO-RESUME ,CO "inventory" T> <==? <LOC ,FLASHLIGHT> ,ADVENTURER>>

    ;"--- TURN ON object without LIGHTBIT: must fail, ONBIT must not be set ---"
    <ASSERT-TEXT "can't turn that on" <CO-RESUME ,CO "turn on rock">>
    <ASSERT "Rock has no ONBIT after failed turn on" <NOT <FSET? ,ROCK ,ONBIT>>>
    <ASSERT-TEXT "can't turn that off" <CO-RESUME ,CO "turn off rock">>

    ;"--- TURN ON/OFF with LIGHTBIT: success and ONBIT flag checks ---"
    <ASSERT "Candle has no ONBIT initially" <NOT <FSET? ,CANDLE ,ONBIT>>>
    <ASSERT "Turn on candle sets ONBIT" <CO-RESUME ,CO "turn on candle" T> <FSET? ,CANDLE ,ONBIT>>
    <ASSERT-TEXT "already on" <CO-RESUME ,CO "turn on candle">>
    <ASSERT "Candle still has ONBIT after already-on attempt" <FSET? ,CANDLE ,ONBIT>>
    <ASSERT "Turn off candle clears ONBIT" <CO-RESUME ,CO "turn off candle" T> <NOT <FSET? ,CANDLE ,ONBIT>>>
    <ASSERT-TEXT "already off" <CO-RESUME ,CO "turn off candle">>
    <ASSERT "Candle still has no ONBIT after already-off attempt" <NOT <FSET? ,CANDLE ,ONBIT>>>

    ;"--- Room lighting: dark room without any light source ---"
    <CO-RESUME ,CO "extinguish flashlight" T>
    <ASSERT-TEXT "pitch black" <CO-RESUME ,CO "look">>

    ;"--- Room lighting: dark room with lit light source in inventory ---"
    <ASSERT "Turn on candle in dark room sets ONBIT" <CO-RESUME ,CO "turn on candle" T> <FSET? ,CANDLE ,ONBIT>>
    <ASSERT-TEXT "dark test room" <CO-RESUME ,CO "look">>

    ;"--- Room lighting: dark room with lit light source placed in room ---"
    <CO-RESUME ,CO "drop candle" T>
    <ASSERT "Candle still has ONBIT after being dropped" <FSET? ,CANDLE ,ONBIT>>
    <ASSERT-TEXT "providing light" <CO-RESUME ,CO "look">>

    ;"--- Room lighting: naturally lit room (ONBIT flag on room) ---"
    ;"Candle remains in STARTROOM; LITROOM has no carried light source"
    <ASSERT "Move to naturally lit room" <CO-RESUME ,CO "north" T> <==? ,HERE ,LITROOM>>
    <ASSERT "LITROOM has ONBIT flag" <FSET? ,LITROOM ,ONBIT>>
    <ASSERT-TEXT "naturally lit" <CO-RESUME ,CO "look">>

    <TELL CR "All tests completed!" CR>>
