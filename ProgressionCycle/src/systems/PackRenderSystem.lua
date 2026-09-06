local RunState = require("src.state.RunState")
local Cards = require("src.data.cards")
local rules = require("src.data.rules")
local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")

local PackRenderSystem = { name = "packRender" }

local function selectedCount(ui)
    local count = 0
    for i = 1, #ui.offer do
        local marked = ui.selected[i]
        if marked then count = count + 1 end
    end
    return count
end

function PackRenderSystem.draw(scene)
    local run = RunState.get()
    local ui = scene.registry:resource("packUI")
    Draw.clear()
    Draw.text("CARD ACQUISITION", 0, 18, 640, "center", 22)
    Draw.text(("Valor %d   Wit %d   Empathy %d"):format(run.stats.valor, run.stats.wit, run.stats.empathy), 0, 45, 640, "center", 11, Palette.muted)

    for i, cardId in ipairs(ui.offer) do
        Draw.card(cardId, 116 + (i - 1) * 142, 84, 112, 144, ui.cursor == i, ui.selected[i])
    end

    Draw.cardDetails(ui.offer[ui.cursor], 72, 250, 496, 70)
    local card = Cards.get(ui.offer[ui.cursor])
    Draw.text("Generated type: " .. rules.typeLabels[card.type], 90, 328, 460, "center", 10, Palette.muted)
    Draw.text(ui.message, 70, 344, 500, "center", 9, Palette.muted)
    Draw.footer(("Selected %d/%d  |  Arrows: move  |  Space: mark  |  Enter: confirm"):format(selectedCount(ui), rules.cardsToChoose))
end

return PackRenderSystem
