# Stage 8 — Implementation

Write the book as a table of pages in C, then read the whole book through the
headless interface. The engine's story runtime (`src/story.c`) validates the
table, keeps the facts, publishes pages and handles Continue and "try again";
the book file is data.

## Inputs

- `work/STORY_MAP.md`, `work/TEXT.md`, `work/SHOTS.md`
- The blockout from stage 7
- `src/book.h` (the `StoryPage`, `StoryChoice` and `Story` types), the
  repository `README.md` and `AGENTS.md`
- [CHOICES.md](CHOICES.md) (implementing an option)
- The example: [books/lighthouse.c](../books/lighthouse.c)

## Required actions

1. **Source file.** Create `books/<name>.c` defining one `static const struct
   StoryPage pages[]`, one `struct Story` naming the book, its start page and
   its button labels («Дальше», «Попробовать снова», «Начать сначала»), and
   `const struct Story *book_story(void)` returning it. The story name is
   `<name>` and selects `books/<name>/`.
2. **Pages.** One entry per page of `STORY_MAP.md`, with a unique `.id`:
   - `STORY_DECISION`: text, camera, location, and up to three
     `.choices` `{label, anchor, target}`;
   - `STORY_PASSAGE`: text, camera, location and `.next`;
   - `STORY_ENDING`: text, camera, location and `.ending` (`ENDING_SUCCESS`,
     `ENDING_PARTIAL` or `ENDING_FAILURE`). A failure or partial ending retries
     from the reader's last decision; set `.retry` to name an earlier decision
     page instead. The success ending restarts the book.
   - `STORY_CHECK`: invisible; goes to `.next` when `.fact` is set, else to
     `.otherwise`. Use it for "Did you…? If so, go to page 50" and for text
     variants that depend on the past.
   Consecutive pages of one moment may share a camera.
3. **Facts.** Declare facts as bit flags (`FOLLOWED_SEAL = 1u << 0`). A page
   sets them with `.sets` when shown; checks read them; a choice can be
   limited with `.requires` and `.excludes`. There is no inventory and nothing
   is carried. Keep facts few; the path itself is memory.
4. **Anchors.** Each choice's `.anchor` is the key of a named group in the
   page camera's scene (lowercased, `_` becomes `-`). The runtime registers
   anchors and locations as objects; nothing else to declare.
5. **Offer only what is possible.** Use checks and `.requires`/`.excludes` so a
   page never offers an option that cannot happen; there are no "you can't"
   pages.
6. **Art.** Every page shows one whole picture: the painting
   `illustrations/<camera>.png` when it exists, otherwise the camera's render,
   so the book is readable before painting. A changed state is another camera.
7. **Tests.** Add `tests/test_<name>.py` using `tests/headless_book.py`, as
   `tests/test_lighthouse.py` does: explore every choice from the start
   (keying explored pages by the pages already seen, because hidden facts
   depend on history), check that every camera is reached and every ending
   appears, and test the fact-dependent routes and "try again" explicitly. Tap
   the published Continue and retry buttons. `make check` runs
   `tests/test_<name>.py` for the selected `BOOK`.
8. **Walkthrough.** Write `WALKTHROUGH.md` with the golden path, each ending
   and the alternatives, as the reader would choose them.
9. **Read it.** Build and read the book headless, one choice at a time:

   ```sh
   make BOOK=<name>
   printf ':continue\n:continue\n' | build/<name>/book --root . --book <name> --headless
   ```

   Each output line is one page as JSON (kind, ending, text, choices,
   hotspots, controls, text region). A choice's `command` is its target page
   id, so a test can type `harbour` to take the choice that leads there.
10. **Text fits its zone.** In each page's `text_region`, `content_height` must
    not exceed `height`, and `font_size` must equal `preferred_size`. A smaller
    font means the text was shrunk to fit: shorten the passage or enlarge the
    camera's `textRect`.
11. **Checks.** Run `make check BOOK=<name>`, then `make check-ui BOOK=<name>`,
    and inspect a smoke capture:

    ```sh
    build/<name>/book --root . --book <name> --smoke --screenshot /tmp/page.ppm
    ```

## Outputs

- `books/<name>.c`, `WALKTHROUGH.md`, tests

## Acceptance checks

- The book starts: `src/story.c` validates the table at launch (unique ids,
  existing targets, choices with anchors, checks with facts, endings with a
  kind) and stops with a message naming the page otherwise.
- `make check` and `make check-ui` pass.
- Every page and every ending from `STORY_MAP.md` is reached in the test, with
  the text from `TEXT.md`.
- Every decision-page choice has a visible circle on its anchor with a
  readable caption, and no circle or caption overlaps the page text.
- Every page's text fits its zone at its preferred size.
- Every fact is set once and changes something later.
