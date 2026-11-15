local cards = require("src.data.cards")
local dragons = require("src.data.dragons")

local dateDialogue = {}

dateDialogue.kaela = {
    cues = {
        competitive = "Kaela marks another set against the anvil. She is not working; she is daring you to train with her.",
        curious = "Kaela lowers the hammer and studies your stance. She wants to know if you understand technique, not just force.",
        vulnerable = "The forge heat dips a little. Kaela adjusts her gloves so she does not have to look straight at what she feels.",
        playful = "Kaela grins through the sparks and offers you the heavy hammer. She is baiting you into doing something interesting.",
        relaxed = "The coals settle into a low glow. Kaela drops her shoulders and lets the rest count as training too.",
    },
    typeReactions = {
        challenge = {
            default = "Kaela accepts the challenge with a clean strike on the anvil. \"There you are. Back straight. Again.\"",
            highPressure = "Kaela smiles, then notices you forcing too hard. \"Careful. I want fire, not smoke.\"",
            chainTooHigh = "Her smile sharpens. \"Brute force again? Show me you know how to pace yourself.\"",
        },
        wit = {
            default = "Kaela narrows her eyes and adjusts your grip. \"Annoyingly clever. Keep going.\"",
            curious = "\"Hm.\" She sets the hammer aside. \"That does explain why the strike kept twisting.\"",
        },
        connection = {
            default = "Kaela looks away, but lets you support the set. \"Fine. But do not baby me.\"",
            vulnerable = "Her jaw tightens, though she does not move away. \"You noticed. Do not make me regret that.\"",
        },
    },
    cardReactions = {
        spotter = "She starts to reject the help, then stops herself. \"Fine. Count my reps. If you get in the way, I carry you out.\"",
        listen_first = "\"Are you just standing there listening to my breathing?\" Her voice softens before she can harden it.",
        gentle_check_in = "\"Asking before helping. That is new.\" She pretends to inspect the anvil instead of looking at you.",
        take_a_breath_card = "Kaela huffs, but lowers the hammer. \"One breath. Then we keep going.\"",
        im_listening = "Kaela lets the silence last a full set. \"You are actually listening. That changes the weight.\"",
        warm_presence = "She does not say thank you. She just shifts the bench so you can stay close while she catches her breath.",
        you_dont_have_to_prove_it = "The words hit harder than the hammer. Kaela looks into the coals and murmurs, \"...I know.\"",
        safe_place_to_land = "She exhales through her nose and loosens her shoulders. \"Do not tell anyone I needed to slow down.\"",

        dry_joke = "The forge goes quiet. Then Kaela lets out a rough laugh. \"Terrible. Do it again.\"",
        read_the_stance = "Her tail goes still when you correct your posture in time. \"Observant. Annoyingly observant.\"",
        quick_observation = "Kaela looks at the point you noticed in her grip. \"Small detail. Big difference. Good eye.\"",
        clever_pivot = "She accepts the shift in rhythm and returns to the anvil with less tension. \"That was elegant. Do not get used to it.\"",
        read_the_room = "\"You read a forge like a room too?\" She looks impressed despite herself. \"Useful trick.\"",
        perfect_timing = "Your timing makes her miss half a beat. \"That was technique or luck. I hate both.\"",
        learned_pattern = "\"You studied the strike pattern?\" Kaela folds her arms, amused. \"Good. Show me.\"",
        remember_that = "She remembers the detail a second after you say it. The smile she gives you is small, but real.",
        read_between_lines = "Kaela sets the hammer on the bench. \"Careful. If you read between the lines, you might find me there.\"",

        friendly_competition = "Kaela leans into the challenge, pleased that you turned it into shared training instead of showing off.",
        one_more_rep = "\"One more, then.\" She says it like a challenge, but steps closer so you can keep pace.",
        bold_question = "The direct question lands. Kaela raises an eyebrow. \"Brave question. Ready for the answer?\"",
        steady_challenge = "\"Good.\" She nods once. \"Challenge me like that: steady, not begging for applause.\"",
        call_her_bluff = "Kaela bursts into laughter. \"You caught the bluff? Maybe I was obvious on purpose.\"",
        shared_laugh = "She laughs with you when the hammer bounces wrong. \"Fine. That rep counts for neither of us.\"",
        forge_a_promise = "The promise heats the room more than the coals. \"Big words. I am going to remember them.\"",
    },
    riskyCards = {
        flex_back = {
            success = "You try to match her pace with the heavy hammer, and the strike lands clean. Kaela smiles. \"Risky. Well executed.\"",
            fail = "The hammer steals your balance. Kaela catches it before it falls. \"Risky does not mean careless. Again, with your head.\"",
        },
        bet_you_cant = {
            success = "She accepts the bet and raises the difficulty of the set. When you hold on, she laughs. \"Good. Now you are fun.\"",
            fail = "The bet outpaces you halfway through the set. Kaela shakes her head. \"Good fire. Bad technique.\"",
        },
        glorious_dare = {
            success = "The move lands through sparks and one perfect strike. Kaela needs a second to speak. \"That was absurd. Do it again.\"",
            fail = "The forge falls silent after the attempt. Kaela folds her arms. \"Legendary is useless if you end up on the floor.\"",
        },
    },
    risky = {
        success = "Kaela hits the anvil with a laugh. \"Risky. But you pulled it off.\"",
        fail = "Her smile turns into a raised eyebrow. \"That was risky. Own it and learn.\"",
    },
}

local fallbackCues = {
    competitive = "The moment turns competitive.",
    curious = "Curiosity takes over the conversation.",
    vulnerable = "The conversation grows more vulnerable.",
    playful = "The mood turns playful.",
    relaxed = "The pressure of the moment eases.",
}

local fallbackReactions = {
    challenge = "The challenge changes the rhythm of the date.",
    wit = "The observation gives the date a clearer angle.",
    connection = "The supportive gesture gives the moment more room.",
}

function dateDialogue.cue(dragonId, mood)
    local dragonDialogue = dateDialogue[dragonId]
    if dragonDialogue and dragonDialogue.cues[mood] then
        return dragonDialogue.cues[mood]
    end
    local dragon = dragons[dragonId]
    return dragon and dragon.quotes[mood] or fallbackCues[mood] or ""
end

function dateDialogue.action(cardId)
    local card = cards.get(cardId)
    return card.action or card.flavor or ""
end

function dateDialogue.reaction(dragonId, cardId, mood, result, dateState)
    local card = cards.get(cardId)
    local dragonDialogue = dateDialogue[dragonId]
    if not dragonDialogue then
        return fallbackReactions[card.type] or ""
    end

    if result.riskRolled and dragonDialogue.riskyCards and dragonDialogue.riskyCards[cardId] then
        local riskyCard = dragonDialogue.riskyCards[cardId]
        return result.riskSuccess and riskyCard.success or riskyCard.fail
    end

    if result.riskRolled and dragonDialogue.risky then
        return result.riskSuccess and dragonDialogue.risky.success
            or dragonDialogue.risky.fail
    end

    if dragonDialogue.cardReactions and dragonDialogue.cardReactions[cardId] then
        return dragonDialogue.cardReactions[cardId]
    end

    local typeData = dragonDialogue.typeReactions and dragonDialogue.typeReactions[card.type]
    if typeData then
        if card.type == "challenge" and (dateState.challengeChain or 0) >= 3 then
            return typeData.chainTooHigh or typeData.default
        end
        if result.appliedPressure and result.appliedPressure > 1 then
            return typeData.highPressure or typeData.default
        end
        return typeData[mood] or typeData.default
    end

    return fallbackReactions[card.type] or ""
end

return dateDialogue
