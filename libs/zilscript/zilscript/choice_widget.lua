local terminal_module = require "zilscript.terminal"

local M = {}

local cursor_up_and_clear = "\27[A\r\27[2K"

local function default_render(item)
  return tostring(item)
end

local function default_value(item)
  return tostring(item)
end

local function run_loop(config, terminal)
  local items = assert(config.items, "choice widget requires items")
  assert(#items > 0, "choice widget requires at least one item")

  local render_item = config.render_item or default_render
  local item_value = config.item_value or default_value
  local selected_marker = config.selected_marker or "> "
  local unselected_marker = config.unselected_marker or "  "
  local prompt = config.prompt or "> "
  local spacer_rows = config.spacer_rows == nil and 1 or config.spacer_rows
  local allow_text = config.allow_text ~= false

  local selected = config.selected_index or 0
  local typed = config.initial_text or ""
  local dirty = true
  local width = terminal:width()
  local rendered_rows = 0

  local function draw()
    if not dirty then
      return
    end
    dirty = false

    if rendered_rows > 0 then
      terminal:write(string.rep(cursor_up_and_clear, rendered_rows))
    end

    local rows = 0
    for index, item in ipairs(items) do
      local marker = index == selected and selected_marker or unselected_marker
      local line = marker .. render_item(item, index)
      terminal:write(line .. "\n")
      rows = rows + math.ceil(#line / width)
    end

    terminal:write(string.rep("\n", spacer_rows))
    terminal:write("\27[2K" .. prompt)
    terminal:write(selected > 0 and item_value(items[selected], selected) or typed)
    rendered_rows = rows + spacer_rows
    terminal:flush()
  end

  draw()

  while true do
    local key = terminal:read_key()
    if key then
      if key.kind == "up" then
        selected = selected > 1 and selected - 1 or #items
        typed = ""
        dirty = true
      elseif key.kind == "down" then
        selected = selected < #items and selected + 1 or 1
        typed = ""
        dirty = true
      elseif key.kind == "escape" then
        selected = 0
        typed = ""
        dirty = true
      elseif key.kind == "enter" then
        if selected > 0 then
          return {
            kind = "item",
            item = items[selected],
            index = selected,
          }
        elseif #typed > 0 then
          return {kind = "text", text = typed}
        end
      elseif key.kind == "backspace" then
        if #typed > 0 then
          typed = typed:sub(1, -2)
          selected = 0
          dirty = true
        end
      elseif key.kind == "interrupt" then
        return {kind = "interrupt"}
      elseif key.kind == "text" and allow_text then
        typed = typed .. key.text
        selected = 0
        dirty = true
      end

      draw()
    end
  end
end

function M.run(config, terminal)
  terminal = terminal or terminal_module.default
  terminal:enter_raw()

  local ok, result = xpcall(function()
    return run_loop(config, terminal)
  end, debug.traceback)

  terminal:leave_raw()

  if not ok then
    error(result, 0)
  end

  terminal:write(result.kind == "interrupt" and "\n" or "\n\n")
  terminal:flush()
  return result
end

return M
