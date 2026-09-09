---
name: foundation-and-premise
description: Define the premise, tone, win/lose conditions, and core fantasy for a ZIL adventure before any coding begins
---

Define what game is being built before coding.

## Inputs
- Product intent from user
- Historical craft principles (Infocom-style)

## Required Actions
1. Establish core principle: simulated world first, not branching button-story.
2. Define premise, target player, tone, length, win condition, lose conditions.
3. Write core fantasy in one sentence (what the player feels they are doing).
4. State constraints that affect design fairness and parser guessability.
5. Confirm this stage does not create ZIL code yet.

## Infocom Praise Alignment
- Treat text as the rendering engine: descriptions should be compact, concrete, and spatial.
- Define a memorable opening with one landmark, one visible object, one blocker, and one quick reward.
- Make the high concept explicit beyond "a text adventure" (explorer, wizard, detective, co-play bedtime mystery, etc.).
- Lock in tone early: clear prose, dry humor, real danger, and occasional absurdity.
- Decide challenge policy now: reasoning difficulty stays high, accidental cruelty stays low.
- Plan for optional progressive hints and social/co-play discussion from day one.

## Output
- `DESIGN.md`

## Acceptance Checks
- Premise is specific and playable.
- Win condition is concrete and testable.
- Tone and target audience are explicit.
- No puzzle or prose contradicts world rules.
- Opening scene is instantly actionable and teaches parser play naturally.
- Core fantasy and emotional target are strong enough to pitch in one sentence.

## Reference Sources
- `skills/source_zil_text_adventure_agents.md`: sections 0, 1.1, 2.1, 2.2
- `skills/source_writing_adventures.md`: Part I sections 1, 2, 5
