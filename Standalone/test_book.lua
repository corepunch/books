-- Run from any directory: lua /path/to/Book/Standalone/test_book.lua /path/to/Book
local root = assert(arg[1], "pass the absolute Book directory")
assert(root:sub(1, 1) == "/", "Book directory must be absolute")
local book = dofile(root .. "/Standalone/book.lua")
local view = book.init(root)

local function check_scene()
    assert(type(view.vertices) == "string" and #view.vertices > 0 and #view.vertices % 108 == 0)
    assert(type(view.matrix) == "table" and #view.matrix == 16)
    for _, n in ipairs(view.matrix) do assert(n == n and math.abs(n) < math.huge) end
end

local function select(label)
    for _, button in ipairs(view.buttons) do
        if button.label:lower():find(label:lower(), 1, true) then
            view = book.action(button.action)
            check_scene()
            return
        end
    end
    error("missing choice: " .. label)
end

local function update(method, ...)
    view = book[method](...)
    check_scene()
end

assert(view.kind == "room" and view.title == "Workshop Floor")
assert(#view.hotspots > 0, "workshop subjects should project onto the image")
check_scene()
for _, hotspot in ipairs(view.hotspots) do
    assert(hotspot.x >= 0 and hotspot.x <= 1 and hotspot.y >= 0 and hotspot.y <= 1)
    assert(view.buttons[hotspot.action].label == hotspot.label)
end

select("enormous bench")
assert(view.kind == "focus")
select("climb the workbench")
assert(view.kind == "beat")
update("continue")
assert(view.kind == "room" and view.title == "Workbench Top")
select("book")
assert(view.kind == "focus")
select("heave the cover")
assert(view.kind == "beat")
update("continue")
assert(view.kind == "focus")
select("read Tolliver")
assert(#view.text > 0)
update("back")
assert(view.kind == "room")

-- Story rules must still prevent leaving the open paper workshop behind.
update("command", "down")
assert(view.kind == "beat" and view.text:find("must be closed", 1, true))
update("continue")
assert(view.title == "Workbench Top")
update("command", "close book")
update("continue")
update("command", "down")
assert(view.kind == "beat")
update("continue")
assert(view.kind == "room" and view.title == "Workshop Floor")

update("reload")
assert(view.kind == "room" and view.title == "Workshop Floor")

for name in pairs(package.loaded) do
    assert(not name:match("^orca[%.]?"), "loaded Orca module: " .. name)
end
assert(not package.loaded["Book.Scripts.WorkshopCamera"], "loaded generated camera metadata")
print("Book standalone story: passed")
