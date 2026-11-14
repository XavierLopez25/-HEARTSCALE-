local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")
local HandGenerator = require("src.generation.HandGenerator")
local rules = require("src.data.rules")

local DateInputSystem = require("src.systems.DateInputSystem")
local DateStateSystem = require("src.systems.DateStateSystem")
local DateRenderSystem = require("src.systems.DateRenderSystem")

return function(payload)
    local scene = Scene.new("date")
    local runState = RunState.get()
    runState.currentDragon = runState.currentDragon or "kaela"

    scene.registry:setResource("runState", runState)
    scene.registry:setResource("dateState", {
        dragonId = runState.currentDragon,
        phase = "choosing",
        exchange = 1,
        maxExchanges = rules.exchangesPerDate,
        chemistry = 0,
        pressure = 0,
        maxPressure = rules.maxPressure,
        hand = HandGenerator.draw(runState.collection, rules.handSize, runState),
        discard = {},
        cursor = 1,
        currentMood = nil,
        queuedMood = nil,
        previewMood = nil,
        feedback = "",
        mulliganUsed = false,
        awaitingNextExchange = false,
        finished = false,
        effects = {
            nextChemistry = 0,
            challengePressureShield = 0,
        },
        insight = 0,
        challengeChain = 0,
        usedTypes = {},
        lastCardType = nil,
        lastResolution = nil,
    })

    scene:addSystem(DateInputSystem)
    scene:addSystem(DateStateSystem)
    scene:addSystem(DateRenderSystem)
    return scene
end
