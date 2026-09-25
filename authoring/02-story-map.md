# Stage 2 — Story map

Turn the design into locations, pages, challenges, choices and the few facts
the book remembers.

## Inputs

- `DESIGN.md`
- [CRAFT.md](CRAFT.md) §1, §3–§11, [CHOICES.md](CHOICES.md)

## Required actions

1. **Locations.** List each place the hero can be in, with its story role
   (start, goal, danger, rest, reveal), its visual anchor, and the act or acts
   it appears in. Name them the way the reader would: "the attic floor", "the
   desk", "the window sill".
2. **Routes.** For each connection, say how the hero travels it physically
   ("jumps from the chair seat onto the desk"), in both directions, or record
   why it is one-way. Routes use things that are really there; stage 3 gives
   them sizes.
3. **Challenges.** For each obstacle between the hero and the goal:
   - what blocks the way and why, in the world's own logic;
   - the kind of challenge (noticing, remembering, understanding a character,
     order or timing);
   - its clue chain: every page where a clue appears, and whether it is in the
     picture, the text, or both (a picture clue always has a text or close-up
     backup);
   - the sensible choice, the tempting wrong choices, and what each wrong
     choice leads to (a funny setback, a new clue, a recoverable danger);
   - what visibly changes once it is solved.
4. **Characters.** For each character other than the hero: where they appear,
   their states (at least three for important characters), what changes each
   state, and how they react to earlier choices.
5. **Page graph.** List every page with a short ID, its kind and its exits:
   - *room* page: the hero is somewhere and chooses (2–3 choices);
   - *beat* page: something happens and the reader taps Continue;
   - *ending* page: no choices.

   Draw the graph as a table or Mermaid diagram. Every page must be reachable
   and every non-ending page must lead somewhere.
6. **Choices.** For each room page, write each choice as an intention in the
   hero's voice ("Jump onto the chair", "Follow the music"), what it tests or
   expresses, and the page it leads to. Two choices with the same outcome are
   one choice. Include at least one playful choice per act with a short funny
   outcome that returns the hero.
7. **Facts, not inventory.** List every fact the book remembers:
   - its name (`FOUND_BRASS_STAR`, `MET_THE_OWL`, `DOOR_LEFT_OPEN`);
   - the page that sets it;
   - every page that checks it, and what changes there (a different choice,
     different text, a different picture state, or a different ending).

   Delete any fact that no later page checks. Prefer the path itself as
   memory: if only one route reaches a page, that page already knows its
   history. Keep facts few: *The Forces of Krill* checks two items in 128
   pages.
8. **Thresholds and world changes.** For each act threshold, list the
   locations that change and how (picture, text, choices). At least two per
   threshold.
9. **Picture states.** For each location, list every visible variant caused
   by facts and thresholds ("desk with copper star", "desk without it", "attic
   at dawn"). Each variant becomes its own camera and its own whole painting
   in stage 5; nothing is drawn on top of a picture.
10. **Failure and danger.** Decide what poor choices lead to, matching the
    audience in `DESIGN.md`. Never punish a choice the reader had no way to
    judge.
11. **Secrets and alternatives.** Each optional secret and how it is found, and
    at least one alternative route or order to the good ending.
12. **Golden path.** The shortest route to the good ending, as page IDs and
    choices.

## Output

`work/STORY_MAP.md` with sections: Locations, Routes, Challenges,
Characters, Page graph, Choices, Facts, Thresholds, Picture states, Failure
and danger, Secrets and alternatives, Golden path.

## Acceptance checks

- Every page is reachable from the opening, and every route ends in an ending.
- Every challenge's answer is shown or stated before the choice that tests it.
- Every choice is a decision with a distinct outcome, not a verb or a
  duplicate.
- Every fact is set once and checked on at least one later page.
- Nothing is tracked as an inventory list; carried things are facts shown in
  pictures and text.
- Every threshold changes at least two locations.
- Every physical route names the real objects used to travel it.
