-- Run from any directory: lua /path/to/Book/Standalone/test_book.lua /path/to/Book
local root = assert(arg[1], "pass the absolute Book directory")
assert(root:sub(1, 1) == "/", "Book directory must be absolute")
local book = dofile(root .. "/Standalone/book.lua")
local view = book.init(root)

local function check_scene()
    assert(view.vertices == nil and view.matrix == nil and view.lighting == nil,
        "Book must only display pre-rendered art")
    assert(view.image:find(root .. "/Rooms/render/workshop-new/", 1, true) == 1)
    local file = assert(io.open(view.image, "rb"), "missing pre-rendered image: " .. view.image)
    assert(file:read(2) == "\255\216", "background must be a JPEG")
    file:close()
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
assert(view.image == root .. "/Rooms/render/workshop-new/workshop-floor.jpg")
for _, hotspot in ipairs(view.hotspots) do
    assert(hotspot.x >= 0 and hotspot.x <= 1 and hotspot.y >= 0 and hotspot.y <= 1)
    assert(view.buttons[hotspot.action].label == hotspot.label)
end

select("enormous bench")
assert(view.kind == "focus")
assert(view.image == root .. "/Rooms/render/workshop-new/workbench.jpg")
select("climb the workbench")
assert(view.kind == "beat")
update("continue")
assert(view.kind == "room" and view.title == "Workbench Top")
assert(view.image == root .. "/Rooms/render/workshop-new/workbench-top.jpg")
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
