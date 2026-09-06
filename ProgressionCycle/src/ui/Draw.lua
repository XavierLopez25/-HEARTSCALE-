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

function Draw.text(value, x, y, w, align, size, c)
    love.graphics.setFont(font(size or 12))
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
        love.graphics.rectangle("fill", x, y + h - 4, w, 4)
    end
    Draw.text(label, x + 8, y + math.floor((h - 13) / 2), w - 16, "center", 12)
end

function Draw.footer(text)
    color(Palette.black, 0.88)
    love.graphics.rectangle("fill", 0, 364, 640, 36)
    Draw.text(text, 12, 374, 616, "center", 11, Palette.muted)
end

function Draw.portrait(dragon, x, y, w, h, selected)
    Draw.panel(x, y, w, h, selected)
    local c = dragon.accent
    love.graphics.setScissor(x, y, w, h)
    love.graphics.setColor(c[1] * 0.18, c[2] * 0.18, c[3] * 0.18, 1)
    love.graphics.rectangle("fill", x + 5, y + 5, w - 10, h - 10, 3, 3)
    love.graphics.setColor(c[1], c[2], c[3], 0.88)
    love.graphics.rectangle("fill", x + 16, y + 20, w - 32, h - 58, 4, 4)
    love.graphics.setColor(1, 1, 1, 0.12)
    love.graphics.rectangle("fill", x + 18, y + 22, w - 36, 10, 3, 3)
    love.graphics.setScissor()
    Draw.text(dragon.name, x + 6, y + h - 24, w - 12, "center", 13)
    Draw.text(dragon.title, x + 6, y + h - 11, w - 12, "center", 9, Palette.muted)
end

local function typeColor(cardType)
    if cardType == "challenge" then return { 0.96, 0.31, 0.12, 1 } end
    if cardType == "wit" then return { 0.22, 0.58, 0.94, 1 } end
    return { 0.22, 0.78, 0.45, 1 }
end

function Draw.card(cardId, x, y, w, h, selected, marked)
    local card = Cards.get(cardId)
    local c = typeColor(card.type)
    Draw.panel(x, y, w, h, selected or marked)
    love.graphics.setColor(c[1], c[2], c[3], 0.92)
    love.graphics.rectangle("fill", x, y, w, 16, 4, 4)
    love.graphics.rectangle("fill", x, y + 12, w, 4)
    if marked then
        love.graphics.setColor(1, 1, 1, 0.18)
        love.graphics.rectangle("fill", x + 4, y + 22, w - 8, h - 26, 2, 2)
    end
    Draw.text(card.name, x + 6, y + 26, w - 12, "center", 10)
    Draw.text(rules.typeLabels[card.type], x + 6, y + h - 34, w - 12, "center", 9, c)
    Draw.text("Value " .. card.value, x + 6, y + h - 18, w - 12, "center", 10, Palette.warning)
end

function Draw.cardDetails(cardId, x, y, w, h)
    if not cardId then return end
    local card = Cards.get(cardId)
    local c = typeColor(card.type)
    Draw.panel(x, y, w, h)
    Draw.text(card.name, x + 10, y + 10, w - 20, "left", 14)
    Draw.text(rules.typeLabels[card.type] .. "  Value " .. card.value, x + 10, y + 32, w - 20, "left", 11, c)
    Draw.text(card.effect, x + 10, y + 56, w - 20, "left", 10, Palette.muted)
end

return Draw
