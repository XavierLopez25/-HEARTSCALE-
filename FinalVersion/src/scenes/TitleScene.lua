local Scene = require("src.ecs.Scene")

local TitleInputSystem = require("src.systems.TitleInputSystem")
local TitleRenderSystem = require("src.systems.TitleRenderSystem")

return function(payload)
    local scene = Scene.new("title")
    scene.registry:setResource("titleMenu", {
        cursor = 1,
        options = {
            { id = "new", label = "New Game" },
            { id = "quit", label = "Quit" },
        },
    })
    scene:addSystem(TitleInputSystem)
    scene:addSystem(TitleRenderSystem)
    return scene
end
