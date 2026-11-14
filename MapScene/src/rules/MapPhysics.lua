-- Pure AABB helpers for the guild map. No LOVE dependency and no physics
-- library: movement is integrated per axis and resolved against solid boxes.
local MapPhysics = {}

-- Largest distance moved in one sub-step. Smaller than the thinnest solid
-- (8 px fences) so a long frame can never tunnel through an obstacle.
MapPhysics.MAX_STEP = 4

function MapPhysics.overlaps(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah
end

function MapPhysics.rectsOverlap(a, b)
    return MapPhysics.overlaps(a.x, a.y, a.w, a.h, b.x, b.y, b.w, b.h)
end

function MapPhysics.clampToBounds(pos, size, bounds)
    pos.x = math.max(bounds.x, math.min(pos.x, bounds.x + bounds.w - size.w))
    pos.y = math.max(bounds.y, math.min(pos.y, bounds.y + bounds.h - size.h))
end

-- Moves pos along one axis ("x" or "y") by delta and pushes it out of any
-- overlapping solid box in the direction it came from.
function MapPhysics.moveAxis(pos, size, delta, axis, solids, bounds)
    if delta == 0 then return false end
    pos[axis] = pos[axis] + delta
    local blocked = false
    for _, box in ipairs(solids) do
        if MapPhysics.overlaps(pos.x, pos.y, size.w, size.h, box.x, box.y, box.w, box.h) then
            blocked = true
            if axis == "x" then
                pos.x = delta > 0 and (box.x - size.w) or (box.x + box.w)
            else
                pos.y = delta > 0 and (box.y - size.h) or (box.y + box.h)
            end
        end
    end
    if bounds then
        local before = pos[axis]
        MapPhysics.clampToBounds(pos, size, bounds)
        if pos[axis] ~= before then blocked = true end
    end
    return blocked
end

-- Moves by (dx, dy) resolving X first, then Y, split into small sub-steps.
function MapPhysics.move(pos, size, dx, dy, solids, bounds)
    local distance = math.max(math.abs(dx), math.abs(dy))
    local steps = math.max(1, math.ceil(distance / MapPhysics.MAX_STEP))
    local sx, sy = dx / steps, dy / steps
    local blockedX, blockedY = false, false
    for _ = 1, steps do
        if MapPhysics.moveAxis(pos, size, sx, "x", solids, bounds) then blockedX = true end
        if MapPhysics.moveAxis(pos, size, sy, "y", solids, bounds) then blockedY = true end
    end
    return blockedX, blockedY
end

function MapPhysics.collides(rect, solids)
    for _, box in ipairs(solids) do
        if MapPhysics.rectsOverlap(rect, box) then return true end
    end
    return false
end

return MapPhysics
