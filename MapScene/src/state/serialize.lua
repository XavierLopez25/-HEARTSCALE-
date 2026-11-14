local serialize = {}

local function isIdentifier(key)
    return type(key) == "string" and key:match("^[%a_][%w_]*$") ~= nil
end

local function encodeValue(value, indent)
    local valueType = type(value)
    if valueType == "number" or valueType == "boolean" then
        return tostring(value)
    elseif valueType == "string" then
        return ("%q"):format(value)
    elseif valueType == "table" then
        local keys = {}
        for key in pairs(value) do keys[#keys + 1] = key end
        table.sort(keys, function(a, b)
            if type(a) == type(b) then return a < b end
            return type(a) == "number"
        end)

        if #keys == 0 then return "{}" end
        local pieces = {}
        local inner = indent .. "    "
        for _, key in ipairs(keys) do
            local keyText
            if isIdentifier(key) then
                keyText = key
            elseif type(key) == "number" then
                keyText = "[" .. tostring(key) .. "]"
            elseif type(key) == "string" then
                keyText = "[" .. ("%q"):format(key) .. "]"
            else
                error("cannot serialize key of type " .. type(key))
            end
            pieces[#pieces + 1] = inner .. keyText .. " = "
                .. encodeValue(value[key], inner) .. ","
        end
        return "{\n" .. table.concat(pieces, "\n") .. "\n" .. indent .. "}"
    end
    error("cannot serialize value of type " .. valueType)
end

function serialize.encode(data)
    assert(type(data) == "table", "can only serialize tables")
    return "return " .. encodeValue(data, "")
end

function serialize.decode(text)
    local loader = loadstring or load
    local chunk = loader(text)
    if not chunk then return nil end
    local ok, result = pcall(chunk)
    if not ok or type(result) ~= "table" then return nil end
    return result
end

return serialize
