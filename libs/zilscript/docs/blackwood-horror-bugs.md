# Blackwood Horror - Bug Report

**Test Date:** 2026-07-14  
**Tested By:** Game Tester Agent

## Summary

| Category | Count |
|----------|-------|
| Critical Bugs | 0 |
| High Severity | 1 |
| Medium Severity | 1 |
| Low Severity | 5 |

**Resolution status:** All seven reported issues are fixed. Every isolated regression is now PASS and is included in `make test-horror-all` through `test-horror-playtest-regressions`.

The game was played organically from the sanitarium gate through the chapel using `llm.lua`, one command at a time. No walkthroughs, tests, diffs, or game source were consulted. The mercy resolution was reached successfully.

The previously suspect chapel greeting path worked in this fresh run. During that playtest, both `hello` and `hello patient` produced:

> Patient 189 tilts its head. Green light flares in its eyes. Something cold reaches into your chest. You are not ready.

That behavior has since been deliberately removed. Blackwood now reserves `HELLO` for stock Zork behavior and uses the explicit phrase `say hello` for the prepared ending.

All five naturally inferred conversation topics (`mordecai`, `treatment`, `identity`, `sanitarium`, and `chapel`) were recognized. Repeating the Mordecai topic also produced distinct repeat prose. `give relic to patient` successfully produced the mercy resolution.

---

## Critical Bugs

None found.

---

## High Severity Bugs

### Bug 1: Safe-key clarification cannot be resolved while the brass key is in scope

- **Description:** Opening the hollow red book reveals a safe key. If `take small key` first opens a clarification between it and the brass key, the parser becomes stuck: answering with `safe key` or even issuing the complete command `take safe key` asks the same question again. A fresh `take safe key` with no pending clarification does work, but that is not apparent once the player is trapped in the clarification loop. This blocks the required safe/chapel-key progression unless the player escapes through an unnatural workaround.
- **Commands and output:**

  `take small key`

  > Which small key do you mean, the brass key or the safe key?

  `safe key`

  > Which key do you mean, the brass key or the safe key?

  `take safe key`

  > Which key do you mean, the brass key or the safe key?

- **Expected:** `safe key` or the complete follow-up `take safe key` should resolve the pending clarification and take the safe key.
- **Reproduction:** Take the brass key in Reception, reach the Director's Office, take and open the red leather book, then try the commands above.
- **Workaround confirmed:** Leave the Director's Office, drop the brass key in the Administrative Wing, return, and enter `take key`.
- **Regression Test:** `books/blackwood-horror/test/test-playtest-safe-key.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-safe-key`
- **Regression Status:** `PASS — SMALL now identifies the brass key, and the exact follow-up "take safe key" takes the safe key without entering a clarification loop`
- **Severity:** High

---

## Medium Severity Bugs

### Bug 2: Chapel presentation gives no conversational affordance

- **Description:** The first chapel description calls the NPC only “something” and does not suggest speaking. `examine something` fails, even though `examine patient` works if the player guesses that noun from earlier lore. Conversation is mechanically meaningful, so this is a substantial discoverability gap.
- **Command:** `examine something`
- **Output:** `You used the word "something" in a way that I don't understand.`
- **Expected:** Either “something” should resolve to Patient 189, or the arrival/first examination prose should name the patient and hint that communication is possible.
- **Reproduction:** Enter the Chapel for the first time and respond naturally to “something stands perfectly still” with `examine something`.
- **Regression Test:** `books/blackwood-horror/test/test-playtest-something.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-something`
- **Regression Status:** `PASS — "something" resolves to Patient 189, and the Chapel description now hints that speaking may matter`
- **Severity:** Medium

---

## Low Severity Bugs

### Bug 3: Child's drawing is described but cannot be examined

- **Description:** The Patient Ward explicitly draws attention to a child's crayon drawing, but the noun is not recognized.
- **Command:** `examine drawing`
- **Output:** `You used the word "drawing" in a way that I don't understand.`
- **Expected:** The drawing should be a separately examinable object, even if it repeats or expands the room prose.
- **Reproduction:** Enter the Patient Ward and examine the drawing.
- **Regression Test:** `books/blackwood-horror/test/test-playtest-scenery.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-scenery`
- **Regression Status:** `PASS — the drawing is a separately examinable object with authored prose`
- **Severity:** Low

### Bug 4: Prominent filing cabinets are not represented as objects

- **Description:** Reception says filing cabinets line the wall, but `examine cabinets` reports that none are present. Similar filing cabinets are also prominent in the Administrative Wing.
- **Command:** `examine cabinets`
- **Output:** `You can't see any cabinets here!`
- **Expected:** The cabinets should be recognized as scenery and provide a short response.
- **Reproduction:** Enter Reception and examine the cabinets.
- **Regression Test:** `books/blackwood-horror/test/test-playtest-scenery.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-scenery`
- **Regression Status:** `PASS — cabinets respond with room-specific prose in Reception and the Administrative Wing`
- **Severity:** Low

