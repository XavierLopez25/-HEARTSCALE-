local Scene = require("src.ecs.Scene")
local DialogueUISystem = require("src.systems.DialogueUISystem")

return function()
    local scene = Scene.new("dialogue")
    scene:addSystem(DialogueUISystem)
    return scene
end
