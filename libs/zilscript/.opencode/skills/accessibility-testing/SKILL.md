---
name: accessibility-testing
description: Test target-audience approachability and accessibility through explicit player personas, fresh sessions, and evidence-based usability findings
---

Evaluate whether the intended audience can perceive, understand, operate, recover from, and complete the adventure. Accessibility is not the same as making every puzzle easy.

## Inputs

- A technically playable packaged build
- Target audience and content expectations from `DESIGN.md` and `package/METADATA.md`
- Hint, recap, objective, transcript, save/restore, and timing behavior

If the target audience is absent or vague, record that as a product-definition finding. Use a conservative provisional audience only to continue the audit, and label the assumption.

## Required Personas

Run each persona from a fresh save and keep their knowledge separate:

1. **Target novice:** Fits the declared audience but has little parser-fiction experience.
2. **Target regular:** Fits the audience and understands common text-adventure conventions.
3. **Access-needs stress persona:** Uses transcript review and keyboard-only input, benefits from plain progress communication, has limited working-memory tolerance, and cannot rely on rapid reactions or subtle formatting.

Add a child/co-play, second-language, or genre-sensitive persona when the declared audience makes it relevant. Personas are test lenses, not claims that one simulation represents every real person.

## Audit Areas

### Operability and parser approachability

- The opening teaches or demonstrates how to begin without requiring prior parser folklore.
- Likely natural commands and reasonable synonyms work or produce corrective guidance.
- Parser failures preserve the player's idea and suggest the missing form without dumping a full command menu.
- Disambiguation, pronouns, `AGAIN`, correction, save, restore, and transcript review are understandable.

### Orientation and cognitive load

- Current location, exits, immediate goal, progress, inventory, and important state changes remain recoverable after a break.
- Essential clues are repeatable or recorded; completion does not depend on remembering a one-time wording detail.
- Note-taking is supported where the design expects it.
- Text density, sentence structure, naming, and clue load fit the target audience.

### Difficulty, recovery, and hints

- Challenge comes from reasoning rather than guessing exact wording.
- Wrong-but-reasonable attempts teach something.
- Hints escalate from attention to direction to action to exact command, and are available before frustration becomes abandonment.
- Irreversible actions, death, resource loss, and timer pressure are telegraphed and recoverable as promised.
- Optional accommodations do not silently alter the default challenge unless declared.

### Perceivability and safety

- Essential information appears in text and is not conveyed only by capitalization, spacing, color, sound, animation, or timing.
- Output order is transcript- and screen-reader-friendly: location, change, and actionable consequence are understandable linearly.
- Keyboard-only play reaches every required function.
- Content warnings and intensity expectations match the intended audience where relevant.

## Evidence and Classification

For every material finding record persona, prerequisite state, exact command, output, expected support, impact, confidence, and whether the issue concerns:

- functional parser/state behavior;
- usability or onboarding;
- cognitive accessibility;
- timing or recovery;
- content suitability;
- optional preference.

Stable functional failures should be documented for inclusion in the unified QA report's appropriate section (functional playtest or accessibility). Do not encode subjective ease, prose taste, or persona preference as a regression.

## Output

Create `<game-name>-accessibility-review.md` with:

- declared audience and assumptions;
- persona session summaries and stall points;
- audit findings with evidence;
- barriers separated from optional conveniences;
- prioritized recommendations;
- an explicit `READY`, `READY WITH BARRIERS`, or `REVISE` recommendation.

## Acceptance Checks

- At least the three required personas used independent fresh saves.
- The target novice was not granted walkthrough knowledge.
- “Accessible” was not used as a synonym for trivial difficulty.
- Essential-information, timing, transcript, keyboard, memory, recovery, and hint behavior were all considered.
- Functional candidates are clearly separated from subjective findings.
