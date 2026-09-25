# Stage 2 — Story map

Turn the design into locations, pages, choices and the few facts the book
remembers.

## Inputs

- `DESIGN.md`

## Required actions

1. **Locations.** List each place the hero can be in, with its story role
   (start, goal, danger, rest, reveal). Name them the way the reader would:
   "the attic floor", "the desk", "the window sill".
2. **Routes.** For each connection, say how the hero travels it physically
   ("jumps from the chair seat onto the desk"), in both directions, or record
   why it is one-way. Routes use things that are really there; stage 3 will
   give them sizes.
3. **Page graph.** List every page with a short ID, its kind and its exits:
   - *room* page: the hero is somewhere and chooses (2–3 choices);
   - *beat* page: something happens and the reader taps Continue;
   - *ending* page: no choices.

   Draw the graph as a table or Mermaid diagram. Every page must be reachable
   and every non-ending page must lead somewhere.
4. **Choices.** For each room page, write each choice as an intention in the
   hero's voice ("Jump onto the chair", "Follow the music"), plus the page it
   leads to. Two choices that lead to the same outcome are one choice.
5. **Facts, not inventory.** List every fact the book remembers:
   - its name (`FOUND_BRASS_STAR`, `MET_THE_OWL`, `DOOR_LEFT_OPEN`);
   - the page that sets it;
   - every page that checks it, and what changes there (a different choice,
     different text, a different picture state, or a different ending).

   Delete any fact that no later page checks. Prefer the path itself as
   memory: if only one route reaches a page, that page already knows its
   history. Keep facts few: *The Forces of Krill* checks two items in 128
   pages.
6. **Picture states.** For each location, list the visible variants that
   facts cause ("desk with copper star", "desk without it"). Each variant
   becomes a camera or item layer in stage 5.
7. **Failure and danger.** Decide what a poor choice leads to: a gentle
   setback that returns the hero, a comic dead end, or a bad ending. Match
   the audience in `DESIGN.md`. Never punish a choice the reader had no way to
   judge.
8. **Golden path and alternatives.** Write the shortest route to the good
   ending, plus at least one different valid order or route.

## Output

`work/STORY_MAP.md` with sections: Locations, Routes, Page graph, Choices,
Facts, Picture states, Failure and danger, Golden path.

## Acceptance checks

- Every page is reachable from the opening, and every route ends in an ending.
- Every choice is a decision with a distinct outcome, not a verb or a
  duplicate.
- Every fact is set on one page and checked on at least one later page.
- Nothing is tracked as an inventory list; carried things are facts shown in
  pictures and text.
- Every physical route names the real objects used to travel it.
