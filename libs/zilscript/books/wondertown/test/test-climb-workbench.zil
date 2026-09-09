"Regression: climb workbench fails without 'up' (missing CLIMBBIT)"
<INSERT-FILE "books/wondertown/wondertown">
<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Setup: be in Workshop Floor where WORKBENCH is"
    <CO-RESUME ,CO "look" T>
    
    ;"Observed during organic play: 'climb workbench' returns
    ;  'The enormous workbench doesn't lead upward.' but
    ;  'climb up workbench' works correctly.
    ;Expected: Both forms should produce the climbing text."
    ;"Root cause: WORKBENCH has SURFACEBIT but not CLIMBBIT, so the
    ;  parser's CLIMB OBJECT syntax doesn't reach the action handler."
    
    ;"Test: 'climb up workbench' works as baseline"
    <ASSERT-TEXT "scramble" <CO-RESUME ,CO "climb up workbench">>
    
    ;"Test: 'climb workbench' should also produce climbing text"
    <ASSERT-TEXT "scramble" <CO-RESUME ,CO "climb workbench">>
>
