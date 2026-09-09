-- ZIL Runtime loader module
-- Shared functionality for loading and executing ZIL files

local parser = require 'zilscript.parser'
local compiler = require 'zilscript.compiler'
local sourcemap = require 'zilscript.sourcemap'

local M = {}

-- Helper function to convert module name to file path
-- e.g., "zork1.globals" -> "zork1/globals"
local function module_to_path(modname)
	return modname:gsub("%.", "/")
end

-- Helper function to search for a module file
-- Returns file path and file type (".lua" or ".zil") if found, nil otherwise
local function search_module(modname, env)
	local name_path = module_to_path(modname)
	local found_lua, found_zil
	
	-- Search for .lua files using package.path
	for path_pattern in package.path:gmatch("[^;]+") do
		local filepath = path_pattern:gsub("?", name_path)
		local file = io.open(filepath, "r")
		if file then
			file:close()
			found_lua = filepath
			break
		end
	end
	
	-- Search for .zil files using package.zilpath if it exists and ZIL is loaded in env
	if env._ZIL_LOADER_INSTALLED and package.zilpath then
		for path_pattern in package.zilpath:gmatch("[^;]+") do
			local filepath = path_pattern:gsub("?", name_path)
			local file = io.open(filepath, "r")
			if file then
				file:close()
				found_zil = filepath
				break
			end
		end
	end
	
	-- Prefer .zil files if both exist and ZIL loader is installed
	if found_zil and env._ZIL_LOADER_INSTALLED then
		return found_zil, ".zil"
	elseif found_lua then
		return found_lua, ".lua"
	elseif found_zil then
		-- ZIL file exists but loader not installed - error
		error("ZIL file found but ZIL loader not installed. Call env.require('zilscript') first.")
	end
	
	return nil, nil
end

-- Create a per-environment require function
-- This function loads modules into the specific environment
function M.create_env_require(env)
	return function(modname)
		-- Check if already loaded in this environment
		if env._LOADED[modname] ~= nil then
			return env._LOADED[modname]
		end
		
		-- Special handling for 'zilscript' module - installs ZIL loader into this environment
		if modname == 'zilscript' then
			local base = require 'zilscript.base'
			base.install_into(env)
			env._LOADED[modname] = true
			return true
		end
		
		-- Search for the module file
		local filepath, filetype = search_module(modname, env)
		
		if not filepath then
			error("module '" .. modname .. "' not found in environment")
		end
		
		-- Load and compile the module
		local code
		if filetype == ".zil" then
			-- Compile ZIL file
			local ok, ast, err = pcall(parser.parse_file, filepath)
			if not ok then
				error("Failed to parse " .. filepath .. ": " .. tostring(ast))
			end
			if not ast then
				error("Failed to parse " .. filepath .. ": " .. (err or "unknown error"))
			end
			
			local basename = 'zil_'..(filepath:match("^.+[/\\](.+)$") or filepath):gsub(".zil", ".lua")
			local result = compiler.compile(ast, basename)
			code = result.combined
		else
			-- Load Lua file
			local file = assert(io.open(filepath, "r"))
			code = file:read("*a")
			file:close()
		end
		
		-- Execute the code in the environment
		env._G = env
		local chunk, err = load(code, '@'..filepath, 't', env)
		if not chunk then
			error("Error loading module '" .. modname .. "': " .. sourcemap.translate(err))
		end
		
		local ok, result = pcall(chunk)
		if not ok then
			local translated_err = sourcemap.translate(tostring(result))
			error("Runtime error in module '" .. modname .. "': " .. translated_err)
		end
		
		-- Cache the result
		if result == nil then
			result = true  -- Modules that don't return anything default to true
		end
		env._LOADED[modname] = result
		
		return result
	end
end

-- Create a standard game environment with all required globals
function M.create_game_env()
	local env = { 
		print = print, 
		io = io,
		os = os,
		coroutine = coroutine,
		setmetatable = setmetatable,
		getmetatable = getmetatable,
		ipairs = ipairs,
		pairs = pairs,
		table = table,
		tostring = tostring,
		tonumber = tonumber,
		type = type,
		string = string,
		pcall = pcall,
		load = load,
		rawget = rawget,
		rawset = rawset,
		error = error,
		assert = assert,
		debug = debug,
		select = select,
		math = math,
		next = next,
		translate = sourcemap.translate,
		_LOADED = {},  -- Per-environment module cache
		package = package,  -- Make package available for INSERT_FILE
	}
	
	-- Create per-environment require function
	env.require = M.create_env_require(env)
	
	return env
end

-- Execute a Lua string in the given environment
-- Returns true on success, false on failure
function M.execute(code, name, env, silent)
	env._G = env
	local chunk, err = load(code, '@'..name, 't', env)
	if not chunk then
		if not silent then
			print("Error: " .. err)
		end
		return false
	end
	
	local ok, run_err = pcall(chunk)
	if not ok then
		if type(env.IS_ZIL_CONTROL_SIGNAL) == "function" 
			and env.IS_ZIL_CONTROL_SIGNAL(run_err) then
			error(run_err, 0)
		end
		local translated_err = sourcemap.translate(tostring(run_err))
		-- if not silent then
			print("Runtime error: " .. translated_err)
		-- end
		return false
	end
	
	return true
end

-- Load and execute the bootstrap file
-- Returns true on success, false on failure
function M.init(env, silent)
	local path = package.searchpath("zilscript.bootstrap", package.path)
	local file = assert(io.open(path, "r"))
	local bootstrap_code = file:read("*a")
	file:close()
	return M.execute(bootstrap_code, 'bootstrap', env, silent)
