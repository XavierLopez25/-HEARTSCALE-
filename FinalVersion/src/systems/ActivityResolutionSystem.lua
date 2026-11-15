local activities = require("src.data.activities")
local Rng = require("src.core.Rng")

local ActivityResolutionSystem = { name = "activityResolution" }

local STAT_LABELS = {
    valor = "Valor",
    wit = "Wit",
    empathy = "Empathy",
}

function ActivityResolutionSystem.update(scene, dt)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local progression = registry:resource("progressionState")

    for _, event in registry:each("activitySelected") do
        local activity = activities[event.id]
        for stat, amount in pairs(activity.effects) do
            runState.stats[stat] = runState.stats[stat] + amount
        end
        for _, tag in ipairs(activity.tags or {}) do
            runState.weeklyTags[tag] = true
        end
        runState.progression.actionsUsed = runState.progression.actionsUsed + 1
        runState.lastActivity = event.id

        local line = activity.lines[Rng.random(runState, 1, #activity.lines)]
        local statLines = {}
        for stat, amount in pairs(activity.effects) do
            statLines[#statLines + 1] = STAT_LABELS[stat] .. " +" .. amount
        end
        table.sort(statLines)

        progression.phase = "feedback"
        progression.message = activity.name .. "\n" .. table.concat(statLines, "   ") .. "\n" .. line
        progression.progressionComplete =
            runState.progression.actionsUsed >= runState.progression.actionsPerWeek
    end
end

return ActivityResolutionSystem
