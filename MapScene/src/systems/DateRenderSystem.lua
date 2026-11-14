local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")
local Cards = require("src.data.cards")
local dragons = require("src.data.dragons")
local moods = require("src.data.moods")
local DateDialogue = require("src.data.date_dialogue")

local DateRenderSystem = { name = "dateRender" }

function DateRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local dateState = scene.registry:resource("dateState")
    local dragon = dragons[dateState.dragonId]
    local mood = moods[dateState.currentMood]
    Draw.clear()

    Draw.text(("WEEK %02d - %s"):format(runState.week, dragon.name:upper()), 18, 14, 280, "left", 18)
    Draw.text(("Exchange %d / %d"):format(dateState.exchange, dateState.maxExchanges), 456, 18, 154, "right", 11, Palette.muted)
    Draw.meter("CHEMISTRY", dateState.chemistry, 10, 18, 47, 260, dragon.accent)
    Draw.meter("PRESSURE", dateState.pressure, dateState.maxPressure, 18, 65, 260, Palette.bad)

    Draw.portrait(dragon, 398, 42, 142, 176)

    Draw.panel(18, 92, 342, 88)
    Draw.text(mood.label:upper(), 32, 104, 300, "left", 15, dragon.accent)
    Draw.text(mood.note, 32, 126, 300, "left", 10, Palette.muted)
    Draw.text(DateDialogue.cue(dateState.dragonId, dateState.currentMood), 32, 148, 300, "left", 10, Palette.ink)
    if dateState.previewMood then
        Draw.text("Next mood: " .. moods[dateState.previewMood].label, 32, 168, 300, "left", 10, Palette.warning)
    end

    if dateState.phase == "feedback" or dateState.phase == "ended" then
        Draw.panel(18, 184, 360, 96, dateState.phase == "ended")
        Draw.text(dateState.feedback, 30, 195, 336, "left", 9, Palette.ink)
    else
        Draw.cardDetails(dateState.hand[dateState.cursor], 18, 184, 360, 96)
    end

    for i, cardId in ipairs(dateState.hand) do
        Draw.card(cardId, 26 + (i - 1) * 118, 292, 102, 62, dateState.phase == "choosing" and dateState.cursor == i, false)
    end

    if dateState.phase == "ended" then
        Draw.footer("Enter: open weekly recap")
    elseif dateState.phase == "feedback" then
        Draw.footer("Enter: continue")
    else
        local selected = Cards.get(dateState.hand[dateState.cursor])
        local risk = selected.risky and ("  |  Risk " .. math.floor(selected.risky.chance * 100) .. "%") or ""
        local mulligan = dateState.mulliganUsed and "Take a Breath used" or "M: take a breath (+1 Pressure)"
        Draw.footer("Arrows: card  |  Enter: play" .. risk .. "  |  " .. mulligan)
    end
end

return DateRenderSystem
