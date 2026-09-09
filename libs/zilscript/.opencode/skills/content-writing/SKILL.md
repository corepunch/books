---
name: content-writing
description: Write player-facing prose, NPC dialogue trees, layered hints, and ensure every noun in text resolves through the parser
---

Write player-facing text and interactions that teach play and maintain tone.

## Inputs
- Prior stage artifacts

## Required Actions
1. Write first-visit and revisit room text with actionable nouns.
2. **Ensure every conspicuous noun is handled** — every object, person, or feature a player might reasonably type must resolve through the parser. Use real `OBJECT`s with `(FLAGS NDESCBIT ...)` for scenic nouns (wallpaper, stairs, dust, fixtures, bars, desks, bookshelves) so they parse natively without VOC-EXACT wiring. Give each scenery OBJECT generous `SYNONYM` and `ADJECTIVE` coverage and an `ACTION` routine for at least `EXAMINE`. Use `PSEUDO` only for trivial single-word scenery that needs no synonyms or compound-phrase matching. Use `GLOBAL`/`LOCAL-GLOBALS` for shared scenery visible from multiple rooms. `NDESCBIT` only suppresses automatic listing; it does not make an unimplemented noun interactive.
3. Author object text to support puzzle affordances.
4. Author NPC behavior scope and conversation patterns (ASK/TELL/GIVE/SHOW).
5. Author layered hints (attention, direction, action, command).
6. Author clear success feedback and useful failure feedback.
7. Keep prose brief and concrete: room descriptions should usually be 1-4 sentences with one strong anchor.
8. Balance tone intentionally: clear spatial prose, dry humor, and credible danger.
9. Add custom responses for obvious silly commands so humor is systemic, not just decorative.
10. Ensure major objects act as more than props (tool, clue, world detail, joke, risk, trophy, or memory marker).
11. Give key NPCs behavior loops (move, block, steal, help, react, change state), not only static dialogue.
12. **Player identity belongs in SYNOPSIS.md/DESIGN.md, not in PLAYER object LDESC** — Infocom never explicitly states who the player is in game text.
13. For every actionable compound noun used in prose, choose and record a canonical command plus natural variants.
14. Write NPC topic rows as executable commands (`ASK HUDSON ABOUT KEY`), with listener, topic noun, response, state change, repeat response, and where the listener is accessible.
15. **Avoid introducing duplicate objects through prose.** Before describing a new item in room text, check whether an identical item already exists elsewhere in the world. If a player finds a knife in one room, do not describe another knife in a different drawer without explicitly differentiating it (e.g. "a rusty dagger" vs. "a chef's knife"). Each portable item should be unique; if the same object type appears in multiple rooms, only one should be interactive.
16. **When writing companion cards, separate intention from parser syntax.**
    Labels must be concise, natural, age-appropriate intentions; hidden commands
    must use parser vocabulary proven in the matching state. Use tentative
    wording such as “Try the door” until success or the obstacle is known.
17. **Write companion labels for complete state coverage.** Review every
    reachable room and material inventory, knowledge, puzzle, NPC, and hazard
    family. Include progress, investigation, interaction/experiment, useful
    movement, and urgent safety or recovery where the state supports them.
    Optional areas and alternate endings receive the same editorial standard as
    the golden path.

## Outputs
- Draft room and object prose set
- NPC topic/reaction matrix
- Hint tiers per puzzle

## Artistic Quality Patterns

### Prose: Show, Don't Tell the Mood
Every room description must contain at least one concrete sensory detail (sight, sound, smell, texture, temperature). Never use emotion-label adjectives as a substitute for description.

### Atmosphere: Systems, Not Backdrops
Atmosphere must be interactive. Before writing flavor text, ask: can the player do something about this?

### NPCs: Characters, Not Props
Every NPC must have at least three behavioral states that the player can discover and affect.

### Emotional Range: Contrast Makes Horror Hit Harder
A horror game must have moments of beauty, humor, or warmth. Without contrast, the player desensitizes.

### Environmental Storytelling: Clues in the World, Not Files in a Drawer
Cut text-dump objects by half. Move their information into room descriptions, object examines, environmental details, and NPC dialogue.

### Twist Delivery: Earn It, Don't Telegraph It
A twist should be discoverable, not stated. The reveal should be the first moment the player truly understands.

### Endings: Interactive Resolution, Not Held-Item Check
An ending must: (1) reference at least two specific discoveries, (2) give the player a choice, (3) imply what comes next.

### Discovery Text: FDESC on Things Worth Discovering
Give portable, surprising, or focal objects `FDESC` discovery text when the room does not already introduce them. Never combine an intended automatic `FDESC` with `NDESCBIT`; suppressed scenery must be introduced by room text or a room action.

For stateful automatic objects on this substrate, prefer `DESCFCN` without `FDESC`: untouched `FDESC` text is emitted before `DESCFCN` and can shadow the current state.

### Assign One Visible Description Owner
Use the Infocom hybrid rather than an absolute room/object split:
- Let portable, newly discovered, or independently changing focal objects describe themselves through `FDESC`, `LDESC`, or `DESCFCN`.
- Describe permanent architectural scenery and multi-object spatial relationships in room `LDESC`/`M-LOOK`, backed by real or pseudo objects with `NDESCBIT`.
- Keep stateful prose in one dynamic owner. A room action may own the state of a rug/trap door or boiler; an object `DESCFCN` may own its own state. Do not leave a static `FDESC` contradicting either.
- Naming an object briefly for spatial orientation is allowed, but do not repeat the same discovery facts in the room paragraph and automatic object line.

Every concrete noun promised by either path must still parse. Rich interaction coverage does not require every scenery noun to produce a separate line during `LOOK`.

### Parser Depth: Pronoun Resolution, GWIM, OOPS
At minimum, implement pronoun resolution (`THIS-IS-IT`) and GWIM defaults for your game.

### NPC Dialogue Trees: Back-and-Forth Conversation
Each NPC must have at least 3 topics that change based on game state.

### Unique Death Text: Every Death a Discovery Moment
Every distinct death type must have unique text. Generic "You have died" is never acceptable.

### Tonal Range
Divide your game into thirds. In the first third, the player should encounter at least ONE thing that is beautiful, ONE thing that is funny, and ONE thing that is warm.

## Acceptance Checks
- Tone remains consistent.
- Room prose implies meaningful actions.
- Wrong-but-reasonable attempts are informative.
- Revisited text is concise and state-aware.
- NPC interactions produce observable world or puzzle consequences.
- Every emphasized clue noun and every noun used in a hint resolves through the parser exactly as written.
- Every visible feature has exactly one coherent description owner on room entry; automatic object lines neither duplicate room prose nor contradict current state.
- Every `FDESC` intended to appear automatically is on an object without `NDESCBIT`.
- No room prose introduces a portable item that duplicates an identical item already placed elsewhere in the world; each portable object type is unique or explicitly differentiated.
- Companion labels never reveal source-only knowledge, never overpromise the
  parser outcome, and provide understandable progress or recovery across every
  reachable state family.

## Reference Sources
- `skills/source_zil_text_adventure_agents.md`: sections 6, 7, 11, 14
- `skills/source_writing_adventures.md`: Crafting Great Adventures section
