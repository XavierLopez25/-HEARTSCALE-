local Rng = require("src.core.Rng")
local Cards = require("src.data.cards")
local rules = require("src.data.rules")
local Collection = require("src.rules.Collection")

local CardGenerator = {}

function CardGenerator.weights(stats)
    local weights = {}
    local total = 0
    for _, cardType in ipairs(rules.typeOrder) do
        local stat = rules.statForType[cardType]
        local value = math.max(0, stats[stat] or 0) + 1
        weights[cardType] = value
        total = total + value
    end
    return weights, total
end

function CardGenerator.maxTier(statValue)
    if statValue >= rules.tier3Stat then return 3 end
    if statValue >= rules.tier2Stat then return 2 end
    return 1
end

local function blockedSet(offer)
    local blocked = {}
    for _, id in ipairs(offer) do blocked[id] = true end
    return blocked
end

local function candidates(stats, owned, offer, requestedType)
    local blocked = blockedSet(offer)
    local result = {}
    for card in Cards.each() do
        local stat = rules.statForType[card.type]
        local maxTier = CardGenerator.maxTier(stats[stat] or 0)
        local typeOk = requestedType == nil or card.type == requestedType
        if typeOk and card.tier <= maxTier and not owned[card.id] and not blocked[card.id] then
            result[#result + 1] = card.id
        end
    end
    return result
end

local function relaxedCandidates(owned, offer)
    local blocked = blockedSet(offer)
    local result = {}
    for card in Cards.each() do
        if not owned[card.id] and not blocked[card.id] then
            result[#result + 1] = card.id
        end
    end
    return result
end

function CardGenerator.offer(runState, count)
    count = count or rules.packSize
    local offer = {}
    local owned = Collection.ownedSet(runState.collection)
    local weights = CardGenerator.weights(runState.stats)

    while #offer < count do
        local cardType = Rng.pickWeighted(runState, weights, rules.typeOrder)
        local pool = candidates(runState.stats, owned, offer, cardType)
        if #pool == 0 then
            pool = candidates(runState.stats, owned, offer, nil)
        end
        if #pool == 0 then
            pool = relaxedCandidates(owned, offer)
        end
        if #pool == 0 then break end
        offer[#offer + 1] = Rng.pick(runState, pool)
    end

    return offer
end

return CardGenerator
