local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local CollectionInputSystem = require("src.systems.CollectionInputSystem")
local CollectionRenderSystem = require("src.systems.CollectionRenderSystem")

return function(payload)
    local scene = Scene.new("collection")
    scene.registry:setResource("runState", RunState.get())
    scene.registry:setResource("collectionState", {
        cursor = 1,
    })
    scene:addSystem(CollectionInputSystem)
    scene:addSystem(CollectionRenderSystem)
    return scene
end
