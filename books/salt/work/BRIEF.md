# Brief: make The Salt Ledger play like an FMV adventure

Status: done. The continue-chain is gone. The screens and the circles are
[GDD.md](../GDD.md). The notes below are the brief that produced that list.
Do not rebuild the walk home from the "What is wrong now" section.

For the next pass on the pages in `books/salt/locations/`. Read this with `../DESIGN.md`, which
still owns the premise, the voice, and the rules for a new page. This file is
about the shape of play. Nothing here changes the hour, the mouths, or the
endings.

## What is wrong now

The office and the wharf play well. Each is a screen with several things to
tap, and tapping one shows something, sets a fact, and comes back. The walk
home does not play. From the lane to the dry room the reader taps Continue
eleven times in a row and makes three choices on the way, two of which lead
to the same page. That is a slideshow with a pause button, not a game.

Count it in the current file: 10 decision pages, 28 passages, and 11 of those
passages are chained with no decision between them (`office-climb`, `steps`,
`chapel`, `yard`, `alley`, `bakery`, `board`, `sluice`, `stair`, `landing`,
`hall`). The alley's two circles both go to `bakery`. The landing's two circles
both go to `hall`.

## The model: The X-Files Game and The Pandora Directive

Both are first-person, static screens, a cursor that changes over what can
be touched. That is exactly our plate and our circles. Play in both is one
loop, repeated in every location:

1. **Arrive at a screen with several things on it.** The Comity Inn is a front
   desk, Mulder's room, Scully's room. Mulder's room alone has a book on the
   desk, an ashtray, a briefcase with a report, a paperback on the nightstand.
   Tex's office has Fitzpatrick's card, a photo of the ex-wife, a can of dog
   food, a newspaper clipping, a final notice, a jack-knife, a fire escape.
2. **Look at things.** Most taps show a close-up and a line, then return to the
   same screen. Most of them are optional. Some of them turn on a lead: the
   ashtray in Mulder's room unlocks the "Phone" idea; the scarf under
   Malloy's bed unlocks "Emily".
3. **Use what you saw on people.** Willmore drags the Phone idea onto the desk
   clerk and gets the call log. Tex offers the scarf to Louie and gets the
   Emily topic; Emily unlocks Gus Leach; Leach unlocks the key. A person
   answers a question only once its subject has been found. Pandora's author
   calls this an Ask About tree.
4. **Progress is gated, never narrated.** Nothing happens until the key thing
   has been found or said. Pandora: "the story stalls when you are following
   the wrong leads... people are not available to talk and you cannot get new
   information." The player backtracks and tries another lead. There is no
   page that says "go on".
5. **Travel is one tap.** The PDA map, the three travel maps. No corridor of
   screens between two places. Getting from the field office to the Comity
   Inn is one click, and the inn is immediately a screen with a desk clerk and
   two doors.
6. **Danger is a place you chose to enter**, not a page you were walked to.
   Entering Apartment A ends Day One with Tex knocked out. The warehouse truck
   scene has a save warning before it.

Read the sources below and look at how many clickable things a single screen
holds, how many of them are optional, and how few Continues there are.

## How that maps onto this engine

Everything needed is already in the format (see
[authoring/XML.md](../../../authoring/XML.md)) and already used in the office
and the wharf:

| FMV idea | Here |
|---|---|
| A location screen | a `<view>` on its own camera, 3–5 circles (max 6) |
| Look at a thing, return | an `<asset>` on a close-up camera, `next` back to the view (through an `<actionlist>` if the view has state variants) |
| Idea / Ask About unlocked | an `<idea>` icon given by `<give>`; a `<conversation with="idea">` on the person's charview |
| Evidence carried | an `<evidence>` or `<inventory>` icon, `take` on the thing, `with` on the circle that uses it |
| Travel | a `<nav>` on the exit anchor, or a `<map>` of `<destination>`s |
| A day gate | a choice with `if` on the variables that matter (`day >= 2`) |
| Death / knocked out | an `<ending>` with `retry` back to the view where the mistake was made |

The rule for the page graph: **every screen that is not a close-up, a clip
beat, or an ending is a hub with at least three distinct things to tap.** A
close-up returns to its hub. Two Continues in a row never happen except
inside an ending. A circle with the same target as another circle on the
same page is deleted.

## What to build

Keep the office, the wharf, the shack, and all their pages. Rebuild the walk
home as three hubs and nothing else between them. Pick the three from the
plates already made and shoot new hubs where the current plates are too
empty to hold three circles.

### Hub A: the alley (replaces steps, chapel, yard, alley, bakery, board)

Camera on the alley with the man's lit door, the laundry, the bakery window
down the street, the tide board under its porch, and the way on. Circles:

- **The board.** Close-up `board`. Chalk, washed. Sets `BOARD`: the tide
  names are gone; his hour exists only in the ledger now. Returns to the hub.
