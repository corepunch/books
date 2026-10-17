# Objects

> Written for the screens before the X-Files structure. [GDD.md](../GDD.md) is the
> game now; this file is kept for its reasoning.

The engine has no parser. A thing the reader can touch is either a choice
anchor or the one carried object. Nouns in the prose that are not anchors are
the picture. They are not a second ledger.

| Thing | Where it starts | What the reader does | Roles |
|---|---|---|---|
| Folder | Office desk, anchor `folder` | Read once. Later, the place the hour is spoken. | Clue, goal |
| Window | Office, anchor `pane` | Look. Later, a wrong mouth for the hour. | Clue, risk |
| Telephone | Office, anchor `phone` | Rings in an empty harbor office. | Optional. No fact |
| Green lamp | Office, anchor `desk-lamp` | The room she meant. | Optional. No fact |
| Office door | Anchor `door` | Opens onto the hill after the folder. From the dry room, goes back to the wharf. | Route |
| Locket | Edith, in the dry room, anchor `locket` | A photograph of Thomas. She shuts it. | Optional. The win closes it |
| Harbor water | Wharf, anchor `water` | Look down. While the ledger is held, a wrong reading. | Clue, risk |
| Fog | Wharf, anchor `fog` | While the ledger is held, read the hour to the lane. | The bend |
| Caleb Marsh | Patience, anchor `mate`. On his deck: `marsh-face`, `marsh-floor`, `marsh-boat`, `marsh-deck`, `marsh-hour` | Questions. With the book open he will not let it be read on the deck. | Clue, warning |
| Shack door | Anchor `shack-door` | Enter. | Route |
| Lane | Anchor `lane` | Empty hands: go home. Book shut: the alley. Book held open, on the wharf: the same climb, beside "To the fog". | Route |
| Ledger | On the shack table, anchor `book`, id `ledger` | Take. Hold to replace the circles with the readings that screen allows. | Clue, tool, the summons |
| Coat | Shack hook, anchor `coat-hook` | Dry on the hook. He did not leave by the door. | Optional. No fact |
| Trap | Shack floor, anchor `trap` | Open. Before or after the hour, he rises. | Risk |
| Shack door out | Anchor `out` | Back to the dock. | Route |
| Tide board | Alley, anchor `alley-board` | A wash of chalk. Sets BOARD. | Unlocks Penry's chalk |
| Bakery window | Alley, anchor `alley-window` | She draws the blind. Clip `bakery`. | Optional. No fact |
| Abel Penry | Alley, anchor `alley-man`. His screen is lines on plate `penry`, not circles | Thomas, then the chalk once the board is read, then the bridge. That's all ends it | The road's sentence. The chalk sets PENRY |
| Bridge | Alley, anchor `alley-bridge` | To the sluice. | Route |
| Sluice water | Anchor `sluice-water` | Look down, or, with the book held, read the hour. | Risk |
| Grating | Anchor `sluice-grate` | A peg cut VOSS. Sets PEG. | The landing's lamp line |
| Sluice stair | Anchor `sluice-stair` | Up to the landing. Also while the book is open. | Route |
| Back to the alley | Anchor `sluice-back` | Down to the alley. | Route |
| Landing lamp | Anchor `landing-lamp` | Him, if the window was taken, until he walks off. Then a still. Held: a wrong reading. | Callback, risk |
| Window opposite | Anchor `landing-window` | Somebody watched, and has gone to bed. | Optional. No fact |
| Office door, outside | Anchor `landing-door` | Into the hall. Also while the book is open. | Route |
| Stair down | Anchor `landing-stair` | Back to the sluice. | Route |
| The hill | Bend, anchor `hill` | Pass the man and climb. The hour has already been spoken. | The partial |
| The coat ahead | Bend, anchor `coat` | Go to the man. | His face in the rain |

The ledger is the only portable object. Its icon is `rooms/item-ledger.jpg`.
Nothing else is carried. The folder, the doors, the trap, and the boat stay
where they are.

Holding the ledger replaces the room circles with the places that hour can be
spoken. Putting it away brings the circles back. A screen with no reading
circle is the wrong room for the hour. On the wharf the fog and the lane are
both offered while the book is open, on anchors `fog` and `lane`.

Close-ups use their own plates: `office-phone`, `office-lamp`, `shack-coat`,
`penry`, `sluice-grate`, `landing-window`, `locket`. The look down at the
sluice stays on the `sluice` plate. Penry's questions are lines on the
`penry` close-up, and his answers play there too. `alley` and `corner` are
the reshoots. `lamp.jpg` is the poster for `clips/lamp.mp4`.
