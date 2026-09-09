# ZIL Text Adventure Design & Implementation Instructions

Purpose: instructions for an LLM/coding agent to design, implement, test, and revise a ZIL-style Infocom text adventure.

Sources used: public descriptions of GET LAMP / Infocom: The Documentary, Steve Meretzky's *Learning ZIL*, Infocom archival material, Infocom/ZIL/Z-machine historical notes, and Steve Meretzky's interview comments on Infocom's workflow and testing.

---

## 0. Core Principle

A text adventure is not a branching story with buttons. It is a simulated world where the player types intentions, the parser interprets them, and the world responds consistently.

The game should be built around:

1. A map of rooms.
2. Objects the player can examine, take, open, move, read, unlock, combine, give, wear, enter, etc.
3. Rules attached to objects, rooms, verbs, and timed events.
4. Puzzles that change the world state.
5. A transcript-driven testing loop.
6. Many custom responses to reasonable failed attempts.

Do not start by writing prose chapters. Start by designing a playable world model.

---

## 1. Materials to Prepare Before Coding

Create these files before implementation:

### 1.1 `DESIGN.md`

Include:

- one-sentence premise;
- target player;
- tone: comic, mysterious, scary, educational, cozy, etc.;
- approximate length;
- win condition;
- lose conditions, if any;
- core fantasy: what the player gets to feel they are doing.

Example:

```md
Premise: A child and parent explore a moonlit library whose books open portals into small fairy-tale worlds.
Target player: parent reading aloud with child aged 6–10.
Core fantasy: discovering secrets by trying verbs and noticing clues.
Win condition: restore the lost bedtime story to the central book.
```

### 1.2 `MAP.md`

Create an ASCII map. Each room needs:

- room id;
- display name;
- short description;
- long description;
- exits;
- blocked exits;
- reason blocked;
- puzzle or story role.

Do not make the map too large at first. A good first game is 8–15 rooms.

### 1.3 `OBJECTS.md`

Table columns:

- object id;
- printed name;
- synonyms;
- starting location;
- portable?;
- container/supporter?;
- openable? locked?;
- visible? hidden?;
- important verbs;
- puzzle role;
- custom failure responses.

### 1.4 `PUZZLES.md`

For every puzzle, write:

- puzzle name;
- player-facing goal;
- required objects;
- required knowledge;
- exact command path;
- alternative valid command phrasings;
- clue chain;
- wrong but reasonable attempts;
- hint text;
- state changes;
- how the puzzle can become unwinnable;
- how to prevent or warn about that.

### 1.5 `STORY_STATE.md`

List all global flags, counters, and story milestones.

Example:

```md
GLOBAL FLAGS
- lantern-lit: boolean
- library-clock-wound: boolean
- goblin-asleep: boolean
- book-restored: boolean

COUNTERS
- turns-since-lantern-lit
- cookies-eaten

MILESTONES
- player enters library
- player opens moon book
- player solves bridge riddle
- player restores final page
```

### 1.6 `TRANSCRIPT_TESTS.md`

Write walkthrough transcripts before or during implementation.

Include:

- golden path transcript;
- transcript for common wrong attempts;
- transcript for examining every important object;
- transcript for all verbs expected by the design;
- transcript for save/restore/restart if supported.

---

## 2. Story Design

### 2.1 Build the story as a world, not as pages

The story is expressed through:

- room descriptions;
- object descriptions;
- changes after actions;
- NPC reactions;
- timed events;
- inventory objects;
- optional discoveries;
- final state.

The player should infer the story by exploring and acting.

### 2.2 Keep a “background universe” document

Before coding, write notes about the world rules:

- what magic/technology exists;
- what characters want;
- what happened before the game starts;
- what cannot happen;
- vocabulary and naming style;
- timeline.

This does not all appear in the game. It exists to make room/object responses consistent.

### 2.3 Use story beats as state changes

Do not write: “Chapter 2 begins.”

Instead, write:

- the clock starts ticking;
- a bridge appears;
- the troll blocks the exit;
- the lantern burns lower;
- the child NPC follows the player;
- a room description changes;
- an object gains a new synonym;
- an NPC answers new topics.

### 2.4 Give every room a job

A room should usually do at least one of these:

- introduce a puzzle;
- hide an object;
- reveal lore;
- connect map regions;
- create danger or time pressure;
- provide a clue;
- act as reward space after a puzzle.

Remove rooms that are only filler unless the mood/exploration value is intentional.

---

## 3. Puzzle Design

### 3.1 A fair puzzle requires three things

