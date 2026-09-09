#!/usr/bin/env lua5.4

local test = require 'tests.test_framework'

local function shell_quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function write_fixture(name, content)
	local path = "/tmp/zilscript-check-vocab-" .. name .. ".zil"
	local file = assert(io.open(path, "w"))
	file:write(content)
	file:close()
	return path
end

local function run_checker(path)
	local command = "lua5.4 scripts/check-vocab.lua " .. shell_quote(path) .. " 2>&1"
	local pipe = assert(io.popen(command, "r"))
	local output = pipe:read("*a")
	local ok, _, code = pipe:close()
	return ok == true and 0 or code or 1, output
end

test.describe("Vocabulary checker", function(t)
	t.it("accepts adjectives and prepositional DESC text", function(assert)
		local path = write_fixture("valid", [[
<OBJECT KNIFE
      (DESC "blood-stained knife")
      (SYNONYM KNIFE BLADE)
      (ADJECTIVE BLOOD STAINED)>
<OBJECT DOOR
      (DESC "door to the garden")
      (SYNONYM DOOR GATE)>
]])
		local code, output = run_checker(path)
		assert.assert_equal(code, 0)
		assert.assert_match(output, "0 critical")
		os.remove(path)
	end)

	t.it("rejects a printed name with no matching synonym", function(assert)
		local path = write_fixture("invalid", [[
<OBJECT RELIQUARY
      (DESC "ornate reliquary")
      (SYNONYM BOX CASE)>
]])
		local code, output = run_checker(path)
		assert.assert_not_equal(code, 0)
		assert.assert_match(output, "no DESC word appears in SYNONYM")
		os.remove(path)
	end)

	t.it("rejects player-addressable scenery with no printed name", function(assert)
		local path = write_fixture("missing-desc", [[
<OBJECT FOG
      (SYNONYM FOG MIST HAZE)
      (FLAGS NDESCBIT)>
]])
		local code, output = run_checker(path)
		assert.assert_not_equal(code, 0)
		assert.assert_match(output, "object has SYNONYM but no DESC")
		os.remove(path)
	end)

	t.it("rejects FDESC suppressed by NDESCBIT", function(assert)
		local path = write_fixture("suppressed-fdesc", [[
<OBJECT CLOCK
      (DESC "clock")
      (FDESC "A clock dominates the room.")
      (SYNONYM CLOCK)
      (FLAGS NDESCBIT)>
]])
		local code, output = run_checker(path)
		assert.assert_not_equal(code, 0)
		assert.assert_match(output, "FDESC is suppressed by NDESCBIT")
		os.remove(path)
	end)

	t.it("rejects static FDESC shadowing DESCFCN", function(assert)
		local path = write_fixture("shadowed-descfcn", [[
<OBJECT BOILER
      (DESC "boiler")
      (FDESC "A cold boiler is here.")
      (DESCFCN BOILER-DESC-F)
      (SYNONYM BOILER)>
]])
		local code, output = run_checker(path)
		assert.assert_not_equal(code, 0)
		assert.assert_match(output, "untouched FDESC shadows the dynamic DESCFCN")
		os.remove(path)
	end)
end)

local success = test.summary()
os.exit(success and 0 or 1)
