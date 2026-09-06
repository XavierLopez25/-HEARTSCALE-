local RunState = {
    current = nil,
}

function RunState.new()
    return {
        week = 1,
        actionsUsed = 0,
        actionsPerWeek = 3,
        stats = { valor = 0, wit = 0, empathy = 0 },
        collection = {},
        lastAcquired = {},
        weeklyTags = {},
        selectedDragon = "kaela",
        affection = { kaela = 0, veyra = 0, sarka = 0 },
        lastDialogueChoice = nil,
    }
end

function RunState.get()
    if not RunState.current then RunState.current = RunState.new() end
    return RunState.current
end

function RunState.reset()
    RunState.current = RunState.new()
    return RunState.current
end

return RunState
