package.path = "./?.lua;" .. package.path

-- Headless LOVE stub: no graphics, audio or keyboard. Movement reads held
-- keys through src.core.Keyboard, which these tests drive directly.
_G.love = {
    event = { quit = function() end },
    timer = { getFPS = function() return 60 end },
}

local Game = require("src.Game")
local RunState = require("src.state.RunState")
local Keyboard = require("src.core.Keyboard")
local MapPhysics = require("src.rules.MapPhysics")
local MapAssets = require("src.ui.MapAssets")
local dragons = require("src.data.dragons")
local map = require("src.data.map")

local function assertEq(actual, expected, message)
    assert(actual == expected, (message or "assertEq failed") .. ": "
        .. tostring(actual) .. " ~= " .. tostring(expected))
end

local function assertNear(actual, expected, message)
    assert(math.abs(actual - expected) < 1e-6, (message or "assertNear failed") .. ": "
        .. tostring(actual) .. " ~= " .. tostring(expected))
end

local held = {}
Keyboard.setProvider(function(...)
    for _, key in ipairs({ ... }) do
        if held[key] then return true end
    end
    return false
end)

local function hold(...)
    held = {}
    for _, key in ipairs({ ... }) do held[key] = true end
end

Game.registerScene("title", require("src.scenes.TitleScene"))
Game.registerScene("progression", require("src.scenes.ProgressionScene"))
Game.registerScene("pack", require("src.scenes.PackScene"))
Game.registerScene("collection", require("src.scenes.CollectionScene"))
Game.registerScene("map", require("src.scenes.MapScene"))
Game.registerScene("date", require("src.scenes.DateScene"))
Game.registerScene("recap", require("src.scenes.RecapScene"))
Game.registerScene("ending", require("src.scenes.EndingScene"))

local function freshMap()
    hold()
    RunState.startNew(7)
    Game.start("map")
    return Game.current()
end

local function mapState()
    return Game.current().registry:resource("mapState")
end

local function playerPos()
    return Game.current().registry:get(mapState().player, "worldPosition")
end

local function teleport(x, y)
    local pos = playerPos()
    pos.x, pos.y = x, y
end

local function step(seconds, dt)
    dt = dt or (1 / 60)
    local elapsed = 0
    while elapsed < seconds - 1e-9 do
        local d = math.min(dt, seconds - elapsed)
        Game.update(d)
        elapsed = elapsed + d
    end
end

local function tap(key)
    Game.keypressed(key)
    Game.update(0)
end

local function playerRect()
    local pos = playerPos()
    return { x = pos.x, y = pos.y, w = map.player.w, h = map.player.h }
end

local solids = map.solids()

-- 1. Data: five dragon locations with unique ids, plus the Guild Hall.
local poiIds, dragonIds, dragonPois = {}, {}, 0
for _, building in ipairs(map.buildings) do
    assert(not poiIds[building.id], "duplicate POI id " .. building.id)
    poiIds[building.id] = true
    if building.dragonId then
        assert(dragons[building.dragonId], "unknown dragon " .. building.dragonId)
        assert(not dragonIds[building.dragonId], "duplicate dragonId " .. building.dragonId)
        dragonIds[building.dragonId] = true
        dragonPois = dragonPois + 1
        assertEq(building.label, dragons[building.dragonId].place, building.id .. " label matches dragon place")
    end
end
assertEq(dragonPois, 5, "dragon points of interest")
for _, id in ipairs(dragons.order) do
    assert(dragonIds[id], "no map location for " .. id)
end
assertEq(map.building("guild_hall").action, "collection", "guild hall returns to collection")

local expectedPlaces = { kaela = "Forge", veyra = "Training Yard", sarka = "Arena", nyxara = "Archive", aurelia = "Gate" }
for dragonId, label in pairs(expectedPlaces) do
    assertEq(map.buildingForDragon(dragonId).label, label, dragonId .. " location")
end

