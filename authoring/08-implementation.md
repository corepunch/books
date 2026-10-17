# Stage 8 — Implementation

Write the book as XML, one file per location, then read the whole book with
the book tool and the headless interface. The format follows the Virtual
Cinema database of *The X-Files Game*; [XML.md](XML.md) is its reference. The
engine reads the XML at launch (`src/storyxml.c`); its story runtime
(`src/story.c`) validates the story, keeps its state, runs triggers and
actions, publishes pages and handles Continue and "try again". The book files
are data.

## Inputs

- `work/STORY_MAP.md`, `work/TEXT.md`, `work/SHOTS.md`
- The blockout from stage 7
- [XML.md](XML.md), the repository `README.md` ("Extending the adventure",
  "The book tool") and `AGENTS.md`
- [CHOICES.md](CHOICES.md) (implementing an option)
- The examples: [books/salt/](../books/salt/) (`title.xml`, `locations/`) and
  [tests/fixture/](../tests/fixture/), which uses every feature once

## Required actions

1. **The title.** Create `books/<name>/title.xml`:

   ```xml
   <title name="<name>" start="first-page" continue="Дальше"
          retry="Попробовать снова" restart="Начать сначала">
     <variable id="followed-seal">what this fact remembers</variable>
     <variable id="day" type="int" initial="1">the day of the investigation</variable>
     <character id="ferryman" name="Перевозчик">who he is</character>
     <inventory id="lantern" name="Фонарь" where="cellar">what it is</inventory>
     <node id="act-1" name="Act 1">
       <location id="harbour"/>
       <location id="cellar"/>
     </node>
   </title>
   ```

   The name is `<name>` and selects `books/<name>/`. Add `fmv="true"` for a
   book whose pictures are the pages. Nodes are chapters; list every location
   in exactly one, in reading order.
2. **Locations and pages.** One `books/<name>/locations/<location>.xml` per
   listed location, `<location id="<location>">`, holding its pages from
   `STORY_MAP.md`. Page ids are unique across the book.
   - `<view id camera>`: `<text>`, then up to eight circles: `<nav label
     anchor target>` to go somewhere, `<explorable>` to look at or use
     something, and a `<charview>` for a person. Views one spot faces in turn
     share a `<viewpoint>` and turn with `<nav edge="left|right">`.
   - `<charview id character camera>`: `<text>`, then `<conversation>` lines,
     one `ends="true"` line per icon the reader may hold there. A line with
     prose or a clip plays its reply and returns.
   - `<asset id camera next>` with its prose as the element's text: a shot, or
     with `read="true"` a document.
   - `<ending id camera kind>` with `kind` `success`, `partial` or `failure`.
     A failure or partial ending retries from the reader's last view; set
     `retry` to name an earlier one instead. The success ending restarts the
     book.
   - `<actionlist id>`: invisible; `<if test>…</if><else>…</else>` and
     `<goto target>` decide where the reader goes. Use it for "Did you…? If
     so, go to page 50" and for page variants that depend on the past.
   Consecutive pages of one moment may share a camera. Unknown elements,
   attributes, names and targets stop the book with their file and line.
3. **State.** Declare each variable once in `title.xml` with what it
   remembers. A page sets booleans with `sets="a b"` when shown; `<trigger
   event="enter">` and actions inside a choice do anything else (`<set var
   add>`, `<enable>`, `<give>`). A choice is limited with `if`. Keep state
   small; the path itself is memory. Icons the reader carries are declared
   beside the variables; see [THINGS.md](THINGS.md).
4. **Anchors.** Each choice's `anchor` is the key of a named group in the
   page camera's scene (lowercased, `_` becomes `-`). The runtime registers
   anchors and locations as objects; nothing else to declare.
5. **Offer only what is possible.** Use action lists, `if` and enable flags so a
   page never offers an option that cannot happen; there are no "you can't"
   pages.
6. **Art.** Every page shows one whole picture: the painting
   `illustrations/<camera>.png` when it exists, otherwise the camera's render,
   so the book is readable before painting. A changed state is another camera.
7. **Tests.** Add `tests/test_<name>.py` using `tests/headless_book.py`, as
   `tests/test_countdown.py` does: explore every choice from the start
   (keying explored pages by the pages already seen, because hidden facts
   depend on history), check that every camera is reached and every ending
   appears, and test the fact-dependent routes and "try again" explicitly. Tap
   the published Continue and retry buttons. `make check` runs
   `tests/test_<name>.py` for the selected `BOOK`.
8. **Walkthrough.** Write `WALKTHROUGH.md` with the golden path, each ending
   and the alternatives, as the reader would choose them.
9. **Read it.** Check and read the book with the book tool, then headless,
   one choice at a time:

   ```sh
   make cli BOOK=<name>
   build/cli/book check <name>
   build/cli/book graph <name>
   build/cli/book play <name> continue harbour
   make BOOK=<name>
   printf ':continue\n:continue\n' | build/<name>/book --root . --book <name> --headless
   ```

   `graph` lists every route and what goes nowhere: unreachable pages, pages
   with no way to an ending, facts set but never tested. `stats` shows the
   shape of each place; `query <name> NAME` shows every use of a page, fact,
   thing, camera, clip or anchor. Each headless output line is one page as
   JSON (kind, ending, text, choices, hotspots, controls, text region). A
   choice's `command` is its target page id, so a test can type `harbour` to
   take the choice that leads there.
10. **Text fits its zones.** In every entry of `text_regions`, `content_height`
    must not exceed `height`. Type keeps its authored size. Compose the complete
    passage across `textRect` and optional `textRect2`, separated by `<region/>`;
    revise the composition or wording if it overflows. Check Mac and landscape
    iPad sizes with `--viewport W H`, including 1133 × 744 for the wider crop.
    Both prose regions must clear every circle, caption and Continue button.
11. **Checks.** Run `make check BOOK=<name>`, then `make check-ui BOOK=<name>`,
    and inspect a smoke capture:

    ```sh
    build/<name>/book --root . --book <name> --smoke --screenshot /tmp/page.ppm
    ```

## Outputs

- `books/<name>/title.xml`, `books/<name>/locations/*.xml`, `WALKTHROUGH.md`, tests

## Acceptance checks

- The book starts: the loader and `src/story.c` validate it at launch (unique
  ids, known names, existing targets, choices with anchors, checks with facts,
  endings with a kind) and stop with a message naming the page otherwise.
- `build/cli/book check <name>` passes, and `graph` reports no finding the
  story does not intend.
- `make check` and `make check-ui` pass.
- Every page and every ending from `STORY_MAP.md` is reached in the test, with
  the text from `TEXT.md`.
- Every decision-page choice has a visible circle on its anchor with a
  readable caption, and no circle or caption overlaps the page text. A talk
  decision uses lines in the bottom band instead; the end line is last.
- Every page's text fits its zone at its preferred size.
- Every fact is set once and changes something later.
