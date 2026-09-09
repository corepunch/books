#!/usr/bin/env lua

local runtime = require 'zilscript.runtime'

local games = {
    lurkinghorror = "infocom.lurkinghorror.h1",
    spellbreaker = "infocom.spellbreaker.z6",
}

for name, module in pairs(games) do
    local env = runtime.create_game_env()
    assert(runtime.init(env, true), "failed to initialize " .. name)
    env.require("zilscript")
    assert(runtime.load_modules(env, {module}, {silent = true}), "failed to load " .. name)

    local game = runtime.create_game(env, true)
    local ok, output = pcall(function() return game:start() end)
    assert(ok, name .. " failed during GO(): " .. tostring(output))
    assert(type(output) == "string" and #output > 0, name .. " produced no startup text")
    assert(game:is_running(), name .. " stopped before accepting input")

    local resumed, look = pcall(function() return game:resume("look") end)
    assert(resumed, name .. " failed its first command: " .. tostring(look))
    assert(type(look) == "string" and #look > 0, name .. " produced no LOOK response")
    print(name .. " startup: ok")
end
