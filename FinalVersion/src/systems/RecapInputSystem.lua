local RunState = require("src.state.RunState")
local rules = require("src.data.rules")
local Audio = require("src.core.Audio")

local RecapInputSystem = { name = "recapInput" }

function RecapInputSystem.update(scene, dt)
    local runState = scene.registry:resource("runState")
    for _, event in scene.registry:each("keyPressed") do
        if event.key == "return" or event.key == "space" then
            Audio.play("confirm")
            if runState.week >= rules.maxWeeks then
                scene.registry:spawn({ switchRequest = { to = "ending" } })
            else
                RunState.startNextWeek(runState)
                scene.registry:spawn({ switchRequest = { to = "progression" } })
            end
        end
    end
end

return RecapInputSystem
