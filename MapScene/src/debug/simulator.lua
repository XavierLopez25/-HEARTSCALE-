local RunState = require("src.state.RunState")
local Cards = require("src.data.cards")
local CardGenerator = require("src.generation.CardGenerator")
local HandGenerator = require("src.generation.HandGenerator")
local Rng = require("src.core.Rng")

local simulator = {}

function simulator.packDistribution(seed, stats, samples)
    local runState = RunState.new(seed or 1)
    runState.collection = {}
    runState.stats = stats or { valor = 6, wit = 2, empathy = 4 }

    local counts = { challenge = 0, wit = 0, connection = 0 }
    local ids = {}
    for _ = 1, samples or 10000 do
        local offer = CardGenerator.offer(runState, 1)
        local card = Cards.get(offer[1])
        counts[card.type] = counts[card.type] + 1
        ids[card.id] = (ids[card.id] or 0) + 1
    end
    return counts, ids
end

function simulator.handDistribution(seed, collection, samples)
    local runState = RunState.new(seed or 1)
    collection = collection or runState.collection

    local counts = { challenge = 0, wit = 0, connection = 0 }
    for _ = 1, samples or 10000 do
        local hand = HandGenerator.draw(collection, math.min(5, #collection), runState)
        for _, id in ipairs(hand) do
            counts[Cards.get(id).type] = counts[Cards.get(id).type] + 1
        end
    end
    return counts
end

function simulator.riskyOutcomes(seed, cardId, samples)
    local card = Cards.get(cardId)
    assert(card.risky, "card is not risky: " .. tostring(cardId))
    local runState = RunState.new(seed or 1)
    local success = 0
    for _ = 1, samples or 10000 do
        if Rng.chance(runState, card.risky.chance) then success = success + 1 end
    end
    return {
        success = success,
        fail = (samples or 10000) - success,
        expected = card.risky.chance,
        observed = success / (samples or 10000),
    }
end

return simulator
