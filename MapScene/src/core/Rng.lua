local Rng = {}

local M = 2147483647
local A = 48271

local function nextUnit(state)
    local seed = state.rngSeed or 1
    if seed <= 0 then seed = 1 end
    state.rngSeed = (A * seed) % M
    if state.rngSeed <= 0 then state.rngSeed = 1 end
    state.rngCalls = (state.rngCalls or 0) + 1
    return state.rngSeed / M
end

function Rng.random(state, low, high)
    local unit = nextUnit(state)
    if low == nil then return unit end
    if high == nil then
        high = low
        low = 1
    end
    return low + math.floor(unit * (high - low + 1))
end

function Rng.chance(state, probability)
    return Rng.random(state) < probability
end

function Rng.pickWeighted(state, weights, order)
    local total = 0
    for _, key in ipairs(order) do
        total = total + math.max(0, weights[key] or 0)
    end
    assert(total > 0, "weighted pick needs a positive total")

    local target = Rng.random(state) * total
    local cumulative = 0
    for _, key in ipairs(order) do
        cumulative = cumulative + math.max(0, weights[key] or 0)
        if target < cumulative then return key end
    end
    return order[#order]
end

function Rng.pick(state, items)
    assert(#items > 0, "cannot pick from an empty list")
    return items[Rng.random(state, 1, #items)]
end

return Rng
