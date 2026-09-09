"Wondertown Essential Path Walkthrough Test"

<INSERT-FILE "books/wondertown/wondertown">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Act 1 — Workshop Exploration"
    <ASSERT "Start" <CO-RESUME ,CO "look" T> <==? ,HERE ,,WORKSHOP-FLOOR>>
    <ASSERT "Take string" <CO-RESUME ,CO "take string" T> <==? <LOC ,KEY-STRING> ,ADVENTURER>>
    <ASSERT "Take oil can" <CO-RESUME ,CO "take oil-can" T> <==? <LOC ,OIL-CAN> ,ADVENTURER>>
    
    ;"Meet Bertrand"
    <ASSERT "Go to tool bench" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,TOOL-BENCH>>
    <ASSERT "Take Bertrand key" <CO-RESUME ,CO "take key" T> <==? <LOC ,BERTRAND-KEY> ,ADVENTURER>>
    <ASSERT "Wind Bertrand" <CO-RESUME ,CO "wind nutcracker"> ,BERTRAND-WOUND>
    
    ;"Climb to countertop"
    <ASSERT "Climb up" <CO-RESUME ,CO "walk up" T> <==? ,HERE ,COUNTERTOP>>
    <ASSERT "Open display case" <CO-RESUME ,CO "open case"> <FSET? ,DISPLAY-CASE ,OPENBIT>>
    <ASSERT "Take soldier" <CO-RESUME ,CO "take soldier" T> <==? <LOC ,TIN-SOLDIER> ,ADVENTURER>>
    <ASSERT "Take music box" <CO-RESUME ,CO "take music box" T> <==? <LOC ,MUSIC-BOX> ,ADVENTURER>>
    <ASSERT "Take button" <CO-RESUME ,CO "take button" T> <==? <LOC ,BUTTON> ,ADVENTURER>>
    <ASSERT "Give button to doll" <CO-RESUME ,CO "give button to doll"> ,MARZIPAN-BUTTON>
    
    ;"Oil ladder and reach loft" 
    <CO-RESUME ,CO "walk down" T>
    <CO-RESUME ,CO "walk west" T>
    <ASSERT "Oil mechanism" <CO-RESUME ,CO "oil mechanism with oil-can"> ,LADDER-OILED>
    <ASSERT "Climb to loft" <CO-RESUME ,CO "walk up" T> <==? ,HERE ,STORAGE-LOFT>>
    <ASSERT "Open toy box" <CO-RESUME ,CO "open cardboard box"> <FSET? ,TOY-BOX ,OPENBIT>>
    <ASSERT "Take doll arm" <CO-RESUME ,CO "take arm" T> <==? <LOC ,DOLL-ARM> ,ADVENTURER>>
    
    ;"Go outside to Snowy Alley"
    <CO-RESUME ,CO "walk down" T>
    <ASSERT "Go through pet door" <CO-RESUME ,CO "walk north" T> <==? ,HERE ,SNOWY-ALLEY>>
    
    ;"Act 2 — Wrenfold"
    <ASSERT "Go to clock square" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,CLOCK-SQUARE>>
    <ASSERT "Go to mailbox corner" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,MAILBOX-CORNER>>
    <ASSERT "Take letter" <CO-RESUME ,CO "take crumpled letter" T> <==? <LOC ,LETTER> ,ADVENTURER>>
    <ASSERT "Drop letter" <CO-RESUME ,CO "drop crumpled letter" T> <N==? <LOC ,LETTER> ,ADVENTURER>>
    <ASSERT "Take scarf" <CO-RESUME ,CO "take scarf" T> <==? <LOC ,SCARF> ,ADVENTURER>>
    
    ;"Go to scrap-yard"
    <CO-RESUME ,CO "walk west" T>
    <ASSERT "Go to scrap-yard" <CO-RESUME ,CO "walk south" T> <==? ,HERE ,SCRAP-YARD>>
    <ASSERT "Take doll head" <CO-RESUME ,CO "take head" T> <==? <LOC ,DOLL-HEAD> ,ADVENTURER>>
    <ASSERT "Give head to cart" <CO-RESUME ,CO "give head to cart"> ,CART-MOVED>
    
    ;"Enter fox den and befriend Nutmeg"
    <ASSERT "Enter fox den" <CO-RESUME ,CO "walk east" T> <==? ,HERE ,FOX-DEN>>
    <ASSERT "Give scarf to fox" <CO-RESUME ,CO "give scarf to fox"> <G? ,NUTMEG-TRUST 0>>
    <ASSERT "Tell fox about tolliver" <CO-RESUME ,CO "tell fox about tolliver"> T>
    <ASSERT "Take key - trust earned" <CO-RESUME ,CO "take key" T> ,KEY-FOUND>
    
    ;"Return to workshop"
    <CO-RESUME ,CO "walk west" T>
    <CO-RESUME ,CO "walk north" T>
    <CO-RESUME ,CO "walk west" T>
    <CO-RESUME ,CO "walk south" T>
    
    ;"Act 3 — Wind Old Tick and access study"
    <ASSERT "Go up to loft" <CO-RESUME ,CO "walk up" T> <==? ,HERE ,STORAGE-LOFT>>
    <ASSERT "Wind Old Tick" <CO-RESUME ,CO "wind clock"> ,OLD-TICK-HEARD>
    <ASSERT "Wind Old Tick again" <CO-RESUME ,CO "wind clock"> ,STUDY-ACCESS>
    <ASSERT "Go down to workshop" <CO-RESUME ,CO "walk down" T> <==? ,HERE ,WORKSHOP-FLOOR>>
    <ASSERT "Enter study" <CO-RESUME ,CO "walk in" T> <==? ,HERE ,TOLLIVER-STUDY>>
    
    ;"Read diagram and journal"
    <ASSERT "Read diagram" <CO-RESUME ,CO "read diagram"> ,DIAGRAM-READ>
    <ASSERT "Read journal" <CO-RESUME ,CO "read journal"> ,STUDY-JOURNAL-READ>
    
    ;"Enter workshop heart"
    <ASSERT "Go to heart" <CO-RESUME ,CO "walk down" T> <==? ,HERE ,WORKSHOP-HEART>>
    
    ;"Wind the heart"
    <ASSERT "Wind heart" <CO-RESUME ,CO "wind heart"> ,KEY-WOUND>
    
    ;"Place companions"
    <ASSERT "Place soldier" <CO-RESUME ,CO "position soldier"> <G? ,COMPANION-COUNT 0>>
    <ASSERT "Place music box" <CO-RESUME ,CO "position music box"> <G? ,COMPANION-COUNT 0>>
    
    ;"Game won!"
    <ASSERT "Game won" ,GAME-WON>
