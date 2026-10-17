# The Salt Ledger — the game

Every place the reader can stand, what can be touched, asked and shown there,
and what each thing opens. [DESIGN.md](DESIGN.md) owns the premise, the voice
and the mood. This file is the game. The played XML is `title.xml` and
`locations/*.xml`; the routes are [WALKTHROUGH.md](WALKTHROUGH.md).

This pass is a structure to playtest. Every still and clip is a placeholder
(see "Placeholders" at the end); the prose a clip will show is printed on it.

## The model: The X-Files Game

The book follows *The X-Files Game* (HyperBole, 1998) in shape, not only in
the XML's names. Read from its database (`~/Developer/ai-tools/xfiles-screen.py`
over the CD, extracted to `~/Desktop/XFiles_CD1/extracted/index.json`):

| | *The X-Files Game* | This book |
|---|---|---|
| Nodes (acts) | 13; each holds 1–3 locations, plus a global node for the home base and one location per phone call | 3: the evening (the office, the town map, the calls), the harbour, the hill |
| Locations | 44, of which 18 places | 9, of which 7 places |
| Viewpoints per place | 1–50 (the Field Office 21, Comity Inn 8) | 1 per place, 2–3 facings where there is something behind you |
| Views per viewpoint | ~4.8 (N, E, S, W, and diagonals) | 1–3 |
| Navs per view | ~2.4: turn left, turn right, step forward | 1–3: an edge to turn, an anchor to walk |
| Explorables per view | ~0.25: most views are only for moving | ~2: every view has something to look at |
| Characters per place | 0–5 | 0–2 |
| Travel | the PDA map, between places a case has found | the town map and the notebook |
| Records | notes, email, photos, phone numbers | notes and two phone numbers (1924: no email, no camera) |

The play loop is the one the brief in `work/BRIEF.md` describes. You arrive
at a place with several things in it. Most looks are optional, and some open
a lead. You use what you found on people: show evidence, hold a topic, show
your card. A person answers once the subject has been found. Progress is
gated, never narrated. Travel takes one tap once a place is known. Danger is
a place, or a mouth, you chose.

## How a screen works here

- **A view** is a place you stand facing one way. Circles sit on things.
  A circle on the picture's left, right or bottom edge turns you
  (`<nav edge>`); a circle on a door or a lane walks you to another view.
- **A look** is a close-up shot with a clip, then back to the view. A
  **document** (the folder, the ledger, the tide book, the roster, the board,
  the peg) keeps its text and Continue.
- **A person** is a conversation (`<charview>`): lines in a dark band, the
  carried things in a row at the top. Every line is a clip. A topic (an
  idea), a piece of evidence or the card is used by holding it: the band then
  offers only what that thing opens with this person, and the way out.
- **The ledger held open** on a view replaces the circles with the mouths:
  places the hour could be read. All but one are endings.
- **The notebook** (the Map disc) lists the places the case has found, the
  notes, and the telephone keypad. It is not offered in a conversation.

Ground rules carried from `DESIGN.md`: second person, present tense, Crowe is
the camera and is never in frame. Facts only turn on. Captions are short
noun phrases. Six circles at most for any held state.

## Places, things and people

**Nodes and locations.** *Nine o'clock* holds `office`, `town` (the map) and
`calls`. *Berth four* holds `wharf`, `shack` and `tide`. *The hill* holds
`alley`, `sluice` and `landing`.

**Carried things.** In views the row shows inventory and evidence. In
conversations it shows everything carried.

| Icon | Kind | From | Used on |
|---|---|---|---|
| Your card | action | carried from the start | the baker: she opens the door |
| Photograph | evidence | the folder | Marsh (the harbour office opens), Penry, the baker, Edith |
| The floor | idea | Marsh, "Thomas?" | Marsh: the warning and the key |
| The coat | idea | the office window | Marsh: he names it, and Penry later says where the man went |
| A dry room | idea | Marsh, "The Patience?" | Penry: the chain, without the board |
| Brass key | inventory | Marsh, the floor | the shack padlock (used up) |
| Ledger | inventory | the shack table | the mouths; the folder at midnight |
| Peg | evidence | the sluice grating | Edith: the locket clip changes |

**Notes** (the notebook), each delivered by `<enable>`: Edith's rule (the
visit), Thomas Voss (the folder), the Harbor Hotel (Edith), the harbour
office (the operator), the board-keeper (the roster), Marsh's warning, the
ledger.

**Telephone.** Grayhaven 3071, the hotel: Edith, until the ledger is taken;
she points to the harbour office. Grayhaven 214, the harbour office: it rings
and rings. Once you have answered it there, water is on the line. Any other
number is not answered. A call returns to the place you dialled from
(`here`).

**The town map.** Your office (only while the ledger is not carried: the book
goes up the hill on foot), Berth four, the harbour office (once the operator,
Edith, Marsh or the pier names it), Bakery Row (once Marsh, the roster or the
lane names it).

## The chains

