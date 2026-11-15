local Audio = {}

local ready = false
local sounds = {}

local RATE = 22050

local function makeTone(freq, seconds, volume)
    local samples = math.floor(RATE * seconds)
    local data = love.sound.newSoundData(samples, RATE, 16, 1)
    for i = 0, samples - 1 do
        local t = i / RATE
        local fade = math.min(1, i / 120, (samples - i) / 120)
        data:setSample(i, math.sin(t * freq * math.pi * 2) * volume * fade)
    end
    return love.audio.newSource(data, "static")
end

local function ensure()
    if ready or not love or not love.sound then return end
    ready = true
    sounds.confirm = makeTone(640, 0.07, 0.20)
    sounds.card = makeTone(420, 0.08, 0.18)
    sounds.chemistry = makeTone(820, 0.09, 0.16)
    sounds.pressure = makeTone(160, 0.12, 0.18)
    sounds.riskSuccess = makeTone(1040, 0.16, 0.18)
    sounds.riskFail = makeTone(90, 0.18, 0.20)
end

function Audio.play(name)
    ensure()
    local source = sounds[name]
    if source then source:clone():play() end
end

return Audio
