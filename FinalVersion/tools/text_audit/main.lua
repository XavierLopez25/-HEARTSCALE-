-- Text-fit audit: checks that every string the game can show fits its box.
-- Run from FinalVersion/:   love tools/text_audit
-- It uses the game's own layouts (Draw.cardLayout, Draw.cardDetailsLayout,
-- DateRenderSystem.moodLayout) and the same fonts, simulates every dragon x mood x card x state
-- for the date feedback, and exits with code 1 if anything overflows or overlaps.
package.path = "./?.lua;" .. package.path

local failures, checks = {}, 0
local slots = {}

local function record(screen, slot, ok, detail)
    checks = checks + 1
    local key = screen .. " | " .. slot
    local s = slots[key] or { screen = screen, slot = slot, total = 0, failed = 0 }
    slots[key] = s
    s.total = s.total + 1
    if not ok then
        s.failed = s.failed + 1
        if s.failed <= 3 then failures[#failures + 1] = ("%s | %s: %s"):format(screen, slot, detail) end
    end
end

-- Elements must stay inside their bottom limit and must not overlap the next block in the column.
local function checkLayout(screen, slot, elements, height)
    local sorted = {}
    for _, e in ipairs(elements) do sorted[#sorted + 1] = e end
    table.sort(sorted, function(a, b) return a.y < b.y end)
    local Draw = require("src.ui.Draw")
    for i, e in ipairs(sorted) do
        record(screen, slot .. " [" .. (e.role or "?") .. " words not split]", Draw.wordsFit(e.text, e.w, e.size),
            ("a word of '%s' is wider than %dpx at size %d"):format(e.text:gsub("\n", " / "):sub(1, 60), e.w, e.size))
        local limit = math.min(e.bottom or height, height)
        record(screen, slot .. " [" .. (e.role or "?") .. "]", e.y + e.h <= limit,
            ("'%s' ends at %d, limit %d"):format(e.text:gsub("\n", " / "):sub(1, 60), e.y + e.h, limit))
        local nxt = sorted[i + 1]
        if nxt and nxt.align == e.align then
            record(screen, slot .. " [" .. e.role .. " vs " .. nxt.role .. "]", e.y + e.h <= nxt.y,
                ("'%s' ends at %d but '%s' starts at %d"):format(e.text:sub(1, 30), e.y + e.h, nxt.text:sub(1, 30), nxt.y))
        end
    end
end

local function checkBox(Draw, screen, slot, text, size, w, maxH)
    local h = Draw.textHeight(text, w, size)
    record(screen, slot, h <= maxH, ("%dpx > %dpx: '%s'"):format(h, maxH, text:gsub("\n", " / "):sub(1, 90)))
end

function love.load()
    local Draw = require("src.ui.Draw")
    local Cards = require("src.data.cards")
    local rules = require("src.data.rules")
    local dragons = require("src.data.dragons")
    local DateDialogue = require("src.data.date_dialogue")
    local CardResolver = require("src.rules.CardResolver")
    local RunState = require("src.state.RunState")
    local activities = require("src.data.activities")
    local dialogue = require("src.data.dialogue")
    local map = require("src.data.map")
    local MapSetupSystem = require("src.systems.MapSetupSystem")
    local DateRenderSystem = require("src.systems.DateRenderSystem")

    -- Cards: every size used by the game
    local CARD_SIZES = { { "Date hand", 102, 62 }, { "Collection", 66, 92 }, { "Pack", 112, 144 } }
    local DETAIL_SIZES = { { "Date", 360, 96 }, { "Collection", 146, 196 }, { "Pack", 492, 98 } }
    for _, id in ipairs(Cards.order) do
        local card = Cards.get(id)
        for _, s in ipairs(CARD_SIZES) do checkLayout(s[1], "card", Draw.cardLayout(card, s[2], s[3]), s[3]) end
        for _, s in ipairs(DETAIL_SIZES) do checkLayout(s[1], "card details", Draw.cardDetailsLayout(card, s[2], s[3]), s[3]) end
        checkBox(Draw, "Recap", "acquired card name", card.name, 11, 180, 16)
        checkBox(Draw, "Collection", "new this week name", card.name, 10, 146, 13)
    end

    -- Date: mood panel for every dragon x mood, with and without the next-mood preview
    local P = DateRenderSystem.MOOD_PANEL
    for _, dragonId in ipairs(dragons.order) do
        for _, mood in ipairs(rules.moodOrder) do
            for _, preview in ipairs({ false, "competitive" }) do
                local els = DateRenderSystem.moodLayout({ dragonId = dragonId, currentMood = mood, previewMood = preview or nil })
                checkLayout("Date", "mood panel", els, P.h)
                if preview then
                    local label, prev = els[1], els[2]
                    record("Date", "mood panel [label vs preview]",
                        Draw.textWidth(label.text, label.size) + 8 + Draw.textWidth(prev.text, prev.size) <= label.w,
                        label.text .. " + " .. prev.text)
                end
            end
        end
    end

    -- Date: feedback after playing each card, in every dragon x mood x state
    for _, dragonId in ipairs(dragons.order) do
        for _, mood in ipairs(rules.moodOrder) do
            for _, id in ipairs(Cards.order) do
                for _, pressure in ipairs({ 0, 2, 4 }) do
                    for _, chain in ipairs({ 0, 3 }) do
                        for seed = 1, 6 do
                            local run = RunState.new(seed)
                            run.weeklyTags = { training = true, study = true, support = true }
                            local ds = { dragonId = dragonId, currentMood = mood, exchange = 2, maxExchanges = 5,
                                chemistry = 3, pressure = pressure, maxPressure = 6, hand = {}, discard = {},
                                effects = { nextChemistry = 1, challengePressureShield = 1 }, insight = 1,
                                challengeChain = chain, usedTypes = { challenge = true }, lastCardType = "wit" }
                            local result = CardResolver.resolve(run, ds, id)
                            local notes = table.concat(result.notes, " | ")
                            if notes == "" then notes = "No special modifier." end
                            local fb = ("%s\n%s\n%s\nC%+d P%+d  %s"):format(Cards.get(id).name, DateDialogue.action(id),
                                DateDialogue.reaction(dragonId, id, mood, result, ds), result.appliedChemistry,
                                result.appliedPressure, notes)
                            checkBox(Draw, "Date", "feedback after a card", fb, 9, 336, 278 - 195)
                        end
                    end
                end
            end
        end
    end
    checkBox(Draw, "Date", "feedback at the end of a date",
        "Pressure reached the limit.\nAwkward Date\nChemistry 10  Pressure 6\nAffection -1", 9, 336, 278 - 195)
    checkBox(Draw, "Date", "footer", "Arrows: card  |  Enter: play  |  Risk 35%  |  M: take a breath (+1 Pressure)", 11, 616, 26)

    -- Progression, recap, ending, map, title
    for _, id in ipairs(activities.order) do
        for _, line in ipairs(activities[id].lines) do
            checkBox(Draw, "Progression", "activity result",
                activities[id].name .. "\nValor 9 -> 11   Wit 9 -> 11   Empathy 9 -> 11\n" .. line, 13, 552, 330 - 264)
        end
    end
    for _, d in ipairs(dragons.order) do
        for _, label in ipairs({ "Awkward Date", "Neutral Date", "Good Date", "Great Date" }) do
            checkBox(Draw, "Recap", "date result title", dragons[d].name .. " - " .. label, 11, 180, 20)
        end
        checkBox(Draw, "Ending", "ending message", dragons[d].ending, 12, 400, 362 - 280)
        checkBox(Draw, "Ending", "friendly ending", dialogue.friendlyEnding:format(dragons[d].name), 12, 400, 362 - 280)
    end
    checkBox(Draw, "Ending", "neutral ending", dialogue.neutralEnding, 12, 400, 362 - 280)
    for _, b in ipairs(map.buildings) do
        checkBox(Draw, "Map", "footer prompt", MapSetupSystem.promptFor(b), 13, 616, 18)
        if b.kind ~= "gate" then
            local need = 16 + Draw.textWidth(b.label, 11) + 6 + (b.dragonId and Draw.textWidth(dragons[b.dragonId].name, 9) or 0)
            record("Map", "sign fits", need <= b.w - 14, b.label)
        end
    end
    checkBox(Draw, "Title", "subtitle", "Train through the week. Turn experiences into cards. Learn to read the moment.", 12, 408, 120)

    -- Report
    local keys = {}
    for k in pairs(slots) do keys[#keys + 1] = k end
    table.sort(keys)
    local failed = 0
    for _, k in ipairs(keys) do
        local s = slots[k]
        if s.failed > 0 then failed = failed + 1 end
        print(("%s %-12s %-45s %5d checks  %4d failed"):format(s.failed > 0 and "FAIL" or " ok ", s.screen, s.slot, s.total, s.failed))
    end
    for _, f in ipairs(failures) do print("  - " .. f) end
    print(("text audit: %d checks, %d failing slots"):format(checks, failed))
    love.event.quit(failed > 0 and 1 or 0)
end
