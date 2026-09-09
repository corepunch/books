# THE LAST TOYMAKER'S APPRENTICE
### A Game Design Premise

**Genre:** Text/parser adventure (interactive fiction), all-ages
**Tone reference:** *Toy Story* meets *Up* meets *Planetfall* — whimsical opening, bittersweet middle, earned joy at the end
**Structural reference:** Infocom's mature 3-act formula (as seen in *Deadline*, *Suspended*, and especially *Planetfall*), where Act 1 teaches through comedy, Act 2 raises the emotional and mechanical stakes, and Act 3 pays off everything you learned

---

## PREMISE

You are **Pip**, a tiny workshop gnome apprentice — no taller than a teacup — who works for Grandfather Tolliver, the last toymaker in the town of **Wrenfold**. Every night after the shop closes, the toys wake up. Pip's job is small and simple: oil the joints, sweep the sawdust, keep the workshop running before dawn.

Tonight, Grandfather Tolliver doesn't come down to lock up. His workshop key — the only thing that keeps the shop's magic wound — has stopped ticking on its hook. Without it, the toys will fall silent by sunrise, one by one, forever.

Pip has one night to find out what happened to the toymaker and rewind the town's heart before the clock runs out.

---

## ACT 1 — "The Nightly Rounds" (comedic, low-stakes, teaches the verbs)

Structurally, this act mirrors *Zork*'s house or *Planetfall*'s Kalamontee — a contained, richly-described space where every room is a joke and a tutorial at once. The player learns to **WIND**, **OIL**, **LISTEN**, and **EXAMINE**, and meets the shop's cast:

- **Bertrand**, a pompous nutcracker who insists he outranks Pip and refuses to help unless addressed "properly" (a light social puzzle — flattery as a mechanic, à la *Hitchhiker's Guide*'s Babel fish sequence).
- **Old Tick**, a cuckoo clock who only speaks in riddles on the hour, forcing the player to manage real-time waiting the way *Deadline* forces attention to a ticking schedule.
- **Marzipan**, a one-eyed rag doll who is secretly the smartest character in the shop and drops the real plot information, disguised as nonsense songs.

By the act's end, a comic red herring (a "haunted" music box) resolves into the actual inciting incident: Grandfather Tolliver's key is missing, and muddy little footprints — not toy-sized — lead out the workshop door into the snow.

---

## ACT 2 — "Wrenfold By Night" (the Pixar turn: stakes, sadness, a real NPC)

This is where the game earns the comparison to Infocom's *later* work rather than its earlier one — the moment the story stops being cute and starts being *about* something.

Pip leaves the shop and discovers the whole town is toys — every streetlamp, mailbox, and shopfront was once a child's plaything, discarded and left to wind down slowly for decades. **Grandfather Tolliver was the last person who still repaired them.** The footprints belong to **Nutmeg**, a fox-shaped toy who has been alone in the cold so long she no longer believes she was ever loved by anyone, and who took the key out of jealousy — she wanted just one more night of being *fixed*, of mattering to somebody.

Nutmeg is this game's **Floyd** — the emotionally complex companion (drawing directly on *Planetfall*'s design): she is funny, then heartbreaking, has her own agenda, can be genuinely helped or genuinely alienated depending on how the player treats her, and her arc — not the plot mechanics — is the emotional spine of the game. Critically, like Floyd, **she is not simply a walking hint dispenser**: she refuses to help at several points, tests the player's patience, and the "correct" solution to more than one puzzle is *kindness with no immediate reward*, which the game must not signal mechanically — the player has to choose it without being told it's the right choice.

Puzzles in this act use Infocom's mid-game staples:
- A **locked door only Nutmeg's small fox-shape can enter**, requiring the player to have earned her trust in Act 1's echo (a callback puzzle).
- A **weight/inventory puzzle**: Pip can only carry a few tools across the frozen square before winding down himself, forcing hard choices about what matters.
- A **misdirection puzzle**: the obvious villain (a scrap-metal junk-collector cart that's been "eating" broken toys all along) turns out to be trying to *save* them, salvaging parts to keep others running — recontextualizing an earlier "threat" the same way *Suspended* recontextualizes its own robots.

Act 2 ends at the town's frozen fountain, where Nutmeg finally admits why she took the key, and Pip realizes: it isn't the key that's magic. It's Grandfather Tolliver's habit of noticing which toy needs fixing next. That's not a thing you can rewind. It's a thing you have to *choose to keep doing*.

---

## ACT 3 — "What the Clockwork Remembers" (resolution, real-time climax, earned ending)

A ticking climax in the Infocom mold (*Deadline*'s countdown, *Starcross*'s escape sequence): dawn is coming in real, counted turns. The key alone can't restart the town — Pip must decide, with limited time, which toys to personally rewind by hand (echoing the weight-limit choices from Act 2), knowing not everyone can be saved before sunrise.

The final puzzle isn't combat or a lock — it's a **choice with no single correct object-flag solution**, evaluated on what the player has done throughout the game: whether they were patient with Bertrand, whether they let Old Tick finish his riddles, whether they treated Nutmeg with care when it cost them nothing in-game to be cruel instead. This produces branching but thematically consistent endings — Grandfather Tolliver returns and finds a shop kept alive not by magic, but by an apprentice who learned to notice.

---

## DESIGN NOTES

- **Complex NPC done right:** Nutmeg needs her own internal clock/schedule (like Floyd), independent of player input, so the world feels inhabited rather than staged.
- **Puzzles as character, not just as locks:** every mechanical puzzle should double as an emotional beat, the way *Planetfall*'s survival puzzles are inseparable from Floyd's companionship.
- **Fair-but-hard, never cruel:** in the Infocom tradition, red herrings are allowed, but no puzzle should be solvable only by trial-and-death; children need to feel clever, not punished.
- **Feelies-equivalent:** a small paper "workshop repair manual" as physical/PDF packaging, styled like a child's picture book, seeding vocabulary and lore without in-game exposition dumps.

Given your existing ZIL-to-Lua VM work, this could realistically be prototyped in ZIL directly and run through your own transpiler — which would be a fitting way to build a children's Infocom homage.
