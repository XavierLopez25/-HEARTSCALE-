local Rng = require("src.core.Rng")

local HandGenerator = {}

function HandGenerator.draw(collection, count, runState)
    count = count or 5
    assert(#collection >= count, "not enough cards to draw a hand")

    local candidates = {}
    for i, id in ipairs(collection) do candidates[i] = id end

    local hand = {}
    for i = 1, count do
        local picked = Rng.random(runState, i, #candidates)
        candidates[i], candidates[picked] = candidates[picked], candidates[i]
        hand[i] = candidates[i]
    end

    return hand
end

function HandGenerator.drawAvoiding(collection, count, runState, avoid)
    avoid = avoid or {}
    local filtered = {}
    for _, id in ipairs(collection) do
        if not avoid[id] then filtered[#filtered + 1] = id end
    end
    if #filtered < count then filtered = collection end
    return HandGenerator.draw(filtered, math.min(count, #filtered), runState)
end

return HandGenerator
