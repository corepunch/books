"ZILCH Feature Tests - Tests for ZILCH-specific ZIL constructs"
<DIRECTIONS NORTH SOUTH EAST WEST>
<CONSTANT RELEASEID 1>

<OBJECT ADVENTURER
        (DESC "you")
        (SYNONYM ADVENTURER ME SELF)
        (FLAGS)>

<ROOM TESTROOM
      (IN ROOMS)
      (DESC "Test Room")
      (LDESC "A test room for ZILCH feature testing.")
      (FLAGS RLANDBIT ONBIT)>

;"============================================"
;"  Compile-time evaluation: %<...>           "
;"============================================"

;"Arithmetic"
<CONSTANT C-ADD %<+ 1 2>>
<CONSTANT C-SUB %<- 10 3>>
<CONSTANT C-MUL %<* 4 5>>
<CONSTANT C-DIV %</ 10 2>>
<CONSTANT C-MIXED %<+ %<* 2 3> 1>>
<CONSTANT C-BIG %<+ 2 0 8 128>>

;"String construction"
<CONSTANT C-STR2 %<STRING "he" "llo">>
<CONSTANT C-STR1 %<STRING "world">>
<CONSTANT C-STR0 %<STRING>>

;"ASCII character"
<CONSTANT C-ASCII-A %<ASCII 65>>
<CONSTANT C-ASCII-B %<ASCII 66>>

;"#BYTE / #WORD storage form"
<CONSTANT C-BYTE %<#BYTE 7>>
<CONSTANT C-WORD %<#WORD 42>>

;"============================================"
;"  GASSIGNED? compile-time check             "
;"============================================"
<SETG G-ZILCH-NOT 0>
%<COND (<GASSIGNED? ZILCH>
        <SETG G-ZILCH-NOT 42>)>
<SETG G-ZILCH-BARE 0>
<COND (%<GASSIGNED? ZILCH>
       <SETG G-ZILCH-BARE 42>)>

;"============================================"
;"  Dollar sign identifiers                   "
;"============================================"
<GLOBAL $DV 42>
<GLOBAL $SV 7>
<GLOBAL $VV T>

;"============================================"
;"  DEFMAC — FORM and SPLICE operators        "
;"============================================"
<DEFMAC SPLICE-AND ("ARGS" A)
    <FORM AND !.A>>
<DEFMAC MAKE-ADD (X Y)
    <FORM + .X .Y>>

<ROUTINE RUN-TEST ()
    <TELL "=== ZILCH Feature Tests ===" CR CR>

    ;"========== Test 1: %<+...> arithmetic =========="
    <TELL "1. Compile-time arithmetic" CR>
    <ASSERT "%<+ 1 2> == 3" <==? ,C-ADD 3>>
    <ASSERT "%<- 10 3> == 7" <==? ,C-SUB 7>>
    <ASSERT "%<* 4 5> == 20" <==? ,C-MUL 20>>
    <ASSERT "%</ 10 2> == 5" <==? ,C-DIV 5>>
    <ASSERT "%<+ %<* 2 3> 1> == 7" <==? ,C-MIXED 7>>
    <ASSERT "%<+ 2 0 8 128> == 138" <==? ,C-BIG 138>>

    ;"========== Test 2: %<STRING ...> =========="
    <TELL "2. Compile-time STRING" CR>
    <ASSERT "%<STRING> == \"\"" <EQUAL? ,C-STR0 "">>
    <ASSERT "%<STRING \"world\"> == \"world\"" <EQUAL? ,C-STR1 "world">>
    <ASSERT "%<STRING \"he\" \"llo\"> == \"hello\"" <EQUAL? ,C-STR2 "hello">>

    ;"========== Test 3: %<ASCII N> =========="
    <TELL "3. Compile-time ASCII" CR>
    <ASSERT "%<ASCII 65> == \"A\"" <EQUAL? ,C-ASCII-A "A">>
    <ASSERT "%<ASCII 66> == \"B\"" <EQUAL? ,C-ASCII-B "B">>

    ;"========== Test 4: GASSIGNED? =========="
    <TELL "4. GASSIGNED? compile-time" CR>
    <ASSERT "ZILCH not assigned" <==? ,G-ZILCH-NOT 0>>
    <ASSERT "Bare %<GASSIGNED? ZILCH> is falsy" <==? ,G-ZILCH-BARE 0>>

    ;"========== Test 5: $ identifiers =========="
    <TELL "5. Dollar sign identifiers" CR>
    <ASSERT "$DV == 42" <==? ,$DV 42>>
    <ASSERT "$SV == 7" <==? ,$SV 7>>
    <ASSERT "$VV is T" ,$VV>

    ;"========== Test 6: #BYTE / #WORD =========="
    <TELL "6. #BYTE/#WORD storage" CR>
    <ASSERT "#BYTE 7 -> 7" <==? ,C-BYTE 7>>
    <ASSERT "#WORD 42 -> 42" <==? ,C-WORD 42>>

    ;"========== Test 7: FORM constructor =========="
    <TELL "7. FORM constructor (MAKE-ADD)" CR>
    <ASSERT "MAKE-ADD 3 5 == 8" <==? <MAKE-ADD 3 5> 8>>
    <ASSERT "MAKE-ADD 10 20 == 30" <==? <MAKE-ADD 10 20> 30>>

    ;"========== Test 8: Splice operator =========="
    <TELL "8. Splice operator (!.A in FORM)" CR>
    <ASSERT "SPLICE-AND T T T == T" <SPLICE-AND T T T>>
    <ASSERT "SPLICE-AND T <> T == nil" <NOT <SPLICE-AND T <> T>>>

    ;"========== Test 9: EMPTY?, LENGTH?, TYPE? =========="
    <TELL "9. EMPTY?, LENGTH?, TYPE?" CR>
    <ASSERT "EMPTY? <> is true" <EMPTY? <>>
    <ASSERT "EMPTY? T is false" <NOT <EMPTY? T>>>
    <ASSERT "LENGTH? <> 5 is false" <NOT <LENGTH? <> 5>>>
    <ASSERT "TYPE? 42 FIX" <TYPE? 42 FIX>>
    <ASSERT "not TYPE? \"hello\" FIX" <NOT <TYPE? "hello" FIX>>>

    ;"========== Test 10: Numeric form <N EXPR> =========="
    <TELL "10. Numeric form (>1 \"ABC\"< etc)" CR>
    <ASSERT "<1 ABC> == A" <EQUAL? <1 "ABC"> "A">>
    <ASSERT "<2 ABC> == B" <EQUAL? <2 "ABC"> "B">>
    <ASSERT "<3 ABC> == C" <EQUAL? <3 "ABC"> "C">>

    ;"========== Test 11: NTH runtime =========="
    <TELL "11. NTH runtime function" CR>
    <ASSERT "NTH(\"hello\",1) == h" <EQUAL? <NTH "hello" 1> "h">>
    <ASSERT "NTH(\"hello\",2) == e" <EQUAL? <NTH "hello" 2> "e">>

    ;"========== Test 12: REST runtime =========="
    <TELL "12. REST runtime function" CR>
    <ASSERT "REST(\"hello\",1) == ello" <EQUAL? <REST "hello" 1> "ello">>
    <ASSERT "REST(\"hello\",4) == o" <EQUAL? <REST "hello" 4> "o">>

    <TELL CR "=== All ZILCH Feature Tests Passed ===" CR>>

(End of file - total 136 lines)
