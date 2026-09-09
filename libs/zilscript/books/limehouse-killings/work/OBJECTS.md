# The Limehouse Killings - Object and Vocabulary Registry

This registry records parser-facing names and narrative roles. `DESC` text is not vocabulary; every canonical command must be backed by `SYNONYM` and `ADJECTIVE` entries.

## Opening and Evidence Objects

| ID | Canonical phrase | Natural variants | Initial location | Role/state |
|---|---|---|---|---|
| `TELEGRAM` | creased telegram | telegram, message, wire | Gate | Visible opening object and quick reward; teaches the name-marked mechanism convention |
| `DEAD-LETTER` | unsent letter | letter, note, paper | Study | Threat/intent discovery; guarded by `DEAD-LETTER-FOUND` |
| `POISON-BOTTLE` | poison bottle | bottle, vial | Study | Method clue; compare `VIAL` with greenhouse plants |
| `BLOOD-STAINED-KNIFE` | blood-stained knife | knife, blade, weapon | Garden | Route/weapon evidence; guarded by `KNIFE-FOUND` |
| `SECRET-LEDGER` | secret ledger | ledger, account, book | Library | Debt clue; guarded by `SECRET-LEDGER-FOUND` |
| `BANK-STATEMENT` | bank statement | statement, receipt | Locked box | Motive corroboration; guarded by `BANK-STATEMENT-FOUND` |
| `FOOTPRINT-CAST` | footprint cast | footprint, cast, mold, impression | Garden | Excludes Lady Ashworth and later matches Moriarty's heel |
| `WAX-SEAL` | wax seal | seal, stamp | Dining Room | Visual `M` clue and optional corroboration |

## Puzzle and Tool Objects

| ID | Canonical phrase | Natural variants | Location | Contract |
|---|---|---|---|---|
| `STUDY-DOOR` | study door | door, oak door, south door | Local global | Real door controlling the north/south route; key/lockpick are optional solutions |
| `LOCKED-BOX` | locked box | box, case, container | Study fireplace | `CONTBIT SEARCHBIT TURNBIT`; name dial, never opened by key/lockpick |
| `TORN-PAGE` | torn page | page, fragment | Library | Explicit red-yellow-green-blue clue |
| `COLORED-MARKERS` | colored markers | markers, ribbons, tags | Library | Environmental half of cipher clue |
| `RED-BOOK` etc. | red-marked book | red book, yellow book, green book, blue book | Library | Four distinct parser objects; `PUSH` advances/reset cipher |
| `MAGNIFYING-GLASS` | magnifying glass | glass, lens, magnifier | Entrance Hall | Reveals the crescent nick in the footprint cast's right heel |
| `LEATHER-ROLL` | leather roll | roll, leather case | Kitchen drawer | Openable container holding picks |
| `LOCKPICK-SET` | lockpick set | lockpick, set, picks, tools | Leather roll | Optional physical route/tool, not a required major gate |
| `KEYRING` | keyring | keys, key | Hudson | Optional study-door solution and Hudson trust response |
| `LANTERN` | oil lantern | lantern, lamp, light | Servants' Quarters | Hudson's maintained keepsake; explicitly not presented as a required darkness tool |
| `FOXGLOVE` | foxglove | digitalis | Pantry | Dangerous digitalis contrast; refuses unsafe self-medication |
| `CHARCOAL` | charcoal | coal | Pantry | Recoverable response to tasting poison; restores one lost health point |

## Major Scenery and Containers

| ID | Room | Required nouns/commands | Function |
|---|---|---|---|
| `GATES`, `PATH`, `FOG` | Gate | examine gates/path/fog | Opening landmark and sensory frame |
| `CHANDELIER`, `PORTRAITS`, `RUG` | Hall | examine chandelier/portraits/rug | Hub texture; portraits are a candidate place for additional name-dial foreshadowing |
| `DESK`, `FIREPLACE`, `WINDOW`, `CHALK-OUTLINE` | Study | examine each; open window | Crime reconstruction and physical route model |
| `BOOKSHELF`, `READING-DESK` | Library | examine/push bookshelf; examine desk | Cipher affordance |
| `TABLE`, `WINE-CABINET` | Dining Room | examine table/cabinet; open cabinet | Interrupted meal and missing private-laboratory delivery bottle |
| `POTS`, `HEARTH`, `SERVANT-BELL`, `DRAWER` | Kitchen | examine; pull/use bell; open drawer | Warm contrast, feedback, tool container |
| `FOUNTAIN`, `HEDGES` | Garden | examine fountain/hedges | Surface footprint and knife discoveries |
| `PLANTS`, `LABELS`, `BENCH` | Greenhouse | examine plants/labels; use vial on plants | Poison comparison |
| `BEDS`, `TRUNK`, `UNIFORMS`, `TRUNK-LETTER` | Quarters | examine/open/read | Hudson environment and secondary testimony |
| `SHELVES` | Pantry | examine shelves | Ingredient context |
| `STONE-WALLS`, `COBWEBS`, `DUST` | Passage | examine | Locked-room route and age |

## NPC Registry

| ID | Canonical listener | Vocabulary | Initial location | Movement |
|---|---|---|---|---|
| `MR-HUDSON` | Mr. Hudson | Hudson, butler; adjectives Mr/Mister | Servants' Quarters | Static, description changes by case state |
| `LADY-ASHWORTH` | Lady Ashworth | Ashworth, wife; adjective Lady | Dining Room | Static, description changes by case state |
| `DR-MORIARTY` | Dr. Moriarty | Moriarty, doctor; adjectives Dr/Doctor | Library | Moves to Entrance Hall after poison interview |
| `INSPECTOR` | Inspector Lestrade | inspector, Lestrade, officer, police | Offstage | Moves to Entrance Hall only at Act III threshold |

## Topic Objects

Global topic objects support `ASK/TELL ... ABOUT ...`: master, alibi, key, Moriarty, marriage, experiments/research, poison/wolfsbane, and case/murder. Actor routines must guard `PRSI` before every containment/equality operation so topicless `ASK NPC` cannot crash.

## Vocabulary Collision Rules

- `SET` and `CAST` are also substrate verbs. At game start their noun senses are re-registered so `TAKE LOCKPICK SET` and `TAKE FOOTPRINT CAST` work.
- `INSPECTOR` truncates to the same six-letter dictionary form as `INSPECT`; its object sense is likewise re-registered.
- Prefer unambiguous canonical puzzle commands such as `USE VIAL ON PLANTS` where `POISON` can resolve to both a topic and a physical bottle.
- Test spaced and hyphenated variants where the prose teaches both.

## Progress Guard Policy

`TAKE`, `READ`, and `EXAMINE` may expose the same clue, but each corresponding `*-FOUND` flag may increment `EVIDENCE-FOUND` only once. Opening the box is separate from discovering/reading its bank statement.

## Optional Evidence State

- `FOOTPRINT-DETAIL-FOUND` records the magnifying-glass discovery and unlocks exact heel-match prose from Moriarty, Lestrade, and the ending.
- `CABINET-CLUE-SEEN` records the missing medicinal-delivery bottle and changes Dining Room revisit prose.
