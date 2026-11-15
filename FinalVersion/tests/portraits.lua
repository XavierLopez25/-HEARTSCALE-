package.path = "./?.lua;" .. package.path

local dragons = require("src.data.dragons")
local DragonPortraits = require("src.ui.DragonPortraits")

local function assertEq(actual, expected, message)
    assert(actual == expected, (message or "assertEq failed") .. ": "
        .. tostring(actual) .. " ~= " .. tostring(expected))
end

local function u32(bytes, offset)
    local a, b, c, d = bytes:byte(offset, offset + 3)
    return ((a * 256 + b) * 256 + c) * 256 + d
end

-- Reads the PNG signature and IHDR chunk without any image library.
local function pngHeader(path)
    local file = io.open(path, "rb")
    if not file then return nil end
    local bytes = file:read(33)
    file:close()
    assert(bytes and #bytes == 33, path .. " is too short to be a PNG")
    assertEq(bytes:sub(1, 8), "\137PNG\r\n\26\n", path .. " PNG signature")
    assertEq(bytes:sub(13, 16), "IHDR", path .. " first chunk")
    return {
        width = u32(bytes, 17),
        height = u32(bytes, 21),
        bitDepth = bytes:byte(25),
        colorType = bytes:byte(26),
    }
end

local seen = {}
for _, id in ipairs(dragons.order) do
    local dragon = dragons[id]
    assert(dragon.portrait, id .. " has no portrait path")
    assertEq(dragon.portrait, "assets/dragons/" .. id .. ".png", id .. " portrait path")
    assert(not seen[dragon.portrait], "portrait reused: " .. dragon.portrait)
    seen[dragon.portrait] = true

    local header = pngHeader(dragon.portrait)
    assert(header, id .. " portrait file is missing: " .. dragon.portrait)
    assertEq(header.width, DragonPortraits.SIZE, id .. " portrait width")
    assertEq(header.height, DragonPortraits.SIZE, id .. " portrait height")
    assertEq(header.bitDepth, 8, id .. " portrait bit depth")
    assertEq(header.colorType, 6, id .. " portrait must be RGBA")
end

-- Headless (no love.graphics): the loader returns nothing, so Draw.portrait
-- would use the mock fallback instead of failing.
assertEq(DragonPortraits.get(dragons.kaela), nil, "headless portrait load")
assertEq(DragonPortraits.get(nil), nil, "nil dragon")
assertEq(DragonPortraits.get({ name = "No Art" }), nil, "dragon without portrait")

print("portrait tests passed")
