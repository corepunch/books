"TEST-TRANSCRIPTS.ZIL - Test files for Infocom game transcripts"

;"This file contains test routines for verifying game transcripts work correctly."

<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<TELL "Running transcript tests..." CR>
	<TELL "This file provides a framework for testing game transcripts." CR>
	<TELL "Each game should have its own test routine that:" CR>
	<TELL "  1. Starts the game at the correct location" CR>
	<TELL "  2. Executes commands from the transcript" CR>
	<TELL "  3. Verifies the game state after each command" CR>
	<TELL CR>
	<TELL "Transcript files are located in:" CR>
	<TELL "  infocom/zork1/test/zork1.txt" CR>
	<TELL "  infocom/zork2/test/zork2.txt" CR>
	<TELL "  infocom/zork3/test/zork3.txt" CR>
	<TELL "  infocom/planetfall/test/planetfall.txt" CR>
	<TELL "  infocom/lurkinghorror/test/lurkinghorror.txt" CR>
	<TELL "  infocom/spellbreaker/test/spellbreaker.txt" CR>
	<TELL CR>
	<TELL "To run a specific game test, use:" CR>
	<TELL "  RUN-ZORK1-TEST" CR>
	<TELL "  RUN-ZORK2-TEST" CR>
	<TELL "  RUN-ZORK3-TEST" CR>
	<TELL "  RUN-PLANETFALL-TEST" CR>
	<TELL "  RUN-LURKINGHORROR-TEST" CR>
	<TELL "  RUN-SPELLBREAKER-TEST" CR>
>>
