---
name: workflow-hints
description: Run specialized review passes (puzzle fairness, vocabulary audit, state audit) and maintain progressive parent-child hint UX
---

Operationalize iterative development with specialized passes and parent-child hint UX.

## Inputs
- Stable playable build
- Current transcripts and bug list

## Required Actions
1. Follow staged workflow for incremental changes.
2. Run specialized review passes:
   - puzzle fairness
   - transcript naivety testing
   - vocabulary audit
   - state audit
   - hint writing
3. Maintain parent-child hint strategy:
   - avoid full verb dumps
   - expose progressive hints
   - keep wrong attempts playful and informative
4. Use layered affordances instead of full command menus:
   - story text (what to notice)
   - soft verb hints (few broad actions)
   - parent/narrator hint (private guidance)
   - progressive command hint (only after repeated failure)
5. Preserve mystery while reducing stall-outs; hints should extend play, not skip play.
6. Design for social solving: puzzle prompts and room/object naming should be easy to discuss out loud.
7. Use a vertical-slice gate: design exact commands, implement one slice, play it through `llm.lua`, add it to the automated walkthrough, then proceed.
8. After any vocabulary, containment, counter, route, NPC, or save-system change, replay both the focused slice and the golden path.
9. When companion choices are in scope, keep one shared candidate profile and
   make the vertical-slice gate update `companion/COVERAGE.json`,
   `COVERAGE.md`, transcript evidence, and regressions together.
10. Continue slices until every declared room is classified and every reachable
    room and material state family is authored and validated. Optional rooms,
    mazes, return/recovery routes, hazards, deaths, and alternate endings are
    part of the game; fallback-only support is not completion.
11. After deterministic validation, run a relatively weak model blind with only
    visible labels and game output. Treat loops, unclear choices, premature
    spoilers, or missing recovery as failed hint UX, while keeping deterministic
    coverage as the completeness authority.

## Outputs
- Review findings per specialist pass
- Updated hint panel content
- Iteration plan for next cycle
- Synchronized companion coverage and blind-route findings when applicable

## Acceptance Checks
- Hints are progressive and contextual.
- Review passes produce concrete fixes.
- Workflow remains slice-based, not big-bang rewrites.
- Hint UI avoids replacing parser agency with exhaustive action lists.
- Co-play flow supports parent guidance without immediate spoilers.
- No iteration batch contains multiple unplayed puzzles; each completed slice has parser-driven coverage before the next begins.
- Companion work is not released until a companion numeric-only route reaches
  an ending and all reachable state families are validated.

## Reference Sources
- `skills/source_zil_text_adventure_agents.md`: sections 9, 11, 13
- `skills/source_writing_adventures.md`: Tips for LLM-Driven Adventure Creation
