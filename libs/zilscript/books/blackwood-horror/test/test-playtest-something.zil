<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Observed command: EXAMINE SOMETHING -> 'You used the word something in a way that I don't understand.'"
    ;"Expected: SOMETHING resolves to the figure described in the Chapel as Patient 189."
    <SETG HERE ,CHAPEL>
    <MOVE ,WINNER ,CHAPEL>
    <MOVE ,PATIENT-189 ,CHAPEL>

    <ASSERT-TEXT "PATIENT 189"
                 <CO-RESUME ,CO "examine something">>>
