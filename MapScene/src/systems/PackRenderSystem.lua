local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")
local Cards = require("src.data.cards")
local rules = require("src.data.rules")

local PackRenderSystem = { name = "packRender" }

local function selectedCount(state)
    local count = 0
    for _, marked in ipairs(state.selected) do
        if marked then count = count + 1 end
    end
    return count
end

function PackRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local state = scene.registry:resource("packState")
    Draw.clear()

    Draw.text("CHOOSE TWO", 0, 18, 640, "center", 22)
    Draw.text(("Collection: %d cards"):format(#runState.collection), 0, 43, 640, "center", 11, Palette.muted)

    for i, cardId in ipairs(state.offer) do
        Draw.card(cardId, 116 + (i - 1) * 142, 84, 112, 144, state.cursor == i, state.selected[i])
    end

    Draw.cardDetails(state.offer[state.cursor], 74, 250, 492, 72)
    local card = Cards.get(state.offer[state.cursor])
    local risk = card.risky and ("  Visible risk: " .. math.floor(card.risky.chance * 100) .. "%") or ""
    Draw.text(rules.typeLabels[card.type] .. risk, 90, 328, 460, "center", 10, Palette.muted)
    Draw.footer(("Selected %d/%d  |  Arrows: move  |  Space: mark  |  Enter: confirm"):format(selectedCount(state), rules.cardsToChoose))
end

return PackRenderSystem
