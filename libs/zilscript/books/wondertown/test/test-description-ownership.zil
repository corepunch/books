<INSERT-FILE "books/wondertown/wondertown">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Room-owned scenery and automatic objects compose without repeating the broom/string."
    <ASSERT-TEXT "brass key hook" <CO-RESUME ,CO "look">>
    <ASSERT-TEXT "Your tiny broom leans against the workbench" <CO-RESUME ,CO "look">>
    <ASSERT-NOT-TEXT "Your tiny broom leans against the bench" <CO-RESUME ,CO "look">>
    <ASSERT-NOT-TEXT "A frayed string dangles from the empty key hook" <CO-RESUME ,CO "look">>

    ;"The workbench-top room owns the book's stateful staging; the object must not repeat it."
    <ASSERT-NOT-TEXT "green leather repair book rests closed" <CO-RESUME ,CO "climb workbench">>

    ;"Stateful focal objects own their current descriptions."
    <SETG HERE ,COUNTERTOP>
    <MOVE ,WINNER ,COUNTERTOP>
    <SETG MARZIPAN-BUTTON T>
    <ASSERT "Marzipan has a dynamic description" <GETP ,MARZIPAN ,P?DESCFCN>>
    <ASSERT-TEXT "two mismatched button eyes" <CO-RESUME ,CO "look">>
    <ASSERT-NOT-TEXT "one button eye" <CO-RESUME ,CO "look">>

    <SETG HERE ,WORKSHOP-FLOOR>
    <MOVE ,WINNER ,WORKSHOP-FLOOR>
    <SETG LADDER-OILED T>
    <ASSERT-TEXT "rises smoothly" <CO-RESUME ,CO "examine loft ladder">>
    <ASSERT-NOT-TEXT "rusted solid" <CO-RESUME ,CO "examine loft ladder">>

    <SETG HERE ,TOOL-BENCH>
    <MOVE ,WINNER ,TOOL-BENCH>
    <MOVE ,BERTRAND-KEY ,WINNER>
    <ASSERT-TEXT "low crate" <CO-RESUME ,CO "look">>
    <ASSERT-TEXT "winding socket in his back empty" <CO-RESUME ,CO "look">>
    <ASSERT-NOT-TEXT "spool" <CO-RESUME ,CO "look">>

    <SETG HERE ,STORAGE-LOFT>
    <MOVE ,WINNER ,STORAGE-LOFT>
    <SETG OLD-TICK-HEARD T>
    <ASSERT-TEXT "ticks steadily" <CO-RESUME ,CO "look">>
    <ASSERT-NOT-TEXT "frozen at five to midnight" <CO-RESUME ,CO "look">>

    <SETG HERE ,SCRAP-YARD>
    <MOVE ,WINNER ,SCRAP-YARD>
    <SETG CART-MOVED T>
    <ASSERT-TEXT "rests beside the track" <CO-RESUME ,CO "look">>
    <ASSERT-NOT-TEXT "creaks along a rusted track" <CO-RESUME ,CO "look">>

    ;"Formerly suppressed FDESC prose is visible where it teaches the goal."
    <SETG HERE ,CLOCK-SQUARE>
    <MOVE ,WINNER ,CLOCK-SQUARE>
    <ASSERT-TEXT "hours until dawn" <CO-RESUME ,CO "look">>

    <SETG HERE ,WORKSHOP-HEART>
    <MOVE ,WINNER ,WORKSHOP-HEART>
    <ASSERT-TEXT "At its core, a keyhole waits" <CO-RESUME ,CO "look">>
>
