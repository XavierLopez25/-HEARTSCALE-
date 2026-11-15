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
    tier = 1,
    chemistry = 2,
    pressure = 1,
    tags = { "training", "challenge" },
    action = "You turn the moment into a friendly contest and invite her to meet you with the same energy.",
    flavor = "You make competition feel like an invitation.",
})

add({
    id = "one_more_rep",
    name = "One More Rep",
    type = "challenge",
    tier = 1,
    chemistry = 2,
    pressure = 0,
    tags = { "training", "grit" },
    effect = { kind = "if_pressure_at_least", threshold = 2, chemistry = 1 },
    action = "You suggest one more rep beside her, matching the effort without trying to dominate.",
    flavor = "A little exhaustion becomes a shared laugh.",
})

add({
    id = "bold_question",
    name = "Bold Question",
    type = "challenge",
    tier = 1,
    chemistry = 2,
    pressure = 1,
    tags = { "challenge", "direct" },
    action = "You ask directly instead of circling what you mean.",
    flavor = "You ask the thing everyone else avoids.",
})

add({
    id = "steady_challenge",
    name = "Steady Challenge",
    type = "challenge",
    tier = 1,
    chemistry = 1,
    pressure = 0,
    tags = { "training", "direct" },
    effect = { kind = "if_mood", mood = "competitive", chemistry = 1 },
    action = "You set a clear challenge, calm enough that it does not sound like showing off.",
    flavor = "No boasting. Just a clear line on the floor.",
})

add({
    id = "read_the_stance",
    name = "Read the Stance",
    type = "wit",
    tier = 1,
    chemistry = 1,
    pressure = 0,
    tags = { "study", "observation" },
    effect = { kind = "reveal_next_mood" },
    action = "You watch her stance and adjust the rhythm before the conversation tightens.",
    flavor = "You notice the shift before it lands.",
})

add({
    id = "dry_joke",
    name = "Dry Joke",
    type = "wit",
    tier = 1,
    chemistry = 2,
    pressure = 0,
    tags = { "humor", "observation" },
    effect = { kind = "if_mood", mood = "playful", chemistry = 1 },
    action = "You answer the tension with a dry joke and wait to see if it lands.",
    flavor = "The joke lands half a second late, which makes it better.",
})

add({
    id = "quick_observation",
    name = "Quick Observation",
    type = "wit",
    tier = 1,
    chemistry = 2,
    pressure = 0,
    tags = { "study", "observation" },
    action = "You point out one small detail everyone else missed.",
    flavor = "You notice what changed and say only what matters.",
})

add({
    id = "clever_pivot",
    name = "Clever Pivot",
    type = "wit",
    tier = 1,
    chemistry = 1,
    pressure = -1,
    tags = { "strategy", "humor" },
    action = "You redirect the topic carefully before the pressure hardens.",
    flavor = "The subject turns before tension settles in.",
})

add({
    id = "spotter",
    name = "Spotter",
    type = "connection",
    tier = 1,
    chemistry = 1,
    pressure = -2,
    tags = { "training", "support" },
    action = "You step close enough to support her next effort and make it clear she does not have to carry it alone.",
    flavor = "You make it clear she does not have to do this alone.",
})

add({
    id = "listen_first",
    name = "Listen First",
    type = "connection",
    tier = 1,
    chemistry = 1,
    pressure = -1,
    tags = { "care", "support" },
    effect = { kind = "next_card_chemistry", amount = 1 },
    action = "You stop trying to impress her and give her room to finish the thought.",
    flavor = "You give the next moment a softer place to land.",
})

add({
    id = "gentle_check_in",
    name = "Gentle Check-In",
    type = "connection",
    tier = 1,
    chemistry = 1,
    pressure = -1,
    tags = { "care", "guild" },
    action = "You ask if she actually wants help before moving any closer.",
    flavor = "One small question proves you are paying attention.",
})

add({
    id = "shared_laugh",
    name = "Shared Laugh",
    type = "connection",
    tier = 1,
    chemistry = 2,
    pressure = 0,
    tags = { "humor", "support" },
    effect = { kind = "if_mood", mood = "playful", chemistry = 1 },
    action = "You laugh with her, not at her, and let the moment stay light.",
    flavor = "The laugh is small, honest, and mutual.",
})

add({
    id = "call_her_bluff",
    name = "Call Her Bluff",
    type = "challenge",
    tier = 2,
    chemistry = 3,
    pressure = 1,
    tags = { "challenge", "direct" },
    effect = { kind = "if_mood", mood = "competitive", chemistry = 1 },
    action = "You call her bluff with a smile, just bold enough to make it fun.",
    flavor = "You smile like you already saw the trick.",
})

add({
    id = "flex_back",
    name = "Flex Back",
    type = "challenge",
    tier = 2,
    chemistry = 0,
    pressure = 0,
    tags = { "training", "risk" },
    risky = {
        chance = 0.75,
        success = { chemistry = 4, pressure = 0 },
        fail = { chemistry = 0, pressure = 2 },
    },
    action = "You try to match her confidence with a physical, risky show of nerve.",
    flavor = "You try to keep pace before thinking too hard.",
})

