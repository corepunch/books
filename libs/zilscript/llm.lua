#!/usr/bin/env lua
-- LLM Play Mode
-- Allows LLMs to interact with the game programmatically
--
-- Usage:
--   lua llm.lua --action "look" [--save savefile.sav] [--game zork1]
--   lua llm.lua --action "take sword" --save game.sav
--   lua llm.lua --new-game --save game.sav  (start new game and save initial state)
--
-- Output: JSON with game response and state info

local runtime = require 'zilscript.runtime'

-- Parse command line arguments
local args = {}
local i = 1
while i <= #arg do
    local a = arg[i]
    if a == "--action" or a == "-a" then
        i = i + 1
        args.action = arg[i]
    elseif a == "--save" or a == "-s" then
        i = i + 1
        args.savefile = arg[i]
    elseif a == "--game" or a == "-g" then
        i = i + 1
        args.game = arg[i]
    elseif a == "--new-game" then
        args.new_game = true
    elseif a == "--help" or a == "-h" then
        args.help = true
    end
    i = i + 1
end

if args.help then
    io.write([[
LLM Play Mode - Interact with ZIL games programmatically

Usage:
  lua llm.lua --action "command" [options]
  lua llm.lua --new-game [options]

Options:
  --action, -a "cmd"   Execute this command and exit
    --save, -s file      Restore from this memory dump file and keep action history in file.actions
  --game, -g name      Game to play (default: zork1)
  --new-game           Start a new game (even if save file exists)
  --help, -h           Show this help

Output: JSON with fields:
  - ok: boolean (success)
  - output: string (game response text)
  - room: string (current room name, if available)
  - savefile: string (path to saved state)
    - historyfile: string (path to the action backlog)
  - error: string (error message, if failed)

Examples:
  lua llm.lua --new-game --save zork1.sav
  lua llm.lua --action "look" --save zork1.sav
  lua llm.lua --action "take lamp" --save zork1.sav
  lua llm.lua --action "go north" --save zork1.sav
]])
    os.exit(0)
end

-- Game configurations
local GAMES = {
    zork1 = {
        modules = {
            "infocom.zork1.globals",
            "infocom.zork1.clock",
            "infocom.zork1.parser",
            "infocom.zork1.verbs",
            "infocom.zork1.actions",
            "infocom.zork1.syntax",
            "infocom.zork1.dungeon",
            "infocom.zork1.main",
        }
    },
    zork3 = {
        modules = {
            "infocom.zork3.gglobals",
            "infocom.zork3.gclock",
            "infocom.zork3.gparser",
            "infocom.zork3.gverbs",
            "infocom.zork3.gsyntax",
            "infocom.zork3.3actions",
            "infocom.zork3.3dungeon",
            "infocom.zork3.gmain",
        }
    },
    lurkinghorror = {
        modules = {"infocom.lurkinghorror.h1"}
    },
    spellbreaker = {
        modules = {"infocom.spellbreaker.z6"}
    },
    ["limehouse-killings"] = {
        modules = {"books.limehouse-killings.limehouse-killings"}
    },
    ["blackwood-horror"] = {
        modules = {"books.blackwood-horror.blackwood-horror"}
    },
    ["wondertown"] = {
        modules = {"books.wondertown.wondertown"}
    },
    planetfall = {
        modules = {
            "infocom.planetfall.syntax",
            "infocom.planetfall.misc",
            "infocom.planetfall.globals",
            "infocom.planetfall.parser",
            "infocom.planetfall.verbs",
            "infocom.planetfall.compone",
            "infocom.planetfall.comptwo",
        }
    },
}

local game_name = args.game or "zork1"
local game_config = GAMES[game_name]
if not game_config then
    local available = {}
    for k in pairs(GAMES or {}) do table.insert(available, k) end
    io.write(string.format('{"ok":false,"error":"Unknown game: %s. Available: %s"}\n',
        game_name, table.concat(available, ", ")))
    os.exit(1)
end

