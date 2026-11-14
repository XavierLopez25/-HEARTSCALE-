local RunState = {}

local active

local INITIAL_CARDS = {
    "friendly_competition",
    "one_more_rep",
    "read_the_stance",
    "dry_joke",
    "spotter",
    "listen_first",
}

local function copyList(list)
    local result = {}
    for i, value in ipairs(list) do result[i] = value end
    return result
end

function RunState.new(seed)
    return {
        week = 1,
        progression = {
            actionsUsed = 0,
            actionsPerWeek = 3,
        },
        stats = {
            valor = 1,
            wit = 1,
            empathy = 1,
        },
        affection = {
            kaela = 0,
            veyra = 0,
            sarka = 0,
            nyxara = 0,
            aurelia = 0,
        },
        collection = copyList(INITIAL_CARDS),
        currentDragon = nil,
        rngSeed = seed or os.time() % 2147483648,
        rngCalls = 0,
        weeklyTags = {},
        lastAcquired = {},
        lastDate = nil,
        gameCompleted = false,
    }
end

function RunState.startNew(seed)
    active = RunState.new(seed)
    return active
end

function RunState.get()
    if not active then active = RunState.new() end
    return active
end

function RunState.startNextWeek(state)
    state.week = state.week + 1
    state.progression.actionsUsed = 0
    state.weeklyTags = {}
    state.currentDragon = nil
    state.lastAcquired = {}
end

return RunState
