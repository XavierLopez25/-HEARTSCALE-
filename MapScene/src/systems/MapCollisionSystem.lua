-- UPDATE phase, step 2: integrates velocity with delta time and resolves
-- AABB collisions one axis at a time (X, then Y) against every solid
-- collider, then clamps the result to the walkable bounds.
local MapPhysics = require("src.rules.MapPhysics")

local MapCollisionSystem = { name = "mapCollision" }

function MapCollisionSystem.solids(registry)
    local solids = {}
    for _, position, collider in registry:each("worldPosition", "collider") do
        if collider.solid then
            solids[#solids + 1] = { x = position.x, y = position.y, w = collider.w, h = collider.h }
        end
    end
    return solids
end

function MapCollisionSystem.update(scene, dt)
    local registry = scene.registry
    local state = registry:resource("mapState")
    local solids = MapCollisionSystem.solids(registry)
    for _, position, collider, velocity in registry:each("worldPosition", "collider", "velocity") do
        local blockedX, blockedY = MapPhysics.move(
            position, collider, velocity.x * dt, velocity.y * dt, solids, state.bounds)
        velocity.blockedX = blockedX
        velocity.blockedY = blockedY
    end
end

return MapCollisionSystem
