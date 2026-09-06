package.path = "./?.lua;" .. package.path

local Game = require("src.Game")
local Screen = require("src.Screen")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Screen.setup(640, 400)
    Game.registerScene("title", require("src.scenes.TitleScene"))
    Game.registerScene("dragonSelect", require("src.scenes.DragonSelectScene"))
    Game.registerScene("dialogue", require("src.scenes.DialogueScene"))
    Game.registerScene("progression", require("src.scenes.ProgressionScene"))
    Game.registerScene("pack", require("src.scenes.PackScene"))
    Game.registerScene("collection", require("src.scenes.CollectionScene"))
    Game.switch("title")
end

function love.update(dt)
    Game.update(dt)
end

function love.draw()
    Screen.begin()
    Game.draw()
    Screen.finish()
end

function love.keypressed(key)
    Game.keypressed(key)
end

function love.resize(w, h)
    Screen.resize(w, h)
end
