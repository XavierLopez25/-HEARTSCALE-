local cards = {
    order = {},
    byId = {},
}

local function add(card)
    cards.order[#cards.order + 1] = card.id
    cards.byId[card.id] = card
end

add({
    id = "friendly_competition",
    name = "Friendly Competition",
    type = "challenge",
    value = 2,
    tags = { "training", "challenge" },
    effect = "Gain Chemistry when the mood is competitive.",
})

add({
    id = "one_more_rep",
    name = "One More Rep",
    type = "challenge",
    value = 2,
    tags = { "training" },
    effect = "Worth more if pressure is already high.",
})

add({
    id = "bold_question",
    name = "Bold Question",
    type = "challenge",
    value = 1,
    tags = { "direct" },
    effect = "Pushes the conversation forward.",
})

add({
    id = "read_the_stance",
    name = "Read the Stance",
    type = "wit",
    value = 1,
    tags = { "study", "observation" },
    effect = "Reveals what the next moment needs.",
})

add({
    id = "dry_joke",
    name = "Dry Joke",
    type = "wit",
    value = 2,
    tags = { "humor" },
    effect = "Works best when the mood is playful.",
})

add({
    id = "learned_pattern",
    name = "Learned Pattern",
    type = "wit",
    value = 2,
    tags = { "study", "strategy" },
    effect = "Benefits from study during the week.",
})

add({
    id = "spotter",
    name = "Spotter",
    type = "connection",
    value = 1,
    tags = { "training", "support" },
    effect = "Lowers pressure by showing support.",
})

add({
    id = "listen_first",
    name = "Listen First",
    type = "connection",
    value = 1,
    tags = { "care", "support" },
    effect = "Makes the next response land better.",
})

add({
    id = "warm_presence",
    name = "Warm Presence",
    type = "connection",
    value = 2,
    tags = { "care" },
    effect = "Creates room for honesty.",
})

function cards.get(id)
    return assert(cards.byId[id], "unknown card: " .. tostring(id))
end

function cards.byType(cardType)
    local list = {}
    for _, id in ipairs(cards.order) do
        local card = cards.byId[id]
        if card.type == cardType then list[#list + 1] = card end
    end
    return list
end

return cards
