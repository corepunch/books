"Test MAILBOX-CORNER description no longer says east"
<INSERT-FILE "books/wondertown/wondertown">
<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    <CO-RESUME ,CO "look" T>
    <CO-RESUME ,CO "go north" T>
    <CO-RESUME ,CO "go east" T>
    <CO-RESUME ,CO "go east" T>
    ;"Bug fix: description now says 'west' instead of 'east'"
    <ASSERT "At mailbox corner" <==? ,HERE ,MAILBOX-CORNER>>
    ;"East from Mailbox Corner should NOT work (description fixed to say west)"
    <CO-RESUME ,CO "go east" T>
    <ASSERT "East does NOT go to scrap-yard (description was wrong)" <N==? ,HERE ,SCRAP-YARD>>
>
