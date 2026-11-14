package.path = "./?.lua;" .. package.path

local RunState = require("src.state.RunState")
local CardResolver = require("src.rules.CardResolver")
local Relationship = require("src.rules.Relationship")

local function assertEq(actual, expected, message)
    assert(actual == expected, (message or "assertEq failed") .. ": "
        .. tostring(actual) .. " ~= " .. tostring(expected))
end

local function date(dragonId, mood, pressure)
    return {
        dragonId = dragonId,
        currentMood = mood,
        exchange = 1,
        maxExchanges = 5,
        chemistry = 0,
        pressure = pressure or 0,
        maxPressure = 6,
        hand = {},
        discard = {},
        effects = { nextChemistry = 0, challengePressureShield = 0 },
        insight = 0,
        challengeChain = 0,
        usedTypes = {},
        lastCardType = nil,
    }
end

local run = RunState.new(1)
local kaela = date("kaela", "competitive", 0)
local first = CardResolver.resolve(run, kaela, "friendly_competition")
assertEq(first.appliedChemistry, 4, "kaela first challenge chemistry")
assertEq(first.appliedPressure, 1, "kaela first challenge pressure")

kaela.currentMood = "curious"
local second = CardResolver.resolve(run, kaela, "one_more_rep")
assertEq(second.appliedChemistry, 3, "kaela second challenge chemistry")
assertEq(second.appliedPressure, 1, "kaela second challenge pressure")

local veyra = date("veyra", "relaxed", 0)
local v1 = CardResolver.resolve(RunState.new(2), veyra, "spotter")
assertEq(v1.appliedChemistry, 2, "veyra first connection")
local v2 = CardResolver.resolve(RunState.new(3), veyra, "listen_first")
assertEq(v2.appliedChemistry, 1, "veyra repeated connection")

local nyxara = date("nyxara", "curious", 0)
local n1 = CardResolver.resolve(RunState.new(4), nyxara, "quick_observation")
assertEq(n1.appliedChemistry, 3, "nyxara wit with curious")
assertEq(nyxara.insight, 1, "nyxara insight gained")
nyxara.currentMood = "relaxed"
local n2 = CardResolver.resolve(RunState.new(5), nyxara, "spotter")
assertEq(n2.appliedChemistry, 2, "nyxara insight consumed")
assertEq(nyxara.insight, 0, "nyxara insight reset")

local aurelia = date("aurelia", "curious", 3)
local a1 = CardResolver.resolve(RunState.new(6), aurelia, "im_listening")
assertEq(a1.appliedPressure, -2, "aurelia extra connection pressure relief")

local riskyRun = RunState.new(1)
local a2 = CardResolver.resolve(riskyRun, date("aurelia", "curious", 0), "flex_back")
assert(a2.riskRolled and a2.riskSuccess, "seed 1 should make flex back succeed")
assertEq(a2.appliedChemistry, 4, "aurelia risky success chemistry")
assertEq(a2.appliedPressure, 1, "aurelia risky extra pressure")

local sarka = date("sarka", "playful", 3)
local s1 = CardResolver.resolve(RunState.new(1), sarka, "flex_back")
assertEq(s1.appliedChemistry, 7, "sarka pressure plus playful risky success")

local good = Relationship.resultFor(7, 5)
assertEq(good.id, "good", "good date threshold")
local great = Relationship.resultFor(10, 3)
assertEq(great.id, "great", "great date threshold")
local awkward = Relationship.resultFor(99, 6)
assertEq(awkward.id, "awkward", "awkward pressure threshold")

print("date resolution tests passed")
