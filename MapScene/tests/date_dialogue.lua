package.path = "./?.lua;" .. package.path

local DateDialogue = require("src.data.date_dialogue")
local RunState = require("src.state.RunState")
local CardResolver = require("src.rules.CardResolver")

local run = RunState.new(10)
local dateState = {
    dragonId = "kaela",
    currentMood = "playful",
    exchange = 1,
    maxExchanges = 5,
    chemistry = 0,
    pressure = 0,
    maxPressure = 6,
    effects = { nextChemistry = 0, challengePressureShield = 0 },
    insight = 0,
    challengeChain = 0,
    usedTypes = {},
}

local result = CardResolver.resolve(run, dateState, "spotter")
local reaction = DateDialogue.reaction("kaela", "spotter", "playful", result, dateState)

assert(reaction:find("Count my reps", 1, true), "Kaela Spotter reaction should be support-specific")
assert(not reaction:find("Risky", 1, true), "Spotter should not use risky/playful text")
assert(DateDialogue.cue("kaela", "playful"):find("heavy hammer", 1, true), "Kaela playful cue should describe pre-card mood")

print("date dialogue tests passed")
