<INSERT-FILE "books/wondertown/wondertown">
<GLOBAL CO <CO-CREATE GO>>
<ROUTINE RUN-TEST ()
    <ASSERT "Start" <CO-RESUME ,CO "look" T> <==? ,HERE ,,WORKSHOP-FLOOR>>
    <ASSERT "Take string" <CO-RESUME ,CO "take string" T> <==? <LOC ,KEY-STRING> ,ADVENTURER>>
>