### Bug 5: Fixed gate plaque can be removed and carried

- **Description:** The corroded plaque is described as hanging on the sanitarium gate, but `take plaque` succeeds. It then consumes limited carrying capacity and can be transported through the game.
- **Command:** `take plaque`
- **Output:** `Taken.`
- **Expected:** The plaque should be fixed in place, or removing it should have bespoke prose and a purpose.
- **Reproduction:** At the starting gate, take the plaque.
- **Regression Test:** `books/blackwood-horror/test/test-playtest-scenery.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-scenery`
- **Regression Status:** `PASS — the plaque refuses removal and remains at the gate`
- **Severity:** Low

### Bug 6: Blood writing and name tag lack their natural nouns

- **Description:** The Padded Cell says something is written on the walls in dried blood, but `read writing` is not understood. The straitjacket examination calls out a name tag, but `read name tag` fails on `tag`. The information remains accessible through `examine walls` and `examine straitjacket`, so this does not block progress.
- **Commands and output:**

  `read writing`

  > You used the word "writing" in a way that I don't understand.

  `read name tag`

  > You used the word "tag" in a way that I don't understand.

- **Expected:** These explicitly mentioned nouns should be recognized and redirect to the relevant descriptions.
- **Reproduction:** In the Padded Cell, try the two commands above after reading the room and straitjacket descriptions.
- **Regression Test:** `books/blackwood-horror/test/test-playtest-scenery.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-scenery`
- **Regression Status:** `PASS — both "writing" and "name tag" resolve to their authored responses`
- **Severity:** Low

### Bug 7: Mercy-ending prose leaves the relic in the wrong location

- **Description:** The mercy ending says, “When the light fades, the relic lies on the floor,” but the relic remains in the player's inventory after Patient 189 is removed.
- **Command:** `give relic to patient`
- **Expected:** The relic should be moved to the Chapel floor as the ending prose states.
- **Reproduction:** In the Chapel, carry the ancient relic and give it to Patient 189, then inspect the relic's location.
- **Regression Test:** `books/blackwood-horror/test/test-playtest-give-relic.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-give-relic`
- **Regression Status:** `PASS — mercy prose, GAME-WON, patient removal, and the relic's Chapel-floor location all pass`
- **Severity:** Low

---

## Successful Regression Checks

- Bare `hello` retains stock Zork behavior and does not complete the ending.
- `hello patient` retains stock Zork behavior and does not complete the ending.
- `say hello` reaches Patient 189 and completes the prepared ending.
- `ask patient about mordecai` works and has distinct first/repeat responses.
- The treatment, identity, sanitarium, and chapel topics all work.
- The chapel topic points clearly toward the wooden box.
- `open box` automatically uses the carried scalpel and reveals the relic.
- `give relic to patient` works and produces a complete mercy-resolution scene; it does not fail silently.
- After the mercy resolution, the Chapel description updates to show that Patient 189 is gone and the oppressive presence has lifted.

### Automated SAY HELLO verification

- **Regression Test:** `books/blackwood-horror/test/test-playtest-say-ending.zil`
- **Test Command:** `lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-say-ending`
- **Regression Status:** `PASS — bare HELLO variants do not win; SAY HELLO produces the distinctive "I remember... who I was" prose, sets GAME-WON, removes Patient 189, and leaves the player in the post-ending Chapel`
- **Load-order note:** Every Blackwood test inserts `books/blackwood-horror/blackwood-horror.zil` itself, matching production. Blackwood does not redefine or route `V-HELLO`; it adds the content-local `SAY HELLO` phrase and `V-SAY-HELLO` action.

### Additional review regressions

- `books/blackwood-horror/test/test-playtest-lore.zil` verifies that taking the patient file or straitjacket before examining it no longer suppresses lore discovery.
- The same test verifies both sides of the mirror-reflection transition at zero and positive lore.
- All isolated tests contain comments preserving the exact organic command and bad output/state that motivated the synthetic setup.

## Implemented recommendations

1. The safe key no longer shares the misleading `SMALL` adjective with the brass key.
2. `something` resolves to Patient 189, and Chapel prose supplies a restrained conversational cue.
3. The drawing and filing cabinets are represented; blood writing and name tag vocabulary are recognized.
4. The gate plaque is fixed in place with bespoke refusal prose.
5. The mercy ending moves the ancient relic to the Chapel floor.

---

*Report generated by game tester agent*
