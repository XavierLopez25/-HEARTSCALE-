local RunState = require("src.state.RunState")
local Audio = require("src.core.Audio")

local TitleInputSystem = { name = "titleInput" }

local function move(menu, amount)
    menu.cursor = (menu.cursor - 1 + amount) % #menu.options + 1
end

function TitleInputSystem.update(scene, dt)
    local menu = scene.registry:resource("titleMenu")
    for _, event in scene.registry:each("keyPressed") do
        if event.key == "up" or event.key == "left" then
            move(menu, -1)
            Audio.play("card")
        elseif event.key == "down" or event.key == "right" then
            move(menu, 1)
            Audio.play("card")
        elseif event.key == "return" or event.key == "space" then
            local option = menu.options[menu.cursor]
            Audio.play("confirm")
            if option.id == "new" then
                RunState.startNew(os.time() % 2147483648)
                scene.registry:spawn({ switchRequest = { to = "progression" } })
            elseif option.id == "quit" then
                love.event.quit()
            end
        end
    end
end

return TitleInputSystem
