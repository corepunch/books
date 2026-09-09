#!/usr/bin/env lua

local test = require 'tests.test_framework'
local runtime = require 'zilscript.runtime'

local function run_command(command)
	local pipe = assert(io.popen(command .. " 2>&1", "r"))
	local output = pipe:read("*a")
	local ok, why, code = pipe:close()
	local exit_code
	if type(ok) == "number" then
		exit_code = ok
	elseif ok == true then
		exit_code = 0
	else
		exit_code = code or 1
	end
	return exit_code, output
end

local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

local function remove_file(path)
	os.remove(path)
end

local function cleanup(savefile)
	remove_file(savefile)
	remove_file(savefile .. ".actions")
end

local function shell_quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function boot_zork1_env()
	local env = runtime.create_game_env()
	assert(runtime.init(env, true))
	env.require('zilscript')
	assert(runtime.load_modules(env, {
		'infocom.zork1.globals',
		'infocom.zork1.clock',
		'infocom.zork1.parser',
		'infocom.zork1.verbs',
		'infocom.zork1.actions',
		'infocom.zork1.syntax',
		'infocom.zork1.dungeon',
		'infocom.zork1.main',
	}, {silent = true}))
	return env
end

test.describe("LLM Mode", function(t)
	t.it("should create an empty history file on new game", function(assert)
		local savefile = "/tmp/test-llm-new.sav"
		cleanup(savefile)

		local exit_code, output = run_command("lua5.4 llm.lua --new-game --save " .. shell_quote(savefile))
		assert.assert_equal(exit_code, 0)
		assert.assert_match(output, "West of House")
		assert.assert_equal(read_file(savefile .. ".actions"), "")

		cleanup(savefile)
	end)

	t.it("should append structured action history entries", function(assert)
		local savefile = "/tmp/test-llm-history.sav"
		cleanup(savefile)
		run_command("lua5.4 llm.lua --new-game --save " .. shell_quote(savefile))

		local exit_code, output = run_command("lua5.4 llm.lua --action \"open mailbox\" --save " .. shell_quote(savefile))
		local history = read_file(savefile .. ".actions") or ""

		assert.assert_equal(exit_code, 0)
		assert.assert_match(output, "mailbox")
		assert.assert_match(history, '"game":"zork1"')
		assert.assert_match(history, '"action":"open mailbox"')

		cleanup(savefile)
	end)

	t.it("should replay structured history when snapshot is missing", function(assert)
		local savefile = "/tmp/test-llm-replay.sav"
		cleanup(savefile)
		local exit_code, output = run_command(
			"rm -f " .. shell_quote(savefile) .. " " .. shell_quote(savefile .. ".actions") ..
			" && lua5.4 llm.lua --new-game --save " .. shell_quote(savefile) ..
			" && lua5.4 llm.lua --action \"open mailbox\" --save " .. shell_quote(savefile) ..
			" && rm -f " .. shell_quote(savefile) ..
			" && lua5.4 llm.lua --action \"take leaflet\" --save " .. shell_quote(savefile)
		)
		assert.assert_equal(exit_code, 0)
		assert.assert_match(output, "Taken")

		cleanup(savefile)
	end)

	t.it("should resume across processes using the memory dump when snapshot exists", function(assert)
		local savefile = "/tmp/test-llm-cross-process.sav"
		cleanup(savefile)

		local env1 = boot_zork1_env()
		local game1 = runtime.create_game(env1, true)
		game1:start()
		local open_output = game1:resume("open mailbox")
		assert.assert_match(open_output, "leaflet")
		assert.assert_true(env1.SAVE(savefile))

		local env2 = boot_zork1_env()
		assert.assert_true(env2.RESTORE(savefile))
		_G._LLM_RESTORED = true
		local game2 = runtime.create_game(env2, true)
		game2:start()
		local take_output = game2:resume("take leaflet")
		_G._LLM_RESTORED = nil

		assert.assert_match(take_output, "Taken")
		cleanup(savefile)
	end)

	t.it("should resume across processes from the initial memory dump without history", function(assert)
		local savefile = "/tmp/test-llm-dump-only.sav"
		cleanup(savefile)

		local env1 = boot_zork1_env()
		local game1 = runtime.create_game(env1, true)
		game1:start()
		assert.assert_true(env1.SAVE(savefile))

		local env2 = boot_zork1_env()
		assert.assert_true(env2.RESTORE(savefile))
		_G._LLM_RESTORED = true
		local game2 = runtime.create_game(env2, true)
		game2:start()
		local open_output = game2:resume("open mailbox")
		assert.assert_match(open_output, "leaflet")
		assert.assert_true(env2.SAVE(savefile))

		local env3 = boot_zork1_env()
		assert.assert_true(env3.RESTORE(savefile))
		_G._LLM_RESTORED = true
		local game3 = runtime.create_game(env3, true)
		game3:start()
		local take_output = game3:resume("take leaflet")
		_G._LLM_RESTORED = nil

		assert.assert_match(take_output, "Taken")
		cleanup(savefile)
	end)

	t.it("should preserve Limehouse noun lookup after taking all across processes", function(assert)
		local savefile = "/tmp/test-llm-limehouse-vocabulary.sav"
		cleanup(savefile)
		local game = " --game limehouse-killings"
		local save = " --save " .. shell_quote(savefile)

		local new_code = run_command("lua5.4 llm.lua --new-game" .. save .. game)
		local north_code = run_command("lua5.4 llm.lua --action \"go north\"" .. save .. game)
		local take_code, take_output = run_command("lua5.4 llm.lua --action \"take all\"" .. save .. game)
		local inventory_code, inventory_output = run_command("lua5.4 llm.lua --action \"inventory\"" .. save .. game)
		local examine_code, examine_output = run_command("lua5.4 llm.lua --action \"examine glass\"" .. save .. game)

		assert.assert_equal(new_code, 0)
		assert.assert_equal(north_code, 0)
		assert.assert_equal(take_code, 0)
		assert.assert_match(take_output, "take the magnifying glass")
		assert.assert_equal(inventory_code, 0)
		assert.assert_match(inventory_output, "magnifying glass")
		assert.assert_equal(examine_code, 0)
		assert.assert_match(examine_output, "lens clear and strong")

		cleanup(savefile)
	end)

	t.it("should replay legacy raw-line history", function(assert)
		local savefile = "/tmp/test-llm-legacy.sav"
		cleanup(savefile)
		local file = _G.assert(io.open(savefile .. ".actions", "w"))
		file:write("open mailbox\n")
		file:close()

		local exit_code, output = run_command("lua5.4 llm.lua --action \"take leaflet\" --save " .. shell_quote(savefile))
		assert.assert_equal(exit_code, 0)
		assert.assert_match(output, "Taken")

		cleanup(savefile)
	end)

	t.it("should reject history from a different game", function(assert)
		local savefile = "/tmp/test-llm-mismatch.sav"
		cleanup(savefile)
		local file = _G.assert(io.open(savefile .. ".actions", "w"))
		file:write('{"time":1,"game":"other-game","action":"look"}\n')
		file:close()

		local exit_code, output = run_command("lua5.4 llm.lua --action \"look\" --save " .. shell_quote(savefile))
		assert.assert_not_equal(exit_code, 0)
		assert.assert_match(output, "History file belongs to game")

		cleanup(savefile)
	end)

	t.it("should preserve Lurking Horror clocks and function exits across processes", function(assert)
		local savefile = "/tmp/test-llm-lurking-horror.sav"
		cleanup(savefile)
		local suffix = " --game lurkinghorror --save " .. shell_quote(savefile)

		local code, opening = run_command("lua5.4 llm.lua --new-game" .. suffix)
		assert.assert_equal(code, 0)
		assert.assert_match(opening, "Release 15 / Serial number 870918")
		local _, hacker_descriptions = opening:gsub(
			"Sitting at a terminal is a hacker whom you recognize%.", "")
		assert.assert_equal(hacker_descriptions, 1)
		local x_code, x_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("x pc") .. suffix)
		assert.assert_equal(x_code, 0)
		assert.assert_match(x_output, "HELP key")
		local inventory_code, inventory_output = run_command(
			"lua5.4 llm.lua --action inventory" .. suffix)
		assert.assert_equal(inventory_code, 0)
		assert.assert_match(inventory_output, "assignment")
		local talk_code, talk_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("talk to hacker") .. suffix)
		assert.assert_equal(talk_code, 0)
		assert.assert_true(not talk_output:match("I don't know the word"))
		local help_code, help_output = run_command(
			"lua5.4 llm.lua --action help" .. suffix)
		assert.assert_equal(help_code, 0)
		assert.assert_match(help_output, "Perhaps you should turn on the computer")
		local outlet_code, outlet_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("examine outlet") .. suffix)
		assert.assert_equal(outlet_code, 0)
		assert.assert_match(outlet_output, "nothing special")
		local ask_code = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("ask hacker") .. suffix)
		assert.assert_equal(ask_code, 0)
		local master_code, master_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("ask hacker about master") .. suffix)
		assert.assert_equal(master_code, 0)
		assert.assert_match(master_output, "master keys")
		local power_code = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("turn on pc") .. suffix)
		assert.assert_equal(power_code, 0)
		local examine_code, examine_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("examine pc") .. suffix)
		assert.assert_equal(examine_code, 0)
		assert.assert_match(examine_output, "On the screen you see a HELP key%.")
		local login_code, login_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("type 872325412") .. suffix)
		assert.assert_equal(login_code, 0)
		assert.assert_match(login_output, "PASSWORD PLEASE")
		local password_code = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("type uhlersoth") .. suffix)
		assert.assert_equal(password_code, 0)
		local menu_code, menu_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("examine pc") .. suffix)
		assert.assert_equal(menu_code, 0)
		assert.assert_match(menu_output, "On the screen you see a menu box%.")
		for _ = 1, 12 do
			local wait_code, wait_output = run_command("lua5.4 llm.lua --action wait" .. suffix)
			assert.assert_equal(wait_code, 0)
			assert.assert_true(not wait_output:match("ERROR:"))
		end
		local south_code, south_output = run_command("lua5.4 llm.lua --action south" .. suffix)
		assert.assert_equal(south_code, 0)
		assert.assert_match(south_output, "second floor of the Computer Center")
		local look_code, look_output = run_command("lua5.4 llm.lua --action look" .. suffix)
		assert.assert_equal(look_code, 0)
		assert.assert_match(look_output, "Second Floor")
		local button_code, button_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("examine call button") .. suffix)
		assert.assert_equal(button_code, 0)
		assert.assert_match(button_output, "up%-arrow or the down%-arrow")
		local west_code, west_output = run_command("lua5.4 llm.lua --action west" .. suffix)
		assert.assert_equal(west_code, 0)
		assert.assert_match(west_output, "Kitchen")

		cleanup(savefile)
	end)

	t.it("should continue Lurking Horror quit confirmation across processes", function(assert)
		local savefile = "/tmp/test-llm-lurking-horror-quit.sav"
		cleanup(savefile)
		local suffix = " --game lurkinghorror --save " .. shell_quote(savefile)

		local new_code = run_command("lua5.4 llm.lua --new-game" .. suffix)
		assert.assert_equal(new_code, 0)
		local quit_code, quit_output = run_command("lua5.4 llm.lua --action quit" .. suffix)
		assert.assert_equal(quit_code, 0)
		assert.assert_match(quit_output, "Do you wish to leave the game")
		local yes_code, yes_output = run_command("lua5.4 llm.lua --action y" .. suffix)
		assert.assert_equal(yes_code, 0)
		assert.assert_true(not yes_output:match("I don't know the word"))

		cleanup(savefile)
	end)

	t.it("should keep the Lurking Horror dream sequence interactive", function(assert)
		local savefile = "/tmp/test-llm-lurking-horror-dream.sav"
		cleanup(savefile)
		local suffix = " --game lurkinghorror --save " .. shell_quote(savefile)
		local commands = {
			"turn on pc", "type 872325412", "type uhlersoth",
			"edit classics paper", "touch paper", "read paper",
			"touch more", "touch more", "touch more", "touch more",
			"wait", "wait", "wait", "wait",
		}

		local new_code = run_command("lua5.4 llm.lua --new-game" .. suffix)
		assert.assert_equal(new_code, 0)
		for _, command in ipairs(commands) do
			local code, output = run_command(
				"lua5.4 llm.lua --action " .. shell_quote(command) .. suffix)
			assert.assert_equal(code, 0)
			assert.assert_true(not output:match("It sounds like supplication"))
		end
		local examine_code, examine_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("examine stone") .. suffix)
		assert.assert_equal(examine_code, 0)
		assert.assert_match(examine_output, "smooth, shiny piece")
		local take_code, take_output = run_command(
			"lua5.4 llm.lua --action " .. shell_quote("take stone") .. suffix)
		assert.assert_equal(take_code, 0)
		assert.assert_match(take_output, "Taken")
		assert.assert_match(take_output, "dimness becomes darkness")
		local first_wait_code, first_wait_output = run_command(
			"lua5.4 llm.lua --action wait" .. suffix)
		assert.assert_equal(first_wait_code, 0)
		assert.assert_match(first_wait_output, "darkness before you, now visible, is a creature")
		local second_wait_code, second_wait_output = run_command(
			"lua5.4 llm.lua --action wait" .. suffix)
		assert.assert_equal(second_wait_code, 0)
		assert.assert_match(second_wait_output, "you fall unconscious")
		assert.assert_match(second_wait_output, "Terminal Room")

		cleanup(savefile)
	end)
end)

local success = test.summary()
os.exit(success and 0 or 1)
