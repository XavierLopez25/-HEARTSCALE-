local dragons = require("src.data.dragons")
local rules = require("src.data.rules")
local Audio = require("src.core.Audio")
local dialogue = require("src.data.dialogue")

local EndingInputSystem = { name = "endingInput" }

local function countOptions()
    return #dragons.order + 1
end

local function move(state, amount)
    state.cursor = (state.cursor - 1 + amount) % countOptions() + 1
end

function EndingInputSystem.update(scene, dt)
    local state = scene.registry:resource("endingState")
    local runState = scene.registry:resource("runState")
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
                local dragonId = dragons.order[state.cursor]
                if not dragonId then
                    state.phase = "result"
                    state.outcome = "neutral"
                    state.message = dialogue.neutralEnding
                elseif (runState.affection[dragonId] or 0) >= rules.romanceAffection then
                    state.phase = "result"
                    state.outcome = "romance"
                    state.dragonId = dragonId
                    state.message = dragons[dragonId].ending
                else
                    state.phase = "result"
                    state.outcome = "friendly"
                    state.dragonId = dragonId
                    state.message = dialogue.friendlyEnding:format(dragons[dragonId].name)
                end
                runState.gameCompleted = true
            end
        elseif state.phase == "result" then
            if event.key == "return" or event.key == "space" then
                Audio.play("confirm")
                scene.registry:spawn({ switchRequest = { to = "title" } })
            end
        end
    end
end

return EndingInputSystem
