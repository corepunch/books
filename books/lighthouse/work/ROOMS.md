# Room bible — Огонь на маяке

Scener centimetres, X east, Y north, Z up. **M** = modelled, **P** = painted
only. Exteriors live in `rooms/bay.blks` (one coordinate system for the whole
bay), the cottage in `rooms/home.blks`, the tower interior in
`rooms/tower.blks`. Plan view: `rooms/layout.jpg`.

## Shared: the bay, light and palette

- **Geography (M).** Sea level at z −20 at low tide (`Sea` group; cameras raise
  it for the tide). Village land y < 250, top z 40. The spit and fork x −400…1400,
  y 250…700. Cliff plateau x −600…1300, y 700…4300, top z 600, cut by the gully
  y 2900…3300. Tidal flats x 1300…3500, sand z 5. North shore y 4700…5400. The
  channel y 5400…6600. The island rock centred (1800, 7250), rising to z 250.
- **The lighthouse (M)** at (1800, 7200, 250): whitewashed tapering tower with a
  red band, 15 m to the gallery, glazed lamp room, red cap; door to the south.
  It is visible from every exterior page and through grandfather's window.
- **Light (M).** A low sun behind storm clouds in the west-south-west
  (`sun dir 0.75 0.45 −0.55`, warm), ambient 0.30. Night pages are painted
  darker (P); the blockout keeps one sun so shapes stay readable.
- **Palette (P).** Storm sky slate-violet `#5c5a78` turning to ink; sea grey-green
  `#35505f`; cliff grass olive `#6b7440`; sand `#bda77a`; whitewash `#dcd8cf`;
  roofs brick red `#9a3a2e`. Story colours: Varya's yellow coat `#eab733` and red
  hat `#c7332d` are the brightest things on every page; the lighthouse beam is
  the only warm yellow in the sea.
- **Weather (P).** Wind from the west: grass, hair, smoke and spray all stream
  east. White horses on the channel. Gulls huddle on roofs.

## Grandfather's cottage (`home.blks`)

**Resident story.** Matvei has kept the lighthouse for forty years and lives
alone in this cottage at the end of the village; Varya stays with him in the
summer. He came home from the lighthouse at noon with a fever and has not been
able to get up since.

**Walk-in.** A low warm room smelling of lamp oil and fish soup. The iron bed
against the west wall, the patchwork quilt, the table with the brass oil lamp.
Through the north window, across the grey bay, the lighthouse stands dark on
its rock. The wind rattles the glass.

| Piece (M) | Size | Position | Why |
|---|---|---|---|
| Room | 400 × 350, ceiling 240 | x −200…200, y −175…175 | — |
| Iron bed | 100 × 200, mattress 46 | against the west wall, head north | grandfather's bed |
| Table with oil lamp | 50 × 50 × 70 | beside the bed head | the key light, 'lit by grandfather' |
| Stool | 36 × 36 × 44 | beside the bed | where Varya sits in `end-stay` |
| Window | 100 × 100 | north wall | the lighthouse view |
| Door | 90 × 200 | east wall | the way out (anchor `door`) |

Painted details (P): patchwork quilt (red and blue squares); grandfather's
keeper's cap and oilskin on the hook by the door; a framed photograph of the
lighthouse above the bed; a barometer needle pointing to «Буря».

## The harbour and the fork (`bay.blks`, passing)

**Reason.** The fishing village: four whitewashed cottages facing the bay,
boats pulled up on the shingle for the storm, a plank pier on posts.

**Walk-in.** Wind off the water, gulls on the roofs, nets hung to dry. At the
east end of the village the road climbs onto a grassy spit and splits at an old
signpost: the sand path drops right to the flats, the rocky path climbs left up
the face of the cliffs. The lighthouse is straight ahead across the bay.

Modelled: cottages (`terrain/house`), two boats (`terrain/boat`), the pier with
its posts and Timka's net, the signpost (`terrain/signpost`). Anchors
`flats-path` (top of the sand path) and `cliff-path` (foot of the rocky path).
Painted: net floats, lobster pots, smoke streaming east from chimneys, the
signpost's worn letters «К маяку» on both boards.

## The tidal flats (`bay.blks`)

**Reason.** A broad sandy flat that dries at low tide; fishermen dig bait here.
The «Чайка», a big rowing boat, was wrecked on it years ago and never moved.

**Walk-in.** Wet sand shining like a mirror, ribbed by the tide; pools; the
smell of weed. The wreck lies on its side, holed amidships. A seal basks on a
rock. To the west the cliffs rise sheer, with a zig-zag path up their face.

