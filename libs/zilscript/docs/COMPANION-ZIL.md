# Companion ZIL Files

## Contextual Intent Cards for Illustrated and Parser-Free Play

This document specifies the companion-file system for ZIL adventures.
A companion file adds a curated, state-aware layer of suggested actions without
changing the adventure's underlying parser, world model, puzzles, or command
handlers.

The player sees narrative intentions such as:

- Open the little mailbox
- Follow the muddy footprints into the kitchen
- Ask Grandfather why he locked the workshop
- Try the door and find out what is wrong

The original game still receives ordinary parser commands:

```text
open mailbox
north
ask grandfather about workshop
open workshop door
```

The companion layer is therefore not a replacement game and not a manually
authored branching tree. It is a presentation and guidance layer over the live
ZIL simulation.

> **Implementation status**
>
> The runtime API described in the core sections is implemented in
> `zilscript/bootstrap.lua`. `main.lua` uses companion play by default and accepts
> `--text` for the original parser loop. Zork I currently has 110 authored cards
> and explicit `SUGGEST-ACTIONS` routing for all 110 of its declared rooms.
> Every reachable room has companion support; games without a companion use
> conservative automatic suggestions, which are a runtime safety net.
>
> State tokens, `CHOICE-SHOWN?`, `llm.lua --choices`, and a graphical client
> remain future work. Sections that describe these facilities identify them as
> planned host contracts rather than current behavior.

For the end-to-end discovery, state-coverage, implementation, and validation
workflow, see [Generating `companion.zil`](GENERATING-COMPANION-ZIL.md).

## Contents

