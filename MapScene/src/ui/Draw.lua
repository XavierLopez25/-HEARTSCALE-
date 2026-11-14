local Palette = require("src.ui.Palette")
local Cards = require("src.data.cards")
local rules = require("src.data.rules")

local Draw = {}

local fonts = {}

local function font(size)
    if not fonts[size] then fonts[size] = love.graphics.newFont(size) end
    return fonts[size]
end

local function color(c, alpha)
    love.graphics.setColor(c[1], c[2], c[3], alpha or c[4] or 1)
end

function Draw.clear()
    color(Palette.bg)
    love.graphics.rectangle("fill", 0, 0, 640, 400)
end

function Draw.font(size)
    love.graphics.setFont(font(size))
    return fonts[size]
end

function Draw.text(value, x, y, w, align, size, c)
    Draw.font(size or 12)
    color(c or Palette.ink)
    love.graphics.printf(value, x, y, w, align or "left")
end

function Draw.panel(x, y, w, h, selected)
    color(selected and Palette.panel2 or Palette.panel)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)
    love.graphics.setLineWidth(selected and 2 or 1)
    color(selected and Palette.ink or Palette.dim)
    love.graphics.rectangle("line", x, y, w, h, 4, 4)
    love.graphics.setLineWidth(1)
end

function Draw.button(label, x, y, w, h, selected, accent)
    Draw.panel(x, y, w, h, selected)
    if selected then
        color(accent or Palette.warning)
        love.graphics.rectangle("fill", x, y + h - 4, w, 4, 0, 0)
    end
    Draw.text(label, x + 6, y + math.floor((h - 13) / 2), w - 12, "center", 12)
end

function Draw.meter(label, value, maxValue, x, y, w, c)
    Draw.text(label, x, y, 82, "left", 11, Palette.muted)
    color(Palette.panel2)
    love.graphics.rectangle("fill", x + 84, y + 2, w - 84, 8, 2, 2)
    local fill = math.max(0, math.min(1, value / maxValue))
    color(c)
    love.graphics.rectangle("fill", x + 84, y + 2, (w - 84) * fill, 8, 2, 2)
    Draw.text(tostring(value), x + w - 28, y - 2, 28, "right", 10, Palette.ink)
end

local function typeColor(cardType)
    return Palette[cardType] or Palette.muted
end

local EFFECT_LABELS = {
    if_pressure_at_least = "bonus at high Pressure",
    if_mood = "mood bonus",
    next_card_chemistry = "boosts the next card",
    previous_type_different = "better if you change type",
    tag_match_week = "weekly activity bonus",
    challenge_pressure_shield = "protects the next Challenge",
    reveal_next_mood = "reveals the next mood",
}

function Draw.card(cardId, x, y, w, h, selected, marked)
    local card = Cards.get(cardId)
    local c = typeColor(card.type)
    Draw.panel(x, y, w, h, selected or marked)
    color(c)
    love.graphics.rectangle("fill", x, y, w, 15, 4, 4)
    love.graphics.rectangle("fill", x, y + 12, w, 4)
    if marked then
        love.graphics.setColor(1, 1, 1, 0.20)
        love.graphics.rectangle("fill", x + 3, y + 18, w - 6, h - 21, 2, 2)
    end
    Draw.text(card.name, x + 5, y + 20, w - 10, "center", 10)
    Draw.text(rules.typeLabels[card.type], x + 5, y + 44, w - 10, "center", 9, c)

    local effect = ("C%+d  P%+d"):format(card.chemistry or 0, card.pressure or 0)
    if card.risky then
        effect = ("%d%% RISKY"):format(card.risky.chance * 100)
    end
    Draw.text(effect, x + 5, y + h - 26, w - 10, "center", 10, Palette.ink)
    Draw.text("T" .. card.tier, x + 5, y + h - 12, w - 10, "center", 9, Palette.muted)
end

function Draw.cardDetails(cardId, x, y, w, h)
    if not cardId then return end
    local card = Cards.get(cardId)
    Draw.panel(x, y, w, h, false)
    local c = typeColor(card.type)
    Draw.text(card.name, x + 10, y + 8, w - 20, "left", 14, Palette.ink)
    Draw.text(rules.typeLabels[card.type] .. "  Tier " .. card.tier, x + 10, y + 28, w - 20, "left", 11, c)

    local line = ("Chemistry %+d   Pressure %+d"):format(card.chemistry or 0, card.pressure or 0)
    if card.risky then
        line = ("Risky: %d%% success"):format(card.risky.chance * 100)
    end
    Draw.text(line, x + 10, y + 50, w - 20, "left", 11)
    Draw.text(card.action or card.flavor or "", x + 10, y + 68, w - 20, "left", 10, Palette.muted)

    if card.effect and h >= 128 then
        Draw.text("Effect: " .. (EFFECT_LABELS[card.effect.kind] or card.effect.kind), x + 10, y + h - 28, w - 20, "left", 10, Palette.warning)
    end
end

function Draw.portrait(dragon, x, y, w, h)
    local c = dragon.accent or Palette.muted
    Draw.panel(x, y, w, h, false)
    love.graphics.setScissor(x, y, w, h)
    love.graphics.setColor(c[1] * 0.18, c[2] * 0.18, c[3] * 0.18, 1)
    love.graphics.rectangle("fill", x + 4, y + 4, w - 8, h - 8)

    color(c, 0.90)
    local cx = x + w / 2
    love.graphics.rectangle("fill", cx - 30, y + 62, 60, 74, 10, 10)
    love.graphics.rectangle("fill", cx - 23, y + 32, 46, 42, 12, 12)
    love.graphics.polygon("fill", cx - 26, y + 38, cx - 56, y + 8, cx - 34, y + 48)
    love.graphics.polygon("fill", cx + 26, y + 38, cx + 56, y + 8, cx + 34, y + 48)

    love.graphics.setColor(0.02, 0.02, 0.025, 0.42)
    love.graphics.rectangle("fill", cx - 20, y + 52, 40, 6, 2, 2)
    love.graphics.circle("fill", cx - 10, y + 49, 2)
    love.graphics.circle("fill", cx + 10, y + 49, 2)

    love.graphics.setScissor()
    Draw.text(dragon.name, x + 6, y + h - 22, w - 12, "center", 13, Palette.ink)
    Draw.text(dragon.title, x + 6, y + h - 10, w - 12, "center", 9, Palette.muted)
end

function Draw.footer(text)
    color(Palette.black, 0.88)
    love.graphics.rectangle("fill", 0, 364, 640, 36)
    Draw.text(text, 12, 374, 616, "center", 11, Palette.muted)
end

return Draw
