# The Salt Ledger — screen by screen

Every screen the reader can reach, everything on it that can be tapped, and
what each tap unlocks. [DESIGN.md](DESIGN.md) owns the premise, the voice
and the mood. This file is the game.

How to read an entry:

- **Screen** — the plate (camera name in `rooms/`), what kind of page it is,
  and the prose shown on arrival.
- **Hotspot** — the circle's caption, then what the tap does: a close-up still
  with prose, a clip, a talk screen, a travel, or an ending. Then what it
  needs, what it sets, and where it returns.
- *Held: ledger* — what changes on that screen while the reader holds the
  book open. Holding it replaces the plain circles with the readings the
  screen allows; putting it away brings the circles back.

Ground rules carried from `DESIGN.md`: second person, present tense, Crowe is
the camera and is never in frame. Facts only turn on. One carried thing, the
ledger. Captions are short noun phrases. Six circles at most on a page,
counting the held ones.

**The clip rule.** Tapping a person always plays a clip, and the clip is
where that person gives something: a fact, a key, a warning, a refusal, a
face. That is how The X-Files Game works: every tap on a character is film.
A question on a talk screen is a tap on a person, so each question is its
own clip, with the prose under it as the caption. Objects and places are
stills, with two exceptions that move on their own: the water, and the trap.

**The unlock rule.** Every character interaction does one of two things, and
most do both: it gives information the reader needs for a later choice, or
it opens a circle that was shut. Nothing a person says is only colour. The
model is The Pandora Directive's Ask About tree: the scarf opens Louie, Louie
opens Emily, Emily opens Leach, Leach opens the key.

Settled here: the office is Crowe's. Edith leaves after the visit and comes
back at midnight to hear the hour in his room.

---

## The chains

What gates what. A reader who taps only exits cannot finish; the spine runs
through three people.

**The spine (mandatory):**

1. Edith gives the rule → the folder sets `READ` → the door is offered.
2. The shack is padlocked. Marsh: ask **Thomas** (`ASKED`) before he will
   speak of **the floor**; the floor gives the warning and the key
   (`HEARD`, `OPEN`) → the shack is offered.
3. The ledger (`KNEW`) → the lane climbs instead of ending the night.
4. The footbridge is chained. Penry: **the chalk** needs the board looked at
   (`BOARD`) or Marsh's tip (`TOLD`); it sets `PENRY` → **the bridge**
   drops the chain (`CHAIN`) → the sluice is offered.
5. The landing. If Thomas was seen from the office window he stands under
   the lamp between you and the door; **the lamp** makes him go (`LEFT`) →
   the door is offered.
6. Edith at midnight → the folder with the book open → the win.

**The window chain (optional):** the office window (`SEEN`) → Marsh, **the
coat** (`WALKER`) → Penry's **Thomas** answer changes and says where the
walker went (`WARNED`) → the landing arrival names him. `SEEN` also counts
toward the best ending.

**The water chain (optional):** the harbor (`GLIMPSED`) → Marsh's **Thomas**
answer changes: the floor opens on the same water → the ledger's held line
on the wharf changes → counts toward the best ending.

**The bakery chain (optional):** the bakery woman (`SIGHT`) → the grating
on the sluice is offered (`PEG`) → Edith's locket clip changes at midnight.

**The shortcut:** Marsh's **Patience** answer (`TOLD`) lets Penry be asked
about the chalk without the board.

---

## 1. The office — the visit

