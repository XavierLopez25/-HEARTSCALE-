local DateInputSystem = { name = "dateInput" }
local Audio = require("src.core.Audio")

local function move(dateState, amount)
    if #dateState.hand == 0 then return end
    dateState.cursor = (dateState.cursor - 1 + amount) % #dateState.hand + 1
end

function DateInputSystem.update(scene, dt)
    local dateState = scene.registry:resource("dateState")
    for _, event in scene.registry:each("keyPressed") do
        if dateState.phase == "choosing" then
            if event.key == "left" then
                move(dateState, -1)
                Audio.play("card")
            elseif event.key == "right" then
                move(dateState, 1)
                Audio.play("card")
            elseif event.key == "m" then
                Audio.play("pressure")
                scene.registry:spawn({ event = true, mulliganRequested = {} })
            elseif event.key == "return" or event.key == "space" then
                Audio.play("confirm")
                scene.registry:spawn({
                    event = true,
                    cardPlayed = {
                        index = dateState.cursor,
                        cardId = dateState.hand[dateState.cursor],
                    },
                })
            end
        elseif dateState.phase == "feedback" or dateState.phase == "ended" then
            if event.key == "return" or event.key == "space" then
                Audio.play("confirm")
                scene.registry:spawn({ event = true, dateAdvanced = {} })
            end
        end
    end
end

return DateInputSystem
