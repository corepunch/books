-- Evaluation for conditional compilation
local compile_time_globals = {}

local function normalized_global(name)
	name = tostring(name or ""):gsub("^[,.]", "")
	return rawget(_G, name)
		or rawget(_G, name:gsub("%-", "_"):gsub("%?", "Q"))
end

local function scalar(node)
	if not node then return nil end
	if node.type == "number" or node.type == "string" then return node.value end
	if node.type == "symbol" or node.type == "ident" then
		if node.value == "T" then return true end
		return normalized_global(node.value)
	end
	if node.type ~= "expr" then return nil end

	local values = {}
	for i, child in ipairs(node) do values[i] = scalar(child) end
	if node.name == "+" then
		local result = 0
		for _, value in ipairs(values) do if type(value) ~= "number" then return nil end result = result + value end
		return result
	elseif node.name == "-" then
		if type(values[1]) ~= "number" then return nil end
		local result = values[1]
		for i = 2, #values do if type(values[i]) ~= "number" then return nil end result = result - values[i] end
		return result
	elseif node.name == "*" then
		local result = 1
		for _, value in ipairs(values) do if type(value) ~= "number" then return nil end result = result * value end
		return result
	elseif node.name == "/" then
		if type(values[1]) ~= "number" then return nil end
		local result = values[1]
		for i = 2, #values do if type(values[i]) ~= "number" then return nil end result = result // values[i] end
		return result
	elseif node.name == "ASCII" then
		if type(values[1]) == "number" then return string.char(values[1]) end
		return values[1]
	elseif node.name == "STRING" then
		local parts = {}
		for i, value in ipairs(values) do
			if value == nil then return nil end
			if type(value) == "number" then value = string.char(value) end
			parts[i] = tostring(value)
		end
		return table.concat(parts)
	end
	return nil
end

local function get_zork_number()
	if compile_time_globals.ZORK_NUMBER then
		return compile_time_globals.ZORK_NUMBER
	end
	local ok, val = pcall(function() return _G.ZORK_NUMBER end)
	if ok and type(val) == "number" then
		return val
	end
	return 1
end

local function get_number(node)
	if not node or node.type ~= "number" then
		if node and node.type == "symbol" and node.value == ",ZORK-NUMBER" then
			return get_zork_number()
		end
		return nil
	end
	return node.value
end

local function evaluate_cond(node, value_node)
	if node.type == "expr" then
		if node.name == "==?" and #node == 2 then
			local a, b = get_number(node[1]), get_number(node[2])
			if a and b and a == b then
				return value_node
			end
		elseif node.name == "OR" then
			for _, child in ipairs(node) do
				if child[1] and evaluate_cond(child[1], value_node) then
					return value_node
				end
			end
		elseif node.name == "GASSIGNED?" then
			return value_node
		end
	elseif node.type == "ident" then
		-- Check if identifier is a global variable and evaluate its truthiness
		local name = node.value
		if name then
			if name == "ELSE" or name == "T" then return value_node end
			-- Strip leading comma (,VAR)
			name = name:gsub("^,", "")
			local ok, val = pcall(function() return rawget(_G, name) end)
			if ok and val then
				return value_node
			end
			-- Also check if it's a boolean true or non-nil constant
			return nil
		end
		return value_node
	elseif node.type == "symbol" then
		-- ,SYMBOL references a global variable
		local name = node.value
		if name then
			name = name:gsub("^,", "")
			local ok, val = pcall(function() return rawget(_G, name) end)
			if ok and val then
				return value_node
			end
		end
		return nil
	end
	return nil
end

local function evaluate(cond)
	if not cond then
		return nil
	end

	local constant = scalar(cond)
	if constant ~= nil and cond.type == "expr" then
		if type(constant) == "number" then return {type = "number", value = constant} end
		if type(constant) == "string" then return {type = "string", value = constant} end
	end

	-- Handle numeric-name expressions (from #BYTE, #WORD, or plain <N> with no children)
	-- These represent numeric constants at the form level
	if cond.type == "expr" and type(cond.name) == "number" and #cond == 0 then
		return {type = "number", value = cond.name}
	end

	-- Handle %<DEBUG-CODE debug-form non-debug-form>
	-- DEBUG-CODE is a compile-time macro: if ZDEBUGGING? then debug-form else non-debug-form
	if cond.type == "expr" and cond.name == "DEBUG-CODE" then
		local ok, zdebugging = pcall(function() return _G.ZDEBUGGING end)
		if ok and zdebugging then
			return cond[1]
		else
			-- Non-debug mode: return second argument if present, else return nil to discard
			return cond[2]
		end
	end

	-- Handle bare %<GASSIGNED? VAR> - check if global is assigned at compile time
	if cond.type == "expr" and cond.name == "GASSIGNED?" and #cond >= 1 then
		local var_name = cond[1].value or cond[1].name
		if var_name then
			-- Check if the global exists and is non-nil
			local ok, val = pcall(function() return rawget(_G, var_name) end)
			if ok and val ~= nil then
				-- Global is assigned - GASSIGNED? returns true
				-- Return the form itself as a truthy marker
				return {type = "ident", value = "TRUE"}
			else
				-- Global not assigned
				return nil
			end
		end
		return nil
	end

	if cond.name ~= "COND" then
		return nil
	end
	for _, clause in ipairs(cond) do
		if clause.type == "list" and #clause > 0 then
			local result = evaluate_cond(clause[1], clause[2])
			if result then
				if result.type == "placeholder" and result[1] then
					return result[1]
				else
					return nil
				end
			end
		end
	end
	return nil
end

return evaluate
