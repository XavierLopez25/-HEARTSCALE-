local Registry = require("src.ecs.Registry")

local Game = {
    factories = {},
    scene = nil,
}

function Game.registerScene(name, factory)
    Game.factories[name] = factory
end

function Game.switch(name, payload)
    local factory = assert(Game.factories[name], "unknown scene: " .. tostring(name))
    Game.scene = factory(payload or {})
    Game.scene:setup()
end

function Game.update(dt)
    if not Game.scene then return end
    Game.scene:update(dt)
    for _, request in Game.scene.registry:each("switchRequest") do
        Game.switch(request.to, request.payload)
        break
    end
end

function Game.draw()
    if Game.scene then Game.scene:draw() end
end

function Game.keypressed(key)
    if not Game.scene then return end
    Game.scene.registry:spawn({ keyPressed = true, key = key })
end

return Game
