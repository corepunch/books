# Stage 10 — Review

Check the finished book from four independent points of view, then fix what
they find. Keep the evidence for each kind of finding separate.

## Inputs

- The built book with its current art (reference renders or paintings)
- `DESIGN.md` and the `work/` documents

## Required actions

1. **Technical pass.** Run `make check BOOK=<name>` and
   `make check-ui BOOK=<name>`, and confirm the Scener scene loads without
   warnings. Read every route in `WALKTHROUGH.md` headless. Record any failed
   check, missing page, broken choice, anchor off-screen, or text overflowing
   its zone.
2. **Blind read-through.** A reader who has not seen the design documents
   reads the book from the first page, in the app or headless, using only
   what a real reader sees: pictures, page text and choice labels. Record
   where they got confused, where a choice felt meaningless, where they could
   not tell where they were or what they were trying to do, and whether they
   reached an ending. Freeze these notes before reading the design.
3. **Artistic pass.** Compare the experience with `DESIGN.md`:
   - does the opening pose a clear question, and does the ending answer it;
   - do the pages alternate discovery, action and rest, with rising stakes;
   - are the funny, beautiful and warm moments present;
   - do choices express the hero and the world rather than acting as locks;
   - does the world stay consistent from page to page;
   - does the ending recall specific discoveries and feel earned.

   Classify each finding as a defect, a risk, a deliberate choice, or an
   opportunity.
4. **Audience pass.** Read the book as the declared audience: a child reading
   alone, and an adult reading aloud to a child. Check vocabulary, sentence
   length, how frightening pages are, whether choices can be made from the
   picture and text alone, and whether a young reader can find the circles
   and the Continue button.
5. **Fix and confirm.** Fix defects in the stage that owns them (story map,
   room bible, shots, text, blockout, code or painting), then rerun the
   affected pass. Record decisions for findings you deliberately keep.

## Output

`work/REVIEW.md` with one section per pass, each finding with evidence (page,
camera, text, what happened), its classification, and its resolution, ending
with `READY`, `READY WITH RISKS` or `REVISE`.

## Acceptance checks

- All four passes ran, and the blind read was done before its reader saw the
  design.
- Every defect is fixed, or kept with a recorded decision.
- `make check` and `make check-ui` pass after the last change.
- The book reaches every ending through choices a reader could understand.
