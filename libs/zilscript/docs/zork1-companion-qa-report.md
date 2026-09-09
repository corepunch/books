# Zork I Companion Interface QA Report

The original report in this file covered a removed, capped interface and is no
longer representative of the current CLI.

The supported card interface is now:

```bash
lua5.4 main.lua --companion infocom.zork1.zork1
```

It displays every unique, currently eligible authored choice under the
“In this scene” and “Go somewhere” headings. The player may select a numbered
choice or type any parser command. Automatic suggestions are used only when the
current state emits no authored choices.

Current automated coverage lives in `tests/test_companion.lua`; full blind
playthrough and matching-state command-execution evidence remain tracked in
`infocom/zork1/companion/COVERAGE.md`.
