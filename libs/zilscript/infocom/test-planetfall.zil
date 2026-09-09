"TEST-PLANETFALL.ZIL - Test routine for Planetfall transcript"

<INSERT-FILE "infocom/planetfall/globals">
<INSERT-FILE "infocom/planetfall/parser">
<INSERT-FILE "infocom/planetfall/verbs">
<INSERT-FILE "infocom/planetfall/syntax">
<INSERT-FILE "infocom/planetfall/main">

<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-PLANETFALL-TEST ()
	<TELL "Testing Planetfall transcript..." CR>
	
	;"Test 1: Start on Deck 9"
	<ASSERT "Start on Deck 9" 
		<CO-RESUME ,CO "look" T> 
		<==? ,HERE ,DECK-NINE>>
	
	;"Test 2: Wait for explosion"
	<ASSERT "Wait for explosion" 
		<CO-RESUME ,CO "wait" T> 
		T>
	
	;"Test 3: Go west"
	<ASSERT "Go west to escape pod" 
		<CO-RESUME ,CO "west" T> 
		T>
	
	;"Test 4: Get in webbing"
	<ASSERT "Get in webbing" 
		<CO-RESUME ,CO "get in webbing" T> 
		T>
	
	;"Test 5: Wait for pod to land"
	<ASSERT "Wait for pod to land" 
		<CO-RESUME ,CO "wait" T> 
		T>
	
	;"Test 6: Get out of webbing"
	<ASSERT "Get out of webbing" 
		<CO-RESUME ,CO "get out of webbing" T> 
		T>
	
	;"Test 7: Take all"
	<ASSERT "Take all items" 
		<CO-RESUME ,CO "take all" T> 
		T>
	
	;"Test 8: Open door"
	<ASSERT "Open door" 
		<CO-RESUME ,CO "open door" T> 
		T>
	
	;"Test 9: Go up"
	<ASSERT "Go up to courtyard" 
		<CO-RESUME ,CO "up" T> 
		T>
	
	<TELL CR "Planetfall transcript test completed!" CR>
>>
