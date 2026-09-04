local Scene = require("src.ecs.Scene")
local CharacterSelectUISystem = require("src.systems.CharacterSelectUISystem")

return function()
    local scene = Scene.new("dragonSelect")
    scene:addSystem(CharacterSelectUISystem)
    return scene
end
