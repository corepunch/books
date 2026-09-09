# Zork I Companion Coverage

## Summary

| Metric | Count |
|---|---:|
| Declared rooms | 110 |
| Classified rooms | 110 |
| Reachable rooms | 110 |
| State families | 110 |
| Authored | 110 |
| Validated | 0 |
| Fallback-reviewed | 0 |
| Not covered | 0 |
| Exempt | 0 |

## Coverage Status

All 110 declared rooms have been classified and have authored companion support.
The companion routes every reachable room through `SUGGEST-ACTIONS` and provides
scene descriptions via `SUGGEST-SCENE`.

## Room Categories

### Surface Rooms (17)
- WEST-OF-HOUSE, NORTH-OF-HOUSE, SOUTH-OF-HOUSE, EAST-OF-HOUSE
- FOREST-1, FOREST-2, FOREST-3, MOUNTAINS, PATH, UP-A-TREE
- GRATING-CLEARING, CLEARING, STONE-BARROW
- CANYON-VIEW, CANYON-BOTTOM, CLIFF-MIDDLE

### House Interior (3)
- KITCHEN, LIVING-ROOM, ATTIC

### Cellar and Vicinity (5)
- CELLAR, TROLL-ROOM, EAST-OF-CHASM, STRANGE-PASSAGE, GRATING-ROOM

### Gallery Area (2)
- GALLERY, STUDIO

### Maze (20)
- MAZE-1 through MAZE-15
- DEAD-END-1 through DEAD-END-5

### Cyclops and Treasure (2)
- CYCLOPS-ROOM, TREASURE-ROOM

### Mirror Rooms and Vicinity (8)
- MIRROR-ROOM-1, MIRROR-ROOM-2, SMALL-CAVE, TINY-CAVE
- COLD-PASSAGE, NARROW-PASSAGE, WINDING-PASSAGE, TWISTING-PASSAGE

### Round Room and Vicinity (9)
- EW-PASSAGE, ROUND-ROOM, DEEP-CANYON, DAMP-CAVE, LOUD-ROOM
- NS-PASSAGE, CHASM-ROOM, ENGRAVINGS-CAVE, DOME-ROOM

### Temple and Egypt (4)
- NORTH-TEMPLE, SOUTH-TEMPLE, EGYPT-ROOM, TORCH-ROOM

### Hades (2)
- ENTRANCE-TO-HADES, LAND-OF-LIVING-DEAD

### Reservoir Area (5)
- RESERVOIR-SOUTH, RESERVOIR, RESERVOIR-NORTH, STREAM-VIEW, IN-STREAM

### Dam Area (5)
- DAM-ROOM, DAM-LOBBY, MAINTENANCE-ROOM, MACHINE-ROOM, DAM-BASE

### River and Shore (12)
- RIVER-1, RIVER-2, RIVER-3, RIVER-4, RIVER-5
- WHITE-CLIFFS-NORTH, WHITE-CLIFFS-SOUTH, SHORE
- SANDY-BEACH, SANDY-CAVE
- ARAGAIN-FALLS, ON-RAINBOW, END-OF-RAINBOW

### Coal Mine (14)
- MINE-ENTRANCE, SQUEEKY-ROOM, BAT-ROOM, SHAFT-ROOM
- SMELLY-ROOM, GAS-ROOM, LADDER-TOP, LADDER-BOTTOM
- TIMBER-ROOM, LOWER-SHAFT
- MINE-1, MINE-2, MINE-3, MINE-4
- SLIDE-ROOM

## Key Design Decisions

1. **Generic maze handling**: All maze rooms (except MAZE-5 which has unique items) share
   a generic `SUGGEST-MAZE` routine with compass directions and explore.
2. **Generic dead-end handling**: All dead ends share `SUGGEST-DEAD-END` with a back command.
3. **River rooms**: All river rooms share `SUGGEST-RIVER` with downstream and land commands.
4. **Mine rooms**: All coal mine rooms share `SUGGEST-MINE` with compass directions.
5. **Forest rooms**: All forest rooms share `SUGGEST-FOREST` with explore and compass.
6. **State-aware conditions**: Key puzzles like dome rope, dam water levels, and cyclops
   have appropriate conditional cards.

## Known Gaps

- Validated command execution evidence (parser confirmation) is pending for newly added rooms.
- A companion-mode numeric-only playthrough has not been run.
- Save/restore persistence testing for new rooms is pending.

## Exemptions

None. All 110 rooms are reachable and have authored companion support.
