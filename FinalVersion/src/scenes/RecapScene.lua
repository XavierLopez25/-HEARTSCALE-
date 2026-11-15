local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local RecapInputSystem = require("src.systems.RecapInputSystem")
local RecapRenderSystem = require("src.systems.RecapRenderSystem")

return function(payload)
    local scene = Scene.new("recap")
    scene.registry:setResource("runState", RunState.get())
    scene:addSystem(RecapInputSystem)
    scene:addSystem(RecapRenderSystem)
    return scene
end
