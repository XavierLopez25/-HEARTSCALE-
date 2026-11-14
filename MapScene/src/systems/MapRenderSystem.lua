-- RENDER phase of the map scene. Draws ground, paths, walls, props,
-- buildings, the player and the HUD. Uses the optional LibreSprite atlases
-- from src/ui/MapAssets.lua when present and primitive placeholders otherwise.
local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")
local MapAssets = require("src.ui.MapAssets")
local dragons = require("src.data.dragons")
local rules = require("src.data.rules")
local map = require("src.data.map")

local MapRenderSystem = { name = "mapRender" }

local TILE = map.tileSize
local HALL_ACCENT = Palette.ink

local function color(c, alpha)
    love.graphics.setColor(c[1], c[2], c[3], alpha or 1)
end

local function shade(c, k)
    return { c[1] * k, c[2] * k, c[3] * k }
end

local function accentOf(poi)
    if poi and poi.dragonId then return dragons[poi.dragonId].accent end
    return HALL_ACCENT
end

-- Stable per-tile variation without touching the gameplay RNG.
local function tileHash(col, row)
    return (col * 73 + row * 151 + col * row * 7) % 11
end

local function drawGround(assets)
    for row = 0, map.rows - 1 do
        for col = 0, map.cols - 1 do
            local x, y = col * TILE, row * TILE
            local h = tileHash(col, row)
            local flowers = h == 0 and (col + row) % 3 == 0 -- about 3% of tiles
            local name = flowers and "grass_flowers" or (h % 2 == 0 and "grass_a" or "grass_b")
            if not MapAssets.drawTerrain(assets, name, x, y) then
                color((col + row) % 2 == 0 and Palette.grass or Palette.grassDark)
                love.graphics.rectangle("fill", x, y, TILE, TILE)
            end
        end
    end
end

local function drawTerrain(assets, position, terrain)
    local cols, rows = terrain.w / TILE, terrain.h / TILE
    for r = 0, rows - 1 do
        for c = 0, cols - 1 do
            local x, y = position.x + c * TILE, position.y + r * TILE
            local name
            if terrain.kind == "plaza" then
                name = (c + r) % 2 == 0 and "plaza_a" or "plaza_b"
                if tileHash(c, r) == 3 then name = "plaza_crack" end
            else
                name = tileHash(c, r) == 5 and "path_alt" or "path"
            end
            if not MapAssets.drawTerrain(assets, name, x, y) then
                if terrain.kind == "plaza" then
                    color((c + r) % 2 == 0 and Palette.plaza or Palette.plazaLine)
                    love.graphics.rectangle("fill", x, y, TILE, TILE)
                else
                    color(Palette.path)
                    love.graphics.rectangle("fill", x, y, TILE, TILE)
                    color(Palette.pathEdge)
                    love.graphics.rectangle("fill", x + 3 + (c + r) % 3 * 3, y + 5, 2, 2)
                end
            end
        end
    end
end

local function drawWall(assets, position, collider)
    for y = position.y, position.y + collider.h - 1, TILE do
        for x = position.x, position.x + collider.w - 1, TILE do
            local corner = (x == 0 or x == map.width - TILE) and (y == 0 or y == map.height - TILE)
            if not MapAssets.drawTerrain(assets, corner and "wall_corner" or "wall_top", x, y) then
                color(Palette.wall)
                love.graphics.rectangle("fill", x, y, TILE, TILE)
                color(Palette.wallTop)
                love.graphics.rectangle("fill", x + 1, y + 1, TILE - 2, 3)
                love.graphics.rectangle("line", x + 0.5, y + 0.5, TILE - 1, TILE - 1)
            end
        end
    end
end

local OBSTACLE_TILES = {
    crate = { "crate" },
    barrel = { "barrel" },
    tree = { "tree" },
    bench = { "bench_left", "bench_right" },
    rack = { "rack_left", "rack_right" },
}