**The spine.** The folder (`read`) → the door → berth four → Marsh, "Thomas?"
(`asked`, *The floor*) → hold *The floor* (`heard`, the key) → hold the key on
the padlock (`open`) → the ledger → Bakery Row → Penry's answer, by the board
(`board` → "The chalk?") or by Marsh's word (*A dry room*) (`penry`) → "The
bridge?" (`chain`) → the sluice → the stair → the landing: if he is under
the lamp, the lamp makes him go (`left`) → the door, the hall, midnight → hold
the ledger, "To the folder".

**The best ending** needs `seen` (the office window) and `glimpsed` (the
water at berth four). Without either it is the quiet ending.

**The window chain.** The office window (`seen`, *The coat*). Marsh, holding
the coat, names a clerk's coat (`walker`). Penry's "Thomas?" then says where
he went (`warned`), and the lamp clip at the landing knows it. `seen` also
puts him under the landing lamp, and puts the twin of the coat on the hook
in the shack.

**The water chain.** The water at berth four (`glimpsed`). Marsh's "Thomas?"
is the face clip instead, and it counts toward the best ending.

**The bakery chain.** The baker will not talk to a stranger. Holding your
card, she does (`sight`), and the sluice grating then holds the peg. The peg
changes Edith's locket clip and the lamp close-up at the landing.

**The harbour office chain** (optional). The tide book (`tide`) opens Edith's
"He wrote it twice" at midnight. The roster names Penry and opens Bakery Row.
The telephone there answers with water (`rang`), and the 214 call changes.

## 1. The office (`office`)

Start: shot `visit`, then the conversation **Edith** (camera `visit`):
"Your brother?" → "The floor?"; "Where will you be?" (the hotel note); "I'll
take the case" → shot `edith-leaves` → the desk.

Viewpoint `desk-spot`, three facings:

- **desk** (`office`, n): The folder (document; `read`, Photograph, note), The
  telephone (the operator; note, the harbour office on the map), The lamp.
  Edges: The window (right), The door (left).
- **window-side** (`office-window`, e): The window (first time the man under
  the lamp: `seen`, *The coat*; then empty glass), Her chair. Edge: The desk.
- **door-side** (`office-door`, w): The door (the town map once `read`; before
  that a shot of the hand on the knob), Call it a night (**E1 Home**). Edge:
  The desk.

Midnight, view **dry-room** (`midnight`): Edith (conversation
`edith-midnight`: The locket, or the peg version; "He wrote it twice" if
`tide`; holding the Photograph, the peg or the ledger, her answer; "Not
yet"), The window, The door (back down to the landing). Holding the ledger:
To the folder (**E7 Best** or **E8 Quiet**), To the glass (**E9 The glass**).

## 2. The town map (`town`) and the calls (`calls`)

Map `town` (`town-map`): the four destinations above. Calls: `call-edith`,
`call-tide-ring`, `call-tide-water`, then `phone-back`.

## 3. Berth four (`wharf`)

Viewpoint `pier`:

- **berth** (`wharf`, n): The water (first time the face: `glimpsed`), Marsh
  (first time his approach, then the conversation), The shack (the padlock
  shot until `open`). Holding the key: The padlock (opens it). Holding the
  ledger: To the water (**E2 The harbour**). Edge: The pier head.
- **pier-head** (`pier-head`, s): The harbour office, The lane (to Bakery
  Row). Holding the ledger: To the fog → `fog-spent` → the bend. Edge: Berth
  four.

**Marsh** (`marsh`): "Thomas?" (`asked`, *The floor*; the face version if
`glimpsed`); holding *The floor*: the warning and the key (`heard`; then a
short repeat); holding *The coat*: `walker`; "The Patience?" (`told`, *A dry
room*); holding the Photograph: the harbour office; holding the ledger: his
palm between the book and the deck. "That's all".

**The bend** (`corner`): The hill (**E10 The stair**, partial), The coat
(**E11 The coat**). Both retry from the pier head.

## 4. The shack (`shack`)

Viewpoint `shack-floor`: **shack** (n): The ledger (taken; document), The
trapdoor (**E3 The floor, unread**). **shack-bare** (n, the ledger gone): The
lamp, The trapdoor (**E4 The floor, read**). **shack-door-side** (s): The coat
(the twin line if `seen`), Outside. The back edge turns between them.

## 5. The harbour office (`tide`)

Viewpoint `counter`: **tide-office** (n): The tide book (document, `tide`),
The telephone (water on the line, `rang`), The window (berth four from
above). Holding the ledger: Into the receiver (**E12 The line**). Edge: The
wall. **tide-wall** (e): The roster (document; note, Bakery Row on the map),
The pier. Edge: The counter.

## 6. Bakery Row (`alley`)

Viewpoint `row`:

- **alley** (n): The board (document, `board`), Penry (first time his
  greeting, then the conversation), The bridge (the chain shot until
  `chain`). Edge: Down the row.
- **alley-down** (s): The bakery (conversation **baker**), The lane (to the
  pier head). Edge: Up the row.

**Penry** (`penry`): "Thomas?" (`named`; if `walker`, where the man went:
`warned`); "The chalk?" if `board` (`penry`); holding *A dry room*: the same
(`penry`); "The bridge?" once `penry` (`chain`: he unhooks it); holding the
Photograph; holding the ledger: he shuts the door. "That's all".

**The baker** (`baker`): "Good evening" (the blind comes down); holding the
card: what came down the sluice (`sight`); holding the Photograph, once she
talks: he went up without his coat. "Good night".

## 7. The sluice (`sluice`)

**bridge** (`sluice`): The water, The grating (dark until `sight`; then the
peg document, Peg), The stair, Bakery Row. Holding the ledger: To the water
(**E5 The sluice**).

## 8. The landing (`landing`)

**landing-man** (if `seen` and not `left`): The lamp (he turns and goes:
`left`; the Penry version if `warned`), The window, The stair. No door: he is
between you and it. **landing-empty**: The lamp (the peg line if carried),
The window, The door (with the ledger the hall, then midnight, then the dry
room; without it, your desk), The stair. Holding the ledger on either: To the
lamp (**E6 The lamp**).

## Endings

| | Page | Kind | Where | Try again returns to |
|---|---|---|---|---|
| E1 | `ending-home` | failure | the door side, Call it a night | the door side |
| E2 | `ending-tide` | failure | berth four, ledger to the water | berth four |
| E3 | `ending-below` | failure | the shack, the trapdoor | the table |
| E4 | `ending-below-knew` | failure | the bare table, the trapdoor | the bare table |
| E5 | `ending-sluice` | failure | the bridge, ledger to the water | the bridge |
| E6 | `ending-lamp` | failure | the landing, ledger to the lamp | the landing as it was |
| E7 | `ending-best` | success | the dry room, to the folder, with `seen` and `glimpsed` | start over |
| E8 | `ending-quiet` | success | the dry room, to the folder | start over |
| E9 | `ending-glass` | failure | the dry room, to the glass | the dry room |
| E10 | `ending-stair` | partial | the bend, the hill | the pier head |
| E11 | `ending-face` | failure | the bend, the coat | the pier head |
| E12 | `ending-line` | failure | the harbour office, into the receiver | the harbour office |

Each ending is a clip carrying its text. Warnings come before each one. E1:
the job is on the desk. E2 and E5: "not to the water". E3: leave the floor
shut, from Edith and from Marsh. E4: the ledger's own line. E6: "not in the
rain", and the man standing there. E9: "not to the glass" (Edith, holding the
ledger). E10 and E11: "not in the rain" and Marsh's "not this fog". E12: the
telephone has already answered with water.

