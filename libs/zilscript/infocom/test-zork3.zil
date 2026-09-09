"TEST-ZORK3.ZIL - Test routine for Zork III transcript"

<SETG ZORK-NUMBER 3>

<INSERT-FILE "infocom/zork3/gglobals">
<INSERT-FILE "infocom/zork3/gclock">
<INSERT-FILE "infocom/zork3/gparser">
<INSERT-FILE "infocom/zork3/gverbs">
<INSERT-FILE "infocom/zork3/gsyntax">
<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND CROSS ENTER>
<INSERT-FILE "infocom/zork3/3actions">
<INSERT-FILE "infocom/zork3/3dungeon">
<INSERT-FILE "infocom/zork3/gmain">

<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<TELL "Testing Zork III transcript..." CR>
	
	;"Test 1: Start at Endless Stairs"
	<ASSERT "Start at Endless Stairs" 
		<CO-RESUME ,CO "look" T> 
		<==? ,HERE ,ENDLESS-STAIRS>>
	
	;"Test 2: Take lamp"
	<ASSERT "Take lamp" 
		<CO-RESUME ,CO "take lamp" T> 
		<==? <LOC ,LAMP> ,ADVENTURER>>
	
	;"Test 3: Go south"
	<ASSERT "Go south to Junction" 
		<CO-RESUME ,CO "south" T> 
		<==? ,HERE ,JUNCTION>>
	
	;"Test 4: Turn on lamp"
	<ASSERT "Turn on lamp" 
		<CO-RESUME ,CO "turn on lamp" T> 
		<FSET? ,LAMP ,ONBIT>>
	
	;"Test 5: Go west"
	<ASSERT "Go west" 
		<CO-RESUME ,CO "west" T> 
		T>
	
	;"Test 6: Go west again"
	<ASSERT "Go west again" 
		<CO-RESUME ,CO "west" T> 
		T>
	
	;"Test 7: Get bread"
	<ASSERT "Get bread" 
		<CO-RESUME ,CO "get bread" T> 
		<==? <LOC ,BREAD> ,ADVENTURER>>
	
	<TELL CR "Zork III transcript test completed!" CR>
>
