"Dictionary debug test for Zork 2"

<INSERT-FILE "infocom/zork2/gglobals">
<INSERT-FILE "infocom/zork2/gclock">
<INSERT-FILE "infocom/zork2/gparser">
<INSERT-FILE "infocom/zork2/gverbs">
<INSERT-FILE "infocom/zork2/2actions">
<INSERT-FILE "infocom/zork2/gsyntax">
<INSERT-FILE "infocom/zork2/2dungeon">
<INSERT-FILE "infocom/zork2/gmain">
<CONSTANT RELEASEID 1>

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
	<TELL "Dictionary debug test" CR>
	<ASSERT-TEXT "Taken." <CO-RESUME ,CO " TAKE SWORD">>
	<TELL "Moving to find robot..." CR>
	<CO-RESUME ,CO " EAST">
	<CO-RESUME ,CO " EAST">
	<CO-RESUME ,CO " EAST">
	<CO-RESUME ,CO " EAST">
	<CO-RESUME ,CO " EAST">
	<CO-RESUME ,CO " EAST">
	<TELL "Attempting TELL ROBOT TO GO EAST..." CR>
	<CO-RESUME ,CO " TELL ROBOT TO GO EAST">
	<TELL "Done." CR>>
