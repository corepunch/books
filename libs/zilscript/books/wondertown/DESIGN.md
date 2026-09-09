# The Last Toymaker's Apprentice — Design Document

## Premise

You are **Pip**, a tiny workshop gnome apprentice — no taller than a teacup — who works for Grandfather Tolliver, the last toymaker in Wrenfold. Every night after the shop closes, the toys wake up. Pip's job is small: oil joints, sweep sawdust, keep the workshop running before dawn.

Tonight, Grandfather Tolliver doesn't come down to lock up. His workshop key — the thing that keeps the shop's magic wound — has stopped ticking on its hook. Without it, the toys will fall silent by sunrise, one by one, forever.

Pip has one night to find out what happened and rewind the town's heart before the clock runs out.

## Core Fantasy

"You are a tiny workshop gnome apprentice in a toy workshop come to life, racing against dawn to save your toy friends before their magic runs out forever."

## Target Player

- All-ages text adventure fans (ages 10+)
- Players who enjoy character-driven puzzles and emotional stakes
- Fans of Toy Story, Up, Planetfall — whimsy with heart
- Light-to-medium difficulty: accessible but never condescending

## Tone

- **Act 1:** Whimsical, comedic, cosy — a toy workshop full of personality
- **Act 2:** Atmospheric, bittersweet — the abandoned toys of Wrenfold, Nutmeg's loneliness
- **Act 3:** Urgent, emotional, earned — choices matter, dawn is coming
- Overall: Clear prose, dry humour where appropriate, genuine sadness, real joy

## Length

- **Playtime:** 60-90 minutes
- **Rooms:** 10-12
- **Objects:** 25-30
- **NPCs:** 4 (Bertrand, Old Tick, Marzipan, Nutmeg)
- **Puzzles:** 6-8 (character-driven, not just locks)

## Win Condition

Find what happened to Grandfather Tolliver, recover the workshop key, and rewind the town's heart before dawn (within 200 turns). The ending evaluates player kindness: were they patient with Bertrand, did they let Old Tick finish his riddles, did they treat Nutmeg with care?

## Lose Conditions

1. **Dawn arrives**: Key not rewound by turn 200 — toys fall silent forever
2. **Nutmeg betrayed**: Player treats Nutmeg cruelly, she destroys the key — player is trapped
3. **No softlocks**: Player can always recover from setbacks; no unwinnable states

## Core Mechanics

### Focus Interaction Model

The shared Companion layer separates Pip's physical world location from the
current interaction focus. It progressively discloses local choices for an
object, character, document, or puzzle while the ZIL room and world state
remain authoritative. Text-only and illustrated products use the same focus
state and actions; only their rendering differs. See
[FOCUS_INTERACTION_MODEL.md](FOCUS_INTERACTION_MODEL.md).

### The Tick System
- The "tick" counter starts at 200 and decrements each turn
- Certain rooms and actions slow/accelerate the tick
- The key can be partially rewound at certain locations to buy more time
- When tick reaches 0 before the key is fully rewound, the game ends

### The WIND Command
- WIND is the core verb: wind toys, wind the key, wind clocks
- Some toys require winding to help you (Bertrand guards a door, Old Tick gives hints)
- The key must be wound at the workshop heart at the end

### The OIL Command
- OIL stuck mechanisms, squeaky hinges, frozen joints
- Essential for reaching certain areas
- Ties into the "repair" theme

### Inventory as Character Development
- You can CARRY small items (Pip is tiny — teacup-sized)
- Some puzzles require choosing which toy to carry vs. which to leave
- Weight and size matter differently (toy-sized physics)

## World Rules

### Toy Physics
- Pip is teacup-sized: everything is enormous
- Gravity is toy-scale: falls from table-height are dangerous
- Water is deadly (a spilled cup is a flood)
- The workshop is the ground floor; "outside" is through the pet door

### Magic Rules
- The workshop key is the source of toy animation
- Key must be wound regularly or magic fades
- Certain toys can be rewound temporarily with personal effort
- The key was taken, not broken — it can be recovered

### Time Rules
- 200 turns until dawn
- Actions take 0-2 ticks (movement 1, complex actions 2, examining 0)
- Clock-related puzzles affect tick rate
- The final act uses real-time tension

## Parser Expectations
- Core verbs: EXAMINE, TAKE, DROP, WIND, OIL, LISTEN, ASK, TELL, SHOW, GIVE
- Toy-specific: WIND CLOCK, OIL HINGE, REPAIR DOLL
- NPC interaction: ASK BERTRAND ABOUT KEY, TELL NUTMEG ABOUT TOLLIVER
- Movement: GO NORTH, GO EAST, etc. (standard Zork directions)
- Synonyms: LOOK AT = EXAMINE, GET = TAKE

## Constraints

### Parser Guessability
- Use clear, common vocabulary
- Important objects described in room text
- Hints available through Old Tick (riddle-hints)
- WIND and OIL taught in Act 1 tutorial

### Design Fairness
- No dead ends (tick depleting is only true fail state)
- Layered hints through NPCs
- Multiple puzzle solutions where reasonable
- Clear feedback for wrong actions
- Items critical to winning are always recoverable

### Technical Limits
- ZIP version ZIL
- Text-only, no graphics
- Standard ZIL object/room model
- Uses Zork1 substrate (parser, syntax, verbs, clock)

## Three-Act Structure

### Act 1 — "The Nightly Rounds" (Rooms: Workshop, Attic Stairs, Storage Loft)
- Pip starts in the workshop, performing nightly duties
- Meet Bertrand (pompous nutcracker), Old Tick (cuckoo clock), Marzipan (rag doll)
- Learn WIND, OIL, LISTEN, EXAMINE
- Discover the key is missing from its hook
- Find muddy footprints leading to the pet door
- Act ends: Pip steps outside into Wrenfold

### Act 2 — "Wrenfold By Night" (Rooms: Snowy Alley, Clock Square, Mailbox Corner, Scrap-Yard, Fox Den)
- Discover Wrenfold's toys: streetlamps, mailboxes, shopfronts — all abandoned playthings
- Meet Nutmeg (fox toy), who took the key
- Nutmeg is guarded, sarcastic, heartbreaking — she must be won over
- Puzzles: locked gate only Nutmeg can pass through, scrap cart puzzle, inventory choice
- Learn what happened to Grandfather Tolliver through environmental clues
- Act ends: Nutmeg either trusts Pip or turns hostile

### Act 3 — "What the Clockwork Remembers" (Rooms: Tolliver's Study, Workshop Heart, Clock Tower)
- Dawn approaching — tick counter made visible
- Pip must rewind the workshop key at the heart of the shop
- Final puzzle: choose which toys to personally rewind (not all can be saved)
- Branching endings based on player's behaviour throughout
- Thematic resolution: kindness matters

## Success Metrics
- Player can complete in 60-90 minutes
- All puzzles solvable without hints (but hints available)
- No softlocks or dead ends
- NPCs feel like characters with arcs
- The ending provides emotional payoff
- Winning feels earned through kindness, not just cleverness
