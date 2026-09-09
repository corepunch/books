#!/usr/bin/env lua
-- check-vocab.lua: Validate objective parser-vocabulary invariants.
--
-- Usage:
--   lua scripts/check-vocab.lua <file.zil> [file2.zil ...]
--   lua scripts/check-vocab.lua books/limehouse-killings/dungeon.zil
--
-- What it checks:
--   CRITICAL: Player-addressable objects have a DESC.
--   CRITICAL: At least one noun from DESC appears in SYNONYM.
--   CRITICAL: NDESCBIT does not silently suppress FDESC.
--   CRITICAL: Static FDESC does not shadow a dynamic DESCFCN.
--
-- Determining whether every prose word in FDESC/LDESC is an interactive noun
-- requires language and world-model context. This script deliberately does not
-- guess: the previous heuristic treated verbs, adverbs, and compounds as nouns
-- and made the repository's own lint target unusable.

-- ============================================================
-- Parse ZIL OBJECT definitions
-- ============================================================
local function parse_zil_objects(content)
    local objects = {}
    local pos = 1
    local len = #content
    local safety = 0

    while pos <= len do
        safety = safety + 1
        if safety > 10000 then break end

        local obj_start = content:find("<OBJECT%s+(%S+)", pos)
        if not obj_start then break end

        local obj_name = content:match("<OBJECT%s+(%S+)", obj_start)
        if not obj_name then
            pos = obj_start + 8
        else
            local depth = 1
            local search_from = obj_start
            local obj_end = nil

            while search_from <= len do
                local next_open = content:find("<", search_from + 1)
                local next_close = content:find(">", search_from + 1)
                if not next_close then break end
                if next_open and next_open < next_close then
                    depth = depth + 1
                    search_from = next_open
                else
                    depth = depth - 1
                    search_from = next_close
                    if depth == 0 then
                        obj_end = next_close
                        break
                    end
                end
            end

            if not obj_end then
                pos = obj_start + 8
            else
                local obj_block = content:sub(obj_start, obj_end)

                local function extract_property(prop_name)
                    local pattern1 = "%(" .. prop_name .. '%s+"([^"]*)"'
                    local val = obj_block:match(pattern1)
                    if val then return val end
                    local pattern2 = "%(" .. prop_name .. "%s+([^)]+)%)"
                    local words_str = obj_block:match(pattern2)
                    if words_str then
                        local words = {}
                        for w in words_str:gmatch("(%S+)") do
                            table.insert(words, w:lower())
                        end
                        return words
                    end
                    return nil
                end

                local synonyms = extract_property("SYNONYM") or {}
                local desc = extract_property("DESC")
                local fdesc = extract_property("FDESC")
                local descfcn = extract_property("DESCFCN")
                local flags = extract_property("FLAGS") or {}

                local syn_set = {}
                if type(synonyms) == "table" then
                    for _, w in ipairs(synonyms) do syn_set[w] = true end
                end

                table.insert(objects, {
                    name = obj_name,
                    synonyms = syn_set,
                    has_synonyms = next(syn_set) ~= nil,
                    desc = desc,
                    fdesc = fdesc,
                    descfcn = descfcn,
                    flags = flags,
                })

                pos = obj_end + 1
            end
        end
    end

    return objects
end

-- ============================================================
-- Tokenize description text
-- ============================================================
local function tokenize_desc(text)
    if not text then return {} end
    local words = {}
    local cleaned = text:gsub("<[^>]+>", " ")
    cleaned = cleaned:gsub("[<>]", " ")
    cleaned = cleaned:gsub('"', " ")
    cleaned = cleaned:gsub("%-%-", " ")
    cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
    for w in cleaned:gmatch("%S+") do
        local clean = w:match("^[%p]*(.-)[%p]*$")
        if clean and #clean > 0 then
            table.insert(words, clean:lower())
        end
    end
    return words
end

-- ============================================================
-- Check a single object
-- ============================================================
local function check_object(obj)
    local issues = {}

    -- An object with vocabulary is player-addressable. Without DESC, generic
    -- responses print nil or an unrelated inherited default name.
    if obj.has_synonyms and not obj.desc then
        table.insert(issues, {
            level = "CRITICAL",
            field = "DESC",
            msg = "player-addressable object has SYNONYM but no DESC",
        })
    end

    -- DESC is the name printed by the engine. At least one of its words must be
    -- an accepted noun. We intentionally do not assume the final word is the
    -- head noun because descriptions such as "door to the garden" are common.
    if obj.desc then
        local desc_words = tokenize_desc(obj.desc)
        local matched_noun = false
        for _, word in ipairs(desc_words) do
            if obj.synonyms[word] then
                matched_noun = true
                break
            end
        end
        if #desc_words > 0 and not matched_noun then
            table.insert(issues, {
                level = "CRITICAL",
                field = "DESC",
                msg = "no DESC word appears in SYNONYM — parser won't match the printed name",
            })
        end
    end

    local has_ndescbit = false
    if type(obj.flags) == "table" then
        for _, flag in ipairs(obj.flags) do
            if flag == "ndescbit" then
                has_ndescbit = true
                break
            end
        end
    end

    if obj.fdesc and has_ndescbit then
        table.insert(issues, {
            level = "CRITICAL",
            field = "FDESC",
            msg = "FDESC is suppressed by NDESCBIT and will not print automatically",
        })
    end

    if obj.fdesc and obj.descfcn then
        table.insert(issues, {
            level = "CRITICAL",
            field = "DESCFCN",
            msg = "untouched FDESC shadows the dynamic DESCFCN on this substrate",
        })
    end

    return issues
end

-- ============================================================
-- Main
-- ============================================================
local function main()
    local files = {}
    for i = 1, #arg do
        table.insert(files, arg[i])
    end

    if #files == 0 then
        io.write("Usage: lua scripts/check-vocab.lua <file.zil> [file2.zil ...]\n")
        io.write("\nValidates that player-addressable objects have DESC and that\n")
        io.write("each DESC contains a noun registered as a SYNONYM.\n")
        os.exit(1)
    end

    local total_critical = 0

    for _, filepath in ipairs(files) do
        local f = io.open(filepath, "r")
        if not f then
            io.write("Error: cannot open " .. filepath .. "\n")
            os.exit(1)
        end
        local content = f:read("*a")
        f:close()

        local objects = parse_zil_objects(content)
        local file_issues = {}

        for _, obj in ipairs(objects) do
            local issues = check_object(obj)
            if #issues > 0 then
                file_issues[obj.name] = issues
            end
        end

        if next(file_issues) then
            io.write(filepath .. ":\n")
            for obj_name, issues in pairs(file_issues) do
                for _, issue in ipairs(issues) do
                    io.write(string.format("  [%s] %s: %s\n", issue.level, obj_name, issue.msg))
                    if issue.level == "CRITICAL" then
                        total_critical = total_critical + 1
                    end
                end
            end
            io.write("\n")
        end
    end

    io.write(string.format("%d critical across %d file(s)\n",
        total_critical, #files))

    if total_critical > 0 then
        os.exit(1)
    end
end

main()
