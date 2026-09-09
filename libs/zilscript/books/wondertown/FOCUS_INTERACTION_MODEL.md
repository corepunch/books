# Wondertown Focus Interaction Model

## Purpose

Focus is primarily an **interaction-design mechanic**, not an illustration
mechanic. Wondertown should preserve its underlying ZIL world model while
narrowing the active interaction context to the subject the reader has chosen.
Both the text-only and illustrated products use the same focus state, Companion
logic, action generation, and underlying commands.

The reader does not need to see every parser action available in a room at
once. Instead, each interaction state frames one narrative subject and offers
a short set of choices relevant to that subject.

The central rule is:

> Focus narrows the action space. Presentation decides how that focus is shown.

The illustrated version makes a focus change visually obvious through framing
and cinematography. The text-only version performs exactly the same narrative
zoom through prose. Neither version should feel like a parser transcript or a
stack of software screens.

## Shared Product Architecture

Focus belongs between the authoritative ZIL world and both product renderers:

```text
                 WORLD MODEL / ZIL
                        |
                  current state
                        |
                COMPANION / FOCUS
                        |
              +---------+---------+
              |                   |
         TEXT BOOK         ILLUSTRATED BOOK
              |                   |
       narrative text       narrative + image
       3-5 actions          the same 3-5 actions
```

Companion should not independently solve the large room-level action-selection
problem for each product. It receives the same hierarchical context and emits
the same small, state-aware action set. Only rendering differs.

## Core Model

Keep physical location and page focus separate.

### World Location

The room where Pip physically exists in the ZIL world. This remains the normal
`HERE` value and continues to govern exits, object containment, NPC location,
inventory, timers, and puzzle logic.

Examples:

- `WORKSHOP-FLOOR`
- `COUNTERTOP`
- `MAILBOX-CORNER`
- `FOX-DEN`
- `TOLLIVER-STUDY`

### Narrative Focus

The object, character, document, puzzle, or detail currently occupying the
interaction context. Focus determines the prose and choices shown to the
reader, plus the image in the illustrated product. Entering a focus does not
move Pip into a new ZIL room.

Examples:

- the empty key hook
- Bertrand and his winding key
- the open display case
- Marzipan's missing eye
- the mailbox and its letters
- Nutmeg during a conversation
- Tolliver's journal
- the workshop heart

### Focus State

The current state of the focused subject. A single focus may have several
states, each with different prose and local choices and, where applicable,
different illustrations.

```text
World Location: MAILBOX-CORNER
Narrative Focus: MAILBOX
Focus State: OPEN_WITH_LETTERS
```

The minimum shared interaction state is therefore:

```text
WORLD_LOCATION
FOCUS_PATH
FOCUS_STATE
NARRATIVE_TEXT
LOCAL_CHOICES
```

An illustrated renderer additionally chooses an illustration or shot for that
state. `NARRATIVE_FOCUS` is interaction context, not physical containment. Do
not implement it by assigning an object such as the mailbox, desk, or clock to
`HERE`.

### Focus Path and Subfocus

Focus may narrow through a short hierarchy:

```text
LOCATION
West of House
    -> FOCUS
       Mailbox
           -> STATE
              Mailbox Open
                  -> SUBFOCUS
                     Leaflet
```

At every level, Companion receives a small and sensible action space. Keep the
hierarchy shallow enough that leaving focus remains understandable.

## Why Focus Works

Classic parser play keeps a room almost completely available after every
action. After opening a container, the player can still type movement commands,
inspect unrelated scenery, speak to a character, or manipulate any other
reachable object. That breadth is appropriate for a text parser, but it creates
noisy choice lists in either button-driven product.

Narrative focus applies progressive disclosure:

1. The location-level context offers three to five meaningful subjects.
2. Selecting a subject establishes a narrower focus.
3. The focused context offers three to five actions concerning that subject.
4. An action may deepen the focus, change its state, resolve it, or return to
   the wider scene.

