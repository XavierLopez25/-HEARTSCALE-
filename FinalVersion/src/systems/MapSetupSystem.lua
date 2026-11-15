-- SETUP phase of the map scene: turns src/data/map.lua into ECS entities
-- and creates the transient mapState resource. Runs once per scene entry,
-- so every weekly visit starts again in front of the Guild Hall.
local map = require("src.data.map")
local dragons = require("src.data.dragons")
local RunState = require("src.state.RunState")
local MapAssets = require("src.ui.MapAssets")

local MapSetupSystem = { name = "mapSetup" }

local function copyRect(rect)
    return { x = rect.x, y = rect.y, w = rect.w, h = rect.h }
end

function MapSetupSystem.promptFor(building)
    if building.dragonId then
        return ("Enter: Visit %s at the %s"):format(dragons[building.dragonId].name, building.label)
    end
    return ("Enter: Return to the %s (Collection)"):format(building.label)
end

function MapSetupSystem.setup(scene)
    local registry = scene.registry
    registry:setResource("runState", RunState.get())

    for _, terrain in ipairs(map.terrain) do
        registry:spawn({
            worldPosition = { x = terrain.x, y = terrain.y },
            terrain = { id = terrain.id, kind = terrain.kind, w = terrain.w, h = terrain.h },
        })
    end

    for _, wall in ipairs(map.walls) do
        registry:spawn({
            worldPosition = { x = wall.x, y = wall.y },
            collider = { w = wall.w, h = wall.h, solid = true },
            wall = { id = wall.id },
        })
    end

    for _, building in ipairs(map.buildings) do
        registry:spawn({
            worldPosition = { x = building.x, y = building.y },
            collider = { w = building.w, h = building.h, solid = true },
            building = building,
            pointOfInterest = {
                id = building.id,
                label = building.label,
                dragonId = building.dragonId,
                action = building.action,
                interactionRect = copyRect(building.interaction),
                door = copyRect(building.door),
                prompt = MapSetupSystem.promptFor(building),
            },
        })
    end

    for _, obstacle in ipairs(map.obstacles) do
        registry:spawn({
            worldPosition = { x = obstacle.x, y = obstacle.y },
            collider = { w = obstacle.w, h = obstacle.h, solid = true },
            obstacle = { id = obstacle.id, kind = obstacle.kind },
        })
    end

    local player = registry:spawn({
        worldPosition = { x = map.spawn.x, y = map.spawn.y },
        collider = { w = map.player.w, h = map.player.h, solid = false },
        velocity = { x = 0, y = 0 },
        player = {
            speed = map.player.speed,
            facing = map.spawn.facing,
            moving = false,
            animTime = 0,
        },
    })

    registry:setResource("mapState", {
        player = player,
        bounds = copyRect(map.bounds),
        nearby = nil,
        prompt = "",
        returnScene = map.returnScene,
        title = map.title,
        assets = MapAssets.load(),
    })
end

return MapSetupSystem
