#!/usr/bin/env lua5.4

local test = require 'tests.test_framework'

local function shell_quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function run_command(command)
	local pipe = assert(io.popen("zsh -lc " .. shell_quote(command) .. " 2>&1", "r"))
	local output = pipe:read("*a")
	local ok, _, code = pipe:close()
	return ok == true and 0 or code or 1, output
end

local function cleanup(savefile)
	os.remove(savefile)
	os.remove(savefile .. ".actions")
end

test.describe("Limehouse Killings walkthrough", function(t)
	t.it("should complete the documented golden path across LLM processes", function(assert)
		local savefile = "/tmp/test-limehouse-golden-path.sav"
		cleanup(savefile)
		local suffix = " --save " .. shell_quote(savefile) .. " --game limehouse-killings"
		local code = run_command("lua5.4 llm.lua --new-game" .. suffix)
		assert.assert_equal(code, 0)

		local actions = {
			"go north", "take magnifying glass", {"go north", "The study door is closed."},
			{"open study door", "need the study key or a lockpick"},
			"go east", "examine reading-desk", "take torn-page", "read torn-page",
			"examine colored-markers", "push red book", "push yellow book", "push green book",
			"push blue book", "go south", "go east", "examine chalk-outline", "examine desk", "take dead-letter",
			"read dead-letter", "take poison-bottle", "examine poison-bottle",
			{"open study door", "interior bolt"}, "go south", "go west",
			"examine table", {"examine wine cabinet", "missing squat bottle"},
			{"open wine cabinet", "opens freely"}, "take wax-seal", "go north", "examine shelves", "take foxglove",
			"take charcoal", {"taste vial", "vision swims"},
			{"use charcoal", "dizziness recedes"}, "go south", "go east", "go down",
			{"examine drawer", "The drawer is closed"},
			{"open drawer", "Inside is a leather roll"},
			{"examine drawer", "A leather roll lies in the open drawer"},
			{"examine leather roll", "The leather roll is closed"},
			{"open leather roll", "The leather roll contains:"},
			{"close leather roll", "You close the leather roll"},
			{"examine leather roll", "The leather roll is closed"},
			{"open leather roll", "The leather roll contains:"},
			"take lockpick set", "go west", "examine hedges", "take blood-stained-knife",
			"take footprint cast", {"use magnifying glass on footprint cast", "outside edge of the right heel"},
			"go north", "examine plants", "examine labels",
			{"use vial on plants", "match the poison bottle label"}, "go south",
			"go south", {"examine trunk", "The trunk contains:"},
			{"close trunk", "You close the trunk"},
			{"examine trunk", "The trunk is closed"},
			{"open trunk", "The trunk contains:"},
			{"examine trunk", "The trunk contains:"},
			"ask hudson", "tell hudson", "ask hudson about master", "ask hudson about alibi",
			"ask hudson about key", "take keyring", "ask hudson about moriarty",
			{"show letter to hudson", "polishing cloth goes still"},
			{"show letter to hudson", "Nine twenty"},
			{"examine hudson", "stopped polishing"}, "go north", "go east",
			"go up", "go west", "ask lady", "tell lady", "ask lady about marriage", "ask lady about alibi",
			{"show letter to lady", "paper rattles"},
			{"show letter to lady", "first draft named the laboratory account"},
			{"examine lady", "wedding ring"}, "go east", "go east",
			"ask moriarty", "tell moriarty", "ask moriarty about experiments",
			{"show letter to moriarty", "Blackmail"}, {"examine moriarty", "sweat darkens"},
			{"show letter to moriarty", "already performed that trick"},
			"ask moriarty about poison", "take secret-ledger",
			"read secret-ledger", "go west", "go north", "examine locked-box",
			"turn locked box to moriarty", "take bank-statement", "read bank-statement", "go south",
			"ask inspector", "tell inspector", "ask inspector about case", "show letter to inspector",
			"show bottle to inspector", "show statement to inspector",
			{"show footprint cast to inspector", "crescent nicks meet"},
		}

		for _, entry in ipairs(actions) do
			local action = type(entry) == "table" and entry[1] or entry
			local expected = type(entry) == "table" and entry[2] or nil
			local action_code, output = run_command(
				"lua5.4 llm.lua --action " .. shell_quote(action) .. suffix)
			assert.assert_equal(action_code, 0, "Command failed: " .. action)
			assert.assert_false(output:find("used the word", 1, true) ~= nil, "Parser rejected: " .. action)
			assert.assert_false(output:find("can't see", 1, true) ~= nil, "Object missing: " .. action)
			assert.assert_false(output:find("can't go", 1, true) ~= nil, "Route failed: " .. action)
			if expected then
				assert.assert_match(output, expected, "Unexpected output for: " .. action)
			end
		end

		local score_code, score = run_command("lua5.4 llm.lua --action score" .. suffix)
		assert.assert_equal(score_code, 0)
		assert.assert_match(score, "Evidence: 5 of 5")
		assert.assert_match(score, "Suspects: 3 of 3")

		local accuse_code, ending = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("accuse moriarty with letter") .. suffix)
		assert.assert_equal(accuse_code, 0)
		assert.assert_match(ending, "THE LIMEHOUSE KILLINGS %-%- SOLVED")

		cleanup(savefile)
	end)

	t.it("should support the reported parser and interaction commands", function(assert)
		local savefile = "/tmp/test-limehouse-command-regressions.sav"
		cleanup(savefile)
		local suffix = " --save " .. shell_quote(savefile) .. " --game limehouse-killings"
		assert.assert_equal(run_command("lua5.4 llm.lua --new-game" .. suffix), 0)

		local actions = {
			{"examine me", "eyes are prehensile"},
			{"examine myself", "eyes are prehensile"},
			{"inspect path", "gravel path leads north"},
			{"hints", "Hint:"},
			{"examine fog", "fog swirls"},
			{"examine gates", "iron gates"},
			{"examine path", "gravel path"},
			{"go north", "Entrance Hall"},
			{"examine chandelier", "chandelier hangs"},
			{"examine portraits", "Portraits of the Ashworth family"},
			{"examine rug", "Persian rug"},
			{"go down", "Kitchen"},
			{"pull servant bell", "distant bell rings"},
			{"use servant bell", "distant bell rings"},
			{"go west", "Garden"},
			{"take footprint cast", "take the footprint cast"},
			{"go south", "Servants' Quarters"},
			{"examine mister hudson", "Mr. Hudson"},
			{"ask hudson", "What do you want to ask Mr. Hudson about"},
			{"tell hudson about footprint-cast", "don't know anything about that"},
			{"show footprint-cast to hudson", "doctor's right heel"},
		}

		for _, entry in ipairs(actions) do
			local code, output = run_command(
				"lua5.4 llm.lua --action " .. shell_quote(entry[1]) .. suffix)
			assert.assert_equal(code, 0, "Command failed: " .. entry[1])
			assert.assert_false(output:find("Runtime error", 1, true) ~= nil, "Runtime failed: " .. entry[1])
			assert.assert_false(output:find("used the word", 1, true) ~= nil, "Parser rejected: " .. entry[1])
			assert.assert_false(output:find("There was no verb", 1, true) ~= nil, "Verb missing: " .. entry[1])
			assert.assert_false(output:find("nil", 1, true) ~= nil, "Nil leaked into output: " .. entry[1])
			assert.assert_match(output, entry[2], "Unexpected output for: " .. entry[1])
		end

		cleanup(savefile)
	end)

	t.it("should keep Lestrade offstage until the case reaches act three", function(assert)
		local savefile = "/tmp/test-limehouse-inspector-arrival.sav"
		cleanup(savefile)
		local suffix = " --save " .. shell_quote(savefile) .. " --game limehouse-killings"
		assert.assert_equal(run_command("lua5.4 llm.lua --new-game" .. suffix), 0)
		assert.assert_equal(run_command("lua5.4 llm.lua --action 'go north'" .. suffix), 0)
		local code, output = run_command("lua5.4 llm.lua --action 'examine inspector'" .. suffix)
		assert.assert_equal(code, 0)
		assert.assert_match(output, "can't see any inspector here")
		cleanup(savefile)
	end)

	t.it("should unlock and open the study door with Hudson's key", function(assert)
		local savefile = "/tmp/test-limehouse-study-door.sav"
		cleanup(savefile)
		local suffix = " --save " .. shell_quote(savefile) .. " --game limehouse-killings"
		assert.assert_equal(run_command("lua5.4 llm.lua --new-game" .. suffix), 0)

		local actions = {
			{"go north", "Entrance Hall"},
			{"go down", "Kitchen"},
			{"go west", "Garden"},
			{"go south", "Servants' Quarters"},
			{"ask hudson about key", "hands you the keyring"},
			{"go north", "Garden"},
			{"go east", "Kitchen"},
			{"go up", "Entrance Hall"},
			{"look", "closed and locked"},
			{"unlock study door with keyring", "study door is now unlocked"},
			{"look", "closed but unlocked"},
			{"open study door", "You open the study door"},
			{"look", "stands open, revealing the study beyond"},
			{"go north", "Study"},
		}

		for _, entry in ipairs(actions) do
			local code, output = run_command(
				"lua5.4 llm.lua --action " .. shell_quote(entry[1]) .. suffix)
			assert.assert_equal(code, 0, "Command failed: " .. entry[1])
			assert.assert_match(output, entry[2], "Unexpected output for: " .. entry[1])
		end

		cleanup(savefile)
	end)
end)

local success = test.summary()
os.exit(success and 0 or 1)
