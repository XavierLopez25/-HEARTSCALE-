local Scene = require("src.ecs.Scene")
local MainMenuUISystem = require("src.systems.MainMenuUISystem")

return function()
    local scene = Scene.new("title")
    scene:addSystem(MainMenuUISystem)
    return scene
end
