<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    <TELL "Testing test helpers..." CR CR>
    
    ;"Start at Sanitarium Gate"
    <ASSERT "Start at Sanitarium Gate" <CO-RESUME ,CO "look" T> <==? ,HERE ,SANITARIUM-GATE>>
    
    ;"Learn about Blackwood Sanitarium"
    <CO-RESUME ,CO "examine plaque">
    
    ;"The brass plaque is fixed to the gate"
    <ASSERT-TEXT "bolted firmly" <CO-RESUME ,CO "take plaque">>
    <ASSERT "Brass plaque remains on the gate" <==? <LOC ,BRASS-PLAQUE> ,SANITARIUM-GATE>>
    
    ;"Enter Sanitarium Entrance Hall"
    <ASSERT "Enter Sanitarium Entrance Hall" <CO-RESUME ,CO "north" T> <==? ,HERE ,SANITARIUM-ENTRANCE>>
    
    <TELL CR "All test helper tests completed!" CR>>
