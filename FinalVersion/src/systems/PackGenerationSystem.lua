local CardGenerator = require("src.generation.CardGenerator")

local PackGenerationSystem = { name = "packGeneration" }

local function generate(scene)
    local runState = scene.registry:resource("runState")
    local state = scene.registry:resource("packState")
    state.offer = CardGenerator.offer(runState)
    state.selected = {}
    state.cursor = 1
    state.message = "Choose two cards from the weekly offer."
end

function PackGenerationSystem.setup(scene)
    local state = scene.registry:resource("packState")
    if #state.offer == 0 then generate(scene) end
end

function PackGenerationSystem.update(scene, dt)
    for _ in scene.registry:each("packRequested") do
        generate(scene)
    end
end

return PackGenerationSystem
