local Cards = require("src.data.cards")
local dragons = require("src.data.dragons")
local moods = require("src.data.moods")
local rules = require("src.data.rules")
local Rng = require("src.core.Rng")
local MoodGenerator = require("src.generation.MoodGenerator")

local CardResolver = {}

local function hasWeeklyTag(runState, card)
    local weekly = runState.weeklyTags or {}
    for _, tag in ipairs(card.tags or {}) do
        if weekly[tag] then return true end
    end
    return false
end

local function applyActiveEffects(dateState, card, result)
    if (dateState.effects.nextChemistry or 0) > 0 then
        result.chemistry = result.chemistry + dateState.effects.nextChemistry
        result.notes[#result.notes + 1] = "Follow-up +"
            .. dateState.effects.nextChemistry .. " Chemistry"
        dateState.effects.nextChemistry = 0
    end

    if card.type == "challenge" and (dateState.effects.challengePressureShield or 0) > 0 then
        local blocked = math.min(dateState.effects.challengePressureShield, math.max(0, result.pressure))
        if blocked > 0 then
            result.pressure = result.pressure - blocked
            result.notes[#result.notes + 1] = "Challenge shield -" .. blocked .. " Pressure"
        end
        dateState.effects.challengePressureShield = 0
    end
end

local function applyCardEffect(runState, dateState, card, result)
    local effect = card.effect
    if not effect then return end

    if effect.kind == "if_pressure_at_least" then
        if dateState.pressure >= effect.threshold then
            result.chemistry = result.chemistry + effect.chemistry
            result.notes[#result.notes + 1] = "Pressure rhythm +" .. effect.chemistry
        end
    elseif effect.kind == "if_mood" then
        if dateState.currentMood == effect.mood then
            result.chemistry = result.chemistry + effect.chemistry
            result.notes[#result.notes + 1] = moods[effect.mood].label .. " bonus +" .. effect.chemistry
        end
    elseif effect.kind == "next_card_chemistry" then
        dateState.effects.nextChemistry = (dateState.effects.nextChemistry or 0) + effect.amount
        result.notes[#result.notes + 1] = "Next card +" .. effect.amount .. " Chemistry"
    elseif effect.kind == "previous_type_different" then
        if dateState.lastCardType and dateState.lastCardType ~= card.type then
            result.chemistry = result.chemistry + effect.different - (card.chemistry or 0)
            result.notes[#result.notes + 1] = "Different rhythm +" .. effect.different
        else
            result.chemistry = result.chemistry + effect.same - (card.chemistry or 0)
            result.notes[#result.notes + 1] = "Repeated rhythm +" .. effect.same
        end
    elseif effect.kind == "tag_match_week" then
        if hasWeeklyTag(runState, card) then
            result.chemistry = result.chemistry + effect.chemistry
            result.notes[#result.notes + 1] = "Weekly experience +" .. effect.chemistry
        end
    elseif effect.kind == "challenge_pressure_shield" then
        dateState.effects.challengePressureShield =
            (dateState.effects.challengePressureShield or 0) + effect.amount
        result.notes[#result.notes + 1] = "Next Challenge ignores " .. effect.amount .. " Pressure"
    elseif effect.kind == "reveal_next_mood" then
        if dateState.exchange < dateState.maxExchanges then
            dateState.queuedMood = dateState.queuedMood
                or MoodGenerator.select(runState, dateState.dragonId)
            dateState.previewMood = dateState.queuedMood
            result.notes[#result.notes + 1] = "Next mood revealed: " .. moods[dateState.previewMood].label
        end
    end
end

local function applyMood(dateState, card, result)
    local mood = dateState.currentMood
    if mood == "competitive" and card.type == "challenge" then
        result.chemistry = result.chemistry + 1
        result.notes[#result.notes + 1] = "Competitive mood +1"
    elseif mood == "curious" and card.type == "wit" then
        result.chemistry = result.chemistry + 1
        result.notes[#result.notes + 1] = "Curious mood +1"
    elseif mood == "vulnerable" then
        if card.type == "connection" then
            result.chemistry = result.chemistry + 2
            result.notes[#result.notes + 1] = "Vulnerable mood +2"
        elseif card.type == "challenge" then
            result.pressure = result.pressure + 1
            result.notes[#result.notes + 1] = "Vulnerable pressure +1"
        end
    elseif mood == "playful" and card.risky and result.riskSuccess then
        result.chemistry = result.chemistry + 1
        result.notes[#result.notes + 1] = "Playful risk +1"
    end
end

local function applyDragonRule(dateState, card, result)
    local dragon = dragons[dateState.dragonId]
    local passive = dragon.passive

    if passive == "kaela_challenge_chain" then
        if card.type == "challenge" then
            local chain = (dateState.challengeChain or 0) + 1
            if chain == 1 then
                result.chemistry = result.chemistry + 1
                result.notes[#result.notes + 1] = "Kaela respects the challenge +1"
            elseif chain == 2 then
                result.chemistry = result.chemistry + 1
                result.pressure = result.pressure + 1
                result.notes[#result.notes + 1] = "Kaela answers with force +1/+1"
            else
                result.pressure = result.pressure + 2
                result.notes[#result.notes + 1] = "Too much competition +2 Pressure"
            end
        end
    elseif passive == "veyra_first_each_type" then
        if not dateState.usedTypes[card.type] then
            result.chemistry = result.chemistry + 1
            result.notes[#result.notes + 1] = "Veyra rewards variety +1"
        end
    elseif passive == "sarka_pressure_bonus" then
        local inDangerZone = dateState.pressure >= 3 and dateState.pressure < dateState.maxPressure
        local successful = result.chemistry > 0 and (not card.risky or result.riskSuccess)
        if inDangerZone and successful then
            result.chemistry = result.chemistry + 1
            result.notes[#result.notes + 1] = "Sarka enjoys the edge +1"
            if card.risky and result.riskSuccess then
                result.chemistry = result.chemistry + 1
                result.notes[#result.notes + 1] = "Sarka loves the risk +1"
            end
        end
    elseif passive == "nyxara_insight" then
        if card.type == "wit" and (not card.risky or result.riskSuccess) then
            dateState.insight = math.min(2, (dateState.insight or 0) + 1)
            result.notes[#result.notes + 1] = "Insight " .. dateState.insight .. "/2"
        elseif card.type ~= "wit" and (dateState.insight or 0) > 0 then
            result.chemistry = result.chemistry + dateState.insight
            result.notes[#result.notes + 1] = "Nyxara insight +" .. dateState.insight
            dateState.insight = 0
        end
    elseif passive == "aurelia_pressure_control" then
        if card.type == "connection" then
            result.pressure = result.pressure - 1
            result.notes[#result.notes + 1] = "Aurelia relaxes -1 Pressure"
        end
        if card.risky then
            result.pressure = result.pressure + 1
            result.notes[#result.notes + 1] = "Risk unsettles Aurelia +1 Pressure"
        end
    end
end

local function applyRelaxedMood(dateState, result)
    if dateState.currentMood == "relaxed" and result.pressure > 0 then
        result.pressure = result.pressure - 1
        result.notes[#result.notes + 1] = "Relaxed mood -1 Pressure"
    end
end

local function riskyBase(runState, card, result)
    if not card.risky then return end
    result.riskRolled = true
    result.riskChance = card.risky.chance
    result.riskSuccess = Rng.chance(runState, card.risky.chance)
    local branch = result.riskSuccess and card.risky.success or card.risky.fail
    result.chemistry = branch.chemistry or 0
    result.pressure = branch.pressure or 0
    result.notes[#result.notes + 1] = result.riskSuccess and "Risky success" or "Risky fail"
end

function CardResolver.resolve(runState, dateState, cardId)
    local card = Cards.get(cardId)
    local result = {
        cardId = card.id,
        cardName = card.name,
        cardType = card.type,
        chemistry = card.chemistry or 0,
        pressure = card.pressure or 0,
        riskRolled = false,
        riskSuccess = nil,
        notes = {},
    }

    riskyBase(runState, card, result)
    applyMood(dateState, card, result)
    applyDragonRule(dateState, card, result)
    applyActiveEffects(dateState, card, result)
    applyCardEffect(runState, dateState, card, result)
    applyRelaxedMood(dateState, result)

    local beforeChemistry = dateState.chemistry
    local beforePressure = dateState.pressure
    dateState.chemistry = math.max(0, dateState.chemistry + result.chemistry)
    dateState.pressure = math.max(0, math.min(dateState.maxPressure, dateState.pressure + result.pressure))
    result.appliedChemistry = dateState.chemistry - beforeChemistry
    result.appliedPressure = dateState.pressure - beforePressure

    if card.type == "challenge" then
        dateState.challengeChain = (dateState.challengeChain or 0) + 1
    else
        dateState.challengeChain = 0
    end
    dateState.usedTypes[card.type] = true
    dateState.lastCardType = card.type
    dateState.lastResolution = result

    return result
end

return CardResolver
