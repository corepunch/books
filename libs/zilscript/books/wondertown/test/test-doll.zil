<INSERT-FILE "books/wondertown/wondertown">
<GLOBAL CO <CO-CREATE GO>>
<ROUTINE RUN-TEST ()
    <CO-RESUME ,CO "look" T>
    <CO-RESUME ,CO "walk east" T>
    <CO-RESUME ,CO "take key" T>
    <CO-RESUME ,CO "wind nutcracker">
    <CO-RESUME ,CO "walk up" T>
    <ASSERT-TEXT "rag" <CO-RESUME ,CO "examine rag doll">>
    <ASSERT-TEXT "one button" <CO-RESUME ,CO "examine marzipan">>
>
