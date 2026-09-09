<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Former PSEUDO words are real scenery objects in the Zork I parser."
    <SETG HERE ,RECEPTION-ROOM>
    <MOVE ,WINNER ,RECEPTION-ROOM>
    <ASSERT-TEXT "bird's nest" <CO-RESUME ,CO "examine nest">>
    <ASSERT-TEXT "soot and old char" <CO-RESUME ,CO "search ashes">>
    <SETG HERE ,OPERATING-THEATER>
    <MOVE ,WINNER ,OPERATING-THEATER>
    <ASSERT-TEXT "Rusty forceps" <CO-RESUME ,CO "examine instruments">>
    <ASSERT-TEXT "Rusty forceps" <CO-RESUME ,CO "examine scalpels">>
    <ASSERT-TEXT "wooden benches" <CO-RESUME ,CO "examine tiers">>

    <SETG HERE ,MORGUE>
    <MOVE ,WINNER ,MORGUE>
    <ASSERT "Canvas bundle remains on the dissection table" <IN? ,CANVAS-BUNDLE ,DISSECTION-TABLE>>
    <ASSERT-TEXT "Patient 237" <CO-RESUME ,CO "examine bundle">>

    ;"Natural bare verb forms reach the intended actions."
    <SETG HERE ,BASEMENT-CORRIDOR>
    <MOVE ,WINNER ,BASEMENT-CORRIDOR>
    <SETG VALVE-TURNED-FLAG <>>
    <ASSERT-TEXT "turn with all your strength" <CO-RESUME ,CO "turn valve">>
    <ASSERT-TEXT "sanitarium answers" <CO-RESUME ,CO "listen">>
    <ASSERT-TEXT "damp stone" <CO-RESUME ,CO "smell">>
    <ASSERT-TEXT "no place to become comfortable" <CO-RESUME ,CO "sit">>

    ;"The boiler's automatic description is the single owner of its current state."
    <SETG HERE ,BOILER-ROOM>
    <MOVE ,WINNER ,BOILER-ROOM>
    <SETG BOILER-FUELED T>
    <SETG BOILER-LIT T>
    <ASSERT-TEXT "boiler is awake now" <CO-RESUME ,CO "look">>
    <ASSERT-NOT-TEXT "cold and silent" <CO-RESUME ,CO "look">>

    ;"Scenery and the legacy HELLO command no longer fall into parser defaults."
    <SETG HERE ,SANITARIUM-GATE>
    <MOVE ,WINNER ,SANITARIUM-GATE>
    <ASSERT-TEXT "lower branches are too high" <CO-RESUME ,CO "climb tree">>
    <ASSERT-TEXT "rusted iron gates" <CO-RESUME ,CO "examine gate">>
    <ASSERT-TEXT "does not mistake it for a farewell" <CO-RESUME ,CO "hello">>

    ;"Post-win descriptions and atmosphere agree with the ending."
    <SETG GAME-WON T>
    <SETG HERE ,CHAPEL>
    <MOVE ,WINNER ,CHAPEL>
    <ASSERT-TEXT "quiet" <CO-RESUME ,CO "listen">>
    <ASSERT-NOT-TEXT "green flame" <CO-RESUME ,CO "look">>
    <ASSERT-NOT-TEXT "help... me" <CO-RESUME ,CO "wait">>

    ;"ASK reaches Patient 189's authored topic dialogue as naturally as TELL."
    <SETG GAME-WON <>>
    <MOVE ,PATIENT-189 ,CHAPEL>
    <ASSERT-TEXT "remember" <CO-RESUME ,CO "ask patient about identity">>
>