## Facts

| Variable | Set by | Read by |
|---|---|---|
| `here` (int) | entering each place | `phone-back`: a call returns there |
| `asked-edith`, `edith-floor`, `edith-hotel` | Edith's lines | which of her lines remain |
| `read` | the folder | the office door |
| `seen` | the office window | the landing (he is there), the shack coat, E7 |
| `glimpsed` | the water | Marsh's "Thomas?" clip, E7 |
| `met`, `met-penry` | the first approach | later visits skip it |
| `asked` | Marsh, "Thomas?" | his line goes |
| `heard` | Marsh, the floor | his short repeat |
| `walker` | Marsh, the coat | Penry's "Thomas?" clip |
| `told` | Marsh, the Patience | his line goes |
| `open` | the padlock | the shack |
| `tide` | the tide book | Edith's "He wrote it twice" |
| `rang` | the harbour office telephone | the 214 call |
| `board` | the tide board | Penry's "The chalk?" |
| `sight` | the baker, with the card | the grating |
| `named`, `warned` | Penry, "Thomas?" | his line goes; the lamp clip |
| `penry` | Penry, the chalk or the dry room | "The bridge?" |
| `chain` | Penry, the bridge | the bridge |
| `left` | the lamp | the landing door |
| `midnight` | the midnight shot | a call from the office returns to the dry room |

Map destinations `to-tide` and `to-alley` and the notes are enable flags.

## Placeholders

Every camera, clip and icon starts as a placeholder made by
`make placeholders BOOK=salt` (`tools/placeholder.py`). A still is a solid
colour per location, carrying the camera's name and its brief (the `comment`
on the camera in `rooms/grayhaven.blks`). It marks every anchor a circle
uses, labelled. A clip is that colour, darker, with the prose of the pages
that play it, held long enough to read, and a bar that fills. The
projection rig in `rooms/grayhaven.blks` stands every camera of a location
at one spot. It puts the anchors on a plane 4 m ahead; its header comment
says how to place one.

To replace a placeholder, paint `illustrations/<camera>.png` (drawn instead
of the room JPEG), or put a finished `rooms/<camera>.jpg` or
`clips/<clip>.mp4` over it. Files without the placeholder marker are never
overwritten, and placeholders that nothing names any more are removed.
`build/cli/book assets salt` reports each asset as painting, render,
present, placeholder or missing. The previous photographic plates and the
clips filmed for the old screens are in `legacy/` for reuse.
