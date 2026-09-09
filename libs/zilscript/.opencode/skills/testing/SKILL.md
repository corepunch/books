---
name: testing
description: Execute golden-path transcripts, wrong-attempt testing, save/reload persistence checks, and harden the automated parser-driven walkthrough
---

Prove completion path, catch regressions, and close parser/content gaps.

## Inputs
- Implemented ZIL files
- `TRANSCRIPT_TESTS.md`
- `companion.zil` and `companion/COVERAGE.json` when companion choices are in
  scope

## Required Actions
0. Begin this loop during Stage 5 after the first playable room; Stage 6 expands and hardens it rather than starting it.

0a. **Pre-flight static audit:** Before any room-by-room testing, run the mandatory static gates from `@tester` (Pass 1: Technical): prose-to-noun audit, vocabulary and parser audit (synonyms, disambiguation, special characters, NPC name variations, direction handler coverage), and exit matrix. These structural checks catch the most common defect categories without requiring a play session.
1. Execute golden-path transcript.
2. Execute wrong-attempt transcripts and confirm quality responses.
3. Run room checklist commands and object checklist commands.
4. Categorize failures (parser/disambiguation/synonym/state/softlock/etc.).
5. Fix and retest until transcript suite is stable.
6. Validate interactions between timed systems and global mechanics.
7. For each major puzzle, test at least ten likely player commands and verify top attempts have useful responses.
8. Run unwinnable-state probes (missed objects, irreversible actions, timer pressure) and document mitigation behavior.
9. Verify danger telegraphing appears before lethal or high-cost consequences.
10. Add transcript cases for playful/silly inputs to validate tone-preserving parser feedback.
11. Verify hint escalation triggers only after repeated failure.
12. Run the game through `llm.lua` one command per process using the same save file.
13. For every new room or puzzle, run a fresh-game micro-playthrough before implementing the next slice.
14. Promote each passing slice into an automated parser-driven walkthrough.
15. Test one-time events with TAKE/READ/EXAMINE repeated and reordered.
16. Test every opened container by taking its contents in the next process invocation.
17. Treat command transport and game-state verification as separate assertions. With the current ZIL runner, execute `<CO-RESUME ...>` as its own form, then use a single-condition `<ASSERT>` for the resulting location, inventory, flag, or output. Never write `<ASSERT "..." <CO-RESUME ...> <state-check>>`: `ASSERT` is not an all-conditions combinator, and an earlier truthy coroutine result can mask an unevaluated state check.
18. Add a default-verb smoke matrix for every object with an `ACTION` routine. Verify that unhandled verbs fall through: TAKE/DROP for `TAKEBIT` objects; OPEN/CLOSE/LOOK-IN/SEARCH for containers; and other obvious substrate verbs implied by flags.
19. Add a prose-to-world transcript pass: follow every direction named in room prose, examine every named fixture from the room where it is described, and type each player-facing head noun verbatim.
20. Test every conversation topic via parser commands in every room where the NPC interaction can occur; direct routine calls do not prove topic scope.
21. Test syntax variants separately when the parser has distinct grammar lines or flag gates, including bare versus prepositional forms such as `CLIMB BENCH` and `CLIMB UP BENCH`.
22. **Test description ownership through rendered output:** Capture `LOOK` on first entry, immediate repeat, after examining/taking/opening focal objects, and after every relevant state transition. Verify each feature is introduced once, remains spatially understandable, and never contradicts current state. A noun may appear briefly in room prose and still own a separate object line, but the two paths must not repeat the same facts.

22a. **Audit LDESC contradictions within each room:** For every pair of objects in the same room, check that their `LDESC` strings do not describe mutually exclusive states (e.g. one object claims "painting hangs on wall" while another claims "safe behind moved painting"). An unconditional `LDESC` without state-gated `NDESCBIT` or `DESCFCN` is a contradiction risk.
23. **Audit `FDESC`/`NDESCBIT` combinations:** Treat an object with both as suspicious. Prove its `FDESC` is printed deliberately by code; otherwise the prose is dead and must move to the room/room action or the suppression flag must be removed.
24. **Test scenery affordances:** For every concrete noun in room or object prose, issue at least `EXAMINE <noun>` in the described scope. Use real, GLOBAL, grouped, or PSEUDO scenery rather than forcing every noun into an automatic `LOOK` line.

24a. **Perform a programmatic prose-to-noun audit:** Before room-by-room testing, extract every concrete noun from all `LDESC`, `FDESC`, `TEXT`, and room action `TELL` strings in the source. Cross-reference each against the full `SYNONYM`, `PSEUDO`, `LOCAL-GLOBALS`, and `VOC-EXACT` vocabulary. Report every unmatched noun as a High-severity phantom-object issue. This catch-all step prevents atmospheric prose from creating dead nouns.

