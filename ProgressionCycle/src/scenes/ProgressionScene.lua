local Scene = require("src.ecs.Scene")
local ProgressionInputSystem = require("src.systems.ProgressionInputSystem")
local ProgressionLogicSystem = require("src.systems.ProgressionLogicSystem")
local ProgressionRenderSystem = require("src.systems.ProgressionRenderSystem")

return function()
    local scene = Scene.new("progression")
    scene:addSystem(ProgressionInputSystem)
    scene:addSystem(ProgressionLogicSystem)
    scene:addSystem(ProgressionRenderSystem)
    return scene
end
