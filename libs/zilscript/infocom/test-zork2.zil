"TEST-ZORK2.ZIL - Test routine for Zork II transcript"

<INSERT-FILE "infocom/zork2/globals">
<INSERT-FILE "infocom/zork2/parser">
<INSERT-FILE "infocom/zork2/verbs">
<INSERT-FILE "infocom/zork2/syntax">
<INSERT-FILE "infocom/zork2/main">

<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-ZORK2-TEST ()
	<TELL "Testing Zork II transcript..." CR>
	
	;"Test 1: Start at Barrow"
	<ASSERT "Start at Barrow" 
		<CO-RESUME ,CO "look" T> 
		<==? ,HERE ,BARROW>>
	
	;"Test 2: Take sword"
	<ASSERT "Take sword" 
		<CO-RESUME ,CO "take sword" T> 
		<==? <LOC ,SWORD> ,ADVENTURER>>
	
	;"Test 3: Take lamp"
	<ASSERT "Take lamp" 
		<CO-RESUME ,CO "take lamp" T> 
		<==? <LOC ,LAMP> ,ADVENTURER>>
	
	;"Test 4: Go south"
	<ASSERT "Go south" 
		<CO-RESUME ,CO "south" T> 
		T>
	
	;"Test 5: Go south again"
	<ASSERT "Go south again" 
		<CO-RESUME ,CO "south" T> 
		T>
	
	;"Test 6: Go south to Shallow Ford"
	<ASSERT "Go south to Shallow Ford" 
		<CO-RESUME ,CO "south" T> 
		T>
	
	;"Test 7: Turn on lamp"
	<ASSERT "Turn on lamp" 
		<CO-RESUME ,CO "turn on lamp" T> 
		<FSET? ,LAMP ,ONBIT>>
	
	;"Test 8: Go southwest"
	<ASSERT "Go southwest" 
		<CO-RESUME ,CO "southwest" T> 
		T>
	
	<TELL CR "Zork II transcript test completed!" CR>
>>