-- 2. Geometry: map fits 640x400 above the footer, zones sit outside colliders.
assert(map.width <= 640 and map.height <= 364, "map must fit above the footer")
assertEq(map.cols * map.tileSize, map.width, "map width on 16 px grid")
assertEq(map.rows * map.tileSize, map.height, "map height on 16 px grid")
local b = map.bounds
for _, building in ipairs(map.buildings) do
    local zone = building.interaction
    assert(not MapPhysics.collides(zone, solids), building.id .. " interaction zone overlaps a collider")
    assert(zone.x >= b.x and zone.y >= b.y and zone.x + zone.w <= b.x + b.w and zone.y + zone.h <= b.y + b.h,
        building.id .. " interaction zone outside bounds")
    assert(zone.w >= map.player.w and zone.h >= 16, building.id .. " interaction zone too small to stand in")
    local door = building.door
    assert(door.x >= building.x and door.y >= building.y
        and door.x + door.w <= building.x + building.w and door.y + door.h <= building.y + building.h,
        building.id .. " door must be on its facade")
end
local spawnRect = { x = map.spawn.x, y = map.spawn.y, w = map.player.w, h = map.player.h }
assert(not MapPhysics.collides(spawnRect, solids), "spawn overlaps a collider")
for _, building in ipairs(map.buildings) do
    assert(not MapPhysics.rectsOverlap(spawnRect, building.interaction), "spawn starts inside " .. building.id)
end