local function drawObstacleAsset(assets, kind, position, collider)
    if not assets.terrain then return false end
    if kind == "well" then
        return MapAssets.drawTerrain(assets, "well", position.x, position.y)
    elseif kind == "fence" then
        for x = position.x, position.x + collider.w - 1, TILE do
            MapAssets.drawTerrain(assets, "fence", x, position.y + collider.h / 2 - TILE / 2)
        end
        return true
    end
    local tiles = OBSTACLE_TILES[kind]
    if not tiles then return false end
    for i, name in ipairs(tiles) do
        MapAssets.drawTerrain(assets, name, position.x + (i - 1) * TILE, position.y)
    end
    return true
end

local function drawObstacle(assets, position, collider, obstacle)
    if drawObstacleAsset(assets, obstacle.kind, position, collider) then return end
    local x, y, w, h = position.x, position.y, collider.w, collider.h
    local kind = obstacle.kind
    if kind == "well" then
        color(Palette.wallTop)
        love.graphics.circle("fill", x + w / 2, y + h / 2, w / 2)
        color(Palette.water)
        love.graphics.circle("fill", x + w / 2, y + h / 2, w / 2 - 5)
        color(Palette.ink, 0.5)
        love.graphics.circle("line", x + w / 2, y + h / 2, w / 2 - 0.5)
    elseif kind == "tree" then
        color(Palette.black, 0.35)
        love.graphics.ellipse("fill", x + w / 2, y + h - 2, w / 2, 3)
        color(Palette.leaf)
        love.graphics.circle("fill", x + w / 2, y + h / 2 - 1, w / 2)
        color(Palette.connection, 0.45)
        love.graphics.circle("fill", x + w / 2 - 2, y + h / 2 - 3, w / 4)
    elseif kind == "fence" then
        color(Palette.wood)
        love.graphics.rectangle("fill", x, y + 2, w, 3)
        for px = x, x + w - 1, 8 do
            love.graphics.rectangle("fill", px + 1, y, 3, h)
        end
    elseif kind == "bench" then
        color(Palette.wood)
        love.graphics.rectangle("fill", x + 1, y + 4, w - 2, 7)
        color(shade(Palette.wood, 0.6))
        love.graphics.rectangle("fill", x + 3, y + 11, 3, 4)
        love.graphics.rectangle("fill", x + w - 6, y + 11, 3, 4)
    elseif kind == "rack" then
        color(Palette.wood)
        love.graphics.rectangle("fill", x, y + 10, w, 4)
        color(Palette.muted)
        for px = x + 4, x + w - 4, 7 do
            love.graphics.rectangle("fill", px, y + 1, 2, 12)
        end
    else -- crate / barrel
        color(Palette.wood)
        if kind == "barrel" then
            love.graphics.circle("fill", x + w / 2, y + h / 2, w / 2 - 1)
            color(shade(Palette.wood, 0.6))
            love.graphics.circle("line", x + w / 2, y + h / 2, w / 2 - 4)
        else
            love.graphics.rectangle("fill", x + 1, y + 1, w - 2, h - 2)
            color(shade(Palette.wood, 0.6))
            love.graphics.rectangle("line", x + 1.5, y + 1.5, w - 3, h - 3)
            love.graphics.line(x + 2, y + 2, x + w - 2, y + h - 2)
        end
    end
end

local function drawIconPlaceholder(assets, building, accent, x, y)
    if MapAssets.drawIcon(assets, building.icon, x, y) then return end
    -- Placeholder icon: the initial of whoever waits there (G for the hall),
    -- so the five locations never share a glyph.
    local who = building.dragonId and dragons[building.dragonId].name or building.label
    color(accent)
    love.graphics.rectangle("fill", x, y, 14, 14, 2, 2)
    Draw.text(who:sub(1, 1), x, y + 1, 14, "center", 10, Palette.black)
end

local function drawDoor(assets, door, side, accent, kind)
    local tile = kind == "gate" and "door_arch" or "door_wood"
    if MapAssets.drawTerrain(assets, tile, door.x, door.y) then return end
    if kind == "yard" then
        color(Palette.path)
        love.graphics.rectangle("fill", door.x, door.y, door.w, door.h)
        color(Palette.wood)
        love.graphics.rectangle("fill", door.x + door.w - 3, door.y - 2, 3, 3)
        love.graphics.rectangle("fill", door.x + door.w - 3, door.y + door.h - 1, 3, 3)
        return
    end
    color(Palette.door)
    love.graphics.rectangle("fill", door.x + 2, door.y + 2, door.w - 4, door.h - 2)
    color(accent)
    love.graphics.rectangle("line", door.x + 1.5, door.y + 1.5, door.w - 3, door.h - 2)
