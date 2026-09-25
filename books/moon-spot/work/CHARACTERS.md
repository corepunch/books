# Characters — Мира и лунный зайчик

## Mira

Mira is the grey storybook kitten; her skeleton (`rooms/prefabs/characters/mira.blk`)
is the series model.

### Scale

| Measure | Value |
|---|---|
| Height to ear tips | 26 cm |
| Nose to rump | 38 cm, tail 22 cm |
| Head | about 15 cm across with ears |
| Reach standing on hind legs | front paws to 40 cm |
| Jump | up to 50 cm onto a surface; down from 75 cm via the stool |

Routes checked: floor → stool seat 45 ✓; stool → table 75 (30 up) ✓; table →
sill board 100 (25 up) ✓; sill → curtain edge at 120–124 while rearing ✓; floor → dresser door
paws at 35 while rearing ✓.

### Silhouette and design

Smoke grey with white socks, a white bib and a pink nose. Large pointed ears,
big head (a third of her height), a long tail that curls up at the tip. Reads
at thumbnail size by the ear triangle and the pale socks.

### Face and expressions

Large round olive eyes. Needed: *determined* (floor wide), *surprised*
(pounce), *polite* (waking Бублик), *concentrating* (pushing and aiming the
mirror), *embarrassed* (hanging on the curtain), *sleepy and content*
(endings).

### Personality in the body

Quick, springy, a little too eager: she leans forward, ears up, tail high.
When she concentrates her body goes low and still.

### Poses

| Pose | Action | Bones and IK |
|---|---|---|
| `Watch` | sitting low, looking up at the spot | head aims up; tail curls |
| `PounceDoor` | rearing up, front paws against the dresser door | spine raised 60°, hind paws planted, front paws IK to the door face |
| `PawDog` | stretching a front paw to Бублик's ear | left front paw IK forward and up, head aims at the dog |
| `LookUp` | standing, looking up at a sitting dog | neck and head aim up |
| `ClimbTable` | hind paws on the stool seat, front paws on the table edge | spine raised, hind planted, front IK to the table edge |
| `LookDown` | on the table edge, looking down | head aims down |
| `LookMirror` | standing on the table, facing the mirror | head level, tail up |
| `PawMirror` | north of the mirror, one front paw on its rim | left front paw IK to the rim |
| `HangCurtain` | rearing on the sill board, front paws in the curtain edge | spine steep, front paws IK to the curtain edge |
| `Curl` | curled asleep | spine lowered, head down, tail wrapped |

### Model sheet shots

Turnaround (front, side, back, three-quarter) and a line-up beside the stool
and Бублик, rendered from `rooms/model-sheet.blks`.

## Бублик

### Scale

| Measure | Value |
|---|---|
| Shoulder height standing | about 48 cm |
| Nose to rump | about 85 cm, tail 30 cm |
| Head | 30 cm long including muzzle |
| Lying | about 28 cm high at the shoulder |
| Sitting | head at about 65 cm |

Mira beside him lying is about the height of his back, which makes the ending
picture work: she fits against his side.

### Silhouette and design

A shaggy village mongrel: long body, short strong legs, deep chest, a big
blunt muzzle, one ear up and one flopped, a bushy tail. Sand-coloured with a
dark muzzle and grey around the eyes (he is old). Reads by the long low body
and the odd ears.

### Face and expressions

Small dark eyes under shaggy brows. Needed: *snoring* (mouth slack), *one eye
open* (grumpy), *sneezing / blinking* (after the spot), *suspicious*,
*gruffly kind* (invitation), *asleep, content* (endings).

### Personality in the body

Slow, heavy, comfortable. He moves as little as possible: he lifts his head
rather than stands, and sits rather than walks.

### Behaviour and states

| State | Looks |
|---|---|
| asleep | lying on his chest, chin on his front paws, eyes shut |
| one eye open | same, head lifted 15° |
| sitting | sitting up on the mat, head high, looking down at Mira |
| friendly | sitting, head tilted (painted), tail sweeping (painted) |
| asleep on side | lying down, head on the mat (ending) |

### Skeleton plan

`spine` (2 segments, root) → `neck` → `head` → `muzzle` (taper); `left_ear`
(up, pointed) and `right_ear` (authored separately so it can flop); eyes and
nose with `on`. `left_shoulder` → `left_forearm` → `left_front_paw` (mirror);
`left_hip` → `left_hock` → `left_hind_paw` (mirror); `tail` (3 segments,
taper). Feet carry `foot="1"`.

### Poses

| Pose | Bones and IK |
|---|---|
| `DogSleep` | spine lowered to the mat, front legs aimed forward flat, hind legs folded forward, head aimed down onto the paws |
| `DogOneEye` | `DogSleep` with the neck and head raised |
| `DogSit` | spine tilted up 50°, hind paws planted, front legs vertical |

### Model sheet shots

Side and three-quarter turnaround in `DogSit`, and a line-up with Mira and the
stool.
