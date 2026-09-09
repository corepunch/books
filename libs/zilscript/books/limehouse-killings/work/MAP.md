# The Limehouse Killings - World Map and Act Overlay

This file is the canonical geography and world-change plan for future `.zil` refactors. Commands and directions match the current parser-driven walkthrough.

## Room Graph

```text
                    ASHWORTH-MANOR-GATE
                              |
                            NORTH
                              |
                    ASHWORTH-ENTRANCE-HALL
                   /       /       \        \
              SOUTH     EAST       WEST     DOWN
                |         |          |        |
              STUDY---SECRET      DINING   KITCHEN---GARDEN
                        PASSAGE      |                  / \
                          |        PANTRY       GREENHOUSE SERVANTS-
                       LIBRARY                              QUARTERS
```

Exact connections:

- Gate `NORTH` → Entrance Hall; Entrance Hall `NORTH` → Gate.
- Entrance Hall `SOUTH` → Study when the study door is open.
- Entrance Hall `EAST` → Library; Library `WEST` → Entrance Hall.
- Entrance Hall `WEST` → Dining Room; Dining Room `EAST` → Entrance Hall.
- Entrance Hall `DOWN` → Kitchen; Kitchen `UP` → Entrance Hall.
- Kitchen `WEST` → Garden; Garden `EAST` → Kitchen.
- Garden `NORTH` → Greenhouse; Greenhouse `SOUTH` → Garden.
- Garden `SOUTH` → Servants' Quarters; Servants' Quarters `NORTH` → Garden.
- Dining Room `NORTH` → Pantry; Pantry `SOUTH` → Dining Room.
- Library `EAST` or `SOUTH` → Secret Passage after the cipher; passage `WEST` → Library and `EAST` → Study.

## Three-Act Overlay

### Act I — Arrival and Exploration (`CASE-ACT = 1`)

- Opening landmark: the iron gates.
- Visible, usable object: the creased telegram.
- Quick reward: reading the telegram teaches that Ashworth marked private mechanisms with a relevant name and supplies a warm Hudson/kettle beat.
- Visible blocker: the locked study door in the hub.
- Dominant play: orientation, object examination, first interviews, and discovering the colored-book mechanism.
- Lestrade is offstage.

### Act II — Reconstruction (`CASE-ACT = 2`)

Threshold: solve the library cipher in red, yellow, green, blue order.

Persistent world changes:

- The library gains an open route into the secret passage.
- The entrance-hall bell wire quivers after the concealed wall moves.
- The secret passage makes the locked-room geography intelligible: someone could cross between library and study unseen.
- Dominant play: connect letter, flower, debt, route, footprint, and weapon rather than merely collecting tools.

### Act III — Confrontation (`CASE-ACT = 3`)

Threshold: at least three counted discoveries and all three suspect interviews.

Persistent world changes:

- Lestrade moves into the entrance hall.
- Moriarty moves toward the front door after the poison interview.
- The entrance hall describes both men and the imminent escape risk.
- Hudson, Lady Ashworth, and Moriarty receive late-case descriptions that expose changed behavior.
- Dominant play: organize discoveries into threat, method, and motive; choose the proof that leads the accusation.

## Room Contracts

| Room | Act I purpose | Later-state obligation | Concrete sensory anchor |
|---|---|---|---|
| Gate | Landmark, telegram, onboarding | May reflect dawn in ending only | River damp, coal smoke, wet iron |
| Entrance Hall | Hub and study-door blocker | Bell wire in Act II; Lestrade/Moriarty in Act III | Beeswax, dust-softened crystal |
| Library | Moriarty encounter and cipher | Open passage after threshold; Moriarty later absent | Cold grate, leather, colored ribbons |
| Study | Crime reconstruction and name-dial box | Door/window/box descriptions track physical state | Gritty ash, dried drops, Turkey carpet |
| Dining Room | Lady Ashworth and interrupted meal | Her posture and objects change by NPC state | Filmed soup, polished cutlery, wax |
| Kitchen | Tool discovery and navigation | Bell feedback echoes Act II threshold | Blue kettle, cold hearth, copper |
| Garden | Route evidence, footprint, knife | Should acknowledge evidence removal on revisit | Damp leaves, dry fountain, branches |
| Greenhouse | Poison comparison | Identified plant should receive a concise revisit line | Humidity, purple flowers, wet glass |
| Servants' Quarters | Hudson, trunk, lantern | Hudson's late state and possible packed bag | Linen, squeaking polishing cloth |
| Pantry | Optional poison-risk context and recovery | Charcoal reverses one health loss; foxglove clearly warns against compounding poisons | Cool dry air, charcoal dust |
| Secret Passage | Locked-room explanation | Open once and remain open | Slick stone, dust, cobwebs |

## Physical Gate Policy

- The study door is a real `DOORBIT` object. It may be opened from inside, unlocked with Hudson's keyring, or picked as an optional physical solution.
- The primary fiction-understanding route into the study is the library cipher and secret passage.
- The locked box is not a key gate. It has a name dial and `TURNBIT`; its solution depends on connecting three discoveries.
- Every mutable route must be represented by object state and/or a room `ACTION` routine, never prose alone.

## Refactor Acceptance Checks

- Every direction above works from a fresh save.
- Each act boundary changes at least two existing room/NPC descriptions.
- Lestrade cannot be examined or addressed before Act III.
- NPCs are visibly listed wherever they are physically present.
- No room description names an actionable fixture without a parser object or deliberate `PSEUDO` handler.
