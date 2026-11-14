local CollectionInputSystem = { name = "collectionInput" }
local Audio = require("src.core.Audio")

local function move(state, collection, amount)
    state.cursor = (state.cursor - 1 + amount) % #collection + 1
end

function CollectionInputSystem.update(scene, dt)
    local state = scene.registry:resource("collectionState")
    local runState = scene.registry:resource("runState")
    for _, event in scene.registry:each("keyPressed") do
        if event.key == "left" then
            move(state, runState.collection, -1)
            Audio.play("card")
        elseif event.key == "right" then
            move(state, runState.collection, 1)
            Audio.play("card")
        elseif event.key == "up" then
            move(state, runState.collection, -4)
            Audio.play("card")
        elseif event.key == "down" then
            move(state, runState.collection, 4)
            Audio.play("card")
        elseif event.key == "return" or event.key == "space" then
            Audio.play("confirm")
            scene.registry:spawn({ switchRequest = { to = "map" } })
        end
    end
end

return CollectionInputSystem
