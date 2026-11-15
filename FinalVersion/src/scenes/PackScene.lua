local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local PackGenerationSystem = require("src.systems.PackGenerationSystem")
local PackInputSystem = require("src.systems.PackInputSystem")
local PackRenderSystem = require("src.systems.PackRenderSystem")

return function(payload)
    local scene = Scene.new("pack")
    local runState = RunState.get()
    scene.registry:setResource("runState", runState)
    scene.registry:setResource("packState", {
        offer = {},
        selected = {},
        cursor = 1,
        message = "Choose two cards from the weekly offer.",
    })
    scene:addSystem(PackGenerationSystem)
    scene:addSystem(PackInputSystem)
    scene:addSystem(PackRenderSystem)
    return scene
end
