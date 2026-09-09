---
name: bug-fixing
description: Fix technical and functional ZIL defects found during staged QA, including parser, object, exit, persistence, progression, and NPC failures
---

Fix technical and functional defects found by the tester. Load the unified QA report and work through code defects in priority order. Artistic revisions belong to their relevant authoring skill; accessibility changes use this skill only when the underlying problem is mechanical.

## Inputs
- QA report from `@tester` (`<adventure-name>-qa-report.md`)
- Regression tests (`test/` — each must be RED against unfixed code)
- Adventure source (`dungeon.zil`, `actions.zil`)

## Workflow

For each bug in priority order (Critical → High → Medium → Low):

1. **Read the regression test** to understand the exact failure
2. **Identify the root cause** in the source
3. **Fix the source** in the narrowest layer
4. **Run the regression test** — it must go GREEN
5. **Run `make test-pure-zil`** — no regressions
6. **Mark the bug as fixed** in the report

If a regression test is wrong (test authoring mistake, not a real bug), correct the test expectation rather than hacking the source.

Before trusting a green ZIL regression, audit its oracle: run the player command separately, then assert one observable postcondition per `ASSERT`. Do not pass `<CO-RESUME ...>` and a state check as sibling conditions; the current runner returns after the first condition and can report success without evaluating later arguments.

## Bug Categories and Fix Patterns

### Parser / Vocabulary

**Bug symptoms:** Typed command produces "You can't see any such thing" or "I don't know the word" for a noun the prose mentioned. Wrong object is selected in disambiguation.

**Root causes and fixes:**

| Pattern | Fix |
|---------|-----|
| Object has no `SYNONYM` entries | Add `(SYNONYM DOOR KEY ...)` matching every noun a player would type |
| Missing `ADJECTIVE` for multi-word references | Add `(ADJECTIVE STUDY OAK)` for "study door" |
| Hyphenated compound not registered | Add exact hyphenated spelling to `SYNONYM`: `(SYNONYM WINE-CABINET CABINET)` |
| Object ID used as noun but no SYNONYM | `(SYNONYM CANDLESTICK)` — the ID alone is not parser vocabulary |
| Two objects in scope share DESC or SYNONYM | Give one a different `DESC` or add distinguishing `ADJECTIVE` |
| Verb not registered in SYNTAX | Search `infocom/zork1/syntax.zil`; if absent, add `(SYNTAX SEARCH ... = V-SEARCH)` in actions.zil |
| ACTION routine mentions a noun with no corresponding object | Create the object or rephrase the TELL text |

### Object / Container

**Bug symptoms:** Can't open a container that should open. Contents not reachable after opening. Container description doesn't update.

**Root causes and fixes:**

| Pattern | Fix |
|---------|-----|
| Missing `CONTBIT` on container | Add `(FLAGS CONTBIT ...)` |
| Missing `OPENBIT` on initially open container | Add `OPENBIT` to flags |
| Opening doesn't set `OPENBIT` | In the OPEN handler: `<FSET ,OBJECT ,OPENBIT>` |
| Contents not moved inside container | `(IN CONTAINER)` in OBJECT definition, or `<MOVE ,ITEM ,CONTAINER>` |
| Contents unreachable after open in next process | Verify open succeeded — test `TAKE ITEM` in a separate `llm.lua` call |
| WRITE / manual EXAMINE override hides container contents | Remove custom EXAMINE handler — let `V-EXAMINE` → `PRINT-CONT` handle it |
| Missing `SEARCHBIT` | Add if container should be searchable (LOOK IN / SEARCH) |
| Object `ACTION` ends in unconditional `<RTRUE>` | Remove the catch-all true return; return true only in handled branches so OPEN/CLOSE/LOOK-IN and other defaults can run |

### Action Dispatch / Silent Commands

**Bug symptoms:** A valid command produces no text and no state change, while the same object has a custom EXAMINE or puzzle handler.

1. Inspect the object's `ACTION` routine for an unconditional trailing `<RTRUE>`.
2. Confirm the desired verb is either explicitly handled or allowed to fall through to the substrate default.
3. Confirm parser syntax and `FIND` flags allow the command to reach the object; a handler cannot repair an object rejected during parsing.
4. Regression-test both the custom branch and an unhandled generic verb on the same object.

### Door / Navigation / Exit

**Bug symptoms:** Can't go through a door. Exit description mentions a door but `OPEN DOOR` fails. Door state doesn't persist.

**Root causes and fixes:**