1. The player can understand the goal.
2. The player can discover the needed information.
3. The successful command is guessable from the game vocabulary.

If any of these is missing, the puzzle is unfair.

### 3.2 Build puzzle chains explicitly

For each puzzle, write the chain:

```md
Need to cross river
→ notice boat is tied
→ need knife or untie command
→ rope is knotted because wet
→ find oil in shed
→ oil rope
→ untie rope
→ enter boat
```

Then implement each intermediate step as a real world response.

### 3.3 Avoid “read the author's mind” puzzles

Bad:

```text
> rub lamp
Nothing happens.
> polish lamp
A genie appears.
```

unless the exact word “polish” has been clearly taught.

Better:

```text
> rub lamp
The tarnish comes away under your sleeve. Something inside the lamp stirs.
```

Accept multiple phrasings:

- RUB LAMP
- CLEAN LAMP
- POLISH LAMP
- WIPE LAMP

### 3.4 Reward reasonable wrong attempts

Never let the game repeatedly say only “You can’t do that.”

For every puzzle, add responses for:

- the almost-correct object;
- the almost-correct verb;
- using the right object in the wrong place;
- solving the puzzle too early;
- trying violence;
- asking an NPC;
- examining the obstacle again after failure.

Example:

```text
> cut rope with spoon
The spoon scrapes the rope but cannot bite into it. Something sharper might work.
```

### 3.5 Hints should be layered

For parent-child play, hints should not dump the answer immediately.

Use a three-layer hint chain:

1. Attention hint: “The rope looks important.”
2. Direction hint: “The knot is too tight because it is wet.”
3. Action hint: “Maybe oil would loosen it.”
4. Command hint, optional: “Try OIL ROPE.”

The UI can expose hints without listing every possible action.

### 3.6 Do not list all options

Instead of showing 20 available verbs, show:

- current goal;
- 1–3 meaningful hints;
- important objects in the scene;
- optional “try examining…” suggestions;
- a fallback verb palette only when the player is stuck.

For child/parent text adventures, the best hint UI is often:

```text
You may want to look more closely at:
- the locked chest
- the silver key
- the painting
```

not:

```text
Possible commands: take, drop, open, close, unlock, lock, push, pull, read, eat...
```

---

## 4. ZIL / Infocom-Style World Model

### 4.1 Think in rooms, objects, routines

ZIL-style IF mainly consists of:

- rooms: locations in the map;
- objects: things the parser can refer to;
- routines: code attached to actions, rooms, objects, events, and verbs.

Every player input must be handled. A silent non-response is a bug.

### 4.2 Parser flow

The parser turns input into:

- action/verb: PRSA;
- direct object: PRSO;
- indirect object: PRSI.

Example:

```text
> HIT CHEST WITH CROWBAR
PRSA = HIT
PRSO = CHEST
PRSI = CROWBAR
```

Handling order should usually be:

1. indirect object action routine;
2. direct object action routine;
3. room action routine;
4. verb default routine.

The more specific handler should get the first chance to respond.

### 4.3 Object definition checklist

Every important object needs:

- `DESC`: printed name;
- `SYNONYM`: words the parser recognizes;
- `ADJECTIVE`: optional distinguishing words;
- `LOC`: starting location;
- flags: takeable, container, openable, light source, hidden, etc.;
- action routine;
- examine text;
- default failure overrides.

### 4.4 Room definition checklist

Every room needs:

- internal id;
- printed name;
- long description;
- short description after first visit;
- exits;
- conditional exits;
- room action routine;
- objects initially present;
- local-global objects if needed, e.g. sky, walls, floor, river.

### 4.5 Verbs and syntax

For each custom action, define:

- verb word;
- synonyms;
- grammar pattern;
- direct object requirement;
- indirect object requirement;
- prepositions.

Example verb families:

```text
UNLOCK door WITH key
OPEN chest
PUT coin IN slot
GIVE apple TO horse
ASK wizard ABOUT moon
TELL wizard ABOUT dragon
```

Support common alternate phrasings.

### 4.6 Global defaults

Create good default responses for common actions:

- TAKE fixed object;
- OPEN non-openable object;
- READ unreadable object;
- EAT inedible object;
- ATTACK harmless object;
- TALK TO non-person;
- GO blocked direction;
- USE vague object.

But override defaults often. Good IF feels hand-authored.

---

## 5. Keeping Track of Story and State

### 5.1 Use explicit flags

Bad:

```text
The code infers progress from object location only.
```

Better:

