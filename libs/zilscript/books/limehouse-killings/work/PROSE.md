# The Limehouse Killings - Prose and NPC Bible

## Voice Rules

1. Show mood through observable detail. Use temperature, texture, smell, sound, posture, and object placement instead of words such as “regret,” “dread,” “ominous,” or “calculating.”
2. Keep room text spatial and actionable: usually one to four sentences with one dominant anchor.
3. Every concrete noun that invites action must resolve through an object, global, or `PSEUDO` handler.
4. First discovery text creates a moment; revisits are concise and state-aware.
5. Horror/noir needs contrast. Preserve at least three non-grim beats: Hudson's kettle, the scholarly warmth/colored ribbons of the library, and dawn lifting over the Thames.
6. NPC emotion appears as behavior: a repeated polishing motion, filmed soup, tapping fingernail, muddy heel, packed bag—not labels.

## Three-Act Prose Palette

| Act | Dominant texture | Counter-tone | Avoid |
|---|---|---|---|
| I — Exploration | Fog, wet iron, beeswax, cold rooms | Telegram humor, kettle warmth, colored ribbons | Calling every room grim or haunted |
| II — Reconstruction | Grit, dried drops, botanical humidity, slick stone | Satisfaction of mechanisms clicking into place | Expository “you realize” paragraphs |
| III — Confrontation | Rain on coats, packed bag, muddy heel, notebook pencil | Tea for four, dawn, promise of another case | Generic congratulations or reputation summary |

## Room Discovery and Revisit Targets

### Ashworth Manor Gate

Discovery: iron bars against fog; river damp and coal smoke; telegram pinned beneath a stone.

Quick reward: the telegram teaches Ashworth's habit of marking private mechanisms with the relevant person's name. Hudson's kettle postscript adds warmth and humor.

Revisit: wet gravel, open gate, manor visible north. Do not replay the entire opening tableau.

### Entrance Hall

Discovery: dust softens chandelier crystals; beeswax sharpens old-oak smell; study door visibly blocks south.

- Act II: servant-bell wire still quivers after the hidden wall opens.
- Act III: Lestrade stands with notebook open; Moriarty watches the front door and fog.

### Study

Discovery: chalk outline interrupts Turkey carpet; three drops dried nearly black; cold ash grits underfoot.

Revisits track study door, window, and name-dial box physically: locked/unlocked/open, closed/open, sealed/open.

### Library

Discovery: cold grate, leather bindings, colored ribbons interrupting orderly shelves; Moriarty taps a four-beat rhythm.

After cipher: describe the open passage as a physical route, not a “beckoning dark mouth” mood label.

### Dining Room

Discovery: two place settings but filmed soup at one; Lady Ashworth's knife precisely aligned; crimson seal at empty place.

Confronted state: paper rattles against wedding ring. Late state: black ribbon laid beside plate while she listens for Lestrade.

### Kitchen

Discovery: cold hearth, tarnished copper, blue kettle ready on range. This is a deliberate warm domestic contrast.

Drawer text must reflect closed/open state and reveal the leather roll only when visible.

### Garden

Discovery: damp branches, dry fountain, plaster footprint, glinting knife. Avoid generic “shadows hiding secrets.”

Revisit removes glints and listed evidence after the player takes them.

### Greenhouse

Discovery: humidity beads on glass; purple wolfsbane flowers; paper labels curl in damp air.

After identification: a concise line should connect the clipped/missing plant material to the vial if implemented.

### Servants' Quarters

Discovery: clean worn linen, trunk, lamp, Hudson's squeaking polishing cloth.

Late state: packed carpetbag and misbuttoned coat replace abstract nervousness.

### Pantry

Discovery: cool dry air, charcoal dust, labeled foxglove. Do not call these “antidote ingredients” unless gameplay makes that claim true.

### Secret Passage

Discovery: slick stone, undisturbed dust, cobwebs catching on sleeves; route clearly connects Library and Study.

If the lantern becomes mechanical, darkness and light state belong here.

## Important Object Discovery Text

