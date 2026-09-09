<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Observed command: TAKE PLAQUE -> 'Taken.' despite the plaque hanging on the gate."
    ;"Expected: the bolted plaque refuses removal and remains at SANITARIUM-GATE."
    <SETG HERE ,SANITARIUM-GATE>
    <MOVE ,WINNER ,SANITARIUM-GATE>
    <MOVE ,BRASS-PLAQUE ,SANITARIUM-GATE>
    <ASSERT-TEXT "bolted firmly" <CO-RESUME ,CO "take plaque">>
    <ASSERT "The plaque remains attached to the gate"
            <==? <LOC ,BRASS-PLAQUE> ,SANITARIUM-GATE>>

    ;"Observed command: EXAMINE DRAWING -> 'You used the word drawing in a way that I don't understand.'"
    ;"Expected: DRAWING resolves to the child's crayon drawing and supplies authored detail."
    <SETG HERE ,PATIENT-WARD>
    <MOVE ,WINNER ,PATIENT-WARD>
    <ASSERT-TEXT "yellow sun" <CO-RESUME ,CO "examine drawing">>

    ;"Observed command: EXAMINE CABINETS -> 'You can't see any cabinets here!'"
    ;"Expected: the explicitly described filing cabinets respond in Reception and Administration."
    <SETG HERE ,RECEPTION-ROOM>
    <MOVE ,WINNER ,RECEPTION-ROOM>
    <ASSERT-TEXT "open and empty" <CO-RESUME ,CO "examine cabinets">>
    <SETG HERE ,ADMINISTRATIVE-WING>
    <MOVE ,WINNER ,ADMINISTRATIVE-WING>
    <ASSERT-TEXT "overturned cabinets" <CO-RESUME ,CO "examine cabinets">>

    ;"Observed command: READ WRITING -> 'You used the word writing in a way that I don't understand.'"
    ;"Expected: WRITING resolves to the dried-blood message on the padded wall."
    <SETG HERE ,PADDED-CELL>
    <MOVE ,WINNER ,PADDED-CELL>
    <ASSERT-TEXT "CHAPEL BEYOND THE GARDEN" <CO-RESUME ,CO "read writing">>

    ;"Observed command: READ NAME TAG -> 'You used the word tag in a way that I don't understand.'"
    ;"Expected: NAME TAG resolves to the straitjacket tag and reveals its date."
    <SETG LIT T>
    <ASSERT-TEXT "1947" <CO-RESUME ,CO "read name tag">>
>
