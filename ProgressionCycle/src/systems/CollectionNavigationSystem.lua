local RunState = require("src.state.RunState")

local CollectionNavigationSystem = { name = "collectionNavigation" }

function CollectionNavigationSystem.setup(scene)
    scene.registry:setResource("collectionUI", { cursor = 1 })
end

function CollectionNavigationSystem.update(scene)
    local run = RunState.get()
    local ui = scene.registry:resource("collectionUI")
    if #run.collection == 0 then return end
    for _, event in scene.registry:each("keyPressed") do
        if event.key == "left" or event.key == "up" then
            ui.cursor = math.max(1, ui.cursor - 1)
        elseif event.key == "right" or event.key == "down" then
            ui.cursor = math.min(#run.collection, ui.cursor + 1)
        elseif event.key == "return" or event.key == "space" then
            run.week = run.week + 1
            run.actionsUsed = 0
            run.weeklyTags = {}
            run.lastAcquired = {}
            scene.registry:spawn({ switchRequest = true, to = "progression" })
        elseif event.key == "escape" then
            scene.registry:spawn({ switchRequest = true, to = "title" })
        end
    end
end

return CollectionNavigationSystem
