"TEST-ZORK1.ZIL - Test routine for Zork I transcript"

<INSERT-FILE "infocom/zork1/globals">
<INSERT-FILE "infocom/zork1/clock">
<INSERT-FILE "infocom/zork1/parser">
<INSERT-FILE "infocom/zork1/verbs">
<INSERT-FILE "infocom/zork1/syntax">
<INSERT-FILE "infocom/zork1/main">

<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-ZORK1-TEST ()
	<TELL "Testing Zork I transcript..." CR>
	
	;"Test 1: Start at West of House"
	<ASSERT "Start at West of House" 
		<CO-RESUME ,CO "look" T> 
		<==? ,HERE ,WEST-OF-HOUSE>>
	
	;"Test 2: Open mailbox"
	<ASSERT "Open mailbox reveals leaflet" 
		<CO-RESUME ,CO "open mailbox" T> 
		T>
	
	;"Test 3: Take leaflet"
	<ASSERT "Take leaflet" 
		<CO-RESUME ,CO "take leaflet" T> 
		<==? <LOC ,LEAFLET> ,ADVENTURER>>
	
	;"Test 4: Go south"
	<ASSERT "Go south to South of House" 
		<CO-RESUME ,CO "south" T> 
		<==? ,HERE ,SOUTH-OF-HOUSE>>
	
	;"Test 5: Go east"
	<ASSERT "Go east to Behind House" 
		<CO-RESUME ,CO "east" T> 
		<==? ,HERE ,BEHIND-HOUSE>>
	
	;"Test 6: Open window"
	<ASSERT "Open window" 
		<CO-RESUME ,CO "open window" T> 
		T>
	
	;"Test 7: Enter house"
	<ASSERT "Enter house to Kitchen" 
		<CO-RESUME ,CO "enter house" T> 
		<==? ,HERE ,KITCHEN>>
	
	;"Test 8: Go west"
	<ASSERT "Go west to Living Room" 
		<CO-RESUME ,CO "west" T> 
		<==? ,HERE ,LIVING-ROOM>>
	
	;"Test 9: Take lamp"
	<ASSERT "Take lamp" 
		<CO-RESUME ,CO "take lamp" T> 
		<==? <LOC ,LAMP> ,ADVENTURER>>
	
	;"Test 10: Take sword"
	<ASSERT "Take sword" 
		<CO-RESUME ,CO "take sword" T> 
		<==? <LOC ,SWORD> ,ADVENTURER>>
	
	<TELL CR "Zork I transcript test completed!" CR>
>>
