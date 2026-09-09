# The Limehouse Killings - Refactor and Iteration Plan

## Current Baseline

The July 15, 2026 story pass established a playable implementation baseline:

- Topicless `ASK/TELL` is nil-safe for every NPC.
- `ASK INSPECTOR ABOUT CASE`, `LOCKPICK SET`, and `FOOTPRINT CAST` parse.
- Lestrade begins offstage and arrives at the Act III threshold.
- Library cipher/secret route and Ashworth name dial are fiction-understanding gates.
- Poison is identified with `USE VIAL ON PLANTS`.
- Hudson, Lady Ashworth, and Moriarty have initial, player-changed, and story-progress states.
- The final case requires threat, method, and motive, then offers a letter/poison lead-proof choice.
- Opening telegram supplies a visible object, quick reward, clue, warmth, and humor.
- Key room prose uses concrete sensory details.

Validation baseline:

- Parser-driven Limehouse walkthrough: 630/630 assertions passing.
- Full `make test-pure-zil`: passing.
- Vocabulary audit: zero critical findings.

## Refactor Priority 1 — Make Documentation and Implementation Identical

- [x] Update map, object registry, puzzle graph, story state, hints, prose, and transcript plan.
- [ ] Copy canonical commands from `TRANSCRIPT_TESTS.md` into any player-facing hints.
- [ ] Remove old references to `MATCH`, `FIND WOLFSBANE`, key-operated box, immediate Inspector, and held-item victory.
- [ ] Update `DESIGN.md` and `PLAN.md` in a separate pass if they still describe four acts or the old finale.

Acceptance: a command documented anywhere either passes through `llm.lua` or is clearly labeled future work.

## Refactor Priority 2 — Complete World-State Prose

- [x] Add state-aware look logic for Gate, Dining Room, Greenhouse, Servants' Quarters, Pantry, and Secret Passage.
- [ ] Add discovery text to all important objects without replaying it on every look.
- [x] Remove evidence glints/listings after objects move.
- [x] Ensure each act boundary changes at least two room descriptions and two NPC behaviors.
- [x] Replace room-level mood labels such as “duty,” “secrets,” or “beckoning” with sensory/physical detail.

Acceptance: every major room has one discovery moment, concise revisit prose, and correct mutable state.

## Refactor Priority 3 — Consequential Tools and Props

- [x] Give magnifying glass an optional footprint-detail reveal used by Moriarty, Lestrade, and the ending.
- [x] Rewrite the lantern as Hudson's maintained household keepsake, with optional passage color and no implied required utility.
- [x] Give charcoal a safe recovery response to poison exposure and identify foxglove as another poison.
- [x] Connect the unlatched wine cabinet to the missing private-laboratory delivery bottle.

Acceptance: every major takeable object has a tool, clue, character, risk, joke, trophy, or memory function.

## Refactor Priority 4 — Deeper NPC Loops

- [x] Make intermediate confrontation states reachable and tested before Act III.
- [x] Add repeat responses so testimony does not sound newly discovered twice.
- [x] Add `SHOW/GIVE` responses for footprint, seal, ledger, and statement where they expose character.
- [ ] Consider physical behavior beyond descriptions: Hudson moves tea, Lady changes table objects, Moriarty blocks/attempts an exit.
- [ ] Ensure `GIVE` uses correct articles and NPC-specific reactions.

Acceptance: each NPC has three tested states and at least one action that changes world state, not dialogue alone.

## Refactor Priority 5 — Ending Branch Quality

- [x] Replace held-item counter ending with three-link argument.
- [x] Add lead-proof choice.
- [ ] Give letter-led and poison-led branches one additional persistent distinction before convergence.
- [ ] Test attempts to accuse before Lestrade, before presentations, without a lead proof, and with an irrelevant proof.
- [ ] Confirm both branches reference discoveries and imply next events.

## Testing Workflow

After each slice:

1. Play the exact new command with `llm.lua` from a fresh save.
2. Add it to `tests/test_limehouse_walkthrough.lua`.
3. Run `make test-limehouse-walkthrough`.
4. Run `lua5.4 scripts/check-vocab.lua books/limehouse-killings/dungeon.zil` for prose/vocabulary changes.
5. Run `make test-pure-zil` before handoff.
6. Update the work document controlling the changed behavior.

## Release Criteria

- [x] Game completable through typed parser commands.
- [x] Critical conversation and vocabulary bugs covered by regressions.
- [x] Two major understanding-based gates.
- [x] Three visible acts.
- [x] Delayed Inspector arrival.
- [x] Evidence-specific ending with player choice.
- [x] All major rooms have state-aware discovery/revisit prose.
- [x] All major props have clue, character, risk, recovery, or optional-route roles.
- [x] NPC intermediate states and repeat responses have transcript coverage.
- [ ] Organic playtest confirms the new deductions are fair without reading source/docs.

## Suggested Next Vertical Slice

Add a second automated end-to-end run for the poison-led accusation and focused failure transcripts for premature and irrelevant-proof accusations. This would verify the remaining unchecked ending criteria without changing the established case architecture.