end

local function drawBuildingBody(building, accent)
    local x, y, w, h = building.x, building.y, building.w, building.h
    local kind = building.kind
    if kind == "yard" then
        color(Palette.grass)
        love.graphics.rectangle("fill", x, y, w, h)
        color(shade(Palette.path, 0.85))
        love.graphics.rectangle("fill", x + 8, y + 26, w - 16, h - 34)
        color(Palette.wood)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x + 2, y + 2, w - 4, h - 4)
        love.graphics.setLineWidth(1)
        for i = 0, 2 do -- training dummies
            local dx, dy = x + 30 + i * 36, y + 46 + (i % 2) * 12
            love.graphics.rectangle("fill", dx, dy, 3, 16)
            love.graphics.rectangle("fill", dx - 5, dy + 4, 13, 3)
            color(accent)
            love.graphics.circle("fill", dx + 1.5, dy - 2, 3)
            color(Palette.wood)
        end
        return
    end

    color(shade(accent, 0.22))
    love.graphics.rectangle("fill", x, y, w, h)
    color(shade(accent, 0.62))
    love.graphics.rectangle("fill", x, y, w, 20)

    if kind == "arena" then
        color(Palette.path)
        love.graphics.ellipse("fill", x + w / 2 + 6, y + 60, w / 2 - 22, 26)
        color(accent, 0.8)
        love.graphics.ellipse("line", x + w / 2 + 6, y + 60, w / 2 - 22, 26)
    elseif kind == "gate" then
        color(Palette.wall)
        love.graphics.rectangle("fill", x, y, 24, h)
        love.graphics.rectangle("fill", x + w - 24, y, 24, h)
        color(accent)
        love.graphics.rectangle("fill", x, y, 24, 5)
        love.graphics.rectangle("fill", x + w - 24, y, 24, 5)
    elseif kind == "forge" then
        color(Palette.wall)
        love.graphics.rectangle("fill", x + w - 26, y + 22, 14, 14)
        color(accent)
        love.graphics.rectangle("fill", x + w - 23, y + 25, 8, 8)
    elseif kind == "archive" then
        color(accent, 0.75)
        for i = 0, 3 do
            love.graphics.rectangle("fill", x + 12 + i * 30, y + 56, 10, 12)
        end
    elseif kind == "hall" then
        color(Palette.warning, 0.8)
        love.graphics.rectangle("fill", x + 14, y + 22, 8, 40)
        love.graphics.rectangle("fill", x + w - 22, y + 22, 8, 40)
    end

    color(accent)
    love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1)
end

local function drawBuilding(assets, building, poi, highlighted)
    local accent = accentOf(poi)
    if not MapAssets.drawFacade(assets, building) then
        drawBuildingBody(building, accent)
    end
    drawDoor(assets, poi.door, poi.door.side, accent, building.kind)

    -- Sign: icon + place + who is waiting there. Readability over detail.
    local signY = building.kind == "yard" and building.y + 6 or building.y + 3
    local signX = building.x + 6
    if building.kind == "gate" then signX, signY = building.x + 28, building.y + 20 end
    local signW = building.kind == "gate" and building.w - 56 or building.w - 12
    if building.kind == "gate" then
        Draw.text(building.label, signX, signY, signW, "center", 11, Palette.ink)
        Draw.text(dragons[building.dragonId].name, signX, signY + 13, signW, "center", 9, accent)
    else
        color(Palette.black, 0.55)
        love.graphics.rectangle("fill", signX, signY, signW, 15, 2, 2)
        drawIconPlaceholder(assets, building, accent, signX, signY)
        Draw.text(building.label, signX + 16, signY + 1, signW - 18, "left", 11, Palette.ink)
        if building.dragonId then
            Draw.text(dragons[building.dragonId].name, signX + 16, signY + 2, signW - 20, "right", 9, accent)
        end
    end

    if highlighted then
        love.graphics.setLineWidth(2)
        color(accent)
        love.graphics.rectangle("line", building.x - 1, building.y - 1, building.w + 2, building.h + 2)
        love.graphics.setLineWidth(1)
    end
