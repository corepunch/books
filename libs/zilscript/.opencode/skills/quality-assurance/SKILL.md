---
name: quality-assurance
description: Coordinate independent technical, blind functional, artistic, and audience-accessibility release passes for a packaged ZIL adventure
---

Run four independent release perspectives and synthesize them without collapsing different kinds of evidence into one generic bug list.

## Inputs

- Completed Stages 1-8 of the adventure workflow
- Packaged playable build and current tests
- Declared genre, artistic intent, and target audience

## Invoking the Unified Tester

Invoke `@tester` via the `task` tool:

```
@tester Run full QA for <adventure-name>.
```

The unified tester runs all four passes sequentially in a single session:

1. **Technical release gate** — white-box source and design inspection, prose-to-noun audit, vocabulary audit, exit matrix, automated test suite
2. **Blind functional playtest** — organic play without source or design knowledge, bug documentation, regression authoring
3. **Artistic review** — first-experience pass frozen before design inspection, craft rubric with transcript evidence
4. **Accessibility testing** — persona-based sessions from independent fresh saves

Expected output: `<game-name>-qa-report.md` with separate sections for technical, functional, artistic, accessibility, cross-cutting findings, and remediation plan.

## Synthesis

The report already contains cross-cutting findings and remediation plan. No separate synthesis step is needed — the unified report serves as the consolidated quality ledger.

Use these classes:

| Class | Typical evidence | Verification |
|-------|------------------|--------------|
| Technical defect | Failed invariant, state, test, or walkthrough | Automated regression |
| Functional play defect | Exact organic command/output and expected behavior | Parser-level regression |
| Artistic finding | Transcript evidence compared with stated intent | Targeted replay and editorial review |
| Accessibility barrier | Persona-specific stall or loss of operability/perceivability | Repeat persona scenario; regression only for stable mechanics |

Deduplicate shared root causes but retain each perspective's evidence. For example, a missing synonym may be one source fix with both a functional regression and an accessibility impact note.

## Release Decision

The QA gate is not complete until:

- critical/high technical and functional defects are fixed and GREEN;
- the golden path passes from a fresh save;
- every artistic `REVISE` finding has a documented revision or an explicit design decision;
- every material accessibility barrier has a mitigation, accepted limitation, or revised audience claim;
- affected specialist scenarios have been rerun after remediation.

After review, invoke `skill bug-fixing` for code defects and the relevant authoring skill for artistic or accessibility revisions. Then run a short confirmation pass via `@tester`.

## Anti-Patterns

- One context plays organically after already reading the walkthrough or design solution.
- A single severity table mixes crashes, pacing opinions, and access barriers without type or evidence.
- Trope counting substitutes for artistic judgment.
- "The walkthrough passes" substitutes for novice usability.
- Subjective preferences become brittle text regressions.
- Accessibility is reduced to easier puzzles or more hints.
