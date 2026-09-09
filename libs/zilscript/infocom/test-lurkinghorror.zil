"TEST-LURKINGHORROR.ZIL - Test routine for The Lurking Horror transcript"

<INSERT-FILE "infocom/lurkinghorror/globals">
<INSERT-FILE "infocom/lurkinghorror/parser">
<INSERT-FILE "infocom/lurkinghorror/verbs">
<INSERT-FILE "infocom/lurkinghorror/syntax">
<INSERT-FILE "infocom/lurkinghorror/main">

<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-LURKINGHORROR-TEST ()
	<TELL "Testing The Lurking Horror transcript..." CR>
	
	;"Test 1: Start in Terminal Room"
	<ASSERT "Start in Terminal Room" 
		<CO-RESUME ,CO "look" T> 
		<==? ,HERE ,TERMINAL-ROOM>>
	
	;"Test 2: Talk to hacker"
	<ASSERT "Talk to hacker" 
		<CO-RESUME ,CO "talk to hacker" T> 
		T>
	
	;"Test 3: Examine PC"
	<ASSERT "Examine PC" 
		<CO-RESUME ,CO "examine pc" T> 
		T>
	
	;"Test 4: Turn on PC"
	<ASSERT "Turn on PC" 
		<CO-RESUME ,CO "turn on pc" T> 
		T>
	
	;"Test 5: Type username"
	<ASSERT "Type username" 
		<CO-RESUME ,CO "type 872325412" T> 
		T>
	
	;"Test 6: Type password"
	<ASSERT "Type password" 
		<CO-RESUME ,CO "type uhlersoth" T> 
		T>
	
	;"Test 7: Edit classics paper"
	<ASSERT "Edit classics paper" 
		<CO-RESUME ,CO "edit classics paper" T> 
		T>
	
	;"Test 8: Press help key"
	<ASSERT "Press help key" 
		<CO-RESUME ,CO "press help key" T> 
		T>
	
	;"Test 9: Click urgent box"
	<ASSERT "Click urgent box" 
		<CO-RESUME ,CO "click urgent box" T> 
		T>
	
	;"Test 10: Read paper"
	<ASSERT "Read paper" 
		<CO-RESUME ,CO "read paper" T> 
		T>
	
	<TELL CR "The Lurking Horror transcript test completed!" CR>
>>
