local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")
local activities = require("src.data.activities")

local ProgressionRenderSystem = { name = "progressionRender" }

local STAT_ROWS = {
    { key = "valor", label = "VALOR", color = Palette.challenge },
    { key = "wit", label = "WIT", color = Palette.wit },
    { key = "empathy", label = "EMPATHY", color = Palette.connection },
}

local STAT_LABELS = {
    valor = "Valor",
    wit = "Wit",
    empathy = "Empathy",
}

function ProgressionRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local state = scene.registry:resource("progressionState")
    Draw.clear()

    Draw.text("PROGRESSION", 20, 18, 220, "left", 20)
    Draw.text(("Week %02d"):format(runState.week), 480, 18, 132, "right", 14, Palette.muted)
    Draw.text(("Actions %d / %d"):format(runState.progression.actionsUsed, runState.progression.actionsPerWeek), 480, 36, 132, "right", 12, Palette.muted)

    Draw.panel(20, 64, 170, 164)
    Draw.text("Stats", 32, 76, 120, "left", 14)
    for i, row in ipairs(STAT_ROWS) do
        local y = 104 + (i - 1) * 36
        Draw.text(row.label, 34, y, 82, "left", 12, row.color)
        Draw.text(tostring(runState.stats[row.key]), 130, y, 36, "right", 18)
    end

    Draw.panel(210, 64, 390, 164)
    Draw.text("Guild Activities", 226, 76, 340, "left", 14)
    for i, id in ipairs(activities.order) do
        local activity = activities[id]
        local x = 226 + (i - 1) * 120
        Draw.button(activity.short, x, 110, 100, 34, state.phase == "choosing" and state.cursor == i, Palette[activity.relatedType])
        local desc = {}
        for stat, amount in pairs(activity.effects) do desc[#desc + 1] = STAT_LABELS[stat] .. " +" .. amount end
        table.sort(desc)
        Draw.text(table.concat(desc, ", "), x, 152, 100, "center", 10, Palette.muted)
    end

    Draw.panel(20, 248, 580, 84, state.phase == "feedback")
    Draw.text(state.message, 34, 264, 552, "left", 13, state.phase == "feedback" and Palette.ink or Palette.muted)

    if state.phase == "feedback" and state.progressionComplete then
        Draw.footer("Progression complete. Enter opens the weekly pack.")
    elseif state.phase == "feedback" then
        Draw.footer("Enter: continue")
    else
        Draw.footer("Arrows: choose activity  |  Enter: confirm")
    end
end

return ProgressionRenderSystem