- **The window.** Close-up `bakery`. The woman draws the blind. Optional, no
  fact. Returns to the hub.
- **The man.** Talk screen on his door (see "Talk screens"). Not Marsh: no
  knit cap. Give him a trade, a name, and a want.
- **The bridge.** Travel to hub B.

Steps, chapel, and yard are not places. If one of them is kept, it is a
close-up a circle in this hub looks at, or it is cut.

### Hub B: the sluice

Camera on the footbridge. Circles:

- **The water.** Look down. Returns. With the ledger held, "To the water" is
  the failure already written (`ending-sluice`).
- **The rail / what is caught under the bridge.** A close-up with something
  that belongs to Thomas (a clerk's cuff, a tide-board peg). Sets a fact the
  landing can read. This is the hidden sight on the road.
- **The stair.** Travel to hub C.
- **Back.** Travel to hub A. The road is walkable both ways, as the wharf is.

### Hub C: the landing

Camera on the lamp, her door, the stair down, the dark window of the house
opposite. Circles:

- **The lamp.** `lamp-check` on `SEEN`. If he was seen from the office, he is
  standing under it now, and the close-up is a clip of him turning away. The
  best ending's "the streetlamp stays empty" means something only if the lamp
  was occupied on the way in. If `SEEN` is off, the cobbles are empty.
- **The window opposite.** Optional look.
- **The door.** Into the hall, then the dry room. `hall` becomes a close-up on
  the way, or is cut.
- **The stair.** Back to hub B.

### Talk screens

A person is a screen too. Marsh already works this way by accident; do it on
purpose. The talk page is a decision on the person's close-up camera. Its
circles sit on things in that frame, and each one is a question:

- Marsh: his clouded eye ("The floor?"), the Patience behind him ("Thomas?"),
  the book if carried ("The hour?", `.with = LEDGER`, his refusal).
- The alley man: his face, the board behind him (`if="board"`), the
  sluice if it has been seen.
- Edith at the end: the folder, the locket, the window.

A question is offered only when its subject has been found. Asked once, it
sets a fact and the answer page returns to the talk screen through a check,
so the circle can change label or disappear.

### Facts

Keep the five that exist. Add at most three on the road, each read by a
later page: `BOARD` (the names are gone), the sluice find, and whatever the
alley man gives. Write them into `STORY_STATE.md` before they appear in `title.xml`.

### What to drop

- Clips of empty places. Six of the ten new clips are rain on a still. The
  film grammar in `DESIGN.md` is right: clips are for people who move. Keep
  `alley` and `bakery` if those screens survive; drop the rest or re-shoot
  them with someone in them.
- The rounded-corner film grade on `yard`, `bakery`, `sluice`, `stair`,
  `landing`, `hall`. None of the original plates have it.
- `corner.jpg`, which is the wharf again. The bend needs its own place or it
  stays on the `street` camera.

### Two story fixes that come first

- **Whose room.** Edith comes to the office and leaves. You take your hat from
  the hook. The road home says "her window", "her door", "green light under
  her door", and the partial has her "waiting in the chair". Decide. The
  simplest fix is that it is Crowe's office and she said she would wait there.
  Then the road says "the office", not "her door".
- **The alley man** must not be Marsh (knit cap, oilskin). Marsh does not
  come up the hill.

## Acceptance

- `make check` passes.
- No two `<asset>` pages chain by Continue outside an ending.
- Every decision page has at least two circles with different targets, and
  every hub has at least three.
- Every new fact is read by a later page.
- A reader who taps only exits (lane, bridge, stair, door) reaches the dry
  room in four screens. A reader who taps everything sees about fifteen
  close-ups and three conversations on the same road.
- Update `MAP.md`, `OBJECTS.md`, `STORY_STATE.md`, `WALKTHROUGH.md`, and
  `tests/test_salt.py` with the hubs. Tests tap the published circles.

## Sources

- The Pandora Directive, complete walkthrough by Aaron Conners, part 1 (Days
  1–3): <https://www.aaronconners.net/uploads/1/8/6/1/18618520/pandora_walk_through_part_1.pdf>.
  Read "Walkthrough terms defined" and Day One for the Ask About tree, the
  stall rule, and the travel maps.
- The Pandora Directive, guide by Steve Metzler, days and decision points per
  path: <https://the-spoiler.com/ADVENTURE/Access/pandora.directive.4/>.
- The X-Files Game, Game Boomers walkthrough, Days One and Two:
  <https://www.gameboomers.com/wtcheats/pcXx/XfilesWT1.htm>. Read the Comity
  Inn: front desk, Mulder's room, Scully's room, the Phone idea, the call log.
- The X-Files Game review of the interface (cursor modes, inventory bar,
  idea icons used on people): <https://www.justgamesretro.com/?p=1475>.
