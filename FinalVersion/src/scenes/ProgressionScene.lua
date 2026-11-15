local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local ProgressionInputSystem = require("src.systems.ProgressionInputSystem")
local ActivityResolutionSystem = require("src.systems.ActivityResolutionSystem")
local ProgressionRenderSystem = require("src.systems.ProgressionRenderSystem")

return function(payload)
    local scene = Scene.new("progression")
    local runState = RunState.get()
    runState.progression.actionsPerWeek = runState.progression.actionsPerWeek or 3
    scene.registry:setResource("runState", runState)
    scene.registry:setResource("progressionState", {
        phase = "choosing",
        cursor = 1,
        progressionComplete = false,
        message = "Choose how to grow before the next date.",
    })
    scene:addSystem(ProgressionInputSystem)
    scene:addSystem(ActivityResolutionSystem)
    scene:addSystem(ProgressionRenderSystem)
    return scene
end
