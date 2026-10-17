# The Salt Ledger — walkthrough

Commands are what `tests/test_salt.py` types. A choice's command is its target
page. `continue` finishes a shot: the clip has ended, or the picture was tapped.
On a document (the folder, the ledger, the board, the peg, the folder again) it
taps Continue. `retry` is Try again or Start over. `hold:ledger` taps the carried
book. Checks are invisible: choosing one publishes the page they resolve to.
Hubs and shots show no prose.

Labels the reader sees are in quotes. The office door is absent until the
folder has been read. Holding the ledger replaces the circles on that screen.

## Best ending

The lamp, the face, and Marsh, then the book, then the three screens home.

1. `continue` — Edith has gone. The office. The door is absent.
2. "The folder" (`office-file`), `continue` — the margin. The door is offered.
3. "The telephone" and "The lamp" are optional and set nothing.
4. "The window" (`window-seen`), `continue` — the man under the lamp. Sets SEEN.
5. "The door" (`office-door`), `continue` — berth four.
6. "The water" (`water-seen`), `continue` — the face turns. Sets GLIMPSED.
7. "The mate" (`marsh-intro`), `continue` — his approach, then the deck.
   "Thomas", "The Patience", and "The floor" (`marsh-floor`). The floor sets HEARD.
8. "The dock" (`dock-back`). "The shack". "The coat" is optional.
   "The ledger" (`shack-ledger`), `continue` — the name and the hour. The book is in the coat.
9. "The door" — the wharf with the book. "The lane" (`lane-shut`), `continue` — the alley.
10. "The window" (`alley-window`) — the blind. "The board" (`alley-board`) sets BOARD.
    "The man" (`penry-greet`), `continue` — he speaks to you. "The chalk" (`penry-chalk`) requires the board and sets PENRY.
11. "The bridge" (`sluice-entry`). Penry's line is in the arrival.
    "The grating" (`sluice-grate`) sets PEG. "The stair" (`landing-entry`).
12. He is under the lamp. "The lamp" (`lamp-meet`), `continue` — he goes down into the fog.
    "The door" (`hall`), `continue` — the dry room. Edith is in the chair.
13. "The folder" (`office-remind`), `continue` — the hour is still shut.
14. `hold:ledger`, "To the folder" (`best-check`).

Edith closes the locket. The streetlamp stays empty, and the floor left shut
does not answer. The visit plate stays a still. Success offers Start over.

## Quiet ending

Skip the window, the water, and Marsh. Exits only.

1. `continue`, "The folder", `continue`, "The door", `continue`.
2. "The shack", "The ledger", `continue`, "The door".
3. "The lane", `continue` — the alley. "The bridge". "The stair". The lamp is empty.
4. "The door", `continue`. `hold:ledger`, "To the folder".

Edith closes the locket. Outside, the rain is only rain. This is also a win.

## The other endings

- **Home.** From the first wharf, before the book, "The lane" (`ending-home`).
  Morning, and the folder is still on the desk. No clip. Retry returns to that
  wharf with empty hands.
- **The floor, unread.** In the shack, "The trapdoor" (`ending-below`) before
  taking the book. The face rises. Clip `below`. Retry returns to the shack.
  The book is on the table.
- **The floor, after the hour.** Take the ledger, then "The trapdoor"
  (`ending-below-knew`). Retry returns to the bare shack with the book carried.
- **The harbor.** On the wharf with the book, `hold:ledger`, "To the water"
  (`ending-tide`). The face turns up and stays. Clip `water`. Retry returns
  to that wharf. The book is put away.
- **The stair.** On the same wharf, `hold:ledger`, "To the fog" (`fog-spent`).
  Clip `street`. `continue`. At the bend, "The hill" (`ending-stair`). Edith
  does not open the locket. Partial. Retry returns to the wharf with the book.
- **The coat.** The same bend, "The coat" (`ending-face`). The face from the
  folder looks back. Failure. Retry returns to that same wharf.
- **The sluice.** On the footbridge, `hold:ledger`, "To the water"
  (`ending-sluice`, or `ending-sluice-heard` after Penry). A pale face turns
  up. The plate stays a still. Retry returns to the bridge you stood on.
- **The lamp.** On the landing, `hold:ledger`, "To the lamp". He is beside you
  before the line is done. No clip. Retry returns to that landing, occupied
  or empty as it was when you entered it.
- **The glass.** In the dry room, `hold:ledger`, "To the glass"
  (`ending-glass`). The latch rises under a hand that is not yours. Retry
  returns to the dry room with the book.

## Not endings

- The dry room's "The door", book shut or open, goes back to the wharf.
- `hold:ledger` and "The mate" on the wharf is Marsh's refusal. `continue`
  returns to the wharf. The hour is unspent. On his deck, "The hour" is the
  same refusal and returns to him.
- A second "The water", after the face has been seen, is a still. The clip
  does not play again. A second "The window" is a still: nothing stands there.
- "The chalk" is absent until the board has been read.
- After the face, holding the book on the wharf mentions the tide beside his
  name. Before the face, it mentions the hour and the dry room.
- The alley, the shack, Penry's doorway, and the bend have no reading circle.
  Open the book there and the circles go away until it is shut again.
  The sluice, the landing, and the dry room keep a way out while it is open.

## Clips

`visit` when Edith gives the rule. `window` on the first look. `water` on the
first look down, and again if the hour is read to the harbor. `marsh` the
first time you go to him. `below` on either trap. `street` when the hour is
read to the fog. `bakery` when the alley window is tapped. Everything else
on the walk home is a still.
