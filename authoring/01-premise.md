# Stage 1 — Premise and design

Decide what book is being made before any map, model or text exists.

## Inputs

- The user's request and any reference books or images they supplied
- [README.md](README.md) for the engine's page model
- [CRAFT.md](CRAFT.md), read in full

## Required actions

1. **One-sentence premise.** Who the hero is, what they want, and what stands
   in the way. "Mira the kitten must gather three stars scattered around the
   attic before morning."
2. **High concept and reader fantasy.** One sentence on what the reader feels
   they are doing, naming what is special about this book (CRAFT §2):
   exploring a giant's house as a kitten, guiding a dragon who melts ice.
3. **Audience and read-aloud use.** Age range, reading level, and whether an
   adult reads it aloud with a child. This sets sentence length, vocabulary,
   and how dangerous things may get.
4. **Tone.** Name two or three qualities, such as "warm night-time fairy tale,
   gentle humour, no threats". Decide how much danger is allowed and whether
   bad endings exist.
5. **Hero and point of view.** Third person with a named hero reads best
   under a picture ("Mira jumps onto the chair"). Use second person only if
   the reader should be the hero, and then keep it throughout. Note what makes
   the hero readable in wide shots (size, colour, silhouette).
6. **Setting and time.** The world in two sentences, the locations roughly,
   and the time span (one night, a day and a night). Time changes lighting on
   every painting, so decide it now.
7. **Acts.** Three acts (or a declared alternative), each with its main
   activity, the threshold that ends it, and how the world changes after it
   (CRAFT §9).
8. **Size and painting budget.** Number of locations, room pages, beat pages
   and endings. Every page is one whole painting, and every picture state of a
   room (door open, door shut) is another painting. A short first book: 1–3 locations,
   10–20 pages. A Zork-book-sized story: 8–15 locations, 40–60 pages, several
   endings.
9. **Structure.** Choose one and say why:
   - *Hub*: the hero moves between a few locations in any order, and facts
     decide what each page offers (Three Stars).
   - *Branch and bottleneck*: branches that rejoin at key scenes, the usual
     Zork-book shape.
   - *Gauntlet*: one main line with short side branches that end or return.
10. **Goal and endings.** The concrete condition for the good ending, and each
    other ending with what causes it. Every ending must follow from choices
    the reader could understand. Note any sequel hook.
11. **Opening page.** One landmark, one visible goal, one obstacle, and one
    quick first success the reader can reach in one or two choices.
12. **Contrast and secrets.** The planned funny, beautiful and warm moments
    per act, and at least one optional secret.
13. **Exclusions.** What the book will not contain: inventory lists, dice,
    timers, combat stats, typed commands, sound (the engine has none).

## Output

`books/<name>/DESIGN.md` with sections: Premise, High concept, Audience, Tone,
Hero, Setting and time, Acts, Size and budget, Structure, Goal and endings,
Opening page, Contrast and secrets, Exclusions. The Three Stars `DESIGN.md` is
a working example of several of these.

## Acceptance checks

- The premise and high concept each fit in one sentence and could be pitched
  aloud; the concept is more than "collect the things", and the plot does not
  depend on picking up and carrying items.
- The audience is specific enough to judge vocabulary and danger.
- The good ending is concrete and testable ("all three stars are in the
  basket"), not a mood.
- Each act has a threshold and a planned change to the world.
- The painting budget is written down and matches the planned page count.
- Nothing in the design needs an inventory, typed commands or a mechanic the
  engine lacks.
