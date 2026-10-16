# Transcript tests

The book has no parser. A step is a published choice. `continue` and `retry` are the buttons. `hold:ledger` taps the carried book. Any other token is the choice's target page, which is what the headless test sends. Checks are invisible: choosing one publishes the page they resolve to.

## Best ending

1. continue — leave Edith. Office. The door is absent.
2. office-file, continue — READ. The door is offered.
3. office-window, continue — SEEN.
4. office-door, continue — the wharf.
5. water-seen, continue — the face, then the wharf. GLIMPSED.
6. marsh-route, continue — Marsh, then the wharf. HEARD.
7. shack-check — the shack, book on the table.
8. shack-ledger, continue — KNEW, book carried, bare shack.
9. dock-back — wharf with the book.
10. leave-check, continue — the lane, then the dry room. The book is shut, so the folder reminds.
11. office-remind, continue — still the dry room.
12. hold:ledger — reading circles.
13. best-check — success, clip `return`, the full last page.

## Quiet ending

Skip the window, the water, and Marsh. Folder, door, ledger, lane, hold, folder. Success, the shorter last page.

## Failures and the partial

- Lane from the first wharf, before the book: dull failure. Retry returns to that wharf with empty hands.
- Trap from the shack before the take: failure, clip `below`. Retry returns to the shack. The book is still on the table.
- Trap from the bare shack: failure, the hour was in the coat. Retry returns there, book carried.
- On the wharf with the book, hold it and choose the water: the face stays. Retry returns to that wharf.
- Hold it and choose the lane: partial, clip `street`. Retry returns with the book.
- In the dry room, hold it and choose the window: the latch. Retry returns to the dry room with the book.
- In the dry room, the door, book shut: back on the wharf with the book, not an ending.
- Hold the book and choose Marsh: he refuses. Continue returns to the wharf. The hour is unspent.

## Ledger line

After the face has been seen, holding the book on the wharf speaks of the tide and his name. Before that, it speaks of the hour and the dry room.

## Systems

Retry never keeps a fact or a take that happened after the snapshot. The best-ending check is the only page that reads SEEN, GLIMPSED, and HEARD together, and it cannot be reached without the book. No clip page is a check. Every clip file is at least five seconds.
