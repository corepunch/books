<INSERT-FILE "books/limehouse-killings/limehouse-killings">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"INSPECT remains a verb while the exact long noun INSPECTOR resolves to Lestrade."
    <ASSERT-TEXT "gravel path leads north" <CO-RESUME ,CO "inspect path">>
    <SETG HERE ,ASHWORTH-ENTRANCE-HALL>
    <MOVE ,WINNER ,ASHWORTH-ENTRANCE-HALL>
    <MOVE ,INSPECTOR ,ASHWORTH-ENTRANCE-HALL>
    <SETG INSPECTOR-PRESENT T>
    <ASSERT-TEXT "Inspector Lestrade" <CO-RESUME ,CO "examine inspector">>
    <ASSERT-TEXT "case as a chain" <CO-RESUME ,CO "ask inspector about murder">>

    ;"Natural sensory and manipulation commands reach authored handlers."
    <ASSERT-TEXT "settling timber" <CO-RESUME ,CO "listen">>
    <ASSERT-TEXT "Beeswax" <CO-RESUME ,CO "smell">>
    <ASSERT-TEXT "one bright kitchen bell" <CO-RESUME ,CO "pull bell wire">>

    ;"State-aware descriptions stop advertising removed evidence."
    <SETG HERE ,LIBRARY>
    <MOVE ,WINNER ,LIBRARY>
    <MOVE ,TORN-PAGE ,WINNER>
    <ASSERT-TEXT "clean rectangle" <CO-RESUME ,CO "examine reading desk">>
    <SETG HERE ,GARDEN>
    <MOVE ,WINNER ,GARDEN>
    <MOVE ,FOOTPRINT-CAST ,WINNER>
    <MOVE ,BLOOD-STAINED-KNIFE ,WINNER>
    <ASSERT-NOT-TEXT "cast lies nearby" <CO-RESUME ,CO "examine fountain">>
    <ASSERT-TEXT "where the knife was lodged" <CO-RESUME ,CO "examine hedges">>

    ;"The puzzle box owns a persistent, state-aware room description."
    <SETG HERE ,STUDY>
    <MOVE ,WINNER ,STUDY>
    <SETG LOCKED-BOX-OPENED T>
    <FSET ,LOCKED-BOX ,OPENBIT>
    <ASSERT-TEXT "box lies open among the cold ashes" <CO-RESUME ,CO "look">>
    <ASSERT-NOT-TEXT "small locked box" <CO-RESUME ,CO "look">>

    ;"The kitchen map has only the documented west exit."
    <SETG HERE ,KITCHEN>
    <MOVE ,WINNER ,KITCHEN>
    <ASSERT-TEXT "can't go that way" <CO-RESUME ,CO "east">>

    ;"Wrong accusations are counted safely."
    <SETG WRONG-ATTEMPTS 0>
    <SETG HERE ,DINING-ROOM>
    <MOVE ,WINNER ,DINING-ROOM>
    <ASSERT-TEXT "alibi" <CO-RESUME ,CO "accuse lady">>
    <ASSERT "Wrong accusation counter increments" <==? ,WRONG-ATTEMPTS 1>>
>