| Item | M/P | Position | Role |
|---|---|---|---|
| Wet sand | M | x 1300…3500, y 300…4700, z 5 | covered as the tide rises |
| The «Чайка» | M | (2300, 2650), boat ×2.4 on its side, hole amidships | shortcut, trap (`wreck`, `deck`) |
| Seal's rock | M | (2700, 2300) | the seal (`seal`) |
| The sandbar | M | a dry strip from (2150, 2900) to (1750, 4700), top z 30 | the secret way |
| Cliff-face path | M | up the plateau's east face, y 1400…2400 | link to the cliffs (`dune-path`, `flats-down`) |
| Tide states | M | `Sea` +28…+70 | picture states |

Painted: weed on the wreck's planks, the name «ЧАЙКА» on its stern, crab
tracks, the tide line, spray.

## The cliffs (`bay.blks`)

**Resident story.** Agafya has grazed her goats on the cliff top for fifty
years and lives in the stone hut by the path. The rope bridge over the gully is
older than she is; she has told the whole village about the rotten plank.

**Walk-in.** Wind tearing at the grass, goats' bells, a steep drop to the
flats on the right. Beyond the hut the plateau is split by a deep gully with a
stream at the bottom; a rope bridge sways across it.

| Item | M/P | Position | Role |
|---|---|---|---|
| Plateau | M | x −600…1300, top z 600 | the high road |
| Agafya's hut | M | (−150, 1900), door to the south-east | Agafya (`agafya`) |
| Goats and pen | M | north of the hut | dressing, Agafya's work |
| Gully | M | y 2900…3300, floor z 100, stream | the obstacle |
| Rope bridge | M | centred (500, 3100), twelve planks, deck z 600 | route (`bridge`) |
| Rotten third plank | M | (500, 2982), dark green | the danger (`plank`); broken state in `cliffs-hang-bridge` |
| Sheep track | P | along the plateau's west edge and round the gully head | Agafya's road |
| North slope path | M | down to the shore at y 5000 | to the channel |

Painted: lichen on the plank, frayed rope ends, heather, a goat's bell.

## The channel landing (`bay.blks`)

**Resident story.** Savely has ferried people to the island for the keeper for
years; he lives in the plank hut at the landing, owes Agafya for goat's milk,
and does not go out in storms.

**Walk-in.** The channel boils with white horses. Savely's hut, a short jetty
with his boat knocking against it, and a line of six flat stones from an old
crossing running out to the island, already awash.

| Item | M/P | Position | Role |
|---|---|---|---|
| Ferry hut | M | (950, 5220), open door, stove inside | `hut-door`, `end-hut` |
| Jetty and boat | M | jetty x 1330, boat (1420, 5620) | the ferry |
| Savely | M | (1250, 5330) | `ferryman` |
| Stepping stones | M | x 1900, y 5480…6380, tops at z 0 | `stones`, `near-stone`, `far-stone` |
| Water levels | M | `Sea` +8…+25 | picture states |

Painted: the stove glowing through the door, Savely's pipe smoke streaming
east, a lantern on the jetty post.

## The island (`bay.blks`, passing)

The lighthouse on its rock plinth; spray bursting on the rocks; the heavy door
to the south. Painted: salt stains, a brass plaque «1889».

## The tower (`tower.blks`)

**Reason.** Matvei's workplace: the stone stair he climbs twice a day and the
lamp he trims every evening.

**Walk-in.** A cold stone tube; a hundred steps spiral round a central column;
a slit window; at the top, the glazed lamp room with the great lamp, the
matches on a shelf, and one casement banging open on the storm.

| Item | M/P | Position | Role |
|---|---|---|---|
| Stair | M | 24 steps modelled of the hundred, radius 75, 18 cm rise | `tower-climb-stairs` |
| Lamp room | M | glazed drum, radius 150, floor z 1500 | the goal |
| Great lamp | M | brass pedestal, wick, glass lens, centre | `wick` |
| Open casement | M | south side, hinged on its west edge; closed state turned shut | `window` |
| Matches | M | on the shelf by the hatch | used in place, never carried |
| Boats' lights | M | small lights far out at sea | the stakes |

Painted: brass polished bright, soot on the lens, a logbook open on the
shelf with grandfather's handwriting.

## Quiet surfaces for text

Storm sky (top of every exterior), the plaster wall and window (cottage), the
dark glazing (lamp room), the stairwell wall.
