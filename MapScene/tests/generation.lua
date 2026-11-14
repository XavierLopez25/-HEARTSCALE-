package.path = "./?.lua;" .. package.path

local Cards = require("src.data.cards")
local rules = require("src.data.rules")
local RunState = require("src.state.RunState")
local CardGenerator = require("src.generation.CardGenerator")
local HandGenerator = require("src.generation.HandGenerator")
local Collection = require("src.rules.Collection")

local function assertEq(actual, expected, message)
    assert(actual == expected, (message or "assertEq failed") .. ": "
        .. tostring(actual) .. " ~= " .. tostring(expected))
end

local countsByTier = { 0, 0, 0 }
local countsByType = { challenge = 0, wit = 0, connection = 0 }
local seen = {}
for card in Cards.each() do
    assert(not seen[card.id], "duplicate card id " .. card.id)
    seen[card.id] = true
    countsByTier[card.tier] = countsByTier[card.tier] + 1
    countsByType[card.type] = countsByType[card.type] + 1
end

assertEq(#Cards.order, 27, "v1 card count")
assertEq(countsByTier[1], 12, "tier 1 count")
assertEq(countsByTier[2], 9, "tier 2 count")
assertEq(countsByTier[3], 6, "tier 3 count")
assertEq(countsByType.challenge, 9, "challenge count")
assertEq(countsByType.wit, 9, "wit count")
assertEq(countsByType.connection, 9, "connection count")

local firstRun = RunState.new(123)
assertEq(#firstRun.collection, 6, "initial collection")
for _, id in ipairs(firstRun.collection) do
    Cards.get(id)
end

local low = RunState.new(1001)
low.collection = {}
low.stats = { valor = 1, wit = 1, empathy = 1 }
local offer = CardGenerator.offer(low, rules.packSize)
assertEq(#offer, 3, "low-stat offer size")
local offerSeen = {}
for _, id in ipairs(offer) do
    local card = Cards.get(id)
    assert(card.tier <= 1, "low stats generated tier " .. card.tier)
    assert(not offerSeen[id], "offer duplicated " .. id)
    offerSeen[id] = true
end

local owned = RunState.new(55)
owned.collection = { "friendly_competition", "one_more_rep", "read_the_stance" }
owned.stats = { valor = 9, wit = 9, empathy = 9 }
local filteredOffer = CardGenerator.offer(owned, 3)
for _, id in ipairs(filteredOffer) do
    assert(not Collection.has(owned.collection, id), "offer contained owned card " .. id)
end

local specialist = RunState.new(77)
specialist.collection = {}
specialist.stats = { valor = 9, wit = 1, empathy = 1 }
local samples = { challenge = 0, wit = 0, connection = 0 }
for _ = 1, 3000 do
    local cardId = CardGenerator.offer(specialist, 1)[1]
    samples[Cards.get(cardId).type] = samples[Cards.get(cardId).type] + 1
end
assert(samples.challenge > samples.wit * 3, "valor specialist did not favor challenge enough")
assert(samples.challenge > samples.connection * 3, "valor specialist did not favor challenge enough")

local collection = {
    "friendly_competition",
    "one_more_rep",
    "read_the_stance",
    "dry_joke",
    "spotter",
    "listen_first",
}
local before = table.concat(collection, ",")
local handRun = RunState.new(96)
local hand = HandGenerator.draw(collection, 5, handRun)
assertEq(#hand, 5, "hand size")
local handSeen = {}
for _, id in ipairs(hand) do
    assert(not handSeen[id], "hand duplicated " .. id)
    handSeen[id] = true
end
assertEq(table.concat(collection, ","), before, "hand draw mutated collection")

print("generation tests passed")
