local Collection = {}

function Collection.addMany(collection, ids)
    local added = {}
    local owned = {}
    for _, id in ipairs(collection) do owned[id] = true end
    for _, id in ipairs(ids) do
        if not owned[id] then
            collection[#collection + 1] = id
            added[#added + 1] = id
            owned[id] = true
        end
    end
    return added
end

return Collection