end

local function drawInteractionZone(poi, highlighted)
    local r = poi.interactionRect
    local accent = accentOf(poi)
    if highlighted then
        color(accent, 0.22)
        love.graphics.rectangle("fill", r.x, r.y, r.w, r.h, 2, 2)
        color(accent, 0.9)
        love.graphics.rectangle("line", r.x + 0.5, r.y + 0.5, r.w - 1, r.h - 1, 2, 2)
    else
        -- Small doormat so every visitable spot is readable at a glance.
        local cx, cy = r.x + r.w / 2, r.y + r.h / 2
        color(accent, 0.55)
        love.graphics.rectangle("fill", cx - 3, cy - 3, 6, 6, 1, 1)
    end
end

local function drawPlayer(assets, position, collider, player)
    local x, y = math.floor(position.x + 0.5), math.floor(position.y + 0.5)
    color(Palette.black, 0.35)
    love.graphics.ellipse("fill", x + collider.w / 2, y + collider.h - 1, collider.w / 2 + 1, 3)

    local frame = player.moving and (math.floor(player.animTime * 8) % MapAssets.PLAYER_FRAME.frames) or 0
    local spriteX = x + math.floor((collider.w - MapAssets.PLAYER_FRAME.w) / 2)
    local spriteY = y + collider.h - MapAssets.PLAYER_FRAME.h
    if MapAssets.drawPlayer(assets, player.facing, frame, spriteX, spriteY) then return end

    color(Palette.ink)
    love.graphics.rectangle("fill", x, y, collider.w, collider.h, 2, 2)
    color(Palette.warning)
    love.graphics.rectangle("fill", x, y, collider.w, 5, 2, 2)
    color(Palette.black)
    local fx, fy = x + collider.w / 2 - 1, y + 7
    if player.facing == "left" then fx = x + 1
    elseif player.facing == "right" then fx = x + collider.w - 3
    elseif player.facing == "up" then fy = y + 1 end
    love.graphics.rectangle("fill", fx, fy, 2, 2)
end

local function drawHud(state, runState)
    Draw.text(state.title:upper(), 22, 2, 300, "left", 10, Palette.ink)
    Draw.text(("Week %d / %d"):format(runState.week, rules.maxWeeks), 318, 2, 300, "right", 10, Palette.muted)

    color(Palette.black, 0.9)
    love.graphics.rectangle("fill", 0, map.height, 640, 400 - map.height)
    if state.nearby then
        Draw.text(state.prompt, 12, map.height + 8, 616, "center", 13, accentOf(state.nearby))
    else
        Draw.text("Walk up to a door to visit someone.", 12, map.height + 9, 616, "center", 11, Palette.muted)
    end
    Draw.text("Arrows/WASD: move  |  Enter/Space: visit  |  Backspace: back to collection",
        12, map.height + 28, 616, "center", 10, Palette.dim)
end

function MapRenderSystem.draw(scene)
    local registry = scene.registry
    local state = registry:resource("mapState")
    local runState = registry:resource("runState")
    local assets = state.assets or {}
    Draw.clear()

    drawGround(assets)
    for _, position, terrain in registry:each("worldPosition", "terrain") do
        drawTerrain(assets, position, terrain)
    end
    for _, position, collider in registry:each("worldPosition", "collider", "wall") do
        drawWall(assets, position, collider)
    end
    for _, poi in registry:each("pointOfInterest") do
        drawInteractionZone(poi, poi == state.nearby)
    end
    for _, position, collider, obstacle in registry:each("worldPosition", "collider", "obstacle") do
        drawObstacle(assets, position, collider, obstacle)
    end
    for _, building, poi in registry:each("building", "pointOfInterest") do
        drawBuilding(assets, building, poi, poi == state.nearby)
    end

    local position = registry:get(state.player, "worldPosition")
    local collider = registry:get(state.player, "collider")
    local player = registry:get(state.player, "player")
    drawPlayer(assets, position, collider, player)

    drawHud(state, runState)
    love.graphics.setColor(1, 1, 1, 1)
end

return MapRenderSystem
