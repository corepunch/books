# The Last Toymaker's Apprentice — Companion Validation Transcripts

## Environment

- Date: 2026-07-29
- Revision: 1
- Lua version: 5.4
- Game module: books.wondertown
- Mode: child / story

## Scenario: Workshop Floor — Initial State

### Prerequisite state

New game. No commands executed.

### Legacy capped visible-card snapshot

1. Examine the enormous workbench — `examine workbench` — scene
2. Look at the empty key hook — `examine hook` — scene
3. Walk to the tool bench — `east` — move

### Selection

Selected card: workshop-floor.examine-workbench

Observed output: "The enormous workbench towers above you, its surface cluttered with tools. Underneath, something small and copper catches the light."

Expected output or state: Player learns about oil can location.

Result: PASS (command accepted, non-empty output)

## Scenario: Tool Bench — Take Bertrand Key

### Prerequisite state

Workshop floor → east to tool bench.

### Legacy capped visible-card snapshot

1. Take the winding key from Bertrand's back — `take key` — scene
2. Examine Bertrand closely — `examine nutcracker` — scene
3. Return to the workshop floor — `west` — move

### Selection

Selected card: tool-bench.take-key

Observed output: "A tiny brass winding key protrudes from the nutcracker's back."

Expected output or state: Key added to inventory.

Result: PASS (command accepted, key acquired)

## Scenario: Tool Bench — Wind Bertrand

### Prerequisite state

Tool bench with key taken from Bertrand.

### Legacy capped visible-card snapshot

1. Wind the nutcracker with his key — `wind nutcracker` — scene
2. Examine Bertrand closely — `examine nutcracker` — scene
3. Return to the workshop floor — `west` — move

### Selection

Selected card: tool-bench.wind-bertrand

Observed output: "You insert the tiny brass key into the nutcracker's back and wind. His jaw snaps shut with a sharp CLACK, then opens wide. 'At last! A proper winding!'"

Expected output or state: BERTRAND-WOUND = true, way upstairs clear.

Result: PASS (command accepted, puzzle state advanced)

## Scenario: Countertop — Open Display Case

### Prerequisite state

Tool bench → wound Bertrand → up to countertop.

### Legacy capped visible-card snapshot

1. Open the dusty glass display case — `open case` — scene
2. Ask Marzipan about Grandfather Tolliver — `ask doll about tolliver` — scene
3. Climb back down to the tool bench — `down` — move

### Selection

Selected card: countertop.open-case

Observed output: "You flip the brass latch and open the display case."

Expected output or state: Display case opens, items become accessible.

Result: PASS (command accepted)

## Scenario: Fox Den — Befriend Nutmeg

### Prerequisite state

Full golden path to fox den with scarf in inventory.

### Legacy capped visible-card snapshot

1. Look at the fox toy in the corner — `examine fox` — scene
2. Give Nutmeg the red wool scarf — `give scarf to fox` — scene
3. Tell Nutmeg about Grandfather Tolliver — `tell fox about tolliver` — scene

### Selection

Selected card: den.give-scarf

Observed output: "Nutmeg stares at the red scarf in your hand. 'For... for me?' She wraps the scarf around her neck."

Expected output or state: NUTMEG-TRUST increases.

Result: PASS (command accepted, trust increased)

## Scenario: Workshop Heart — Final Rewind

### Prerequisite state

Key found, study accessed, diagram read, heart reached with soldier and music box.

### Legacy capped visible-card snapshot

1. Place the tin soldier beside the heart — `position soldier` — scene
2. Place the music box near the heart — `position music box` — scene
3. Examine the workshop heart — `examine mechanism` — scene

### Selection

Selected card: heart.place-soldier

Observed output: "You place the tin soldier beside the heart mechanism. He snaps to attention."

Expected output or state: COMPANION-COUNT increases.

Result: PASS (command accepted, companion placed)