| Object | Discovery moment | Revisit/use focus |
|---|---|---|
| Telegram | Rain-spotted paper under gate stone | Name-marking convention and kettle warmth |
| Letter | Yellow envelope among desk papers | Threat to expose Moriarty |
| Vial | Clear liquid with faded Aconitum label | Cross-location botanical identity |
| Knife | Metal glint in damp branches | Surgical form and dried blood |
| Footprint cast | White plaster beside dark fountain | Size and worn heel |
| Ledger | Leather book amid scientific papers | Exact £500 debt |
| Locked box | Name dial and three tiny engravings | No keyhole; letter/flower/debt inference |
| Bank statement | Paper revealed by dial | Corroborates ledger, not a standalone “motive established” dump |
| Magnifying glass | Brass handle worn smooth | Reveals the crescent nick in the cast's right heel |
| Lantern | Clean glass, full fuel, servants' initials beneath base | Hudson's non-promissory household keepsake; optional warm light in passage |

## NPC Behavior Matrices

### Mr. Hudson

| Phase | Player-visible behavior | Executable interaction |
|---|---|---|
| Initial | Polishes one spoon repeatedly | `ASK HUDSON ABOUT MASTER/ALIBI/KEY` |
| Player-changed | Stops polishing; admits carrying the threat letter upstairs | `SHOW LETTER TO HUDSON` before Act III |
| Story-changed | Packed bag, wrong coat buttons, relief at being noticed | Return after Lestrade arrives |

Dialogue voice: formal, compressed, protective of household ritual. His warmth appears through practical care, especially tea.

### Lady Ashworth

| Phase | Player-visible behavior | Executable interaction |
|---|---|---|
| Initial | Untouched soup, geometrically aligned cutlery | `ASK LADY ABOUT MARRIAGE/ALIBI` |
| Player-changed | Ring and paper betray a tremor; admits destroying first draft | `SHOW LETTER TO LADY` before Act III |
| Story-changed | Mourning ribbon removed; listening for police | Return after Lestrade arrives |

Dialogue voice: controlled and economical. Avoid “cold,” “calculating,” and “composure cracking”; show the physical cost of control.

### Dr. Moriarty

| Phase | Player-visible behavior | Executable interaction |
|---|---|---|
| Initial | Four-beat fingernail tap beside scientific folios | `ASK MORIARTY ABOUT EXPERIMENTS` |
| Player-changed | Sweat at collar, gloved hand pocketed, eyes counting exits | `SHOW LETTER TO MORIARTY` or poison confrontation |
| Story-changed | Moves to hall; muddy heel matches footprint | Return/examine in Act III |

Dialogue voice: precise, superior, involuntarily over-specific when threatened.

### Inspector Lestrade

| Phase | Player-visible behavior | Executable interaction |
|---|---|---|
| Offstage | Not in scope | Any early reference reports he is absent |
| Receiving case | Rain on shoulders, blank notebook page | `ASK INSPECTOR ABOUT CASE`; show three links |
| Case complete | Notebook labels THREAT, METHOD, MOTIVE | Accuse and choose leading proof |

Dialogue voice: procedural but not mechanical. He translates objects into an evidentiary chain.

## Ending Contract

The ending must:

- Reference the greenhouse/vial connection and the ledger/statement/name-dial connection.
- Use footprint/knife/escape behavior as corroborating route evidence.
- Let the player lead with letter or poison, producing distinct immediate payoffs.
- Show consequences for Hudson and Lady Ashworth.
- End on dawn, tea, the Thames, and Lestrade's next impossible file.

Never end with only “Congratulations,” “case closed,” or a reputation counter.

## Parser Trust Checklist

- “Telegram,” “kettle,” “bell wire,” “name dial,” “engravings,” “purple flower,” “notebook,” and every other actionable noun must have a parser decision: object, pseudo-object, or deliberately non-actionable wording.
- Compound phrases taught in prose must parse: `lockpick set`, `footprint cast`, `bank statement`, `study door`, `colored markers`.
- NPC topic rows are commands, not abstract conversation notes.
