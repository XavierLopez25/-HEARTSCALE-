local Scene = require("src.ecs.Scene")
local CollectionNavigationSystem = require("src.systems.CollectionNavigationSystem")
local CollectionRenderSystem = require("src.systems.CollectionRenderSystem")

return function()
    local scene = Scene.new("collection")
    scene:addSystem(CollectionNavigationSystem)
    scene:addSystem(CollectionRenderSystem)
    return scene
end
