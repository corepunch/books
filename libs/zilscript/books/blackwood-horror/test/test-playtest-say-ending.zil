<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Observed during play: SAY HELLO was rejected and left Patient 189 present."
    ;"Expected: SAY HELLO performs the prepared ending; HELLO and HELLO PATIENT retain stock Zork behavior."
    <SETG HERE ,CHAPEL>
    <MOVE ,WINNER ,CHAPEL>
    <MOVE ,PATIENT-189 ,CHAPEL>
    <MOVE ,ANCIENT-RELIC ,WINNER>
    <MOVE ,STRANGE-SERUM ,WINNER>
    <MOVE ,SYRINGE ,WINNER>
    <SETG GAME-WON <>>

    <CO-RESUME ,CO "hello" T>
    <ASSERT "Bare HELLO does not set the win flag" <NOT ,GAME-WON>>
    <ASSERT "Bare HELLO leaves Patient 189 in the Chapel"
            <IN? ,PATIENT-189 ,CHAPEL>>

    <ASSERT-TEXT "bows his head"
                 <CO-RESUME ,CO "hello patient">>
    <ASSERT "HELLO PATIENT does not set the win flag" <NOT ,GAME-WON>>
    <ASSERT "HELLO PATIENT leaves Patient 189 in the Chapel"
            <IN? ,PATIENT-189 ,CHAPEL>>

    <ASSERT-TEXT "I remember... who I was"
                 <CO-RESUME ,CO "say hello">>
    <ASSERT "SAY HELLO sets the win flag" ,GAME-WON>
    <ASSERT "SAY HELLO removes Patient 189"
            <NOT <IN? ,PATIENT-189 ,CHAPEL>>>
    <ASSERT "SAY HELLO leaves the player in the post-ending Chapel"
            <==? ,HERE ,CHAPEL>>>
