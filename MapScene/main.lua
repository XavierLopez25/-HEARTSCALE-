local Game = require("src.Game")
local Screen = require("src.Screen")
local DebugOverlay = require("src.debug.DebugOverlay")

local gameCanvas

local function scaledViewport()
    local ww, wh = love.graphics.getDimensions()
    local scale = math.max(1, math.floor(math.min(ww / Screen.w, wh / Screen.h)))
    local x = math.floor((ww - Screen.w * scale) / 2)
    local y = math.floor((wh - Screen.h * scale) / 2)
    return scale, x, y
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    gameCanvas = love.graphics.newCanvas(Screen.w, Screen.h)

    Game.registerScene("title", require("src.scenes.TitleScene"))
    Game.registerScene("progression", require("src.scenes.ProgressionScene"))
    Game.registerScene("pack", require("src.scenes.PackScene"))
    Game.registerScene("collection", require("src.scenes.CollectionScene"))
    Game.registerScene("map", require("src.scenes.MapScene"))
    Game.registerScene("date", require("src.scenes.DateScene"))
    Game.registerScene("recap", require("src.scenes.RecapScene"))
    Game.registerScene("ending", require("src.scenes.EndingScene"))

    Game.start("title")
end

function love.update(dt)
    Game.update(dt)
end

function love.draw()
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0.063, 0.063, 0.078, 1)
    Game.draw()
    love.graphics.setCanvas()

    love.graphics.clear(0.02, 0.02, 0.025, 1)
    local scale, x, y = scaledViewport()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, x, y, 0, scale, scale)
    DebugOverlay.draw(Game.current(), scale, x, y)
end

function love.keypressed(key)
    if DebugOverlay.keypressed(key, Game.current()) then return end
    Game.keypressed(key)
end

function love.quit()
    Game.quit()
end
