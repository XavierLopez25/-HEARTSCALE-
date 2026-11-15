-- UPDATE phase, step 3: finds the point of interest the player is standing
-- in front of, builds the prompt, and handles Enter/Space and Backspace.
local Audio = require("src.core.Audio")
local MapPhysics = require("src.rules.MapPhysics")

local MapInteractionSystem = { name = "mapInteraction" }

local function center(rect)
    return rect.x + rect.w / 2, rect.y + rect.h / 2
end

function MapInteractionSystem.findNearby(registry, playerRect)
    local px, py = center(playerRect)
    local best, bestDistance = nil, math.huge
    for _, poi in registry:each("pointOfInterest") do
        if MapPhysics.rectsOverlap(playerRect, poi.interactionRect) then
            local dx, dy = center(poi.door)
            local distance = (dx - px) ^ 2 + (dy - py) ^ 2
            if distance < bestDistance then
                best, bestDistance = poi, distance
            end
        end
    end
    return best
end

local function visit(scene, poi, runState)
    if poi.dragonId then
        runState.currentDragon = poi.dragonId
        Audio.play("confirm")
        scene.registry:spawn({ switchRequest = { to = "date" } })
        return true
    elseif poi.action == "collection" then
        Audio.play("confirm")
        scene.registry:spawn({ switchRequest = { to = "collection" } })
        return true
    end
    return false
end

function MapInteractionSystem.update(scene, dt)
    local registry = scene.registry
    local state = registry:resource("mapState")
    local runState = registry:resource("runState")

    local position = registry:get(state.player, "worldPosition")
    local collider = registry:get(state.player, "collider")
    local playerRect = { x = position.x, y = position.y, w = collider.w, h = collider.h }

    state.nearby = MapInteractionSystem.findNearby(registry, playerRect)
    state.prompt = state.nearby and state.nearby.prompt or ""

    for _, event in registry:each("keyPressed") do
        if event.key == "return" or event.key == "space" then
            -- Outside an interaction zone Enter intentionally does nothing.
            if state.nearby and visit(scene, state.nearby, runState) then return end
        elseif event.key == "backspace" then
            Audio.play("confirm")
            registry:spawn({ switchRequest = { to = state.returnScene } })
            return
        end
    end
end

return MapInteractionSystem
