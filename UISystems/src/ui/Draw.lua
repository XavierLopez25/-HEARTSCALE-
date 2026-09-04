local Palette = require("src.ui.Palette")

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

return Draw
