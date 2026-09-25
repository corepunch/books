# Writing an illustrated adventure book

These stages turn a premise into a finished illustrated gamebook for this
engine: a picture book where the reader chooses what happens next, in the
tradition of the Zork books (*The Forces of Krill*) and Choose Your Own
Adventure. It is not a parser game. The reader never types, never sees a
transcript, and never manages an inventory. Each page is one illustration, one
short passage of story text, and two or three choices.

Run the stages in order, one at a time. Each stage file lists its inputs,
required actions, outputs and acceptance checks. Do not start a stage until the
previous stage's acceptance checks pass. When a later stage exposes a problem
in an earlier artifact, fix that artifact first and record the change there.

| Stage | File | Produces |
|---|---|---|
| 1 | [01-premise.md](01-premise.md) | `books/<name>/DESIGN.md` |
| 2 | [02-story-map.md](02-story-map.md) | `work/STORY_MAP.md` |
| 3 | [03-room-bible.md](03-room-bible.md) | `work/ROOMS.md` |
| 4 | [04-characters.md](04-characters.md) | `work/CHARACTERS.md` |
| 5 | [05-shot-list.md](05-shot-list.md) | `work/SHOTS.md` |
| 6 | [06-page-text.md](06-page-text.md) | `work/TEXT.md` |
| 7 | [07-blockout.md](07-blockout.md) | `rooms/*.blks`, `rooms/prefabs/`, reference JPEGs |
| 8 | [08-implementation.md](08-implementation.md) | `books/<name>.c`, `WALKTHROUGH.md`, tests |
| 9 | [09-illustration.md](09-illustration.md) | `work/ILLUSTRATION.md`, finished PNGs |
| 10 | [10-review.md](10-review.md) | `work/REVIEW.md`, fixes |

Paths are relative to `books/<name>/` unless they start with `books/`.

## What makes these books work

- **A picture book on the surface, a world underneath.** Each page reads like
  a picture-book spread: the illustration carries the concrete scene, and the
  text tells the story beat. Underneath is a consistent place: rooms with
  fixed geography, furniture that stays put, routes that make physical sense.
- **Choices are decisions, not verbs.** "Follow the music" or "Hide under the
  table" is a choice. "Take lamp" is not. Every choice should change where the
  story goes, what the hero learns, or how a later page reads.
- **No inventory.** The book remembers a few story facts, such as "Juranda
  found the bronze key", and later pages check them. *The Forces of Krill*
  has 128 pages and asks about only two remembered items. Show what the hero
  carries in the pictures and the text, never as a list.
- **One world, many cameras.** Every page is a camera in one 3D blockout of
  the location. The blockout fixes perspective, scale, lighting and continuity
  before anyone paints.
- **It must make sense.** Every object has a support and a reason to be there,
  and every route uses things a resident would own. See Scener's
  `skills/populate-simplegl-scenes/references/world-logic.md`.

## Book folder

```text
books/<name>.c                  story state, pages, choices, prose
books/<name>/
├── DESIGN.md                   premise, tone, audience, structure (stage 1)
├── WALKTHROUGH.md              golden path and alternate routes (stage 8)
├── work/
│   ├── STORY_MAP.md            locations, page graph, facts (stage 2)
│   ├── ROOMS.md                room bible for modelling and painting (stage 3)
│   ├── CHARACTERS.md           character sheets and poses (stage 4)
│   ├── SHOTS.md                one camera per page (stage 5)
│   ├── TEXT.md                 page text and choice labels (stage 6)
│   ├── ILLUSTRATION.md         painting briefs (stage 9)
│   └── REVIEW.md               review findings and decisions (stage 10)
├── rooms/
│   ├── <scene>.blks            Scener scene: geometry, cameras, anchors
│   ├── prefabs/                furniture, props and character skeletons
│   └── <camera>.jpg            reference renders, one per camera
└── illustrations/              finished PNG pages and item layers (local)
```

## Rules for every stage

1. Write in the book's language for anything the reader sees; keep working
   notes in English unless the book's documents already use another language.
2. Never invent a mechanic the engine lacks. The engine has room pages with
   choices, intermediate beat pages with Continue, and ending pages. Story
   state lives in the book's C file.
3. Keep one source of truth for each fact. Geography and dimensions live in
   `ROOMS.md` and the `.blks` scene; page wording lives in `TEXT.md` and the C
   file; cameras live in `SHOTS.md` and the `.blks` scene. When they disagree,
   fix the source you did not intend to change.
4. Read a complete stage file before starting it, and re-read the acceptance
   checks before declaring it done.
5. Play what you build. After stage 8, read the book through the headless
   interface after every change (see [08-implementation.md](08-implementation.md)).
