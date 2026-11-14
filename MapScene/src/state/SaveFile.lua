local serialize = require("src.state.serialize")

local SaveFile = {
    FILENAME = "save.lua",
    VERSION = 1,
}

function SaveFile.save(data)
    data.version = SaveFile.VERSION
    love.filesystem.write(SaveFile.FILENAME, serialize.encode(data))
end

function SaveFile.load()
    local text = love.filesystem.read(SaveFile.FILENAME)
    if not text then return nil end
    local data = serialize.decode(text)
    if not data or data.version ~= SaveFile.VERSION then return nil end
    return data
end

return SaveFile
