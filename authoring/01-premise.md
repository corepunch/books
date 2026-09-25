# Stage 1 — Premise and design

Decide what book is being made before any map, model or text exists.

## Inputs

- The user's request and any reference books or images they supplied
- [README.md](README.md) for the engine's page model
- [CRAFT.md](CRAFT.md), read in full

## Required actions

1. **One-sentence premise.** Who the hero is, where they must go or what they
   must do, and what stands in the way. "Two children must carry a magic sword
   across an invaded kingdom to the wizard who can wield it, before the
   warlock's army finds them."
2. **High concept and reader fantasy.** One sentence on what the reader feels
   they are doing, naming what is special about this book (CRAFT §2): crossing
   a giant's house at night as a kitten, guiding a baby dragon home through a
   frozen valley, following a river to the sea on a raft.
3. **Journey line.** Where the story starts, where the goal is, the opposing
   force that acts along the way, and the reason to hurry or be afraid. Name
   the companion or pair of heroes and the strangers met on the road
   (CRAFT §1–§2, §9).
4. **Audience and read-aloud use.** Age range, reading level, and whether an
   adult reads it aloud with a child. This sets sentence length, vocabulary,
   and how dangerous things may get.
5. **Tone.** Name two or three qualities, such as "warm night-time fairy tale,
   gentle humour, real but gentle peril". Decide how failure endings look for
   this audience (CRAFT §6); they exist in every adventure.
6. **Hero and point of view.** Third person with a named hero reads best
   under a picture ("Varya steps over the rotten plank"). Use second person only if
   the reader should be the hero, and then keep it throughout. Note what makes
   the hero readable in wide shots (size, colour, silhouette).
7. **Setting, route and time.** The world in two sentences, then the route as
   an ordered list of locations from start to goal, with the branches that
   visit other places. Six or more locations; the hero ends far from the start
   (CRAFT §1). State the time span (one night, a day and a night): time changes
   lighting on every painting, so decide it now.
8. **Acts.** Departure, the road, the confrontation (CRAFT §10): for each, its
   stretch of country, main activity, the threshold that ends it, and what is
   different afterwards.
9. **Size and painting budget.** Number of locations, decision pages, story
   (Continue) pages and endings, and the number of distinct pictures. Aim for
   about two story pages per decision page (CRAFT §5).

   | Book | Locations | Pages | Decision pages | Endings |
   |---|---|---|---|---|
   | Short adventure | 6–10 | 25–40 | 8–12 | 4–7 (one full success) |
   | Zork-book size | 15–25 | 60–120 | 18–25 | 12–20 |

   Every page shows one whole picture, but consecutive pages of one moment may
   share a camera (Krill illustrates about every other page), so pictures can
   be about two thirds of the page count. A book with fewer than six locations
   is not an adventure; rethink the premise rather than shrinking the map.
10. **Structure.** Branch and bottleneck, the Zork-book shape: the route
    splits into alternative stretches of country that rejoin at a few key
    scenes (the house, the dam, the lair), with failure endings hanging off
    each stretch. A *gauntlet* (one main line with short side branches that end
    or rejoin) suits a very short book. A *hub* (moving freely among a few
    places while facts change what they offer) is allowed only as one episode
    inside the journey, such as exploring a house before going down to the
    cellar; it is never the whole book.
11. **Goal and endings.** The concrete condition for the full success, then
    every other ending: partial successes, failures and the early "safe and
    dull" ending (CRAFT §6), each with the choice that causes it, the warning
    that precedes it, and the decision page the reader should retry from.
    Note any sequel hook.
12. **Opening.** The ordinary world, the strange event that starts the
    adventure, and the first decision by page two or three (CRAFT §11).
13. **Contrast and secrets.** The planned funny, beautiful and warm moments
    per act, at least one hidden place and one shortcut.
14. **Exclusions.** What the book will not contain: inventory lists, dice,
    timers, combat stats, typed commands, sound (the engine has none).

## Output

`books/<name>/DESIGN.md` with sections: Premise, High concept, Journey line,
Audience, Tone, Hero, Setting, route and time, Acts, Size and budget,
Structure, Goal and endings, Opening, Contrast and secrets, Exclusions.
`books/lighthouse/DESIGN.md` is a worked example.

## Acceptance checks

- The premise and high concept each fit in one sentence and could be pitched
  aloud; the concept is more than "collect the things", and the plot does not
  depend on picking up and carrying items.
- The audience is specific enough to judge vocabulary and danger.
- It is an adventure: six or more locations on an ordered route, the hero
  ends far from the start, and no location is planned to hold more than a
  quarter of the pages.
- There is an opposing force and a reason to hurry or be afraid.
- The full success is concrete and testable ("the sword is in Syovar's
  hands"), not a mood, and there are several failure endings plus an early
  safe one.
- Each act has a threshold and a planned change to the world.
- The painting budget is written down and matches the planned page count.
- Nothing in the design needs an inventory, typed commands or a mechanic the
  engine lacks.
