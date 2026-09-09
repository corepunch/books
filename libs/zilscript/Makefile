# Targets
.PHONY: test test-all test-unit test-integration test-game-startup test-zork1 test-zork2 test-parser test-containers test-directions test-light test-pronouns test-take test-turnbit test-clock test-clock-direct test-assertions test-check-commands test-read-mailbox test-walk-around-house test-horror-helpers test-horror-partial test-horror test-horror-failures test-horror-playtest-regressions test-horror-all test-limehouse-walkthrough test-wondertown-descriptions test-pure-zil test-simple-new test-insert-file test-let test-save test-llm help llm-new llm-look test-zilch test-flow-control lint-zil zip limehouse-killings blackwood-horror wondertown

help:
	@echo "Available targets:"
	@echo "  run-text          - Run the game in text mode"
	@echo "  llm-new           - Start a new LLM game session"
	@echo "  llm-look          - Look around in LLM mode"
	@echo ""
	@echo "Test targets:"
	@echo "  test              - Run all tests (unit + integration)"
	@echo "  test-all          - Alias for 'test'"
	@echo "  test-unit         - Run unit tests only"
	@echo "  test-integration  - Run all integration tests"
	@echo "  test-zork1        - Run Zork1 integration tests"
	@echo "  test-zork2        - Run Zork2 integration tests"
	@echo "  test-game-startup - Start Lurking Horror and Spellbreaker"
	@echo "  test-parser       - Run all parser/runtime tests"
	@echo "  test-pure-zil     - Run pure ZIL tests (using ASSERT functions)"
	@echo ""
	@echo "Individual parser/runtime tests:"
	@echo "  test-containers   - Run container interaction tests"
	@echo "  test-directions   - Run direction/movement tests"
	@echo "  test-light        - Run light source tests"
	@echo "  test-pronouns     - Run pronoun tests"
	@echo "  test-take         - Run TAKE command tests"
	@echo "  test-turnbit      - Run TURNBIT flag tests"
	@echo "  test-clock        - Run clock system tests"
	@echo "  test-clock-direct - Run clock system direct tests"
	@echo "  test-assertions   - Run assertion tests"
	@echo "  test-check-commands - Run check commands tests"
	@echo "  test-read-mailbox - Run Zork I mailbox/read regression"
	@echo "  test-walk-around-house - Run forward ACTION routine regression"
	@echo "  test-simple-new   - Run simple assertion tests"
	@echo "  test-insert-file  - Run INSERT-FILE tests"
	@echo "  test-let          - Run LET form tests"
	@echo "  test-save         - Run save/restore tests"
	@echo "  test-llm          - Run LLM persistence tests"
	@echo "  test-limehouse-walkthrough - Run Limehouse golden-path LLM test"
	@echo "  test-wondertown-descriptions - Run Wondertown rendered description regressions"
	@echo "  lint-zil          - Check printed object names against parser vocabulary"
	@echo ""
	@echo "Horror game tests:"
	@echo "  test-horror-helpers - Run horror test helpers"
	@echo "  test-horror-partial - Run horror partial walkthrough"
	@echo "  test-horror-playtest-regressions - Run isolated Blackwood playtest regressions"
	@echo "  test-horror-failures - Run horror failing conditions tests"
	@echo "  test-horror       - Run horror complete walkthrough"
	@echo "  test-horror-all   - Run all horror tests"
	@echo ""
	@echo "Packaging targets:"
	@echo "  zip <gamename>    - Create a zip of a book game's .zil files + zork1 runtime (e.g. make zip limehouse-killings)"
	@echo ""
run-text:
	lua main.lua

# LLM mode targets
llm-new:
	@lua5.4 llm.lua --new-game --save savefile.sav

llm-look:
	@lua5.4 llm.lua --action "look" --save savefile.sav

# Test targets
test: test-unit test-integration
	@echo "All tests completed successfully!"

test-all: test
	@echo "All tests completed successfully!"

test-unit:
	@echo "Running unit tests..."
	lua tests/run_all.lua

test-integration: test-zork1 test-zork2 test-game-startup test-parser test-horror-all test-limehouse-walkthrough test-wondertown-descriptions
	@echo "All integration tests completed!"

test-zork1:
	@echo "Running Zork1 integration tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/zork1-walkthrough

test-zork2:
	@echo "Running Zork2 integration tests..."
	@lua5.4 run-zil-test.lua infocom/zork2/test/test-auto-generated

test-game-startup:
	@echo "Running imported game startup tests..."
	@lua5.4 tests/test_game_startup.lua

test-parser: test-containers test-directions test-light test-pronouns test-take test-turnbit test-clock test-clock-direct test-assertions test-check-commands test-read-mailbox test-walk-around-house test-simple-new test-insert-file test-let test-save
	@echo "All parser/runtime tests completed!"

test-containers:
	@echo "Running container tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-containers

test-directions:
	@echo "Running direction tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-directions

test-light:
	@echo "Running light tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-light

test-pronouns:
	@echo "Running pronoun tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-pronouns

