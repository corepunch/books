-- Plain Lua presentation adapter with paths rooted in the Book project.
-- Hotspot coordinates are normalized in the source image before display scaling.
local Book = {}
local session, scene, scene_spec, projection, book_root
local actions = {}

local function title(name)
    return (name or "Wondertown"):lower():gsub("-", " "):gsub("%f[%a]%l", string.upper)
end

local function add_button(view, label, handler)
    local index = #actions + 1
    actions[index] = handler
    view.buttons[#view.buttons + 1] = {label = label, action = index}
    return index
end

function Book.init(root)
    book_root = assert(root, "Book root required"):gsub("/$", "")
    local library = book_root .. "/libs/zilscript/"
    package.path = library .. "?.lua;" .. library .. "?/init.lua;" .. package.path
    package.zilpath = book_root .. "/Scripts/?.zil;" .. library .. "?.zil;" .. (package.zilpath or "")
    -- Retain the existing module identities without requiring a parent Book folder.
    for _, name in ipairs({"WorkshopInteractions", "SceneProjection", "WondertownScenes", "WorkshopSession"}) do
        package.preload["Book.Scripts." .. name] = assert(loadfile(book_root .. "/Scripts/" .. name .. ".lua"))
    end
    scene_spec = require "Book.Scripts.WorkshopInteractions"
    projection = require "Book.Scripts.SceneProjection"
    local source = scene_spec.scene_path:gsub("^Book/", "")
    scene = assert(projection.load(book_root .. "/" .. source))
    local directory, scene_name = source:match("^(.*)/([^/]+)%.blks$")
    session = require("Book.Scripts.WorkshopSession").new {
        bootstrap_path = library .. "zilscript/bootstrap.lua",
        story_module = "WondertownPrototype",
        render_dir = book_root .. "/" .. directory .. "/render/" .. scene_name .. "/",
    }
    return Book.view()
end

function Book.view()
    assert(session, "Book.init must be called first")
    local state = session:view()
    local image = assert(io.open(state.image, "rb"),
        "Missing Scener render: " .. state.image .. ". Run `make render ROOM=workshop-new` from Book.")
    image:close()
    local view = {
        kind = state.kind, title = title(session:room()), text = state.text or "",
        image = state.image, camera = state.camera,
        source_width = scene_spec.source_width, source_height = scene_spec.source_height,
        buttons = {}, hotspots = {},
    }
    actions = {}
    if state.kind == "beat" then
        add_button(view, "Continue", function() session:continue() end)
    elseif state.kind == "focus" then
        view.title = title(state.subject)
        for index, choice in ipairs(state.choices) do
            add_button(view, choice.label, function() session:choose(index) end)
        end
        add_button(view, state.exit, function() session:leave_focus() end)
    else
        local camera = scene.cameras[state.camera]
        for _, subject in ipairs(state.subjects) do
            local prefix = subject.kind == "take" and "Take the "
                or subject.kind == "focus" and "Look closer at the " or "Examine the "
            local label = prefix .. subject.label
            local index = add_button(view, label, function() session:tap(subject.name) end)
            local point = projection.anchor(scene, subject.node)
            local width, height = view.source_width, view.source_height
            local screen = projection.project(camera, point, width, height, width, height,
                camera and camera.near)
            if screen and screen.depth <= (camera.far or math.huge) then
                view.hotspots[#view.hotspots + 1] = {
                    x = screen.x / width, y = screen.y / height, label = label, action = index,
                }
            end
        end
        for _, destination in ipairs(state.exits) do
            add_button(view, destination.label, function() session:exit(destination.command) end)
        end
    end
    return view
end

function Book.reload()
    local source = scene_spec.scene_path:gsub("^Book/", "")
    scene = assert(projection.load(book_root .. "/" .. source))
    return Book.view()
end

function Book.action(index)
    local handler = actions[index]
    if handler then handler() end
    return Book.view()
end

function Book.back()
    if session.pending then session:continue() else session:leave_focus() end
    return Book.view()
end

function Book.continue()
    session:continue()
    return Book.view()
end

function Book.command(text)
    if type(text) ~= "string" or not text:match("%S") then return Book.view() end
    -- A typed command dismisses the previous response, then becomes a new beat.
    if session.pending then session:continue() end
    local before = session.env.HERE
    local output = session.game:resume(text) or ""
    local changed = session.env.HERE ~= before
    if changed then session.focus, session.focus_text = nil, nil end
    local state = session:view()
    session.pending = {
        text = output, camera = state.camera, image = state.image, room_changed = changed,
    }
    return Book.view()
end

return Book
