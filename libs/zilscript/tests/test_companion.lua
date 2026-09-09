#!/usr/bin/env lua

local test = require 'tests.test_framework'
local runtime = require 'zilscript.runtime'

test.describe("Companion ZIL integration", function(t)
	t.it("should play the Zork I opening from intent-card IDs", function(assert)
		local env = runtime.create_game_env()
		assert.assert_true(runtime.init(env, true))
		env.require("zilscript")
		assert.assert_true(runtime.load_modules(
			env,
			{"infocom.zork1.zork1"},
			{silent = true}
		))

		local loaded, load_error = pcall(
			env.require,
			"infocom.zork1.companion"
		)
		assert.assert_true(loaded, tostring(load_error))

		local game = runtime.create_game(env, true)
		game:start()

		local choices = env.COMPANION_QUERY().choices
		local function count_group(choices, group)
			local count = 0
			for _, choice in ipairs(choices) do
				if choice.group == group then count = count + 1 end
			end
			return count
		end

		assert.assert_true(#choices >= 5)
		assert.assert_true(count_group(choices, "scene") >= 2)
		assert.assert_true(count_group(choices, "move") >= 3)

		local function choose(id)
			local selected = env.COMPANION_SELECT(id)
			assert.assert_true(selected.ok, id .. ": " .. tostring(selected.error))
			if selected.ok then game:resume(selected.command) end
		end

		choose("west-house.open-mailbox")
		choose("west-house.take-leaflet")
		choose("west-house.go-south")
		choose("south-house.go-behind")
		choose("east-house.open-window")
		choose("east-house.enter-window")
		choose("kitchen.enter-living-room")
		choose("living-room.take-lamp")
		choose("living-room.take-sword")
		choose("living-room.move-rug")
		choose("living-room.open-trap-door")
		choose("living-room.light-lamp")
		choose("living-room.descend")

		assert.assert_equal(env.HERE, env.CELLAR)
		assert.assert_true(env.FSETQ(env.LAMP, env.ONBIT))
		assert.assert_true(env.INQ(env.LAMP, env.WINNER))
	end)
end)

local success = test.summary()
os.exit(success and 0 or 1)
