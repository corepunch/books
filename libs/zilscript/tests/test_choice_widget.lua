local framework = require "tests.test_framework"
local choice_widget = require "zilscript.choice_widget"
local terminal = require "zilscript.terminal"

local function fake_terminal(keys)
  local fake = {
    keys = keys,
    key_index = 0,
    output = {},
    entered_raw = 0,
    left_raw = 0,
  }

  function fake:write(text)
    self.output[#self.output + 1] = text
  end

  function fake:flush()
  end

  function fake:enter_raw()
    self.entered_raw = self.entered_raw + 1
  end

  function fake:leave_raw()
    self.left_raw = self.left_raw + 1
  end

  function fake:width()
    return 80
  end

  function fake:read_key()
    self.key_index = self.key_index + 1
    return self.keys[self.key_index]
  end

  return fake
end

local items = {
  {label = "First", command = "first"},
  {label = "Second", command = "second"},
}

local function config()
  return {
    items = items,
    render_item = function(item)
      return item.label .. " (" .. item.command .. ")"
    end,
    item_value = function(item)
      return item.command
    end,
  }
end

framework.describe("Data-driven choice widget", function(suite)
  suite.it("wraps down directly from the last item to the first", function(t)
    local fake = fake_terminal({
      {kind = "down"},
      {kind = "down"},
      {kind = "down"},
      {kind = "enter"},
    })

    local result = choice_widget.run(config(), fake)

    t.assert_equal(result.kind, "item")
    t.assert_equal(result.item, items[1])
    t.assert_equal(result.index, 1)
    t.assert_equal(fake.entered_raw, 1)
    t.assert_equal(fake.left_raw, 1)
  end)

  suite.it("wraps up from no selection to the last item", function(t)
    local fake = fake_terminal({
      {kind = "up"},
      {kind = "enter"},
    })

    local result = choice_widget.run(config(), fake)

    t.assert_equal(result.item, items[2])
    t.assert_equal(result.index, 2)
  end)

  suite.it("accepts free text when enabled", function(t)
    local fake = fake_terminal({
      {kind = "text", text = "l"},
      {kind = "text", text = "o"},
      {kind = "text", text = "o"},
      {kind = "text", text = "k"},
      {kind = "enter"},
    })

    local result = choice_widget.run(config(), fake)

    t.assert_equal(result.kind, "text")
    t.assert_equal(result.text, "look")
  end)

  suite.it("redraws from column zero and leaves a spacer before the prompt", function(t)
    local fake = fake_terminal({
      {kind = "down"},
      {kind = "enter"},
    })

    choice_widget.run(config(), fake)
    local output = table.concat(fake.output)

    t.assert_true(output:find("\n\n\27[2K> ", 1, true) ~= nil)
    t.assert_true(output:find("\27[A\r\27[2K", 1, true) ~= nil)
  end)

  suite.it("restores the terminal if rendering fails", function(t)
    local fake = fake_terminal({})
    local broken = config()
    broken.render_item = function()
      error("render failed")
    end

    local ok = pcall(choice_widget.run, broken, fake)

    t.assert_false(ok)
    t.assert_equal(fake.entered_raw, 1)
    t.assert_equal(fake.left_raw, 1)
  end)
end)

framework.describe("Terminal text styles", function(suite)
  suite.it("bolds configured words without adding a color", function(t)
    local styled = terminal.bold_words("Go east toward East.", {"east"})

    t.assert_equal(
      styled,
      "Go \27[1meast\27[0m toward \27[1mEast\27[0m."
    )
    t.assert_false(styled:find("32m", 1, true) ~= nil)
    t.assert_false(styled:find("36m", 1, true) ~= nil)
  end)
end)

os.exit(framework.summary() and 0 or 1)
