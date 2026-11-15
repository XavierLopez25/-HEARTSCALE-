local rules = require("src.data.rules")
local Cards = require("src.data.cards")
local MoodGenerator = require("src.generation.MoodGenerator")
local HandGenerator = require("src.generation.HandGenerator")
local CardResolver = require("src.rules.CardResolver")
local Relationship = require("src.rules.Relationship")
local Audio = require("src.core.Audio")
local DateDialogue = require("src.data.date_dialogue")

local DateStateSystem = { name = "dateState" }

local function chooseMood(runState, dateState)
    if dateState.queuedMood then
        dateState.currentMood = dateState.queuedMood
        dateState.queuedMood = nil
        dateState.previewMood = nil
    else
        dateState.currentMood = MoodGenerator.select(runState, dateState.dragonId)
    end
end

local function finishDate(runState, dateState, reason)
    if dateState.finished then return end
    dateState.finished = true
    dateState.phase = "ended"
    runState.lastDate = Relationship.apply(
        runState,
        dateState.dragonId,
        dateState.chemistry,
        dateState.pressure)
    dateState.feedback = ("%s\nChemistry %d  Pressure %d\nAffection %+d")
        :format(
            runState.lastDate.label,
            dateState.chemistry,
            dateState.pressure,
            runState.lastDate.affectionDelta)
    if reason then
        dateState.feedback = reason .. "\n" .. dateState.feedback
    end
end

local function discardSet(dateState, includeHand)
    local avoid = {}
    for _, id in ipairs(dateState.discard) do avoid[id] = true end
    if includeHand then
        for _, id in ipairs(dateState.hand) do avoid[id] = true end
    end
    return avoid
end

function DateStateSystem.setup(scene)
    local runState = scene.registry:resource("runState")
    local dateState = scene.registry:resource("dateState")
    chooseMood(runState, dateState)
end

function DateStateSystem.update(scene, dt)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local dateState = registry:resource("dateState")

    for _ in registry:each("mulliganRequested") do
        if dateState.mulliganUsed then
            dateState.feedback = "You already used Take a Breath on this date."
            dateState.phase = "feedback"
            dateState.awaitingNextExchange = false
        else
            dateState.mulliganUsed = true
            dateState.pressure = math.min(dateState.maxPressure, dateState.pressure + 1)
            if dateState.pressure >= dateState.maxPressure then
                finishDate(runState, dateState, "The extra pressure was too much.")
            else
                dateState.hand = HandGenerator.drawAvoiding(
                    runState.collection,
                    rules.handSize,
                    runState,
                    discardSet(dateState, true))
                dateState.cursor = 1
                dateState.feedback = "Take a Breath: new hand, Pressure +1."
                dateState.phase = "feedback"
                dateState.awaitingNextExchange = false
            end
        end
    end

    for _, play in registry:each("cardPlayed") do
        if not play.cardId then return end
        local cardId = table.remove(dateState.hand, play.index)
        dateState.discard[#dateState.discard + 1] = cardId
        local result = CardResolver.resolve(runState, dateState, cardId)
        local card = Cards.get(cardId)
        if result.riskRolled then
            Audio.play(result.riskSuccess and "riskSuccess" or "riskFail")
        elseif result.appliedPressure > 0 then
            Audio.play("pressure")
        elseif result.appliedChemistry > 0 then
            Audio.play("chemistry")
        else
            Audio.play("card")
        end

        local notes = table.concat(result.notes, " | ")
        if notes == "" then notes = "No special modifier." end
        dateState.feedback = ("%s\n%s\n%s\nC%+d P%+d  %s")
            :format(
                card.name,
                DateDialogue.action(cardId),
                DateDialogue.reaction(dateState.dragonId, cardId, dateState.currentMood, result, dateState),
                result.appliedChemistry,
                result.appliedPressure,
                notes)
        dateState.phase = "feedback"
        dateState.awaitingNextExchange = true
        dateState.cursor = math.max(1, math.min(dateState.cursor, #dateState.hand))

        if dateState.pressure >= dateState.maxPressure then
            finishDate(runState, dateState, "Pressure reached the limit.")
        elseif dateState.exchange >= dateState.maxExchanges then
            finishDate(runState, dateState)
        end
    end

    for _ in registry:each("dateAdvanced") do
        if dateState.phase == "ended" then
            registry:spawn({ switchRequest = { to = "recap" } })
        elseif dateState.phase == "feedback" then
            if dateState.awaitingNextExchange then
                dateState.exchange = dateState.exchange + 1
                chooseMood(runState, dateState)
                dateState.awaitingNextExchange = false
            end
            dateState.phase = "choosing"
        end
    end
end

return DateStateSystem
