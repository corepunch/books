# Stage 6 — Page text

Write what the reader actually reads: one short passage per page and the
choice labels. Think of a read-along picture book with choices: the picture
carries the scene, the text carries the story.

## Inputs

- `DESIGN.md`, `work/STORY_MAP.md`, `work/ROOMS.md`, `work/SHOTS.md`
- [CRAFT.md](CRAFT.md) §4, §6, §10, §12, [CHOICES.md](CHOICES.md)

## Required actions

1. **One beat per page.** Each passage says what happened, why it matters or
   how the hero feels, and what changed. It does not repeat what the picture
   plainly shows ("there is a desk and a chair"); it names only what the
   reader needs to understand the choices.
2. **Length.** Room pages: 1–3 sentences, about 25–45 words. Beat pages: 1–2
   sentences. Endings may run a little longer. Check that each passage fits
   its text zone at its text scale.
3. **Room pages invite choices.** Mention every choice's anchor in the story
   so the choices make sense ("the chair stands right by the desk"). The first
   visit sets the scene; revisits are shorter and reflect current facts
   ("The brass star is already Mira's").
4. **Beat pages resolve the choice.** Show the hero's action with a concrete
   physical detail ("she jumps onto the seat, then puts her front paws on the
   edge of the desk"), then let Continue return to a room or advance the
   story.
5. **Choice captions.** Short questions about an action, as in the Zork
   books ("Jump onto the chair?", "Take the dirt trail?"), all in the same
   form, under about 30 characters. Set every option up in the passage first
   and end the passage on the dilemma. Never write system commands, parser
   verbs or item lists. See [CHOICES.md](CHOICES.md).
6. **No mechanics on the page.** No inventory, no "you can't", no "nothing
   happens", no counts or scores. If a choice is not possible, do not offer
   it. Carried things appear in the text only when they matter ("the key she
   found in the nest fits").
7. **Clues in words.** Every clue the story map relies on appears in the text
   at least once, even when the picture also shows it, so a reader who misses
   a painted detail can still reason it out. Give clues naturally, as
   something the hero notices, never as an instruction.
8. **Paths remembered.** On pages where branches rejoin, add a phrase that
   reflects the path taken (from `SHOTS.md`), and on revisits after a
   threshold, say what has changed.
9. **Dialogue.** Keep spoken lines short, in quotation marks, and attributed
   ("“Up there!” hoots the owl."). One speaker per page where possible.
10. **Playful outcomes.** Funny choices get a short, warm payoff that returns
    the hero, not a telling-off.
11. **Concrete and sensory.** Use one sense detail per page where it helps (the
    cold sill, the smell of ink). Show feelings through action rather than
    labels.
12. **Voice and tone.** Keep the point of view from `DESIGN.md`, the vocabulary
    of the audience, and the tonal contrast (something funny, beautiful and
    warm early on).
13. **Endings.** Refer back to at least two things the reader discovered or
    chose, resolve the goal, and hint at what comes next.
14. **Read aloud.** Read every passage aloud. Rewrite anything that trips the
    tongue or needs a second reading.

## Output

`work/TEXT.md` listing each page ID with its camera, passage and choice
labels, including every fact-dependent variant.

## Acceptance checks

- Every page and every fact variant has text.
- Every room page's text names or implies each choice's anchor.
- Every clue appears in text at least once before the choice that needs it.
- No passage shows a mechanic, an inventory, or a failure message.
- Passages fit their text zones and read smoothly aloud.
- The ending recalls specific discoveries or choices.
