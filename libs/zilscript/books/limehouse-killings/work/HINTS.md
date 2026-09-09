# The Limehouse Killings - Hint Design

Hints must preserve idea-space challenge while removing parser friction. Every final-tier hint uses a command accepted by the current parser-driven walkthrough.

## Current Delivery

The implemented `HINTS` command chooses one state-aware hint:

1. Study access while the door is locked.
2. Library cipher until solved.
3. Poison comparison until identified.
4. Case assembly and Lestrade afterward.

Topic-specific, repeat-to-advance tiers are a future UI refactor, not current behavior. The content below is the target copy for that refactor.

## Opening and Study Access

| Tier | Copy |
|---|---|
| Attention | “The study door is locked, but a locked-room crime may have more than one route.” |
| Direction | “Hudson has the study key. The colored books in the library may reveal how someone avoided the door.” |
| Action | “Ask Hudson about the key for the physical route, or solve the marked-book sequence for the hidden route.” |
| Command | `ASK HUDSON ABOUT KEY`, or `PUSH RED BOOK`, `PUSH YELLOW BOOK`, `PUSH GREEN BOOK`, `PUSH BLUE BOOK` |

Design note: never imply the key or lockpick is the only solution. The secret passage is the preferred story-bearing route.

## Library Passage

| Tier | Copy |
|---|---|
| Attention | “The torn page and colored ribbons describe the same arrangement.” |
| Direction | “The page says rainbow order; only four marked colors are present.” |
| Action | “Push the marked books from the warm end of the sequence toward blue.” |
| Command | `PUSH RED BOOK`, then yellow, green, and blue |

Wrong order: “The book springs back. The sequence resets.”

## Greenhouse Poison

| Tier | Copy |
|---|---|
| Attention | “The vial and the greenhouse labels each use two names for one plant.” |
| Direction | “Aconitum is wolfsbane; compare the physical vial with the purple plant.” |
| Action | “Use the vial on the plants rather than merely carrying antidote ingredients.” |
| Command | `USE VIAL ON PLANTS` |

Wrong attempts:

- `TASTE VIAL`: danger feedback and recoverable health loss.
- Merely taking foxglove/charcoal: no progress; these are not the identification solution.

## Ashworth Name Dial

| Tier | Copy |
|---|---|
| Attention | “The box has no keyhole. Its three engravings are categories of evidence.” |
| Direction | “Connect the sealed letter, purple flower, and columns of debt to one person.” |
| Action | “Read the letter and ledger, identify the poison, then set the dial to the shared name.” |
| Command | `TURN LOCKED BOX TO MORIARTY` |

Wrong attempts:

- `OPEN BOX`: teaches that the dial is the lock.
- Correct name before prerequisites: identifies the unresolved three categories.
- Wrong name: dial returns to blank.

## NPC Interviews and State Changes

| Tier | Copy |
|---|---|
| Attention | “Answers establish alibis; showing evidence changes behavior.” |
| Direction | “Ask Hudson and Lady Ashworth about their alibis. Ask Moriarty about poison.” |
| Action | “Show the unsent letter before Act III if you want to expose a suspect's intermediate state.” |
| Command | `ASK HUDSON ABOUT ALIBI`, `ASK LADY ABOUT ALIBI`, `ASK MORIARTY ABOUT POISON`, `SHOW LETTER TO HUDSON/LADY/MORIARTY` |

Topicless `ASK NPC` should prompt for a topic, never crash.

## Lestrade's Case Chain

| Tier | Copy |
|---|---|
| Attention | “Lestrade wants an argument, not an inventory count.” |
| Direction | “Organize the case as threat, method, and motive.” |
| Action | “Show him Ashworth's threat, the identified poison, and the financial corroboration.” |
| Command | `SHOW LETTER TO INSPECTOR`, `SHOW BOTTLE TO INSPECTOR`, `SHOW STATEMENT TO INSPECTOR` |

Early accusation response must name the missing argument links, not say only “not enough evidence.”

## Final Choice

| Tier | Copy |
|---|---|
| Attention | “The case is complete. Decide which proof should lead.” |
| Direction | “The letter invites witness confirmation; the poison may provoke specialized knowledge.” |
| Action | “Accuse Moriarty with either the letter or the poison.” |
| Command | `ACCUSE MORIARTY WITH LETTER` or `ACCUSE MORIARTY WITH POISON` |

## General Hint Principles

- Attention → direction → action → exact command.
- Hint the inference before the syntax.
- Use nouns printed in current room/object prose.
- Never reference nonexistent verbs such as `MATCH` or `FIND WOLFSBANE`.
- Never describe foxglove/charcoal as mandatory until an antidote system exists.
- Update hints at act boundaries so solved problems disappear.
- Preserve dry Victorian voice; Hudson's kettle is a useful tonal model.
