local RunState = require("src.state.RunState")
local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")

local MainMenuUISystem = { name = "mainMenuUI" }

local function move(menu, amount)
    menu.cursor = (menu.cursor - 1 + amount) % #menu.buttons + 1
end

function MainMenuUISystem.setup(scene)
    scene.registry:setResource("mainMenuUI", {
        cursor = 1,
        buttons = {
            { label = "Start", action = "start" },
            { label = "Credits", action = "credits" },
            { label = "Quit", action = "quit" },
        },
        message = "Choose a UI flow to preview.",
    })
end

function MainMenuUISystem.update(scene)
    local menu = scene.registry:resource("mainMenuUI")
    for _, event in scene.registry:each("keyPressed") do
        if event.key == "up" or event.key == "left" then
            move(menu, -1)
        elseif event.key == "down" or event.key == "right" then
            move(menu, 1)
        elseif event.key == "return" or event.key == "space" then
            local action = menu.buttons[menu.cursor].action
            if action == "start" then
                RunState.reset()
                scene.registry:spawn({ switchRequest = true, to = "dragonSelect" })
            elseif action == "credits" then
                menu.message = "Heartscale UI prototype - built with Lua, LÖVE2D, and ECS."
            elseif action == "quit" then
                love.event.quit()
            end
        end
    end
end

function MainMenuUISystem.draw(scene)
    local menu = scene.registry:resource("mainMenuUI")
    Draw.clear()
    Draw.text("HEARTSCALE", 0, 58, 640, "center", 36)
    Draw.text("UI Systems Prototype", 0, 98, 640, "center", 13, Palette.warning)
    Draw.panel(196, 138, 248, 142)
    for i, button in ipairs(menu.buttons) do
        Draw.button(button.label, 244, 158 + (i - 1) * 36, 152, 26, menu.cursor == i, Palette.warning)
    end
    Draw.text(menu.message, 140, 304, 360, "center", 11, Palette.muted)
    Draw.footer("Arrows: move  |  Enter: confirm")
end

return MainMenuUISystem
