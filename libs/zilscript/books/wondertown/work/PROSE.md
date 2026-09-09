# Wondertown — Prose (Room Descriptions & Dialogue)

## Room Prose

### WORKSHOP-FLOOR
> You are in Grandfather Tolliver's workshop. The enormous workbench towers above you, its surface cluttered with tools and half-finished toys. A brass key hook on the wall hangs empty — only a frayed string still dangles from it. Your tiny broom leans against the bench. Soft sawdust covers the floorboards like a golden blanket.
>
> A small pet door is cut into the workshop's main door to the north. An old cuckoo clock ticks softly on the wall. A folding wooden ladder rises toward the storage loft, though its mechanism looks worryingly rusted. To the east, the tool bench waits beneath the countertop.

### TOOL-BENCH
> The tool bench stretches away, a landscape of enormous chisels and planes. A low crate leads to an old chair, where three broad repair books are stacked flat against the back. A painted wooden nutcracker stands frozen on the seat. A pot of varnish sits open nearby, its contents gone tacky.
>
> The crate, chair, and books make a stable route to the countertop, but the nutcracker blocks the chair seat.

### COUNTERTOP
> You've climbed to the countertop — the toy display. A dusty glass case holds forgotten treasures, and through the frosted shop window you can see the snowy street outside, the clock tower visible in the distance.
>
> A rag doll with one button eye sits against the window, her stitched mouth curved in a permanent smile. She's humming a little tune.

### STORAGE-LOFT
> The storage loft is dusty and dim, cobwebs draping the rafters like grey curtains. An old cuckoo clock — the twin of the one downstairs — sits silent among the shadows, its hands frozen at five to midnight.
>
> A cardboard box labelled "Broken — For Repair" sits in the corner. This was where Tolliver kept toys he meant to fix.

### SNOWY-ALLEY
> You emerge into the snowy alley behind the workshop. Fresh snow blankets the cobblestones, and the winter moon casts long blue shadows. Tiny fox footprints — unmistakably toy-sized — lead east through the snow.
>
> A streetlamp flickers overhead. It's not a real streetlamp — it's a toy lantern, repurposed and mounted on a pole. The workshop door looms behind you, the pet door at its base.

### CLOCK-SQUARE
> The clock tower dominates the square, its great face showing the hours until dawn with unnerving clarity. Abandoned shopfronts line the square — a bakery, a cobbler's — each window displaying a toy frozen in its work.
>
> Tin toy lamps dot the cobblestones, their light weak and flickering. A brass winding mechanism sits at the clock tower's base, just out of reach.

### MAILBOX-CORNER
> At the corner, a red tin mailbox tilts slightly into the snow. Its flap hangs open, and scattered letters lie half-buried. The mailbox shivers — or maybe it was just the wind. A red wool scarf lies abandoned in the snow.
>
> More fox footprints continue east, toward what looks like the old scrap-yard.

### SCRAP-YARD
> The scrap-yard is a sad place. Broken toys are piled everywhere — a headless porcelain doll, a three-legged horse, toys that someone loved once and then discarded. A scrap-metal cart creaks slowly along a track, gathering up the broken things.
>
> Behind the cart, an iron gate leads east — but the cart blocks the way.

### FOX-DEN
> Behind the scrap-yard, tucked into a nook between old crates, is a cosy den made of rags and twigs. A tiny toy candle burns inside, casting warm shadows.
>
> Curled in the centre is a fox-shaped toy with patchy orange fur and two button eyes that watch you warily. The workshop key — the one from the empty hook — hangs from a string around her neck.

### TOLLIVER-STUDY
> Grandfather Tolliver's private study. A wooden desk is cluttered with papers, diagrams, and an open journal. His worn coat hangs on the back of the chair, as if he just stepped away. A cup of tea — stone cold — sits beside the inkwell.
>
> The room smells of wood shavings, old paper, and something else: a faint trace of the magic that keeps the toys alive. Stairs lead back down to the workshop.

### WORKSHOP-HEART
> You're inside the workshop's heart — a vast chamber hidden behind the clock. Giant brass gears surround you, motionless. A central winding mechanism waits, its keyhole dark. Around the walls, dozens of toys stand frozen — silent witnesses.
>
> This is where the magic lives. This is what needs rewinding.

---

## NPC Dialogue Trees

### Bertrand (Nutcracker)

**Before winding:** (No dialogue — his jaw is clamped shut)
- EXAMINE: "His jaw is clamped tight. He looks rather affronted about it."
- TALK TO BERTRAND: "His painted mouth stays shut. He looks like he has plenty to say, if only he could."

**After winding:**
- First greeting: `> talk to bertrand` → "'Captain Bertrand of the Nutcracker Brigade, at your service!' He snaps his heels together. 'I've been stuck in that undignified pose for HOURS. You have my gratitude, small apprentice.'"
- ASK BERTRAND ABOUT KEY: "'The master's key? Gone from its hook, I noticed. Most irregular. I would have investigated myself, but...' He gestures at his wooden legs. 'Limited mobility, I'm afraid.'"
- ASK BERTRAND ABOUT TOLLIVER: "'The Grandfather? Finest toymaker in three counties. He wound me himself, you know. Every evening at six.' His voice softens. 'He hasn't come down tonight.'"
- TELL BERTRAND ABOUT FOX: "'A fox, you say? With the key? That's... that's rather sad, actually. The fox toys never sold well. Too clever, the shopkeepers said. Too knowing.'"

