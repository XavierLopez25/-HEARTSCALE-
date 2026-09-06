local RunState = require("src.state.RunState")
local Cards = require("src.data.cards")
local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")

local CollectionRenderSystem = { name = "collectionRender" }

function CollectionRenderSystem.draw(scene)
    local run = RunState.get()
    local ui = scene.registry:resource("collectionUI")
    Draw.clear()
    Draw.text("COLLECTION", 20, 18, 260, "left", 22)
    Draw.text(("Week %d  |  %d cards owned"):format(run.week, #run.collection), 364, 24, 240, "right", 12, Palette.muted)

    for i, cardId in ipairs(run.collection) do
        local col = (i - 1) % 6
        local row = math.floor((i - 1) / 6)
        Draw.card(cardId, 22 + col * 74, 64 + row * 102, 66, 90, ui.cursor == i, false)
    end

    Draw.cardDetails(run.collection[ui.cursor], 474, 64, 142, 188)
    if #run.lastAcquired > 0 then
        Draw.text("New this week:", 474, 270, 142, "left", 11, Palette.warning)
        for i, id in ipairs(run.lastAcquired) do
            Draw.text(Cards.get(id).name, 474, 286 + (i - 1) * 14, 142, "left", 10, Palette.muted)
        end
    end

    Draw.footer("Arrows: inspect cards  |  Enter: next week  |  Esc: title")
end

return CollectionRenderSystem
