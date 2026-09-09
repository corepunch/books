-- Expression form handlers for ZIL compiler
-- Each handler is responsible for emitting code for a specific ZIL form
--
-- Pattern Note: These handlers receive (buf, node, indent) and use:
-- - buf.write() for output (dot notation, not colon)
-- - node[i].value for direct property access (like TypeScript)
-- - compiler.value(node) for value conversion (helper function pattern)
--
-- This follows TypeScript's emitter pattern where specialized functions
-- handle different node types, rather than having nodes emit themselves.
local utils = require 'zilscript.compiler.utils'

local Forms = {}

-- Helper: Generate error return with specified value
local function writeErrorReturn(buf, error_value)
  buf.write("\terror(%s)", error_value)
end

-- Helper: Generate a function call with string arguments from node values
local function writeStringCall(buf, name, node)
  buf.write("%s(", name)
  for i = 1, #node do
    if i > 1 then buf.write(", ") end
    buf.write('"%s"', node[i].value)
  end
  buf.writeln(")")
end

-- Helper: Generate a table constructor call (LTABLE, TABLE share same pattern)
local function writeTableCall(buf, name, node, printNode)
  local first_is_storage_spec = utils.safeget(node[1], 'type') == "list"
  if first_is_storage_spec then
    local has_string, has_length = false, false
    for _, spec in ipairs(node[1]) do
      has_string = has_string or spec.value == "STRING"
      has_length = has_length or spec.value == "LENGTH"
    end
    if has_string and node[2] and node[2].type == "string" and #node == 2 then
      buf.write("STRING_TABLE(")
      printNode(buf, node[2], 0)
      buf.write(", %s)", has_length and "true" or "false")
      return
    end
  end
  local start = first_is_storage_spec and 2 or 1
  buf.write("%s(", name)
  for i = start, #node do
    local child = node[i]
    if child.type == "ident" or child.type == "symbol" then
      buf.write('GLOBAL_REF("%s")', utils.normalizeIdentifier(child.value))
    else
      printNode(buf, child, 0)
    end
    if i < #node then buf.write(",") end
  end
  buf.write(")")
end

-- Helper: Increment/decrement with comparison (IGRTR?, DLESS? share pattern)
local function writeModifyCompare(buf, node, op, cmp, compiler)
  local target = compiler.localVarName(node[1])
  buf.write("APPLY(function() %s = %s %s 1", target, target, op)
  buf.write(" return %s %s %s end)", target, cmp, compiler.value(node[2]))
end

local __again = 0xDEADBEEF

-- Helper: Generate pcall-wrapped prog block (PROG and REPEAT share structure)
local function writeProgBlock(buf, node, indent, is_repeat, compiler, printNode)
  local p = compiler.prog
  compiler.prog = compiler.prog + 1
  buf.writeln()
  buf.indent(indent)
  buf.writeln("local __prog%d = function()", p)
  for i = 2, #node do
    buf.indent(indent + 1)
    printNode(buf, node[i], indent + 1)
    if is_repeat then buf.writeln() end
  end
  if is_repeat then
    buf.writeln()
    buf.writeln("error(0x%X) end", __again)
  else
    buf.writeln("end")
  end
  buf.writeln("local __ok%d, __res%d", p, p)
  buf.writeln("repeat __ok%d, __res%d = pcall(__prog%d)", p, p, p)
  buf.writeln("until __ok%d or __res%d ~= 0x%X", p, p, __again)
  buf.writeln("if not __ok%d then error(__res%d)", p, p)
  buf.writeln("else __tmp = __res%d or true end", p, p)
end

-- SET/SETG implementation
local function compileSet(buf, node, indent, compiler, printNode)
  local target = compiler.localVarName(node[1])
  buf.write("APPLY(function() %s = ", target)
  for i = 2, #node do
    if utils.isCond(node[i]) then
      buf.write("APPLY(function()")
      printNode(buf, node[i], indent + 1)
      buf.write(" return __tmp end)")
    else
      printNode(buf, node[i], indent + 1)
    end
  end
  buf.write(" return %s end)", target)
end

