"Regression: SCRAP-CART non-moved EXAMINE text no longer mentions 'a three-legged horse'
which is in SCRAP-YARD, not in the cart."

<INSERT-FILE "books/wondertown/wondertown">

<GLOBAL CO <CO-CREATE GO>>

<ROUTINE RUN-TEST ()
    ;"Arrange: move to scrap-yard with cart not yet moved."
    <SETG HERE ,SCRAP-YARD>
    <MOVE ,WINNER ,SCRAP-YARD>
    <SETG CART-MOVED <>>

    ;"Fixed: cart description no longer names specific toys not in it."
    <ASSERT-TEXT "broken toys" <CO-RESUME ,CO "examine cart">>
    <ASSERT-TEXT "broken toys" <CO-RESUME ,CO "examine cart">>

    ;"Verify horse is in the room, not in the cart."
    <ASSERT "TOY-HORSE is in SCRAP-YARD, not in SCRAP-CART"
            <AND <IN? ,TOY-HORSE ,SCRAP-YARD>
                 <NOT <IN? ,TOY-HORSE ,SCRAP-CART>>>>
>
