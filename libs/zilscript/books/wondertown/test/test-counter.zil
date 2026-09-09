<INSERT-FILE "books/wondertown/wondertown">
<GLOBAL CO <CO-CREATE GO>>
<ROUTINE RUN-TEST ()
    <CO-RESUME ,CO "look" T>
    <ASSERT "Go to tool bench" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,TOOL-BENCH>>
    <ASSERT "Take key" <CO-RESUME ,CO "take key" T> <==? <LOC ,BERTRAND-KEY> ,ADVENTURER>>
    <ASSERT "Wind nutcracker" <CO-RESUME ,CO "wind nutcracker"> ,BERTRAND-WOUND>
    <ASSERT "Climb to countertop" <CO-RESUME ,CO "walk up" T> <==? ,HERE ,COUNTERTOP>>
    <ASSERT "Doll is here" <IN? ,MARZIPAN ,COUNTERTOP>>
    <ASSERT-TEXT "rag doll" <CO-RESUME ,CO "examine doll">>
>
