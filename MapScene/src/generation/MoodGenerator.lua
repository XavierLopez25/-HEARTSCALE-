local Rng = require("src.core.Rng")
local dragons = require("src.data.dragons")
local rules = require("src.data.rules")

local MoodGenerator = {}

function MoodGenerator.select(runState, dragonId)
    local dragon = assert(dragons[dragonId], "unknown dragon: " .. tostring(dragonId))
    return Rng.pickWeighted(runState, dragon.moodWeights, rules.moodOrder)
end

return MoodGenerator
