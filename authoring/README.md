# Writing an illustrated adventure book

These stages turn a premise into a finished illustrated gamebook for this
engine: a picture book where the reader chooses what happens next, in the
tradition of the Zork books (*The Forces of Krill*) and Choose Your Own
Adventure. It is not a parser game. The reader never types, never sees a
transcript, and never manages an inventory. Each page is one illustration, one
short passage of story text, and either two or three choices or a Continue
button.

Read [CRAFT.md](CRAFT.md) first: it explains what makes these books
interesting. Then run the stages in order, one at a time. Each stage file lists
its inputs, required actions, outputs and acceptance checks. Do not start a
stage until the previous stage's acceptance checks pass. When a later stage
exposes a problem in an earlier artifact, fix that artifact first and record
the change there.

| Stage | File | Produces |
|---|---|---|
| — | [CRAFT.md](CRAFT.md) | Principles and checklist used by every stage |
| 1 | [01-premise.md](01-premise.md) | `DESIGN.md` |
| 2 | [02-story-map.md](02-story-map.md) | `work/STORY_MAP.md` |
| 3 | [03-room-bible.md](03-room-bible.md) | `work/ROOMS.md` |
| 4 | [04-characters.md](04-characters.md) | `work/CHARACTERS.md` |
| 5 | [05-shot-list.md](05-shot-list.md) | `work/SHOTS.md` |
| 6 | [06-page-text.md](06-page-text.md) | `work/TEXT.md` |
| 7 | [07-blockout.md](07-blockout.md) | Scener scene, prefabs, reference renders, model sheets, plan view |
| 8 | [08-implementation.md](08-implementation.md) | `books/<name>.c`, `WALKTHROUGH.md`, tests |
| 9 | [09-illustration.md](09-illustration.md) | `work/ILLUSTRATION.md`, sheets, key art, painted pages, item layers |
| 10 | [10-packaging.md](10-packaging.md) | `package/`: title, synopsis, cover, metadata, map, parent notes |
| 11 | [11-review.md](11-review.md) | `work/REVIEW.md`, fixes |

Paths are relative to `books/<name>/` unless they start with `books/` or
`tools/`.

## What makes these books work

- **A picture book on the surface, a world underneath.** The illustration
  carries the concrete scene and the text tells the story beat. Underneath is
  a consistent place: fixed geography, furniture that stays put, routes that
  make physical sense.
- **Challenges the reader can solve.** The answer is always in the world
  before the choice: in a picture, in the text, in what a character said.
- **Choices are decisions, not verbs.** "Follow the music" or "Hide under the
  table" is a choice. "Take lamp" is not.
- **No inventory.** The book remembers a few story facts, such as "Juranda
  found the bronze key", and later pages check them. *The Forces of Krill*
  has 128 pages and asks about only two remembered items. Show what the hero
  carries in the pictures and the text, never as a list.
- **One world, many cameras.** Every page is a camera in one 3D blockout. The
  blockout fixes perspective, scale, layout and light so that paintings stay
  consistent; the paintings bring the art.
- **It must make sense.** Every object has a support and a reason to be there,
  and every route uses things a resident would own. See Scener's
  `skills/populate-simplegl-scenes/references/world-logic.md`.

## Book folder

```text
books/<name>.c                   story facts, pages, choices, prose
books/<name>/
├── DESIGN.md                    stage 1
├── WALKTHROUGH.md               stage 8
├── work/
│   ├── STORY_MAP.md             stage 2
│   ├── ROOMS.md                 stage 3 (room bible)
│   ├── CHARACTERS.md            stage 4
│   ├── SHOTS.md                 stage 5
│   ├── TEXT.md                  stage 6
│   ├── ILLUSTRATION.md          stage 9
│   └── REVIEW.md                stage 11
├── rooms/
│   ├── <scene>.blks             geometry, lights, page cameras, anchors
│   ├── model-sheet.blks         character turnarounds and object close-ups
│   ├── prefabs/                 furniture, props, character skeletons
│   ├── <camera>.jpg             reference renders
│   └── layout.jpg               plan view (make layout)
├── package/                     stage 10
│   ├── TITLE.md  SYNOPSIS.md  METADATA.md  PARENT_NOTES.md
└── illustrations/               local, not in git
    ├── <camera>.png             painted pages and room plates
    ├── cover.png, map and extras
    ├── sheets/                  model sheets, object sheets, key art
    └── items/
        ├── polygons.json        outlines of collectible objects
        ├── <object>-<camera>.png
        ├── crops/  rects.json   produced by tools/extract_items.swift
```

## Deliverables

A finished book has all of these:

- **Story:** `DESIGN.md`, `STORY_MAP.md`, `TEXT.md`, `books/<name>.c`,
  `WALKTHROUGH.md`, tests that reach every ending.
- **World:** `ROOMS.md` (with the painted-detail registry), `CHARACTERS.md`,
  `SHOTS.md` (with the colour script).
- **Blockout:** Scener scene(s) loading without warnings, prefabs, bone
  characters and poses, one render per camera, model-sheet renders, plan view.
- **Art:** style bible and page briefs in `ILLUSTRATION.md`, character and
  object sheets, key art per location, one painted page per camera, room
  plates with item layers, the cover.
- **Package:** title and tagline, synopsis, metadata, map, parent notes,
  optional in-world extras.
- **Review:** `REVIEW.md` ending in `READY` or `READY WITH RISKS`.

## Engine facts every stage relies on

- Page kinds: room pages (choices shown as circles on the picture), beat pages
  (one Continue button) and ending pages. State lives in the book's C file as
  named facts.
- Pages are 4:3 images. The app window is 11:8 on Mac, so about 3 % is
  cropped from the top and bottom; keep essential content 5 % inside every
  edge.
- Choice circles are 48 px across on an 1100 × 800 page, need at least a
  radius of clear space, and appear on named anchors in the scene.
- Page text sits in each camera's `textRect` at base size 36 px scaled by
  `textScale`; the headless `text_region` reports whether it fits.
- Room pages fall back to the camera's render until a painted plate and its
  item layer exist, so a book is readable before painting.

## Rules for every stage

1. Write in the book's language for anything the reader sees; keep working
   notes in English unless the book's documents already use another language.
2. Never invent a mechanic the engine lacks. Sound, timers, dice, typing and
   inventories do not exist here.
3. Keep one source of truth for each fact. Geography and dimensions live in
   `ROOMS.md` and the scene; wording lives in `TEXT.md` and the C file;
   cameras live in `SHOTS.md` and the scene. When they disagree, fix the
   source you did not intend to change.
4. Read a complete stage file before starting it, and re-read the acceptance
   checks before declaring it done.
5. Read what you build. From stage 8 on, read the book through the headless
   interface after every change.
