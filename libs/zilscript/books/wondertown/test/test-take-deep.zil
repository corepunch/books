"Test to verify TAKE actually moves objects - tests each TAKE individually"
<INSERT-FILE "books/wondertown/wondertown">
<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    <CO-RESUME ,CO "look" T>
    ;"Test 1: Take string - the action routine should not swallow the TAKE"
    ;"Observed during organic play: 'take string' returns empty output and item stays in room"
    ;"Expected: 'Taken.' message and item moves to inventory"
    <CO-RESUME ,CO "take string" T>
    <ASSERT "String moved to inventory" <==? <LOC ,KEY-STRING> ,ADVENTURER>>
    
    ;"Test 2: Take oil can"
    <CO-RESUME ,CO "take oil-can" T>
    <ASSERT "Oil can moved to inventory" <==? <LOC ,OIL-CAN> ,ADVENTURER>>
    
    ;"Test 3: Take broom"
    <CO-RESUME ,CO "take broom" T>
    <ASSERT "Broom moved to inventory" <==? <LOC ,SWEEP-BROOM> ,ADVENTURER>>
    
    ;"Test 4: Drop string - if TAKE is broken, DROP is also broken"
    <CO-RESUME ,CO "drop string" T>
    <ASSERT "String dropped from inventory" <N==? <LOC ,KEY-STRING> ,ADVENTURER>>
>