1. [Goals](#goals)
2. [Non-goals](#non-goals)
3. [Core model](#core-model)
4. [Why the companion is a ZIL file](#why-the-companion-is-a-zil-file)
5. [Recommended file layout and loading](#recommended-file-layout-and-loading)
6. [Intent-card data model](#intent-card-data-model)
7. [Proposed ZIL API](#proposed-zil-api)
8. [Evaluation and selection lifecycle](#evaluation-and-selection-lifecycle)
9. [State, knowledge, and history](#state-knowledge-and-history)
10. [Ranking and diversity](#ranking-and-diversity)
11. [Companion interface](#companion-interface)
12. [Authoring patterns](#authoring-patterns)
13. [Navigation as narrative intention](#navigation-as-narrative-intention)
14. [Information and discovery actions](#information-and-discovery-actions)
15. [Inventory and puzzle actions](#inventory-and-puzzle-actions)
16. [NPC, emotional, and expressive choices](#npc-emotional-and-expressive-choices)
17. [Danger, clocks, and changing state](#danger-clocks-and-changing-state)
18. [Scene illustrations](#scene-illustrations)
19. [Host and UI contract](#host-and-ui-contract)
20. [Fallback suggestions](#fallback-suggestions)
21. [Agent-assisted authoring](#agent-assisted-authoring)
22. [Validation and testing](#validation-and-testing)
23. [Retrofitting existing adventures](#retrofitting-existing-adventures)
24. [Common mistakes](#common-mistakes)
25. [Implementation status and next phases](#implementation-status-and-next-phases)
26. [Complete example](#complete-example)
27. [Reference checklist](#reference-checklist)

## Goals

The companion system should:

1. Let a player interact without typing or learning parser grammar.
2. Derive available choices from the adventure's actual current state.
3. Preserve the original ZIL game as the authority for what happens.
4. Present meaningful intentions rather than implementation-oriented commands.
5. Show every currently eligible, meaningfully distinct choice.
6. Mix progress, investigation, character, atmosphere, and experimentation.
7. Reduce parser friction without automatically revealing every puzzle answer.
8. Make temporary failure useful by offering discovery actions.
9. Track what the player has learned separately from what is objectively true
   in the world.
10. Work as an optional layer so classic typed play remains available.
11. Permit an agent to draft coverage by playing and inspecting an existing
    adventure.
12. Produce deterministic, testable, offline behavior in the shipped game.
13. Allow a graphical host to associate the current scene with an illustration.

The intended experience is an interactive illustrated book backed by a real
simulated world. The choices change because objects move, doors open, characters
react, clocks fire, and puzzle globals change—not because the player arrived at
a hard-coded paragraph number.

## Non-goals

The companion system should not:

- Reimplement room, object, inventory, or puzzle state in a second engine.
- Replace the original parser command handlers.
- Generate arbitrary commands with a live language model during ordinary play.
- List every command the parser could technically recognize.
- Guarantee that every visible card is equally productive.
- Turn each room into a static choose-your-own-adventure page.
- Expose compass directions when a more meaningful destination can be named.
- Spoil a solution before the player has observed the relevant problem.
- Mutate game state merely because the UI asks which choices are available.
- Advance turns, clocks, enemies, hunger, light timers, or random sequences while
  evaluating suggestions.
- Require changes to vendored adventure logic when a companion module can express
  the behavior locally.

## Core model

Each displayed choice is an **intent card** with two faces:

| Player-facing face | Engine-facing face |
|---|---|
| Narrative label | Parser command |
| “Climb through the kitchen window” | `enter window` |
| “See whether the old key fits” | `unlock door with old key` |
| “Follow the singing into the forest” | `east` |
| “Ask Mara what frightened her” | `ask mara about fear` |

The player chooses what the protagonist intends to do. The original parser and
action routines decide whether it works and produce the resulting prose.

This preserves several useful properties of parser adventures:

- The object tree remains authoritative.
- Existing `ACTION` routines still handle edge cases.
- The same command can behave differently as state changes.
- Scores, clocks, NPCs, inventory limits, darkness, vehicles, and hazards retain
  their existing behavior.
- Typed play and card-based play can share save games.
- A companion-file bug cannot silently invent a new puzzle outcome; at worst it
  can offer a poor or unrecognized command, which validation must catch.

The companion is best understood as a state-dependent command index plus a
narrative editorial layer.

## Why the companion is a ZIL file

A companion file should live in the same runtime environment as the adventure.
That lets its conditions directly reference:

- `HERE`
- `WINNER`
- rooms and objects
- `IN?` and `LOC`
- flags through `FSET?`
- ordinary adventure globals
- puzzle counters and NPC states
- light, vehicle, and containment state
- companion-specific knowledge flags

For example:

```zil
<COND
  (<AND <EQUAL? ,HERE ,WORKSHOP-YARD>
        <IN? ,LOCKPICK ,WINNER>
        <NOT <FSET? ,WORKSHOP-DOOR ,OPENBIT>>>
   <CHOICE "workshop.pick-lock"
           "Unlock the workshop with the lockpick"
           "unlock workshop door with lockpick"
           ,CHOICE-PROGRESS
           100>)>
```

The companion does not need a serialized mirror saying:

```json
{
  "room": "workshop-yard",
  "inventory": ["lockpick"],
  "workshopDoorOpen": false
}
```

Avoiding that mirror prevents synchronization bugs. The ZIL world is queried
directly.

The companion is also well suited to source control:

- Choice wording can be reviewed alongside game prose.
- Conditions can use the same identifiers as the adventure.
- Changes can be diffed and tested deterministically.
- Imported games can remain substantially untouched.
- Agent-generated drafts can be edited by a human before release.

## Recommended file layout and loading

Use one primary companion file per adventure:

```text
infocom/zork1/
  zork1.zil
  dungeon.zil
  actions.zil
  companion.zil

books/my-adventure/
  my-adventure.zil
  dungeon.zil
  actions.zil
  companion.zil
  companion-scenes.json
```

Large adventures may split the source internally:

```text
companion.zil
companion/
  surface.zil
  underground.zil
  finale.zil
  characters.zil
```

`companion.zil` remains the public entry module and inserts the smaller files.

### Load order

Load the companion after the adventure has declared the rooms, objects, globals,
directions, parser vocabulary, syntax, and action routines it references.

For an aggregate game file, the conceptual order is:

```zil
<INSERT-FILE "main">
<INSERT-FILE "parser">
<INSERT-FILE "syntax">
<INSERT-FILE "verbs">
<INSERT-FILE "globals">
<INSERT-FILE "dungeon">
<INSERT-FILE "actions">
<INSERT-FILE "companion">
```

For host-managed module lists:

```lua
modules = {
    "infocom.zork1.globals",
    "infocom.zork1.clock",
    "infocom.zork1.parser",
    "infocom.zork1.verbs",
    "infocom.zork1.actions",
    "infocom.zork1.syntax",
    "infocom.zork1.dungeon",
    "infocom.zork1.main",
    "infocom.zork1.companion",
}
```

The exact order still depends on the adventure. The rule is simple: the
companion is an adapter over completed game declarations, so load it last unless
a specific game has a documented reason not to.

### Recommended entry routines

The companion module exposes these routines:

```zil
<ROUTINE SUGGEST-ACTIONS () ...>
<ROUTINE SUGGEST-SCENE () ...>
```

`SUGGEST-ACTIONS` emits eligible candidates for the current state.
`SUGGEST-SCENE` optionally emits an illustration key and accessible description.

The host calls these routines only while the game is waiting at `READ`.

## Intent-card data model

Every card requires five core fields.

| Field | Meaning | Example |
|---|---|---|
| `id` | Stable machine identifier | `workshop.pick-lock` |
| `label` | Text shown to the player | `Unlock the workshop with the lockpick` |
| `command` | Parser input sent to the game | `unlock workshop door with lockpick` |
| `kind` | Editorial role in the set | `PROGRESS` |
| `priority` | Base ranking weight | `100` |

Recommended optional metadata includes:

| Field | Meaning |
|---|---|
| `tone` | Brave, kind, curious, cautious, funny, mischievous |
| `group` | `scene` for local actions or `move` for navigation |
| `destination` | Named destination for navigation cards |
| `subject` | Primary room object or NPC |
| `once` | Whether to suppress after selection |
| `repeat-penalty` | How quickly repeated presentation should decay |
| `learns` | Knowledge recorded when the card is selected |
| `image-key` | Optional preview or card artwork |
| `accessibility-label` | Alternate spoken label when needed |
| `debug-note` | Author-only explanation of the condition |

The minimal API should not require all optional fields. It is better to ship a
small reliable primitive and add metadata through explicit helper forms than to
make every author write a very long positional call.

### Stable IDs

IDs should be:

- Unique within the adventure.
- Stable across wording edits.
- Lowercase ASCII with dot-separated namespaces.
- Descriptive of the intention, not its current label.
- Independent of display order.

Good:

```text
west-house.open-mailbox
workshop.discover-locked-door
workshop.pick-lock
grandfather.ask-about-key
forest.return-to-bridge
```

Poor:

```text
choice1
button-three
open-the-old-brown-workshop-door-with-the-rusty-lock
north
```

The ID is used for history, stale-choice validation, testing, analytics, and save
compatibility. Renaming it should be treated as a data migration.

### Labels

A label should:

- Begin with a concrete verb.
- Name a destination instead of a compass direction when possible.
- Be understandable without parser knowledge.
- Avoid promising success when the action may fail.
- Avoid exposing a fact the protagonist has not learned.
- Usually fit on one or two lines in the target UI.
- Preserve the tone and narrative voice of the adventure.

Compare:

| Weak | Better |
|---|---|
| `North` | `Walk around to the front of the house` |
| `Use key` | `See whether the brass key fits the blue door` |
| `Open locked door` | `Try the workshop door` |
| `Talk` | `Ask Grandfather why he is hiding` |
| `Examine` | `Look more closely at the muddy footprints` |
| `Continue` | `Follow the lantern light downstairs` |

### Commands

Commands should:

- Be accepted by the adventure's existing parser.
- Use vocabulary actually declared by the game.
- Prefer the shortest reliable form.
- Avoid relying on pronouns such as `it`.
- Avoid ambiguity when multiple objects share a noun.
- Work from every state in which their card is eligible.
- Produce a turn exactly as typed play would.

Commands are implementation details. A UI may omit them from production payloads
and submit only the stable ID.

## Proposed ZIL API

The following API is implemented in the Lua bootstrap and available to companion
ZIL modules.

### Choice kinds

```zil
<CONSTANT CHOICE-PROGRESS 1>
<CONSTANT CHOICE-INVESTIGATE 2>
<CONSTANT CHOICE-INTERACT 3>
<CONSTANT CHOICE-EXPERIMENT 4>
<CONSTANT CHOICE-RETURN 5>
<CONSTANT CHOICE-SAFETY 6>
```

Meanings:

- `CHOICE-PROGRESS`: likely advances a puzzle, objective, or story state.
- `CHOICE-INVESTIGATE`: reveals useful information or establishes knowledge.
- `CHOICE-INTERACT`: develops character, atmosphere, humor, or world response.
- `CHOICE-EXPERIMENT`: plausible action with uncertain or optional consequences.
- `CHOICE-RETURN`: revisits a previously discovered place or unfinished lead.
- `CHOICE-SAFETY`: responds to immediate danger or prevents an avoidable
  accessibility failure.

`PROGRESS` is not synonymous with “correct.” It describes the editorial purpose
of the card. The original game remains free to reject the command because of a
race, clock, or unusual state change.

### `CHOICE`

```zil
<CHOICE ID LABEL COMMAND KIND PRIORITY>
```

Example:

```zil
<CHOICE "west-house.open-mailbox"
        "Open the little mailbox"
        "open mailbox"
        ,CHOICE-INVESTIGATE
        80>
```

`CHOICE` emits a candidate into a temporary host-owned collection. It does not
print, move objects, modify flags, consume a turn, or immediately select the
card.

### `CHOICE-DETAILS`

Optional metadata can be attached to the most recently emitted card:

```zil
<CHOICE-DETAILS
    "tone" "curious"
    "subject" ,MAILBOX
    "once" T
    "learns" "mailbox.contains-leaflet">
```

An implementation may eventually prefer specialized helpers instead of a
key/value form. Unknown metadata should be ignored by older hosts rather than
making the game unloadable.

`learns` is applied only after the card is revalidated and selected. It must be
used only when executing the card's command necessarily communicates that fact.
Displaying the card does not apply it.

### `CHOICE-SEEN?`

```zil
<CHOICE-SEEN? ID>
```

Returns true if the card has been selected at least once.

```zil
<COND
  (<NOT <CHOICE-SEEN? "workshop.try-door">>
   <CHOICE "workshop.try-door"
           "Try the workshop door"
           "open workshop door"
           ,CHOICE-INVESTIGATE
           90>)>
```

Selection history is not the same as world state. A door can remain locked after
the player tries it, but the companion should now know that the obstacle has been
discovered.

### `CHOICE-SHOWN?` (planned)

```zil
<CHOICE-SHOWN? ID>
```

Returns true if the host has displayed the card before. Use this sparingly.
Merely showing a card should not normally teach the protagonist anything.

`CHOICE-SHOWN?` is most useful for reducing repetitive flavor cards, not for
unlocking puzzle information. This helper is not implemented in the current
runtime because queries intentionally remain side-effect free.

### `CHOICE-COUNT`

```zil
<CHOICE-COUNT ID>
```

Returns the number of times a card has been selected. It supports repeated
interactions and escalation:

```zil
<COND
  (<L? <CHOICE-COUNT "owl.ask-riddle"> 2>
   <CHOICE "owl.ask-riddle"
           "Ask the owl to repeat the riddle"
           "ask owl about riddle"
           ,CHOICE-INTERACT
           40>)>
```

### `KNOW` and `KNOWS?`

Some knowledge is broader than a single card. Implemented helpers:

```zil
<KNOW "workshop-door.locked">
<KNOWS? "workshop-door.locked">
```

Knowledge should normally be recorded when:

- The selected command's response necessarily reveals the fact.
- An original game global already establishes that the player learned it.
- A companion-specific selection handler explicitly records it.

Knowledge must not be recorded merely because a card was displayed.

Where the adventure already has an appropriate lore global, prefer that global
over duplicate companion knowledge.

### `SCENE`

```zil
<SCENE KEY ALT-TEXT>
```

Example:

```zil
<SCENE "workshop-yard.locked"
       "A moonlit workshop yard with a locked wooden door and a low window.">
```

`SCENE` selects a logical asset key. It does not embed image bytes or prescribe
how artwork is generated.

### Companion entry routines

```zil
<ROUTINE SUGGEST-ACTIONS ()
  <COND
    (<EQUAL? ,HERE ,WEST-OF-HOUSE>
     <SUGGEST-WEST-OF-HOUSE>)
    (<EQUAL? ,HERE ,WORKSHOP-YARD>
     <SUGGEST-WORKSHOP-YARD>)
    (T
     <SUGGEST-GENERIC>)>>

<ROUTINE SUGGEST-SCENE ()
  <COND
    (<EQUAL? ,HERE ,WORKSHOP-YARD>
     <COND
       (<FSET? ,WORKSHOP-DOOR ,OPENBIT>
        <SCENE "workshop-yard.open"
               "The workshop door stands open onto a warm, cluttered room.">)
       (T
        <SCENE "workshop-yard.locked"
               "A moonlit workshop yard with a closed wooden door.">)>)>>
```

Use room-specific helper routines rather than one enormous `COND`.

## Evaluation and selection lifecycle

The lifecycle has two separate operations: **query** and **select**.

### 1. The game reaches `READ`

The original adventure prints its current prose and waits for input. At this
point its coroutine is suspended.

### 2. The host queries choices

The host requests the current companion choices. The runtime:

1. Clears the temporary candidate collection.
2. Establishes read-only companion context.
3. Calls `SUGGEST-ACTIONS`.
4. Collects every emitted `CHOICE`.
5. Filters invalid and duplicate candidates.
6. Applies history penalties and deterministic ordering.
7. Returns every eligible card.
8. Leaves the game waiting at the same `READ`.

This operation must not count as a turn.

### 3. The player selects an ID

The client sends the stable card ID, not an arbitrary command.

### 4. The runtime revalidates the card

Before acting, the runtime evaluates the current candidates again. The selected
ID must still be eligible. This matters when:

- A UI displays cached cards.
- A clock or external host event changes state.
- Another control acts before the player taps.
- The player restores a different save.
- A multiplayer or shared-story host changes the active protagonist.

If the ID is stale, return a refresh response instead of executing its old
command.

### 5. The runtime records selection history

The card's selection count and associated knowledge effects are updated as part
of the accepted selection.

### 6. The command resumes the original game

The hidden parser command is passed to the suspended `READ`. From here onward,
the turn is indistinguishable from typed input.

### Purity rule

`SUGGEST-ACTIONS` and `SUGGEST-SCENE` are queries. They must not:

- call `RANDOM`;
- move objects;
- set or clear adventure flags;
- change globals;
- print story text;
- call action routines;
- invoke `PERFORM`;
- queue or dequeue interrupts;
- save or restore;
- advance counters;
- reveal containers by opening them;
- run code whose side effects depend on `M-LOOK`.

The `CHOICE` and `SCENE` primitives may mutate temporary host-side collection
state only. Repeated queries in the same game state must return equivalent
candidates.

## State, knowledge, and history

A high-quality companion distinguishes three kinds of state.

### World state

Facts objectively true in the simulation:

```zil
<FSET? ,WORKSHOP-DOOR ,OPENBIT>
<IN? ,LOCKPICK ,WINNER>
<EQUAL? ,HERE ,WORKSHOP-YARD>
,GRANDFATHER-AWAKE
```

World state belongs to the original adventure whenever possible.

### Player knowledge

Facts the protagonist or reader has learned:

```zil
<KNOWS? "workshop-door.locked">
<KNOWS? "grandfather.has-spare-key">
<KNOWS? "window.opens-from-outside">
```

The world may know that Grandfather has the key long before the player does. A
card must not say “Ask Grandfather for his spare key” until the player has a
reason to know or suspect that.

### Presentation history

Facts about the card UI:

```zil
<CHOICE-SHOWN? "yard.listen-at-window">
<CHOICE-SEEN? "yard.try-door">
<CHOICE-COUNT "owl.ask-riddle">
```

Presentation history helps vary repeated card sets, but should not become a
hidden second puzzle engine.

### Persistence

World state, companion knowledge, and selection counts must survive save and
restore.

The preferred implementation stores companion history in memory that participates
in the normal save snapshot or explicitly extends the save format. It must not
exist only in a transient UI process.

Required save behavior:

1. Save while a locked-door discovery card has been selected.
2. Make further progress.
3. Restore.
4. The companion returns to the earlier knowledge and card-history state.
5. Classic typed input and card input remain interchangeable after restore.

### Do not infer knowledge from truth alone

Incorrect:

```zil
<COND
  (,WORKSHOP-LOCKED
   <CHOICE "yard.find-key"
           "Search for the key to the locked workshop"
           "search yard"
           ,CHOICE-PROGRESS
           80>)>
```

If the player has not examined or tried the door, the label is a spoiler.

Better:

```zil
<COND
  (<AND ,WORKSHOP-LOCKED
        <NOT <KNOWS? "workshop-door.locked">>>
   <CHOICE "yard.try-door"
           "Try the workshop door"
           "open workshop door"
           ,CHOICE-INVESTIGATE
           90>)
  (<AND ,WORKSHOP-LOCKED
        <KNOWS? "workshop-door.locked">>
   <SUGGEST-WORKSHOP-SOLUTIONS>)>
```

## Ranking and diversity

The companion should emit all reasonable candidates. The host selects the final
three to five using predictable editorial rules.

### Base priority

Recommended ranges:

| Priority | Intended use |
|---:|---|
| 100–120 | Immediate safety or strongly productive action |
| 80–99 | Current puzzle progress or important discovery |
| 60–79 | Useful investigation or navigation |
| 40–59 | Character, atmosphere, optional object interaction |
| 20–39 | Playful experimentation and revisits |
| 1–19 | Rare fallback |

Priority is relative. It must not be used as a secret walkthrough step number.

### Selection pipeline

A recommended deterministic pipeline is:

1. Evaluate conditions.
2. Reject malformed candidates.
3. Deduplicate by ID.
4. Deduplicate identical commands unless explicitly allowed.
5. Apply repeat penalties.
6. Sort remaining candidates by adjusted priority and stable ID.
7. Return every eligible candidate.

Stable-ID tie-breaking prevents ordering from changing with Lua table iteration.

### Scene and movement groups

Every candidate belongs to one of two presentation groups:

- `scene`: inspect, take, use, solve, converse, wait, or experiment locally.
- `move`: an intention expected to change the current location.

The terminal UI labels these groups “In this scene” and “Go somewhere,” and
shows every eligible card in both groups.

Authored movement cards declare:

```zil
<CHOICE "garden.enter-workshop"
        "Step inside the workshop"
        "north"
        ,CHOICE-PROGRESS
        90>
<CHOICE-DETAILS "group" "move">
```

Automatic direct-exit fallbacks are assigned to `move`; all other candidates
default to `scene`.

### Category mix

Prefer a useful mix:

1. One or two progress cards.
2. One or two investigative cards.
3. Character, expressive, or playful cards where meaningful.
4. Useful movement and return cards.

These are defaults, not absolute laws. An urgent fire scene can legitimately
offer three safety responses. A quiet conversation scene can offer three
emotional approaches.

### Avoid the glowing-answer problem

Do not make one card obviously correct while the rest are decorative:

```text
Unlock the door with the exact correct key
Look at a pebble
Wait for no reason
```

A better set is:

```text
See whether the brass key fits
Ask Grandfather why the workshop is locked
Look through the low window
```

All three express plausible intentions. Only one may produce immediate mechanical
progress, but the others provide knowledge, character, or an alternate lead.

## Companion interface

Companion mode displays every eligible authored card, grouped into scene and
movement actions. It accepts a displayed number or a typed parser command.

Companion cards should:

- Use short, concrete verbs.
- Name relevant items explicitly once discovered.
- Avoid abstract compass navigation.
- Avoid irreversible failure without clear warning.
- Prefer kind, curious, brave, and playful alternatives.
- Ensure a player can make meaningful progress without constructing commands.

Example:

```text
Use the little key on the blue door
Ask the fox what is behind the door
Peek through the star-shaped keyhole
```

Companion mode also leaves typing available for a player who wants to attempt
something outside the list.

Cards can preserve inference:

```text
Examine the blue door
Ask the fox about the tower
Search the nursery again
Follow the cold draft downstairs
```

The companion profile does not necessarily “show the solution immediately.”
It promises controlled pacing:

- The current useful observation is offered.
- After the observation, a stronger lead becomes eligible.
- After one or two deliberate discoveries, an exact progress intention may
  appear.

This produces a hint ladder through play rather than a separate hint screen.

## Authoring patterns

### Organize by room, then by major state

```zil
<ROUTINE SUGGEST-ACTIONS ()
  <COND
    (<EQUAL? ,HERE ,WEST-OF-HOUSE>
     <SUGGEST-WEST-OF-HOUSE>)
    (<EQUAL? ,HERE ,WORKSHOP-YARD>
     <SUGGEST-WORKSHOP-YARD>)
    (<EQUAL? ,HERE ,WORKSHOP-INTERIOR>
     <SUGGEST-WORKSHOP-INTERIOR>)
    (T
     <SUGGEST-GENERIC>)>>
```

Within a room, group conditions by the obstacle the player currently perceives.

```zil
<ROUTINE SUGGEST-WORKSHOP-YARD ()
  <COND
    (<FSET? ,WORKSHOP-DOOR ,OPENBIT>
     <SUGGEST-OPEN-WORKSHOP>)
    (<KNOWS? "workshop-door.locked">
     <SUGGEST-LOCKED-WORKSHOP>)
    (T
     <SUGGEST-UNTRIED-WORKSHOP>)>>
```

### Keep conditions next to their wording

The label is part of the logic. Reviewing the condition and label together makes
spoilers visible.

### Prefer helpers for repeated facts

If “player can reach the workshop” has a complicated definition, use a routine:

```zil
<ROUTINE CAN-REACH-WORKSHOP? ()
  <AND ,BRIDGE-LOWERED
       <NOT ,FLOOD-ACTIVE>
       <NOT <IN? ,WINNER ,ROWBOAT>>>>
```

Then both adventure and companion tests can reason about the same fact.

### Use compact emitters for repeated metadata

Movement cards otherwise repeat a full `CHOICE` plus
`<CHOICE-DETAILS "group" "move">` at every call site. A helper keeps labels and
commands visible while centralizing invariant metadata:

```zil
<ROUTINE MOVE-CHOICE (ID LABEL COMMAND KIND PRIORITY)
  <CHOICE .ID .LABEL .COMMAND .KIND .PRIORITY>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-WORKSHOP-YARD ()
  <MOVE-CHOICE "yard.go-garden"
               "Follow the path into the garden"
               "north"
               ,CHOICE-RETURN
               40>>
```

Define helpers before routines that call them because the current compiler
cannot forward-reference generated local functions. Use a small number of
obvious helpers for truly invariant details; do not hide state conditions,
labels, commands, or priorities inside a data abstraction that reviewers cannot
read.

When the same choice appears across several mutually exclusive state branches,
prefer emitting it once outside the branch. If its priority or wording really
changes, reuse an ID only when it still represents the same player intention and
hidden command. A static audit should reject an ID whose meaning drifts.

### Avoid duplicating action semantics

Incorrect companion logic:

```zil
<COND
  (<IN? ,BRASS-KEY ,WINNER>
   ;"Assume the key always unlocks the door."
   <CHOICE ...>)>
```

If the original action also requires the lock to be oiled, use the same relevant
state in the condition or offer a tentative label:

```text
See whether the brass key fits
```

The parser command remains authoritative.

### Use tentative verbs honestly

Use:

- Try
- See whether
- Test
- Ask
- Look for
- Listen for

when success is not guaranteed.

Use direct success language:

- Unlock
- Enter
- Repair
- Rescue

only when the eligible state makes that outcome sufficiently reliable.

## Navigation as narrative intention

The world may still use `NORTH`, `SOUTH`, `EAST`, `WEST`, `UP`, `DOWN`, `IN`,
and `OUT`. The player-facing label should expose meaning.

```zil
<CHOICE "west-house.go-north-side"
        "Walk around the north side of the house"
        "north"
        ,CHOICE-PROGRESS
        70>
```

Other examples:

| Parser command | Intent label |
|---|---|
| `east` | `Enter the kitchen` |
| `up` | `Climb into the oak tree` |
| `down` | `Follow the lantern light into the cellar` |
| `south` | `Return to Grandfather's workshop` |
| `enter window` | `Climb through the open kitchen window` |
| `cross bridge` | `Cross the rope bridge toward the tower` |

### Destination correctness

Do not derive a destination label only from a static directional map when the
exit can:

- run a routine;
- redirect the player;
- be blocked;
- change destination;
- kill the player;
- depend on a vehicle;
- produce only a message.

For these exits, author the label against the current state.

```zil
<COND
  (,BRIDGE-LOWERED
   <CHOICE "ravine.cross-bridge"
           "Cross the bridge to the old tower"
           "north"
           ,CHOICE-PROGRESS
           80>)
  (T
   <CHOICE "ravine.examine-gap"
           "Look across the broken bridge"
           "examine bridge"
           ,CHOICE-INVESTIGATE
           70>)>
```

### Return cards

Returning should also use narrative memory:

```zil
<CHOICE "forest.return-workshop"
        "Return to Grandfather's workshop"
        "west"
        ,CHOICE-RETURN
        50>
```

If the route spans several parser moves, do not silently teleport. Either:

- offer the next meaningful leg;
- let the host animate an explicitly supported travel command; or
- add a game-level travel action whose risks and clocks are defined.

## Information and discovery actions

An action can be valuable even when it does not change the obstacle.

Initial state:

```text
Try the workshop door
Look through the low window
Knock and listen
```

After choosing “Try the workshop door,” the original game responds:

```text
The handle moves, but the door is locked.
```

The next card set can become:

```text
Search the yard for a key
Ask Grandfather about the locked workshop
Look for another way inside
```

The first selection did not advance the door state. It advanced player
knowledge. That is legitimate gameplay, not a consolation prize.

### Discovery ladders

A good ladder has several stages:

1. **Attention:** Look at the crooked painting.
2. **Direction:** Feel behind the loose frame.
3. **Action:** Move the painting aside.
4. **Exact solution:** Turn the hidden dial to the date from the letter.

Mode and history determine how quickly the ladder advances.

```zil
<COND
  (<NOT <KNOWS? "painting.loose">>
   <CHOICE "office.examine-painting"
           "Look closely at the crooked painting"
           "examine painting"
           ,CHOICE-INVESTIGATE
           80>)
  (<NOT <KNOWS? "safe.behind-painting">>
   <CHOICE "office.move-painting"
           "Move the painting away from the wall"
           "move painting"
           ,CHOICE-INVESTIGATE
           90>)
  (T
   <SUGGEST-SAFE-ACTIONS>)>
```

Do not skip directly from knowing nothing to naming a hidden safe.

## Inventory and puzzle actions

Inventory conditions are one of the strongest reasons to evaluate companions
inside the ZIL world.

```zil
<COND
  (<IN? ,LOCKPICK ,WINNER>
   <CHOICE "workshop.pick-lock"
           "Unlock the workshop with the lockpick"
           "unlock workshop door with lockpick"
           ,CHOICE-PROGRESS
           100>)
  (<IN? ,BRASS-KEY ,WINNER>
   <CHOICE "workshop.try-brass-key"
           "See whether the brass key fits"
           "unlock workshop door with brass key"
           ,CHOICE-PROGRESS
           90>)
  (T
   <CHOICE "workshop.seek-entry"
           "Look for another way into the workshop"
           "search workshop"
           ,CHOICE-INVESTIGATE
           70>)>
```

### Items inside containers

Check whether the parser command can actually reach the object. An item may be:

- in inventory;
- inside an open carried bag;
- inside a closed carried bag;
- on the ground;
- inside a closed room container;
- held by an NPC;
- present only as a global object.

Do not offer “Use the lockpick” because `LOC(LOCKPICK)` is nonzero. Use the
adventure's own reachability conventions or conservative conditions.

### Tool specificity

Prefer concrete companion labels:

```text
Cut the ribbon with the little scissors
```

Typed parser input remains available for players who want to infer the tool:

```text
Examine the ribbon
```

All three can lead to the same underlying command eventually. The difference is
how much inference the presentation performs for the player.

### Alternate solutions

If a puzzle has several solutions, preserve them:

```text
Pick the lock
Ask Mara to open the door
Climb through the window
```

The ranking system should not always erase optional ingenuity in favor of the
shortest walkthrough route.

## NPC, emotional, and expressive choices

The system becomes more than a puzzle menu when it includes meaningful social
intentions:

```text
Tell Mara the truth
Protect Grandfather's secret
Ask for more time
Change the subject to the missing key
```

These may map to parser commands:

```text
tell mara about workshop
ask grandfather about secret
ask inspector about time
ask mara about key
```

### Do not fabricate emotional affordances

Only offer a richly worded intention if the underlying command produces a
compatible response. “Comfort the frightened child” should not map to a generic
`talk to child` response that says “There is no reply.”

When imported adventures lack expressive handlers, labels should remain honest:

```text
Ask the child about the noise
```

rather than:

```text
Promise the child that everything will be all right
```

### Tone metadata

Tone can help the host avoid three emotionally identical choices:

```zil
<CHOICE-DETAILS "tone" "kind">
<CHOICE-DETAILS "tone" "cautious">
<CHOICE-DETAILS "tone" "mischievous">
```

Tone is editorial metadata, not morality scoring unless the original adventure
explicitly implements such a system.

## Danger, clocks, and changing state

Timed adventures need stricter rules.

### Querying never advances time

Opening, closing, or refreshing the card tray must not:

- increment `MOVES`;
- call the clocker;
- drain lamp power;
- move an NPC;
- select a random response;
- consume oxygen, food, warmth, or health.

### Urgent card sets

When danger is immediate, normal category diversity can be suspended:

```zil
<COND
  (,ROOM-ON-FIRE
   <CHOICE "laboratory.escape-window"
           "Climb out through the broken window"
           "enter window"
           ,CHOICE-SAFETY
           120>
   <CHOICE "laboratory.use-extinguisher"
           "Use the extinguisher on the flames"
           "spray fire with extinguisher"
           ,CHOICE-SAFETY
           115>
   <CHOICE "laboratory.warn-mara"
           "Shout a warning to Mara"
           "tell mara about fire"
           ,CHOICE-SAFETY
           110>)>
```

The companion should not conceal urgency merely to maintain one playful card.

### Stale choices

If the room changes between display and selection, the host must reject the old
ID and refresh. Never execute a cached hidden command solely because it came from
a previously valid payload.

## Scene illustrations

The companion can describe the logical scene while keeping artwork outside ZIL.
For the editorial workflow that selects dramatic beats, separates art style
from beat planning, and verifies text-image pairs, see
[Illustrating Adventures as Interactive Storybooks](ILLUSTRATING_ADVENTURES.md).

```zil
<ROUTINE SUGGEST-SCENE ()
  <COND
    (<EQUAL? ,HERE ,WORKSHOP-YARD>
     <COND
       (<FSET? ,WORKSHOP-DOOR ,OPENBIT>
        <SCENE "workshop-yard.door-open"
               "The workshop door is open, with warm lamplight spilling into the yard.">)
       (<KNOWS? "workshop-door.locked">
        <SCENE "workshop-yard.locked"
               "A locked workshop door beneath a low, moonlit window.">)
       (T
        <SCENE "workshop-yard.arrival"
               "A small wooden workshop at the edge of a moonlit garden.">)>)
    (<EQUAL? ,HERE ,WORKSHOP-INTERIOR>
     <SCENE "workshop.interior"
            "A warm workshop crowded with clocks, tools, and half-finished toys.">)>>
```

A separate manifest resolves keys:

```json
{
  "workshop-yard.arrival": {
    "asset": "images/workshop-yard-arrival.webp",
    "focus": "workshop-door",
    "palette": "moonlit-blue"
  },
  "workshop-yard.door-open": {
    "asset": "images/workshop-yard-open.webp",
    "focus": "open-door",
    "palette": "blue-and-warm-amber"
  }
}
```

### Scene-key granularity

Do not create a unique illustration for every inventory permutation. A new scene
key is justified when the visible composition materially changes:

- a door opens;
- a creature arrives;
- a room floods;
- a major object is removed;
- day becomes night;
- the protagonist enters a vehicle;
- a climactic transformation occurs.

Small state changes can remain in prose and cards.

### Accessibility

Every scene should provide alt text authored for the current state. Alt text
should describe visible information without leaking hidden puzzle facts.

## Host and UI contract

The runtime exposes `COMPANION_QUERY()` and `COMPANION_SELECT(id)` while the
game is waiting for input.
`main.lua` calls these functions directly. The JSON messages below define the
planned contract for graphical or remote hosts.

### Query request (planned transport)

Conceptual request:

```json
{
  "operation": "choices"
}
```

The existing coroutine control route could encode this as a special input such as
`choices`, but a typed host method is preferable once more clients exist.

### Query response

```json
{
  "stateToken": "opaque-state-token",
  "scene": {
    "key": "workshop-yard.locked",
    "alt": "A locked workshop door beneath a low, moonlit window."
  },
  "choices": [
    {
      "id": "workshop.pick-lock",
      "label": "Unlock the workshop with the lockpick",
      "kind": "progress",
      "group": "scene",
      "priority": 100,
      "tone": "clever"
    },
    {
      "id": "workshop.look-window",
      "label": "Look through the low window",
      "kind": "investigate",
      "priority": 75,
      "tone": "curious"
    },
    {
      "id": "workshop.knock",
      "label": "Knock and listen",
      "kind": "interact",
      "priority": 55,
      "tone": "cautious"
    }
  ]
}
```

Production clients do not need the hidden command. Debug tools may request it.

### Selection request (planned transport)

```json
{
  "operation": "selectChoice",
  "stateToken": "opaque-state-token",
  "id": "workshop.pick-lock"
}
```

The runtime currently performs the revalidation and selection steps in-process.
An opaque state token is planned for remote clients. The complete target flow is:

1. Confirms the token matches the waiting state.
2. Re-evaluates the companion.
3. Finds the same eligible ID.
4. Records selection.
5. Retrieves the server-side command.
6. Resumes the game with that command.

### Selection response

The normal turn response contains:

- story output;
- current room if available;
- score and move information if enabled;
- a new state token;
- optionally the next scene and card set.

### Errors

Recommended error codes:

| Code | Meaning |
|---|---|
| `stale_choice` | State changed; refresh choices |
| `unknown_choice` | ID was never emitted |
| `choice_no_longer_eligible` | ID existed but its condition is now false |
| `companion_unavailable` | Game has no companion module |
| `companion_error` | Evaluation failed |
| `game_not_waiting` | Query occurred outside `READ` |

The UI should recover from stale choices by refreshing, not by showing a fatal
error.

## Fallback suggestions

`zilscript/bootstrap.lua` already contains early introspection helpers that derive
room items, likely verbs, and exits. These can support games without authored
coverage, but they are not a substitute for a companion.

Fallbacks can safely suggest broad actions such as:

- Examine a visible object.
- Open an obviously openable object.
- Read a visible readable object.
- Take a visible takeable object.
- Visit a directly connected, plainly named room.

Fallbacks cannot reliably know:

- whether an action is narratively important;
- whether a destination name is a spoiler;
- whether a routine exit is currently safe;
- whether a puzzle solution should be revealed;
- what the protagonist has learned;
- which NPC topic matters;
- whether three technically valid actions form a satisfying set.

### Fallback policy

Recommended order:

1. Authored companion candidates.
2. Conservative generic navigation and visible-object candidates.
3. A universal `Look around` or `Review what I am carrying` card.
4. Typed input or an explicit help affordance.

Never advertise fallback coverage as equivalent to authored coverage.

## Agent-assisted authoring

An agent is valuable during development, not as an uncontrolled runtime oracle.

### Why not generate live

Live generation introduces:

- network and model latency;
- nondeterministic card sets;
- commands unsupported by the parser;
- accidental spoilers;
- inconsistent reading level;
- difficulty validating save/replay behavior;
- unpredictable cost;
- privacy and offline-play concerns;
- failures when a service is unavailable.

The shipped companion should be deterministic ZIL reviewed like any other game
content.

### Authoring workflow

An agent can draft a companion through five sources of evidence.

#### 1. Structural source inspection

Inspect:

- rooms and exits;
- object vocabulary and flags;
- action routines;
- puzzle globals;
- clocks and interrupts;
- NPC state routines;
- walkthroughs and regression tests.

This reveals possible states and commands that a single playthrough may miss.
The inspection must enumerate every declared room and classify it as reachable,
conditionally reachable, unreachable, terminal, or exempt. The classified count
must equal the source room count before generation can claim full coverage.

#### 2. Golden-path play

Play the official or known walkthrough and record:

- room before each action;
- visible output;
- inventory;
- important globals;
- command;
- resulting room and state;
- whether the action is progress, investigation, or transition.

This produces the first progress-card spine.

#### 3. Branch exploration

From saved checkpoints, test:

- with and without key items;
- before and after discoveries;
- open and closed containers;
- alternate puzzle solutions;
- NPCs present and absent;
- timed-event phases;
- failure and recovery states;
- revisits after partial progress.

#### 4. Draft generation

Generate:

- stable IDs;
- narrative labels;
- hidden commands;
- eligibility conditions;
- kinds and priorities;
- knowledge gates;
- state-aware variants;
- scene keys where useful.

#### 5. Validation and editorial review

Every emitted command must be executed from an isolated restore of a matching
saved state. A deterministic runner, rather than a model choosing opportunistically,
should enumerate all eligible cards and record their parser output and
postconditions. A human or independent review pass checks tone, spoilers,
variety, age level, and whether the options preserve meaningful agency.

Run a relatively weak model as a blind companion player after mechanical
validation. The visible card set makes it useful for detecting confusing labels,
loops, missing recovery actions, and accidental spoilers. Its successful route
is accessibility evidence, not completeness evidence: it cannot detect a state
or missing card that was never presented.

### State-coverage matrix

The authoring agent should maintain a matrix:

| Area | State | Inventory | Knowledge | Required card | Covered |
|---|---|---|---|---|---|
| Workshop yard | Door untried | None | None | Try door / investigate | Yes |
| Workshop yard | Door known locked | None | Locked | Find clue or alternate entry | Yes |
| Workshop yard | Door locked | Lockpick | Locked | Pick lock | Yes |
| Workshop yard | Door open | Any | Open | Enter workshop | Yes |
| Workshop | Grandfather present | Any | Secret unknown | Conversation | Yes |

“Played the game once” is not a sufficient coverage claim.

The authoritative coverage artifact should be machine-readable and store a
reproducible setup, required and forbidden IDs, expected parser result, and
status for every state family. `COVERAGE.md` is the human-readable report; it
must not be the only source used to calculate completeness.

### Agent output rules

An authoring agent should:

- cover every reachable room, including optional areas, mazes, return routes,
  hazards, and alternate endings;
- mark uncertain conditions with comments;
- never silently edit original puzzle logic to make a card work;
- use parser vocabulary confirmed by execution;
- record the state used to validate each command;
- avoid deriving hidden facts from source knowledge in player-facing wording;
- keep generated IDs stable across later prose polishing;
- submit companion source, the machine-readable coverage manifest, transcript
  evidence, and coverage tests together;
- never call fallback-only support complete for a reachable room.

## Validation and testing

Companion files need both mechanical and editorial tests.

### Compilation test

The companion parses, compiles, and loads after its target adventure.

### Purity test

Snapshot relevant state, query choices repeatedly, and assert:

- `HERE` is unchanged;
- object locations are unchanged;
- flags and globals are unchanged;
- move count is unchanged;
- random sequence is unchanged;
- clocks are unchanged;
- output is unchanged;
- candidates are deterministic.

### Eligibility tests

For each reachable state family:

1. Construct or restore the state.
2. Query candidates.
3. Assert required IDs are present.
4. Assert spoiler or impossible IDs are absent.

Illustrative pure-ZIL-style assertions:

```zil
<ASSERT "Lockpick card appears when carried"
        <TEST-CHOICE-PRESENT? "workshop.pick-lock">>

<ASSERT "Lockpick card is absent without lockpick"
        <NOT <TEST-CHOICE-PRESENT? "workshop.pick-lock">>>
```

The exact test helpers are part of the proposed implementation.

### Command execution tests

For every candidate:

1. Restore the state in which it is eligible.
2. Clone or restore an independent copy for that candidate.
3. Select the card through the public host path.
4. Assert the parser recognizes the command.
5. Assert it does not ask an unexpected disambiguation question.
6. Assert output is nonempty and appropriate.
7. Assert the declared postcondition.
8. Assert the resulting turn is identical to typing the hidden command.

### Full-room coverage tests

- Enumerate all source `<ROOM ...>` declarations.
- Require exactly one reachability classification for each declaration.
- Require one or more authored state families for every reachable room.
- Require every reachable state family to be `VALIDATED`.
- Fail release when a reachable room depends only on automatic fallback.
- Require a companion numeric-only route to reach an ending.
- Require route or checkpoint evidence for optional rooms, backtracking,
  alternate solutions, hazard recovery, deaths, and alternate endings.

### Diversity tests

For each critical state:

- IDs and commands are unique.
- A progress or discovery path exists where promised.
- The visible set is not filled with dead-end flavor.
- Urgent states favor safety.

### Knowledge tests

- Facts are not named before discovery.
- Selecting a discovery action unlocks the expected later cards.
- Merely displaying a card does not mark knowledge.
- Save and restore preserve knowledge.
- Rewinding restores earlier knowledge.

### Stale-selection tests

1. Query a card set.
2. Change or restore state before selection.
3. Submit the old ID and token.
4. Assert that no parser command runs.
5. Assert the host returns `stale_choice` or
   `choice_no_longer_eligible`.

### Scene tests

- Every emitted scene key exists in the asset manifest.
- Alt text is nonempty.
- Visible major state changes select the intended key.
- Alt text does not mention hidden objects or solutions.

### Editorial review

Mechanical validity is not enough. Review:

- Does each label describe what the command actually attempts?
- Are options meaningfully different?
- Is there a mixture of motivations?
- Is progression too obvious?
- Can the player discover obstacles naturally?
- Are humorous cards rewarding rather than fake?
- Is the reading level suitable?
- Are irreversible or frightening actions signaled appropriately?
- Does navigation name destinations clearly?
- Are NPC choices emotionally honest?

## Retrofitting existing adventures

Classic adventures such as Zork should be adapted in layers.

### Layer 1: Navigation and obvious objects

Cover:

- named movement;
- visible containers;
- readable objects;
- obvious takeable items;
- room-level examination.

This creates a usable exploration shell quickly.

### Layer 2: Discovery gates

Add:

- locked-door discovery;
- darkness and light understanding;
- container knowledge;
- NPC topic discovery;
- dangerous-state warnings;
- previously observed leads.

### Layer 3: Puzzle progress

Add state-aware cards for:

- tool use;
- item combinations;
- alternate solutions;
- puzzle sequences;
- recovery from partial progress.

### Layer 4: Narrative and expressive polish

Add:

- playful interactions;
- atmospheric investigation;
- character questions;
- meaningful returns;
- age-appropriate wording variants;
- scene illustration keys.

### Preserve imported source

Prefer:

```text
infocom/zork1/companion.zil
```

plus a loader entry over invasive changes to `dungeon.zil` or `actions.zil`.

Change original source only when:

- the parser lacks a necessary synonym;
- the original response contradicts the card;
- a genuine adventure bug prevents a valid intention;
- the companion reveals a discoverability defect that should also be fixed for
  typed play.

Such changes should be reviewed as independent game fixes, not hidden inside
companion work.

## Common mistakes

### Unclosed ROUTINE brackets swallowing subsequent routines

A missing `>` at the end of a `<ROUTINE>` silently leaves the routine open.
The parser consumes every subsequent `<ROUTINE>` as part of the unclosed one,
producing fewer parsed routines than written. The Lua environment then has `nil`
for the missing entry points (`SUGGEST_ACTIONS`, `SUGGEST_SCENE`), and
integration tests fail with `choice_no_longer_eligible`.

**Diagnosis:** run the parser on the companion file and compare the parsed
routine count to `grep -c "^<ROUTINE "`. If the counts differ, a bracket is
unclosed. A character-by-character `<`/`>` depth tracker (ignoring strings and
`;` comments) will find the exact position.

**Fix:** close every `<ROUTINE>` with a `>` before the next `<ROUTINE>`. A
typical pattern is `<CHOICE-DETAILS "group" "move">)>` — the `)` closes the
COND clause and the first `>` closes the COND; you still need a second `>` to
close the ROUTINE.

### ZIL hyphens become Lua underscores

The ZIL compiler translates hyphens to underscores in identifiers. A routine
named `SUGGEST-ACTIONS` in ZIL becomes `SUGGEST_ACTIONS` in Lua. The bootstrap
calls `SUGGEST_ACTIONS` (underscore) as the entry point. If the dispatcher
routine is named `SUGGEST-ACTIONS` in ZIL, the `require` will expose it as
`SUGGEST_ACTIONS` — but calling `SUGGEST-ACTIONS` from Lua will fail because
no global with that name exists.

**Fix:** when referencing ZIL routines from Lua or writing integration tests,
use the underscore form. When writing ZIL, use hyphens as normal. The compiler
handles the translation.

### Treating room truth as player knowledge

The companion names the hidden key or locked door before discovery.

**Fix:** gate labels on lore globals, selected discovery cards, or observed
events.

### Rewriting the game as branches

The companion tracks a second `CURRENT-PAGE` and duplicates outcomes.

**Fix:** use `HERE`, object state, and original globals; submit parser commands.

### Offering every valid verb

The card tray becomes a parser vocabulary dump.

**Fix:** curate intentions and let ranking enforce a small diverse set.

### Three versions of the same answer

```text
Unlock with key
Use key on door
Open door using key
```

**Fix:** deduplicate commands and fill other slots with investigation, character,
or alternate approaches.

### Labels that overpromise

“Open the vault” maps to a command that reports the vault is locked.

**Fix:** say “Try the vault door” until success is guaranteed.

### Compass directions in the UI

The child must reconstruct a map from `east` and `south`.

**Fix:** name destinations or narrative cues.

### Query side effects

Refreshing choices drains the lamp or advances an enemy.

**Fix:** enforce query purity and test repeated evaluation.

### Live agent dependency

The game needs a model call after every turn.

**Fix:** use agents to author and test deterministic companion source offline.

### Assuming one walkthrough is coverage

Cards fail when the player lacks an item or solves a puzzle in another order.

**Fix:** build a state matrix and restore branch checkpoints.

### Hiding impossible commands behind attractive prose

The label sounds excellent but the parser does not recognize the vocabulary.

**Fix:** execute every hidden command from every eligible state.

### Using presentation history as core puzzle state

Progress depends on whether the UI happened to display a card.

**Fix:** base progress on the adventure and use selection/knowledge history only
for facts genuinely learned through the card path.

## Implementation status and next phases

| Phase | Status |
|---|---|
| Runtime primitives and deterministic query API | Implemented |
| Selection revalidation, counts, knowledge, save/restore | Implemented |
| Default `--companion` interface and `--text` mode | Implemented |
| Zork I full authored coverage (110/110 declared rooms) | Implemented |
| Full Zork I companion coverage | In progress |
| `llm.lua` companion authoring commands | Not started |
| Machine-readable coverage manifest and exhaustive card runner | Manifest implemented; card runner not started |
| Illustrated graphical client | Not started |

### Phase 1: Runtime primitive and debug API

Implemented:

- temporary candidate collection;
- `CHOICE`;
- `SUGGEST-ACTIONS` lookup;
- deterministic ranking;
- a `choices` control query at `READ`;
- unit tests for purity and stable ordering.

No graphical UI is required yet.

### Phase 2: Selection and persistence

Implemented:

- selection by ID;
- revalidation;
- selection counts;
- companion knowledge;
- save/restore support;
- `choice_no_longer_eligible` errors.

Stable remote state tokens and `stale_choice` transport errors remain planned.

### Phase 3: Zork I full coverage

The current `infocom/zork1/companion.zil` covers:

- 110 authored cards;
- explicit routing for all 110 declared rooms;
- the opening house sequence, all underground puzzle regions, forest paths,
  mines, rivers, and the barrow;
- state-aware inventory and object conditions throughout;
- child, story, and casual presentation through the shared candidate profile.

A machine-readable `companion/COVERAGE.json` and human-readable
`companion/COVERAGE.md` ship with the adventure. The integration regression
tests the opening route to the Cellar. Full-game completion testing and
state-family manifest generation for every reachable room remain future work.

### Phase 4: CLI and agent tooling

Extend `llm.lua` with conceptual operations:

```bash
lua5.4 llm.lua --new-game --save /tmp/zork1.sav
lua5.4 llm.lua --choices --save /tmp/zork1.sav
lua5.4 llm.lua --choose west-house.open-mailbox --save /tmp/zork1.sav
```

Add:

- candidate dumps;
- machine-readable state-family setups and expectations;
- state-coverage reports;
- isolated-checkpoint execution of every hidden command;
- companion purity checks;
- declared-versus-classified and missing-room reports;
- companion numeric-only completion runners;
- structured failure records for fixing agents.

### Phase 5: Illustrated client

Build the page layout:

1. Scene illustration.
2. One or two short story paragraphs.
3. Three large action cards for children.
4. Optional inventory, map, transcript, and accessibility controls.

### Phase 6: Broader migration

Complete and validate every reachable Zork I room, then use the stabilized
authoring and validation process for Zork II, Zork III, and newer books.

## Complete example

The following is a cohesive example of a `companion.zil`. The companion
primitives are implemented, but the fictional rooms, objects, and parser
vocabulary in this example must be supplied by its adventure.

```zil
;"Companion intent cards for The Clockmaker's Garden."

<CONSTANT CHOICE-PROGRESS 1>
<CONSTANT CHOICE-INVESTIGATE 2>
<CONSTANT CHOICE-INTERACT 3>
<CONSTANT CHOICE-EXPERIMENT 4>
<CONSTANT CHOICE-RETURN 5>
<CONSTANT CHOICE-SAFETY 6>

<ROUTINE SUGGEST-ACTIONS ()
  <COND
    (<EQUAL? ,HERE ,GARDEN-PATH>
     <SUGGEST-GARDEN-PATH>)
    (<EQUAL? ,HERE ,WORKSHOP-YARD>
     <SUGGEST-WORKSHOP-YARD>)
    (<EQUAL? ,HERE ,WORKSHOP-INTERIOR>
     <SUGGEST-WORKSHOP-INTERIOR>)
    (T
     <SUGGEST-GENERIC>)>>

<ROUTINE SUGGEST-GARDEN-PATH ()
  <CHOICE "garden.follow-footprints"
          "Follow the muddy footprints toward the workshop"
          "north"
          ,CHOICE-PROGRESS
          80>
  <CHOICE-DETAILS "group" "move">

  <COND
    (<NOT <CHOICE-SEEN? "garden.examine-clockbird">>
     <CHOICE "garden.examine-clockbird"
             "Look at the clockwork bird in the hedge"
             "examine clockwork bird"
             ,CHOICE-INVESTIGATE
             65>
     <CHOICE-DETAILS "tone" "curious" "once" T>)>

  <CHOICE "garden.return-house"
          "Return to the warm kitchen"
          "south"
          ,CHOICE-RETURN
          40>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-WORKSHOP-YARD ()
  <COND
    (<FSET? ,WORKSHOP-DOOR ,OPENBIT>
     <SUGGEST-WORKSHOP-OPEN>)
    (<KNOWS? "workshop-door.locked">
     <SUGGEST-WORKSHOP-LOCKED>)
    (T
     <SUGGEST-WORKSHOP-UNTRIED>)>>

<ROUTINE SUGGEST-WORKSHOP-UNTRIED ()
  <CHOICE "workshop.try-door"
          "Try the workshop door"
          "open workshop door"
          ,CHOICE-INVESTIGATE
          95>
  <CHOICE-DETAILS "learns" "workshop-door.locked">

  <CHOICE "workshop.look-window"
          "Look through the low window"
          "examine workshop window"
          ,CHOICE-INVESTIGATE
          75>
  <CHOICE-DETAILS "learns" "window.opens-from-outside">

  <CHOICE "workshop.knock"
          "Knock and listen"
          "knock on workshop door"
          ,CHOICE-INTERACT
          60>>

<ROUTINE SUGGEST-WORKSHOP-LOCKED ()
  <COND
    (<IN? ,LOCKPICK ,WINNER>
     <CHOICE "workshop.pick-lock"
             "Unlock the workshop with the lockpick"
             "unlock workshop door with lockpick"
             ,CHOICE-PROGRESS
             110>
     <CHOICE-DETAILS "tone" "clever">)

    (<IN? ,BRASS-KEY ,WINNER>
     <CHOICE "workshop.try-brass-key"
             "See whether the brass key fits"
             "unlock workshop door with brass key"
             ,CHOICE-PROGRESS
             100>)>

  <COND
    (<AND <KNOWS? "window.opens-from-outside">
          <NOT <FSET? ,WORKSHOP-WINDOW ,OPENBIT>>>
     <CHOICE "workshop.open-window"
             "Open the low workshop window"
             "open workshop window"
             ,CHOICE-PROGRESS
             90>)
    (<NOT <KNOWS? "window.opens-from-outside">>
     <CHOICE "workshop.examine-window"
             "Examine the low window more closely"
             "examine workshop window"
             ,CHOICE-INVESTIGATE
             75>)>

  <CHOICE "workshop.search-entry"
          "Search the yard for another way inside"
          "search yard"
          ,CHOICE-INVESTIGATE
          60>

  <CHOICE "workshop.return-garden"
          "Return to the garden path"
          "south"
          ,CHOICE-RETURN
          35>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-WORKSHOP-OPEN ()
  <CHOICE "workshop.enter"
          "Step inside the workshop"
          "north"
          ,CHOICE-PROGRESS
          110>
  <CHOICE-DETAILS "group" "move">

  <COND
    (<NOT <CHOICE-SEEN? "workshop.listen-before-entering">>
     <CHOICE "workshop.listen-before-entering"
             "Pause and listen before going inside"
             "listen"
             ,CHOICE-INTERACT
             50>)>

  <CHOICE "workshop.return-garden"
          "Return to the garden path"
          "south"
          ,CHOICE-RETURN
          35>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-WORKSHOP-INTERIOR ()
  <COND
    (,WORKSHOP-ON-FIRE
     <SUGGEST-WORKSHOP-FIRE>)
    (,GRANDFATHER-PRESENT
     <SUGGEST-GRANDFATHER>)
    (T
     <SUGGEST-EMPTY-WORKSHOP>)>>

<ROUTINE SUGGEST-GRANDFATHER ()
  <COND
    (<NOT <KNOWS? "grandfather.hiding-something">>
     <CHOICE "grandfather.ask-arrival"
             "Ask Grandfather why he called you here"
             "ask grandfather about letter"
             ,CHOICE-INTERACT
             90>
     <CHOICE-DETAILS "learns" "grandfather.hiding-something">)
    (T
     <CHOICE "grandfather.ask-secret"
             "Ask what Grandfather is hiding"
             "ask grandfather about secret"
             ,CHOICE-PROGRESS
             95>)>

  <CHOICE "workshop.examine-machine"
          "Look at the unfinished machine"
          "examine unfinished machine"
          ,CHOICE-INVESTIGATE
          75>

  <COND
    (<IN? ,BROKEN-CLOCKBIRD ,WINNER>
     <CHOICE "grandfather.show-clockbird"
             "Show Grandfather the broken clockwork bird"
             "show clockwork bird to grandfather"
             ,CHOICE-INTERACT
             85>)>>

<ROUTINE SUGGEST-EMPTY-WORKSHOP ()
  <CHOICE "workshop.examine-machine"
          "Look at the unfinished machine"
          "examine unfinished machine"
          ,CHOICE-INVESTIGATE
          85>

  <CHOICE "workshop.search-bench"
          "Search the crowded workbench"
          "search workbench"
          ,CHOICE-INVESTIGATE
          70>

  <CHOICE "workshop.return-yard"
          "Step back into the yard"
          "south"
          ,CHOICE-RETURN
          45>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-WORKSHOP-FIRE ()
  <COND
    (<IN? ,EXTINGUISHER ,WINNER>
     <CHOICE "workshop.extinguish-fire"
             "Use the extinguisher on the flames"
             "spray flames with extinguisher"
             ,CHOICE-SAFETY
             120>)>

  <CHOICE "workshop.warn-grandfather"
          "Shout a warning to Grandfather"
          "tell grandfather about fire"
          ,CHOICE-SAFETY
          115>

  <CHOICE "workshop.escape"
          "Run back into the yard"
          "south"
          ,CHOICE-SAFETY
          110>
  <CHOICE-DETAILS "group" "move">>

<ROUTINE SUGGEST-GENERIC ()
  <CHOICE "generic.look"
          "Look around"
          "look"
          ,CHOICE-INVESTIGATE
          20>

  <CHOICE "generic.inventory"
          "Remember what you are carrying"
          "inventory"
          ,CHOICE-INVESTIGATE
          15>>

<ROUTINE SUGGEST-SCENE ()
  <COND
    (<EQUAL? ,HERE ,GARDEN-PATH>
     <SCENE "garden-path.moonlit"
            "A moonlit garden path crossed by muddy footprints.">)

    (<EQUAL? ,HERE ,WORKSHOP-YARD>
     <COND
       (<FSET? ,WORKSHOP-DOOR ,OPENBIT>
        <SCENE "workshop-yard.open"
               "Warm light spills from the open workshop into the moonlit yard.">)
       (<KNOWS? "workshop-door.locked">
        <SCENE "workshop-yard.locked"
               "The workshop's locked wooden door stands beneath a low window.">)
       (T
        <SCENE "workshop-yard.arrival"
               "A small wooden workshop waits at the edge of the garden.">)>)

    (<EQUAL? ,HERE ,WORKSHOP-INTERIOR>
     <COND
       (,WORKSHOP-ON-FIRE
        <SCENE "workshop.fire"
               "Flames climb the workshop curtains as smoke fills the room.">)
       (,GRANDFATHER-PRESENT
        <SCENE "workshop.grandfather"
               "Grandfather stands among clocks and tools beside an unfinished machine.">)
       (T
        <SCENE "workshop.empty"
               "An empty workshop crowded with clocks, tools, and unfinished toys.">)>)>>
```

### What the example demonstrates

- Navigation labels name destinations.
- The locked door is not named as locked until discovered.
- Inventory changes the available solution.
- Companion choices can provide a more concrete search target.
- Selection history suppresses one-time flavor.
- A dangerous state replaces the normal diverse set with urgent choices.
- Scene keys change only for visually important state.
- Original parser commands still perform every action.

## Reference checklist

Before declaring a companion adventure complete, verify:

### Architecture

- [ ] Companion source loads after everything it references.
- [ ] The original game remains authoritative.
- [ ] Queries occur only while waiting at `READ`.
- [ ] Query evaluation is deterministic and side-effect free.
- [ ] Selection revalidates the stable ID.
- [ ] Companion history participates in save and restore.

### Every card

- [ ] ID is unique and stable.
- [ ] Label is narrative, concise, and honest.
- [ ] Hidden command is accepted by the parser.
- [ ] Command works in every eligible state.
- [ ] Kind reflects editorial purpose.
- [ ] Group is `scene`, or `move` when the intention changes location.
- [ ] Priority is reasonable relative to nearby cards.
- [ ] Label does not reveal unknown information.
- [ ] Navigation names a destination when possible.
- [ ] Card is not a duplicate of another visible intention.

### Every important state

- [ ] Companion mode exposes every eligible card and accepts typed input.
- [ ] Scene and movement cards appear under separate headings.
- [ ] Companion choices provide a path to progress.
- [ ] Investigation and character are not crowded out by walkthrough actions.
- [ ] Immediate hazards receive appropriate priority.
- [ ] Alternate solutions remain visible when desirable.
- [ ] Return navigation is understandable.
- [ ] No card depends accidentally on UI display history.
- [ ] Repeated queries do not advance time or change randomness.

### Agent-generated coverage

- [ ] Every declared room is classified exactly once.
- [ ] Every reachable room has authored cards and validated state families.
- [ ] No reachable room depends only on fallback suggestions.
- [ ] Golden path was played.
- [ ] Inventory branches were restored and tested.
- [ ] Discovery-before/after states were tested.
- [ ] Timed and NPC states were tested.
- [ ] Optional rooms, mazes, return routes, hazards, deaths, and alternate
      endings were tested.
- [ ] Every hidden command was executed from an isolated matching-state restore.
- [ ] A companion numeric-only route reached an ending.
- [ ] A weak-model blind route checked clarity, loops, and recovery without
      receiving source or hidden commands.
- [ ] Machine-readable coverage data and synchronized `COVERAGE.md` are stored
      with the adventure.
- [ ] Human editorial review checked spoilers, tone, and reading level.

### Illustration layer

- [ ] Every scene key resolves to an asset.
- [ ] Alt text exists.
- [ ] Alt text describes only visible knowledge.
- [ ] Major visible state changes use appropriate scenes.
- [ ] Minor permutations do not create unnecessary asset explosion.

## Summary

A companion ZIL file transforms parser-level possibilities into a small set of
state-aware narrative intentions. It does not flatten the adventure into static
branches. It allows the same simulated world to support:

- classic typed play;
- casual card-based play;
- child-friendly illustrated-book play;
- adaptive story pacing;
- agent-assisted content authoring;
- deterministic offline execution.

The decisive design rule is:

> **The companion chooses what is worth presenting; the original game decides
> what actually happens.**
