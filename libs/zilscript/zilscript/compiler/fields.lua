-- Field writing functions for ZIL objects
local utils = require 'zilscript.compiler.utils'

local Fields = {}

local function writeObjectRef(buf, node, compiler)
  if node.type == "number" then
    buf.write("%s", compiler.value(node))
  else
    buf.write('OBJECT_REF("%s")', compiler.value(node))
  end
end

-- Helper: Write a list with optional formatting function
local function writeFormattedList(buf, node, formatter, compiler)
  local list = {}
  for i = 2, #node do
    local child = node[i]
    table.insert(list, formatter and formatter(child) or compiler.value(child))
  end
  buf.write("{")
  buf.write(table.concat(list, ", "))
  buf.write("}")
end

-- Write list of strings
local function writeListString(buf, node, compiler)
  writeFormattedList(buf, node, function(child)
    return string.format('"%s"', compiler.value(child))
  end, compiler)
end

-- Vocabulary is player-facing text, not a Lua identifier. Preserve ZIL word
-- spelling (notably hyphens) so commands such as "take torn-page" resolve.
local function writeWordList(buf, node, compiler)
  writeFormattedList(buf, node, function(child)
    return string.format("%q", tostring(child.value))
  end, compiler)
end

-- Write plain list
local function writeList(buf, node, compiler)
  writeFormattedList(buf, node, nil, compiler)
end

local function writeObjectList(buf, node, compiler)
  buf.write("{")
  for i = 2, #node do
    if i > 2 then buf.write(", ") end
    writeObjectRef(buf, node[i], compiler)
  end
  buf.write("}")
end

-- Write first child with optional quoting
local function writeFirstChild(buf, node, quote_non_strings, compiler)
  if #node >= 2 then
    local child = node[2]
    if quote_non_strings and child.type ~= "string" then
      buf.write('"%s"', child.value)
    else
      buf.write("%s", compiler.value(child))
    end
  end
end

-- Write string field (first child, quoted)
local function writeStringField(buf, node, compiler)
  writeFirstChild(buf, node, true, compiler)
end

-- Write value field (first child, unquoted)
local function writeValueField(buf, node, compiler)
  writeFirstChild(buf, node, false, compiler)
end

-- Routine-valued properties are symbolic in ZIL and may refer to routines
-- declared in a later INSERT-FILE. Keep the name until the runtime linker can
-- resolve it instead of eagerly reading a possibly-nil Lua global.
local function writeRoutineField(buf, node, compiler)
  local child = node[2]
  if not child then return end
  if child.type == "number" then
    buf.write("%s", compiler.value(child))
  else
    buf.write('ROUTINE_REF("%s")', compiler.value(child))
  end
end

local function writeObjectField(buf, node, compiler)
  if node[2] then writeObjectRef(buf, node[2], compiler) end
end

-- Zork room PSEUDO properties are alternating vocabulary words and action
-- routines.  Keep routine names symbolic because adventure actions commonly
-- load after dungeon objects.
local function writePseudoField(buf, node, compiler)
  buf.write("PSEUDO_TABLE(")
  for i = 2, #node, 2 do
    if i > 2 then buf.write(", ") end
    local word = node[i]
    local routine = node[i + 1]
    buf.write("%q, ROUTINE_REF(%q)", tostring(word.value), compiler.value(routine))
  end
  buf.write(")")
end

-- Field writer dispatch table
Fields.FIELD_WRITERS = {
  FLAGS = writeListString,
  SYNONYM = writeWordList,
  ADJECTIVE = writeWordList,
  DESC = writeStringField,
  LDESC = writeStringField,
  FDESC = writeStringField,
  ACTION = writeRoutineField,
  DESCFCN = writeRoutineField,
  IN = writeObjectField,
  GLOBAL = writeObjectList,
  PSEUDO = writePseudoField,
}

-- Navigation direction writer
-- Format: (direction TO room [IF condition [IS flag]] [ELSE say])
function Fields.writeNav(buf, node, compiler)
  local parts = {}
  
  -- Collect navigation parts
  for i = 2, #node do
    table.insert(parts, node[i])
  end
  
  -- parts[1] = TO
  -- parts[2] = room
  -- parts[3] = IF (optional)
  -- parts[4] = condition (optional)
  -- parts[5] = IS (optional)
  -- parts[6] = flag (optional)
  -- parts[7] = ELSE (optional)
  -- parts[8] = say (optional)
  
  if utils.safeget(parts[3], 'value') == "IF" and parts[4] then
    -- Conditional navigation - use table and/or for short-circuit evaluation
    local cond = compiler.value(parts[4])
    
    -- Check for IS flag test
    if utils.safeget(parts[5], 'value') == "IS" and parts[6] then
      cond = "door = "..cond
    else
      if parts[4].type == "ident" or parts[4].type == "symbol" then
        cond = "flag = GLOBAL_FLAG_REF(\"" .. cond .. "\")"
      else
        cond = "flag = "..cond
      end
    end
    
    local room = compiler.value(parts[2])
    
    -- Check for ELSE clause
    local else_idx = utils.safeget(parts[5], 'value') == "ELSE" and 6 or
                     utils.safeget(parts[7], 'value') == "ELSE" and 8 or nil
    local say = else_idx and parts[else_idx] and compiler.value(parts[else_idx]) or nil
    
    if say then
      buf.write('{OBJECT_REF("%s"), %s, say = %s}', room, cond, say)
    else
      buf.write('{OBJECT_REF("%s"), %s}', room, cond)
    end
  elseif parts[2] then
    -- Simple navigation
    writeObjectRef(buf, parts[2], compiler)
  elseif utils.safeget(parts[1], 'type') == "string" then
    buf.write("%s", compiler.value(parts[1]))
  else
    buf.write("nil")
  end
end

-- Write field using appropriate writer or default
function Fields.writeField(buf, node, field_name, compiler)
  if field_name == "THINGS" and node[2] and node[2].type == "expr"
      and node[2].name == "PSEUDO" then
    buf.write("PSEUDO_TABLE(")
    for i, tuple in ipairs(node[2]) do
      if i > 1 then buf.write(", ") end
      local adjective = tuple[1] and tuple[1].value
      local noun = tuple[2] and tuple[2].value
      buf.write("{%s, %q}", adjective and string.format("%q", adjective) or "nil", noun)
    end
    buf.write(")")
    return
  end
  local writer = Fields.FIELD_WRITERS[field_name] or writeValueField
  writer(buf, node, compiler)
end

return Fields