add({
    id = "bet_you_cant",
    name = "Bet You Can't",
    type = "challenge",
    tier = 2,
    chemistry = 0,
    pressure = 0,
    tags = { "challenge", "risk" },
    risky = {
        chance = 0.70,
        success = { chemistry = 3, pressure = 1 },
        fail = { chemistry = 0, pressure = 2 },
    },
    action = "You make a playful bet and put your pride on the table.",
    flavor = "It is a terrible idea, which is why it might work.",
})

add({
    id = "read_the_room",
    name = "Read the Room",
    type = "wit",
    tier = 2,
    chemistry = 1,
    pressure = 0,
    tags = { "study", "observation" },
    effect = { kind = "reveal_next_mood" },
    action = "You slow down and read the room before committing to the next move.",
    flavor = "You let the next beat reveal itself.",
})

add({
    id = "perfect_timing",
    name = "Perfect Timing",
    type = "wit",
    tier = 2,
    chemistry = 1,
    pressure = 0,
    tags = { "strategy", "humor" },
    effect = { kind = "previous_type_different", different = 3, same = 1 },
    action = "You change the rhythm exactly when the conversation needs it.",
    flavor = "You shift the beat at the exact right moment.",
})

add({
    id = "learned_pattern",
    name = "Learned Pattern",
    type = "wit",
    tier = 2,
    chemistry = 2,
    pressure = 0,
    tags = { "study", "strategy" },
    effect = { kind = "if_mood", mood = "curious", chemistry = 1 },
    action = "You connect this moment to a pattern you studied earlier.",
    flavor = "The conversation becomes a shared puzzle.",
})

add({
    id = "im_listening",
    name = "I'm Listening",
    type = "connection",
    tier = 2,
    chemistry = 2,
    pressure = -1,
    tags = { "care", "support" },
    effect = { kind = "if_mood", mood = "vulnerable", chemistry = 2 },
    action = "You hear what she is not saying and answer that part first.",
    flavor = "You respond to the feeling, not just the words.",
})

add({
    id = "take_a_breath_card",
    name = "Take a Breath",
    type = "connection",
    tier = 2,
    chemistry = 0,
    pressure = -3,
    tags = { "care", "calm" },
    action = "You pause the push and pull and let both of you breathe.",
    flavor = "Nothing clever. Just space.",
})

add({
    id = "warm_presence",
    name = "Warm Presence",
    type = "connection",
    tier = 2,
    chemistry = 2,
    pressure = -2,
    tags = { "guild", "care" },
    action = "You stay present without crowding her, steady enough to lean on.",
    flavor = "You stay close without pushing.",
})

add({
    id = "forge_a_promise",
    name = "Forge a Promise",
    type = "challenge",
    tier = 3,
    chemistry = 4,
    pressure = 2,
    tags = { "challenge", "guild" },
    action = "You make a bold promise and accept the heat that comes with saying it out loud.",
    flavor = "The line is intense because you mean it.",
})

add({
    id = "glorious_dare",
    name = "Glorious Dare",
    type = "challenge",
    tier = 3,
    chemistry = 0,
    pressure = 0,
    tags = { "challenge", "risk" },
    risky = {
        chance = 0.60,
        success = { chemistry = 5, pressure = 1 },
        fail = { chemistry = 0, pressure = 3 },
    },
    action = "You attempt a daring move that will either impress her or leave the room silent.",
    flavor = "This will be legendary or very educational.",
})

add({
    id = "remember_that",
    name = "Remember That?",
    type = "wit",
    tier = 3,
    chemistry = 2,
    pressure = 0,
    tags = { "study", "guild", "observation" },
    effect = { kind = "tag_match_week", chemistry = 2 },
    action = "You bring up something from the week that proves you were paying attention.",
    flavor = "A detail from the week returns at the perfect moment.",
})

add({
    id = "read_between_lines",
    name = "Read Between Lines",
    type = "wit",
    tier = 3,
    chemistry = 3,
    pressure = 0,
    tags = { "study", "observation" },
    effect = { kind = "reveal_next_mood" },
    action = "You notice the feeling under her words and name it carefully.",
    flavor = "You hear what the pause is doing.",
})

add({
    id = "you_dont_have_to_prove_it",
    name = "You Don't Have to Prove It",
    type = "connection",
    tier = 3,
    chemistry = 2,
    pressure = -2,
    tags = { "care", "support" },
    effect = { kind = "challenge_pressure_shield", amount = 1 },
    action = "You remind her she does not need to prove anything to be respected.",
    flavor = "The next challenge can be brave without becoming harsh.",
})

add({
    id = "safe_place_to_land",
    name = "Safe Place to Land",
    type = "connection",
    tier = 3,
    chemistry = 3,
    pressure = -3,
    tags = { "care", "trust" },
    action = "You make the conversation safe enough for honesty, not performative toughness.",
    flavor = "For a moment, no one has to pretend to be strong.",
})

function cards.get(id)
    return assert(cards.byId[id], "unknown card: " .. tostring(id))
end

function cards.each()
    local i = 0
    return function()
        i = i + 1
        local id = cards.order[i]
        if id then return cards.byId[id] end
    end
end

return cards
