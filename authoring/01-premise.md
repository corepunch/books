# Stage 1 — Premise and design

Decide what book is being made before any map, model or text exists.

## Inputs

- The user's request and any reference books or images they supplied
- [README.md](README.md) for the engine's page model

## Required actions

1. **One-sentence premise.** Who the hero is, what they want, and what stands
   in the way. "Mira the kitten must gather three stars scattered around the
   attic before morning."
2. **Reader fantasy.** One sentence on what the reader feels they are doing:
   exploring, rescuing, solving, escaping, befriending.
3. **Audience and read-aloud use.** Age range, reading level, and whether an
   adult reads it aloud with a child. This sets sentence length, vocabulary,
   and how dangerous things may get.
4. **Tone.** Name two or three qualities, such as "warm night-time fairy tale,
   gentle humour, no threats". Decide how much danger is allowed and whether
   bad endings exist.
5. **Protagonist and point of view.** Third person with a named hero reads
   best under a picture ("Mira jumps onto the chair"). Use second person only
   if the reader should be the hero, and then keep it throughout.
6. **Size.** Number of locations, pages (camera shots) and endings. A short
   first book: 1–3 locations, 10–20 pages, 1–2 endings. A Zork-book-sized
   story: 8–15 locations, 40–60 pages, several endings.
7. **Structure.** Choose one and say why:
   - *Hub*: the hero moves between a few locations in any order, and facts
     decide what each page offers (Three Stars).
   - *Branch and bottleneck*: branches that rejoin at key scenes, the usual
     Zork-book shape.
   - *Gauntlet*: one main line with short side branches that end or return.
8. **Goal and endings.** The concrete condition for the good ending, and each
   other ending with what causes it. Every ending must follow from choices the
   reader could understand.
9. **Opening page.** It needs one landmark, one visible goal, one obstacle,
   and one quick first success the reader can reach in one or two choices.
10. **Contrast.** Plan at least one funny, one beautiful and one warm moment,
    even in an adventure story.
11. **Exclusions.** Write down what the book will not contain (inventory
    lists, dice, timers, combat stats, parser commands).

## Output

`books/<name>/DESIGN.md` with sections: Premise, Reader fantasy, Audience,
Tone, Hero, Size, Structure, Goal and endings, Opening page, Contrast,
Exclusions. The Three Stars `DESIGN.md` is a working example.

## Acceptance checks

- The premise and fantasy each fit in one sentence and could be pitched aloud.
- The audience is specific enough to judge vocabulary and danger.
- The good ending is concrete and testable ("all three stars are in the
  basket"), not a mood.
- The opening page can be described as landmark, goal, obstacle and first
  success.
- Nothing in the design needs an inventory, typed commands or a mechanic the
  engine lacks.
