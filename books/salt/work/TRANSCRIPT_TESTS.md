# Transcript tests

The book has no parser. A step is a published choice. `continue` and `retry`
are the buttons. `hold:ledger` taps the carried book. Any other token is the
choice's target page, which is what the headless test sends. Checks are
invisible: choosing one publishes the page they resolve to.

`tests/test_salt.py` plays these. It also checks the page graph: no passage
Continues into another passage, every decision has two circles with different
targets, and every hub has three.

## Best ending

1. continue — leave Edith. Office. The door is absent.
2. office-file, continue — READ. The door is offered. Five circles.
3. office-phone, continue. office-lamp, continue. Neither sets a fact.
4. window-seen, continue — the clip, then the office. SEEN.
5. office-door, continue — the wharf.
6. water-seen, continue — the face. GLIMPSED.
7. marsh-intro, continue — the clip, then his deck. Thomas, the Patience, the floor. HEARD.
8. dock-back — the wharf. shack-check. shack-coat, continue. shack-ledger, continue — KNEW, the bare shack.
9. hold:ledger, hold:ledger — the shack has no reading circle. dock-back — the wharf with the book.
10. marsh-intro — no clip this time. hold:ledger, marsh-refuse, continue — he refuses. The hour is unspent. dock-back.
11. hold:ledger, hold:ledger. lane-shut, continue — the alley.
12. alley-window, continue — the bakery clip. alley-board, continue — BOARD.
13. penry. penry-thomas, continue — the line leaves. penry-chalk, continue — PENRY, and the bridge line appears. penry-bridge, continue — that line leaves. That's all remains.
14. hold:ledger, alley — he shuts the door. sluice-entry — the warned bridge.
15. sluice-look, continue. sluice-grate, continue — PEG. hold:ledger, hold:ledger.
16. landing-entry — he is under the lamp. hold:ledger, hold:ledger. landing-window, continue.
17. lamp-meet, continue — he walks off. The landing is empty. lamp-still, continue — the peg's line.
18. hall, continue — the dry room, the visit plate.
19. locket, continue. office-look, continue. office-remind, continue.
20. hold:ledger, best-check — success, the full last page. No clip.

## Quiet ending

Folder, door, ledger, lane, bridge, stair, door, hold, folder. No window, no
water, no Marsh. Success, the shorter last page. The landing is empty.

## Failures and the partial

- Lane from the first wharf, before the book: dull failure. Retry returns to that wharf with empty hands.
- Trap from the shack before the take: failure, clip `below`. Retry returns to the shack. The book is still on the table.
- Trap from the bare shack: failure, the hour was in the coat. Retry returns there, book carried.
- On the wharf with the book, hold it and choose the water: the face stays. Retry returns to that wharf.
- Hold it and choose the fog: the street clip, then the bend. The hill is the partial. The coat is the failure. Either retry returns to the wharf with the book.
- On the footbridge, hold the book and choose the water: a pale face turns up. No clip. Retry returns to that bridge.
- On the landing, hold the book and choose the lamp: he is beside you. No clip. Retry returns to the landing you entered.
- In the dry room, hold it and choose the window: the latch. Retry returns to the dry room with the book.
- In the dry room, the door goes back to the wharf with the book.
- A second look at the water, and a second look at the office window, are stills.

## Ledger line

After the face has been seen, holding the book on the wharf speaks of the tide
and his name. Before that, it speaks of the hour and the dry room. On the
wharf the open book shows To the water, To the fog, The lane, and The mate.
The shack is not among them.

## Systems

Retry never keeps a fact or a take that happened after the snapshot. The
best-ending check is the only page that reads SEEN, GLIMPSED, and HEARD
together. No clip page is a check. The clips are visit, window, marsh, water,
below, street, and bakery. Each file is at least five seconds.
