local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")
local dragons = require("src.data.dragons")
local rules = require("src.data.rules")

local EndingRenderSystem = { name = "endingRender" }

function EndingRenderSystem.draw(scene)
    local state = scene.registry:resource("endingState")
    local runState = scene.registry:resource("runState")
    Draw.clear()

    Draw.text("FESTIVAL OF THE FIRST FLAME", 0, 16, 640, "center", 20)

    if state.phase == "choosing" then
        Draw.text("Invite someone to the festival.", 0, 44, 640, "center", 11, Palette.muted)
        for i, id in ipairs(dragons.order) do
            local dragon = dragons[id]
            local y = 78 + (i - 1) * 42
            Draw.button(dragon.name, 202, y, 132, 28, state.cursor == i, dragon.accent)
            Draw.text(("Affection %d / %d"):format(runState.affection[id] or 0, rules.romanceAffection), 350, y + 8, 112, "left", 10, Palette.muted)
        end
        Draw.button("Go Alone", 202, 78 + #dragons.order * 42, 132, 28, state.cursor == #dragons.order + 1, Palette.warning)
        Draw.footer("Arrows: choose  |  Enter: confirm")
    else
        local dragon = state.dragonId and dragons[state.dragonId]
        if dragon then
            Draw.portrait(dragon, 250, 62, 140, 170)
        end
        local title = state.outcome == "romance" and "ROMANTIC ENDING"
            or state.outcome == "friendly" and "FRIENDSHIP ENDING"
            or "NEUTRAL ENDING"
        Draw.text(title, 0, 250, 640, "center", 18, dragon and dragon.accent or Palette.warning)
        Draw.text(state.message, 120, 280, 400, "center", 12, Palette.ink)
        Draw.footer("Enter: return to title")
    end
end

return EndingRenderSystem
