local RunState = require("src.state.RunState")
local activities = require("src.data.activities")
local rules = require("src.data.rules")

local ProgressionLogicSystem = { name = "progressionLogic" }

local STAT_LABELS = {
    valor = "Valor",
    wit = "Wit",
    empathy = "Empathy",
}

function ProgressionLogicSystem.setup()
    local run = RunState.get()
    run.actionsPerWeek = rules.actionsPerWeek
end

function ProgressionLogicSystem.update(scene)
    local run = RunState.get()
    local ui = scene.registry:resource("progressionUI")
    for _, event in scene.registry:each("activitySelected") do
        local activity = activities[event.id]
        for stat, amount in pairs(activity.effects) do
            run.stats[stat] = run.stats[stat] + amount
        end
        for _, tag in ipairs(activity.tags) do
            run.weeklyTags[tag] = true
        end
        run.actionsUsed = run.actionsUsed + 1

        local gains = {}
        for stat, amount in pairs(activity.effects) do
            gains[#gains + 1] = STAT_LABELS[stat] .. " +" .. amount
        end
        table.sort(gains)

        local line = activity.lines[((run.actionsUsed - 1) % #activity.lines) + 1]
        ui.phase = "feedback"
        ui.complete = run.actionsUsed >= run.actionsPerWeek
        ui.message = activity.name .. "\n" .. table.concat(gains, "   ") .. "\n" .. line
    end
end

return ProgressionLogicSystem
