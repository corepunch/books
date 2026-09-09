#!/usr/bin/env lua
-- Run all unit tests

-- Initialize ZIL require system
require 'zilscript'

local test_files = {
	"tests/test_compiler.lua",
	"tests/test_check_vocab.lua",
	"tests/test_choice_widget.lua",
	"tests/test_companion.lua",
	"tests/test_comprehensive_accuracy.lua",
	"tests/test_defmac.lua",
	"tests/test_framework.lua",
	"tests/test_line_accuracy.lua",
	"tests/test_llm.lua",
	"tests/test_macro_expansion.lua",
	"tests/test_parser.lua",
	"tests/test_require_system.lua",
	"tests/test_runtime.lua",
	"tests/test_sourcemap_integration.lua",
	"tests/test_sourcemap.lua",
	"tests/test_typescript_modules.lua",
}

local all_passed = true

print("Running ZIL Runtime Unit Tests")
print(string.rep("=", 60))

for _, test_file in ipairs(test_files) do
	print("\n" .. test_file)
	local ok, why, code = os.execute("lua " .. test_file)
	local exit_code
	if type(ok) == "number" then
		-- Lua 5.1: os.execute returns a numeric exit status
		exit_code = ok
	elseif ok == true then
		-- Lua 5.2+: success indicated by true
		exit_code = 0
	else
		-- Lua 5.2+: failure; use returned exit code or default to 1
		exit_code = code or 1
	end
	if exit_code ~= 0 then
		all_passed = false
	end
end

print("\n" .. string.rep("=", 60))
if all_passed then
	print("All unit tests passed!")
	os.exit(0)
else
	print("Some unit tests failed!")
	os.exit(1)
end
