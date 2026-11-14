local Scene = require("src.ecs.Scene")

local MapSetupSystem = require("src.systems.MapSetupSystem")
local MapMovementSystem = require("src.systems.MapMovementSystem")
local MapCollisionSystem = require("src.systems.MapCollisionSystem")
local MapInteractionSystem = require("src.systems.MapInteractionSystem")
local MapRenderSystem = require("src.systems.MapRenderSystem")

-- Setup -> Update -> Render:
--   setup:  MapSetupSystem builds entities and the mapState resource.
--   update: movement (input -> velocity), collision (velocity -> position),
--           interaction (nearby POI, Enter, Backspace), in that order.
--   draw:   MapRenderSystem draws ground, buildings, props, player and HUD.
return function(payload)
    local scene = Scene.new("map")
    scene:addSystem(MapSetupSystem)
    scene:addSystem(MapMovementSystem)
    scene:addSystem(MapCollisionSystem)
    scene:addSystem(MapInteractionSystem)
    scene:addSystem(MapRenderSystem)
    return scene
end
