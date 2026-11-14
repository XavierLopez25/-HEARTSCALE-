local rules = require("src.data.rules")

local Relationship = {}

function Relationship.resultFor(chemistry, pressure)
    if pressure >= rules.maxPressure then
        return { id = "awkward", label = "Awkward Date", affection = -1 }
    elseif chemistry >= rules.greatDateChemistry and pressure <= rules.greatDatePressure then
        return { id = "great", label = "Great Date", affection = 2 }
    elseif chemistry >= rules.goodDateChemistry then
        return { id = "good", label = "Good Date", affection = 1 }
    end
    return { id = "neutral", label = "Neutral Date", affection = 0 }
end

function Relationship.apply(runState, dragonId, chemistry, pressure)
    local result = Relationship.resultFor(chemistry, pressure)
    local before = runState.affection[dragonId] or 0
    local after = math.max(0, before + result.affection)
    runState.affection[dragonId] = after
    return {
        id = result.id,
        label = result.label,
        affectionDelta = after - before,
        affectionBefore = before,
        affectionAfter = after,
        chemistry = chemistry,
        pressure = pressure,
        dragonId = dragonId,
    }
end

return Relationship
