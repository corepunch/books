# Review — Огонь на маяке

## Technical pass

- `make check` passes: geometry, transitions, hotspots, and
  `tests/test_lighthouse.py` (35 page states explored with their histories, all
  28 pictures reached, 7 endings, retry with restored facts, the seal and
  Agafya facts, the ferryman refusing once).
- `make check-ui` passes; the smoke capture shows the opening page text on the
  cottage wall and the Continue button.
- All scenes load without Scener warnings (`bay`, `home`, `tower`,
  `model-sheet`); every page's text fits its zone at the preferred size; no
  caption overlaps text, another circle or caption.

## Adventure pass (CRAFT checklist)

| Check | Result |
|---|---|
| Route goes somewhere; 6+ places; no place over a quarter of pages | 7 places; the channel holds 9 of 34 pages (26 %), borderline but it is the bottleneck |
| Goal far away, opposing force | the island lighthouse; the storm and the rising tide |
| Most choices are way, trust or risk | yes; one remembering choice at the end |
| About two story pages per decision | 17 : 10 |
| Several warned failures and an early safe ending | 5 failures, each warned; `end-stay` |
| Strangers help, deceive or change | the seal, Agafya, Savely (refuses, then relents) |
| Each act its own country | village; flats or cliffs and the channel; the island and tower |
| Ending recalls the road and points onward | the success recalls grandfather's warning and points to the Far Island; it does not yet recall the road taken (risk) |
| Secret and shortcut | the seal's sandbar; the wreck and the bridge |

## Visual pass

- The blockout reads in every camera: actor, action and target are visible,
  the lighthouse stands on the horizon from the fork, the flats, the cliffs and
  the channel, and the tide rises from page to page.
- Night endings are lit like dusk in the blockout; the colour script asks the
  painter to darken them.
- Humans are simple bone figures; faces, hair, clothes, oars, spray and weather
  are left to the painting.

## Findings

| Finding | Kind | Resolution |
|---|---|---|
| The success ending does not mention the road taken | opportunity | add a `STORY_CHECK` before `end-light` for seal / Agafya variants |
| Failures all end "the lighthouse stays dark"; similar | risk | vary the aftermath in painting and a line each |
| The flats' wreck reads as a dark wedge in the blockout | risk | painter's brief: boat on its side, ribs showing |
| No paintings yet (stage 9) | deliberate | pages show their renders until illustrations exist |

**READY WITH RISKS**
