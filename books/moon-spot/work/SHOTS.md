# Shot list — Мира и лунный зайчик

One camera per page and per picture state, all in `rooms/kitchen.blks`. Text
zones are normalised `x y width height` of the 4:3 image; they were sized from
the headless `text_region` so every passage fits at its preferred size.
Anchors are the named groups the C file registers (`moonspot`, `bublik`,
`stool`, `mirror`, `curtain`).

| Camera | Page | Story question | Actor / action / target | Framing | Clues and continuity | Colour script | Text zone | Anchors | Picture state |
|---|---|---|---|---|---|---|---|---|---|
| `floor-show-kitchen` | room | "Mira wants that spot of light." | Mira sitting, watching the spot on the dresser door | wide, high from the south-east corner, oblique | spot trembling; curtain at the window; Бублик asleep; stool by the table; photograph by the window | cold moon on the table, red stove glow on Бублик | dark floor, lower left `0.03 0.76 0.42 0.19` ×0.72 | `MoonSpot`, `Bublik`, `Stool` | Бублик asleep, spot on dresser, mirror facing it |
| `floor-pounce-spot` | beat | "The spot slides away." | Mira rearing, paws on the dresser door, spot beside them (painted on her back) | close, low | chip on the dresser door | cold, dim | plaster, upper right `0.62 0.06 0.35 0.14` ×0.74 | — | as start |
| `floor-wake-bublik` | beat | "The old dog opens one eye." | Mira paws Бублик's ear; he lifts his head | medium, low from the south-east | spot still on the dresser behind | warm stove light on both | dark floor, lower left `0.03 0.81 0.38 0.14` ×0.74 | — | Бублик one eye open |
| `floor-climb-stool` | beat | "Up to the table." | hind paws on the stool, front paws on the table edge | medium, low from the south-west, tight so neither dresser nor mat shows | window, photograph | moonlit window above | dark window, upper left `0.03 0.03 0.40 0.11` ×0.74 | — | valid in both states |
| `table-show-mirror` | room | "The light comes from grandmother's mirror." | Mira on the table facing the mirror | medium-wide, high from the south | spot on the dresser at left, the window, both curtains, stool | moonbeam (painted) crossing the dark room | floor, lower left `0.03 0.80 0.44 0.16` ×0.72 | `Mirror`, `Curtain`, `Stool` | mirror facing the dresser |
| `table-push-mirror` | beat | "Push — and the spot jumps onto Бублик's nose." | Mira's paw on the mirror rim; Бублик sitting, spot on his nose | medium, table height from the south-west | the stove and kettle; spot on nose | warm and cold meeting | plaster, top centre `0.40 0.03 0.32 0.20` ×0.74 | — | mirror turned, Бублик sitting |
| `table-show-turned` | room | "Now Mira knows how to move it." | Mira on the table; spot on the mat by the sitting dog | same as `table-show-mirror` | spot gone from the dresser; basket in the dark corner | same, the spot now warm-side | same zone (never consecutive with `table-show-mirror`) | `Mirror`, `Curtain`, `Stool` | mirror turned toward the mat |
| `table-catch-curtain` | beat | "The curtain covers the moon." | Mira up on the sill board, paws in the curtain's edge | close, from the east | window, open форточка | darkest page of the book | plaster, upper left `0.03 0.05 0.36 0.17` ×0.74 | — | valid in both states |
| `table-go-floor` | beat | "Back down, quietly." | Mira at the table edge looking down at the stool | medium, low from the south-west | stool directly below | moonlit table edge | dark window, upper left `0.03 0.03 0.38 0.11` ×0.74 | — | valid in both states |
| `floor-show-awake` | room | "Бублик is awake and the spot lies by him." | Mira approaching the sitting dog | same as `floor-show-kitchen` | spot on the mat; the dresser door now dark | stove glow brighter in the story (painted) | dark floor, lower left `0.03 0.82 0.42 0.13` ×0.72 | `Bublik`, `Stool` | Бублик sitting, spot on the mat, mirror turned |
| `floor-talk-bublik` | beat | "The grumpy dog is kind." | Mira looking up at the sitting dog | medium, low from the south-west | photograph above the table (the secret), spot on the mat | warm | plaster, upper right `0.70 0.05 0.27 0.19` ×0.72 | — | Бублик friendly |
| `kitchen-sleep-basket` | ending | "Mira sleeps in her own patch of moon." | Mira curled in her basket in the spot | medium, high from the north-east | basket, yarn ball, dresser; Бублик asleep off-frame | silver in the basket against warm dark | plaster, top `0.10 0.04 0.52 0.22` ×0.72 | — | mirror aimed at the basket |
| `kitchen-sleep-bublik` | ending | "Two friends asleep in one patch of moon." | Mira curled at Бублик's side, both in the spot | medium, low from the south-west | stove glow, table and the photograph behind | warmest page | dark floor, lower left `0.03 0.80 0.54 0.16` ×0.72 | — | spot on the mat, both asleep |
| `cover` | — | "A kitten, a spot of moonlight, a sleeping dog." | Mira watching the spot; Бублик asleep | wide, low from the south-east | dresser, window, table | as the opening | ceiling and upper wall for the title | — | as start |

Wide shots keep Mira at about 7 % of the frame height (`floor-show-kitchen`)
and Бублик well above that. Every anchor lies at least 5 % inside the frame;
the headless read and `tests/test_moon-spot.py` confirm every room choice has a
circle whose caption misses the text and the other controls.

Known repeat: `floor-wake-bublik` and the page after it (`floor-show-kitchen`)
both keep their text lower left. Both are the only quiet dark floor in their
frames; recorded in REVIEW.md.