```text
bridge-built = true
riddle-solved = true
goblin-trusts-player = true
```

Object location can still matter, but major story states deserve named flags.

### 5.2 State should affect descriptions

After a puzzle changes the world, update:

- room description;
- object description;
- NPC dialogue;
- blocked exits;
- available hints;
- score or progress marker;
- transcript tests.

### 5.3 Maintain a dependency graph

For every object, know which puzzles depend on it.

Example:

```md
silver key
- opens nursery chest
- required before finding moon page
- must not be droppable into well unless recoverable
```

Use this to prevent unwinnable states.

### 5.4 Prevent accidental softlocks

Avoid:

- destroyable required objects;
- NPCs that can permanently leave with required objects;
- one-way exits without warning;
- time limits without enough feedback;
- locked doors after the key is lost;
- puzzles requiring hidden syntax.

If old-school cruelty is desired, make it explicit. For parent-child play, prefer recoverable mistakes.

---

## 6. Writing Room and Object Text

### 6.1 Descriptions must teach gameplay

A room description should:

- establish mood;
- name important nouns;
- imply exits;
- hint at interactable objects;
- avoid burying critical clues in long prose.

Bad:

```text
You are in a beautiful room with many wonderful things.
```

Better:

```text
Moonlight falls across a locked toy chest. A crooked painting hangs above it, and a narrow door leads east.
```

The nouns “chest,” “painting,” and “door” must be implemented or handled.

### 6.2 If a noun is mentioned, handle it

If the room says “moonlight,” “painting,” “dust,” or “rug,” then EXAMINE MOONLIGHT / PAINTING / DUST / RUG should not produce a parser failure.

For unimportant nouns, create scenery objects or local-global responses.

### 6.3 Use short descriptions after first visit

First visit:

```text
You are in the Moonlit Library. Tall shelves lean inward like sleepy giants. A brass ladder rolls along the shelves, and a locked blue book rests on a reading stand.
```

Later:

```text
Moonlit Library
The brass ladder waits by the shelves. The blue book rests on the stand.
```

### 6.4 Make success text visible

After solving a puzzle, print what changed.

Bad:

```text
Done.
```

Better:

```text
The key turns with a soft click. The chest lid rises by itself, releasing the smell of old paper and cinnamon.
```

---

## 7. NPCs and Conversation

### 7.1 Keep NPCs simple unless conversation is central

For each NPC, define:

- location or movement rules;
- topics they understand;
- objects they react to;
- what they know before/after milestones;
- whether they can receive objects;
- whether they can follow commands.

### 7.2 Support ASK/TELL/GIVE/SHOW

At minimum:

```text
ASK WIZARD ABOUT BOOK
TELL WIZARD ABOUT DRAGON
SHOW KEY TO WIZARD
GIVE APPLE TO HORSE
```

### 7.3 NPCs can act as hint systems

For parent-child play, a companion NPC can give diegetic hints.

Example:

```text
> ask owl about chest
"Keys like hiding near things that look ordinary," says the owl, glancing at the painting.
```

---

## 8. Debugging and Testing

### 8.1 Test by transcript

Interactive fiction should be tested through recorded play sessions.

For each test, store:

- commands typed;
- expected output fragments;
- final state;
- score/progress;
- inventory.

### 8.2 Use tester transcripts as design input

When testers try reasonable commands that fail, do not only “fix bugs.” Add:

- synonyms;
- clearer descriptions;
- better failure messages;
- intermediate clues;
- alternate solutions;
- hints.

Testing is where the skeleton becomes a finished game.

### 8.3 Testing phases

Use this staged process:

1. Author test: game compiles, golden path works.
2. Pre-alpha: other authors/agents play and criticize puzzle fairness.
3. Alpha: internal testers try to break the world and solve naturally.
4. Beta: outside testers play without help.
5. Gamma: only critical fixes; no major redesign unless unavoidable.

### 8.4 Bug categories

Track bugs by type:

- parser failure: word not recognized;
- disambiguation failure;
- missing synonym;
- missing scenery object;
- wrong default response;
- puzzle accepts impossible action;
- puzzle rejects reasonable action;
- softlock;
- state desync;
- description not updated;
- NPC contradiction;
- score/progress error;
- typo/style issue.

### 8.5 Required test commands for every room

For each room, test:

```text
LOOK
EXAMINE every noun in room description
GO each listed exit
GO each blocked exit
TAKE each visible object
OPEN/CLOSE each container or door
SEARCH likely scenery
LISTEN
SMELL
INVENTORY
HELP or HINT
```