end

-- Compile and execute a list of ZIL files
-- Options table can contain:
--   - save_lua: if true, saves compiled .lua files to disk
--   - silent: if true, suppresses load messages
-- Returns true if all files loaded successfully
function M.load_zil_files(files, env, options)
	options = options or {}
	
	for _, f in ipairs(files) do
		local ok, ast, err = pcall(parser.parse_file, f)
		if not ok then
			-- pcall caught an exception thrown during parsing (e.g., syntax error)
			if not options.silent then
				print("Failed to parse " .. f .. ": " .. tostring(ast))
			end
			return false
		end
		if not ast then
			-- parse_file successfully returned nil (e.g., file not found)
			if not options.silent then
				print("Failed to parse " .. f .. ": " .. (err or "unknown error"))
			end
			return false
		end
		
		local basename = 'zil_'..(f:match("^.+[/\\](.+)$") or f):gsub(".zil", ".lua")
		local result = compiler.compile(ast, basename)
		
		-- Optionally save the compiled Lua file
		if options.save_lua then
			local file = io.open(basename, "w")
			if file then
				file:write(result.combined)
				file:close()
			end
		end
		
		-- Execute the compiled code
		if not M.execute(result.combined, basename, env, options.silent) then
			if not options.silent then
				print("Failed to load " .. f)
			end
			return false
		end
	end

	-- Resolve any SYNTAX entries that were deferred because action functions
	-- weren't defined yet (e.g., syntax.zil loaded before verbs.zil)
	M.execute("if FINALIZE_REFERENCES then FINALIZE_REFERENCES() end; if FINALIZE_SYNTAX then FINALIZE_SYNTAX() end", 'finalize-syntax', env, options.silent)

	if type(env.CAPTURE_RESTART_STATE) == "function" then
		env.CAPTURE_RESTART_STATE()
	end
		
	return true
end

-- Load a list of modules into the given environment
-- Options table can contain:
--   - silent: if true, suppresses load messages
-- Returns true if all modules loaded successfully
function M.load_modules(env, modules, options)
	options = options or {}
	local seen = {}
	
	for _, modname in ipairs(modules) do
		-- If we've seen this module before in this load_modules call,
		-- clear it from the cache to force a reload
		-- This maintains backward compatibility with tests that load the same file twice
		if seen[modname] then
			env._LOADED[modname] = nil
		end
		seen[modname] = true
		
		local ok, err = pcall(env.require, modname)
		if not ok then
			if not options.silent then
				print("Failed to load module " .. modname .. ": " .. tostring(err))
			end
			return false
		end
	end

	-- Resolve any SYNTAX entries that were deferred because action functions
	-- weren't defined yet (e.g., syntax.zil loaded before verbs.zil)
	M.execute("if FINALIZE_REFERENCES then FINALIZE_REFERENCES() end; if FINALIZE_SYNTAX then FINALIZE_SYNTAX() end", 'finalize-syntax', env, options.silent)

	if type(env.CAPTURE_RESTART_STATE) == "function" then
		env.CAPTURE_RESTART_STATE()
	end
	
	-- REMOVED: FINALIZE_PREPOSITIONS call - prepositions now use pre-allocated array format
	-- M.execute("if FINALIZE_PREPOSITIONS then FINALIZE_PREPOSITIONS() end", 'finalize', env, options.silent)
	
	return true
end

-- Create a coroutine for the game that yields on input
-- Returns a coroutine object
function M.create_game(env, silent)
	local co
	co = coroutine.create(function()
		-- Check if we're restoring from a save (LLM mode)
		local restored = rawget(_G, "_LLM_RESTORED")
		if restored then
			-- Skip GO() initialization, go directly to MAIN_LOOP
			local success = M.execute("MAIN_LOOP()", 'main', env, silent)
			if not success then
				error("Failed to start game: MAIN_LOOP() not defined or failed")
			end
		else
			-- Normal game start
			if type(env.GO) ~= "function" then
				error("Failed to start game: GO() not defined or failed")
			end
		end

		while true do
			local ok, result = pcall(env.GO)
			if ok then
				if not silent then
					print("\n*** Game has ended ***\n")
				end
				return result
			end

			if type(env.IS_ZIL_CONTROL_SIGNAL) == "function"
				and env.IS_ZIL_CONTROL_SIGNAL(result, "restart") then
				-- RESTART restores captured state and re-enters GO().
			elseif type(env.IS_ZIL_CONTROL_SIGNAL) == "function"
				and env.IS_ZIL_CONTROL_SIGNAL(result, "quit") then
				if not silent then
					print("\n*** Game has ended ***\n")
				end
				return
			else
				error(tostring(result), 0)
			end
		end
	end)
	return {
		coroutine = co,
		-- Start the game coroutine (run until it yields at READ)
		-- Returns the initial output (room description etc.)
		start = function(self)
			local ok, output = coroutine.resume(self.coroutine)
			if not ok then
				error(output)
			end
			return output
		end,
		-- Resume the game coroutine with input
		-- Returns: status (boolean), result (any value or error message)
		resume = function (self, input)
			local ok, response = coroutine.resume(self.coroutine, input)
			if not ok then
				error(response)
			end
			return response
		end,
		-- Check if the coroutine is still running
		is_running = function(self) return coroutine.status(self.coroutine) ~= "dead" end,
	}
end


return M
