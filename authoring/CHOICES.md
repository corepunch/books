# Choices: how the reader decides what happens

Read this with stages 2, 5, 6 and 8. It shows how the Zork gamebooks present
choices and how this engine presents the same thing on an illustrated page.

## How *The Forces of Krill* does it

Every decision page follows the same three steps.

1. **The prose sets up the options.** The situation is described so that each
   option is already visible in the scene before it is offered:

   > The trail forks. One trail is covered with a thick bed of leaves. The
   > other shows the dirt of the forest floor. Next to the fork stands a large
   > tree with low branches that could be climbed. "What do we do now?" asks
   > Juranda.

2. **The page ends on a short question per option**, usually two, sometimes
   three:

   > Take the leaf-covered trail? *Go to page 29.*
   > Take the dirt trail? *Go to page 32.*
   > Try climbing the tree? *Go to page 35.*

3. **Pages without a decision simply continue** ("Go to page 34"), and
   occasionally a page checks a remembered fact ("Did you get the bronze key
   from the bird's nest? If so, go to page 50. If not, go to page 53.").

The options are real dilemmas, often safety against curiosity or duty
against temptation:

- "Do you think Bill should take the sword?" / "…ignore the sword and
  continue home?"
- "Follow the knights to the campsite?" / "Find the old man in the village
  instead?"
- "Would you stay with the old man?" / "Would you try to bring the Sword of
  Zork to the forest?"

## How this engine shows it

The page number becomes a place on the picture. Each option on a room page is
a **circle on the thing it concerns, with the option's text as a caption beside
it**. The reader can tap the circle or the caption. Pages without a decision
show the Continue button. Remembered facts are checked by the book itself, so
the reader is never asked "did you get the key?"; the page simply offers what
is possible.

So a decision page has:

- the picture, showing every option's object;
- the page text, which sets up the options as *Krill* does;
- one circle with a caption per option, placed on its object.

## Writing the options

1. **Set them up in the text.** Every option's object or direction is named or
   clearly implied in the passage before it appears as a caption. End the
   passage on the dilemma, as a thought, a question from a character, or the
   situation itself ("The chair stands right by the desk, and the star glints
   by the basket.").
2. **Two or three options.** One is not a choice; four crowds the picture.
3. **Short questions, like Krill.** Write each caption as a short question
   about an action: "Take the dirt trail?", "Follow the owl?", "Jump onto the
   chair?". Use the same form for every option on a page. Keep captions under
   about 30 characters so they fit on one or two lines.
4. **Real dilemmas.** Each option must lead somewhere different and express a
   different attitude: careful or bold, helpful or hurried, curious or
   obedient. Never offer two captions with the same outcome.
5. **Reasonable from the page alone.** The reader must be able to reason
   about each option from the picture and text they have seen. Clues come
   before choices (see [CRAFT.md](CRAFT.md) §3).
6. **No meta options.** No "go back", "look around" or "inventory". Moving to
   another place is an option only when it is a story decision; the book's
   Continue button handles plain progression.
7. **Playful options are welcome.** One per act may lead to a short funny
   outcome that returns the hero.

## Placing the circles (anchors)

Each option needs an anchor: a named point in the scene where its circle
appears.

- **Acting on an object:** the object itself (the star, the sword, the
  lever).
- **Travelling:** the first step of the route (the chair seat, the start of
  the leafy trail, the sill edge), not the destination far away.
- **Talking to or trusting someone:** that character (the old man, the owl).
- **An inner decision** (wait, hide, give up the search): the place where the
  hero would do it (under the table, the basket), never an empty wall.

Placement rules:

- Every anchor must be visible in the page's camera, at least 5 % inside the
  frame, and outside the text zone.
- Leave room for captions. The engine puts each caption below its circle, or
  above, right or left if that side is blocked, and never over the page text,
  another circle or another caption. Keep about 250 × 60 px (on an 1100 × 800
  page) free on at least one side of every anchor.
- Anchors of different options on the same page need clear space between
  them; if two objects are close together, move one or reframe the camera.

## Implementing an option

In the book's C file:

1. Register the anchor object with `set_object(OBJECT_…, "key", …)`. The key
   matches the scene's anchor group name (lowercase, `_` becomes `-`), so the
   `Chair` group is the `chair` key.
2. On the room page, add the option with
   `append_choice(object_choice(OBJECT_…, "Запрыгнуть на стул?", "go table"))`:
   the caption, then a unique command used by tests and headless play.
3. Handle the object in `perform()`: update facts, then call `show_beat()`
   with the outcome text and camera. The beat page's Continue returns to the
   room or advances the story.
4. Offer an option only when it is possible under the current facts; remove it
   once it no longer makes sense (the gate is already open).

## Checking options

- Headless output lists each circle control with its `label` and its
  `caption` rectangle. `tests/test_book.py` checks that captions stay on the
  page and never overlap the text, other circles or other captions.
- Read each decision page in the app: every option's object is visible, every
  caption is readable against the art, and the reader could explain why they
  might choose each option.
