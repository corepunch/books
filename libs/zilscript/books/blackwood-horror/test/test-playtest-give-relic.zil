<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"The relic alone must not bypass the serum-and-syringe solution."
    <SETG HERE ,CHAPEL>
    <MOVE ,WINNER ,CHAPEL>
    <MOVE ,PATIENT-189 ,CHAPEL>
    <MOVE ,ANCIENT-RELIC ,WINNER>
    <SETG GAME-WON <>>

    <ASSERT-TEXT "serum"
                 <CO-RESUME ,CO "give relic to patient">>
    <ASSERT "The relic alone does not win" <NOT ,GAME-WON>>
    <ASSERT "Patient 189 remains before the full solution"
            <IN? ,PATIENT-189 ,CHAPEL>>

    ;"With all three linked objects, GIVE remains a natural solution command."
    <MOVE ,STRANGE-SERUM ,WINNER>
    <MOVE ,SYRINGE ,WINNER>
    <ASSERT-TEXT "I remember... who I was"
                 <CO-RESUME ,CO "give relic to patient">>
    <ASSERT "Complete GIVE solution sets the win flag" ,GAME-WON>
    <ASSERT "Complete GIVE solution removes Patient 189"
            <NOT <IN? ,PATIENT-189 ,CHAPEL>>>
    <ASSERT "Complete GIVE solution leaves the player in the Chapel"
            <==? ,HERE ,CHAPEL>>>
