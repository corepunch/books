<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Observed command: TAKE SMALL KEY -> 'Which small key do you mean, the brass key or the safe key?'"
    ;"Observed follow-up: TAKE SAFE KEY -> 'Which key do you mean, the brass key or the safe key?'"
    ;"Expected: SMALL identifies the brass key; SAFE KEY then takes the distinct safe key."
    <SETG HERE ,DIRECTORS-OFFICE>
    <MOVE ,WINNER ,DIRECTORS-OFFICE>
    <MOVE ,BRASS-KEY ,WINNER>
    <MOVE ,HOLLOW-BOOK ,WINNER>
    <FSET ,HOLLOW-BOOK ,OPENBIT>
    <MOVE ,SAFE-KEY ,HOLLOW-BOOK>

    <ASSERT-TEXT "already have"
                 <CO-RESUME ,CO "take small key">>
    <ASSERT-TEXT "Taken" <CO-RESUME ,CO "take safe key">>
    <ASSERT "TAKE SAFE KEY selects the safe key"
            <==? <LOC ,SAFE-KEY> ,WINNER>>>
