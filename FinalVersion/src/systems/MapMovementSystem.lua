-- UPDATE phase, step 1: reads held keys (arrows or WASD) and turns them into
-- a velocity. Diagonals are normalized so they are never faster than 95 px/s.
local Keyboard = require("src.core.Keyboard")

local MapMovementSystem = { name = "mapMovement" }

MapMovementSystem.KEYS = {
    left = { "left", "a" },
    right = { "right", "d" },
    up = { "up", "w" },
    down = { "down", "s" },
}

local function held(direction)
    local keys = MapMovementSystem.KEYS[direction]
    return Keyboard.isDown(keys[1], keys[2])
end

function MapMovementSystem.direction()
    local dx, dy = 0, 0
    if held("left") then dx = dx - 1 end
    if held("right") then dx = dx + 1 end
    if held("up") then dy = dy - 1 end
    if held("down") then dy = dy + 1 end
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then
        dx, dy = dx / length, dy / length
    end
    return dx, dy
end

local function facingFor(dx, dy, previous)
    local horizontal = dx < 0 and "left" or (dx > 0 and "right" or nil)
    local vertical = dy < 0 and "up" or (dy > 0 and "down" or nil)
    if horizontal and vertical then
        -- Keep the current facing while it still matches one of the axes.
        if previous == horizontal or previous == vertical then return previous end
        return horizontal
    end
    return horizontal or vertical or previous
end

function MapMovementSystem.update(scene, dt)
    local dx, dy = MapMovementSystem.direction()
    for _, player, velocity in scene.registry:each("player", "velocity") do
        velocity.x = dx * player.speed
        velocity.y = dy * player.speed
        player.moving = dx ~= 0 or dy ~= 0
        if player.moving then
            player.facing = facingFor(dx, dy, player.facing)
            player.animTime = player.animTime + dt
        else
            player.animTime = 0
        end
    end
end

return MapMovementSystem
