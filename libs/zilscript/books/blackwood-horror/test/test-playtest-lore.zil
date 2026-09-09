<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Observed state: TAKE set TOUCHBIT before EXAMINE, suppressing the straitjacket's first-time prose and lore increment."
    ;"Expected: lore discovery uses a dedicated flag and survives taking the object first."
    <SETG HERE ,PADDED-CELL>
    <MOVE ,WINNER ,PADDED-CELL>
    <MOVE ,STRAITJACKET ,WINNER>
    <FSET ,STRAITJACKET ,TOUCHBIT>
    <SETG STRAITJACKET-LORE <>>
    <SETG PATIENT-LORE 0>
    <ASSERT-TEXT "handwriting seems... familiar"
                 <CO-RESUME ,CO "examine straitjacket">>
    <ASSERT "First examination increments lore after TAKE"
            <==? ,PATIENT-LORE 1>>
    <ASSERT-TEXT "name on the tag is illegible"
                 <CO-RESUME ,CO "examine straitjacket">>
    <ASSERT "Repeat examination does not increment lore"
            <==? ,PATIENT-LORE 1>>

    ;"Observed state: PATIENT-LORE was numeric zero, but the mirror still printed the changed-reflection prose."
    ;"Expected: zero lore shows the ordinary mirror; positive lore shows the shifting reflection."
    <SETG HERE ,OBSERVATION-DECK>
    <MOVE ,WINNER ,OBSERVATION-DECK>
    <SETG LIT T>
    <SETG PATIENT-LORE 0>
    <ASSERT-TEXT "throne of suffering" <CO-RESUME ,CO "examine mirror">>
    <SETG PATIENT-LORE 1>
    <ASSERT-TEXT "reflection is barely visible" <CO-RESUME ,CO "examine mirror">>

    ;"Observed state: taking the patient file set TOUCHBIT, so reading it did not add its lore point."
    ;"Expected: the patient file's dedicated discovery flag increments lore exactly once."
    <SETG HERE ,RECEPTION-ROOM>
    <MOVE ,WINNER ,RECEPTION-ROOM>
    <MOVE ,PATIENT-FILE ,WINNER>
    <FSET ,PATIENT-FILE ,TOUCHBIT>
    <SETG PATIENT-FILE-LORE <>>
    <SETG PATIENT-LORE 0>
    <ASSERT-TEXT "Patient transferred to chapel"
                 <CO-RESUME ,CO "read patient file">>
    <ASSERT "Reading a taken patient file increments lore"
            <==? ,PATIENT-LORE 1>>
>