-- 3. Reachability: flood fill on a 2 px grid from the spawn reaches every zone.
do
    local GRID = 2
    local function free(x, y)
        local rect = { x = x, y = y, w = map.player.w, h = map.player.h }
        if x < b.x or y < b.y or x + rect.w > b.x + b.w or y + rect.h > b.y + b.h then return false end
        return not MapPhysics.collides(rect, solids)
    end
    local seen, queue, head = {}, { { map.spawn.x, map.spawn.y } }, 1
    seen[map.spawn.x .. ":" .. map.spawn.y] = true
    local reached = {}
    while queue[head] do
        local x, y = queue[head][1], queue[head][2]
        head = head + 1
        for _, building in ipairs(map.buildings) do
            if MapPhysics.rectsOverlap({ x = x, y = y, w = map.player.w, h = map.player.h }, building.interaction) then
                reached[building.id] = true
            end
        end
        for _, d in ipairs({ { GRID, 0 }, { -GRID, 0 }, { 0, GRID }, { 0, -GRID } }) do
            local nx, ny = x + d[1], y + d[2]
            local key = nx .. ":" .. ny
            if not seen[key] and free(nx, ny) then
                seen[key] = true
                queue[#queue + 1] = { nx, ny }
            end
        end
    end
    for _, building in ipairs(map.buildings) do
        assert(reached[building.id], building.id .. " is not reachable from the spawn")
    end
end

-- 4. Scene setup creates the expected ECS entities and resources.
local scene = freshMap()
assertEq(scene.name, "map", "scene id")
local state = mapState()
assert(state and state.player, "mapState with player reference")
assertEq(state.returnScene, "collection", "return scene")
assertEq(#scene.registry:query("pointOfInterest"), 6, "five dragon POIs plus guild hall")
assertEq(#scene.registry:query("player", "worldPosition", "collider"), 1, "one player")
local colliderCount = 0
for _, _, collider in scene.registry:each("worldPosition", "collider") do
    if collider.solid then colliderCount = colliderCount + 1 end
end
assertEq(colliderCount, #solids, "every wall, building and obstacle is a solid collider")
assertEq(playerPos().x, map.spawn.x, "spawn x")
assertEq(playerPos().y, map.spawn.y, "spawn y")
assert(next(MapAssets.load()) == nil, "headless run must fall back to placeholders")

-- 5. Movement: horizontal and vertical with arrows and WASD, using delta time.
local speed = map.player.speed
assertEq(speed, 95, "player speed")
for _, case in ipairs({
    { keys = { "right" }, dx = 1, dy = 0 },
    { keys = { "d" }, dx = 1, dy = 0 },
    { keys = { "left" }, dx = -1, dy = 0 },
    { keys = { "a" }, dx = -1, dy = 0 },
    { keys = { "down" }, dx = 0, dy = 1 },
    { keys = { "s" }, dx = 0, dy = 1 },
}) do
    freshMap()
    hold(table.unpack(case.keys))
    Game.update(0.1)
    assertNear(playerPos().x, map.spawn.x + case.dx * speed * 0.1, case.keys[1] .. " moves x")
    assertNear(playerPos().y, map.spawn.y + case.dy * speed * 0.1, case.keys[1] .. " moves y")
end

freshMap()
teleport(314, 160)
hold("w")
Game.update(0.1)
assertNear(playerPos().y, 160 - speed * 0.1, "w moves up")

freshMap()
hold("right", "left")
Game.update(0.1)
assertEq(playerPos().x, map.spawn.x, "opposite keys cancel")

freshMap()
hold("right")
step(0.5, 1 / 30)
assertNear(playerPos().x, map.spawn.x + speed * 0.5, "movement scales with delta time")

-- 6. Diagonal normalization: never faster than straight movement.
for _, keys in ipairs({ { "right", "down" }, { "d", "s" }, { "left", "down" } }) do
    freshMap()
    hold(table.unpack(keys))
    Game.update(0.1)
    local dx, dy = playerPos().x - map.spawn.x, playerPos().y - map.spawn.y
    assertNear(math.sqrt(dx * dx + dy * dy), speed * 0.1, "diagonal speed " .. table.concat(keys, "+"))
    assertNear(math.abs(dx), speed * 0.1 / math.sqrt(2), "diagonal x component")
end

-- 7. Bounds: the player stops at every edge of the walkable area.
local edges = {
    { start = { 24, 140 }, keys = { "left" }, axis = "x", value = b.x },
    { start = { 600, 140 }, keys = { "right" }, axis = "x", value = b.x + b.w - map.player.w },
    { start = { 242, 70 }, keys = { "up" }, axis = "y", value = b.y },
    { start = { 24, 300 }, keys = { "down" }, axis = "y", value = b.y + b.h - map.player.h },
}
for _, edge in ipairs(edges) do
    freshMap()
    teleport(edge.start[1], edge.start[2])
    hold(table.unpack(edge.keys))
    step(3)
    assertEq(playerPos()[edge.axis], edge.value, edge.keys[1] .. " stops at the bound")
end

-- Large frame spikes cannot tunnel through walls either.
freshMap()
teleport(24, 140)
hold("left")
Game.update(5)
assertEq(playerPos().x, b.x, "long frame clamps to bound")

-- 8. Building and obstacle collisions, resolved per axis.
freshMap()
hold("up")
step(2)
assertEq(playerPos().y, 96, "guild hall blocks the player at its facade")
assertEq(playerPos().x, map.spawn.x, "vertical collision does not change x")

freshMap()
teleport(314, 150)
hold("down")
step(2)
assertEq(playerPos().y, 184 - map.player.h, "well blocks the player")

freshMap()
teleport(206, 190) -- between the Training Yard and the courtyard
hold("left")
step(2)
assertEq(playerPos().x, 192, "training yard fence blocks from the east")

freshMap()
teleport(300, 252)
hold("down", "left")
step(2)
local pos = playerPos()
assert(not MapPhysics.collides(playerRect(), solids), "diagonal slide ends outside every collider")
assert(pos.y <= 272, "south fence blocks the courtyard diagonal")

freshMap()
teleport(434, 216)
hold("right")
step(1, 1 / 5) -- one big step per frame still cannot cross the wall
assertEq(playerPos().x, 448 - map.player.w, "arena wall blocks with large dt")

-- Random walk: never leaves bounds and never ends inside a collider.
do
    freshMap()
    local seed = 12345
    local function rand(n)
        seed = (seed * 1103515245 + 12345) % 2147483648
        return seed % n
    end
    local keySets = {
        { "up" }, { "down" }, { "left" }, { "right" },
        { "up", "left" }, { "up", "right" }, { "down", "left" }, { "down", "right" }, {},
    }
    for _ = 1, 400 do
        hold(table.unpack(keySets[rand(#keySets) + 1]))
        for _ = 1, 10 do
            Game.update(1 / 60)
            local r = playerRect()
            assert(r.x >= b.x and r.y >= b.y and r.x + r.w <= b.x + b.w and r.y + r.h <= b.y + b.h, "left the bounds")
            assert(not MapPhysics.collides(r, solids), ("inside a collider at %.2f, %.2f"):format(r.x, r.y))
        end
    end
end

-- 9. Enter outside any POI does nothing.
freshMap()
tap("return")
assertEq(Game.current().name, "map", "enter outside POI stays on map")
assertEq(RunState.get().currentDragon, nil, "enter outside POI selects nobody")
assertEq(mapState().prompt, "", "no prompt outside POI")
tap("space")
assertEq(Game.current().name, "map", "space outside POI stays on map")

-- 10. Every location selects its dragon and opens the date directly.
local expectedPrompts = {
    kaela = "Enter: Visit Kaela at the Forge",
    veyra = "Enter: Visit Veyra at the Training Yard",
    sarka = "Enter: Visit Sarka at the Arena",
    nyxara = "Enter: Visit Nyxara at the Archive",
    aurelia = "Enter: Visit Aurelia at the Gate",
}
for _, building in ipairs(map.buildings) do
    for _, key in ipairs({ "return", "space" }) do
        freshMap()
        local zone = building.interaction
        teleport(zone.x + zone.w / 2 - map.player.w / 2, zone.y + zone.h / 2 - map.player.h / 2)
        Game.update(0)
        assertEq(mapState().nearby and mapState().nearby.id, building.id, building.id .. " detected as nearby")
        if building.dragonId then
            assertEq(mapState().prompt, expectedPrompts[building.dragonId], building.id .. " prompt")
            tap(key)
            assertEq(Game.current().name, "date", building.id .. " opens date")
            assertEq(RunState.get().currentDragon, building.dragonId, building.id .. " selects dragon")
            assertEq(Game.current().registry:resource("dateState").dragonId, building.dragonId, "date uses dragon")
        else
            assertEq(mapState().prompt, "Enter: Return to the Guild Hall (Collection)", "guild hall prompt")
            tap(key)
            assertEq(Game.current().name, "collection", "guild hall returns to collection")
            assertEq(RunState.get().currentDragon, nil, "guild hall selects nobody")
        end
    end
end

-- Walking (not teleporting) into the Forge zone also works.
freshMap()
hold("left")
for _ = 1, 600 do
    Game.update(1 / 60)
    if playerPos().x <= 106 then break end
end
hold("up")
step(0.5)
hold()
Game.update(0)
assertEq(mapState().nearby and mapState().nearby.dragonId, "kaela", "walked to the forge")

-- 11. Backspace returns to Collection without choosing a dragon.
freshMap()
hold("right")
step(0.2)
tap("backspace")
assertEq(Game.current().name, "collection", "backspace returns to collection")
assertEq(RunState.get().currentDragon, nil, "backspace selects nobody")

-- Collection -> Map, and each new entry starts from the spawn again.
tap("return")
assertEq(Game.current().name, "map", "collection continues to map")
assertEq(playerPos().x, map.spawn.x, "re-entry resets x")
assertEq(playerPos().y, map.spawn.y, "re-entry resets y")

-- 12. Debug scene jump (F2) lists the map in slot 5 instead of dragon select.
do
    local DebugOverlay = require("src.debug.DebugOverlay")
    RunState.startNew(7)
    Game.start("collection")
    assert(DebugOverlay.keypressed("f2", Game.current()), "F2 opens scene jump")
    assert(DebugOverlay.keypressed("5", Game.current()), "5 is consumed by scene jump")
    Game.update(0)
    assertEq(Game.current().name, "map", "debug slot 5 jumps to map")
    DebugOverlay.keypressed("f1", Game.current()) -- hide overlay again
end

print("map tests passed")
