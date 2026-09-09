---
name: artistic-review
description: Review a playable adventure for narrative architecture, genre craft, pacing, contrast, prose, puzzle-story integration, and ending quality
---

Assess whether the adventure succeeds as a designed work, separately from whether its code functions.

## Inputs

- A technically playable packaged build
- `DESIGN.md`
- `work/PROSE.md`, `work/PUZZLES.md`, and `work/STORY_STATE.md`
- Package synopsis and metadata

## Review Sequence

### 1. First-experience pass

Start a fresh game and play without reading design rationale, walkthroughs, tests, or source. Record transcript excerpts and state/location context for:

- the opening promise and player motivation;
- moments of curiosity, surprise, dread, warmth, humor, beauty, confusion, or boredom;
- perceived act thresholds and escalation;
- how puzzles contribute to or interrupt the story;
- changes in the world and NPC behavior;
- the emotional and thematic effect of the ending.

Freeze these observations before inspecting authored intent.

### 2. Intent comparison

Read the design and working materials. Compare intended genre, audience, themes, acts, contrast, puzzle roles, NPC arcs, and ending with the experienced result. Do not award credit for intentions that are not legible in play.

### 3. Craft rubric

Evaluate with transcript evidence:

1. **Promise and payoff:** The opening establishes a compelling dramatic question and later developments answer or transform it.
2. **Act architecture:** Three acts or the declared alternative have perceptible thresholds, escalating stakes, and different dominant dramatic or challenge functions.
3. **Genre and tropes:** Required genre pleasures are present; familiar tropes are varied, combined, or deliberately subverted rather than merely checked off.
4. **Contrast:** Sustained horror, comedy, or intensity has countertones that restore sensitivity. For horror, explicitly examine beauty, warmth, and humor.
5. **Pacing:** Discovery, reflection, pressure, and payoff alternate intentionally. Exposition and puzzle friction do not flatten momentum.
6. **Puzzle-story unity:** Major puzzles express character, setting, theme, or conflict rather than acting as interchangeable locks.
7. **World response:** Major thresholds visibly change at least two existing rooms, objects, systems, or NPC behaviors when the design calls for a changed world.
8. **Characters:** Key NPCs have discoverable states, agency, reactions, and consequences beyond static topic dispensing.
9. **Prose and description ownership:** Text is concrete, concise, state-aware, tonally coherent, and avoids contradictory or repetitive description paths.
10. **Ending:** Resolution follows from play, recalls specific discoveries, preserves meaningful agency, and produces an earned emotional aftereffect.
11. **Object uniqueness:** Each portable item type appears as exactly one interactive instance; duplicate items (e.g. a knife in one room and another knife elsewhere) are either consolidated or explicitly differentiated with distinct descriptions, states, and puzzle roles. Duplicate portable objects confuse players about which item is relevant and dilute the significance of discovery.

## Finding Types

Classify each finding as:

- **Defect:** The experienced work contradicts an explicit promise or itself.
- **Craft risk:** Evidence suggests the intended effect is weak, uneven, or likely to miss.
- **Deliberate choice:** A departure from convention that is coherent and supported.
- **Opportunity:** Optional improvement, not a release blocker.

Rate confidence separately from impact. Artistic findings are not functional bugs by default and do not require synthetic parser regressions.

## Output

Create `<game-name>-artistic-review.md` containing:

- intended and experienced genre/promise;
- first-experience notes;
- act and pacing map;
- rubric findings with transcript/location evidence;
- strengths that should be preserved during revision;
- prioritized recommendations;
- an explicit `READY`, `READY WITH RISKS`, or `REVISE` recommendation.

## Acceptance Checks

- First-experience observations were frozen before design inspection.
- Every material criticism cites something experienced in play.
- Trope presence is not confused with artistic success.
- Intent is compared with execution, not substituted for it.
- Subjective recommendations are not presented as deterministic test failures.