Plate `visit` (Edith in the client's chair). Passage. **Clip `visit`:** Edith
across the desk gives the rule, then stands and goes. Poster is the still.

> Edith Voss has come about her brother. Read his hour to her in this room,
> she says, and leave the floor at berth four shut. She will be back at
> midnight.

Continue → **2. The office.**

## 2. The office

Plate `office` (desk, folder, green lamp, telephone, window, door, hat on
the hook). Hub.

> She has gone. The lamp is warm, the folder still shut, and the streetlamp
> across the rain burns in the dark.

- **The folder** — close-up still `office-file`. Sets `READ`. Returns here.
  > Thomas Voss, tide clerk, twenty-eight. Berth four, the trawler Patience.
  > In the margin her pencil reads: the hour, to her, in this room. Not to
  > the water. Not in the rain.
- **The window** — **clip `window`:** through the glass, a man in a wet olive
  coat with brass buttons under the streetlamp, too still for the rain; the
  hand finds the latch; the cobbles are empty. Sets `SEEN`. Returns here.
  On a second tap, the still only:
  > Rain on the glass. The lamp over empty cobbles. Nothing stands there now.
- **The telephone** — close-up still `office-phone`. No fact. The one voice
  with no face, so no clip.
  > The exchange gives you the harbor office. The operator says it rang off
  > at the turn of the tide and has not answered since. The tide clerk is
  > the one who would have picked up.
- **The lamp** — close-up still `office-lamp`. No fact. The rule, said by
  the room.
  > Green glass, a dry blotter, a room with a door that shuts. This is the
  > room she meant.
- **The door** — requires `READ`. Passage on the `office` still.
  > You take your hat from the hook and open the door. The rain takes you
  > down the hill to berth four.

  Continue → **3. The wharf.**

## 3. The wharf

Plate `wharf` (the Patience at her pilings, the shack with its lit window
and a padlocked door, the lane into the fog, black water at the edge). Hub.
Returned to after every dock screen.

Without the book:

> Berth four. The Patience knocks the pilings. The shack window is lit and
> the door is locked. The lane home is a guess in the fog.

With the book in the coat:

> The ledger is in your coat. The lane, with the book shut, climbs to the
> office. Hold it open only to spend the hour on the dock.

- **The water** — first time, **clip `water`:** kneeling at the edge, between
  the pilings something pale turns, the size of a face, and the tide takes
  it. Sets `GLIMPSED`. Returns here.
  > You kneel at the edge. Between the pilings something pale turns, the
  > size of a face, and the tide takes it.

  Second time, the `water` still only:
  > You look again. The harbor keeps what it turned. The name is in the
  > book, not in the tide.
- **The mate** — first time, **clip `marsh`:** Marsh on the deck turns his
  clear eye on the camera and his clouded one on the shack (`MET`). Then →
  **4. Marsh.** Later times go straight to 4.
- **The shack** — requires `OPEN` → **5. The shack** (or **7** if the book
  is carried). Before that, close-up still `shack-door`:
  > A padlock through the hasp, boat-brass, the kind the Patience uses on
  > her lockers. The window is lit for nobody. The mate has the key.

  Returns here.
- **The lane** — without the book: ending **E1 Home.** With the book shut:
  passage on the `street` still:
  > You take the lane with the book shut. The fog lets you pass. The town
  > begins where the planks end.

  Continue → **8. The alley.**

*Held: ledger.* Item line: before the face, "His name, and an hour already
passed. The lane would carry it to a dry room." After the face, "Tonight's
tide is circled beside his name. The face under the pilings is that name."
The circles become:

- **To the water** — ending **E2 The harbor.**
- **To the fog** — passage, **clip `street`:** the lane, and a step that
  matches yours. → **14. The bend.**
- **The lane** — the book shut, as above.
- **The mate** — Marsh refuses it: see 4.

## 4. Marsh

Plate `marsh` (Marsh on the deck of the Patience, his oilskin, the rail, the
shack over his shoulder, the water beside the hull). Talk screen: a hub
whose circles are questions, each on the thing it asks about.

First arrival:

> Marsh keeps his clear eye on you and the clouded one on the shack. He
> knows why you are here. He waits to see which question you start with.

Later arrivals:

> Marsh does not turn. He has said what he has to say, but he will answer
> what is asked.

- **Thomas** (circle on his face) — sets `ASKED`. Returns here. The clip
  depends on what you have seen:

  Without `GLIMPSED`, **clip `marsh-thomas`:** he answers without looking at
  the shack, then does look at it, once.
  > "He kept the tide. He came down for his hour and did not come up."
  > He nods at the shack without looking at it. "Nothing went in the water
  > from this deck. Ask me about the floor if you want the rest."

  With `GLIMPSED`, **clip `marsh-face`:** he looks at the water where you
  knelt, then at you.
  > "You looked, then. Then you know what the floor in there opens on. Same
  > water. Nearer." He does not say the name. "Ask me about the floor."
- **The floor** (circle on the shack door behind him) — requires `ASKED`.
  **Clip `marsh-floor`:** he turns the clouded eye full on the camera for
  the warning, steps down off the deck, and his hand with a brass key goes
  to the padlock on the shack door; it drops open. Sets `HEARD`, `OPEN`.
  Returns here.
  > "The book is on the table. Leave the floor. Read the hour to the woman
  > up the hill." He steps off the boat and the padlock drops open under his
  > hand. "The rain is not a room."

  Once `HEARD`, the same circle is the short repeat, on the still. He does
  not turn, and that is the point:
  > You heard him. The table, not the floor, and not a word of the hour
  > where the water can listen.
- **The coat** (circle on his oilskin) — requires `SEEN`. **Clip
  `marsh-coat`:** he looks down at his own coat and then up the hill. Sets
  `WALKER`. Returns here.
  > "Olive, with brass buttons? That's a tide clerk's coat. The harbor
  > issues them." He looks up the lane. "He's still wearing his, then.
  > Penry at the board will have seen him go up."
- **The Patience** (circle on the rail or the wheelhouse) — **clip
  `marsh-patience`:** he pats the rail, and the boat knocks the pilings
  once. Sets `TOLD`. Returns here.
  > "She stays tied till his name's read somewhere dry. Not my rule." He
  > pats the rail. "Penry keeps the board up the hill, and the sluice
  > chain. He'll want to know where you mean to read it before he lets you
  > over. Tell him: a dry room."
- **The dock** (circle on the planks at the bottom of frame) — travel →
  **3. The wharf.**

*Held: ledger.* The question circles are replaced by one:

- **The hour** (circle on the open book) — **clip `marsh-hour`:** his palm
  comes into frame between the book and the deck and stays there until the
  book is shut. Returns to 4 with the book put away. The hour is not spent.
  > Marsh puts a palm between the ledger and the deck. "Dry room," he says.
  > "Her voice waiting. Not this boat, and not this fog."

Five plain circles and one held: six.

## 5. The shack

Plate `shack` (lamp, table, the ledger, the rope ring in the boards, a coat
on a hook, the door). Hub. Reached only with `OPEN`.

> A lamp, a table, a ledger blotched with tidewater. A rope handle marks the
> boards over the harbor.

- **The ledger** — takes the book. Close-up still `shack-ledger`. Sets
  `KNEW`. Continue → **7. The shack, bare.**
  > The tide has taken the ink. What is left is the dent of a name, Thomas
  > Voss, and the dent of an hour already passed. Under it, in the folder's
  > hand: say it where the floor is dry.
- **The coat** (on the hook) — close-up still `shack-coat`. No fact. The
  clue that he did not leave by the door.
  > A tide clerk's coat, olive, brass buttons, dry on its hook. His hat is
  > under it. Nobody walked out of here into this rain.

  (If `SEEN`: the man under the lamp wore this coat, and this coat is here.
  Add one sentence: "The one under your window was wearing its twin.")
- **The trapdoor** — ending **E3 The floor, unread.**
- **The door** — travel → **3. The wharf.**

## 6. The open ledger

Plate `shack-ledger`. The close-up reached from 5. Continue → 7.

## 7. The shack, bare

Plate `shack-bare`. Hub.

> The ledger is in your coat. The lamp burns. The rope in the floor waits,
> and the door is behind you.

- **The coat** — as in 5.
- **The trapdoor** — ending **E4 The floor, read.**
- **The door** — travel → **3. The wharf** (with the book).

*Held: ledger.* Item line: "His name, the hour, and her line under it. This
floor is a door onto the harbor." No reading circle. The shack is the wrong
room, and the line under his name says so.

## 8. The alley

Plate `alley` (reshoot). In frame: the lit doorway with Abel Penry in it,
the laundry overhead, the tide board under its porch, the bakery window
down the street, the bridgehead with a chain across it. Hub.

> The lane becomes an alley. A man stands in a lit doorway and will not look
> at you. Under the porch across from him a tide board runs with chalk, and
> at the end of the alley a chain hangs across the bridge.

- **The board** — close-up still `board`. Sets `BOARD`. Returns here.
  > The board is a wash of chalk. Pegs for the boats, lines for the hours,
  > and nothing left in either. Patience has a peg. Its line is wet wood.
- **The window** — **clip `bakery`:** the woman draws the blind, then the
  shop door opens a hand's width and she speaks through it, and shuts it.
  Sets `SIGHT`. Returns here.
  > She draws the blind, then opens the door a crack. "Something came down
  > the sluice at the turn of the tide. It's caught in the grating under
  > the bridge. I'm not going to look." The door shuts.
- **The man** — first time, **clip `penry`:** he turns in his doorway, looks
  the camera up and down, and says his line. Then → **9. Penry.** Later
  times go straight to 9.
  > He turns in his light and keeps his hands in the towel. "Board-keeper,"
  > he says before you ask. "And the chain's mine. Say what you want."
- **The bridge** — requires `CHAIN` → **10. The sluice.** Before that,
  close-up still `chain`:
  > A chain across the bridgehead, padlocked to the rail. The keeper's.
  > Nobody crosses the sluice at night without his say.

  Returns here.

*Held: ledger.* Item line: "The rain is not a room. He said so." No reading
circle.

## 9. Penry

Plate `penry` (the doorway close-up). Talk screen. Abel Penry, 60,
board-keeper: he chalks the tide board and washes it. Grey beard, no cap, a
towel over his shoulder. He is not Marsh and does not dress like him.

The picture stays full frame. A soft darkening covers the bottom. His waiting
line sits in that band, then the lines that can be asked. The last line is
always **That's all**, and it returns to the alley. A line leaves once he has
answered it. Choosing one plays his reply, then comes back here.

> He stands in his light, hands in the towel.

- **Thomas?** — until it has been asked. **Clip `penry-voss`.** Sets `NAMED`.
  > "Voss chalked his own hour. Clerks don't do that." He looks at the
  > board. "He was letting the street read it."
- **The chalk?** — requires `BOARD`, until it has been asked. **Clip
  `penry-wash`.** Sets `PENRY`.
  > "I washed it. A name on a board at night is a name said out loud." He
  > steps back into the room. "Chalk washes off. A dry room does not."
- **The bridge?** — requires `PENRY`, until it has been asked. **Clip
  `penry-rail`.** Sets `RAIL`.
  > "Don't stop on it. The sluice is harbor water with a lid on."
- **That's all** — always, at the bottom. Travel → **8. The alley.**

*Held: ledger.* The questions go. The band says he shuts the door, and
**That's all** is still the way out.

> He shuts the door on the book. The light goes with him.

## 10. The sluice

Plate `sluice` (the footbridge, the black water under it, the grating where
the sluice meets the harbor, the stair beyond). Hub.

> A footbridge crosses a black sluice. The water is empty. The far rail
> disappears into the fog. Penry said not to stop on it.

- **The water** — look down. Close-up on the `sluice` still. No fact.
  Returns here.
  > You look down. The sluice keeps what it has. No face turns. Harbor
  > water, with a lid on.
- **The grating** — requires `SIGHT`. Close-up still `sluice-grate`: a
  board peg jammed in the iron, the letters VOSS cut in it. Sets `PEG`.
  Returns here.
  > What the baker saw. A board peg wedged in the grating, the kind that
  > holds a boat's name. The letters cut in it are VOSS. It came down from
  > the board on the water, not in a pocket.
- **The stair** — travel → **11. The landing.**
- **The alley** — travel → **8. The alley.**

*Held: ledger.* Item line: "The hour was for a dry room. This water can
hear." Circles become:

- **To the water** — ending **E5 The sluice.**
- **The stair**, **The alley** — as above, book put away.

## 11. The landing

Plate `landing` (the streetlamp, the office door behind it, the dark window
of the house opposite, the stair down). Hub.

If `SEEN` and not `LEFT`:

> The streetlamp at the top of the stair has a man under it, between you
> and the office door. He is not looking at the door. He is looking at you.

With `WARNED` as well, add: "Where Penry said he would be."

Otherwise:

> The streetlamp burns over empty cobbles. The office door is shut. The rain
> has the step to itself.

- **The lamp** — if `SEEN` and not `LEFT`, **clip `lamp`:** the man in the
  olive coat under the lamp turns, looks at the camera long enough to be
  the face from the folder, unchanged, and walks down past you into the
  fog without hurrying. Sets `LEFT`. Returns here; the arrival prose
  becomes the empty version.
  > He turns as you come up. It is the face from the folder, and it is only
  > a face. He goes down past you into the fog without hurry. The lamp has
  > the cobbles to itself, and the door is clear.

  Otherwise a close-up still of the lamp. With `PEG`:
  > You stand under the lamp. His name is not on the board, and not in the
  > chalk. It is in your coat, and nowhere else tonight.

  Without `PEG`:
  > You stand under the lamp. The cobbles stay empty. The door waits.
- **The window opposite** — close-up still `landing-window`. No fact.
  > A dark window with the curtain drawn back a hand's width. Whoever
  > watched the lamp tonight saw what you saw, and has not gone to bed.
- **The door** — requires `LEFT`, or not `SEEN` (two entries, one visible).
  Passage, close-up still `hall`:
  > Wet prints come in with you. Green light lies under the office door. The
  > dry room is on the other side.

  Continue → passage on `visit`, **clip `midnight`:** the office door opens
  on the room; Edith looks up from the chair, and does not stand.
  > Midnight. She is in the chair. She looks up, and she does not ask.

  Continue → **12. The dry room.**

  While he stands under the lamp the door is not offered: he is between you
  and it. That is the gate. Reading the hour to him is **E6**.
- **The stair** — travel → **10. The sluice.**

*Held: ledger.* Item line: "The lamp is rain. She was plain about that."
Circles become:

- **To the lamp** — ending **E6 The lamp.**
- **The door** (if offered), **The stair** — as above, book put away.

Five plain entries, two of them the door pair, plus the held lamp: six.

## 12. The dry room

Plate `visit` (Edith in the chair; the folder on the blotter; the window;
the door). Hub. Anchors `folder`, `pane`, `door` as on the office plate,
plus `locket` on her.

> Midnight. Edith is in the chair. Her folder is on the blotter and the
> window is rain. She does not ask. She waits.

- **The folder** — with the book shut, close-up still `office-file`:
  > The folder waits. The hour is still shut in your coat. Open the ledger,
  > and read it here.

  Returns here.
- **The locket** (circle on Edith) — returns here. The clip depends on the
  sluice:

  Without `PEG`, **clip `locket`:** she opens the locket and holds it toward
  the camera; the photograph is Thomas, dry and younger; she shuts it.
  > She opens the locket for you. The photograph is the face from the
  > folder, younger, dry, and smiling at whoever held the camera. "He wrote
  > me which room," she says. "I did not understand it until tonight."

  With `PEG`, **clip `locket-peg`:** the same, and she keeps it open a
  moment longer.
  > She opens the locket. The face from the folder, younger and dry. "That
  > peg in the grating is his. He cut it when he was nineteen, the first
  > time his name went on the board." She shuts the locket. "It is not his
  > name any more. The one in your coat is."
- **The door** — travel → **3. The wharf**, book in the coat. The door only
  goes back down.

*Held: ledger.* Item line: "Read it onto her folder. The window is rain. She
was plain about that." Circles become:

- **To the folder** — ending **E7 Best** if `SEEN` and `GLIMPSED` are both
  set (`HEARD` is always set by now), otherwise **E8 Quiet.**
- **To the glass** — ending **E9 The glass.**
- **The door** — as above.

Three plain circles and three held: six. The window has no plain circle in
this room; the reading to the glass is its only use.

## 13. The hall

Plate `hall`. The close-up reached from 11's door. Continue → the midnight
clip → 12.

## 14. The bend

Plate `corner` (reshoot: the lane above the dock where the hill starts, a
hill lamp smeared in fog, a man in a wet olive coat a few planks ahead with
his back turned). Decision, two circles. Reached only after the hour was
read to the fog.

> The hill lamp is a smear in the fog. A man in a wet coat keeps a few
> planks ahead, and does not look back.

- **The hill** — ending **E10 The stair** (partial).
- **The coat** — ending **E11 The coat.**

*Held: ledger.* Item line: "The hour was spoken in the rain. Shutting the
book does not call it back." No reading circle.

---

## Endings

Every failure and the partial end on "Try again", which returns to the
screen named, with the facts and the book as they were when that screen was
entered. The two successes end on "Start over".

| | Name | Kind | Plate | Clip | Text | Try again returns to |
|---|---|---|---|---|---|---|
| E1 | Home | Failure | `street` | — | You take the lane with empty hands. The fog lets you go. In the morning the folder is still on the desk, and Thomas Voss is a wet line on a washed board. | 3, no book |
| E2 | The harbor | Failure | `water` | `water` | You read his hour to the harbor. The pale face turns up between the pilings and does not go back under. | 3, with book |
| E3 | The floor, unread | Failure | `below` | `below` | The ring comes up in your hand. Black water waits under the shack, and the face from the folder rises to meet you. | 5 |
| E4 | The floor, read | Failure | `below` | `below` | The hour is in your coat, and still you open the floor. The face rises, because you brought his name down to the water. | 7 |
| E5 | The sluice | Failure | `sluice` | — | You read his hour to the sluice. The black water rises to the boards, and a pale face turns up where the water was empty. | 10 |
| E6 | The lamp | Failure | `landing` | — | You read his hour under the lamp. He is beside you before the line is done, and the office door behind him is further than it was. | 11 |
| E7 | Best | Success | `visit` | `win` | You read Thomas's hour here. Edith closes the locket. The streetlamp stays empty, and the floor you left shut does not answer. | Start over |
| E8 | Quiet | Success | `visit` | `win` | You read the hour here. Edith closes the locket. Outside, the rain is only rain, and the floor at berth four stays shut. | Start over |
| E9 | The glass | Failure | `window` | `glass` | You read his hour to the wet glass. The man under the lamp steps in close, and the latch rises under a hand that is not yours. | 12 |
| E10 | The stair | Partial | `visit` | `stair` | You pass him and climb. Edith waits in the chair. The hour was spoken in the rain, and she does not open the locket. He is still on the stair. | 3, with book |
| E11 | The coat | Failure | `coat` | `coat` | You go to him. The face from the folder looks back through the rain, and he does not speak. The hill does not take you. | 3, with book |

Ending clips: `win` is Edith closing the locket and lifting her eyes to the
window; `glass` is the man stepping in to the pane and the latch rising;
`stair` is Edith in the chair not moving her hand to the locket; `coat` is
the man ahead turning, and the changed face (`concepts/thomas-changed.jpg`)
holding on the camera without a word. E6 stays a still: he is beside you
before the line is done, and the plate does not get to show it.

Warnings given before each: E1 the job was the book; E2 "not to the water";
E3 "leave the floor shut"; E4 the book's own line; E5 "not to the water" and
Penry; E6 "not in the rain" and the man standing there; E9 "the window is
rain"; E10 and E11 "not in the rain" and Marsh.

## Facts

| Flag | Set by | Opens or changes |
|---|---|---|
| READ | 2, the folder | 2, the door is offered |
| SEEN | 2, the window | 4, the coat question; 5, the coat's second sentence; 11, he is under the lamp and the door is shut until he goes; E7 |
| GLIMPSED | 3, the water | 4, the Thomas clip becomes the face clip; 3, the held line; E7 |
| MET | 3, the mate | 3, the approach clip plays once |
| ASKED | 4, Thomas | 4, the floor question is offered |
| HEARD | 4, the floor | 4, the short repeat |
| OPEN | 4, the floor | 3, the shack is offered |
| WALKER | 4, the coat | 9, the Thomas clip becomes the walker clip |
| TOLD | 4, the Patience | 9, the chalk question without the board |
| KNEW | 5, taking the ledger | E4's wording |
| BOARD | 8, the board | 9, the chalk question |
| SIGHT | 8, the bakery | 10, the grating is offered |
| PENRY | 9, the chalk | 9, the bridge question |
| CHAIN | 9, the bridge | 8, the bridge is offered |
| WARNED | 9, the walker | 11, the arrival line |
| PEG | 10, the grating | 11, the lamp close-up; 12, the locket clip |
| LEFT | 11, the lamp | 11, the door is offered; the lamp is empty |

Seventeen facts. `DESIGN.md` asked for few; this is the cost of a road where
every person is a gate or a key. Each one is set on one screen and read on
another, and none is read only by an ending.

The best ending needs `SEEN` and `GLIMPSED`. `HEARD` is on the spine now, so
the quiet ending is the one that skipped the window or the water.

## The shortest and the longest night

Spine only: folder, door, the mate, Thomas, the floor, the dock, the shack,
the ledger, the door, the lane, the board, the man, the chalk, the bridge,
the alley, the bridge, the stair, the door, the locket or not, the folder.
About twenty taps, three people, two of them asked twice.

Everything: the same with the window, the lamp, the telephone, the water
twice, Marsh's five questions, the padlock, the coat on the hook, the
bakery, Penry's four, the chain, the sluice water, the grating, the man
under the lamp, the window opposite, the locket. About thirty taps, and
every person met tells you something the next one will use.

## Plates

Existing, kept as they are: `visit`, `office`, `office-file`, `window`,
`wharf`, `water`, `marsh`, `shack`, `shack-ledger`, `shack-bare`, `below`,
`street`, `coat`, `board`, `bakery`, `sluice`, `landing`, `hall`.

Reshoot: `alley` (Penry's door, the board, the bakery window and the
chained bridgehead in one frame), `corner` (its own place, not the wharf).
The `wharf` plate needs a visible padlock on the shack door, or a
`shack-door` close-up that shows one.

New close-ups: `office-phone`, `office-lamp`, `shack-door`, `shack-coat`,
`chain`, `sluice-grate`, `landing-window`. New talk plate: `penry` (the
poster of the `penry` clip). Match the originals: eye height, 3:2, the
green lamp indoors, lanterns outdoors, no rounded film corners.

Cut: `steps`, `chapel`, `yard`, `stair` as pages.

## Clips

Every tap on a person is a clip. Each is a few seconds, first person, 3:2,
720×480, at least five seconds in the file, with the matching concept image
so the face stays put.

| Clip | Person | Where | What happens | Gives |
|---|---|---|---|---|
| `visit` | Edith | 1 | Gives the rule, stands, goes (exists) | The rule |
| `window` | Thomas | 2 | Under the lamp, then gone (exists) | SEEN |
| `marsh` | Marsh | 3→4 | Turns the clear eye on you (exists) | MET |
| `marsh-thomas` | Marsh | 4 | Answers, looks at the shack once | ASKED, points to the floor |
| `marsh-face` | Marsh | 4 | Looks at the water, then you | ASKED, the floor is the face |
| `marsh-floor` | Marsh | 4 | The warning; the padlock drops under his key | HEARD, OPEN |
| `marsh-coat` | Marsh | 4 | Looks at his coat, then up the hill | WALKER, Penry saw him |
| `marsh-patience` | Marsh | 4 | Pats the rail; the boat knocks | TOLD, the answer Penry wants |
| `marsh-hour` | Marsh | 4, held | Palm between the book and the deck | The hour is not spent |
| `water` | Thomas | 3, E2 | The face turns under the pilings (exists) | GLIMPSED |
| `below` | Thomas | E3, E4 | The face rises under the floor (exists) | — |
| `street` | Thomas | 3→14 | A step that matches yours (exists) | — |
| `bakery` | the woman | 8 | Draws the blind, speaks through the door | SIGHT, the grating |
| `penry` | Penry | 8→9 | Turns in his doorway, his line | The talk opens |
| `penry-voss` | Penry | 9 | Looks past you at the board | NAMED, the Thomas line is spent |
| `penry-wash` | Penry | 9 | Shows the chalk on the towel | PENRY, the chalk line is spent and the bridge line opens |
| `penry-rail` | Penry | 9 | The sluice warning | RAIL, the bridge line is spent |
| `lamp` | Thomas | 11 | Turns, is only a face, goes down past you | LEFT, the door |
| `midnight` | Edith | 11→12 | Looks up from the chair | She is back |
| `locket` | Edith | 12 | Opens the locket toward you | He wrote her which room |
| `locket-peg` | Edith | 12 | The same, longer | The peg was his first name on the board |
| `win` | Edith | E7, E8 | Closes the locket, eyes to the window | — |
| `glass` | Thomas | E9 | Steps in to the pane; the latch rises | — |
| `stair` | Edith | E10 | Her hand does not go to the locket | — |
| `coat` | Thomas | E11 | Turns; the changed face holds on you | — |

Twenty-seven clips, seven of them existing. Drop the ten rain-on-a-still
clips: `steps`, `chapel`, `yard`, `alley`, `board`, `sluice`, `stair` (the
old one), `landing`, `hall`. Rain on an empty place is a still.

Taps that stay stills, and why: the second look at the water and Marsh's
repeat (nothing moves again, and that is the point); the padlock, the
chain, the board, the coat on the hook, the grating, the window opposite,
the telephone, the lamp shade, the folder (objects); E1, E5, E6 (nobody is
in frame to move).

## Checks before it ships

- `make check` passes.
- No two passages chain by Continue except inside an ending and the
  hall→midnight pair.
- Every decision page has at least two circles with different targets.
  Every hub has at least three. No page has more than six entries counting
  the held ones and the paired entries that never show together.
- Every fact above is set on one screen and read on another.
- Every person tap plays a clip, and every clip in the table gives what its
  last column says.
- Circles sit on the thing they name, outside the prose band, with a clear
  radius between them.
- `DESIGN.md` is brought into line: the ending table, the size, the film
  grammar (the wins, the glass, the coat and Marsh's refusal are clips now),
  the best-ending condition, and the "few facts" rule.
- `WALKTHROUGH.md`, `work/MAP.md`, `work/OBJECTS.md`, `work/STORY_STATE.md`
  and `tests/test_salt.py` are updated to these screens. Tests tap the
  published circles, Continue, Try again and the ledger.
