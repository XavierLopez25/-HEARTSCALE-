local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")
local Cards = require("src.data.cards")
local dragons = require("src.data.dragons")
local moods = require("src.data.moods")
local DateDialogue = require("src.data.date_dialogue")

local DateRenderSystem = { name = "dateRender" }

-- Mood panel: starts right under the meters; its blocks flow by real text height.
DateRenderSystem.MOOD_PANEL = { x = 18, y = 82, w = 342, h = 98 }

function DateRenderSystem.moodLayout(dateState)
    local P = DateRenderSystem.MOOD_PANEL
    local dragon = dragons[dateState.dragonId]
    local mood = moods[dateState.currentMood]
    local tx, tw = 14, P.w - 28
    local elements = {
        { role = "label", text = mood.label:upper(), x = tx, y = 8, w = tw, size = 15, align = "left",
          color = dragon.accent },
    }
    if dateState.previewMood then
        -- shares the title row, right-aligned
        elements[#elements + 1] = { role = "preview", text = "Next mood: " .. moods[dateState.previewMood].label,
            x = tx, y = 12, w = tw, size = 10, align = "right", color = Palette.warning }
    end
    local y = 8 + Draw.textHeight(mood.label:upper(), tw, 15) + 3
    for _, block in ipairs({
        { "note", mood.note, Palette.muted },
        { "cue", DateDialogue.cue(dateState.dragonId, dateState.currentMood), Palette.ink },
    }) do
        local hgt = Draw.textHeight(block[2], tw, 10)
        elements[#elements + 1] = { role = block[1], text = block[2], x = tx, y = y, w = tw, size = 10,
            align = "left", color = block[3], h = hgt }
        y = y + hgt + 4
    end
    for _, e in ipairs(elements) do
        e.h = e.h or Draw.textHeight(e.text, e.w, e.size)
        e.bottom = P.h - 4
    end
    return elements
end

function DateRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local dateState = scene.registry:resource("dateState")
    local dragon = dragons[dateState.dragonId]
    Draw.clear()

    Draw.text(("WEEK %02d - %s"):format(runState.week, dragon.name:upper()), 18, 14, 280, "left", 18)
    Draw.text(("Exchange %d / %d"):format(dateState.exchange, dateState.maxExchanges), 456, 18, 154, "right", 11, Palette.muted)
    Draw.meter("CHEMISTRY", dateState.chemistry, 10, 18, 47, 260, dragon.accent)
    Draw.meter("PRESSURE", dateState.pressure, dateState.maxPressure, 18, 65, 260, Palette.bad)

    Draw.portrait(dragon, 398, 42, 142, 176)

    local P = DateRenderSystem.MOOD_PANEL
    Draw.panel(P.x, P.y, P.w, P.h)
    Draw.elements(DateRenderSystem.moodLayout(dateState), P.x, P.y)

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