**If addressed politely (CAPTAIN/SIR):**
- "He puffs up with pride. 'You show proper respect, apprentice. That is rare.'" (BERTRAND-POLITE = T)

**During final rewind:**
- If BERTRAND-POLITE and BERTRAND-WOUND: "'Captain Bertrand reporting for duty! The heart needs a soldier's discipline. Allow me.' He marches to the mechanism and stands guard."

### Old Tick (Cuckoo Clock)

**Before wound/listened:**
- EXAMINE: "The old cuckoo clock is dusty and still, its hands frozen at five to midnight."

**After listening on the hour (first riddle):**
- LISTEN (when tick count lands on a multiple of 10): "The cuckoo clock stirs. A tiny wooden bird emerges and speaks: 'The key is gone, the fox is cold / A story waiting to be told / Through the door where snowflakes fall / The smallest apprentice must stand tall.'"

**Subsequent riddles:**
- "'Tick and tock, the hours race / Wind the tower, slow the pace / But kindness, child, not clever tricks / Is what will fix the fox's fix.'"
- "'Behind the clock, a hidden stair / The toymaker's last secret there / But only one with fox's grace / Can reach the latch and find the place.'"

**If ASK OLD TICK ABOUT TOLLIVER:**
- "The clock's hands tremble. 'The toymaker went to mend the heart. He said he would return by midnight. That was three midnights ago.'"

### Marzipan (Rag Doll)

**Idle singing (heard in room):**
- "'Fox feet, fox feet, left the shop / Through the door with a hop and a hop / Key round neck and heart so sore / Find her where the broken toys snore.'"

**ASK MARZIPAN ABOUT KEY:**
- "'The key that ticks? The key that tocks? / Gone with fox through snowy blocks!'"

**ASK MARZIPAN ABOUT TOLLIVER:**
- "'Old man, kind man, mended me / Stitched my smile for all to see / Then one night he climbed the stair / And nobody's seen him anywhere.'" (She points toward the clock.)

**ASK MARZIPAN ABOUT FOX:**
- "'Foxy, foxy, all alone / Colder than a stepping stone / Give her something warm and red / And she might trust a word you've said.'"

**GIVE BUTTON TO MARZIPAN:**
- "'For me?' Her stitched face seems to brighten. She sews the button on as a second eye. Now both eyes watch you. 'Thank you, little apprentice. I'll sing you a secret now.'"
- Secret song: "'Behind the ticking, ticking clock / A door that needs no key or lock / But small paws only fit the crack / To push the hidden latch way back.'"

### Nutmeg (Fox Toy)

**First encounter:**
- "The fox toy lifts her head. Her button eyes are unreadable. 'You're from the shop.' It's not a question."

**ASK NUTMEG ABOUT KEY:**
- "She curls tighter around the key. 'It's the only thing that's ever ticked for me. Do you know what it's like? Being a toy nobody wanted? The shop sold every last soldier, every doll, every wooden train — but nobody ever picked me. I sat on the shelf for YEARS.'"

**ASK NUTMEG ABOUT TOLLIVER:**
- "Her ears droop. 'The old man. He was the only one who ever fixed me. When my stitching came loose, when my button eye fell off — he always put me back together. And then... then he stopped coming.'"

**TELL NUTMEG ABOUT TOLLIVER (if trust >= 1):**
- "'He's... gone? Not just busy? Not just... forgetting about me?' She's quiet for a long moment. 'I thought he'd stopped caring. Like everyone else.'"

**GIVE SCARF TO NUTMEG (gift 1):**
- "'For... for me?' She touches the red wool with her paw. 'It's warm. Nobody ever gave me anything warm before.' Her voice cracks on the last word."

**GIVE STRING-BALL TO NUTMEG (gift 2):**
- "She bats the ball of yarn with her paw, almost despite herself. 'I... I used to do this. In the shop window. Before I knew nobody was coming for me.'"

**After 2+ kindness actions (trust = 3):**
- "Nutmeg is quiet for a long moment. Then she paws the key off her neck and places it before you. 'Take it. I'm sorry I took it. I just... I didn't want to be alone when the ticking stopped.'"

**If attacked/betrayed:**
- "'I knew it.' She doesn't sound angry — just tired. 'You're just like the others.' She retreats to the deepest corner of her den, key clutched to her chest. She won't look at you anymore."

**During final rewind (if befriended):**
- "Nutmeg pads up beside you at the heart. 'Let me help,' she says quietly. 'I've been alone long enough. I'd like to be part of something.' She curls up at the base of the mechanism, and the heart glows warmer."

---

## Tick Warning Messages

| Ticks Left | Message |
|-----------|---------|
| 150 | — (silent) |
| 100 | "The cuckoo clock chimes softly. Plenty of night left." |
| 75 | "Through the frosted window, the sky is still dark. But you feel the hours passing." |
| 50 | "The sky outside shows the first grey hint of approaching dawn." |
| 30 | "The cuckoo clock chimes again, more urgently. Half the night is gone." |
| 20 | "Golden light creeps at the eastern horizon. Dawn is close now." |
| 10 | "The toys around you are growing still — their magic waning. Hurry!" |
| 5 | "Sunlight touches the rooftops. You have minutes, not hours." |
| 0 | "The sun rises. The last tick fades into silence. The workshop is still. You are alone." |
