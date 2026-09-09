<INSERT-FILE "books/blackwood-horror/blackwood-horror">

<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    <TELL "Testing failing conditions..." CR CR>
    
    ;"Test 1: Drawer cannot be opened without unlocking first"
    ;"Start at Reception Room"
    <SETG HERE ,RECEPTION-ROOM>
    <MOVE ,WINNER ,HERE>
    
    ;"Try opening locked drawer - command should fail, drawer remains closed (no OPENBIT)"
    <ASSERT "Try to open locked drawer (should fail - drawer is locked)" 
        <CO-RESUME ,CO "open drawer" T> 
        <NOT <FSET? ,BOTTOM-DRAWER ,OPENBIT>>>
    
    ;"Test 2: With key, drawer can be unlocked and opened"
    <ASSERT "Take the brass key" 
        <CO-RESUME ,CO "take key" T> 
        <==? <LOC ,BRASS-KEY> ,ADVENTURER>>
    
    ;"The 'unlock' command both unlocks AND opens the drawer (sets OPENBIT)"
    <ASSERT "Unlock drawer with key (opens it)" 
        <CO-RESUME ,CO "unlock drawer with key" T> 
        <FSET? ,BOTTOM-DRAWER ,OPENBIT>>
    
    ;"Test 3: Test at different location - Sanitarium Gate"
    <SETG HERE ,SANITARIUM-GATE>
    <MOVE ,WINNER ,HERE>
    
    <ASSERT "Move to Sanitarium Gate" 
        <CO-RESUME ,CO "look" T> 
        <==? ,HERE ,SANITARIUM-GATE>>
    
    <ASSERT "Verify plaque has no TAKEBIT flag"
        <NOT <FSET? ,BRASS-PLAQUE ,TAKEBIT>>>
    
    <ASSERT-TEXT "bolted firmly" <CO-RESUME ,CO "take plaque">>
    <ASSERT "Plaque stays at the gate"
        <==? <LOC ,BRASS-PLAQUE> ,SANITARIUM-GATE>>
    
    <TELL CR "All failing conditions tests completed!" CR>>
