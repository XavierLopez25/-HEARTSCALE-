local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")

local TitleRenderSystem = { name = "titleRender" }

function TitleRenderSystem.draw(scene)
    local menu = scene.registry:resource("titleMenu")
    Draw.clear()

    Draw.text("HEARTSCALE", 0, 52, 640, "center", 36, Palette.ink)
    Draw.text("Train through the week. Turn experiences into cards. Learn to read the moment.", 116, 95, 408, "center", 12, Palette.muted)

    love.graphics.setColor(0.96, 0.31, 0.12, 0.9)
    love.graphics.rectangle("fill", 192, 130, 256, 4)
    love.graphics.setColor(0.14, 0.62, 0.91, 0.9)
    love.graphics.rectangle("fill", 242, 138, 156, 4)
    love.graphics.setColor(0.22, 0.78, 0.45, 0.9)
    love.graphics.rectangle("fill", 286, 146, 68, 4)

    for i, option in ipairs(menu.options) do
        Draw.button(option.label, 244, 222 + (i - 1) * 42, 152, 28, menu.cursor == i, Palette.warning)
    end

    Draw.footer("Arrows: move  |  Enter: confirm  |  F1: debug")
end

return TitleRenderSystem
