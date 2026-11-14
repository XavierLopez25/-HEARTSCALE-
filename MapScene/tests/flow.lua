package.path = "./?.lua;" .. package.path

_G.love = {
    event = { quit = function() end },
    sound = nil,
    audio = nil,
    timer = { getFPS = function() return 60 end },
}

local Game = require("src.Game")
local RunState = require("src.state.RunState")
local Keyboard = require("src.core.Keyboard")

local held = {}
Keyboard.setProvider(function(...)
    for _, key in ipairs({ ... }) do
        if held[key] then return true end
    end
    return false
end)

os.time = function() return 42 end

Game.registerScene("title", require("src.scenes.TitleScene"))
Game.registerScene("progression", require("src.scenes.ProgressionScene"))
Game.registerScene("pack", require("src.scenes.PackScene"))
Game.registerScene("collection", require("src.scenes.CollectionScene"))
Game.registerScene("map", require("src.scenes.MapScene"))
Game.registerScene("date", require("src.scenes.DateScene"))
Game.registerScene("recap", require("src.scenes.RecapScene"))
Game.registerScene("ending", require("src.scenes.EndingScene"))

local function tap(key)
    Game.keypressed(key)
    Game.update(0)
end

local function sceneName()
    return Game.current().name
end

local function assertScene(expected)
    assert(sceneName() == expected, "expected scene " .. expected .. ", got " .. sceneName())
end

Game.start("title")
assertScene("title")
tap("return")
assertScene("progression")

local run = RunState.get()
assert(run.week == 1, "new game starts week 1")

for _ = 1, 3 do
    tap("return")
    assertScene("progression")
    tap("return")
end
assertScene("pack")
assert(run.stats.valor == 7, "default progression cursor should train valor three times")

tap("space")
tap("right")
tap("space")
tap("return")
assertScene("collection")
assert(#run.collection == 8, "pack should add two cards")

tap("return")
assertScene("map")
assert(run.currentDragon == nil, "entering the map does not choose a dragon")

tap("return")
assertScene("map")
assert(run.currentDragon == nil, "enter at the spawn should not start a date")

-- Walk west along the north road, then north to the Forge door.
local function playerPos()
    local scene = Game.current()
    return scene.registry:get(scene.registry:resource("mapState").player, "worldPosition")
end
held = { left = true }
for _ = 1, 600 do
    Game.update(1 / 60)
    if playerPos().x <= 106 then break end
end
held = { up = true }
for _ = 1, 30 do Game.update(1 / 60) end
held = {}
Game.update(0)
assert(Game.current().registry:resource("mapState").prompt == "Enter: Visit Kaela at the Forge",
    "forge prompt should be visible at the door")

tap("return")
assertScene("date")
assert(run.currentDragon == "kaela", "visiting the Forge should choose Kaela")

for i = 1, 5 do
    tap("return")
    if i < 5 then
        assertScene("date")
        tap("return")
        assertScene("date")
    end
end
assertScene("date")
tap("return")
assertScene("recap")
assert(run.lastDate ~= nil, "date should write recap data")

tap("return")
assertScene("progression")
assert(run.week == 2, "recap should advance to week 2")

print("flow smoke test passed")
