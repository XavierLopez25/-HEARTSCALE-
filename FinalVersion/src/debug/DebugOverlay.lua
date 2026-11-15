local Screen = require("src.Screen")
local RunState = require("src.state.RunState")
local dragons = require("src.data.dragons")
local moods = require("src.data.moods")

local DebugOverlay = {}

local visible = false
local sceneJump = false
local font

local SCENES = {
    "title",
    "progression",
    "pack",
    "collection",
    "map",
    "date",
    "recap",
    "ending",
}

local SCENE_LABELS = {
    title = "title",
    progression = "progression",
    pack = "pack",
    collection = "collection",
    map = "map",
    date = "date",
    recap = "recap",
    ending = "ending",
}

local DRAGON_LABELS = {
    kaela = "K",
    veyra = "V",
    sarka = "S",
    nyxara = "N",
    aurelia = "A",
}

local function ensureFont()
    if not font then font = love.graphics.newFont(10) end
end

local function addAffection(state, amount)
    local dragon = state.currentDragon or "kaela"
    state.affection[dragon] = math.max(0, (state.affection[dragon] or 0) + amount)
end

function DebugOverlay.keypressed(key, scene)
    if key == "f1" then
        visible = not visible
        return true
    elseif key == "f2" then
        visible = true
        sceneJump = not sceneJump
        return true
    end

    if sceneJump and scene and key:match("^[1-8]$") then
        local target = SCENES[tonumber(key)]
        if target == "date" then
            RunState.get().currentDragon = RunState.get().currentDragon or "kaela"
        end
        scene.registry:spawn({ switchRequest = { to = target } })
        sceneJump = false
        return true
    end

    if not visible then return false end

    local state = RunState.get()
    local date = scene and scene.registry:resource("dateState")
    if key == "f3" then
        state.stats.valor = state.stats.valor + 1
        return true
    elseif key == "f4" then
        state.stats.wit = state.stats.wit + 1
        return true
    elseif key == "f5" then
        state.stats.empathy = state.stats.empathy + 1
        return true
    elseif key == "f6" then
        addAffection(state, 1)
        return true
    elseif key == "f7" and date then
        date.chemistry = date.chemistry + 1
        return true
    elseif key == "f8" and date then
        date.pressure = math.min(date.maxPressure, date.pressure + 1)
        return true
    end

    return false
end

local function text(line, x, y)
    love.graphics.print(line, x, y)
    return y + 12
end

local function sceneLabel(name)
    return SCENE_LABELS[name] or name or "?"
end

local function dragonLabel(id)
    local dragon = id and dragons[id]
    return dragon and dragon.name or id or "?"
end

local function moodLabel(id)
    local mood = id and moods[id]
    return mood and mood.label or id or "?"
end

function DebugOverlay.draw(scene, scale, ox, oy)
    if not visible then return end
    ensureFont()

    love.graphics.push()
    love.graphics.origin()
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 0.78)
    love.graphics.rectangle("fill", ox + 6 * scale, oy + 6 * scale, 382 * scale, 132 * scale)
    love.graphics.setColor(1, 1, 1, 0.9)

    local state = RunState.get()
    local x = ox + 10 * scale
    local y = oy + 10 * scale
    love.graphics.scale(scale, scale)
    x, y = x / scale, y / scale

    y = text(("FPS %d  SCENE %s"):format(love.timer.getFPS(), sceneLabel(scene and scene.name)), x, y)
    y = text(("SEED %d  RNG %d"):format(state.rngSeed, state.rngCalls or 0), x, y)
    y = text(("WEEK %d  ACTIONS %d/%d"):format(
        state.week,
        state.progression.actionsUsed,
        state.progression.actionsPerWeek), x, y)
    y = text(("VAL %d  WIT %d  EMP %d"):format(
        state.stats.valor,
        state.stats.wit,
        state.stats.empathy), x, y)
    y = text(("AFFECTION %s%d %s%d %s%d %s%d %s%d"):format(
        DRAGON_LABELS.kaela,
        state.affection.kaela,
        DRAGON_LABELS.veyra,
        state.affection.veyra,
        DRAGON_LABELS.sarka,
        state.affection.sarka,
        DRAGON_LABELS.nyxara,
        state.affection.nyxara,
        DRAGON_LABELS.aurelia,
        state.affection.aurelia), x, y)

    local date = scene and scene.registry:resource("dateState")
    if date then
        y = text(("DATE %s  MOOD %s"):format(dragonLabel(date.dragonId), moodLabel(date.currentMood)), x, y)
        y = text(("CHEM %d  PRESS %d/%d"):format(date.chemistry, date.pressure, date.maxPressure), x, y)
    end

    local mapState = scene and scene.registry:resource("mapState")
    if mapState then
        local pos = scene.registry:get(mapState.player, "worldPosition")
        y = text(("MAP X %d  Y %d  NEAR %s"):format(
            math.floor(pos.x), math.floor(pos.y),
            mapState.nearby and mapState.nearby.id or "-"), x, y)
    end

    y = text("F2 scenes | F3/F4/F5 stats | F6 affection | F7/F8 date", x, y)
    if sceneJump then
        local list = {}
        for i, name in ipairs(SCENES) do list[#list + 1] = i .. " " .. sceneLabel(name) end
        text(table.concat(list, "  "), x, y)
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

return DebugOverlay
