# Zork I retheme catalog

This catalog covers the reusable Zork I framework files. `actions.zil` and
`dungeon.zil` are deliberately out of scope because each new game rewrites its
story logic and world from scratch.

## Directly configurable theme identifiers

| Zork identifier | Defined/used in | Meaning | Suggested treatment |
| --- | --- | --- | --- |
| `GRUE`, `GRUE-FUNCTION` | `globals.zil`, `verbs.zil` | Darkness monster and its parser responses | Rename both and replace all grue prose |
| `ZORKMID`, `ZORKMID-FUNCTION` | `globals.zil` | Great Underground Empire currency | Rename both and replace singular/plural currency prose |
| `V-ZORK`, parser word `ZORK` | `verbs.zil`, `syntax.zil` | Brand-name easter-egg command | Rename to a game-name invocation |
| `V-FROBOZZ`, parser word `FROBOZZ` | `verbs.zil`, `syntax.zil` | Frobozz Corporation easter-egg command | Rename to an in-world organization or magic word |

Identifier replacements are token-aware. Changing `GRUE` therefore also
updates references such as `,GRUE`, but does not accidentally change a larger
identifier.

## Player-facing text to replace

The example config includes the most recognizable occurrences:

- Title and series names: `ZORK I: The Great Underground Empire`, `Zork I: ...`,
  `The ZORK Trilogy`, and `The Zork Trilogy`.
- Publisher/rights text in the `VERSION` response: `Infocom interactive
  fiction`, the Infocom rights line, and the ZORK trademark line.
- Lore organizations and places: `The FROBOZZ Corporation` and `Great
  Underground Empire`.
- Currency: the zorkmid description and its `FIND` response.
- Darkness monster: its description, `FIND`/`LISTEN` responses, pitch-dark
  warning (`You are likely to be eaten by a grue`), movement deaths, vehicle
  death, and the Zork III-only grue-lair variants.
- Small remaining brand jokes: `playing Zork` in `V-COUNT` and `At your
  service!` in `V-ZORK`.

Use exact `from`/`to` entries for prose. This is intentional: broad replacement
of the word `ZORK` would also corrupt the engine selector described below.

### Source index

| File | Lines | Theme material |
| --- | ---: | --- |
| `zork1.zil` | 1-3 | `ZORK1`, full title, Infocom copyright |
| `main.zil`, `parser.zil`, `syntax.zil`, `verbs.zil`, `globals.zil` | 2 | Zork Trilogy headers |
| `clock.zil`, `macros.zil` | 2-3 | Zork Trilogy and Infocom copyright headers |
| `syntax.zil` | 227, 562 | `FROBOZZ` and `ZORK` commands |
| `globals.zil` | 90 | shared-Zorks source comment |
| `globals.zil` | 184-206 | grue object, vocabulary, description, and responses |
| `globals.zil` | 291-303 | zorkmid object, vocabulary, and responses |
| `verbs.zil` | 98-112 | titles, publisher, copyright, and trademark banner |
| `verbs.zil` | 365-368 | `playing Zork` count joke |
| `verbs.zil` | 704-706 | Frobozz Corporation response |
| `verbs.zil` | 1454 | Great Underground Empire reference |
| `verbs.zil` | 1569-1578 | darkness movement/grue deaths |
| `verbs.zil` | 1618 | `ZORK` command response |
| `verbs.zil` | 1635-1642 | pitch-black/grue warning |
| `verbs.zil` | 2101-2119 | grue-lair and vehicle-entry deaths |

## Game-specific commands stranded in framework files

These are not branding, but they encode Zork I puzzles or jokes and should be
rewritten or removed when the new `actions.zil` and `dungeon.zil` are written:

| Identifier | Location | Zork-specific behavior |
| --- | --- | --- |
| `SAILOR`, `SAILOR-FCN`, `HS` | `globals.zil`, `verbs.zil` | `HELLO, SAILOR` running joke |
| `V-ODYSSEUS` plus `ODYSSEUS`/`ULYSSES` syntax | `verbs.zil`, `syntax.zil` | Cyclops puzzle solution |
| `V-TREASURE` plus `TREASURE` syntax | `verbs.zil`, `syntax.zil` | Zork score/treasure joke |
| `CRETIN-FCN`, `ME`/`ADVENTURER` descriptions | `globals.zil` | Original game's narrator voice |

They can be added to the config's `identifiers` and `text` lists, but there is
no universal one-to-one replacement, so the example leaves them visible for an
authorial decision.

## Names that look thematic but must remain

- `ZORK-NUMBER` is a compile-time game selector understood specially by
  `zilscript/evaluate.lua`. Keep it as `ZORK-NUMBER` and keep its value at `1`
  for this source base. The tool rejects attempts to rename it.
- `ZPROB`, `ZMEMQ`, and `ZMEMQB` are legacy Z-machine/library helper names, not
  player-facing lore.
- `FLATHEAD-OCEAN`, `ZORK3`, `DARK-1`, and `DARK-2` occur only inside trilogy
  compile-time branches that are inactive when `ZORK-NUMBER` is `1`. They are
  compatibility residue, not live Zork I theme variables.

## Copy and retheme tool

Copy the example config, edit every `to` value and desired identifier, then run:

```sh
python3 tools/retheme-zork1.py my-theme.json books/my-game
```

The example remains strict JSON. Because JSON has no native comment syntax,
each replacement uses a `where` metadata field as its inline comment, pointing
to the source files, lines, and behavior affected. Optional `comment` metadata
is also accepted. Identifier entries may use either the annotated
`{"to": "NEW-NAME", "where": "..."}` form or the shorter legacy string form.

The final broad, case-sensitive word replacements in the example (`grue`,
`zorkmid`, `Frobozz`, `Zork`, and `Infocom`) are cleanup passes for short
descriptions, comments, and inactive trilogy branches. Keep them after the
longer phrase replacements. Do not add a broad uppercase `ZORK` text rule;
uppercase theme words are handled by token-aware identifier replacement so
`ZORK-NUMBER` remains intact.

The destination must not already exist. The tool copies and rethemes the eight
reusable framework files, renames `zork1.zil` to `<game_slug>.zil`, and creates
new placeholder `actions.zil` and `dungeon.zil` files. It also writes a short
bootstrap `README.md` and preserves the applied settings as `retheme.json`.

It intentionally does **not** copy Zork I's story implementations, tests,
cover, compiled story, or historical README. Use `--dry-run` to validate the
configuration and preview match counts before creating anything.