The reader sees fewer choices at once, but the underlying world remains rich.
The narrowing feels natural because the reader has already chosen what to pay
attention to.

## Companion Action Generation

Without focus, Companion must answer a difficult and unstable question:

> Out of everything theoretically possible in this room, what are the four
> best commands?

With focus, Companion receives a hierarchy:

```text
LOCATION -> FOCUS -> STATE -> optional SUBFOCUS
```

Each level provides a bounded set of relevant nouns, intentions, and commands.
The resulting choices become easier to author, generate, validate, and explain.

### Text-Only Mailbox Example

At room level, the text product might begin with:

```text
You are standing west of the house. A small mailbox leans beside the path.

Actions:
- Open the mailbox
- Examine the window
- Try the front door
- Go around the house
```

After `Open the mailbox`, `HERE` remains `WEST-OF-HOUSE`, but focus becomes the
open mailbox:

```text
You pull open the little mailbox. Its hinges squeal. Inside is a folded
leaflet, yellowed around the edges.

Actions:
- Take the leaflet
- Read it without removing it
- Look behind it
- Close the mailbox
```

After taking the leaflet, the world and interaction state advance:

```text
You take the leaflet. There is nothing else inside except a rusty screw and a
dark stain in the back corner.

Actions:
- Read the leaflet
- Examine the stain
- Put the leaflet back
- Step away from the mailbox
```

`Step away from the mailbox` returns Companion to the room-level context:

```text
- Go around the house
- Examine the window
- Try the front door
- Look at the mailbox again
```

No illustration is required for this mechanic to work. The prose makes the
same narrowing and widening of attention clear.

## Narrative Zoom and Shot Grammar

Both products use the same narrative zoom:

```text
room -> desk -> drawer -> photograph
```

The text product expresses it through increasingly specific prose. The
illustrated product may additionally interpret it as cinematography:

```text
establishing shot
    -> focused close-up
    -> action or insert shot
    -> changed close-up
    -> changed establishing shot
```

For example:

```text
Mailbox Corner
    -> closed mailbox
    -> Pip opens the door
    -> open mailbox with letters
    -> close-up of Tolliver's envelope
    -> Mailbox Corner after the letter is taken
```

The return to a location-level context is important. In text, changed prose
confirms that the mailbox remains open or the envelope is gone. In the
illustrated product, the changed establishing image provides the same
confirmation visually. Both renderers communicate persistent world state
without reproducing a parser transcript.

## Entering and Leaving Focus

Entering focus should feel like directing attention to a more specific subject,
not opening a modal interface.

Good transition language:

- Approach the workbench
- Look inside the display case
- Kneel beside Nutmeg
- Open Tolliver's journal
- Examine the clock face
- Step closer to the workshop heart

Good exit language:

- Step away from the workbench
- Close the journal
- Return to the room
- Leave Nutmeg some space
- Climb down to the workshop floor

Avoid generic interface labels such as `Back`, `Close panel`, or `Exit mode`
when an in-world phrase is available. A completed action may return to the
establishing page automatically when that creates a stronger narrative beat.

## Local Choice Rules

Each interaction state should normally show three to five choices.

Choices should:

- describe an intention in plain language;
- act on something visible or clearly mentioned on the page;
- differ meaningfully in information, tone, risk, or outcome;
- include a natural way to leave when the focus is not self-resolving;
- reflect current world and focus state;
- avoid revealing objects or knowledge Pip has not discovered;
- disappear or change wording after they are exhausted.

While focused, hide unrelated room navigation and remote object actions. The
reader examining Marzipan's missing eye does not also need choices for leaving
the workshop, climbing the workbench, or opening the display case.

Do not expose every parser verb. `KICK MAILBOX`, `PUSH MAILBOX`, and similar
generic actions only deserve a choice when they contribute character, comedy,
information, or state change.

## Focus Types

The same model supports several kinds of interaction in both products.

### Object Focus

Used for containers, tools, mechanisms, props, and environmental details.

