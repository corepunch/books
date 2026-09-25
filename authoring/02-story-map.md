# Stage 2 — Story map

Turn the design into a journey: the places on the route, the pages that carry
the story between them, the forks, the dangers, the endings and the few facts
the book remembers.

## Inputs

- `DESIGN.md`
- [CRAFT.md](CRAFT.md) §1, §3–§11, [CHOICES.md](CHOICES.md)

## Required actions

1. **Route and locations.** Draw the journey as a map from the starting place
   to the goal, with every branch. Then list each location in route order with
   its story role (start, crossing, danger, rest, reveal, lair), its visual
   anchor, its act, which branches pass through it, and how many pages it
   holds. Name them the way the reader would: "the signpost at the fork", "the
   white house", "the dam". Most locations are visited once; mark any the
   story returns to and why.
2. **Travel.** For each connection, say how the hero gets there: walking
   the forest trail, floating down from the cliff, riding the raft, climbing
   the dam stairs, falling through a grating. Most travel happens on story
   pages between locations. Where the hero moves inside one place (floor to
   table, kitchen to cellar), name the real objects used; stage 3 gives them
   sizes.
3. **Dangers and challenges.** For each threat or obstacle on the road (a
   troll, a flood, a false friend, a maze, a locked door):
   - what blocks the way and why, in the world's own logic;
   - the kind of decision it poses (which way, whom to trust, risk or
     safety) or, rarely, the reasoning it needs (remembering a warning,
     noticing, understanding a character);
   - its clue chain: every page where a clue appears, and whether it is in the
     picture, the text, or both (a picture clue always has a text or close-up
     backup);
   - the sensible choice, the tempting wrong choices, and what each wrong
     choice leads to (a detour to another place, a danger survived, a
     capture, or a failure ending);
   - what visibly changes once it is solved.
4. **Characters.** For each character other than the hero: where they appear,
   their states (at least three for important characters), what changes each
   state, and how they react to earlier choices.
5. **Page graph.** List every page with a short ID, its kind and its exits:
   - *decision* page (a room page in the engine): the hero is somewhere and
     chooses (2–3 choices);
   - *story* page (a beat page): travel, an encounter, news or danger, then
     Continue;
   - *ending* page: success, partial success or failure.

   Aim for about two story pages per decision page (CRAFT §5); a decision
   rarely follows a decision directly.

   Draw the graph as a table or Mermaid diagram. Every page must be reachable
   and every non-ending page must lead somewhere.
6. **Endings.** A table of every ending: its kind (full success, partial,
   failure, early safe ending), the choice that causes it, the warning that
   came before it, how far along the journey it happens, and the decision page
   the reader should retry from. A short adventure has four to seven endings,
   spread along the route, not bunched at the end.
7. **Choices.** For each room page, write each choice as an intention in the
   hero's voice ("Take the dirt trail", "Follow the knights", "Fight the
   troll"), whether it is a way, trust or risk choice, and the page it leads
   to. Two choices with the same outcome are one choice. Most choices are
   about the road; count them (CRAFT §3).
8. **Facts, not inventory.** List every fact the book remembers:
   - its name (`MIRROR_TURNED`, `BUBLIK_INVITED`, `DOOR_LEFT_OPEN`);
   - the page that sets it;
   - every page that checks it, and what changes there (a different choice,
     different text, a different picture state, or a different ending).

   Delete any fact that no later page checks. Prefer the path itself as
   memory: if only one route reaches a page, that page already knows its
   history. Keep facts few: *The Forces of Krill* checks two items in 128
   pages.
9. **Thresholds.** For each act threshold, the new stretch of country and
   what has changed: news, danger, what the heroes now want.
10. **Picture states.** For each location, list every visible variant caused
   by facts and thresholds ("the bridge whole", "the third plank broken",
   "the flats at high tide"). Each variant becomes its own camera and
   its own whole painting in stage 5; nothing is drawn on top of a picture.
11. **Failure and danger.** Decide how each failure is told for the audience
    in `DESIGN.md` (CRAFT §6). Never end the book on a choice the reader had no
    way to judge.
12. **Secrets and alternatives.** Each optional secret and how it is found, and
    at least one alternative route or order to the good ending.
13. **Golden path.** The route to the full success, as page IDs and choices.
    It should pass through most acts' country and take 12 or more pages even in
    a short book.

## Output

`work/STORY_MAP.md` with sections: Route and locations, Travel, Dangers and
challenges, Characters, Page graph, Endings, Choices, Facts, Thresholds,
Picture states, Failure and danger, Secrets and alternatives, Golden path.

## Acceptance checks

- Every page is reachable from the opening, and every route ends in an ending.
- Every challenge's answer is shown or stated before the choice that tests it.
- Every choice is a decision with a distinct outcome, not a verb or a
  duplicate.
- Every fact is set once and checked on at least one later page.
- Nothing is picked up, carried, or tracked as an inventory list. Facts are
  story conditions, shown in pictures and text.
- The route has six or more locations in order, the golden path ends far from
  where it starts, and no location holds more than a quarter of the pages.
- There are about two story pages for each decision page, and most choices
  are about the way, trust or risk.
- The endings table has one full success, several failures spread along the
  route and an early safe ending; each failure is warned and names its retry
  page.
- Every threshold opens new country or changes what the heroes want.
- Every move inside a location names the real objects used.
