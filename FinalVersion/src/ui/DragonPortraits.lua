-- Dragon portrait images (128x128 busts exported from the source .ase files).
-- Every image is optional: a missing, unreadable or wrongly sized file is
-- ignored and Draw.portrait falls back to the primitive mock portrait.
local DragonPortraits = {}

DragonPortraits.SIZE = 128

local cache = {}
local MISSING = {}

local function available()
    return love and love.graphics and love.graphics.newImage
        and love.filesystem and love.filesystem.getInfo
end

local function load(path)
    if not love.filesystem.getInfo(path, "file") then
        print("[portraits] missing " .. path .. ", using the mock portrait")
        return nil
    end
    local ok, image = pcall(love.graphics.newImage, path)
    if not ok or not image then
        print("[portraits] could not load " .. path .. ", using the mock portrait")
        return nil
    end
    local size = DragonPortraits.SIZE
    if image:getWidth() ~= size or image:getHeight() ~= size then
        print(("[portraits] %s is %dx%d, expected %dx%d; using the mock portrait"):format(
            path, image:getWidth(), image:getHeight(), size, size))
        return nil
    end
    image:setFilter("nearest", "nearest")
    return image
end

-- Returns the portrait image for a dragon data table, or nil.
function DragonPortraits.get(dragon)
    local path = dragon and dragon.portrait
    if not path or not available() then return nil end
    local cached = cache[path]
    if cached == nil then
        cached = load(path) or MISSING
        cache[path] = cached
    end
    if cached == MISSING then return nil end
    return cached
end

function DragonPortraits.reset()
    cache = {}
end

return DragonPortraits