```text
Focus: DISPLAY-CASE
State: CLOSED
Choices:
- Open the glass case
- Wipe dust from the lid
- Look at the toys inside
- Step away
```

### Character Focus

Used for conversation, trust, emotional choices, and giving or showing items.

```text
Focus: NUTMEG
State: WARY
Choices:
- Ask why she took the key
- Offer the red scarf
- Tell her about Tolliver
- Give her some space
```

Character focus should use pose, eye line, personal distance, and expression to
make relationship state visible.

### Document Focus

Used for letters, journals, diagrams, labels, and inscriptions.

```text
Focus: TOLLIVER-LETTER
State: FRONT
Choices:
- Read the letter
- Study the handwriting
- Turn it over
- Put it away
```

### Puzzle Focus

Used when a mechanism or arrangement has several local operations.

```text
Focus: WORKSHOP-HEART
State: KEY_INSERTED
Choices:
- Turn the workshop key
- Place the music box beside the heart
- Ask a companion to come closer
- Step back from the mechanism
```

### Detail Focus

Used for a clue within another focused page. Detail focus should be shallow and
purposeful: an unusual seam, a hidden latch, a signature, or a symbol. It should
not create long chains of nested navigation.

## Wondertown Example Sequences

### Workshop and Key Hook

```text
WORKSHOP-FLOOR / no focus
Illustration: wide establishing view of the workshop
Choices:
- Examine the empty key hook
- Approach the workbench
- Follow the moonlight to the pet door

WORKSHOP-FLOOR / KEY-HOOK / EMPTY
Illustration: Pip beside the empty hook and frayed string
Choices:
- Examine the broken string
- Listen for the key's ticking
- Search the floor below
- Step back into the workshop
```

### Bertrand

```text
TOOL-BENCH / BERTRAND / FROZEN
Illustration: Bertrand frozen mid-stride, key visible in his back
Choices:
- Examine the brass winding key
- Wind Bertrand
- Address him as "Captain"
- Step away

TOOL-BENCH / BERTRAND / WOUND_AND_POLITE
Illustration: Bertrand saluting, the route beyond him now clear
Choices:
- Ask about Tolliver
- Ask about the missing workshop key
- Request permission to pass
- Return to the tool bench
```

### Mailbox

```text
MAILBOX-CORNER / MAILBOX / CLOSED
    -> open it
MAILBOX-CORNER / MAILBOX / OPEN_WITH_LETTERS
    -> inspect Tolliver's envelope
MAILBOX-CORNER / TOLLIVER-LETTER / UNREAD
    -> read it
MAILBOX-CORNER / TOLLIVER-LETTER / READ
    -> put it away
MAILBOX-CORNER / no focus / LETTER_TAKEN
```

The final establishing illustration should retain the open mailbox and show
that the important envelope is no longer inside.

### Marzipan

```text
COUNTERTOP / MARZIPAN / ONE_EYE
Choices:
- Listen to her song
- Ask about the fox
- Offer the spare button
- Return to the countertop

COUNTERTOP / MARZIPAN / TWO_EYES
Illustration: the new mismatched eye and a warmer expression
Choices:
- Hear the secret song
- Ask about the hidden latch
- Thank her
- Return to the countertop
```

### Nutmeg

Nutmeg's focus pages should make trust changes visually obvious. The den remains
the same world location while composition and distance change:

```text
FOX-DEN / NUTMEG / DEFENSIVE
FOX-DEN / NUTMEG / LISTENING
FOX-DEN / NUTMEG / SOFTENING
FOX-DEN / NUTMEG / TRUSTING
FOX-DEN / NUTMEG / BETRAYED
```

Do not reduce these states to a dialogue menu over a static portrait. Her ears,
tail, shoulders, proximity to Pip, grip on the key, and use of the scarf should
carry the emotional state.

## State and Persistence

The focused presentation must derive from authoritative game state. It must not
create a second, contradictory version of the world.

Examples:

