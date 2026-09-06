local activities = require("src.data.activities")

local ProgressionInputSystem = { name = "progressionInput" }

local function move(ui, amount)
    ui.cursor = (ui.cursor - 1 + amount) % #activities.order + 1
end

function ProgressionInputSystem.setup(scene)
    scene.registry:setResource("progressionUI", {
        cursor = 1,
        phase = "choosing",
        message = "Choose three activities before opening the weekly pack.",
    })
end

function ProgressionInputSystem.update(scene)
    local ui = scene.registry:resource("progressionUI")
    for _, event in scene.registry:each("keyPressed") do
        if ui.phase == "choosing" then
            if event.key == "left" or event.key == "up" then
                move(ui, -1)
            elseif event.key == "right" or event.key == "down" then
                move(ui, 1)
            elseif event.key == "return" or event.key == "space" then
                scene.registry:spawn({ activitySelected = true, id = activities.order[ui.cursor] })
            end
        elseif event.key == "return" or event.key == "space" then
            if ui.complete then
                scene.registry:spawn({ switchRequest = true, to = "pack" })
            else
                ui.phase = "choosing"
                ui.message = "Choose the next activity."
            end
        end
    end
end

return ProgressionInputSystem
