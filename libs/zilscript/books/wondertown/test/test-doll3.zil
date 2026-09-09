<INSERT-FILE "books/wondertown/wondertown">
<GLOBAL CO <CO-CREATE GO>>
<ROUTINE RUN-TEST ()
    <CO-RESUME ,CO "look" T>
    <CO-RESUME ,CO "walk east" T>
    <CO-RESUME ,CO "take key" T>
    <CO-RESUME ,CO "wind nutcracker" T>
    <CO-RESUME ,CO "walk up" T>
    <ASSERT "At countertop" <==? ,HERE ,COUNTERTOP>>
    <ASSERT "Marzipan here" <IN? ,MARZIPAN ,COUNTERTOP>>
    <ASSERT-TEXT "button" <CO-RESUME ,CO "examine doll">>
>
