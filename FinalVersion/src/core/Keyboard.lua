-- Thin wrapper around love.keyboard.isDown so continuous movement can be
-- tested headless with Lua 5.4. Tests inject a provider; the game uses LOVE.
local Keyboard = {}

local provider = nil

function Keyboard.setProvider(fn)
    provider = fn
end

function Keyboard.isDown(...)
    if provider then return provider(...) end
    if love and love.keyboard and love.keyboard.isDown then
        return love.keyboard.isDown(...)
    end
    return false
end

return Keyboard
