# Characters — Огонь на маяке

All five people share one human bone skeleton with the same bone names, so
every pose in the scenes works on every person; only proportions, girth and
materials differ. The files are `rooms/prefabs/characters/<name>.blk`. The seal
is its own skeleton. Line-up, turnaround and pose renders:
`rooms/sheet-cast.jpg`, `sheet-varya-turn.jpg`, `sheet-varya-poses.jpg`.

## The shared human skeleton

`spine` (root, 2 segments, upright) → `neck` → `head`; `hem` (a coat or skirt
hanging from the hips); `left_arm` → `left_forearm` → `left_hand` (mirrored);
`left_thigh` → `left_shin` → `left_foot` (mirrored, `foot="1"`). Heads grow
more slowly than bodies (radius ∝ scale^0.6), so children read as children.
Head extras by person: knitted hat with bobble, cap with peak, headscarf, bald
crown; a braid or a beard as extra bones.

**Posing rule.** A joint's `aim` is relative to its parent's current
direction. With the thigh aimed straight forward (`0 0`, a 90° turn from its
rest `0 -90`), the shin needs `0 -178` to hang straight down. Poses in the
scenes: Walk, Run, LookUp, LookDown, Balance, Hang, Climb, Sit, SitHug, Row,
Point, Smoke, Wave, Mend, Push, Jump, Swim, Reach, Lie.

## Varya

| Measure | Value |
|---|---|
| Height | 135 cm (10 years old) |
| Reach | arms up to 175 cm |
| Jump | a 60 cm gap between stones; a long step over one plank (34 cm) |

- **Design:** yellow oilskin coat to the knee, red knitted hat with bobble, one
  brown braid, dark rubber boots. The yellow and red are the brightest colours
  on every page.
- **Face:** round, freckled, brown eyes. Expressions: worried (cottage),
  determined (fork, stones), wary (bridge), scared (falling), triumphant (lamp).
- **Body:** quick and forward-leaning; runs more than she walks.
- **Poses used:** LookDown, LookUp, Run, Walk, Climb, SitHug, Balance, Hang,
  Sit, Jump, Swim, Push, Reach.

## Grandfather Matvei, the keeper

Tall (173 cm), white beard, grey hair, striped nightshirt. States: feverish in
bed, giving his warning, holding Varya's hand asleep. Pose: Lie (the instance
is turned onto its back in the bed).

## Timka

Eleven, 139 cm; blue cap, grey jacket, green rubber boots. Sits mending nets on
the pier (Mend). In the wreck ending he rows out at dawn (painted).

## Agafya, the shepherd

Old, 159 cm, broad; dark red headscarf, brown shawl, long green skirt (a long
`hem`). States: at her hut door pointing the way (Point), leading the sheep
track, waving and running to the bridge (Wave).

## Savely, the ferryman

Big (184 cm), heavy; black cap, bushy brown beard, dark blue pea jacket.
States: smoking by the hut (Smoke), refusing, relenting, rowing (Row),
running to the rescue (Run), standing by the stove.

## The seal

About 120 cm nose to tail, grey, big dark eyes. States: basking on its rock,
speaking, swimming beside the sandbar and the stones (SealSwim).
