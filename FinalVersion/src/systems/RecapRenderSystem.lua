local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")
local Cards = require("src.data.cards")
local dragons = require("src.data.dragons")

local RecapRenderSystem = { name = "recapRender" }

function RecapRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local lastDate = runState.lastDate
    Draw.clear()

    Draw.text("WEEKLY RECAP", 0, 18, 640, "center", 22)
    Draw.panel(72, 64, 496, 210)

    Draw.text("Cards Acquired", 94, 86, 180, "left", 14, Palette.warning)
    if #runState.lastAcquired == 0 then
        Draw.text("None", 94, 110, 180, "left", 11, Palette.muted)
    else
        for i, id in ipairs(runState.lastAcquired) do
            Draw.text(Cards.get(id).name, 94, 108 + (i - 1) * 16, 180, "left", 11)
        end
    end

    if lastDate then
        local dragon = dragons[lastDate.dragonId]
        Draw.text("Date Result", 336, 86, 180, "left", 14, dragon.accent)
        Draw.text(dragon.name .. " - " .. lastDate.label, 336, 110, 180, "left", 11)
        Draw.text(("Chemistry %d  Pressure %d"):format(lastDate.chemistry, lastDate.pressure), 336, 130, 180, "left", 11, Palette.muted)
        Draw.text(("Affection %+d  (%d -> %d)"):format(
            lastDate.affectionDelta,
            lastDate.affectionBefore,
            lastDate.affectionAfter), 336, 148, 180, "left", 11, Palette.muted)
    end

    Draw.text(("Valor %d   Wit %d   Empathy %d"):format(
        runState.stats.valor,
        runState.stats.wit,
        runState.stats.empathy), 94, 212, 440, "center", 12, Palette.muted)

    if runState.week >= 6 then
        Draw.footer("Week 6 complete. Enter opens the Festival.")
    else
        Draw.footer("Enter: start the next week")
    end
end

return RecapRenderSystem
