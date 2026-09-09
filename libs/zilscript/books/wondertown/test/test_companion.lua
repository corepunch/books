#!/usr/bin/env lua

local test = require 'tests.test_framework'
local runtime = require 'zilscript.runtime'

test.describe("Wondertown companion integration", function(t)
	t.it("should load companion and query initial choices", function(assert)
		local env = runtime.create_game_env()
		assert.assert_true(runtime.init(env, true))
		env.require("zilscript")
		assert.assert_true(runtime.load_modules(
			env,
			{"books.wondertown.wondertown"},
			{silent = true}
		))

		local loaded, load_error = pcall(
			env.require,
			"books.wondertown.companion"
		)
		assert.assert_true(loaded, tostring(load_error))

		local game = runtime.create_game(env, true)
		game:start()

		-- Verify starting room
		assert.assert_equal(env.HERE, env.WORKSHOP_FLOOR)

		-- Query every eligible companion choice.
		local result = env.COMPANION_QUERY()
		assert.assert_true(result.ok, tostring(result.error))
		local choices = result.choices
		assert.assert_true(#choices >= 3)

		-- Count scene vs move groups
		local scene_count = 0
		local move_count = 0
		for _, choice in ipairs(choices) do
			if choice.group == "scene" then scene_count = scene_count + 1 end
			if choice.group == "move" then move_count = move_count + 1 end
		end
		assert.assert_true(scene_count >= 2)
		assert.assert_true(move_count >= 1)

		-- Verify required IDs are present in the choices.
		local choice_ids = {}
		local choices_by_id = {}
		for _, choice in ipairs(choices) do
			choice_ids[choice.id] = true
			choices_by_id[choice.id] = choice
		end
		-- Should have at least one workshop-floor.* choice
		local has_workshop = false
		for id, _ in pairs(choice_ids) do
			if id:match("^workshop%-floor%.") then has_workshop = true end
		end
		assert.assert_true(has_workshop, "Expected workshop-floor.* companion choice")
		assert.assert_equal(
			choices_by_id["workshop-floor.climb-workbench"].image_key,
			"workshop-floor.climb-workbench"
		)
	end)

	t.it("should play through Act 1 golden path via companion choices", function(assert)
		local env = runtime.create_game_env()
		assert.assert_true(runtime.init(env, true))
		env.require("zilscript")
		assert.assert_true(runtime.load_modules(
			env,
			{"books.wondertown.wondertown"},
			{silent = true}
		))

		local loaded, load_error = pcall(
			env.require,
			"books.wondertown.companion"
		)
		assert.assert_true(loaded, tostring(load_error))

		local game = runtime.create_game(env, true)
		game:start()

		local function choose(id)
			local selected = env.COMPANION_SELECT(id)
			assert.assert_true(selected.ok, id .. ": " .. tostring(selected.error))
			if selected.ok then game:resume(selected.command) end
		end

		-- Act 1: Workshop
		choose("workshop-floor.examine-workbench")
		choose("workshop-floor.climb-workbench")
		assert.assert_equal(env.HERE, env.WORKBENCH_TOP)
		choose("workbench-top.open-repair-book")
		assert.assert_true(env.REPAIR_BOOK_OPEN)
		local book_scene = env.COMPANION_QUERY().scene
		assert.assert_equal(book_scene.key, "workbench.top-open")
		choose("workbench-top.close-repair-book")
		choose("workbench-top.go-down")
		choose("workshop-floor.take-oil-can")
		choose("workshop-floor.go-toolbench")

		-- Tool bench: take key, wind Bertrand
		choose("tool-bench.take-key")
		choose("tool-bench.wind-bertrand")

		-- Climb to countertop
		choose("tool-bench.climb-countertop")

		-- Countertop: open case, take items
		choose("countertop.open-case")
		choose("countertop.take-soldier")
		choose("countertop.take-music-box")
		choose("countertop.take-button")
		choose("countertop.give-button")

		-- Return to workshop, oil ladder
		choose("countertop.go-down")
		choose("tool-bench.go-workshop")
		choose("workshop-floor.oil-ladder")

		-- Climb to loft
		choose("workshop-floor.climb-loft")
		choose("loft.open-box")
		choose("loft.take-doll-arm")
		choose("loft.wind-old-tick")

		-- Go outside
		choose("loft.go-down")
		choose("workshop-floor.go-outside")

		-- Verify we're in snowy alley
		assert.assert_equal(env.HERE, env.SNOWY_ALLEY)

		-- Continue through Act 2
		choose("alley.go-clock-square")
		choose("square.go-mailbox")
		choose("mailbox.take-scarf")
		choose("mailbox.go-square")
		choose("square.go-scrap-yard")

		-- Scrap yard: take head, give to cart
		choose("yard.take-head")
		choose("yard.give-head")

		-- Enter fox den
		choose("yard.go-fox-den")
		choose("den.give-scarf")
		choose("den.tell-tolliver")
		choose("den.take-key")

		-- Return to workshop
		choose("den.go-scrap-yard")
		choose("yard.go-square")
		choose("square.go-alley")
		choose("alley.go-workshop")

		-- Access study
		choose("workshop-floor.wind-clock")
		choose("workshop-floor.wind-clock")
		choose("workshop-floor.climb-loft")
		choose("loft.wind-old-tick")
		choose("loft.go-down")

		-- Enter study
		choose("workshop-floor.enter-study")
		assert.assert_equal(env.HERE, env.TOLLIVER_STUDY)

		-- Read diagram, go to heart
		choose("study.read-diagram")
		choose("study.go-heart")
		assert.assert_equal(env.HERE, env.WORKSHOP_HEART)

		-- Wind heart
		choose("heart.wind-heart")
		assert.assert_true(env.KEY_WOUND)

		-- Place companions
		choose("heart.place-soldier")
		choose("heart.place-music-box")

		-- Verify game won
		assert.assert_true(env.GAME_WON)
	end)

	t.it("should return stable IDs across companion queries", function(assert)
		local env = runtime.create_game_env()
		assert.assert_true(runtime.init(env, true))
		env.require("zilscript")
		assert.assert_true(runtime.load_modules(
			env,
			{"books.wondertown.wondertown"},
			{silent = true}
		))

		local loaded, load_error = pcall(
			env.require,
			"books.wondertown.companion"
		)
		assert.assert_true(loaded, tostring(load_error))

		local game = runtime.create_game(env, true)
		game:start()

		local first_result = env.COMPANION_QUERY()
		local second_result = env.COMPANION_QUERY()

		local second_ids = {}
		for _, choice in ipairs(second_result.choices) do
			second_ids[choice.id] = true
		end
		for _, choice in ipairs(first_result.choices) do
			assert.assert_true(second_ids[choice.id],
				"Companion choice " .. choice.id .. " was not stable")
		end
	end)
end)

local success = test.summary()
os.exit(success and 0 or 1)
