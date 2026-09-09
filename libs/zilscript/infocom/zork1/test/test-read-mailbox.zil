<INSERT-FILE "infocom/zork1/zork1">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    <ASSERT-TEXT "Opening the small mailbox reveals a leaflet." <CO-RESUME ,CO "open mailbox">>
    <ASSERT "Bare read after opening mailbox does not crash" <CO-RESUME ,CO "read" T>>
    <TELL CR "Read mailbox regression completed!" CR>>
