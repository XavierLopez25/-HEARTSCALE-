package.path = "./?.lua;" .. package.path

love = {
    math = {
        random = function(max) return max end,
    },
    event = {
        quit = function() end,
    },
}

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")
local ProgressionInputSystem = require("src.systems.ProgressionInputSystem")
local ProgressionLogicSystem = require("src.systems.ProgressionLogicSystem")
local PackInputSystem = require("src.systems.PackInputSystem")
local Cards = require("src.data.cards")
local CardGenerator = require("src.generation.CardGenerator")

local progression = Scene.new("progression")
RunState.reset()
progression:addSystem(ProgressionInputSystem)
progression:addSystem(ProgressionLogicSystem)
progression:setup()
progression.registry:spawn({ keyPressed = true, key = "return" })
progression:update(0)
progression:update(0)
local run = RunState.get()
assert(run.actionsUsed == 1, "activity should be applied once per key press")
assert(run.stats.valor == 2, "forge training should add Valor once")

local pack = Scene.new("pack")
pack.registry:setResource("packUI", {
    offer = { "friendly_competition", "read_the_stance", "spotter" },
    selected = {},
    cursor = 1,
    message = "",
})
pack:addSystem(PackInputSystem)
pack:setup()
pack.registry:spawn({ keyPressed = true, key = "space" })
pack:update(0)
pack.registry:spawn({ keyPressed = true, key = "right" })
pack:update(0)
pack.registry:spawn({ keyPressed = true, key = "right" })
pack:update(0)
pack.registry:spawn({ keyPressed = true, key = "space" })
pack:update(0)
pack.registry:spawn({ keyPressed = true, key = "return" })
pack:update(0)
assert(#run.collection == 2, "cards 1 and 3 should count as two selected cards")

local nearlyComplete = RunState.reset()
for i = 1, #Cards.order - 1 do
    nearlyComplete.collection[#nearlyComplete.collection + 1] = Cards.order[i]
end
nearlyComplete.stats.valor = 14
nearlyComplete.stats.empathy = 14
local lateOffer = CardGenerator.offer(nearlyComplete, 3)
assert(#lateOffer == 3, "late-game offer should still contain three cards")

print("regression tests passed")
