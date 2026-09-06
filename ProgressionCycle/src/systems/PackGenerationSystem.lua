local RunState = require("src.state.RunState")
local CardGenerator = require("src.generation.CardGenerator")
local rules = require("src.data.rules")

local PackGenerationSystem = { name = "packGeneration" }

function PackGenerationSystem.setup(scene)
    local run = RunState.get()
    scene.registry:setResource("packUI", {
        offer = CardGenerator.offer(run, rules.packSize),
        selected = {},
        cursor = 1,
        message = "Stats influence this offer: Valor favors Challenge, Wit favors Wit, Empathy favors Connection.",
    })
end

return PackGenerationSystem
