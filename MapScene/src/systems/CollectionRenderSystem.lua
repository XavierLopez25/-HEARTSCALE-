local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")
local Cards = require("src.data.cards")

local CollectionRenderSystem = { name = "collectionRender" }

function CollectionRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local state = scene.registry:resource("collectionState")
    Draw.clear()

    Draw.text("COLLECTION", 20, 16, 250, "left", 20)
    Draw.text(("Week %d  |  %d cards"):format(runState.week, #runState.collection), 394, 20, 216, "right", 11, Palette.muted)

    for i, cardId in ipairs(runState.collection) do
        local col = (i - 1) % 6
        local row = math.floor((i - 1) / 6)
        Draw.card(cardId, 20 + col * 74, 58 + row * 104, 66, 92, state.cursor == i, false)
    end

    Draw.cardDetails(runState.collection[state.cursor], 474, 58, 146, 196)

    if #runState.lastAcquired > 0 then
        Draw.text("New this week:", 474, 270, 146, "left", 11, Palette.warning)
        for i, id in ipairs(runState.lastAcquired) do
            Draw.text(Cards.get(id).name, 474, 286 + (i - 1) * 13, 146, "left", 10, Palette.muted)
        end
    end

    Draw.footer("Arrows: inspect cards  |  Enter: continue to the guild map")
end

return CollectionRenderSystem
