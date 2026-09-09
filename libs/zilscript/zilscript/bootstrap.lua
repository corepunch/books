-- zil_init.lua
-- Equivalent of zil_newstate() in plain Lua

-- === Object Flags ===
ZIL_ObjectFlags = {
  "SACREDBIT", "FIGHTBIT", "TOUCHBIT", "WEARBIT", "SEARCHBIT",
  "NWALLBIT", "NONLANDBIT", "TRANSBIT", "SURFACEBIT", "INVISIBLE",
  "STAGGERED", "OPENBIT", "RLANDBIT", "TRYTAKEBIT", "NDESCBIT",
  "TURNBIT", "READBIT", "TAKEBIT", "CONTBIT", "ONBIT", "FOODBIT",
  "DRINKBIT", "DOORBIT", "CLIMBBIT", "RMUNGBIT", "FLAMEBIT",
  "BURNBIT", "VEHBIT", "TOOLBIT", "WEAPONBIT", "ACTORBIT",
  "LIGHTBIT", "MAZEBIT"
}

D = 0xBAADF00D
N = 0xBAADF00E
TELL_A = 0xBAADF00F
TELL_THE = 0xBAADF010
TELL_CTHE = 0xBAADF011

OQANY=1

PSQOBJECT=128
PSQVERB=64
PSQADJECTIVE=32
PSQDIRECTION=16
PSQPREPOSITION=8
PSQBUZZ_WORD=4

P1QNONE=0
P1QOBJECT=0
P1QVERB=1
P1QADJECTIVE=2
P1QDIRECTION=3

-- Standard room-exit property layouts.  Some Infocom sources (including
-- The Lurking Horror) treat these as substrate-provided constants and leave
-- their local declarations commented out.
REXIT=0
UEXIT=1
NEXIT=2
FEXIT=3
CEXIT=4
DEXIT=5
NEXITSTR=0
FEXITFCN=0
CEXITFLAG=1
CEXITSTR=1
DEXITOBJ=1
DEXITSTR=1

SH=128
SC=64
SIR=32
SOG=16
STAKE=8
SMANY=4
SHAVE=2

-- === Register globals ===
for i, flag in ipairs(ZIL_ObjectFlags) do
  _G[flag] = i
end

-- === Core globals ===
VERBS   = nil
QUEUES  = {}
ROOMS   = {}
PROPERTIES = {}
-- PREPOSITIONS: Pre-allocated array format [0]=count, [1]=word_ptr1, [2]=index1, ...
-- Maximum 128 prepositions, format: index_count, then pairs of (word_ptr, original_index)
PREPOSITIONS = {[0] = 0}  -- Initialize with count = 0
PREPOSITIONS._hash = {}   -- Helper hash for quick lookup during population
ADJECTIVES = {}
ADJ = "ADJ"
ADJECTIVE = "ADJECTIVE"
NOUN = "NOUN"
-- ACTIONS/PREACTIONS: mem-allocated 256×2-byte dispatch tables, lazily initialized on first SYNTAX call.
-- They are populated during loading (by SYNTAX) AND read at runtime on every command dispatch:
-- the game's PERFORM routine calls <GET ,ACTIONS .A> and <GET ,PREACTIONS .A> to find and
-- invoke the handler for the current verb. Keeping them in mem is therefore correct -- they
-- are not loading-only data.
ACTIONS = 0   -- mem address of action dispatch table (action_id → fn_idx)
PREACTIONS = 0  -- mem address of pre-action dispatch table (action_id → fn_idx)
FLAGS = {}
FUNCTIONS = {}
_DIRECTIONS = {}

_GLOBAL_FLAG_SLOTS = {}    -- global name → Z-machine variable number
_GLOBAL_FLAG_NAMES = {}    -- Z-machine variable number → global name
_next_global_flag_slot = 15 -- 0 is the stack; 1..15 are local variables

DESCS = {}
DIRS = {}

_VTBL = {}
_OTBL = 0  -- mem address of 256×2-byte object pointer table; set on first DECL_OBJECT
_CHILD_TBL = 0 -- parent object id -> first child object id
_SIBLING_TBL = 0 -- object id -> next sibling object id

T = true
CR = "\n"
PRSA = nil
PRSO = nil
PRSI = nil

local ZIL_CONTROL_SIGNALS = {
	quit = {},
	restart = {},
}

M_FATAL = 2
M_HANDLED = 1
M_NOT_HANDLED = nil
M_OBJECT = nil
M_BEG = 1
M_END = 6
M_ENTER = 2
M_LOOK = 3
M_FLASH = 4
M_OBJDESC = 5
M_LEAVE = M_END
M_CONTAINER = M_OBJECT

local mem
local _obj_count = 0  -- number of declared objects; object IDs are 1.._obj_count
local _act_count = 0  -- number of registered actions; action IDs are 1.._act_count
local _act_fn_to_id = {}  -- build-time reverse-lookup: fn_idx -> action_id
local _pending_syntax = {}  -- SYNTAX entries deferred until action functions are defined
local _pending_synonyms = {} -- vocabulary aliases applied after all object words exist
local restart_snapshot
local suggestions = {
	READBIT = "READ",
	TAKEBIT = "TAKE",
	CONTBIT = "OPEN",
	DOORBIT = "OPEN",
}

-- Companion intent-card constants. ZIL companion modules use these while the
-- Lua host receives stable lowercase kind names.
CHOICE_PROGRESS = 1
CHOICE_INVESTIGATE = 2
CHOICE_INTERACT = 3
CHOICE_EXPERIMENT = 4
CHOICE_RETURN = 5
CHOICE_SAFETY = 6

-- These are strings so they participate in the existing scalar save, restore,
-- and restart snapshots without adding a second persistence format.
COMPANION_CHOICE_COUNTS = COMPANION_CHOICE_COUNTS or ""
COMPANION_KNOWLEDGE_IDS = COMPANION_KNOWLEDGE_IDS or ""

local companion_context

local function room_global_objects(room)
	local room_globals = {}
	local pqglobal = rawget(_G, "PQGLOBAL")
	if pqglobal and GETPT(room, pqglobal) then
		local ptr = GETPT(room, pqglobal)
		local size = PTSIZE(ptr)
		for i = 0, size - 1 do
			room_globals[mem:byte(ptr + i)] = true
		end
	end

	return room_globals
end

local function objects_in_room(room)
	local room_globals = room_global_objects(room)
	local yielded = {}
	local child = FIRSTQ(room)
	local i = 0

	return function()
		while child do
			local obj = child
			child = NEXTQ(child)
			if obj ~= ADVENTURER then
				yielded[obj] = true
				return obj
			end
		end

		while true do
			i = i + 1
			if i > _obj_count then return nil end
			if i ~= ADVENTURER and room_globals[i] and not yielded[i] then return i end
		end
	end
end

