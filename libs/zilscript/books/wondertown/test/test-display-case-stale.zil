"Regression: DISPLAY-CASE always lists soldier and music box even after they are taken."

<INSERT-FILE "books/wondertown/wondertown">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Arrange: move to countertop, open case, take both items."
    <SETG HERE ,COUNTERTOP>
    <MOVE ,WINNER ,COUNTERTOP>
    <FSET ,DISPLAY-CASE ,OPENBIT>
    <MOVE ,TIN-SOLDIER ,WINNER>
    <MOVE ,MUSIC-BOX ,WINNER>

    ;"Bug observed: examine display case still says
    ;  'Inside, you can see a brave tin soldier and a silver music box'
    ;  even though both items are in the player inventory."
    ;"Expected: examine should NOT list items that are no longer inside."
    <ASSERT-NOT-TEXT "tin soldier" <CO-RESUME ,CO "examine display case">>
    <ASSERT-NOT-TEXT "music box" <CO-RESUME ,CO "examine display case">>

    ;"Also check look-in after items removed."
    <ASSERT-TEXT "empty" <CO-RESUME ,CO "look in display case">>
>
