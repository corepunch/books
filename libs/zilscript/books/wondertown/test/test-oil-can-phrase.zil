"Regression: take oil can two-word form fails (parser treats 'oil' as noun)"
<INSERT-FILE "books/wondertown/wondertown">
<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Setup: be in Workshop Floor where OIL-CAN is located"
    <CO-RESUME ,CO "look" T>
    
    ;"Observed during organic play: 'take oil can' returns
    ;  'You can't see any oil can here!' even though the oil can is right there.
    ;Expected: 'Taken.' — the object is described as 'a tiny copper oil can'
    ;and players naturally try 'oil can' as the noun phrase."
    ;"Root cause: OIL-CAN has (SYNONYM CAN OIL OILCAN OIL-CAN) and
    ;  (ADJECTIVE TINY COPPER OIL). The parser treats 'oil' as a noun
    ;  (since it's a synonym) and fails the two-word match."
    
    ;"Test: 'take oil can' should NOT produce the rejection message"
    <ASSERT "take oil can should work"
            <CO-RESUME ,CO "take oil can" T>
            <NOT <EQUAL? <LOC ,OIL-CAN> ,WORKSHOP-FLOOR>>>
>
