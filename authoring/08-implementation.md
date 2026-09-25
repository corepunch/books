# Stage 8 — Implementation

Encode pages, choices and facts in the book's C file, then read the whole
book through the headless interface.

## Inputs

- `work/STORY_MAP.md`, `work/TEXT.md`, `work/SHOTS.md`
- The blockout from stage 7
- Repository `README.md` ("Extending the adventure") and `AGENTS.md`
- [CHOICES.md](CHOICES.md) (implementing an option)

## Required actions

1. **Source file.** Create `books/<name>.c`, with `book_name()` returning
   `<name>`. Use the engine interface in `src/book.h` and the page
   constructors described in the repository `README.md`.
2. **Locations and objects.** Register each location and each chosen thing
   (story objects and route anchors) with `set_object()`. Object keys must
   match the anchor group names in the scene (lowercased, `_` becomes `-`).
3. **Facts.** Keep story state as named facts (`FOUND_BRASS_STAR`), set by
   the page that establishes them and checked by later pages. There is no
   inventory structure and no inventory command.
4. **Pages.** Build room pages in `show_room()` with the text and camera for
   the current facts, beat pages with `show_beat()`, and endings with
   `finish_story()`. Offer only possible choices; never publish a "you can't"
   page.
5. **Choices.** Append complete choices with `append_choice(object_choice(…))`
   using the labels from `TEXT.md`, and handle each in `perform()`.
6. **Art.** Every page shows one whole picture: the painting
   `illustrations/<camera>.png` when it exists, otherwise the camera's render,
   so the book is readable before painting. Never draw objects on top of a
   page picture; a changed state is another camera.
7. **Tests.** Add `tests/test_<name>.py`, modelled on `tests/test_book.py`, that
   walks the golden path and every alternative route, taps the published
   Continue control, and reaches every ending. Make `make check` run the test
   for the selected `BOOK` (it currently runs the Three Stars test).
8. **Walkthrough.** Write `WALKTHROUGH.md` with the golden path and the
   alternatives, as the reader would choose them.
9. **Read it.** Build and read the book headless, one choice at a time:

   ```sh
   make BOOK=<name>
   printf ':choose 0\n:continue\n' | build/<name>/book --root . --book <name> --headless
   ```

   Each output line is one page as JSON (kind, text, choices, hotspots, text
   region). Check every page's text, choices and hotspots against `TEXT.md`
   and `SHOTS.md`.
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

- `make check` and `make check-ui` pass.
- Every page from `STORY_MAP.md` appears in a headless read, with the text
  from `TEXT.md`.
- Every room-page choice has a visible circle on its anchor with a readable
  caption, and no circle or caption overlaps the page text.
- Every page's text fits its zone at its preferred size.
- Every fact is set once and changes something later.
- No code path exposes an inventory or a failure message.
