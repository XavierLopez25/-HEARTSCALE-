local Game = {}

local factories = {}
local current = nil

function Game.registerScene(name, factory)
    factories[name] = factory
end

local function performSwitch(name, payload)
    assert(factories[name], "unknown scene: " .. tostring(name))
    if current then
        current:unload()
    end
    current = factories[name](payload)
    current:setup()
end

function Game.start(name, payload)
    performSwitch(name, payload)
end

function Game.update(dt)
    if not current then return end
    current:update(dt)

    for _, entity in ipairs(current.registry:query("event")) do
        current.registry:destroy(entity)
    end

    local _, request = current.registry:first("switchRequest")
    if request then
        performSwitch(request.to, request.payload)
    end
end

function Game.draw()
    if current then current:draw() end
end

function Game.keypressed(key)
    if key == "escape" then
        love.event.quit()
        return
    end
    if current then
        current.registry:spawn({ event = true, keyPressed = { key = key } })
    end
end

function Game.quit()
    if current then current:unload() end
end

function Game.current()
    return current
end

function Game.sceneNames()
    local names = {}
    for name in pairs(factories) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end

return Game
