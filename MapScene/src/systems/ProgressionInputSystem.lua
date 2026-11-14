local activities = require("src.data.activities")
local Audio = require("src.core.Audio")

local ProgressionInputSystem = { name = "progressionInput" }

local function move(state, amount)
    state.cursor = (state.cursor - 1 + amount) % #activities.order + 1
end

function ProgressionInputSystem.update(scene, dt)
    local state = scene.registry:resource("progressionState")
    for _, event in scene.registry:each("keyPressed") do
        if state.phase == "choosing" then
            if event.key == "up" or event.key == "left" then
                move(state, -1)
                Audio.play("card")
            elseif event.key == "down" or event.key == "right" then
                move(state, 1)
                Audio.play("card")
            elseif event.key == "return" or event.key == "space" then
                Audio.play("confirm")
                scene.registry:spawn({
                    event = true,
                    activitySelected = { id = activities.order[state.cursor] },
                })
            end
        elseif state.phase == "feedback" then
            if event.key == "return" or event.key == "space" then
                Audio.play("confirm")
                if state.progressionComplete then
                    scene.registry:spawn({ switchRequest = { to = "pack" } })
                else
                    state.phase = "choosing"
                    state.message = "Choose the next activity."
                end
            end
        end
    end
end

return ProgressionInputSystem