-- AND/OR implementation
local function compileLogical(buf, node, indent, op, compiler, printNode)
  if indent == 1 then buf.indent(indent) end
  buf.write("PASS(")
  for i = 1, #node do
    local cond_node = utils.isCond(node[i]) and node[i]
      or (node[i].type == "placeholder" and utils.isCond(node[i][1]) and node[i][1])
    if cond_node then
      buf.write("APPLY(function() ")
      printNode(buf, cond_node, indent + 1)
      buf.write(" return __tmp end)")
    else
      printNode(buf, node[i], indent + 1)
    end
    if i < #node then buf.write(string.format(" %s ", string.lower(op))) end
  end
  buf.write(")")
end

-- Create form handlers table
function Forms.createHandlers(compiler, printNode)
  local form = {}

  local function writeMap(buf, node, indent, runtime_name, binder_count)
    local bindings = node[1]
    if not bindings or bindings.type ~= "list" or #bindings < binder_count + 1 then
      error(runtime_name .. " requires a binding list")
    end

    local saved_local_vars = {}
    for k, v in pairs(compiler.local_vars) do saved_local_vars[k] = v end
    local binders = {}
    for i = 1, binder_count do
      compiler.registerLocalVar(bindings[i])
      binders[i] = compiler.localVarName(bindings[i])
    end

    local end_clause
    local body_start = 2
    if node[2] and node[2].type == "list"
        and utils.safeget(node[2][1], "value") == "END" then
      end_clause = node[2]
      body_start = 3
    end

    buf.write("%s(", runtime_name)
    printNode(buf, bindings[#bindings], indent + 1)
    buf.write(", function(%s) local __tmp", table.concat(binders, ", "))
    for i = body_start, #node do
      buf.write("; ")
      if utils.needReturn(node[i]) then buf.write("__tmp = ") end
      printNode(buf, node[i], indent + 1)
    end
    buf.write("; return __tmp end, ")
    if end_clause then
      buf.write("function() local __tmp")
      for i = 2, #end_clause do
        buf.write("; ")
        if utils.needReturn(end_clause[i]) then buf.write("__tmp = ") end
        printNode(buf, end_clause[i], indent + 1)
      end
      buf.write("; return __tmp end")
    else
      buf.write("nil")
    end
    buf.write(")")
    compiler.local_vars = saved_local_vars
  end

  form["MAP-DIRECTIONS"] = function(buf, node, indent)
    writeMap(buf, node, indent, "MAP_DIRECTIONS", 2)
  end

  form["MAP-CONTENTS"] = function(buf, node, indent)
    local bindings = node[1]
    local binder_count = bindings and (#bindings - 1) or 1
    writeMap(buf, node, indent, "MAP_CONTENTS", binder_count)
  end

  form["RARG?"] = function(buf, node, indent)
    local target = compiler.local_vars.RARG and "m_RARG" or "RARG"
    buf.write("EQUALQ(%s", target)
    for i = 1, #node do
      buf.write(", ")
      local context = node[i].value
      if context == "OBJDESC?" then
        buf.write("M_OBJDESCQ")
      elseif context and ({BEG=true, CONTAINER=true, END=true, ENTER=true,
          LEAVE=true, LOOK=true, OBJDESC=true})[context] then
        buf.write("M_%s", context)
      else
        printNode(buf, node[i], indent + 1)
      end
    end
    buf.write(")")
  end

  -- P? is the compact Infocom predicate for matching the current verb,
  -- direct object, indirect object, and actor. Its macro normally adds the
  -- V? prefix to verb atoms; emitting a plain atom makes it nil at runtime,
  -- which turns the verb slot into a wildcard and matches every command.
  form["P?"] = function(buf, node, indent)
    local dimensions = {
      {predicate = "VERBQ", node = node[1], verb = true},
      {predicate = "PRSOQ", node = node[2]},
      {predicate = "PRSIQ", node = node[3]},
      {predicate = "WINNERQ", node = node[4]},
    }
    local wrote = false
    buf.write("PASS(")
    for _, dimension in ipairs(dimensions) do
      local argument = dimension.node
      if argument and argument.value ~= "*" then
        if wrote then buf.write(" and ") end
        wrote = true
        buf.write("%s(", dimension.predicate)
        local values = argument.type == "list" and argument or {argument}
        for i, value in ipairs(values) do
          if dimension.verb and value.type == "ident" then
            local verb = value.value == "THROUGH" and "ENTER" or value.value
            compiler.current_verbs[#compiler.current_verbs + 1] = verb
            buf.write("VQ%s", utils.normalizeIdentifier(verb))
          else
            printNode(buf, value, indent + 1)
          end
          if i < #values then buf.write(", ") end
        end
        buf.write(")")
      end
    end
    if not wrote then buf.write("true") end
    buf.write(")")
  end

  -- COND (if-elseif-else)
  form.COND = function(buf, node, indent)
    if node[1] and utils.safeget(node[1][1], 'value') == "ELSE" then
      for j = 2, #node[1] do
        if j > 2 then
          buf.writeln()
          buf.indent(indent)
        end
        if utils.needReturn(node[1][j]) then buf.write("__tmp = ") end
        printNode(buf, node[1][j], indent)
      end
      return
    end

    for i, clause in ipairs(node) do
      buf.writeln()
      buf.indent(indent)
      if utils.safeget(clause[1], 'value') == "ELSE" then
        -- A COND whose earlier clauses were commented out can begin with ELSE.
        -- In that case the clause is unconditional and needs no Lua keyword.
        if i > 1 then buf.write("else ") end
      else
        buf.write(i == 1 and "if " or "elseif ")
        buf.write("ZIL_TRUE(APPLY(function() __tmp = ")
        printNode(buf, clause[1], indent + 1)
        buf.write(" return __tmp end))")
        buf.write(" then ")
      end
      
      -- Then clauses
      for j = 2, #clause do
        buf.writeln()
        buf.indent(indent + 1)
        if utils.needReturn(clause[j]) then buf.write("\t__tmp = ") end
        printNode(buf, clause[j], indent + 1)
      end
    end
    buf.writeln()
    buf.indent(indent)
    buf.writeln("end")
  end

  -- SET/SETG
  form.SET = function(buf, node, indent)
    compileSet(buf, node, indent, compiler, printNode)
  end
  form.SETG = form.SET

  form.PROB = function(buf, node, indent)
    buf.write("ZPROB(")
    if node[1] then
      printNode(buf, node[1], indent + 1)
    else
      buf.write("0")
    end
    buf.write(")")
  end

  form.TELL = function(buf, node, indent)
    -- TELL-TOKENS gives these identifiers formatting semantics distinct from
    -- their ordinary globals (THE is also commonly an object flag).
    local tokens = {
      A = "TELL_A",
      AN = "TELL_A",
      THE = "TELL_THE",
      CTHE = "TELL_CTHE",
    }
    buf.write("TELL(")
    for i = 1, #node do
      local cond_node = utils.isCond(node[i]) and node[i]
        or (node[i].type == "placeholder" and utils.isCond(node[i][1]) and node[i][1])
      local token = node[i].type == "ident" and tokens[node[i].value]
      if token then
        buf.write(token)
      elseif node[i].type == "placeholder" and node[i][1] and not cond_node then
        buf.write("D, ")
        printNode(buf, node[i][1], indent + 1)
      elseif cond_node then
        buf.write("APPLY(function() ")
        printNode(buf, cond_node, indent + 1)
        buf.write(" return __tmp end)")
      else
        printNode(buf, node[i], indent + 1)
      end
      if i < #node then buf.write(", ") end
    end
    buf.write(")")
  end

  -- LET - Local variable bindings
  form.LET = function(buf, node, indent)
    -- LET has form: <LET ((VAR1 INIT1) (VAR2 INIT2) ...) body...>
    -- First element is the binding list
    local bindings = node[1]
    
    -- Save the current local_vars state to restore later
    local saved_local_vars = {}
    for k, v in pairs(compiler.local_vars) do
      saved_local_vars[k] = v
    end
    
    -- Emit do block start
    buf.writeln()
    buf.indent(indent)
    buf.writeln("do")
    
    -- Process bindings and emit local declarations
    if bindings and bindings.type == "list" then
      for _, binding in ipairs(bindings) do
        if binding.type == "list" then
          -- Validate binding has exactly 2 elements (variable and initializer)
          if #binding ~= 2 then
            error(string.format("LET binding must have exactly 2 elements (variable and initializer), got %d", #binding))
          end
          
          -- Register the variable name
          compiler.registerLocalVar(binding[1])
          
          -- Get the normalized Lua variable name
          local lua_var_name = compiler.localVarName(binding[1])
          
          -- Emit local variable declaration with initialization
          buf.indent(indent + 1)
          buf.write("local %s = ", lua_var_name)
          printNode(buf, binding[2], indent + 2)
          buf.writeln()
        end
      end
    end
    
    -- Process body expressions
    for i = 2, #node do
      buf.indent(indent + 1)
      if utils.needReturn(node[i]) then buf.write("__tmp = ") end
      printNode(buf, node[i], indent + 1)
      buf.writeln()
    end
    
    -- Emit do block end
    buf.indent(indent)
    buf.writeln("end")
    
    -- Restore the previous local_vars state
    compiler.local_vars = saved_local_vars
  end

  -- IGRTR?, DLESS?
  form["IGRTR?"] = function(buf, node, indent)
    writeModifyCompare(buf, node, "+", ">", compiler)
  end

  form["DLESS?"] = function(buf, node, indent)
    writeModifyCompare(buf, node, "-", "<", compiler)
  end

  -- RETURN
  form.RETURN = function(buf, node, indent)
    if node[1] then
      buf.write("ZIL_RETURN(")
      printNode(buf, node[1], indent + 1)
      buf.write(")")
    else
      buf.write("return true")
    end
  end

  -- RTRUE, RFALSE, RFATAL
  form.RTRUE = function(buf, node, indent)
    writeErrorReturn(buf, "true")
  end

  form.RFALSE = function(buf, node, indent)
    writeErrorReturn(buf, "false")
  end

  form.RFATAL = function(buf, node, indent)
    writeErrorReturn(buf, "2")
  end

  -- PROG (do block)
  form.PROG = function(buf, node, indent)
    writeProgBlock(buf, node, indent, false, compiler, printNode)
  end

  -- REPEAT (while true loop)
  form.REPEAT = function(buf, node, indent)
    writeProgBlock(buf, node, indent, true, compiler, printNode)
  end

  form.AGAIN = function(buf, node, indent)
    buf.write("\terror(0x%X)", __again)
  end

  -- Inclusive numeric loop: <DO (VAR START END [STEP]) body...>
  form.DO = function(buf, node, indent)
    local spec = node[1]
    if not spec or spec.type ~= "list" or not spec[1] then
      buf.write("true")
      return
    end
    local saved_local_vars = {}
    for k, v in pairs(compiler.local_vars) do saved_local_vars[k] = v end
    compiler.registerLocalVar(spec[1])
    local var = compiler.localVarName(spec[1])
    buf.write("APPLY(function() for %s = ", var)
    printNode(buf, spec[2], indent + 1)
    buf.write(", ")
    printNode(buf, spec[3], indent + 1)
    if spec[4] then
      buf.write(", ")
      printNode(buf, spec[4], indent + 1)
    end
    buf.write(" do ")
    -- Ordinary body forms run first. Parenthesized forms are DO iteration
    -- clauses and run after the body on each pass.
    for i = 2, #node do
      if node[i].type ~= "list" and not (node[i].type == "expr" and (node[i].name or "") == "") then
        printNode(buf, node[i], indent + 1)
        buf.write("; ")
      end
    end
    for i = 2, #node do
      if node[i].type == "list" then
        for _, child in ipairs(node[i]) do
          printNode(buf, child, indent + 1)
          buf.write("; ")
        end
      end
    end
    buf.write("end return true end)")
    compiler.local_vars = saved_local_vars
  end

  -- BUZZ and SYNONYM
  form.BUZZ = function(buf, node, indent)
    writeStringCall(buf, "BUZZ", node)
  end

  form.SYNONYM = function(buf, node, indent)
    writeStringCall(buf, "SYNONYM", node)
  end

  -- Infocom vocabulary sources distinguish verb/preposition aliases from the
  -- generic SYNONYM directive.  They share the same dictionary representation
  -- at runtime, so preserve the source spelling while lowering both forms to
  -- the existing synonym implementation.
  form["VERB-SYNONYM"] = function(buf, node, indent)
    writeStringCall(buf, "DEFER_SYNONYM", node)
  end

  form["PREP-SYNONYM"] = function(buf, node, indent)
    writeStringCall(buf, "DEFER_SYNONYM", node)
  end

  -- GLOBAL and CONSTANT
  form.GLOBAL = function(buf, node, indent)
    local name = compiler.value(node[1])
    buf.write("%s = ", name)
    printNode(buf, node[2], 0)
    buf.writeln()
  end

  form.CONSTANT = function(buf, node, indent)
    buf.write("%s = ", compiler.value(node[1]))
    for i = 2, #node do
      printNode(buf, node[i], 0)
      buf.writeln()
    end
  end

  -- SYNTAX
  form.SYNTAX = function(buf, node, indent)
    compiler.current_decl.writeln('_G["NUM_%s"] = (_G["NUM_%s"] or 0) + 1', node[1].value, node[1].value)

    buf.writeln("SYNTAX {")
    buf.writeln('\tVERB = "%s\",', node[1].value)
    
    local i = 2
    while utils.safeget(node[i], 'value') ~= "OBJECT" and node[i].value ~= "=" do
      buf.writeln("\tPREFIX = \"%s\",", node[i].value)
      i = i + 1
    end
    
    if utils.safeget(node[i], 'value') == "OBJECT" then
      i = compiler.printSyntaxObject(buf, node, i, "OBJECT")
    end
    
    if utils.safeget(node[i], 'value') ~= "OBJECT" and node[i].value ~= "=" then
      buf.writeln('\tJOIN = "%s",', node[i].value)
      i = i + 1
    end
    
    if utils.safeget(node[i], 'value') == "OBJECT" then
      i = compiler.printSyntaxObject(buf, node, i, "SUBJECT")
    end
    
    -- Skip modifier keywords (like TEXT) between JOIN/OBJECT and =
    while utils.safeget(node[i], 'value') ~= "OBJECT" and node[i].value ~= "=" and utils.safeget(node[i], 'value') do
      i = i + 1
    end
    
    if utils.safeget(node[i], 'value') == "=" then
      buf.writeln("\tACTION = \"%s\",", compiler.value(node[i + 1]))

      if utils.safeget(node[i+2], 'value') then
        buf.writeln("\tPREACTION = \"%s\",", compiler.value(node[i+2]))
      end

    end

    buf.writeln("}")
  end

  -- LTABLE, TABLE, ITABLE
  form.LTABLE = function(buf, node)
    writeTableCall(buf, "LTABLE", node, printNode)
  end

  form.TABLE = function(buf, node)
    writeTableCall(buf, "TABLE", node, printNode)
  end

  form.PTABLE = function(buf, node)
    writeTableCall(buf, "TABLE", node, printNode)
  end

  form.PLTABLE = function(buf, node)
    writeTableCall(buf, "LTABLE", node, printNode)
  end

  form.ITABLE = function(buf, node)
    if node[1] and node[1].type == "number"
        and not (node[2] and node[2].type == "list") then
      buf.write("ITABLE_WORDS(%s, %d)", compiler.value(node[1]), math.max(1, #node - 1))
    elseif (utils.safeget(node[1], "value") == "NONE"
            or utils.safeget(node[1], "value") == "BYTE"
            or utils.safeget(node[1], "value") == "WORD") and node[2] then
      buf.write("ITABLE_WORDS(")
      printNode(buf, node[2], 0)
      buf.write(", 1)")
    else
      -- Preserve the established byte/LEXV buffer layout for flagged tables.
      buf.write("ITABLE(")
      printNode(buf, node[1], 0)
      buf.write(")")
    end
  end

  -- AND/OR
  form.AND = function(buf, node, indent)
    compileLogical(buf, node, indent, "AND", compiler, printNode)
  end

  form.OR = function(buf, node, indent)
    compileLogical(buf, node, indent, "OR", compiler, printNode)
  end

  -- FORM - Construct a form (used in macros)
  form.FORM = function(buf, node, indent)
    -- FORM creates an expression form at compile time
    -- Convert it to the actual form it represents
    if node[1] then
      -- Create a new expression node with the FORM's contents
      local form_name = compiler.value(node[1])
      buf.write("%s(", utils.normalizeFunctionName(form_name))
      local first = true
      for i = 2, #node do
        if node[i].type == "list" then
          -- Splice list elements as individual arguments
          for j = 1, #node[i] do
            if not first then buf.write(", ") end
            printNode(buf, node[i][j], indent)
            first = false
          end
        else
          if not first then buf.write(", ") end
          printNode(buf, node[i], indent)
          first = false
        end
      end
      buf.write(")")
    else
      buf.write("nil")
    end
  end

  -- INSERT-FILE - Include and execute another ZIL file
  form["INSERT-FILE"] = function(buf, node, indent)
    -- Generate INSERT_FILE call with the filename
    if node[1] and node[1].type == "string" then
      local meta = getmetatable(node)
      local source = meta and meta.source and meta.source.filename or ""
      buf.write('INSERT_FILE("%s", "%s")', node[1].value, source:gsub("\\", "\\\\"):gsub('"', '\\"'))
    else
      buf.write('INSERT_FILE("", "")')
    end
  end

  return form
end

return Forms
