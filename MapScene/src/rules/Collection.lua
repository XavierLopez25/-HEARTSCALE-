local Collection = {}

function Collection.ownedSet(collection)
    local set = {}
    for _, id in ipairs(collection) do set[id] = true end
    return set
end

function Collection.has(collection, id)
    for _, owned in ipairs(collection) do
        if owned == id then return true end
    end
    return false
end

function Collection.add(collection, id)
    if Collection.has(collection, id) then return false end
    collection[#collection + 1] = id
    return true
end

function Collection.addMany(collection, ids)
    local added = {}
    for _, id in ipairs(ids) do
        if Collection.add(collection, id) then
            added[#added + 1] = id
        end
    end
    return added
end

return Collection
