local Palette = require("src.ui.Palette")
local Cards = require("src.data.cards")
local rules = require("src.data.rules")
local DragonPortraits = require("src.ui.DragonPortraits")

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

-- Height in pixels that Draw.text uses for `value` wrapped at width `w`.
function Draw.textHeight(value, w, size)
    local f = font(size or 12)
    local _, lines = f:getWrap(value, w)
    return math.ceil(math.max(1, #lines) * f:getHeight() * f:getLineHeight())
end

function Draw.textWidth(value, size)
    return font(size or 12):getWidth(value)
end

-- Draws a list of layout elements { text, x, y, w, size, align, color } relative to (ox, oy).
function Draw.elements(elements, ox, oy)
    for _, e in ipairs(elements) do
        Draw.text(e.text, ox + e.x, oy + e.y, e.w, e.align, e.size, e.color)
    end
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

Draw.CARD_HEADER = 15
Draw.COMPACT_CARD_HEIGHT = 80

local function cardEffect(card)
    if card.risky then return ("%d%% RISKY"):format(card.risky.chance * 100) end
    return ("C%+d  P%+d"):format(card.chemistry or 0, card.pressure or 0)
end

-- Layout of a card face, relative to its top-left corner. The type label lives in the colored
-- header so the body only holds the name (wrapping freely) above the effect line. Small cards
-- (height < 80, like the date hand) drop the tier line to keep room for two-line names.
-- True when every word of `text` fits `w` at `size` (so wrapping never splits a word).
function Draw.wordsFit(text, w, size)
    for word in text:gmatch("%S+") do
        if Draw.textWidth(word, size) > w then return false end
    end
    return true
end

function Draw.cardLayout(card, w, h)
    local compact = h < Draw.COMPACT_CARD_HEIGHT
    local effectY = compact and (h - 15) or (h - 26)
    -- narrow cards shrink the name (10 -> 9 -> 8) when a long word would otherwise be split
    local nameSize = 10
    while nameSize > 8 and not Draw.wordsFit(card.name, w - 10, nameSize) do nameSize = nameSize - 1 end
    local elements = {
        { role = "type", text = rules.typeLabels[card.type], x = 5, y = 2, w = w - 10, size = 9, align = "center",
          color = Palette.black, bottom = Draw.CARD_HEADER },
        { role = "name", text = card.name, x = 5, y = Draw.CARD_HEADER + 4, w = w - 10, size = nameSize, align = "center",
          color = Palette.ink, bottom = effectY - 1 },
        { role = "effect", text = cardEffect(card), x = 5, y = effectY, w = w - 10, size = 10, align = "center",
          color = Palette.ink, bottom = compact and h or (h - 12) },
    }
    if not compact then
        elements[#elements + 1] = { role = "tier", text = "T" .. card.tier, x = 5, y = h - 12, w = w - 10, size = 9,
            align = "center", color = Palette.muted, bottom = h }
    end
    for _, e in ipairs(elements) do e.h = Draw.textHeight(e.text, e.w, e.size) end
    return elements
end

function Draw.card(cardId, x, y, w, h, selected, marked)
    local card = Cards.get(cardId)
    local c = typeColor(card.type)
    Draw.panel(x, y, w, h, selected or marked)
    color(c)
    love.graphics.rectangle("fill", x, y, w, Draw.CARD_HEADER, 4, 4)
    love.graphics.rectangle("fill", x, y + Draw.CARD_HEADER - 3, w, 4)
    if marked then
        love.graphics.setColor(1, 1, 1, 0.20)
        love.graphics.rectangle("fill", x + 3, y + 18, w - 6, h - 21, 2, 2)
    end
    Draw.elements(Draw.cardLayout(card, w, h), x, y)
end

local function detailStats(card, width)
    if card.risky then return ("Risky: %d%% success"):format(card.risky.chance * 100) end
    local line = ("Chemistry %+d   Pressure %+d"):format(card.chemistry or 0, card.pressure or 0)
    if Draw.textWidth(line, 11) > width then
        line = ("Chemistry %+d\nPressure %+d"):format(card.chemistry or 0, card.pressure or 0)
    end
    return line
end

-- Layout of the card details panel: every block is placed under the previous one using the
-- real wrapped height of its text, so long names or narrow panels never overlap.
function Draw.cardDetailsLayout(card, w, h)
    local tw, y, elements = w - 20, 8, {}
    local function add(role, text, size, c, gap)
        local hgt = Draw.textHeight(text, tw, size)
        elements[#elements + 1] = { role = role, text = text, x = 10, y = y, w = tw, size = size, align = "left",
            color = c, h = hgt, bottom = h - 4 }
        y = y + hgt + (gap or 4)
    end
    add("name", card.name, 14, Palette.ink)
    add("type", rules.typeLabels[card.type] .. "  Tier " .. card.tier, 11, typeColor(card.type))
    add("stats", detailStats(card, tw), 11, Palette.ink, 6)
    add("action", card.action or card.flavor or "", 10, Palette.muted)
    if card.effect then
        local text = "Effect: " .. (EFFECT_LABELS[card.effect.kind] or card.effect.kind)
        if y + Draw.textHeight(text, tw, 10) <= h - 4 then add("effect", text, 10, Palette.warning) end
    end
    return elements
end

function Draw.cardDetails(cardId, x, y, w, h)
    if not cardId then return end
    Draw.panel(x, y, w, h, false)
    Draw.elements(Draw.cardDetailsLayout(Cards.get(cardId), w, h), x, y)
end

function Draw.portrait(dragon, x, y, w, h)
    local c = dragon.accent or Palette.muted
    Draw.panel(x, y, w, h, false)
    love.graphics.setScissor(x, y, w, h)
    love.graphics.setColor(c[1] * 0.18, c[2] * 0.18, c[3] * 0.18, 1)
    love.graphics.rectangle("fill", x + 4, y + 4, w - 8, h - 8)

    local image = DragonPortraits.get(dragon)
    if image then
        -- Real art at integer 1x scale: the bust rests on the name area.
        local size = DragonPortraits.SIZE
        local px = x + math.floor((w - size) / 2)
        local py = math.max(y + 4, y + h - 29 - size)
        color(c, 0.90)
        love.graphics.rectangle("fill", x + 4, py + size - 1, w - 8, 1)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(image, px, py)
    else
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
    end

    love.graphics.setScissor()
    Draw.text(dragon.name, x + 6, y + h - 27, w - 12, "center", 13, Palette.ink)
    Draw.text(dragon.title, x + 6, y + h - 13, w - 12, "center", 9, Palette.muted)
end

function Draw.footer(text)
    color(Palette.black, 0.88)
    love.graphics.rectangle("fill", 0, 364, 640, 36)
    Draw.text(text, 12, 374, 616, "center", 11, Palette.muted)
end

return Draw
