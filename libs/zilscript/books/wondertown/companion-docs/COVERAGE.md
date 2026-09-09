# The Last Toymaker's Apprentice — Companion Coverage

## Summary

| Metric | Count |
|---|---:|
| Declared rooms | 11 |
| Classified rooms | 11 |
| Reachable rooms | 11 |
| State families | 22 |
| Authored | 22 |
| Validated | 0 |
| Fallback-reviewed | 0 |
| Not covered | 0 |
| Exempt | 0 |

## Matrix

| Room | Reachability | State family | Entry evidence | Desired support | Status | Evidence |
|---|---|---|---|---|---|---|
| WORKSHOP-FLOOR | Reachable | workshop.initial | New game | investigate, progress, movement | AUTHORED | — |
| WORKSHOP-FLOOR | Reachable | workshop.have-oil-can | take oil can | oil ladder, investigate, movement | AUTHORED | — |
| WORKSHOP-FLOOR | Reachable | workshop.ladder-oiled | oil mechanism | climb loft, investigate, movement | AUTHORED | — |
| WORKSHOP-FLOOR | Reachable | workshop.key-found-no-study | nutmeg gives key | wind clock, investigate, movement | AUTHORED | — |
| WORKSHOP-FLOOR | Reachable | workshop.study-access | wind old tick x2 | enter study, investigate, movement | AUTHORED | — |
| TOOL-BENCH | Reachable | toolbench.initial | go east | take key, examine, return | AUTHORED | — |
| TOOL-BENCH | Reachable | toolbench.have-key | take key | wind bertrand, examine, return | AUTHORED | — |
| TOOL-BENCH | Reachable | toolbench.wound | wind nutcracker | climb countertop, interact, return | AUTHORED | — |
| COUNTERTOP | Reachable | countertop.case-closed | climb up | open case, interact, return | AUTHORED | — |
| COUNTERTOP | Reachable | countertop.case-open | open case | take items, give button, return | AUTHORED | — |
| COUNTERTOP | Reachable | countertop.items-taken | take items | ask about fox/key, give button, return | AUTHORED | — |
| STORAGE-LOFT | Reachable | loft.initial | climb loft | wind clock, read journal, open box | AUTHORED | — |
| STORAGE-LOFT | Reachable | loft.tick-heard | wind clock | read journal, ask tick, return | AUTHORED | — |
| SNOWY-ALLEY | Reachable | alley.initial | go north (pet door) | examine footprints, go east, return | AUTHORED | — |
| CLOCK-SQUARE | Reachable | square.initial | go east | examine tower, movement options | AUTHORED | — |
| CLOCK-SQUARE | Reachable | square.have-soldier | have soldier | wind tower, examine, movement | AUTHORED | — |
| MAILBOX-CORNER | Reachable | mailbox.initial | go east x2 | take scarf, ask fox, read letter | AUTHORED | — |
| SCRAP-YARD | Reachable | yard.initial | go south | examine cart, take head, return | AUTHORED | — |
| SCRAP-YARD | Reachable | yard.have-head | take head | give head to cart, examine, return | AUTHORED | — |
| SCRAP-YARD | Reachable | yard.cart-moved | give head to cart | go fox den, examine, return | AUTHORED | — |
| FOX-DEN | Reachable | den.initial | go east (past cart) | examine, give scarf, tell tolliver | AUTHORED | — |
| FOX-DEN | Reachable | den.trusting | befriend nutmeg | take key, ask key, tell tolliver | AUTHORED | — |
| FOX-DEN | Reachable | den.hostile | attack fox | examine, candle, return | AUTHORED | — |
| TOLLIVER-STUDY | Reachable | study.initial | enter study | read diagram/journal, examine, descend | AUTHORED | — |
| WORKSHOP-HEART | Reachable | heart.initial | descend to heart | wind heart, examine, return | AUTHORED | — |
| WORKSHOP-HEART | Reachable | heart.wound | wind heart | place companions, examine, return | AUTHORED | — |

## Full-game route evidence

- Child numeric-only ending: (pending validation run)
- Story numeric-only ending: (pending validation run)
- Mixed typed-and-choice ending: (pending validation run)
- Weak-model blind route: (pending validation run)

## Known Gaps

- None. Every reachable room has authored companion support with explicit state families.

## Exemptions

- None. All 11 declared rooms are reachable in ordinary play.
