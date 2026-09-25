# Stage 10 — Packaging and companion materials

Prepare everything around the pages: how the book presents itself, and the
extras that make it bigger than the screen, like Infocom's maps and letters.

## Inputs

- The finished book from stages 1–9
- `DESIGN.md`, `work/STORY_MAP.md`, the plan view from stage 7
- [CRAFT.md](CRAFT.md) §10, §13

## Required actions

1. **Title and tagline.** The title, and one line that sells the high
   concept without spoilers.
2. **Synopsis.** A back-cover paragraph: hero, goal, the first obstacle and
   the promise of choices, in the book's language and tone. No spoilers past
   the opening.
3. **Cover.** A cover shot in the blockout: a `cover` camera with the hero and
   the book's main landmark, room reserved for the title. Render it with the
   other cameras, then paint it after the location key art, matching the
   style bible.
4. **Metadata.** Audience age, reading level, typical reading time, number of
   pages and endings, language, content notes (mild peril, darkness), and
   credits (writing, blockout, painting).
5. **Map.** From the stage 7 plan view, a reader-facing map of the locations
   with the landmarks named as in the text, drawn in the book's style. Mark
   only what the opening page already reveals, or provide a blank map for
   the reader to fill in.
6. **Parent notes.** For an adult reading aloud: for each challenge, three
   hints that climb gently (what to notice, where to look, what to try), plus
   two or three questions to talk about after reading. Keep them on separate
   pages so a child reading alone is not spoiled.
7. **In-world extras (optional).** Artefacts from the story that deepen it or
   serve as hints: grandmother's letter, the owl's note, a page of the star
   map. Each must match `ROOMS.md` and the painted detail registry.
8. **Sequel hook (optional).** If the book is part of a series, note where the
   ending points and where the next book begins.

## Outputs

`package/` in the book folder:

- `TITLE.md` (title and tagline), `SYNOPSIS.md`, `METADATA.md`
- `PARENT_NOTES.md`
- `cover` camera in the scene, its render and the painted cover
  `illustrations/cover.png`
- the map and any extras (images in `illustrations/`, sources in `package/`)

## Acceptance checks

- The tagline and synopsis are spoiler-free and match the book's tone.
- The cover shows the hero and a landmark, with room for the title.
- Metadata states the audience and content notes accurately.
- The map's names match the page text.
- Every challenge has three rising parent hints, kept apart from the book.
