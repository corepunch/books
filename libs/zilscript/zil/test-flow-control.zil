"ZIL Flow Control & Data Structure Tests"
<DIRECTIONS NORTH SOUTH>
<CONSTANT RELEASEID 1>

<OBJECT ADVENTURER
        (DESC "you")
        (SYNONYM ADVENTURER ME SELF)
        (FLAGS)>

<ROOM TESTROOM
      (IN ROOMS)
      (DESC "Test Room")
      (LDESC "A test room for ZIL flow control and data structures.")
      (FLAGS RLANDBIT ONBIT)>

<DEFMAC SPLICE-AND ("ARGS" A)
    <FORM AND !.A>>
<DEFMAC MAKE-ADD (X Y)
    <FORM + .X .Y>>

<ROUTINE RUN-TEST ()
    <TELL "=== ZIL Flow Control & Data Structure Tests ===" CR CR>

    ;"========== Test 1: REPEAT loop =========="
    <TELL "1. REPEAT (no bindings)" CR>
    <SETG REPEAT-CNT 0>
    <REPEAT ()
        <SETG REPEAT-CNT <+ ,REPEAT-CNT 1>>
        <COND (<==? ,REPEAT-CNT 5> <RETURN>)>>
    <ASSERT "REPEAT counts to 5" <==? ,REPEAT-CNT 5>>
    <TELL "  PASS (1)" CR>

    ;"========== Test 2: COND branching =========="
    <TELL "2. COND branching" CR>
    <ASSERT "COND false -> ELSE" <==? <COND (<> 1) (ELSE 2)> 2>>
    <ASSERT "COND true -> first" <==? <COND (T 99)> 99>>
    <ASSERT "COND T catch-all" <==? <COND (<==? 1 2> 0) (<==? 2 3> 0) (T 42)> 42>>
    <ASSERT "COND single clause match" <==? <COND (<==? 3 3> 100)> 100>>
    <ASSERT "COND no match returns false" <NOT <COND (<==? 1 2> 77)>>>
    <TELL "  PASS (5)" CR>

    ;"========== Test 3: DO loop =========="
    <TELL "3. DO loop" CR>
    <SETG DO-SUM 0>
    <DO (I 1 5)
        <SETG DO-SUM <+ ,DO-SUM .I>>>
    <ASSERT "DO 1..5 sum = 15" <==? ,DO-SUM 15>>
    <TELL "  PASS (1)" CR>

    ;"========== Test 4: AND / OR / NOT =========="
    <TELL "4. AND / OR / NOT" CR>
    <ASSERT "AND T T is T" <AND T T>>
    <ASSERT "AND T <> is false" <NOT <AND T <>>>>
    <ASSERT "OR <> T is T" <OR <> T>>
    <ASSERT "OR <> <> is false" <NOT <OR <> <>>>>
    <ASSERT "AND 3xT is T" <AND T T T>>
    <ASSERT "OR 3x<> is false" <NOT <OR <> <> <>>>>
    <ASSERT "NOT <> is T" <NOT <>>
    <ASSERT "NOT T is false" <NOT <NOT T>>>
    <TELL "  PASS (8)" CR>

    ;"========== Test 5: ==? N==? =========="
    <TELL "5. ==? N==?" CR>
    <ASSERT "5 ==? 5 is T" <==? 5 5>>
    <ASSERT "5 ==? 6 is false" <NOT <==? 5 6>>>
    <ASSERT "N==? 5 6 is T" <N==? 5 6>>
    <ASSERT "N==? 5 5 is false" <NOT <N==? 5 5>>>
    <TELL "  PASS (4)" CR>

    ;"========== Test 6: Runtime arithmetic =========="
    <TELL "6. Runtime arithmetic" CR>
    <ASSERT "<+ 5 7> = 12" <==? <+ 5 7> 12>>
    <ASSERT "<- 10 3> = 7" <==? <- 10 3> 7>>
    <ASSERT "<* 4 5> = 20" <==? <* 4 5> 20>>
    <ASSERT "</ 10 3> = 3" <==? </ 10 3> 3>>
    <ASSERT "<+ <* 2 3> 4> = 10" <==? <+ <* 2 3> 4> 10>>
    <TELL "  PASS (5)" CR>

    ;"========== Test 7: DEFMAC expansion =========="
    <TELL "7. DEFMAC expansion" CR>
    <ASSERT "SPLICE-AND T T T -> T" <SPLICE-AND T T T>>
    <ASSERT "SPLICE-AND T <> T -> nil" <NOT <SPLICE-AND T <> T>>>
    <ASSERT "MAKE-ADD 3 5 -> 8" <==? <MAKE-ADD 3 5> 8>>
    <TELL "  PASS (3)" CR>

    ;"========== Test 8: TABLE / GET / PUT =========="
    <TELL "8. TABLE access" CR>
    <SETG TBL <TABLE 10 20 30 40 50>>
    <ASSERT "TABLE GET 0 -> 10" <==? <GET ,TBL 0> 10>>
    <ASSERT "TABLE GET 2 -> 30" <==? <GET ,TBL 2> 30>>
    <PUT ,TBL 1 99>
    <ASSERT "TABLE PUT elem 1, GET 1 -> 99" <==? <GET ,TBL 1> 99>>
    <ASSERT "TABLE unchanged elem 0 -> 10" <==? <GET ,TBL 0> 10>>
    <TELL "  PASS (4)" CR>

    ;"========== Test 9: LTABLE =========="
    <TELL "9. LTABLE" CR>
    <SETG LTBL <LTABLE 10 20 30>>
    <ASSERT "LTABLE GET 0 (len) -> 3" <==? <GET ,LTBL 0> 3>>
    <ASSERT "LTABLE GET 1 -> 10" <==? <GET ,LTBL 1> 10>>
    <ASSERT "LTABLE GET 2 -> 20" <==? <GET ,LTBL 2> 20>>
    <TELL "  PASS (3)" CR>

    ;"========== Test 10: ITABLE =========="
    <TELL "10. ITABLE" CR>
    <SETG ITBL <ITABLE 5>>
    <ASSERT "ITABLE 5 creates table" ,ITBL>
    <TELL "  PASS (1)" CR>

    ;"========== Test 11: Object flags =========="
    <TELL "11. Object flags" CR>
    <ASSERT "TESTROOM has ONBIT" <FSET? ,TESTROOM ,ONBIT>>
    <ASSERT "TESTROOM has RLANDBIT" <FSET? ,TESTROOM ,RLANDBIT>>
    <ASSERT "ADVENTURER no TAKEBIT" <NOT <FSET? ,ADVENTURER ,TAKEBIT>>>
    <TELL "  PASS (3)" CR>

    ;"========== Test 12: MOVE / LOC =========="
    <TELL "12. MOVE / LOC" CR>
    <SETG HERE ,TESTROOM>
    <SETG WINNER ,ADVENTURER>
    <MOVE ,ADVENTURER ,HERE>
    <ASSERT "ADVENTURER at TESTROOM" <==? <LOC ,ADVENTURER> ,TESTROOM>>
    <TELL "  PASS (1)" CR>

    ;"========== Test 13: Comparison operators =========="
    <TELL "13. Comparison operators" CR>
    <ASSERT "G? 10 5 is T" <G? 10 5>>
    <ASSERT "G? 5 10 is false" <NOT <G? 5 10>>>
    <ASSERT "G? 5 5 is false" <NOT <G? 5 5>>>
    <ASSERT "G=? 10 5 is T" <G=? 10 5>>
    <ASSERT "G=? 5 10 is false" <NOT <G=? 5 10>>>
    <ASSERT "G=? 5 5 is T" <G=? 5 5>>
    <ASSERT "L? 5 10 is T" <L? 5 10>>
    <ASSERT "L? 10 5 is false" <NOT <L? 10 5>>>
    <ASSERT "L? 5 5 is false" <NOT <L? 5 5>>>
    <ASSERT "L=? 5 10 is T" <L=? 5 10>>
    <ASSERT "L=? 10 5 is false" <NOT <L=? 10 5>>>
    <ASSERT "L=? 5 5 is T" <L=? 5 5>>
    <TELL "  PASS (12)" CR>

    <TELL CR "=== All Flow Control & Data Structure Tests Passed ===" CR>>

(End of file - total 163 lines)
