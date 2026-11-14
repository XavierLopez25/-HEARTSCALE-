local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local EndingInputSystem = require("src.systems.EndingInputSystem")
local EndingRenderSystem = require("src.systems.EndingRenderSystem")

return function(payload)
    local scene = Scene.new("ending")
    scene.registry:setResource("runState", RunState.get())
    scene.registry:setResource("endingState", {
        phase = "choosing",
        cursor = 1,
        outcome = nil,
        dragonId = nil,
        message = "",
    })
    scene:addSystem(EndingInputSystem)
    scene:addSystem(EndingRenderSystem)
    return scene
end
