# Stage 8 — Implementation

Encode pages, choices and facts in the book's C file, then read the whole
book through the headless interface.

## Inputs

- `work/STORY_MAP.md`, `work/TEXT.md`, `work/SHOTS.md`
- The blockout from stage 7
- Repository `README.md` ("Extending the adventure") and `AGENTS.md`

## Required actions

1. **Source file.** Create `books/<name>.c`, with `book_name()` returning
   `<name>`. Use `books/three-stars.c` as the template.
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
6. **Art fallback.** Room pages show a painted plate plus item layer when both
   exist, and otherwise the camera's own render, so the book is readable
   before painting.
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
10. **Checks.** Run `make check BOOK=<name>`, then `make check-ui BOOK=<name>`,
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
- Every room-page choice has a visible circle on its anchor, and no circle
  overlaps the page text.
- Every fact is set once and changes something later.
- No code path exposes an inventory or a failure message.
