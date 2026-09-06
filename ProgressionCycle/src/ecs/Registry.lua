local Registry = {}
Registry.__index = Registry

function Registry.new()
    return setmetatable({ entities = {}, resources = {} }, Registry)
end

function Registry:spawn(entity)
    self.entities[#self.entities + 1] = entity
    return entity
end

function Registry:setResource(key, value)
    self.resources[key] = value
end

function Registry:resource(key)
    return self.resources[key]
end

function Registry:each(component)
    local i = 0
    return function()
        i = i + 1
        while self.entities[i] do
            local entity = self.entities[i]
            if entity[component] then return i, entity end
            i = i + 1
        end
    end
end

function Registry:clearEvents()
    local kept = {}
    for _, entity in ipairs(self.entities) do
        if not entity.keyPressed and not entity.activitySelected then
            kept[#kept + 1] = entity
        end
    end
    self.entities = kept
end

return Registry