local function connected_exits(room)
    local i, keys = 0, {}
    for d in pairs(_DIRECTIONS) do keys[#keys+1]=d end
    return function()
        while i<#keys do
            i=i+1; local d=_DIRECTIONS[keys[i]]; local pp=GETPT(room,d)
            if pp then return keys[i], pp end
        end
    end
end

local function can_suggest_contents(obj)
	return FSETQ(obj, SURFACEBIT) or FSETQ(obj, OPENBIT)
end

local function add_items(room)
	local items = {}
	for obj in objects_in_room(room) do
		local verbs = {}
		local action = GETP(obj, PQACTION)
		local text = GETP(obj, PQTEXT) and not FSETQ(obj, READBIT)
		local item = GETP(obj, PQDESC) or ""
		if action then
			local func = FUNCTIONS[tonumber(action)]
			for k, v in pairs(_G) do
				if v == func then
					verbs = _G['_'..k] or {}
					break
				end
			end
		end
		if text then table.insert(verbs, "EXAMINE") end
		local fnd = function(name, array) 
			for _, n in ipairs(array) do if n == name then return true end end
		end
		for k, v in pairs(suggestions) do
			if FSETQ(obj, _G[k]) and not fnd(v, verbs) then
				table.insert(verbs, v)
			end
		end
		local marks, unique_verbs = {}, {}
		for _, verb in ipairs(verbs) do
			if not marks[verb] then table.insert(unique_verbs, verb) marks[verb] = true end
		end
		local words = {}
		for word in item:gmatch("%S+") do
			table.insert(words, word:lower())
		end
		local children = can_suggest_contents(obj) and add_items(obj) or {}
		table.insert(items, {table.concat(words, " "), unique_verbs, children})
	end
	return items
end

	local function add_exits(room)
	local exits = {}
	for d, pp in connected_exits(room) do
		if PTSIZE(pp) == 1 then
			local dest_room = GETB(pp, 0)
			local desc = GETP(dest_room, PQDESC)
			if not FSETQ(dest_room, ONBIT) then
				desc = desc .. " (pitch black)"
			end
			table.insert(exits, {d, desc, true, dest_room})
		elseif PTSIZE(pp) == 2 then
			table.insert(exits, {d, string.format("\"%s\"", mem:string(GET(pp, 0))), false})
		elseif PTSIZE(pp) == 4 then
			table.insert(exits, {d, GETP(GETB(pp, REXIT), PQDESC), false})
		elseif PTSIZE(pp) == 5 then
			table.insert(exits, {d, GETP(GETB(pp, REXIT), PQDESC), false})
		end
	end
	return exits
end

local function is_room_name(text)
	if not text then return false end
	text = tostring(text):gsub("^%s+", ""):gsub("%s+$", "")
	for room = 1, _obj_count do
		if GETP(room, PQLOC) == ROOMS and GETP(room, PQDESC) == text then
			return true
		end
	end
	return false
end

local companion_kind_names = {
	[CHOICE_PROGRESS] = "progress",
	[CHOICE_INVESTIGATE] = "investigate",
	[CHOICE_INTERACT] = "interact",
	[CHOICE_EXPERIMENT] = "experiment",
	[CHOICE_RETURN] = "return",
	[CHOICE_SAFETY] = "safety",
}

local function valid_companion_id(id)
	return type(id) == "string" and id:match("^[%w][%w._-]*$") ~= nil
end

local function decode_companion_counts(encoded)
	local counts = {}
	for id, count in tostring(encoded or ""):gmatch("([%w][%w._-]*)=(%d+)") do
		counts[id] = tonumber(count)
	end
	return counts
end

local function encode_companion_counts(counts)
	local ids = {}
	for id, count in pairs(counts) do
		if valid_companion_id(id) and tonumber(count) and tonumber(count) > 0 then
			ids[#ids + 1] = id
		end
	end
	table.sort(ids)
	local parts = {}
	for _, id in ipairs(ids) do
		parts[#parts + 1] = id .. "=" .. tostring(math.floor(counts[id]))
	end
	return table.concat(parts, ";")
end

local function decode_companion_set(encoded)
	local result = {}
	for id in tostring(encoded or ""):gmatch("[%w][%w._-]*") do
		result[id] = true
	end
	return result
end

local function encode_companion_set(values)
	local ids = {}
	for id, enabled in pairs(values) do
		if enabled and valid_companion_id(id) then ids[#ids + 1] = id end
	end
	table.sort(ids)
	return table.concat(ids, ";")
end

function CHOICE_COUNT(id)
	if not valid_companion_id(id) then return 0 end
	return decode_companion_counts(COMPANION_CHOICE_COUNTS)[id] or 0
end

function CHOICE_SEENQ(id)
	return CHOICE_COUNT(id) > 0
end

function KNOWSQ(id)
	if not valid_companion_id(id) then return false end
	return decode_companion_set(COMPANION_KNOWLEDGE_IDS)[id] == true
end

function KNOW(id)
	if not valid_companion_id(id) then
		error("Invalid companion knowledge ID: " .. tostring(id))
	end
	local knowledge = decode_companion_set(COMPANION_KNOWLEDGE_IDS)
	knowledge[id] = true
	COMPANION_KNOWLEDGE_IDS = encode_companion_set(knowledge)
	return true
end

function CHOICE(id, label, command, kind, priority)
	if not companion_context then
		error("CHOICE may only be used while companion choices are being evaluated")
	end
	if not valid_companion_id(id) then
		error("Invalid companion choice ID: " .. tostring(id))
	end
	if type(label) ~= "string" or label == "" then
		error("Companion choice " .. id .. " has no label")
	end
	if type(command) ~= "string" or command == "" then
		error("Companion choice " .. id .. " has no command")
	end
	kind = tonumber(kind) or CHOICE_INTERACT
	priority = tonumber(priority) or 50
	local candidate = {
		id = id,
		label = label,
		command = command,
		kind = kind,
		kind_name = companion_kind_names[kind] or "interact",
		priority = priority,
		group = "scene",
	}
	companion_context.candidates[#companion_context.candidates + 1] = candidate
	companion_context.last_choice = candidate
	return true
end

function CHOICE_DETAILS(...)
	if not companion_context or not companion_context.last_choice then
		error("CHOICE_DETAILS requires a preceding CHOICE")
	end
	local candidate = companion_context.last_choice
	for i = 1, select("#", ...), 2 do
		local key = select(i, ...)
		local value = select(i + 1, ...)
		if type(key) == "string" then
			key = key:lower():gsub("-", "_")
			candidate[key] = value
		end
	end
	return true
end

function SCENE(key, alt_text)
	if not companion_context then
		error("SCENE may only be used while companion state is being evaluated")
	end
	if type(key) ~= "string" or key == "" then
		error("Companion scene has no key")
	end
	companion_context.scene = {
		key = key,
		alt = type(alt_text) == "string" and alt_text or "",
	}
	return true
end

local function companion_slug(text)
	local slug = tostring(text or ""):lower():gsub("[^%w]+", "-")
	slug = slug:gsub("^%-+", ""):gsub("%-+$", "")
	return slug ~= "" and slug or "unknown"
end

local function companion_fallback_choices()
	if not HERE or not FIRSTQ or not GETP then return end

	local direct = {}
	local c = FIRSTQ(HERE)
	while c do
		if c ~= ADVENTURER then direct[c] = true end
		c = NEXTQ(c)
	end

	local verb_labels = {
		EXAMINE = "Examine the %s",
		READ = "Read the %s",
		OPEN = "Open the %s",
		TAKE = "Take the %s",
	}
	local verb_preference = {"OPEN", "READ", "TAKE", "EXAMINE"}
	local fnd = function(name, array)
		for _, n in ipairs(array) do if n == name then return true end end
	end

	for obj in objects_in_room(HERE) do
		if FSETQ(obj, INVISIBLE) then goto fallback_next end
		if not direct[obj] then goto fallback_next end

		local verbs = {}
		local action = GETP(obj, PQACTION)
		local text = GETP(obj, PQTEXT) and not FSETQ(obj, READBIT)
		local item = GETP(obj, PQDESC) or ""

		if action then
			local func = FUNCTIONS[tonumber(action)]
			if func then
				for k, v in pairs(_G) do
					if v == func then
						verbs = _G['_'..k] or {}
						break
					end
				end
			end
		end
		if text then table.insert(verbs, "EXAMINE") end
		for k, v in pairs(suggestions) do
			if FSETQ(obj, _G[k]) and not fnd(v, verbs) then
				table.insert(verbs, v)
			end
		end

		local marks, unique_verbs = {}, {}
		for _, verb in ipairs(verbs) do
			if not marks[verb] then table.insert(unique_verbs, verb) marks[verb] = true end
		end

		local words = {}
		for word in item:gmatch("%S+") do
			table.insert(words, word:lower())
		end
		local item_name = table.concat(words, " ")
		if item_name == "" then goto fallback_next end

		local selected_verb
		for _, wanted in ipairs(verb_preference) do
			for _, verb in ipairs(unique_verbs) do
				if verb == wanted then selected_verb = verb; break end
			end
			if selected_verb then break end
		end
		if selected_verb and verb_labels[selected_verb] then
			local id = "fallback.item." .. companion_slug(item_name) .. "." .. selected_verb:lower()
			CHOICE(
				id,
				string.format(verb_labels[selected_verb], item_name),
				selected_verb:lower() .. " " .. item_name,
				(selected_verb == "READ" or selected_verb == "EXAMINE")
					and CHOICE_INVESTIGATE or CHOICE_INTERACT,
				25
			)
		end

		::fallback_next::
	end

	for _, exit in ipairs(add_exits(HERE)) do
		local direction, destination, safe, dest_room = table.unpack(exit)
		if safe and type(destination) == "string" and destination ~= "" then
			local dir_lower = tostring(direction):lower()
			local visited = dest_room and FSETQ(dest_room, TOUCHBIT)
			local label
			if dir_lower == "up" then
				label = (visited and "Climb back to " or "Climb to ") .. destination
			elseif dir_lower == "down" then
				label = (visited and "Climb back down to " or "Down to ") .. destination
			elseif visited then
				label = "Walk back to " .. destination
			else
				label = "Walk to " .. destination
			end
			CHOICE(
				"fallback.exit." .. companion_slug(dir_lower),
				label,
				dir_lower,
				CHOICE_RETURN,
				30
			)
			CHOICE_DETAILS("group", "move")
		end
	end
end

local function select_companion_candidates(candidates)
	local counts = decode_companion_counts(COMPANION_CHOICE_COUNTS)
	local unique_ids, unique_commands, eligible = {}, {}, {}
	for _, candidate in ipairs(candidates) do
		local command_key = candidate.command:lower():gsub("%s+", " ")
		if not unique_ids[candidate.id] and not unique_commands[command_key]
				and not (candidate.once and (counts[candidate.id] or 0) > 0) then
			candidate.group = candidate.group == "move" and "move" or "scene"
			unique_ids[candidate.id] = true
			unique_commands[command_key] = true
			candidate.adjusted_priority =
				candidate.priority - ((counts[candidate.id] or 0) * 15)
			eligible[#eligible + 1] = candidate
		end
	end
	table.sort(eligible, function(a, b)
		if a.adjusted_priority ~= b.adjusted_priority then
			return a.adjusted_priority > b.adjusted_priority
		end
		return a.id < b.id
	end)

	return eligible
end

function COMPANION_QUERY()
	companion_context = {
		candidates = {},
	}

	local ok, err
	if type(SUGGEST_ACTIONS) == "function" then
		ok, err = pcall(SUGGEST_ACTIONS)
		if not ok then
			companion_context = nil
			return {ok = false, error = tostring(err), choices = {}}
		end
	end

	if #companion_context.candidates == 0 then
		ok, err = pcall(companion_fallback_choices)
		if not ok then
			companion_context = nil
			return {ok = false, error = tostring(err), choices = {}}
		end
	end

	if type(SUGGEST_SCENE) == "function" then
		ok, err = pcall(SUGGEST_SCENE)
		if not ok then
			companion_context = nil
			return {ok = false, error = tostring(err), choices = {}}
		end
	end

	local context = companion_context
	local choices = select_companion_candidates(context.candidates)
	companion_context = nil
	return {
		ok = true,
		scene = context.scene,
		choices = choices,
	}
end

function COMPANION_SELECT(id)
	local result = COMPANION_QUERY()
	if not result.ok then return result end
	for _, candidate in ipairs(result.choices) do
		if candidate.id == id then
			local counts = decode_companion_counts(COMPANION_CHOICE_COUNTS)
			counts[id] = (counts[id] or 0) + 1
			COMPANION_CHOICE_COUNTS = encode_companion_counts(counts)
			if type(candidate.learns) == "string" and candidate.learns ~= "" then
				KNOW(candidate.learns)
			end
			return {
				ok = true,
				id = id,
				command = candidate.command,
			}
		end
	end
	return {
		ok = false,
		error = "choice_no_longer_eligible",
		id = id,
	}
end

local function companion_route_choices()
	return COMPANION_QUERY()
end

local function companion_route_select(id)
	return COMPANION_SELECT(id)
end

local function encode_fptr(n)
  return string.format("<@F:%X>", n)
end

local function decode_fptr(s)
    local hex = s:match("<@F:([A-Fa-f0-9]+)>")
    return hex and tonumber(hex, 16)
end

local function makebyte(val)
	return string.char(math.min(math.max(0,val), 0xff))
end

local function makeword(val)
	return string.char(val&0xff, (val>>8)&0xff)
end

local function makedword(val)
	return string.char(val&0xff, (val>>8)&0xff, (val>>16)&0xff, (val>>24)&0xff)
end

local function makeqword(val)
	return string.char(val&0xff, (val>>8)&0xff, (val>>16)&0xff, (val>>24)&0xff,
	                   (val>>32)&0xff, (val>>40)&0xff, (val>>48)&0xff, (val>>56)&0xff)
end

mem = setmetatable({size=0},{__index={
	write = function(self, buffer, pos)
		if not pos then pos = self.size + 1 end  -- Append if no pos
		local buf_len = #buffer
		assert(pos+buf_len-1 <= 0xffff, "Memory overflow: can't write beyond 65535")
		for i = 1, buf_len do
			local byte = buffer:byte(i)
			if pos + i - 1 > self.size then self.size = pos + i - 1 end
			self[pos + i] = byte
		end
		return pos
	end,

	stringprop = function (self, s)
		if type(s) == 'number' then s = encode_fptr(s) end
		return makeword(self:write(makeword(#s)..s))
	end,

	write_word = function(mem, k) return mem:write(makeword(k)) end,
	writestring2 = function(mem, s) return mem:write(makeword(#s)..s) end,

	table_to_str = function(self, start, end_pos)
		local bytes = {}
		local len = end_pos - start + 1
		for i = 1, len do bytes[i] = self:byte(start + i - 1) or 0 end
		return string.char(table.unpack(bytes))
	end,

	byte = function(self, idx) return self[idx+1] or 0 end,
	word = function(self, ptr) return self:byte(ptr)|(self:byte(ptr+1)<<8) end,
	dword = function(self, ptr) return self:byte(ptr)|(self:byte(ptr+1)<<8)|(self:byte(ptr+2)<<16)|(self:byte(ptr+3)<<24) end,
	qword = function(self, ptr) return self:byte(ptr)|(self:byte(ptr+1)<<8)|(self:byte(ptr+2)<<16)|(self:byte(ptr+3)<<24)|(self:byte(ptr+4)<<32)|(self:byte(ptr+5)<<40)|(self:byte(ptr+6)<<48)|(self:byte(ptr+7)<<56) end,
	string = function(self, ptr)
		local str = self:table_to_str(ptr + 2, ptr + self:word(ptr) + 1)
		return decode_fptr(str) or str
	end,

	read = function(self, size, pos)
		if size <= 0 then return "" end
		return self:table_to_str(pos, pos + size - 1)
	end
}})

-- The Z-machine header occupies address zero in a story file, while this
-- runtime keeps its compact object/table heap separately.  Model the handful
-- of writable header bytes used by Infocom ZIL without reserving or aliasing
-- heap memory.
local z_header = {}

function SET_HEADER(release, serial)
	release = tonumber(release) or 0
	z_header[2] = release & 0xff
	z_header[3] = (release >> 8) & 0xff
	serial = tostring(serial or "000000")
	serial = (serial .. "000000"):sub(1, 6)
	for i = 1, 6 do
		z_header[17 + i] = serial:byte(i)
	end
	return true
end

SET_HEADER(0, "000000")

local cache = {
	verbs = {},
	words = {},
	synonyms = {},
	exact_words = {},
}

local function fn(f) 
	for n, ff in ipairs(FUNCTIONS) do if f == ff then return n end end
	table.insert(FUNCTIONS, f)
	return #FUNCTIONS
end

-- Expose fn as a global function for use in ZIL code
-- Converts a function reference to its index in the FUNCTIONS table
-- This is needed for clock system INT/QUEUE functions which expect routine numbers
function ROUTINE_NUM(f)
	if type(f) == 'number' then return f end  -- Already a number (routine index)
	if type(f) == 'function' then return fn(f) end  -- Convert function to index
	-- Invalid type - error with helpful message
	error("ROUTINE_NUM: expected function or number, got " .. type(f))
end

local learn

local function merge_dictionary_word(target, source)
	local old = mem:read(7, target)
	local new = mem:read(7, source)
	local old_flags = old:byte(5) or 0
	local new_flags = new:byte(5) or 0
	if old_flags == 0 then
		mem:write(new, target)
		return
	end
	local old_primary = old_flags & 3
	local new_primary = new_flags & 3
	local secondary = old:byte(7) or 0
	if new_primary ~= old_primary then
		secondary = new:byte(6) or secondary
	end
	mem:write(string.char(
		old:byte(1), old:byte(2), old:byte(3), old:byte(4),
		((old_flags | new_flags) & ~3) | old_primary,
		old:byte(6) or 0,
		secondary
	), target)
end

local function register(tbl, value)
	local n = 0
	if type(value) == "string" then value = value:lower() end
	
	-- Special handling for PREPOSITIONS to maintain array format
	if tbl == PREPOSITIONS then
		if tbl._hash[value] then
			return tbl._hash[value]
		end
		-- Count existing entries in the hash
		for k, v in pairs(tbl._hash) do n = n + 1 end
		local index = n + 1
		tbl._hash[value] = index
		-- Will be filled in learn() when word_ptr is available
		return index
	end
	
	-- Original logic for other tables
	for k, v in pairs(tbl) do n = n + 1 end
	if not tbl[value] then tbl[value] = n + 1 end
	return tbl[value]
end

-- === Utility functions ===

function VERBQ(...)
	return EQUALQ(PRSA, ...)
end

function PRSOQ(...) return EQUALQ(PRSO, ...) end
function PRSIQ(...) return EQUALQ(PRSI, ...) end
function HEREQ(...) return EQUALQ(HERE, ...) end
ROOMQ = HEREQ
function WINNERQ(...) return EQUALQ(WINNER, ...) end
function CONTEXTQ(...) return EQUALQ(RARG, ...) end
RARGQ = CONTEXTQ

-- Runtime equivalents of the compiler macros used by later Infocom sources.
-- The original ZILCH expanded these at compile time; varargs preserve their
-- observable behavior without requiring an MDL macro evaluator.
function PQ(verb, object, indirect, winner)
	return (winner == nil or winner == "*" or WINNERQ(winner))
		and (verb == nil or verb == "*" or VERBQ(verb))
		and (object == nil or object == "*" or PRSOQ(object))
		and (indirect == nil or indirect == "*" or PRSIQ(indirect))
end

function BSET(object, ...)
	for i = 1, select("#", ...) do FSET(object, select(i, ...)) end
	return true
end

function BCLEAR(object, ...)
	for i = 1, select("#", ...) do FCLEAR(object, select(i, ...)) end
	return true
end

function BSETQ(object, ...)
	for i = 1, select("#", ...) do
		if FSETQ(object, select(i, ...)) then return true end
	end
	return false
end

function STRING(...)
	local parts = {}
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if type(value) == "number" then value = string.char(value) end
		parts[#parts + 1] = tostring(value or "")
	end
	return table.concat(parts)
end

function USL() return true end

function VOC(word, kind)
	if kind == ADJ or kind == ADJECTIVE then
		return learn(word, PSQADJECTIVE, ADJECTIVES)
	end
	return learn(word, PSQOBJECT, nil)
end

-- Register a full-input spelling as an alias without applying the Z-machine's
-- six-character dictionary truncation.  This is useful for the rare case where
-- a long noun (for example INSPECTOR) collides with a shorter verb (INSPECT).
function VOC_EXACT(word, target)
	local target_key = tostring(target):lower():sub(1, 6)
	local target_word = cache.words[target_key]
	cache.exact_words[tostring(word):lower()] = target_key
	return target_word or 0
end

function VOC_EXACT_FIRST(word, target)
	local target_key = tostring(target):lower():sub(1, 6)
	local target_word = cache.words[target_key]
	cache.exact_words[tostring(word):lower()] = { target = target_key, first = true }
	return target_word or 0
end

function RANDOM(base)
	local value = math.random(1, base)
	-- print(value)
	return value
end

function PICK_ONE(table)
	local num = mem:word(table)
	-- local sel = math.random(2, num)
	local sel = RANDOM(num-1)+1
	return mem:word(table+sel*2)
	-- local table_size = mem:byte(table)
	-- return mem:word(table + RANDOM(table_size) * 2)
end

function RANDOM_ELEMENT(frob)
	return GET(frob, RANDOM(GET(frob, 0)))
end

function PROB(base)
	return RANDOM(100) <= base
end

ZPROB = PROB

-- At the top of bootstrap, add output buffer
local output_buffer = {}
local zil_nil_return = {}

function ZIL_RETURN(value)
	if value == nil then
		error(zil_nil_return)
	end

	error(value)
end

function ZIL_UNWRAP_RETURN(value)
	if value == zil_nil_return then
		return nil
	end

	return value
end

local function io_write(...)
	-- Check if io_write was overridden globally (for tests)
	if _G.io_write then
		return _G.io_write(...)
	end
	-- Default: buffered mode for coroutine-based games
	for i = 1, select("#", ...) do
		table.insert(output_buffer, tostring(select(i, ...)))
	end
end

local function io_flush()
	-- Check if io_flush was overridden globally (for tests)
	if _G.io_flush then
		return _G.io_flush()
	end
	-- Default: return buffered content
	local text = table.concat(output_buffer)
	output_buffer = {}
	return text
end

local function is_control_signal(signal, kind)
	if kind then
		return signal == ZIL_CONTROL_SIGNALS[kind]
	end
	return signal == ZIL_CONTROL_SIGNALS.quit or signal == ZIL_CONTROL_SIGNALS.restart
end

function IS_ZIL_CONTROL_SIGNAL(signal, kind)
	return is_control_signal(signal, kind)
end

local function is_state_global(value)
	local value_type = type(value)
	return value_type == "number"
		or value_type == "boolean"
		or value_type == "string"
end

local function capture_game_state()
	local state = {
		mem_size = mem.size,
		mem_bytes = {},
		globals = {},
	}

	for i = 1, mem.size do
		state.mem_bytes[i] = mem[i]
	end
	for name, value in pairs(_G) do
		if is_state_global(value) then
			state.globals[name] = value
		end
	end

	return state
end

local function restore_game_state(state)
	for name, value in pairs(_G) do
		if is_state_global(value) and state.globals[name] == nil then
			_G[name] = nil
		end
	end
	for name, value in pairs(state.globals) do
		_G[name] = value
	end

	for i = state.mem_size + 1, mem.size do
		mem[i] = nil
	end
	for i = 1, state.mem_size do
		mem[i] = state.mem_bytes[i]
	end
	mem.size = state.mem_size
	output_buffer = {}
end

function CAPTURE_RESTART_STATE()
	restart_snapshot = capture_game_state()
	return true
end

function QUIT()
	error(ZIL_CONTROL_SIGNALS.quit, 0)
end

function VERIFY() return true end

function RESTART()
	if not restart_snapshot then
		return false
	end

	restore_game_state(restart_snapshot)
	error(ZIL_CONTROL_SIGNALS.restart, 0)
end

function TELL(...)
	local object = false
	local number = false
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if v == D then object = "D"
		elseif v == TELL_A then object = "A"
		elseif v == TELL_THE then object = "THE"
		elseif v == TELL_CTHE then object = "CTHE"
		elseif v == N then number = true
		elseif object then
			local token = object
			object = false
			if v then
				local printer = token == "A" and rawget(_G, "PRINTA")
					or token == "THE" and rawget(_G, "THE_PRINT")
					or token == "CTHE" and rawget(_G, "CTHE_PRINT")
					or token == "D" and rawget(_G, "DPRINT")
				if printer then
					APPLY(printer, v)
				else
					local desc = GETP(v, _G["PQDESC"]) or ""
					if token == "A" then
						io_write(desc:match("^[AEIOUaeiou]") and "an " or "a ")
					elseif token == "THE" then
						io_write("the ")
					elseif token == "CTHE" then
						io_write("The ")
					end
					io_write(desc)
				end
			end
		elseif number then number = false io_write(tostring(v))
		elseif v == nil or v == false then -- FALSE expressions print nothing
		elseif type(v) == "number" then io_write(mem:string(v))
		elseif v == '>' then -- skip
		else io_write(tostring(v)) end
	end
	return true
end

function PRINT(n) io_write(mem:string(n)) return true end
function PRINTD(ptr) io_write(GETP(ptr, _G["PQDESC"])) return true end
function PRINTR(ptr) io_write(GETP(ptr, _G["PQLDESC"])) return true end
function PRINTB(ptr)
	for word, index in pairs(cache.words) do
		if index == ptr then 
			io_write(word)
			return true
		end
	end
	return false
end
function PRINTI(n) io_write(tostring(n)) return true end
function PRINTN(n) io_write(tostring(n)) return true end
function PRINTC(ch) io_write(string.char(ch)) return true end
function PRINC(n) io_write(tostring(n)) return true end
function CRLF() io_write("\n") return true end

function JIGS_UP(msg)
	TELL(msg, CR)
	MOVE(WINNER, HERE)
	-- os.exit(1)
end

local routes = {
	['room-items'] = add_items,
	['room-exits'] = add_exits,
	['room-name?'] = is_room_name,
	['choices'] = companion_route_choices,
	['choice-select'] = companion_route_select,
}

local function route_response(input)
	local route = routes[input]
	if route then
		return true, route(HERE)
	end

	if type(input) ~= "string" then
		return false
	end

	local route_name, arg = input:match("^([^:]+):(.*)$")
	route = routes[route_name]
	if route then
		return true, route(arg)
	end

	return false
end

-- Modified READ to yield with output
function READ(inbuf, parse)
	-- for k, v in pairs(_G) do
	-- 	if type(v) == 'boolean' then print(k, type(v)) end
	-- end

	-- Yield with accumulated output, get input back
	local s = coroutine.yield(io_flush())
	::restart_read::
	local handled, response = route_response(s)
	if handled then
		s = coroutine.yield(response)
		goto restart_read
	end
	-- Handle nil input (e.g., EOF)
	if not s then
		os.exit(0)
	end
	
	local p = {}
	for pos, word in s:gmatch("()(%S+)") do
		-- Z-machine truncates dictionary words to 6 characters
		local normalized = word:lower()
		local truncated = normalized:sub(1, 6)
		local exact_spec = cache.exact_words[normalized]
		local exact_target
		if type(exact_spec) == "table" then
			if not exact_spec.first or #p == 0 then exact_target = exact_spec.target end
		else
			exact_target = exact_spec
		end
		local index = (exact_target and cache.words[exact_target]) or cache.words[truncated] or 0
		table.insert(p, makeword(index).. string.char(#word, pos&0xff))
	end
	mem:write(s: lower()..'\0', inbuf+1)
	mem:write(string.char(#p)..table.concat(p), parse+1)
end

-- Logic / bitwise
function NOT(a) return not a or a == 0 end
function ZIL_TRUE(value) return value ~= nil and value ~= false and value ~= 0 end
function PASS(a) return a end
function BAND(a, b) return (a or 0) & (b or 0) end
function BOR(a, b) return (a or 0) | (b or 0) end
function BTST(a, b) return ((a or 0) & (b or 0)) == (b or 0) end

-- Arithmetic / comparison
function EQUALQ(a, ...)
	for i = 1, select("#", ...) do
		local b = select(i, ...)
		if (a or 0) == (b or 0) then return true end
		if type(a) == 'number' and type(b) == 'function' then
			for n, ff in ipairs(FUNCTIONS) do if b == ff then if a == n then return true end; break end end
		elseif type(a) == 'function' and type(b) == 'number' then
			for n, ff in ipairs(FUNCTIONS) do if a == ff then if b == n then return true end; break end end
		end
	end
	return false
end
function GASSIGNEDQ(name) return rawget(_G, tostring(name)) ~= nil end
function NEQUALQ(a, b) return not EQUALQ(a, b) end
function SIGNED_WORD(value)
	value = value or 0
	if type(value) == "number" and value >= 0x8000 and value <= 0xffff then
		return value - 0x10000
	end
	return value
end
function GQ(a, b) return (a or 0) > (b or 0) end
function LQ(a, b) return (a or 0) < (b or 0) end
function GEQ(a, b) return (a or 0) >= (b or 0) end
function LEQ(a, b) return (a or 0) <= (b or 0) end
function ZEROQ(a) return (a or 0) == 0 end
function ONEQ(a) return a == 1 end
function ADD(a, b) return (a or 0) + (b or 0) end
function SUB(a, ...)
	if select("#", ...) == 0 then return -(a or 0) end
	local result = a or 0
	for i = 1, select("#", ...) do
		result = result - (select(i, ...) or 0)
	end
	return result
end
function DIV(a, b) return (a or 0) // (b or 0) end
function MUL(a, b) return (a or 0) * (b or 0) end
function MOD(a, b) return (a or 0) % (b or 0) end

-- Audio is optional in the current text-only host.  Preserve the opcode's
-- successful control-flow behavior even when no sound backend is attached.
function SOUND(...) return true end

-- function GQ(a, b) return a > b end
-- IGRTRQ = GQ
LESSQ = LQ
MULL = MUL

-- Object / room ops
-- Returns the mem address of object num's property table block.
-- _OTBL is the base of a 256×2-byte array allocated in mem by the first DECL_OBJECT call.
local function getobj(num)
	if type(num) ~= "number" or num <= 0 then return nil end
	local pointer = mem:word(_OTBL + (num-1)*2)
	return pointer ~= 0 and pointer or nil
end

-- In ZIL, <VALUE var> gets the runtime value of a variable. Conditional exits
-- store a variable number in their property bytes, so resolve those numbers
-- back to the live Lua global; other values retain the legacy identity behavior.
function VALUE(x)
	if type(x) == "number" then
		local gname = _GLOBAL_FLAG_NAMES[x]
		if gname then
			return rawget(_G, gname)
		end
	end
	return x
end

function LOC(obj) return GETP(obj, PQLOC) end
function INQ(obj, room) return GETP(obj, PQLOC) == room end

local function unlink_object(obj)
	local parent = LOC(obj)
	if not parent or parent == 0 then return end
	local child = mem:byte(_CHILD_TBL + parent)
	local previous = 0
	while child ~= 0 do
		if child == obj then
			local next_sibling = mem:byte(_SIBLING_TBL + child)
			if previous == 0 then
				mem:write(makebyte(next_sibling), _CHILD_TBL + parent)
			else
				mem:write(makebyte(next_sibling), _SIBLING_TBL + previous)
			end
			mem:write(makebyte(0), _SIBLING_TBL + child)
			return
		end
		previous = child
		child = mem:byte(_SIBLING_TBL + child)
	end
end

function MOVE(obj, dest)
	unlink_object(obj)
	PUTP(obj, PQLOC, dest)
	if dest and dest ~= 0 then
		local first = mem:byte(_CHILD_TBL + dest)
		mem:write(makebyte(first), _SIBLING_TBL + obj)
		mem:write(makebyte(obj), _CHILD_TBL + dest)
	end
end

function REMOVE(obj)
	unlink_object(obj)
	PUTP(obj, PQLOC, 0)
end

function FIRSTQ(obj)
	local child = mem:byte(_CHILD_TBL + obj)
	return child ~= 0 and child or nil
end

function NEXTQ(obj)
	local sibling = mem:byte(_SIBLING_TBL + obj)
	return sibling ~= 0 and sibling or nil
end

function MAP_CONTENTS(container, callback, end_callback)
	local object = FIRSTQ(container)
	local result
	while object do
		local next_object = NEXTQ(object)
		result = callback(object, next_object)
		object = next_object
	end
	if end_callback then return end_callback() end
	return result
end

function MAP_DIRECTIONS(room, callback, end_callback)
	local directions = {}
	for _, property in pairs(_DIRECTIONS) do
		directions[#directions + 1] = property
	end
	table.sort(directions)
	local result
	for _, property in ipairs(directions) do
		local property_table = GETPT(room, property)
		if property_table then
			result = callback(property, property_table)
		end
	end
	if end_callback then return end_callback() end
	return result
end

learn = function(word, atom, value)
	local function upper2(word)
		local specials = {
			["."] = "PERIOD",
			[","] = "COMMA",
			["\""] = "QUOTE",
		}
		return specials[word] or word:upper()
	end
	local prim = {
		[PSQOBJECT]=P1QOBJECT,
		[PSQVERB]=P1QVERB,
		[PSQADJECTIVE]=P1QADJECTIVE,
		[PSQDIRECTION]=P1QDIRECTION,
		[PSQPREPOSITION]=P1QOBJECT,
		[PSQBUZZ_WORD]=P1QNONE,
	}
	if not word then return 0 end
	word = word:lower()
	-- Z-machine truncates dictionary words to 6 characters
	local word_key = word:sub(1, 6)
	if type(value) == 'table' then value = register(value, word) end
	if cache.words[word_key] then
		local index = cache.words[word_key]
		local ent = mem:read(7, cache.words[word_key])
		local new = string.char(0,0,0,0,ent:byte(5)|atom,ent:byte(6),value or OQANY)
		mem:write(new, index)
	else
		local enc = string.char(0,0,0,0,atom|prim[atom],value or OQANY,0)
		local pos = mem:write(enc)
		cache.words[word_key] = pos
		_G['WQ'..upper2(word)] = pos
	end
	for _, syn in ipairs(cache.synonyms[word_key] or {}) do
		local syn_key = syn:lower():sub(1, 6)
		if cache.words[syn_key] then
			merge_dictionary_word(cache.words[syn_key], cache.words[word_key])
		end
	end
	
	-- Special handling for PREPOSITIONS: populate array format immediately
	if atom == PSQPREPOSITION and value and type(value) == 'number' then
		local word_ptr = cache.words[word_key]
		if word_ptr and PREPOSITIONS._hash[word_key] then
			-- Add to array format: [0]=count, [1]=word_ptr1, [2]=index1, [3]=word_ptr2, [4]=index2, ...
			local count = PREPOSITIONS[0]
			PREPOSITIONS[count * 2 + 1] = word_ptr
			PREPOSITIONS[count * 2 + 2] = value
			PREPOSITIONS[0] = count + 1
		end
	end
	
	return value or cache.words[word_key]
end


function FSET(obj, flag)
	PUTP(obj, PQFLAGS, GETP(obj, PQFLAGS) | (1 << flag))
	assert(FSETQ(obj, flag), string.format("Failed to set flag %d on object %d", flag, obj))
end
function FCLEAR(obj, flag)
	PUTP(obj, PQFLAGS, GETP(obj, PQFLAGS) & ~(1 << flag))
	assert(not FSETQ(obj, flag), string.format("Failed to clear flag %d on object %d", flag, obj))
end
function FSETQ(obj, flag)
	if not obj or obj == 0 or not flag then return false end
	return ((GETP(obj, PQFLAGS) or 0) & (1 << flag)) ~= 0
end
function GETPT(obj, prop)
	local tbl = getobj(obj)
	if not tbl then return nil end
	local l = mem:byte(tbl)+tbl+1
	local pname, psize = mem:byte(l), mem:byte(l+1)
	local header = 2
	while psize > 0 do
		if pname==prop then return l+header end
		l = l+psize+header
		pname, psize = mem:byte(l), mem:byte(l+1)
	end
end
function PTSIZE(ptr)
	if not ptr then return 0 end
	return mem:byte(ptr-1)
end
function PUTP(obj, prop, val)
	local ptr = GETPT(obj, prop)
	if type(val) == 'string' then
		assert(PTSIZE(ptr) == 2, "String property "..prop.." size must be 2")
		mem:write(mem:stringprop(val), ptr)
		return
	elseif type(val) == 'function' then
		assert(PTSIZE(ptr) == 2, "Function property "..prop.." size must be 2")
		mem:write(mem:stringprop(fn(val)), ptr)
		return
	end
	assert(type(val) == 'number', "Only numbers are supported in PUTP, not "..type(val))
	if PTSIZE(ptr) == 1 then mem:write(makebyte(val), ptr)
	elseif PTSIZE(ptr) == 2 then mem:write(makeword(val), ptr)
	elseif PTSIZE(ptr) == 4 then mem:write(makedword(val), ptr)
	elseif PTSIZE(ptr) == 8 then mem:write(makeqword(val), ptr)
	else
		error("Unsupported property size for number: "..PTSIZE(ptr))
	end
end
function GETP(obj, prop)
	if not GETPT(obj, prop) then return nil end
	local ptr = GETPT(obj, prop)
	local ptsize = PTSIZE(ptr)
	if ptsize == 1 then return mem:byte(ptr) end
	if ptsize == 2 then
		local value = mem:word(ptr)
		if prop == rawget(_G, "PQTHINGS") then return value ~= 0 and value or nil end
		return value ~= 0 and mem:string(value) or nil
	end
	if ptsize == 4 then return mem:dword(ptr) end
	if ptsize == 8 then return mem:qword(ptr) end
	assert(false, "Unsupported property to get")
end
function NEXTP(obj, prop)
	-- Returns the next property number after prop
	-- If prop is 0, returns the first property
	-- If no more properties, returns 0
	local tbl = getobj(obj)
	local l = mem:byte(tbl)+tbl+1
	local pname, psize = mem:byte(l), mem:byte(l+1)
	local header = 2
	local found = (prop == 0)  -- If prop is 0, return first property
	while psize > 0 do
		if found then
			-- Return this property (the next one after prop)
			return pname
		end
		if pname == prop then
			-- Found the requested property, next iteration will return the next one
			found = true
		end
		l = l+psize+header
		pname, psize = mem:byte(l), mem:byte(l+1)
	end
	return 0  -- No more properties
end

table.concat2 = function(t, fn)
	local tmp = {}
	for i, s in ipairs(t) do tmp[i] = fn(s) end
	return table.concat(tmp)
end

local declared_objects = {}

function DECL_OBJECT(name)
	if name and declared_objects[name] then return declared_objects[name] end
	if not _OTBL or _OTBL == 0 then
		-- Allocate the 256×2-byte object pointer table on first use
		_OTBL = mem:write(string.rep('\0\0', 256))
		_CHILD_TBL = mem:write(string.rep('\0', 256))
		_SIBLING_TBL = mem:write(string.rep('\0', 256))
	end
	-- Direction properties are passed through PRSO for WALK. Several Infocom
	-- parsers also use numeric pseudo-objects such as IT, so assigning an object
	-- the same number as a direction makes a walk look like pronoun substitution.
	-- Leave holes for direction-property numbers when allocating object IDs.
	repeat
		_obj_count = _obj_count + 1
		local is_direction = false
		for _, property in pairs(_DIRECTIONS) do
			if property == _obj_count then is_direction = true break end
		end
	until not is_direction
	assert(_obj_count <= 255, "Too many objects (max 255) while declaring " .. tostring(name))
	if name then declared_objects[name] = _obj_count end
	return _obj_count
end

function OBJECT_REF(name)
	local value = rawget(_G, name)
	if type(value) == "number" then return value end
	value = DECL_OBJECT(name)
	_G[name] = value
	return value
end

function GLOBAL_REF(name)
	local value = rawget(_G, name)
	if value ~= nil then return value end
	return {__global_ref = name}
end

function GLOBAL_FLAG_REF(name)
	return {__global_ref = name}
end

local pending_routine_refs = {}

function ROUTINE_REF(name)
	local value = rawget(_G, name)
	if type(value) == "function" then return value end
	return {__routine_ref = name}
end

local function defer_routine_ref(name, object_id, property_name, kind, offset)
	local pending = pending_routine_refs[name]
	if not pending then
		pending = {}
		pending_routine_refs[name] = pending
	end
	pending[#pending + 1] = {
		object = object_id,
		property = register(PROPERTIES, property_name),
		kind = kind,
		offset = offset,
	}
end

function DEFINE_ROUTINE(name, routine)
	assert(type(routine) == "function", "DEFINE_ROUTINE expected function for "..tostring(name))
	-- Register every named routine when it is defined.  A routine can otherwise
	-- receive its first numeric pointer only when GO queues it; restored llm.lua
	-- sessions skip GO, leaving that saved pointer beyond the rebuilt table.
	local routine_index = fn(routine)
	local pending = pending_routine_refs[name]
	if not pending then return routine end

	for _, ref in ipairs(pending) do
		if ref.kind == "exit" or ref.kind == "property-offset" then
			local ptr = GETPT(ref.object, ref.property)
			assert(ptr, "Missing deferred routine property: "..tostring(name))
			mem:write(makeword(routine_index), ptr + (ref.offset or 0))
		else
			PUTP(ref.object, ref.property, routine)
		end
	end
	pending_routine_refs[name] = nil
	return routine
end

local function sorted_keys(tbl)
	local keys = {}
	for key in pairs(tbl) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	return keys
end

function OBJECT(object)
	local function resolve_global(value)
		if type(value) == "string" then
			return rawget(_G, value) or value
		end
		return value
	end
	local function function_prop(value, property_name, object_id)
		value = resolve_global(value)
		if type(value) == "table" and value.__routine_ref then
			defer_routine_ref(value.__routine_ref, object_id, property_name, "property")
			return '\0\0'
		end
		return type(value) == 'function' and mem:stringprop(fn(value)) or '\0\0'
	end
	local function makeprop(body, name)
		local num = register(PROPERTIES, name)
		if not _G["PQ"..name] then _G["PQ"..name] = num end
		return string.char(num,#body)..body
	end
	if object.DESC then
		table.insert(DESCS, object.DESC)
		table.insert(DESCS, object.DESC:lower())
	end
	local object_name = object.ZIL_NAME or object.NAME
	local n = _G[object_name]
	local t = {string.char(#object_name), object_name}
	assert(n, "DECL_OBJECT not called for "..tostring(object_name))
	-- Object declarations are Lua tables, whose hash iteration order varies from
	-- process to process.  Property numbers and function-pointer slots are both
	-- assigned while walking these fields, so an unstable order makes a memory
	-- dump written by one llm.lua process incompatible with the next one.
	for _, k in ipairs(sorted_keys(object)) do
		local v = object[k]
		if k == "ZIL_NAME" then
		elseif type(v) == "table" and v.__property_bytes then
			table.insert(t, makeprop(v.__property_bytes, k))
			for _, ref in ipairs(v.__routine_refs or {}) do
				defer_routine_ref(ref.name, n, k, "property-offset", ref.offset)
			end
		elseif k == "SYNONYM" then
			local body = table.concat2(v, function(syn)
				return makeword(learn(syn, PSQOBJECT, nil))
			end)
			table.insert(t, makeprop(body, k))
		elseif k == "ADJECTIVE" then
			table.insert(t, makeprop(table.concat2(v, function(adj)
				return string.char(learn(adj, PSQADJECTIVE, ADJECTIVES))
			end), k))
		elseif k == "FLAGS" then
			local flags = 0
			for _, f in ipairs(v) do
				if not _G[f] then _G[f] = register(FLAGS, f) end
				flags = flags | (1 << _G[f])
			end
			table.insert(t, makeprop(makeqword(flags), k))
		elseif k == "GLOBAL" then 	
			table.insert(t, makeprop(table.concat2(v, string.char), k))
		elseif k == "LOC" then 
			-- LOC property: stores the object's location as a numeric object ID
			-- In proper ZIL games, containers like ROOMS are defined as objects with numeric IDs
			-- If LOC is a table (e.g., bootstrap's default ROOMS = {}), we use 0 to indicate "no valid location"
			-- This is acceptable because well-formed ZIL will redefine ROOMS as an actual object
			-- Once ROOMS is defined as an object, its numeric ID will be used correctly
			local loc_value = type(v) == 'number' and v or 0
			table.insert(t, makeprop(makebyte(loc_value), k))
		-- using PQACTION for ACTION property, commented out original function support
		elseif k == "ACTION" or k == "DESCFCN" then 
			table.insert(t, makeprop(function_prop(v, k, n), k))
		elseif k == "THINGS" and type(v) == "number" then
			table.insert(t, makeprop(makeword(v), k))
		elseif type(v) == 'string' then table.insert(t, makeprop(mem:stringprop(v), k))
		elseif type(v) == 'number' then table.insert(t, makeprop(makebyte(v), k))
		elseif type(v) == 'function' then table.insert(t, makeprop(mem:stringprop(fn(v)), k))
		elseif _DIRECTIONS[k] or (type(v) == "table" and (v.per or v[1] ~= nil)) then
			if not _DIRECTIONS[k] then DIRECTIONS(k) end
			local str
			if type(v) == 'number' then
				-- UEXIT: bare number from compiler (e.g., SOUTH = ROOM_ID)
				str = string.char(v)
			elseif type(v) == 'string' then
				-- NEXIT: bare string from compiler (e.g., OUT = "message")
				str = mem:write(v.."\0")
			elseif v.per then
				local per = resolve_global(v.per)
				if type(per) == "table" and per.__routine_ref then
					defer_routine_ref(per.__routine_ref, n, k, "exit")
					str = makeword(0)..string.char(0) -- deferred FEXIT = 3
				else
					assert(type(per) == "function", "Unresolved exit routine for "..tostring(object_name).."."..tostring(k))
					str = makeword(fn(per))..string.char(0) -- FEXIT = 3
				end
			elseif type(v[1]) == 'string' then
				str = mem:write(v[1].."\0") -- NEXIT = 2
			else
				if v[1] == nil then
					error(string.format("Unresolved exit target for %s.%s", tostring(object_name), tostring(k)))
				end
				str = string.char(v[1]) -- UEXIT = 1
				local say = v.say and mem:writestring2(v.say) or 0
				if v.door ~= nil then
					local door = type(v.door) == "boolean" and (v.door and 1 or 0) or v.door
					str = str..string.char(door)..makeword(say)..string.char(0) -- DEXIT = 5
				elseif v.flag ~= nil then
					local flag_val = v.flag
					if type(flag_val) == "table" and flag_val.__global_ref then
						local gname = flag_val.__global_ref
						if not _GLOBAL_FLAG_SLOTS[gname] then
							_next_global_flag_slot = _next_global_flag_slot + 1
							_GLOBAL_FLAG_SLOTS[gname] = _next_global_flag_slot
							_GLOBAL_FLAG_NAMES[_next_global_flag_slot] = gname
						end
						local variable = _GLOBAL_FLAG_SLOTS[gname]
						assert(variable <= 255, "Too many global variables for conditional exits (max 240)")
						str = str..string.char(variable)..makeword(say) -- CEXIT = 4
					else
						flag_val = type(flag_val) == "boolean" and (flag_val and 1 or 0) or flag_val
						str = str..string.char(flag_val)..makeword(say) -- CEXIT = 4
					end
				end
			end
			table.insert(t, makeprop(str, k))
		else 
			assert(false, "Unsupported property "..k.." of type "..type(v))
		end
	end
	-- Ensure LOC property always exists (default to 0 if not specified)
	if not object.LOC then
		local loc_value = 0
		table.insert(t, makeprop(makebyte(loc_value), "LOC"))
	end
	-- Ensure FLAGS property always exists (default to 0 if not specified)
	if not object.FLAGS then
		table.insert(t, makeprop(makeqword(0), "FLAGS"))
	end
	local tbl_addr = mem:write(table.concat(t) .. "\0\0")
	mem:write(makeword(tbl_addr), _OTBL + (n-1)*2)
	-- Initial object trees retain declaration order. Runtime MOVE uses the
	-- Z-machine rule of inserting the object at the head of its new parent.
	local parent = LOC(n)
	if parent and parent ~= 0 then
		local first = mem:byte(_CHILD_TBL + parent)
		if first == 0 then
			mem:write(makebyte(n), _CHILD_TBL + parent)
		else
			local sibling = first
			while mem:byte(_SIBLING_TBL + sibling) ~= 0 do
				sibling = mem:byte(_SIBLING_TBL + sibling)
			end
			mem:write(makebyte(n), _SIBLING_TBL + sibling)
		end
	end
end

function REST(s, i)
	if type(s) == 'number' then
		return s+(i or 1)
	end
	if type(s) == 'table' then s = string.char(#s)..table.concat(s) end
	return s:sub((i or 1) + 1)
end

function BACK(s, i)
	if type(s) == 'number' then
		return s-(i or 1)
	end
	error("BACK: unsupported type " .. type(s))
end

function EMPTYQ(s)
	if s == nil then return true end
	if type(s) == 'table' then
		return #s == 0
	end
	if type(s) == 'string' then
		return #s == 0
	end
	return s == false or s == 0
end

function LENGTHQ(s, n)
	if s == nil then return n == nil end
	if type(s) == 'table' then
		return n == nil or #s == n
	end
	if type(s) == 'string' then
		return n == nil or #s == n
	end
	return n == nil or 1 == n
end

FIX = "FIX"

function TYPEQ(v, ...)
	local types = {...}
	for _, t in ipairs(types) do
		if t == "ATOM" then
			if type(v) == "number" or type(v) == "string" or type(v) == "boolean" then
				return true
			end
		elseif t == "LIST" then
			if type(v) == "table" then return true end
		elseif t == "STRING" then
			if type(v) == "string" then return true end
		elseif t == "TABLE" then
			if type(v) == "table" then return true end
		elseif t == "FIX" then
			if type(v) == "number" then return true end
		elseif t == "FORM" then
			if type(v) == "function" or type(v) == "table" then return true end
		elseif t == "FALSE" then
			if v == false or v == 0 or v == nil then return true end
		end
	end
	return false
end

function NTH(s, i)
	if type(s) == 'table' then
		return s[i]
	end
	if type(s) == 'string' then
		return s:sub(i, i)
	end
	return nil
end

function AND(...)
	local args = {...}
	for i = 1, #args do
		if not args[i] or args[i] == 0 then return args[i] end
	end
	return args[#args]
end

function OR(...)
	local args = {...}
	for i = 1, #args do
		if args[i] and args[i] ~= 0 then return args[i] end
	end
	return args[#args]
end

function APPLY(func, ...)
	if type(func) == 'number' then
		if func == 0 then return end
		return FUNCTIONS[func](...)
	else
		return func and func(...)
	end
end

function PUT(obj, i, val)
	assert(type(obj) == 'number', "PUT: Only number types, not "..type(obj))
	if obj == 0 then
		val = type(val) == 'function' and fn(val) or val or 0
		z_header[i * 2] = val & 0xff
		z_header[i * 2 + 1] = (val >> 8) & 0xff
		return
	end
	mem:write(makeword(type(val) == 'function' and fn(val) or val or 0), obj+i*2)
end

function PUTB(s, i, val) 
	assert(type(s) == 'number', "PUTB: Only number types, not "..type(s))
	if s == 0 then
		z_header[i] = val & 0xff
		return
	end
	mem:write(makebyte(val), s+i)
end
-- function GET(t, i) return type(t) == 'table' and t[i * 2] or 0 end
-- function GETB(t, i) return type(t) == 'table' and t[i] or 0 end

function GETB(s, i)
	assert(type(s) == 'number', "GETB: Only number types")
	if s == 0 then return z_header[i or 0] or 0 end
	return mem:byte(s+i)
	-- if s == 0 then return GET(s)
	-- elseif type(s) == 'string' then return i==0 and #i or s:byte(i)
	-- elseif type(s) == 'table' then return i==0 and #s or table.concat(s):byte(i)
	-- elseif type(s) == 'number' then return mem:byte(s+i)
	-- else 
	-- 	error("GETB: Unsupported type "..type(s))
	-- end
end

function GET(s, i)
	if not i then return 0 end
	if type(s) == 'number' then
		return (GETB(s,i*2) or 0)|((GETB(s,i*2+1) or 0)<<8)
	end
	assert(type(s) == 'table', "GET requires a table")
	return i == 0 and #s or s[i]
	-- if type(s) == 'table' then return s.index and s:index(i) or s[i] end
	-- return GETB(s, i * 2) | (GETB(s, i * 2 + 1) << 8)
end

function DIRECTIONS(...)
	for _, dir in ipairs {...} do
		-- Top-level object declarations are emitted before directive bodies. If
		-- the next direction-property number aliases the numeric pseudo-object
		-- IT, swap that still-forward declaration with the final object declared
		-- in this module. Otherwise WALK WEST can look like pronoun substitution.
		local next_property = 1
		for _ in pairs(PROPERTIES) do next_property = next_property + 1 end
		for object_name, object_id in pairs(declared_objects) do
			if object_name == "IT" and object_id == next_property
					and not getobj(object_id) then
				for swap_name, swap_id in pairs(declared_objects) do
					if swap_id == _obj_count and not getobj(swap_id) then
						declared_objects[swap_name] = object_id
						_G[swap_name] = object_id
						break
					end
				end
				declared_objects[object_name] = _obj_count
				_G[object_name] = _obj_count
				break
			end
		end
		_DIRECTIONS[dir] = learn(dir, PSQDIRECTION, PROPERTIES)
		if type(DIRS) == "table" and dir ~= "IN" and dir ~= "OUT" then
			table.insert(DIRS, dir:lower())
		end
	end
end

local function action_id(fn_idx)
	if _act_fn_to_id[fn_idx] then return _act_fn_to_id[fn_idx] end
	_act_count = _act_count + 1
	assert(_act_count <= 255, "Too many actions (max 255)")
	_act_fn_to_id[fn_idx] = _act_count
	-- Write fn_idx at offset _act_count*2 so that GET(ACTIONS, _act_count) = mem:word(ACTIONS + _act_count*2) reads it back.
	-- Action IDs are 1-based; offset 0 is unused (same convention as VERBS).
	mem:write(makeword(fn_idx), ACTIONS + _act_count * 2)
	return _act_count
end

function TRACEBACK()
	print(debug.traceback())
end

function PTABLE(tbl, size)
	local out = {}
	for i = 0, size do table.insert(out, GET(tbl, i)) end
	print(table.concat(out, " "))
end

function SYNTAX(syn)
	VERBS = VERBS or mem:write(string.rep('\0\0', 256))
	if ACTIONS == 0 then
		ACTIONS = mem:write(string.rep('\0\0', 256))
		PREACTIONS = mem:write(string.rep('\0\0', 256))
	end
	local name = syn.VERB:lower()
	if not syn.ACTION then
		error(string.format("SYNTAX for verb '%s' is missing ACTION", syn.VERB))
	end
	-- Defer if the action function isn't defined yet (e.g., syntax.zil loaded before verbs.zil)
	if _G[syn.ACTION] == nil or (syn.PREACTION and _G[syn.PREACTION] == nil) then
		table.insert(_pending_syntax, syn)
		return
	end
	local action = action_id(fn(_G[syn.ACTION]))
	local function encode(s)
		return string.char(
			s.OBJECT and (s.SUBJECT and 2 or 1) or 0,
			learn(s.PREFIX, PSQPREPOSITION, PREPOSITIONS),
			learn(s.JOIN, PSQPREPOSITION, PREPOSITIONS),
			s.OBJECT and s.OBJECT.FIND or 0,
			s.SUBJECT and s.SUBJECT.FIND or 0,
			s.OBJECT and s.OBJECT.WHERE or 0,
			s.SUBJECT and s.SUBJECT.WHERE or 0,
			action
		)
	end
	if cache.verbs[name] then
		local ptr = GET(VERBS, cache.verbs[name])
		local num = GETB(ptr, 0)
		local bytecode = encode(syn)
		mem:write(string.char(num + 1), ptr)
		mem:write(bytecode, ptr + 1 + num * #bytecode)
	else
		local num = register(cache.verbs, name)
		local bytecode = string.rep(encode(syn), _G["NUM_"..syn.VERB] or 1)
		PUT(VERBS, num, mem:write(string.char(1)..bytecode))
		_G['ACTQ'..syn.VERB] = learn(name, PSQVERB, 255-num)
	end
	_G[syn.ACTION:gsub("_", "Q", 1)] = action
	if syn.PREACTION then 
		mem:write(makeword(fn(_G[syn.PREACTION])), PREACTIONS + action * 2)
	end
end

function FINALIZE_SYNTAX()
	local pending = _pending_syntax
	_pending_syntax = {}
	for _, syn in ipairs(pending) do
		SYNTAX(syn)
	end
	local synonyms = _pending_synonyms
	_pending_synonyms = {}
	for _, args in ipairs(synonyms) do
		SYNONYM(table.unpack(args))
	end
end

function BUZZ(...)
	for _, buzz in ipairs {...} do
		learn(buzz, PSQBUZZ_WORD, nil)
		_G['WQ'..buzz:upper()] = cache.words[buzz:lower():sub(1, 6)]
	end
end

function DEFER_SYNONYM(...)
	_pending_synonyms[#_pending_synonyms + 1] = {...}
	return true
end

function SYNONYM(verb, ...)
	verb = verb:lower():sub(1, 6)
	cache.synonyms[verb] = {...}
  for _, syn in ipairs {...} do
		-- Truncate to 6 chars (Z-machine dictionary convention)
		local syn_key = syn:lower():sub(1, 6)
		if cache.words[verb] then
			if cache.words[syn_key] then
				merge_dictionary_word(cache.words[syn_key], cache.words[verb])
			else
				cache.words[syn_key] = mem:write(mem:read(7, cache.words[verb]))
			end
		else
			cache.words[syn_key] = cache.words[syn_key]
				or mem:write(string.rep('\0', 7))
		end
		_G['WQ'..syn:upper()] = cache.words[syn_key]
  end
end

ROOM = OBJECT

function ITABLE(size, maybe_size)
	if size == nil and type(maybe_size) == "number" then
		size = maybe_size
	end
	local address = mem:write_word(size)
	mem:write(string.rep("\0", size))
	return address
end

function ITABLE_WORDS(count, pattern_width)
	count = count or 0
	pattern_width = pattern_width or 1
	return mem:write(string.rep("\0\0", count * pattern_width))
end

function STRING_TABLE(value, with_length)
	value = tostring(value or "")
	if with_length then
		assert(#value <= 255, "Length-prefixed STRING table exceeds 255 bytes")
		return mem:write(string.char(#value) .. value)
	end
	return mem:write(value)
end

local pending_table_refs = {}

function PSEUDO_TABLE(...)
	local entries = {...}
	-- Room PSEUDO property: alternating noun spelling and routine reference.
	if type(entries[1]) == "string" then
		local words = {}
		local refs = {}
		local offset = 0
		for i = 1, #entries, 2 do
			local noun = VOC(entries[i], NOUN)
			local routine = entries[i + 1]
			words[#words + 1] = makeword(noun)
			offset = offset + 2
			if type(routine) == "function" then
				words[#words + 1] = mem:stringprop(fn(routine))
			elseif type(routine) == "table" and routine.__routine_ref then
				words[#words + 1] = makeword(0)
				refs[#refs + 1] = { name = routine.__routine_ref, offset = offset }
			else
				error("PSEUDO_TABLE expected an action routine reference")
			end
			offset = offset + 2
		end
		return { __property_bytes = table.concat(words), __routine_refs = refs }
	end

	-- Legacy THINGS/PSEUDO tuple form.
	local words = {}
	for _, entry in ipairs(entries) do
		local adjective = entry[1] and VOC(entry[1], ADJECTIVE) or 0
		local noun = entry[2] and VOC(entry[2], NOUN) or 0
		words[#words + 1] = makeword(adjective) .. makeword(noun)
	end
	return mem:write(makeword(#entries * 2) .. table.concat(words))
end

local function table_word(value, pending, offset)
	if type(value) == 'string' then return makeword(mem:writestring2(value)) end
	if type(value) == 'number' then return makeword(value) end
	if type(value) == 'nil' then return makeword(0) end
	if type(value) == 'table' and value.__global_ref then
		pending[#pending + 1] = {offset = offset, name = value.__global_ref}
		return makeword(0)
	end
	error("TABLE: Unsupported type "..type(value))
end

function TABLE(...)
	local tbl = {}
	local pending = {}
	for i = 1, select("#", ...) do
		tbl[i] = table_word(select(i, ...), pending, (i - 1) * 2)
	end
	local address = mem:write(table.concat(tbl))
	for _, ref in ipairs(pending) do
		ref.address = address + ref.offset
		pending_table_refs[#pending_table_refs + 1] = ref
	end
	return address
end

function LTABLE(...)
	local n = select("#", ...)
	local tbl = {}
	local pending = {}
	for i = 1, n do
		tbl[i] = table_word(select(i, ...), pending, i * 2)
	end
	local address = mem:write_word(n)
	mem:write(table.concat(tbl))
	for _, ref in ipairs(pending) do
		ref.address = address + ref.offset
		pending_table_refs[#pending_table_refs + 1] = ref
	end
	return address
end

function FINALIZE_REFERENCES()
	for _, ref in ipairs(pending_table_refs) do
		local value = rawget(_G, ref.name)
		assert(type(value) == "number", "Unresolved table reference: "..ref.name)
		mem:write(makeword(value), ref.address)
	end
	pending_table_refs = {}
	for name, refs in pairs(pending_routine_refs) do
		if #refs > 0 then
			error("Unresolved routine reference: "..name)
		end
	end
end

BUZZ(".", ",", "\"")


-- ENABLE/DISABLE helpers for clock interrupts
-- These are defined as macros in ZIL (macros.zil) but we implement them as functions
-- ENABLE: <DEFMAC ENABLE ('INT) <FORM PUT .INT ,C-ENABLED? 1>>
-- DISABLE: <DEFMAC DISABLE ('INT) <FORM PUT .INT ,C-ENABLED? 0>>
function ENABLE(i)
    PUT(i, C_ENABLEDQ, 1)
    return i
end

function DISABLE(i)
    PUT(i, C_ENABLEDQ, 0)
    return i
end

function FLAMINGQ(OBJ)
	return FSETQ(OBJ, FLAMEBIT) and FSETQ(OBJ, ONBIT)
end

function OPENABLEQ(OBJ)
		return FSETQ(OBJ, DOORBIT) or FSETQ(OBJ, CONTBIT)
end

function CO_CREATE(func)
	local co = coroutine.create(function(...)
		while true do
			local ok, result = pcall(func, ...)
			if ok then
				return result
			end
			if is_control_signal(result, "restart") then
				-- Restart reruns the entry routine from the captured initial state.
			elseif is_control_signal(result, "quit") then
				return
			else
				error(result, 0)
			end
		end
	end)
	coroutine.resume(co)  -- Start the coroutine
	return co
end

 -- if only_flag is true, return only success flag, for chaining of arguments
function CO_RESUME(co, param, only_flag)
	_G.TEST_BREADCRUMB_STEP = (_G.TEST_BREADCRUMB_STEP or 0) + 1
	_G.TEST_BREADCRUMB_COMMAND = param
	local ok, err = coroutine.resume(co, param)
	if only_flag then
		return ok
	else
		return ok, err
	end
end

local function dirname(path)
	return path and path:match("^(.*)[/\\][^/\\]*$") or nil
end

local function try_open(path)
	local file = io.open(path, "r")
	if file then return file, path end
	local lower = path:lower()
	if lower ~= path then
		file = io.open(lower, "r")
		if file then return file, lower end
	end
	return nil, nil
end

-- INSERT_FILE loads and executes a ZIL file
-- This is used by INSERT-FILE directive to include other files
function INSERT_FILE(filename, source_filename)
	-- Convert module-style filename (e.g., "zork1.globals") to file path
	local name_path = filename:gsub("%.", "/")
	local file, filepath

		local function lowercase_basename(path)
			local prefix, name = path:match("^(.*[/\\])([^/\\]+)$")
			if prefix then
				return prefix .. name:lower()
			end
			return path:lower()
		end

		local function try_candidate(path)
			if not path or path == "" then return nil end
			file, filepath = try_open(path)
			if file then return true end
			if not path:match("%.zil$") then
				file, filepath = try_open(path .. ".zil")
				if file then return true end
			end
			local lower_path = lowercase_basename(path)
			if lower_path ~= path then
				file, filepath = try_open(lower_path)
				if file then return true end
				if not lower_path:match("%.zil$") then
					file, filepath = try_open(lower_path .. ".zil")
					if file then return true end
				end
			end
			return false
		end

	local base_dir = dirname(source_filename)
	if base_dir and not name_path:match("^/") and try_candidate(base_dir .. "/" .. name_path) then
		-- Found relative to including file.
	end
	
	-- Search for the file using package.zilpath if available
	if not file and package and package.zilpath then
		for path_pattern in package.zilpath:gmatch("[^;]+") do
			if try_candidate(path_pattern:gsub("?", name_path):gsub("%.zil$", "")) then
				break
			end
		end
	end
	
	-- If not found, try direct path with .zil extension
	if not file then try_candidate(name_path) end
	
	-- If still not found, try the filename as-is
	if not file then try_candidate(filename) end
	
	-- Final fallback: try infocom/zork1/ as substrate
	if not file and not name_path:match("infocom/zork[123][/\\]") then
		try_candidate("infocom/zork1/" .. name_path)
	end
	
	if not file then
		error(string.format("INSERT_FILE: Cannot open '%s' (resolved to '%s', tried package.zilpath and direct paths)", filename, name_path))
	end
	
	local content = file:read("*all")
	file:close()
	
	-- Parse and compile the ZIL content
	local parser = require 'zilscript.parser'
	local compiler = require 'zilscript.compiler'
	local sourcemap = require 'zilscript.sourcemap'
	
	local ok, ast = pcall(parser.parse, content, filepath)
	if not ok then
		error(string.format("%s: Failed to parse: %s", filepath, ast))
	end
	
	local result = compiler.compile(ast, filepath .. ".lua")
	
	-- Execute the compiled code in the current environment
	local chunk, load_err = load(result.combined, "@" .. filepath, "t", _G)
	if not chunk then
		error(string.format("%s: Failed to load: %s", filepath, sourcemap.translate(load_err)))
	end
	
	local exec_ok, exec_err = pcall(chunk)
	if not exec_ok then
		error(string.format("%s: Failed to execute: %s", filepath, sourcemap.translate(exec_err)))
	end
end

-- === Save / Restore game state ===
-- The save file contains: mem (which holds object properties, locations, and FLAGS),

local SAVE_MAGIC_V1 = "ZILSAVE\1"
local SAVE_MAGIC_V2 = "ZILSAVE\2"
local SAVE_CHUNK_SIZE = 4096  -- Write mem to file in chunks to avoid table.unpack limits

-- Write a 4-byte little-endian integer into file
local function write_int32(file, val)
	file:write(string.char(val & 0xff, (val >> 8) & 0xff, (val >> 16) & 0xff, (val >> 24) & 0xff))
end

-- Write an 8-byte little-endian integer into file
local function write_int64(file, val)
	write_int32(file, val & 0xffffffff)
	write_int32(file, (val >> 32) & 0xffffffff)
end

-- Read a 4-byte little-endian integer from a 4-byte string
local function read_int32(s)
	return s:byte(1) | (s:byte(2) << 8) | (s:byte(3) << 16) | (s:byte(4) << 24)
end

-- Read an 8-byte little-endian integer from a string at byte offset 1..8
local function read_int64(s)
	local val = 0
	for i = 1, 8 do val = val | (s:byte(i) << ((i - 1) * 8)) end
	return val
end

function SAVE(filename)
	filename = filename or "savefile.sav"
	local file = io.open(filename, "wb")
	if not file then
		TELL("Cannot open save file.", CR)
		return false
	end

	-- Header
	file:write(SAVE_MAGIC_V2)

	-- mem: size (4 bytes LE) + raw bytes written in chunks
	local size = mem.size
	write_int32(file, size)
	local pos = 1
	while pos <= size do
		local chunk_end = math.min(pos + SAVE_CHUNK_SIZE - 1, size)
		local bytes = {}
		for i = pos, chunk_end do bytes[#bytes + 1] = mem[i] or 0 end
		file:write(string.char(table.unpack(bytes)))
		pos = chunk_end + 1
	end

	-- ZIL globals: count (2 bytes LE) + name-length-prefixed name + typed value
	-- Save from both _G and the game environment (env) since some globals
	-- like VERBS, ROOMS, PROPERTIES live in env, not _G
	local to_save = {}
	local seen = {}
	for name, val in pairs(_G) do
		if is_state_global(val) then
			table.insert(to_save, {name, val})
			seen[name] = true
		end
	end
	-- Also save env globals (accessible as _G inside the bootstrap)
	local game_env = _G
	for name, val in pairs(game_env) do
		if is_state_global(val) and not seen[name] then
			table.insert(to_save, {name, val})
			seen[name] = true
		end
	end
	file:write(makeword(#to_save))
	for _, entry in ipairs(to_save) do
		local name, val = entry[1], entry[2]
		local namelen = math.min(#name, 255)
		file:write(string.char(namelen) .. name:sub(1, namelen))
		if type(val) == 'number' then
			file:write(string.char(1))  -- type 1 = number
			write_int64(file, val)
		elseif type(val) == 'boolean' then
			file:write(string.char(2))  -- type 2 = boolean
			file:write(string.char(val and 1 or 0))
		else
			file:write(string.char(3))  -- type 3 = string
			write_int32(file, #val)
			file:write(val)
		end
	end

	-- Save cache.words (vocabulary lookup table) as a special entry
	-- Type 4 = cache_words: count(2) + pairs of (namelen(1) + name + address(8))
	local cw_count = 0
	for _ in pairs(cache.words) do cw_count = cw_count + 1 end
	file:write(string.char(4))  -- type 4 = cache_words
	file:write(makeword(cw_count))
	for word, addr in pairs(cache.words) do
		local namelen = math.min(#word, 255)
		file:write(string.char(namelen) .. word)
		write_int64(file, addr)
	end

	-- Save exact-input aliases separately from the six-character dictionary.
	-- Type 5 = exact_words: count(2) + source/target strings and first-word flag.
	local exact_count = 0
	for _ in pairs(cache.exact_words) do exact_count = exact_count + 1 end
	file:write(string.char(5))
	file:write(makeword(exact_count))
	for source, spec in pairs(cache.exact_words) do
		local target = type(spec) == "table" and spec.target or spec
		local first = type(spec) == "table" and spec.first or false
		local source_len = math.min(#source, 255)
		local target_len = math.min(#target, 255)
		file:write(string.char(source_len) .. source:sub(1, source_len))
		file:write(string.char(target_len) .. target:sub(1, target_len))
		file:write(string.char(first and 1 or 0))
	end

	file:close()
	return true
end

function RESTORE(filename)
	filename = filename or "savefile.sav"
	local file = io.open(filename, "rb")
	if not file then
		TELL("Cannot open save file.", CR)
		return false
	end

	-- Verify header
	local magic = file:read(#SAVE_MAGIC_V2)
	if magic ~= SAVE_MAGIC_V1 and magic ~= SAVE_MAGIC_V2 then
		TELL("Invalid save file.", CR)
		file:close()
		return false
	end

	-- Restore mem
	local sb = file:read(4)
	if not sb or #sb < 4 then file:close(); return false end
	local size = read_int32(sb)
	local data = file:read(size)
	if not data or #data < size then file:close(); return false end
	for i = 1, size do mem[i] = data:byte(i) end
	mem.size = size

	-- Restore ZIL globals
	local restored_globals = {}
	local gc = file:read(2)
	if gc and #gc >= 2 then
		local num_globals = gc:byte(1) | (gc:byte(2) << 8)
		for _ = 1, num_globals do
			local nl = file:read(1)
			if not nl then break end
			local name = file:read(nl:byte())
			if not name then break end
			local gtype = file:read(1)
			if not gtype then break end
			if gtype:byte() == 1 then
				local vb = file:read(8)
				if vb and #vb >= 8 then
					_G[name] = read_int64(vb)
					restored_globals[name] = true
				end
			elseif gtype:byte() == 2 then
				local vb = file:read(1)
				if vb then
					_G[name] = vb:byte() ~= 0
					restored_globals[name] = true
				end
			elseif gtype:byte() == 3 then
				local len_bytes = file:read(4)
				if not len_bytes or #len_bytes < 4 then break end
				local len = read_int32(len_bytes)
				local vb = file:read(len)
				if vb and #vb >= len then
					_G[name] = vb
					restored_globals[name] = true
				end
			elseif gtype:byte() == 4 then
				-- type 4 = cache_words: count(2) + pairs of (namelen(1) + name + address(8))
				local count_bytes = file:read(2)
				if count_bytes and #count_bytes >= 2 then
					local cw_count = count_bytes:byte(1) | (count_bytes:byte(2) << 8)
					for _ = 1, cw_count do
						local nl = file:read(1)
						if not nl then break end
						local wname = file:read(nl:byte())
						if not wname then break end
						local addr_bytes = file:read(8)
						if addr_bytes and #addr_bytes >= 8 then
							cache.words[wname] = read_int64(addr_bytes)
						end
					end
				end
			end
		end
	end

	-- Version 2 saves append the vocabulary address map after the scalar globals.
	-- Dictionary storage is rebuilt whenever a game process starts, and its
	-- addresses are not guaranteed to match those in the process that wrote the
	-- save.  Restore the saved map so READ and parser word lookups point into the
	-- memory image we just loaded.
	if magic == SAVE_MAGIC_V2 then
		local section_type = file:read(1)
		if section_type and section_type:byte() == 4 then
			local count_bytes = file:read(2)
			if not count_bytes or #count_bytes < 2 then
				file:close()
				return false
			end
			local cw_count = count_bytes:byte(1) | (count_bytes:byte(2) << 8)
			local restored_words = {}
			for _ = 1, cw_count do
				local nl = file:read(1)
				if not nl then
					file:close()
					return false
				end
				local word = file:read(nl:byte())
				local addr_bytes = file:read(8)
				if not word or not addr_bytes or #addr_bytes < 8 then
					file:close()
					return false
				end
				restored_words[word] = read_int64(addr_bytes)
			end
			cache.words = restored_words
		end

		local exact_section_type = file:read(1)
		if exact_section_type and exact_section_type:byte() == 5 then
			local count_bytes = file:read(2)
			if not count_bytes or #count_bytes < 2 then
				file:close()
				return false
			end
			local exact_count = count_bytes:byte(1) | (count_bytes:byte(2) << 8)
			local restored_exact_words = {}
			for _ = 1, exact_count do
				local source_len = file:read(1)
				if not source_len then file:close(); return false end
				local source = file:read(source_len:byte())
				local target_len = file:read(1)
				if not source or not target_len then file:close(); return false end
				local target = file:read(target_len:byte())
				local flags = file:read(1)
				if not target or not flags then file:close(); return false end
				if flags:byte() & 1 ~= 0 then
					restored_exact_words[source] = { target = target, first = true }
				else
					restored_exact_words[source] = target
				end
			end
			cache.exact_words = restored_exact_words
		end
	end

	-- Clean up state globals in the game environment (env) that weren't in the save file.
	-- _G inside the bootstrap IS the env table (env._G = env).
	local game_env = _G
	for name, value in pairs(game_env) do
		if is_state_global(value) and not restored_globals[name] then
			game_env[name] = nil
		end
	end

	file:close()
	return true
end

-- === LLM Mode Support ===
-- Flag to indicate game was restored and should skip GO() initialization
_LLM_RESTORED = false

-- === Done ===