24b. **Check FDESC nouns for independent backing:** Every concrete noun in an `FDESC` string must have its own parser-accessible object or PSEUDO entry. An `FDESC` mentioning "lamp", "carts", and "benches" requires all three to resolve — not just the object whose `FDESC` it is.
25. **Test untouched dynamic objects:** On this substrate, an untouched object's `FDESC` bypasses `DESCFCN`. For every object with `DESCFCN`, test a changed state before any command touches that object and ensure no static `FDESC` shadows the dynamic text.
26. **Audit golden-path directions after exit changes:** When any room's exit properties change (directions added, removed, or swapped), trace every test action that navigates through the affected rooms and verify the direction strings still match the room definitions. The failing action may be several steps away from the changed room.
27. **Build and test the complete exit matrix:** Enumerate every declared room edge, not only golden-path or conditional exits. For `A --NORTH--> B`, require `B --SOUTH--> A`; likewise pair `NORTHEAST/SOUTHWEST`, `EAST/WEST`, `SOUTHEAST/NORTHWEST`, `UP/DOWN`, and `IN/OUT`. Treat `A --NORTH--> B` plus `B --NORTH--> A` as a failing same-direction loop. Permit a missing or non-opposite return only when the asymmetry is explicitly documented as intentional.
28. **Exercise exits through the parser in both directions:** Static room properties are insufficient because custom `V-GO-*` handlers can diverge from them. Traverse every edge from A to B, then issue the expected opposite direction from B and assert return to A. Apply this to ordinary, conditional, door-backed, and custom movement. For conditional exits, test blocked and unblocked states in both directions and verify compatible conditions.
29. **Audit for duplicate objects:** For each portable item type (knife, key, rope, etc.), verify that exactly one interactive instance exists in the world. If the same item type appears in multiple locations, test that only one is TAKE-able and the others are either non-interactive scenery or distinct objects with different descriptions and states.
30. **Run the complete companion coverage gate when a companion is in scope:**
    - compare all source room declarations with the manifest classifications;
    - fail if the counts differ or a reachable room lacks authored candidates;
    - restore every reachable state-family setup;
    - query required and forbidden IDs in companion mode;
    - execute every eligible card from an independent restore;
    - assert parser output and the declared postcondition separately;
    - fail if any reachable family remains `FALLBACK-REVIEWED` or
      `NOT-COVERED`.
31. **Run a full choice-only route:** From a fresh game, reach an ending in
    companion mode using numbered choices only. Add route or checkpoint
    evidence for optional rooms, backtracking, alternate solutions, hazard
    recovery, deaths, and alternate endings.
32. **Use models only for the evidence they can supply:** run a relatively weak
    model as a blind player with visible labels and game output to detect loops,
    unclear wording, spoilers, and missing recovery. Use deterministic tooling
    for room enumeration and exhaustive card execution; a successful model
    route is not a completeness proof.
33. **Prefer the persistent companion host path:** use
    `llm.lua --choices/--choose` when implemented. Until then, a focused Lua
    runner may call `COMPANION_QUERY` and `COMPANION_SELECT` directly, but it
    must isolate checkpoints and emit equivalent structured evidence.

## Play-As-You-Build Loop

```bash
SAVE=/tmp/adventure-slice.sav
lua5.4 llm.lua --new-game --save "$SAVE" --game adventure-name
lua5.4 llm.lua --action "go north" --save "$SAVE" --game adventure-name
lua5.4 llm.lua --action "examine reading-desk" --save "$SAVE" --game adventure-name
```

Testing has three complementary layers:
1. Direct ZIL assertions prove routines and state transitions.
2. Focused `llm.lua` sequences prove parser and cross-process persistence.
3. A full automated golden path proves the shipped game from fresh start to win.

Companion work adds two more layers:
4. A deterministic state-family runner proves every emitted card from an
   isolated matching state.
5. A blind weak-model route tests whether the curated choices are understandable
   without source knowledge.

For direct ZIL tests, keep each assertion atomic. A successful coroutine resume proves only that the command loop ran; it does not prove that the command parsed, printed useful output, moved the player, moved an object, or changed state.

## Executable Walkthrough Contract
- A module run by `run-zil-test.lua` must load its prerequisites and expose `RUN_TEST`.
- Prefer a parser-driven `tests/test_<adventure>_walkthrough.lua` for the release golden path.
- Add a `make test-<adventure>-walkthrough` target.

## Outputs
- Updated transcripts
- Parser-driven automated walkthrough and Make target
- Bug ledger by category
- Fix changelog
- Companion room/state-family coverage report and per-card execution evidence
  when applicable

## Acceptance Checks
- Golden path is completable end-to-end.
- No known softlocks unless intentionally documented.
- Reasonable commands no longer fail silently or generically.
- Golden path passes from a fresh game with every action crossing a save/reload boundary.
- The exact documented compound nouns, conversation topics, and custom verbs parse successfully.
- No test combines a coroutine resume and its postcondition as multiple arguments to `ASSERT`.
- Every object action routine has at least one test proving an unhandled generic verb still reaches the substrate default.
- Every room has rendered-output checks showing one coherent description owner per feature on first entry, repeat `LOOK`, and relevant post-state views.
- No intended automatic `FDESC` is silently suppressed by `NDESCBIT`, and no room-owned scenery noun is parser-dead.
- Every test action that navigates between rooms uses the correct direction for both the forward and return trip.
- The technical report contains a complete exit matrix; every ordinary edge has its opposite return or an explicit intentional-asymmetry record.
- No room pair returns via the same compass direction unless a non-Euclidean exception is explicitly designed, documented, and tested.
- Every conditional exit is tested in both the blocked and unblocked states.
- No portable item type has more than one interactive instance; duplicates are either consolidated or explicitly differentiated.
- For companion work, declared and classified room counts match, every reachable
  room and state family is validated, every emitted card has isolated
  matching-state evidence, and a companion numeric-only route reaches an ending.

## Reference Sources
- `skills/source_zil_text_adventure_agents.md`: section 8
- `skills/source_writing_adventures.md`: Testing Your Adventure
