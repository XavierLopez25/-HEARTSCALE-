local Cards = require("src.data.cards")
local rules = require("src.data.rules")

local CardGenerator = {}

local function ownedSet(collection)
    local owned = {}
    for _, id in ipairs(collection) do owned[id] = true end
    return owned
end

local function weightedType(runState)
    local total = 0
    local weights = {}
    for _, cardType in ipairs(rules.typeOrder) do
        local stat = rules.statForType[cardType]
        local weight = (runState.stats[stat] or 0) + 1
        weights[#weights + 1] = { type = cardType, weight = weight }
        total = total + weight
    end

    local roll = love.math.random(total)
    local cursor = 0
    for _, entry in ipairs(weights) do
        cursor = cursor + entry.weight
        if roll <= cursor then return entry.type end
    end
    return weights[#weights].type
end

local function addCandidatesByType(available, pickedSet, cardType, owned, allowOwned)
    local candidates = Cards.byType(cardType)
    for _, card in ipairs(candidates) do
        if not pickedSet[card.id] and (allowOwned or not owned[card.id]) then
            available[#available + 1] = card
        end
    end
end

local function addAnyCandidates(available, pickedSet, owned, allowOwned)
    for _, id in ipairs(Cards.order) do
        local card = Cards.get(id)
        if not pickedSet[id] and (allowOwned or not owned[id]) then
            available[#available + 1] = card
        end
    end
end

function CardGenerator.offer(runState, count)
    local owned = ownedSet(runState.collection)
    local picked = {}
    local pickedSet = {}

    while #picked < count do
        local cardType = weightedType(runState)
        local available = {}

        addCandidatesByType(available, pickedSet, cardType, owned, false)
        if #available == 0 then
            addAnyCandidates(available, pickedSet, owned, false)
        end
        if #available == 0 then
            addCandidatesByType(available, pickedSet, cardType, owned, true)
        end
        if #available == 0 then
            addAnyCandidates(available, pickedSet, owned, true)
        end
        if #available == 0 then break end

        local selected = available[love.math.random(#available)]
        picked[#picked + 1] = selected.id
        pickedSet[selected.id] = true
    end

    return picked
end

return CardGenerator
