#!/usr/bin/env lua5.4
-- Generic ZIL test runner
-- Usage: lua5.4 run-zil-test.lua test-name
--   e.g., lua5.4 run-zil-test.lua tests.test-simple-new

local GREEN = "\27[1;32m"
local RED = "\27[1;31m"
local NEUTRAL = "\27[36m"
local RESET = "\27[0m"

local success = true
local TEST_FAILURE_PREFIX = "__ZIL_TEST_FAILURE__:"

local function breadcrumb_label()
	local step = rawget(_G, "TEST_BREADCRUMB_STEP")
	local command = rawget(_G, "TEST_BREADCRUMB_COMMAND")
	if type(step) == "number" and type(command) == "string" and command ~= "" then
		command = command:match("^%s*(.-)%s*$")
		return string.format("[step %d] %s", step, command)
	end
	return nil
end

local function format_assertion(message)
	local breadcrumb = breadcrumb_label()
	if breadcrumb then
		return breadcrumb .. " => " .. message
	end
	return message
end

local function fail_fast(message)
	success = false
	error(TEST_FAILURE_PREFIX .. (message or "Assertion failed"), 0)
end

-- ASSERT that checks ALL conditions and prints [PASS] only if ALL are truthy
function ASSERT(msg, ...)
	for _, condition in ipairs {...} do
		if not condition then
			print(RED .. "[FAIL] " .. format_assertion(msg or "Assertion failed") .. RESET)
			fail_fast(msg)
		end
	end
	print(GREEN .. "[PASS] " .. format_assertion(msg or "Assertion passed") .. RESET)
	return true
end

function ASSERT_TEXT(expected, ok, actual)
	local label = format_assertion(expected)
	if ok and actual:lower():find(expected:lower(), 1, true) then
		print(GREEN .. "[PASS] " .. label .. RESET)
		return true
	else
		print(RED .. "[FAIL] " .. label .. '\n' .. actual .. RESET)
		fail_fast(expected)
	end
end

function ASSERT_NOT_TEXT(unexpected, ok, actual)
	local label = format_assertion("not: " .. unexpected)
	if ok and not actual:lower():find(unexpected:lower(), 1, true) then
		print(GREEN .. "[PASS] " .. label .. RESET)
		return true
	else
		print(RED .. "[FAIL] " .. label .. '\n' .. actual .. RESET)
		fail_fast("Unexpected text: " .. unexpected)
	end
end

local zil = require "zilscript"
require "zilscript.bootstrap"

-- zil.config.save_lua = true

-- Set up direct output (bypass ZIL's buffering system)
-- _G['io_write'] = io.write
-- _G['io_flush'] = io.flush

-- Override RANDOM function for deterministic tests
local seed = 0
_G.n = seed
function RANDOM(max)
  local m = _G.n
  _G.n = _G.n + 1
  return m % max + 1
end

-- Load the test module from command line argument
local test_module = arg[1]
if not test_module then
	print("Error: No test module specified")
	print("Usage: lua5.4 run-zil-test.lua tests.test-name")
	os.exit(1)
end

print("Running ZIL test: " .. test_module)
require(test_module)

if type(FINALIZE_REFERENCES) == "function" then FINALIZE_REFERENCES() end
if type(FINALIZE_SYNTAX) == "function" then FINALIZE_SYNTAX() end

if type(CAPTURE_RESTART_STATE) == "function" then
	CAPTURE_RESTART_STATE()
end

-- Run the RUN_TEST routine
local ok, err = pcall(RUN_TEST)

if not ok then
	local err_text = tostring(err)
	if err_text:find(TEST_FAILURE_PREFIX, 1, true) then
		-- Assertion details were already printed at the failure site.
	else
		error(err, 0)
	end
end

-- Flush any remaining output
io.flush()

os.exit(success and 0 or 1)
