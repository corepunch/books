local M = {}

local esc = "\27["

local function escape_pattern(text)
  return (text:gsub("([^%w])", "%%%1"))
end

function M.bold(text)
  return esc .. "1m" .. text .. esc .. "0m"
end

function M.bold_words(text, words)
  if type(words) ~= "table" then
    return text
  end

  for _, word in ipairs(words) do
    local pattern = escape_pattern(word)
    local capitalized = word:sub(1, 1):upper() .. word:sub(2)
    local capitalized_pattern = escape_pattern(capitalized)

    text = text:gsub("(%f[%a]" .. pattern .. "%f[%A])", M.bold)
    text = text:gsub(
      "(%f[%a]" .. capitalized_pattern .. "%f[%A])",
      M.bold
    )
  end

  return text
end

local Terminal = {}
Terminal.__index = Terminal

function Terminal:write(text)
  self.stdout:write(text)
end

function Terminal:flush()
  self.stdout:flush()
end

function Terminal:enter_raw()
  self.execute("stty -icanon -echo min 0 time 1 2>/dev/null")
end

function Terminal:leave_raw()
  self.execute("stty icanon echo 2>/dev/null")
end

function Terminal:width()
  local handle = self.popen("tput cols 2>/dev/null || echo 80")
  local width = handle and handle:read("*n") or 80
  if handle then
    handle:close()
  end
  return width or 80
end

function Terminal:read_key()
  local char = self.stdin:read(1)
  if not char then
    return nil
  end

  if char == "\27" then
    local prefix = self.stdin:read(1)
    if prefix == "[" then
      local code = self.stdin:read(1)
      if code == "A" then
        return {kind = "up"}
      elseif code == "B" then
        return {kind = "down"}
      end
    end
    return {kind = "escape"}
  elseif char == "\r" or char == "\n" then
    return {kind = "enter"}
  elseif char == "\127" or char == "\8" then
    return {kind = "backspace"}
  elseif char == "\3" then
    return {kind = "interrupt"}
  elseif char:match("^[%w%p%s]$") then
    return {kind = "text", text = char}
  end

  return {kind = "unknown"}
end

function M.new(dependencies)
  dependencies = dependencies or {}
  return setmetatable({
    stdin = dependencies.stdin or io.stdin,
    stdout = dependencies.stdout or io.stdout,
    execute = dependencies.execute or os.execute,
    popen = dependencies.popen or io.popen,
  }, Terminal)
end

M.default = M.new()

return M
