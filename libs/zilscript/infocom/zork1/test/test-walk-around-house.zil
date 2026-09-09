<INSERT-FILE "infocom/zork1/zork1">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    <ASSERT-TEXT "North of House" <CO-RESUME ,CO "walk around the house">>
    <TELL CR "Forward ACTION routine regression completed!" CR>>