test-take:
	@echo "Running take command tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-take

test-turnbit:
	@echo "Running TURNBIT flag tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-turnbit

test-clock:
	@echo "Running clock system tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-clock

test-clock-direct:
	@echo "Running clock system direct tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-clock-direct

test-assertions:
	@echo "Running assertion tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-assertions

test-check-commands:
	@echo "Running check commands tests..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-check-commands

test-read-mailbox:
	@echo "Running Zork I mailbox/read regression..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-read-mailbox

test-walk-around-house:
	@echo "Running Zork I forward ACTION routine regression..."
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-walk-around-house

test-simple-new:
	@echo "Running simple assertion tests..."
	@lua5.4 run-zil-test.lua zil/test-simple-new

test-insert-file:
	@echo "Running INSERT-FILE tests..."
	@lua5.4 run-zil-test.lua zil/test-insert-file

test-let:
	@echo "Running LET form tests..."
	@lua5.4 run-zil-test.lua zil/test-let

test-save:
	@echo "Running save/restore tests..."
	@lua5.4 run-zil-test.lua zil/test-save

test-llm:
	@echo "Running LLM persistence tests..."
	@lua tests/test_llm.lua

test-limehouse-walkthrough:
	@echo "Running Limehouse Killings golden-path walkthrough..."
	@lua5.4 run-zil-test.lua books/limehouse-killings/test/test-report-regressions
	@lua5.4 tests/test_limehouse_walkthrough.lua

test-wondertown-descriptions:
	@echo "Running Wondertown description ownership regressions..."
	@lua5.4 run-zil-test.lua books/wondertown/test/test-description-ownership

test-zilch:
	@echo "Running ZILCH feature tests..."
	@lua5.4 run-zil-test.lua zil/test-zilch

test-flow-control:
	@echo "Running flow control & data structure tests..."
	@lua5.4 run-zil-test.lua zil/test-flow-control

test-horror-helpers:
	@echo "Running horror test helpers..."
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-helpers

test-horror:
	@echo "Running horror complete walkthrough tests..."
	lua5.4 run-zil-test.lua books/blackwood-horror/test/test-walkthrough

test-horror-failures:
	@echo "Running horror failing conditions tests..."
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-failures

test-horror-playtest-regressions:
	@echo "Running isolated Blackwood playtest regressions..."
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-report-regressions
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-safe-key
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-say-ending
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-give-relic
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-something
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-scenery
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-lore
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-playtest-systems

test-horror-all: test-horror-helpers test-horror-partial test-horror-failures test-horror-playtest-regressions test-horror
	@echo "All horror tests completed!"

test-pure-zil:
	@echo "Running pure ZIL tests..."
	@lua5.4 run-zil-test.lua zil/test-simple-new
	@lua5.4 run-zil-test.lua zil/test-insert-file
	@lua5.4 run-zil-test.lua zil/test-let
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-containers
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-directions
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-light
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-pronouns
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-walk-around-house
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-take
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-turnbit
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-clock
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-clock-direct
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-assertions
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-check-commands
	@lua5.4 run-zil-test.lua infocom/zork1/test/test-read-mailbox
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-helpers
	@lua5.4 run-zil-test.lua books/blackwood-horror/test/test-failures
	@lua5.4 run-zil-test.lua infocom/zork1/test/zork1-walkthrough
	@lua5.4 run-zil-test.lua infocom/zork2/test/test-auto-generated
	@lua5.4 run-zil-test.lua zil/test-zilch
	@lua5.4 run-zil-test.lua zil/test-flow-control
	@echo "All pure ZIL tests completed!"

lint-zil:
	@echo "Checking vocabulary consistency in book adventures..."
	@lua5.4 scripts/check-vocab.lua books/limehouse-killings/dungeon.zil books/blackwood-horror/dungeon.zil books/wondertown/dungeon.zil

zip:
	@if [ -z "$(filter-out zip,$(MAKECMDGOALS))" ]; then echo "Usage: make zip <gamename>"; echo "Example: make zip limehouse-killings"; exit 1; fi
	@game=$(filter-out zip,$(MAKECMDGOALS)); \
	if [ ! -d "books/$$game" ]; then echo "Error: books/$$game not found"; exit 1; fi; \
	mkdir -p "$(CURDIR)/publish"; \
	tmpdir=$$(mktemp -d); \
	mkdir -p "$$tmpdir"; \
	cp books/$$game/*.zil "$$tmpdir/" 2>/dev/null || true; \
	for f in infocom/zork1/*.zil; do \
		base=$$(basename "$$f"); \
		if [ "$$base" != "dungeon.zil" ] && [ "$$base" != "actions.zil" ]; then \
			cp "$$f" "$$tmpdir/"; \
		fi; \
	done; \
	cd "$$tmpdir" && zip -j "$(CURDIR)/publish/$$game.zip" *.zil; \
	rm -rf "$$tmpdir"; \
	echo "Created publish/$$game.zip"

limehouse-killings blackwood-horror wondertown:
	@true

