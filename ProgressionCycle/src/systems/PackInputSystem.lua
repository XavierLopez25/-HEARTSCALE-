local RunState = require("src.state.RunState")
local Collection = require("src.rules.Collection")
local rules = require("src.data.rules")

local PackInputSystem = { name = "packInput" }

local function move(ui, amount)
    ui.cursor = (ui.cursor - 1 + amount) % #ui.offer + 1
end

local function selectedIds(ui)
    local ids = {}
    for i = 1, #ui.offer do
        local marked = ui.selected[i]
        if marked then ids[#ids + 1] = ui.offer[i] end
    end
    return ids
end

function PackInputSystem.update(scene)
    local ui = scene.registry:resource("packUI")
    local run = RunState.get()
    for _, event in scene.registry:each("keyPressed") do
        if event.key == "left" or event.key == "up" then
            move(ui, -1)
        elseif event.key == "right" or event.key == "down" then
            move(ui, 1)
        elseif event.key == "space" then
            ui.selected[ui.cursor] = not ui.selected[ui.cursor]
        elseif event.key == "return" then
            local ids = selectedIds(ui)
            if #ids == rules.cardsToChoose then
                run.lastAcquired = Collection.addMany(run.collection, ids)
                scene.registry:spawn({ switchRequest = true, to = "collection" })
            else
                ui.message = "Choose exactly two cards with Space."
            end
        end
    end
end

return PackInputSystem
