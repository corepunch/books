# The Salt Ledger — walkthrough

Commands are what `tests/test_salt.py` and `build/cli/book play salt` type. A
choice's command is the page it leads to. `continue` finishes a shot (the
clip ended, or the picture was tapped) or puts down a document. `retry` is
Try again or Start over. `hold:ICON` taps a carried thing, and tapping it
again puts it away. `map:open` opens the notebook. Checks are invisible:
choosing one publishes the page it resolves to. Labels the reader sees are
in quotes.

## Best ending

1. `continue` — Edith in the chair. Ask "Your brother?" (`edith-thomas`),
   then "The floor?" (`edith-floor`) and "Where will you be?" (`edith-hotel`),
   `continue` after each. "I'll take the case" (`edith-leaves`), `continue`.
2. The desk. Turn right, "The window" (`window-side`). "The window"
   (`window-seen`), `continue`: the man under the lamp. Sets `seen`, gives
   *The coat*. Turn back, "The desk" (`desk`).
3. "The folder" (`office-file`), `continue`. Sets `read` and gives the
   Photograph. "The telephone" is optional: the operator opens the harbour
   office on the map.
4. Turn left, "The door" (`door-side`). "The door" (`town`): the town map.
   "Berth four" (`berth`).
5. "The water" (`water-seen`), `continue`: the face. Sets `glimpsed`.
6. "Marsh" (`marsh-intro`), `continue`. "Thomas?" (`marsh-thomas-check`),
   `continue`: *The floor*. `hold:floor`, "The floor" (`marsh-floor`),
   `continue`: the warning and the key. "The Patience?" (`marsh-patience`),
   `continue`: *A dry room*. "That's all" (`berth`).
7. `hold:key`, "The padlock" (`shack-unlock`), `continue`: the shack. "The
   ledger" (`shack-ledger`), `continue`. Turn round (`shack-door-side`),
   "Outside" (`berth`).
8. Turn round, "The pier head" (`pier-head`). "The lane" (`alley`).
9. "Penry" (`penry-intro`), `continue`. `hold:dry-room`, "A dry room"
   (`penry-dry`), `continue`. "The bridge?" (`penry-rail`), `continue`: he
   unhooks the chain. "That's all" (`alley`).
10. "The bridge" (`bridge-check`): the sluice. "The stair" (`landing-entry`):
    the man under the lamp.
11. "The lamp" (`lamp-check`), `continue`: he goes. "The door" (`door-check`),
    `continue` (the hall), `continue` (midnight): the dry room.
12. `hold:ledger`, "To the folder" (`best-check`): **E7 Best**.

## Quiet ending

Skip the window and the water. At Bakery Row take the board instead of
Marsh's word: "The board" (`alley-board`), `continue`, then Penry's "The
chalk?" (`penry-wash`). The landing lamp is empty and the door is open at
once. To the folder: **E8 Quiet**.

## Optional

- The harbour office (from the pier head, or the map): "The tide book" opens
  Edith's "He wrote it twice"; "The telephone" answers with water; turn
  right for "The roster" (Penry's name, Bakery Row on the map).
- The baker, down the row: "Good evening" gets the blind. `hold:card`,
  "Your card": what came down the sluice. Then at the sluice "The grating"
  is the peg, which changes Edith's locket and the lamp close-up.
- Marsh holding *The coat* names the coat. Penry's "Thomas?" then says where
  the man went, and the lamp clip says "Where Penry said".
- The telephone: `map:open`, `map:phone`, dial `3071` (Edith, until the
  ledger is taken) or `214` (the harbour office).

## Every other ending

| Ending | From | Commands |
|---|---|---|
| E1 Home | the office door side | `ending-home` |
| E2 The harbour | berth four with the ledger | `hold:ledger`, `ending-tide` |
| E3 The floor, unread | the shack table | `ending-below` |
| E4 The floor, read | the bare table | `ending-below-knew` |
| E5 The sluice | the bridge with the ledger | `hold:ledger`, `ending-sluice` |
| E6 The lamp | the landing with the ledger | `hold:ledger`, `ending-lamp` |
| E9 The glass | the dry room | `hold:ledger`, `ending-glass` |
| E10 The stair | the pier head with the ledger | `hold:ledger`, `fog-spent`, `continue`, `ending-stair` |
| E11 The coat | the same | `hold:ledger`, `fog-spent`, `continue`, `ending-face` |
| E12 The line | the harbour office with the ledger | `hold:ledger`, `ending-line` |
