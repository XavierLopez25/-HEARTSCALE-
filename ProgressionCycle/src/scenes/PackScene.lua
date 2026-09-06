local Scene = require("src.ecs.Scene")
local PackGenerationSystem = require("src.systems.PackGenerationSystem")
local PackInputSystem = require("src.systems.PackInputSystem")
local PackRenderSystem = require("src.systems.PackRenderSystem")

return function()
    local scene = Scene.new("pack")
    scene:addSystem(PackGenerationSystem)
    scene:addSystem(PackInputSystem)
    scene:addSystem(PackRenderSystem)
    return scene
end
