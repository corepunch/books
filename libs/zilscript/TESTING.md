# Testing & QA Orchestration

How to run QA on any ZIL adventure using the unified tester agent.

## Prerequisites

- Adventure has a playable build (compiled ZIL, runnable via `llm.lua`)
- Adventure folder exists under `books/` or `infocom/` with `dungeon.zil` and `actions.zil`
- `make test-pure-zil` passes on existing tests (if any)
- For a new adventure: Stages 1–8 of the game-writer workflow are complete and the adventure is packaged

## Unified QA

The `@tester` agent runs all four passes sequentially in a single session and produces one unified report:

| # | Pass | Skill | Report Section |
|---|------|-------|----------------|
| 1 | Technical Release Gate | `skill testing` | Technical Audit |
| 2 | Blind Functional Playtest | `skill playtesting` | Functional Playtest |
| 3 | Artistic Review | `skill artistic-review` | Artistic Review |
| 4 | Accessibility Testing | `skill accessibility-testing` | Accessibility |

### Invocation

```
@tester Run full QA for <adventure-name>.
```

**Expected output:** `<game-name>-qa-report.md` with sections for technical, functional, artistic, accessibility, cross-cutting findings, and remediation plan.

The agent maintains pass independence internally — the technical phase runs first (white-box), then functional runs blind (no technical findings carried forward), then artistic (first-experience frozen before design inspection), then accessibility (persona sessions from fresh saves).

## Remediation

After the report is generated:

1. Load `skill bug-fixing` for code defects
2. Fix Critical → High → Medium → Low priority bugs
3. Run `make test-pure-zil` after each fix
4. Run affected specialist scenarios after remediation

## Release Decision

The QA gate is not complete until:

- Critical/high technical and functional defects are fixed and GREEN
- Golden path passes from a fresh save
- Every artistic `REVISE` finding has a documented revision or explicit design decision
- Every material accessibility barrier has a mitigation, accepted limitation, or revised audience claim
- Affected specialist scenarios have been rerun after remediation

## Quick Reference: Re-test blackwood-horror

```
@tester Run full QA for blackwood-horror.
```

This generates `blackwood-horror-qa-report.md`. Review the report, then remediate with `skill bug-fixing`.
