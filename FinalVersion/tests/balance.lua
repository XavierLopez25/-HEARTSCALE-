package.path = "./?.lua;" .. package.path

local simulator = require("src.debug.simulator")

local packs = simulator.packDistribution(2026, { valor = 6, wit = 2, empathy = 4 }, 3000)
assert(packs.challenge > packs.wit, "pack simulator should reflect higher valor than wit")
assert(packs.connection > packs.wit, "pack simulator should reflect higher empathy than wit")

local risk = simulator.riskyOutcomes(2026, "flex_back", 3000)
assert(math.abs(risk.observed - risk.expected) < 0.03,
    ("risky simulator drifted: %.3f vs %.3f"):format(risk.observed, risk.expected))

print("balance simulator tests passed")