- `MARZIPAN-BUTTON` selects the one-eye or two-eye illustration.
- `BERTRAND-WOUND` selects frozen or active Bertrand.
- `LETTER-READ` changes document choices and later dialogue.
- `CART-MOVED` changes the scrap-yard establishing shot.
- `NUTMEG-TRUST` selects composition, expression, and available responses.
- `KEY-FOUND` removes the key from Nutmeg and changes the workshop's urgency.
- `STUDY-ACCESS` reveals the route behind Old Tick.

When the reader leaves and later re-enters a focus, show the current state, not
the first image in the sequence.

## Relationship to ZIL Commands

The visible choices are authored presentations of valid game intentions. They
may map to hidden parser commands, direct action routines, or a higher-level
choice dispatcher, but the visible wording should be natural prose rather than
parser syntax.

```text
Visible choice: Offer Nutmeg the warm scarf
Possible command: GIVE SCARF TO NUTMEG

Visible choice: Wind the frozen captain
Possible command: WIND BERTRAND
```

Focus narrows what the interface offers; it does not remove the underlying
object model or invalidate normal ZIL state transitions.

### Focus Supplies Implicit Objects

The interface should remember what the interaction is about. Instead of making
the reader repeatedly specify complete parser-style noun phrases:

```text
OPEN MAILBOX
LOOK IN MAILBOX
TAKE LEAFLET FROM MAILBOX
READ LEAFLET
```

the focus hierarchy carries the implicit object:

```text
Open the mailbox
    -> Take the leaflet
        -> Read it
```

This mirrors normal conversation. After opening a drawer, a person says
`Look at the photograph`, not `Examine the photograph inside the drawer of the
desk`. After focusing the photograph, `Turn it over` is sufficient. Companion
uses the current focus path to resolve these shorter intentions into complete,
validated game commands.

## Illustration Inventory Consequences

Illustrations should be planned by meaningful focus state, not by room alone.
Before generating art for a location, inventory:

1. its establishing states;
2. each important focus;
3. visible state families for that focus;
4. transition beats worth illustrating;
5. changed establishing shots required after resolution;
6. expression or pose variants driven by trust and story state.

Not every command needs new art. Reuse an image when the composition, visible
state, and emotional beat are genuinely unchanged. Create a new image when the
reader must perceive a changed object, clue, relationship, route, or consequence.

## Non-Goals

Wondertown is not trying to become:

- a free-roaming character-control game;
- a pixel-hunt interface;
- an FMV game with mandatory UI navigation;
- a literal visualization of every parser transcript line;
- a room screen containing every possible action at once;
- a deeply nested stack of object screens;
- an illustration-only interaction system with separate text-product logic.

The desired experience remains a book: read a page, notice what matters, make
a choice, and turn to the next meaningful image.

## Authoring Checklist

For every focused interaction state, confirm:

- [ ] World location remains correct.
- [ ] Narrative focus is explicit.
- [ ] Focus state comes from authoritative game state.
- [ ] Prose clearly communicates the focus and state without requiring art.
- [ ] When present, the illustration communicates the same focus and state.
- [ ] The page offers three to five relevant choices.
- [ ] Unrelated room actions are hidden while focused.
- [ ] There is an in-world exit or an intentional automatic return.
- [ ] Choice wording expresses intention rather than parser syntax.
- [ ] Returning to the location-level context shows persistent consequences;
      the illustrated renderer also reflects them in its establishing shot.
- [ ] Pip's inventory, NPC trust, puzzle state, and timer remain consistent.
- [ ] Text and illustrated products receive the same Companion actions.
- [ ] The illustrated sequence feels like cinematic composition, not software UI.

## Compact Design Rule

> Keep the ZIL room as the physical world location. Use Companion focus to
> carry the current subject, state, implicit object, prose, and local actions.
> Feed that same interaction state to both products. Text renders the narrative
> zoom in prose; illustration may additionally render it as wide shots,
> close-ups, inserts, and changed establishing shots.