-- Capture output function
local captured_output = {}
local function capture_print(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    table.insert(captured_output, table.concat(parts, "\t"))
end

local function capture_io_write(...)
    for i = 1, select("#", ...) do
        local s = tostring(select(i, ...))
        table.insert(captured_output, s)
    end
end

local function flush_capture()
    local result = table.concat(captured_output)
    captured_output = {}
    return result
end

-- Override io_write and io_flush in the game environment
-- to capture output instead of printing to terminal
local function setup_capture(env)
    -- Store original functions
    local original_io_write = _G.io_write
    local original_io_flush = _G.io_flush
    
    -- Override globally for the game environment
    _G.io_write = function(...)
        capture_io_write(...)
    end
    
    _G.io_flush = function()
        return flush_capture()
    end
    
    return function()
        -- Restore function
        _G.io_write = original_io_write
        _G.io_flush = original_io_flush
    end
end

-- Create game environment
local env = runtime.create_game_env()

-- Load bootstrap
if not runtime.init(env) then
    io.write('{"ok":false,"error":"Failed to initialize ZIL runtime"}\n')
    os.exit(1)
end

-- Install ZIL support
env.require('zilscript')

-- Load game modules
if not runtime.load_modules(env, game_config.modules, {silent = true}) then
    io.write('{"ok":false,"error":"Failed to load game modules"}\n')
    os.exit(1)
end

-- Create game coroutine
local game = runtime.create_game(env, true)

-- Helper to escape strings for JSON
local function json_escape(s)
    if not s then return "null" end
    s = s:gsub('\\', '\\\\')
    s = s:gsub('"', '\\"')
    s = s:gsub('\n', '\\n')
    s = s:gsub('\r', '\\r')
    s = s:gsub('\t', '\\t')
    -- Remove ANSI escape codes
    s = s:gsub('\27%[[0-9;]*m', '')
    return '"' .. s .. '"'
end

local function json_unescape(s)
    s = s:gsub('\\n', '\n')
    s = s:gsub('\\r', '\r')
    s = s:gsub('\\t', '\t')
    s = s:gsub('\\"', '"')
    s = s:gsub('\\\\', '\\')
    return s
end

local function current_working_dir()
    local pipe = io.popen("pwd", "r")
    if not pipe then
        return nil
    end
    local path = pipe:read("*l")
    pipe:close()
    return path
end

local function normalize_path(path)
    if not path or path == "" then
        return path
    end
    if path:sub(1, 1) == "/" then
        return path
    end
    local cwd = current_working_dir()
    if not cwd or cwd == "" then
        return path
    end
    return cwd .. "/" .. path
end

local restore

local function write_error_and_exit(message)
    restore()
    message = tostring(message):gsub('\27%[[0-9;]*m', '')
    io.write("ERROR: " .. message .. "\n")
    os.exit(1)
end

-- Helper to get current room name
local function get_room_name(env)
    local ok, result = pcall(function()
        local here = rawget(_G, "HERE") or rawget(env, "HERE")
        if here and type(here) == "number" then
            -- Try to get the DESC property
            local pqdesc = rawget(_G, "PQDESC") or rawget(env, "PQDESC")
            if pqdesc then
                local desc = env.GETP and env.GETP(here, pqdesc)
                if desc and type(desc) == "number" then
                    return env.mem and env.mem:string(desc)
                elseif type(desc) == "string" then
                    return desc
                end
            end
        end
        return nil
    end)
    return ok and result or nil
end

local function get_score_info(env)
    local ok, result = pcall(function()
        local score = rawget(_G, "SCORE") or rawget(env, "SCORE")
        local moves = rawget(_G, "MOVES") or rawget(env, "MOVES")
        local max = rawget(_G, "SCORE_MAX") or rawget(env, "SCORE_MAX")
        if score and moves then
            return { score = score, moves = moves, max = max }
        end
        return nil
    end)
    return ok and result or nil
end

-- Main logic
restore = setup_capture(env)

local savefile = normalize_path(args.savefile or "savefile.sav")
local historyfile = savefile .. ".actions"
local game_started = false
local resumed_from_dump = false
local resumed_from_history = false

local function file_exists(path, mode)
    local file = io.open(path, mode or "r")
    if not file then
        return false
    end
    file:close()
    return true
end

local function read_action_history(path)
    local actions = {}
    local file = io.open(path, "r")
    if not file then
        return actions
    end
    for line in file:lines() do
        if line ~= "" then
            local entry = { action = line }
            local encoded_time, encoded_game, encoded_action = line:match('^%{"time":(%d+),"game":"(.*)","action":"(.*)"%}$')
            if encoded_action then
                entry = {
                    time = tonumber(encoded_time),
                    game = json_unescape(encoded_game),
                    action = json_unescape(encoded_action),
                }
            else
                local legacy_time, legacy_action = line:match('^%{"time":(%d+),"action":"(.*)"%}$')
                if legacy_action then
                    entry = {
                        time = tonumber(legacy_time),
                        action = json_unescape(legacy_action),
                    }
                end
            end
            actions[#actions + 1] = entry
        end
    end
    file:close()
    return actions
end

local function reset_action_history(path)
    local file, err = io.open(path, "w")
    if not file then
        return false, err
    end
    file:close()
    return true
end

local function append_action_history(path, action)
    local file, err = io.open(path, "a")
    if not file then
        return false, err
    end
    file:write(string.format('{"time":%d,"game":%s,"action":%s}\n', os.time(), json_escape(game_name), json_escape(action)))
    file:close()
    return true
end

local function start_game()
    local output = game:start()
    if resumed_from_dump then
        _G._LLM_RESTORED = nil
    end
    game_started = true
    return output
end

local function resume_action(action)
    local ok, result = pcall(function()
        return game:resume(action)
    end)
    if not ok then
        error(tostring(result))
    end
    if type(result) == "string" then
        return result
    elseif type(result) == "table" and result.status then
        return string.format("[%s] %s", result.status, result.message or "")
    end
    return ""
end

local function replay_action_history(path)
    local actions = read_action_history(path)
    if #actions == 0 then
        return false
    end
    for _, entry in ipairs(actions) do
        if entry.game and entry.game ~= game_name then
            error(string.format("History file belongs to game '%s', not '%s'", entry.game, game_name))
        end
    end
    start_game()
    for _, entry in ipairs(actions) do
        resume_action(entry.action)
    end
    return true
end

if not args.new_game then
    if file_exists(savefile, "rb") then
        local ok, restore_err = pcall(function()
            env.RESTORE(savefile)
        end)
        if ok then
            _G._LLM_RESTORED = true
            resumed_from_dump = true
        else
            _G._LLM_RESTORED = nil
        end
    end

    if not resumed_from_dump and file_exists(historyfile, "r") then
        local ok, replayed_or_err = pcall(replay_action_history, historyfile)
        if not ok then
            write_error_and_exit(replayed_or_err)
        end
        resumed_from_history = replayed_or_err and true or false
    end
end

-- Helper to execute an action and get output
local function execute_action(action)
    if not game_started then
        start_game()
    end
    return resume_action(action)
end

-- A memory dump cannot serialize a coroutine suspended inside YES?.  If the
-- preceding one-command invocation stopped at a confirmation prompt, recreate
-- that prompt in the fresh coroutine before delivering the answer.
local function execute_action_with_confirmation(action)
    local answer = action:lower():match("^%s*(.-)%s*$")
    if answer == "y" or answer == "yes" or answer == "n" or answer == "no" then
        local history = read_action_history(historyfile)
        local previous = history[#history]
        local prompt_action = previous and previous.action:lower():match("^%s*(.-)%s*$")
        if prompt_action == "quit" or prompt_action == "q"
                or prompt_action == "restart" or prompt_action == "restar" then
            execute_action(previous.action)
        end
    end
    return execute_action(action)
end

-- If we have an action, execute it
if args.action then
    local ok, output = pcall(execute_action_with_confirmation, args.action)
    
    if not ok then
        write_error_and_exit(output)
    end
    
    -- Get room name
    local room = get_room_name(env)
    
    -- Save game state
    local save_err = nil
    local history_err = nil
    local ok, err = pcall(function()
        env.SAVE(savefile)
    end)
    if not ok then
        save_err = tostring(err)
    end
    local history_ok, history_write_err = append_action_history(historyfile, args.action)
    if not history_ok then
        history_err = tostring(history_write_err)
    end
    
    local score = get_score_info(env)
    restore()
    
    -- Output plain text (exit 0 = success)
    io.write(output)
    if score then
        io.write(string.format("\n%%SCORE%% { \"score\": %d, \"moves\": %d, \"max\": %d }\n",
            score.score, score.moves, score.max or 0))
    end
    os.exit(0)
    
elseif args.new_game then
    -- Start a new game and get initial output
    local ok, result = pcall(start_game)
    
    if not ok then
        write_error_and_exit(result)
    end
    
    local output = ""
    if type(result) == "string" then
        output = result
    end
    
    local room = get_room_name(env)
    
    local history_err = nil
    local history_ok, history_reset_err = reset_action_history(historyfile)
    if not history_ok then
        history_err = tostring(history_reset_err)
    end

    -- Save initial state as a raw memory dump. The action history remains available as a backlog and fallback path.
    local save_err = nil
    local ok, err = pcall(function()
        env.SAVE(savefile)
    end)
    if not ok then
        save_err = tostring(err)
    end
    
    local score = get_score_info(env)
    restore()
    
    -- Output plain text (exit 0 = success)
    io.write(output)
    if score then
        io.write(string.format("\n%%SCORE%% { \"score\": %d, \"moves\": %d, \"max\": %d }\n",
            score.score, score.moves, score.max or 0))
    end
    os.exit(0)
    
else
    write_error_and_exit("No action specified. Use --action or --new-game")
end
