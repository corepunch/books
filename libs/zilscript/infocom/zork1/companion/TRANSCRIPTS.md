# Zork I Companion Validation Transcripts

## Environment

- Date: 2026-07-28
- Revision: full-game companion expansion
- Game module: infocom.zork1
- Mode: companion

## Scenario: Opening Route (Surface to Cellar)

### Prerequisite state

New game, starting at West of House.

### Legacy capped visible-card snapshot

1. Open the little mailbox — open mailbox — scene
2. Try the boarded front door — open front door — scene
3. Walk around the north side of the house — north — move

### Selection 1: Open the little mailbox

Selected card: west-house.open-mailbox
Hidden command: `open mailbox`

Observed output:
```
Opening the small mailbox reveals a leaflet.
```

Result: PASS

### Selection 2: Take the leaflet

Selected card: west-house.take-leaflet
Hidden command: `take leaflet`

Observed output:
```
Taken.
```

Result: PASS

### Selection 3: Walk north

Selected card: west-house.go-north
Hidden command: `north`

Observed output:
```
North of House

You are facing the north side of a white house. There is no door here,
and all the windows are boarded up. To the north a narrow path winds through
the trees.
```

Result: PASS

## Scenario: Kitchen Entry

### Prerequisite state

At East of House after navigating from West of House.

### Legacy capped visible-card snapshot

1. Open the slightly ajar kitchen window — open kitchen window — scene
2. Look through the small kitchen window — examine kitchen window — scene
3. Follow the path into the forest clearing — east — move

### Selection: Open the kitchen window

Selected card: east-house.open-window
Hidden command: `open kitchen window`

Observed output:
```
With great effort, the window is opened far enough to allow entry.
```

Result: PASS

## Scenario: Underground Navigation

### Prerequisite state

At Cellar after descending from Living Room.

### Legacy capped visible-card snapshot

1. Go north toward the troll room — north — move
2. Go south toward the east of the chasm — south — move
3. Climb back up to the living room — up — move

### Selection: Go to troll room

Selected card: cellar.go-troll-room
Hidden command: `north`

Observed output:
```
The Troll Room

This is a small room with passages to the east and south and a
forbidding hole leading west. Bloodstains and deep scratches
(perhaps made by an axe) mar the walls.
```

Result: PASS

## Scenario: Maze Navigation

### Prerequisite state

At Maze-1 after entering from Troll Room.

### Legacy capped visible-card snapshot

1. Look around the maze — look — scene
2. Go north — north — move
3. Go south — south — move

### Selection: Look around

Selected card: maze.explore
Hidden command: `look`

Observed output:
```
Maze

This is part of a maze of twisty little passages, all alike.
```

Result: PASS

## Scenario: Dam Area

### Prerequisite state

At Dam Lobby after navigating from Dam Room.

### Legacy capped visible-card snapshot

1. Take the matchbook — take matchbook — scene
2. Take the tour guidebook — take guide — scene
3. Go into the main dam room — north — move

### Selection: Take the matchbook

Selected card: dam-lobby.take-matches
Hidden command: `take matchbook`

Observed output:
```
Taken.
```

Result: PASS

## Scenario: Coal Mine

### Prerequisite state

At Mine Entrance after navigating from Slide Room.

### Legacy capped visible-card snapshot

1. Enter the squeaky room — west — move
2. Go south to the slide room — south — move

### Selection: Enter the mine

Selected card: mine-entrance.go-west
Hidden command: `west`

Observed output:
```
Squeaky Room

You are in a small room. Strange squeaky sounds may be heard coming
from the passage at the north end. You may also escape to the east.
```

Result: PASS

## Known Issues

- Parser confirmation of all newly added commands is pending exhaustive validation.
- A companion-mode full playthrough has not been completed.
- Save/restore behavior for new rooms is pending verification.