### 8.6 Required test commands for every object

For each important object, test:

```text
EXAMINE object
TAKE object
DROP object
PUT object IN container
GIVE object TO npc
SHOW object TO npc
USE object
USE object ON puzzle target
READ object
OPEN/CLOSE object if relevant
PUSH/PULL object if physical
```

---

## 9. Agent Workflow

When asked to build or modify a ZIL adventure, follow this order:

1. Read `DESIGN.md`, `MAP.md`, `OBJECTS.md`, `PUZZLES.md`, `STORY_STATE.md`, and existing source.
2. Do not start coding until you can state the win condition and current puzzle chain.
3. Implement one room/object/puzzle slice at a time.
4. Add parser vocabulary immediately when adding nouns to prose.
5. Add transcript tests for the new slice.
6. Run compile/tests.
7. Play the slice manually or with scripted transcript.
8. Add custom responses for failed reasonable attempts.
9. Update docs after code changes.
10. Avoid large rewrites unless the map/puzzle dependency graph requires it.

---

## 10. Minimum Vertical Slice

The first playable build should include:

- 3 rooms;
- 1 locked or blocked exit;
- 1 takeable object;
- 1 scenery object;
- 1 container;
- 1 NPC or sign/book with information;
- 1 puzzle with at least two clue levels;
- 1 win condition;
- transcript tests.

Example slice:

```text
Library → Hallway → Garden
Puzzle: unlock blue book using key hidden behind painting.
Clues: painting is crooked; dust outline behind painting; owl hints that keys hide behind ordinary things.
Commands: EXAMINE PAINTING, MOVE PAINTING, TAKE KEY, UNLOCK BOOK WITH KEY, OPEN BOOK.
```

---

## 11. Parent-Child Hint UI Rules

For an app where a parent reads to a child:

- Do not expose all parser verbs by default.
- Show a small “things to notice” list.
- Allow optional progressive hints.
- Make wrong attempts entertaining, not punishing.
- Let the parent ask for “gentle hint,” “strong hint,” or “exact command.”
- Avoid time pressure unless it is very clear and reversible.
- Prefer puzzle goals that can be discussed aloud.
- Keep room text readable in one breath.

Suggested UI side panel:

```text
Goal: Find a way to open the blue book.
Notice: chest, painting, owl.
Gentle hint: The painting seems less fixed than the shelves.
Strong hint: Try moving the painting.
Command hint: MOVE PAINTING.
```

---

## 12. Definition of Done

A room is done when:

- all nouns in its description are handled;
- all exits work or explain why blocked;
- LOOK changes correctly after state changes;
- room-specific hints exist;
- transcript tests cover normal and wrong actions.

An object is done when:

- synonyms are complete;
- EXAMINE works;
- TAKE/DROP behavior is correct;
- relevant verbs have custom responses;
- impossible uses are explained;
- puzzle dependencies are documented.

A puzzle is done when:

- goal is visible;
- clue chain exists;
- exact command path works;
- alternate phrasing works;
- reasonable wrong attempts receive useful responses;
- no softlock exists unless intentional;
- hints are layered;
- transcript tests pass.

A game is done when:

- golden path works from start to finish;
- every room/object has basic coverage;
- testers can solve it without author help;
- transcripts have been reviewed;
- late fixes are limited to bugs and clarity.

---

## 13. Practical LLM Prompts for Subagents

### Puzzle reviewer

```text
Review PUZZLES.md and source. Find unfair puzzles, hidden assumptions, missing synonyms, missing clues, and possible softlocks. Return concrete fixes only.
```

### Transcript tester

```text
Play the game as a naive player using commands from the visible text. Save the transcript. Mark every parser failure, unhelpful default response, and reasonable attempt that deserved a custom response.
```

### Vocabulary auditor

```text
Scan all room and object descriptions. List every noun phrase. Verify that each noun can be EXAMINEd or has a deliberate parser response.
```

### State auditor

```text
Review all puzzle-critical objects and flags. Identify states where the game becomes unwinnable or descriptions contradict state.
```

### Hint writer

```text
For every puzzle, write four hints: attention, direction, action, exact command. Keep hints suitable for a parent reading to a child.
```

---

## 14. Important Style Rules

- Prefer concrete nouns over abstract prose.
- Mention interactable objects clearly.
- Keep commands guessable.
- Accept synonyms generously.
- Add custom failure text for reasonable attempts.
- Use testing transcripts as the main feedback mechanism.
- Build small, play, revise, then expand.
- Treat text adventure development as simulation design plus writing, not only writing.