| Pattern | Fix |
|---------|-----|
| Room LDESC says "door" but no door OBJECT exists | Create door object with `(SYNONYM DOOR)`, declare as `GLOBAL` in both rooms |
| Door is a global boolean, not a real object | Replace global with OBJECT + `OPENBIT`; use global only for supplementary state (locked vs closed) |
| Exit condition checks wrong flag | Fix to check `<FSET? ,DOOR ,OPENBIT>` |
| V-GO routine bypasses conditional exit | Every `(TO ROOM IF COND)` on a room must be replicated in the custom V-GO handler for that direction |
| Door LDESC is static — stays "locked" after unlock | Move to ACTION routine with M-LOOK; compose from object state |
| Missing DOORBIT | Add `DOORBIT` to the door object's flags |
| Room prose promises a direction with no matching exit | Add/correct the exit or correct the prose; verify the stated destination and reverse route |

### State / Persistence

**Bug symptoms:** After save/reload, object states reset. One-time events fire repeatedly. Room description contradicts object state.

**Root causes and fixes:**

| Pattern | Fix |
|---------|-----|
| One-time event not guarded | Wrap in `<COND (<NOT ,FLAG> <SETG FLAG T> ...)>` |
| Parallel verbs discover same clue but all increment | Route through one guard: if TAKE/READ/EXAMINE all reveal it, check the same flag |
| Room LDESC hardcodes mutable state | Remove LDESC, add ACTION routine with M-LOOK |
| Global not set in GO() | Initialize globals in `ROUTINE GO ()` |
| Counter not reset on restore | Z-machine restores from save — test with separate `llm.lua` invocation |

### NPC / Dialogue

**Bug symptoms:** No response to ASK/TELL. Topic not recognized. Wrong response for context.

**Root causes and fixes:**

| Pattern | Fix |
|---------|-----|
| NPC routine checks `<VERB? ASK>` instead of `<VERB? TELL>` | Fix — the zork1 substrate uses `TELL` for both ASK and TELL |
| Topic object doesn't exist or not in scope | Create topic as GLOBAL-OBJECT or ensure it's accessible |
| Topic exists in `LOCAL-GLOBALS` but room omits it from `GLOBAL` | Add it to every room where the conversation can occur, then test through `ASK/TELL ... ABOUT ...` |
| Missing ACTORBIT | Add `ACTORBIT` to NPC flags |
| NPC has only one response — no state awareness | Add at least 3 states: first encounter, after progress, after key event |
| NPC-given item can be TAKEn before gift | Guard TAKE handler with a flag check |
| NPC movement daemon doesn't stop after win | Guard with `<NOT ,GAME-WON>` |

### Progression / Softlock

**Bug symptoms:** Can't reach ending. Puzzle prerequisite inaccessible. Walkthrough fails mid-game.

**Root causes and fixes:**

| Pattern | Fix |
|---------|-----|
| Puzzle chain has missing link | Verify every step in the golden path is reachable and the action exists |
| Item needed for puzzle is destroyed or consumed | Make item indestructible or ensure respawn/recovery path |
| Exit permanently closes behind player | Add alternate return route or make exit one-way only (intentional design) |
| Walkthrough command doesn't match parser | Fix walkthrough to use exact verb/noun forms the parser accepts |
| Score/progress counter never reaches win threshold | Verify every milestone increments a counter and win condition checks it |

## Verification

After each fix:

```bash
# Run the specific regression test
make test-pure-zil

# Run the parser-driven walkthrough (if one exists)
lua5.4 tests/test_<adventure>_walkthrough.lua

# Quick smoke test
lua5.4 llm.lua --game <adventure> --new-game --save /tmp/fix-test.sav
lua5.4 llm.lua --action "look" --save /tmp/fix-test.sav --game <adventure>
```

For a clustered adventure bug report, also run these static audits before closing it:

- object `ACTION` routines with trailing unconditional `<RTRUE>`;
- directional words in room prose versus declared exits;
- concrete prose nouns versus `SYNONYM` entries and object location/scope;
- conversation topic objects versus room `GLOBAL` lists;
- intended command forms versus syntax `FIND` flag requirements;
- tests that pass multiple conditions to `ASSERT`, especially `<CO-RESUME>` followed by a postcondition.

## Outputs
- Updated `dungeon.zil` / `actions.zil`
- Updated regression tests (now GREEN)
- Updated bug ledger with fix status
- Optional: updated QA report with fix notes

## Acceptance Checks
- Every regression test that was RED now passes GREEN
- `make test-pure-zil` passes with no regressions
- Bug ledger shows all critical and high bugs as fixed
- The parser-driven walkthrough completes from a fresh game

## Reference Sources
- `.opencode/agents/tester.md` — the unified tester agent
- `.opencode/skills/quality-assurance/SKILL.md` — finding classification and verification ownership
- `.opencode/skills/zil-implementation/SKILL.md` — critical implementation rules for all the patterns above
- `skills/source_writing_adventures.md` — full ZIL reference
