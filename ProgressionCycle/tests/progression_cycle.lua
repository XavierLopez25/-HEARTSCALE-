package.path = "./?.lua;" .. package.path

local RunState = require("src.state.RunState")
local CardGenerator = require("src.generation.CardGenerator")
local Collection = require("src.rules.Collection")

love = {
    math = {
        random = function(max) return max end,
    },
}

local run = RunState.reset()
run.stats.valor = 6
run.stats.wit = 0
run.stats.empathy = 0

local offer = CardGenerator.offer(run, 3)
assert(#offer == 3, "expected three offered cards")

local added = Collection.addMany(run.collection, { offer[1], offer[2] })
assert(#added == 2, "expected two cards added")
assert(#run.collection == 2, "collection should persist added cards")

print("progression cycle tests passed")
