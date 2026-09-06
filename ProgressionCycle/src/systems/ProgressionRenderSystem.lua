local RunState = require("src.state.RunState")
local activities = require("src.data.activities")
local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")

local ProgressionRenderSystem = { name = "progressionRender" }

local STAT_ROWS = {
    { key = "valor", label = "VALOR" },
    { key = "wit", label = "WIT" },
    { key = "empathy", label = "EMPATHY" },
}

function ProgressionRenderSystem.draw(scene)
    local run = RunState.get()
    local ui = scene.registry:resource("progressionUI")
    Draw.clear()
    Draw.text("PROGRESSION", 20, 18, 260, "left", 22)
    Draw.text(("Week %d  Actions %d/%d"):format(run.week, run.actionsUsed, run.actionsPerWeek), 386, 24, 220, "right", 12, Palette.muted)

    Draw.panel(24, 64, 160, 156)
    Draw.text("Stats", 38, 78, 120, "left", 14)
    for i, stat in ipairs(STAT_ROWS) do
        local y = 106 + (i - 1) * 34
        Draw.text(stat.label, 40, y, 80, "left", 11, Palette.muted)
        Draw.text(tostring(run.stats[stat.key]), 126, y - 4, 34, "right", 18)
    end

    Draw.panel(208, 64, 408, 156)
    Draw.text("Weekly Activities", 224, 78, 240, "left", 14)
    for i, id in ipairs(activities.order) do
        local activity = activities[id]
        Draw.button(activity.short, 224 + (i - 1) * 126, 118, 106, 34, ui.phase == "choosing" and ui.cursor == i, Palette.warning)
        Draw.text(activity.name, 224 + (i - 1) * 126, 158, 106, "center", 9, Palette.muted)
    end

    Draw.panel(72, 246, 496, 84, ui.phase == "feedback")
    Draw.text(ui.message, 92, 262, 456, "left", 12, ui.phase == "feedback" and Palette.ink or Palette.muted)

    if ui.phase == "feedback" and ui.complete then
        Draw.footer("Progression complete. Enter opens card acquisition.")
    elseif ui.phase == "feedback" then
        Draw.footer("Enter: continue")
    else
        Draw.footer("Arrows: choose activity  |  Enter: confirm")
    end
end

return ProgressionRenderSystem
