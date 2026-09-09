---
name: playtesting
description: Run blind functional play-throughs with @tester, collect player-visible evidence, and prepare functional regressions
---

Run blind functional play-throughs with the unified tester agent, collect structured bug reports, and prepare functional defects for remediation. Artistic judgment and audience/accessibility testing are also covered by `@tester` as part of its full QA pass.

## Inputs
- Complete adventure source (`dungeon.zil`, `actions.zil`)
- Existing test suite (`test/`)

## Required Actions

### 1. Invoke the unified tester

Use the `task` tool to invoke `@tester`:

```
@tester Run full QA for <adventure-name>.
```

The unified tester runs all passes in sequence:
1. Technical release gate (white-box, source inspection)
2. Blind functional playtest (organic play, no source knowledge)
3. Artistic review (first-experience, then design comparison)
4. Accessibility testing (persona sessions, fresh saves)

The blindness boundary is maintained internally — the technical phase completes and its findings are set aside before the organic play phase begins.

### 2. Review the QA report

Inspect `<game-name>-qa-report.md`. The functional playtest section categorizes bugs as:
- **Critical** — crashes, hangs, unreachable endings, broken core mechanics
- **High** — missing objects, broken puzzles, blocked progression, state corruption
- **Medium** — missing synonyms, wrong descriptions, weak error messages
- **Low** — cosmetic issues, missing scenery responses, minor verb gaps

### 3. Verify regression tests

For every file the tester created under `test/`:
- Run `make test-pure-zil` to confirm the test runner picks them up
- If a test is a standalone Lua walkthrough, run it directly
- Confirm each regression test is RED against the current unfixed code (reproduces the bug)
- Inspect the oracle, not just the color: issue `<CO-RESUME ...>` separately and assert a single observable postcondition. Reject tests that combine coroutine success and state checks as multiple `ASSERT` arguments.
- For silent-command bugs, assert state/location/inventory or expected text; coroutine resume success alone is not evidence that the verb worked.

## Outputs
- `<game-name>-qa-report.md` — unified report with all pass findings
- Regression tests under `test/`

## Acceptance Checks
- Tester completed a full organic play session
- Every reproducible functional bug requiring a regression has a corresponding RED test
- Bug ledger is prioritized and ready for the fixing stage
- No functional findings were silently skipped; subjective writing observations may remain report-only

## Relation to Other Pipeline Stages

Blind functional playtesting is one part of the post-packaging quality-assurance gate. Bugs found here are fed into the remediation stage. After fixing, rerun the affected focused scenarios and a fresh organic smoke pass.

## Reference Sources
- `.opencode/agents/tester.md` — unified tester agent definition and workflow
- `.opencode/skills/quality-assurance/SKILL.md` — coordination with technical, artistic, and accessibility passes
- `PLAYING.md` — how `llm.lua` works for automated game interaction
