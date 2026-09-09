"Regression: STUDY-DESK always mentions diagram and journal even after they are taken."

<INSERT-FILE "books/wondertown/wondertown">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Arrange: move to study, put items on desk, then take them."
    <SETG HERE ,TOLLIVER-STUDY>
    <MOVE ,WINNER ,TOLLIVER-STUDY>
    <MOVE ,DIAGRAM ,WINNER>
    <MOVE ,STUDY-JOURNAL ,WINNER>

    ;"Bug observed: examine desk still says
    ;  'An open journal lies among them, alongside a hand-drawn winding diagram'
    ;  even though both items are in the player inventory."
    ;"Expected: examine should NOT list items that are no longer on the desk."
    <ASSERT-NOT-TEXT "open journal" <CO-RESUME ,CO "examine desk">>
    <ASSERT-NOT-TEXT "winding diagram" <CO-RESUME ,CO "examine desk">>
>
