local Collection = require("src.rules.Collection")
local rules = require("src.data.rules")
local Audio = require("src.core.Audio")

local PackInputSystem = { name = "packInput" }

local function selectedCount(state)
    local count = 0
    for _, marked in ipairs(state.selected) do
        if marked then count = count + 1 end
    end
    return count
end

local function move(state, amount)
    state.cursor = (state.cursor - 1 + amount) % #state.offer + 1
end

function PackInputSystem.update(scene, dt)
    local state = scene.registry:resource("packState")
    local runState = scene.registry:resource("runState")
    for _, event in scene.registry:each("keyPressed") do
        if event.key == "left" then
            move(state, -1)
            Audio.play("card")
        elseif event.key == "right" then
            move(state, 1)
            Audio.play("card")
        elseif event.key == "space" then
            Audio.play("card")
            local count = selectedCount(state)
            if state.selected[state.cursor] then
                state.selected[state.cursor] = false
            elseif count < rules.cardsToChoose then
                state.selected[state.cursor] = true
            end
        elseif event.key == "return" then
            if selectedCount(state) == rules.cardsToChoose then
                Audio.play("confirm")
                local chosen = {}
                for i, marked in ipairs(state.selected) do
                    if marked then chosen[#chosen + 1] = state.offer[i] end
                end
                runState.lastAcquired = Collection.addMany(runState.collection, chosen)
                scene.registry:spawn({ switchRequest = { to = "collection" } })
            else
                state.message = "Choose exactly two cards with Space."
            end
        end
    end
end

return PackInputSystem
