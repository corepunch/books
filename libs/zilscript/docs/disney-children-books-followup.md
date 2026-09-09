# Disney Children's Books Follow-Up

Date: 2026-08-01

## Goal

Use Disney children's books as a writing model for our own children's-book work, with two output modes in mind:

1. Illustrated versions, where the art carries most of the scene-setting.
2. Text-only versions, closer to Zork, where prose has to carry the room, action, and player-facing meaning.

I focused on official publisher pages and lawful publisher-provided companion material. I did not download full copyrighted books: the titles below are commercial editions and no full public edition or publisher excerpt was available to verify their complete prose. Claims about page count, age range, format, and stated features are therefore catalog facts; conclusions about the downloadable activity pack come from direct inspection.

## Exact Source Material Checked

| Material | What was checked | What it establishes |
| --- | --- | --- |
| [Moana Activity Sheets](research-source-material/moana-activity-sheets.pdf) | Official nine-page PDF linked by Disney beside the `Moana Read-Along Storybook & CD` page. Downloaded 2026-08-01; SHA-256 `b9267afba9c30f5a844657f1f46163607962e2ebbcdc852df19b3b94af373069`. | Disney uses a single sentence to set up a pictured scene, then turns scene knowledge into coloring, hidden-object, maze, line-following, and jigsaw activities. It is a companion pack, not the book's complete text. |
| [Moana Read-Along Storybook & CD](https://books.disney.com/book/moana-read-along-storybook-cd/) | Official Disney catalog record. | Exact edition: 32 pages, ISBN `9781484743614`, ages 6-8. |
| [Disney's Movie Night Read-Along Storybook and CD Collection](https://books.disney.com/book/disneys-movie-night-read-along-storybook-and-cd-collection/) | Official Disney catalog record. | Exact format claim: the three stories, including Moana, use word-for-word narration, character voices, and sound effects. |
| [Moana: The Junior Novelization](https://www.penguinrandomhouse.com/books/534904/moana-the-junior-novelization-disney-moana-by-rh-disney/) | Official publisher catalog record. | Exact edition: 144 pages, ISBN `9780736436007`, complete-film retelling, eight pages of full-color film scenes. |
| [5-Minute Moana Stories](https://books.disney.com/book/5-minute-moana-stories/) | Official Disney catalog record. | Exact edition: 208 pages, ISBN `9781368081689`, twelve original short stories designed for five-minute read-aloud sessions, ages 3-5. |

### What the downloadable pack adds

The activity PDF makes the illustrated-to-interactive link more concrete than catalog information alone:

- A brief caption tells the child whose moment this is and what changes.
- The image supplies identity, setting, pose, objects, and emotional reading.
- Activities turn recognition into action: find an object, trace the right route, choose the correct puzzle piece, or color a character.

For a child-friendly text adventure, preserve that sequence even when there is no illustration:

1. State the immediate situation in one short sentence.
2. Name the two or three visible, usable things.
3. Offer a goal that can be understood before the child types.
4. Let the action produce an obvious consequence.

Example of the shape, not Disney text: `The little boat is drifting toward the rocks. A paddle and a coil of rope lie beside you. How will you steer it?`

## What The Disney Material Shows

Disney publishes at least two clearly different children's-book patterns:

1. Picture-book/storybook formats for ages roughly 0-7.
2. Junior novelization and chapter-book formats for ages roughly 6-12.
3. Read-along editions, where an illustrated book is paced by narration, character voices, and sound effects.

That split is useful because it maps cleanly to our own design problem:

- Illustrated mode: the picture establishes the space, character look, and background state.
- Text-only mode: the prose has to establish the same information explicitly.

In other words, Disney storybooks behave a lot like a split between a visual adventure and a text adventure. That makes them a good reference point for a Zork-style children's project.

## Research Findings

### 1. Illustrated storybooks are short, direct, and action-led

Examples:

- [We Are Voyagers! (Disney Moana 2)](https://www.penguinrandomhouse.com/books/750205/we-are-voyagers-disney-moana-2-by-rh-disney-illustrated-by-the-disney-storybook-art-team/)
- [The Ocean is Our Friend! (Disney Moana)](https://www.penguinrandomhouse.com/books/812030/the-ocean-is-our-friend-disney-moana-by-rh-disney-illustrated-by-the-disney-storybook-art-team/)
- [Disney Moana Storybook Collection](https://www.penguinrandomhouse.com/books/812028/disney-moana-storybook-collection-by-rh-disney-illustrated-by-the-disney-storybook-art-team/)
- [Sweet and Spooky Halloween (Disney Princess)](https://www.penguinrandomhouse.com/books/141414/sweet-and-spooky-halloween-disney-princess-by-rh-disney/)
- [M Is for Monster](https://www.penguinrandomhouse.com/books/141198/m-is-for-monster-by-disney-book-group-illustrated-by-disney-book-group-disney-book-group/)

What these have in common:

- 24 to 32 page lengths for stand-alone storybooks.
- Age bands around preschool through early elementary.
- Very compact story beats.
- A lot of emotional and physical information is left to the art.
- The text mainly does three jobs: advance the plot, deliver dialogue, and point to the key narrative change on the page.

### 2. Junior novelizations are prose-first, but still keep some visual support

Examples:

- [Moana: The Junior Novelization](https://www.penguinrandomhouse.com/books/534904/moana-the-junior-novelization-disney-moana-by-rh-disney/)
- [Disney/Pixar Luca: The Junior Novelization](https://www.penguinrandomhouse.com/books/668146/disneypixar-luca-the-junior-novelization-disneypixar-luca-by-steve-behling/)
- [Disney Lilo & Stitch: The Junior Novelization](https://www.penguinrandomhouse.com/books/141154/disney-lilo-and-stitch-the-junior-novelization-by-rh-disney/)
- [Disney Moana 2: The Junior Novelization](https://www.penguinrandomhouse.com/books/751327/disney-moana-2-the-junior-novelization-by-elizabeth-rudnick/)

What these have in common:

- Much longer page counts, often around 128 to 144 pages.
- Age bands around 6-12.
- They retell the story in complete prose.
- They usually include a small full-color insert rather than depending on illustrations throughout.

This is the closest Disney gets to a text-dominant mode. For our purposes, it is the useful bridge to a Zork-like experience.

### 3. The same property can exist in both modes

Moana is a good example:

- Picture-book style titles: `We Are Voyagers!`, `The Ocean is Our Friend!`, `Sisters Are Forever!`
- Prose-first title: `Moana: The Junior Novelization`

That matters because it shows the franchise can support both:

- A child who wants visual immersion.
- A reader who wants a story-first, text-first experience.

### 4. Read-along is the useful middle mode

The Moana read-along materials point to a third surface we should consider:

- The book remains visual and compact.
- Narration controls pacing for an adult reading with a child or for independent listening.
- Character voices and sound effects mark emotion and action without adding harder prose.

For our project, this could become an optional `read-aloud` mode: the game reads a short room description, plays a light sound cue, then waits for a choice or command. It should remain fully playable with text alone; audio should support comprehension, not hide required information.

## How To Apply This To Children's Books

### For illustrated versions

Use the art to do the heavy lifting.

- Let the illustration establish location, scale, costume, and mood.
- Keep the text short enough that it does not repeat everything the page already shows.
- Make each spread do one main story job.
- Prefer one clear emotional or narrative turn per page.
- Use sound effects, typographic emphasis, and dialogue sparingly for energy.

Practical writing rule:

- If the image already shows the room, do not spend text describing every object in it.
- If the image already shows the action, use the text for meaning, motive, or consequence.

This is the big Disney lesson: the page should not explain the picture; it should complete it.

### For text-only versions

Treat the story like a compact adventure game.

- Open with a strong setting line.
- Anchor the reader in a place, then move them through a sequence of actions.
- Use concrete nouns and active verbs.
- Repeat important spatial information when it matters for navigation.
- Keep paragraph length short enough for young readers.
- End sections on a decision, a reveal, or a small cliffhanger.

Practical writing rule:

- If there is no image, every important scene detail must be translated into text.
- The text has to replace the picture's job, not just narrate around it.

### Narrative voice: third person by default

For the Disney-style children's-book mode, use a named protagonist and third-person narration by default:

> Milo freezes. Something moves behind the cabinet.

This lets the child control a character without having to pretend that they literally are the character. It also gives illustrations a stable subject: the protagonist can have a recognizable face, clothing, expressions, relationships, and physical actions. The result feels closer to an interactive picture book than to an illustrated terminal transcript.

Do not make grammatical person a universal engine rule. Choose it as part of the book's narrative mode:

| Mode | Feeling | Best fit |
| --- | --- | --- |
| Third person — “Maya opened the door” | Watching and guiding a character | Young children, fairy tales, Disney-like storybooks |
| Second person — “You opened the door” | Being inside the adventure | Self-insertion, superheroes, mysteries, older readers |
| First person — “I opened the door” | A character telling their own story | Diary, confessional, or strongly voiced narrators |

The default for this project should therefore be **third-person named characters**, while the underlying ZIL engine remains capable of supporting other narrative modes.

### Room titles should do the location work

When the interface already displays a room name as a prominent title, do not spend the first sentence repeating that the protagonist is in the same place. Prefer:

```text
ABANDONED WORKSHOP

Alex wipes a finger across the workbench. Under twelve years of dust,
someone has scratched a tiny arrow into the wood.
```

Avoid:

```text
ABANDONED WORKSHOP

Alex is in an abandoned workshop. Dust covers the workbench...
```

The title establishes **where**. The illustration establishes **what it looks like**. The prose should add action, sensory detail, character reaction, change, or a meaningful clue. Repeating the location is acceptable only when it contributes something new, such as: “For once, the Forbidden Forest doesn't look particularly forbidden.”

This is a presentation rule for the storybook surface, not a ban on spatial language. A character may still be described as entering, crossing, hiding in, or returning to a place when that movement matters to the scene.

### What Infocom did — and did not — avoid

The historical comparison is useful, but the answer is not that Infocom solved this completely. Classic Infocom is overwhelmingly second person, not first person, and its room descriptions often use “You are...” or “You stand...” even when the room title has just appeared.

The local source makes the split clear:

- `infocom/zork1/actions.zil`, `WEST-HOUSE`, prints the heading `West of House` through the room description system and then begins the prose, “You are standing in an open field west of a white house...”.
- `infocom/zork2/gverbs.zil`, `DESCRIBE-ROOM`, prints the room's `DESC` first and then emits its `LDESC`. Zork II's room sources contain many corresponding “You are inside...” and “You are standing...” openings.
- Infocom did deliberately separate terse room/object identity from contextual prose. `DESC` is the label used for a room or object; `LDESC`/`FDESC` are authored descriptions. `NDESCBIT` suppresses objects that are already naturally described in room prose, avoiding a second automatic object listing.
- The Zork II routine even contains a commented-out automatic vehicle clarification, `(You are in the <vehicle>.)`, suggesting that the authors were conscious of unnecessary explanatory repetition in at least some cases.

So: yes, the writers cared about repetition and built mechanisms to control it, especially for objects and dynamic descriptions. But the classic room format still optimized for a text-only simulation: the heading identified the location, while the following paragraph re-established the player's physical position and visible geometry. That was functional orientation in a screen with no illustration, not a strict literary rule against duplication.

For our Disney-like surface, the medium is different. A title plus illustration already supplies the orientation that Infocom had to encode in prose. We should keep Infocom's useful separation between labels and descriptions, then go one step further: **never begin a room passage with “You are in [room]” or “Alex is in [room]” unless the sentence changes the meaning.**

### For a Zork-style children's adaptation

This is the most interesting hybrid.

We can treat the world as having two layers:

1. Storybook layer: art-first, short prose, emotional beats.
2. Adventure layer: text-first, interactive, object-focused, puzzle-aware.

Suggested design pattern:

- Each illustrated spread becomes one interactive location or story beat.
- Each location gets a short room description, one or two salient objects, and one action hook.
- The illustrated edition can omit many room details because the image supplies them.
- The text-only edition must spell out those same details in parser-friendly language.

Use the activity-sheet pattern as a rule for early puzzles:

- Make the goal visible before the puzzle begins.
- Put only a few meaningful objects in the scene.
- Use one obvious verb family per goal, such as `find`, `follow`, `match`, `help`, or `steer`.
- Give immediate, concrete feedback for a correct action.
- Do not require the child to know a hidden verb or infer an unseen object.

### Wondertown pattern to preserve: a breadcrumb mystery

The second Wondertown scene, `SNOWY-ALLEY`, works because the fox footprints are a **breadcrumb mystery** (also called a curiosity hook or trail clue): they create an unanswered question, point to a visible next action, and then pay it off with a more meaningful encounter.

The exact sequence is worth reusing:

1. **A trace:** unusual toy-sized fox footprints appear in fresh snow.
2. **A question:** who made them, and why are they leaving the workshop?
3. **A direction:** the trail explicitly leads east, so the player can act without guessing.
4. **A reward:** following it eventually reveals Nutmeg, the patchy fox toy, and turns the missing-key problem into an emotional story.

That is why the scene feels rewarding rather than merely descriptive: the detail is both a story promise and a playable instruction.

Apply this to every early child-facing mystery:

- Show one strange, concrete trace rather than explaining the whole problem.
- Make the first follow-up action obvious.
- Put a small discovery soon after it.
- Let the discovery deepen the question instead of merely confirming it.

### Wondertown opening revision: mystery first, detail on demand

The first room previously introduced several atmospheric details at once: sawdust, the pet door, the clock, the workbench, the empty hook, and the tool bench. The key hook is the strongest opening hook, so the room description now leads with it and names only the two immediate routes. The other details remain examinable through their existing object responses.

Rule for future opening rooms: put only the **mystery, usable landmark, and immediate choice** in `LOOK`; reserve optional texture, history, and secondary objects for `EXAMINE`. This follows the adventure-writing skill's opening-scene rule: one landmark, one visible object, one blocker, and one quick reward.

That means we can write one underlying story bible, then express it in two surfaces:

- `picture-book` surface for younger children and read-aloud mode.
- `text-adventure` surface for older children or Zork-style play.

## Working Rules I Would Use

1. One scene, one job.
2. Never duplicate what the art already says.
3. In text-only mode, always anchor the player in space before asking for action.
4. Use dialogue to deliver character and emotion.
5. Use description to deliver navigation and consequence.
6. Keep the same core plot across both versions, but rewrite the surface language for the medium.

## Recommended Source Set

Best starting points for continued research:

- [Disney Moana Storybook Collection](https://www.penguinrandomhouse.com/books/812028/disney-moana-storybook-collection-by-rh-disney-illustrated-by-the-disney-storybook-art-team/)
- [We Are Voyagers! (Disney Moana 2)](https://www.penguinrandomhouse.com/books/750205/we-are-voyagers-disney-moana-2-by-rh-disney-illustrated-by-the-disney-storybook-art-team/)
- [The Ocean is Our Friend! (Disney Moana)](https://www.penguinrandomhouse.com/books/812030/the-ocean-is-our-friend-disney-moana-by-rh-disney-illustrated-by-the-disney-storybook-art-team/)
- [Moana: The Junior Novelization](https://www.penguinrandomhouse.com/books/534904/moana-the-junior-novelization-disney-moana-by-rh-disney/)
- [Disney Moana 2: The Junior Novelization](https://www.penguinrandomhouse.com/books/751327/disney-moana-2-the-junior-novelization-by-elizabeth-rudnick/)
- [Disney Chapter Book Series overview](https://www.penguinrandomhouse.com/the-read-down/disney-chapter-book-series/)

## Rights and Evidence Boundary

- The downloaded PDF is an official Disney Publishing Worldwide activity sheet. It is retained as research reference material, with the source URL recorded above; it is not an asset to republish, modify, or ship with our project.
- Full Disney storybooks and junior novelizations should be read through purchase, a library loan, or other authorized access before we make claims about their exact wording, scene order, or prose technique.
- Until then, use this document's catalog-derived findings for format decisions only, and use the inspected activity-sheet observations for interaction design.

## Bottom Line

Disney children's books suggest a simple but useful rule:

- Illustrated books let the art describe the scene.
- Text-first books let prose describe the scene.
- A Zork-like children's project should deliberately support both, instead of trying to make one format do the work of the other.
