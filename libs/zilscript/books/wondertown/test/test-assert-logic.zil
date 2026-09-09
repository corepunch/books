"Test to demonstrate the ASSERT short-circuit bug"
<INSERT-FILE "books/wondertown/wondertown">
<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    <CO-RESUME ,CO "look" T>
    ;"This is how the existing walkthrough test asserts TAKE:
    ;  <ASSERT 'Take string' <CO-RESUME ,CO 'take string' T> <==? <LOC ,KEY-STRING> ,ADVENTURER>>
    ;"
    ;"BUG: ASSERT returns on the first truthy condition. CO-RESUME always returns true
    ;(coroutine resumed), so the state check <==? <LOC ,KEY-STRING> ,ADVENTURER> is NEVER evaluated.
    ;The test passes even when TAKE is broken."
    ;"This test demonstrates the bug by checking the state AFTER the command."
    <CO-RESUME ,CO "take string" T>
    ;"Now check ONLY the state - this should fail if TAKE is broken"
    <ASSERT "TAKE actually works (no RTRUE swallowing)" <==? <LOC ,KEY-STRING> ,ADVENTURER>>
>
