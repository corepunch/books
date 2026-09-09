# The Limehouse Killings - Design Document

## Premise

You are a private detective in Victorian London, 1888. Lord Ashworth, a wealthy industrialist, has been found dead in his locked study at Ashworth Manor in the Limehouse district. Scotland Yard is baffled - the room was sealed from the inside, yet the victim bears the marks of violent murder. Lady Ashworth has hired you to investigate before the press gets wind of the scandal.

## Core Fantasy

"You are a brilliant detective in foggy Victorian London, piecing together clues, interrogating suspects, and unmasking a killer before they strike again."

## Target Player

- Fans of mystery/detective stories (Sherlock Holmes, Agatha Christie)
- Players who enjoy investigation and deduction over action
- Text adventure enthusiasts who appreciate atmospheric writing
- Medium difficulty - challenging but fair puzzles

## Tone

- Dark, atmospheric Victorian noir
- Fog-choked streets, gaslight shadows, whispered secrets
- Intellectual satisfaction of solving puzzles
- Tension of confronting dangerous suspects
- Grim but not gratuitous violence

## Length

- **Playtime:** 2-3 hours
- **Rooms:** 10
- **Puzzles:** 4 major, 2 minor
- **Objects:** 20-25
- **NPCs:** 3 (with conversation trees)

## Win Condition

Present the correct combination of evidence to Inspector Lestrade of Scotland Yard, naming the killer with proof. The game ends with the killer's arrest and your reputation secured.

## Lose Conditions

1. **Wrong Accusation:** Accuse an innocent person - game ends with your disgrace
2. **Missing Evidence:** Fail to find critical clues - case goes cold
3. **Killer Escapes:** Take too long (metaphorically, no timer) - killer flees London
4. **Death:** Certain dangerous actions can get you killed (e.g., confronting killer unarmed)

## Core Mechanics

### Investigation
- Examine rooms and objects for clues
- Take evidence to build your case
- Connect clues to identify suspect means, motive, opportunity

### Conversation
- ASK NPCs about topics
- TELL NPCs about findings
- SHOW items to NPCs for reactions
- NPCs have limited topics and may lie or withhold information

### Puzzles
- **Lockpicking:** Physical manipulation puzzles
- **Cipher:** Decode hidden messages
- **Chemical:** Identify poison and antidote
- **Deduction:** Connect evidence to suspect

### Inventory
- Carry up to 7 items
- Use items on objects/NPCs
- Items can be combined or transformed

## World Rules

### Victorian London Authenticity
- Technology limited to 1888 (no electricity, no phones)
- Social hierarchy matters (servants vs. masters)
- Women's roles constrained by era
- Class distinctions affect NPC interactions

### Fair Play
- All clues discoverable through exploration
- No pixel hunts - important objects are described
- Multiple paths to key evidence
- Wrong choices provide feedback, not permanent locks

### Parser Expectations
- Standard verbs: EXAMINE, TAKE, DROP, USE, OPEN, CLOSE, LOOK, READ, ASK, TELL, SHOW, GO
- synonyms: LOOK AT = EXAMINE, SEARCH = LOOK INSIDE
- NPC names: ASK HUDSON, TELL LADY, SHOW KNIFE TO MORIARTY

## Constraints

### Parser Guessability
- Use common Victorian English vocabulary
- Avoid obscure synonyms
- Provide parser hints for important actions
- TEST command available for walkthrough verification

### Design Fairness
- No dead ends that require restart
- Hints available through in-game hint system
- Multiple solutions where reasonable
- Clear feedback for wrong actions

### Technical Limits
- ZIP version ZIL (no overhead instructions)
- No sound, graphics, or color
- Text-only presentation
- Standard ZIL object/room model

## Narrative Arc

### Act 1: Arrival (Rooms: Gate, Entrance Hall)
- Detective arrives at Ashworth Manor
- Meet Mr. Hudson (butler)
- Learn basic facts of the case
- Gain access to entrance hall

### Act 2: Investigation (Rooms: Study, Library, Dining Room, Kitchen, Garden)
- Explore the manor and grounds
- Find evidence in study
- Decode library cipher
- Discover poison connection
- Interview Lady Ashworth and Dr. Moriarty

### Act 3: Deduction (Rooms: Greenhouse, Servants' Quarters, Secret Passage)
- Identify poison source
- Find hidden evidence
- Connect clues to suspect
- Build case for accusation

### Act 4: Confrontation (Final Room: Inspector's Office)
- Present evidence to Inspector
- Name the killer
- Game ends based on correctness

## Success Metrics

- Player can complete game in 2-3 hours
- All puzzles solvable without hints (but hints available)
- No softlocks or dead ends
- Atmospheric writing maintains Victorian tone
- NPCs feel like characters, not just information dispensers
- Winning feels earned, not guessed
