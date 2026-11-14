-- Optional pixel-art assets for the guild map.
-- The contract lives in LIBRESPRITE_ASSET_BRIEF.md. Every file is optional:
-- a missing, unreadable or wrongly sized file is ignored and the renderer
-- falls back to primitive placeholders, so missing art never breaks the game.
local MapAssets = {}

MapAssets.DIR = "assets/map/"

MapAssets.SPEC = {
    terrain = { file = "terrain_atlas.png", w = 128, h = 80 },
    facades = { file = "facades_atlas.png", w = 480, h = 192 },
    player = { file = "player.png", w = 64, h = 96 },
    icons = { file = "poi_icons.png", w = 96, h = 16 },
}

-- terrain_atlas.png: 8 columns x 5 rows of 16x16 tiles. { col, row } in tiles.
MapAssets.TERRAIN = {
    grass_a = { 0, 0 }, grass_b = { 1, 0 }, grass_flowers = { 2, 0 },
    path = { 3, 0 }, path_alt = { 4, 0 },
    plaza_a = { 5, 0 }, plaza_b = { 6, 0 }, plaza_crack = { 7, 0 },
    wall_top = { 0, 1 }, wall_face = { 1, 1 }, wall_corner = { 2, 1 },
    fence = { 3, 1 }, fence_post = { 4, 1 },
    door_wood = { 5, 1 }, door_arch = { 6, 1 }, shadow = { 7, 1 },
    crate = { 0, 2 }, barrel = { 1, 2 }, tree = { 2, 2 },
    bench_left = { 3, 2 }, bench_right = { 4, 2 },
    rack_left = { 5, 2 }, rack_right = { 6, 2 }, dummy = { 7, 2 },
    well = { 0, 3, 2, 2 }, -- 32x32 block spanning columns 0-1, rows 3-4
}

-- facades_atlas.png: 3x2 cells of 160x96; each facade sits at its cell's
-- top-left corner with the exact footprint size of its building in map.lua.
MapAssets.FACADE_CELL = { w = 160, h = 96 }

-- player.png: columns are frames 0-3, rows are directions.
MapAssets.PLAYER_FRAME = { w = 16, h = 24, frames = 4 }
MapAssets.PLAYER_ROWS = { down = 0, left = 1, right = 2, up = 3 }

local cache = nil

local function available()
    return love and love.graphics and love.graphics.newImage
        and love.filesystem and love.filesystem.getInfo
end

local function loadImage(spec)
    local path = MapAssets.DIR .. spec.file
    if not love.filesystem.getInfo(path, "file") then return nil end
    local ok, image = pcall(love.graphics.newImage, path)
    if not ok or not image then
        print("[map assets] could not load " .. path .. ", using placeholders")
        return nil
    end
    if image:getWidth() ~= spec.w or image:getHeight() ~= spec.h then
        print(("[map assets] %s is %dx%d, expected %dx%d; using placeholders"):format(
            path, image:getWidth(), image:getHeight(), spec.w, spec.h))
        return nil
    end
    image:setFilter("nearest", "nearest")
    return image
end

function MapAssets.load()
    if cache then return cache end
    cache = {}
    if not available() then return cache end
    for key, spec in pairs(MapAssets.SPEC) do
        cache[key] = loadImage(spec)
    end
    return cache
end

function MapAssets.reset()
    cache = nil
end

local quads = {}

-- Images are tinted by the current color, so always draw them untinted.
local function untinted()
    love.graphics.setColor(1, 1, 1, 1)
end

local function quad(image, x, y, w, h)
    local key = tostring(image) .. ":" .. x .. ":" .. y .. ":" .. w .. ":" .. h
    if not quads[key] then
        quads[key] = love.graphics.newQuad(x, y, w, h, image:getWidth(), image:getHeight())
    end
    return quads[key]
end

function MapAssets.drawTerrain(assets, name, x, y)
    local cell = MapAssets.TERRAIN[name]
    if not (assets.terrain and cell) then return false end
    local w, h = (cell[3] or 1) * 16, (cell[4] or 1) * 16
    untinted()
    love.graphics.draw(assets.terrain, quad(assets.terrain, cell[1] * 16, cell[2] * 16, w, h), x, y)
    return true
end

function MapAssets.drawFacade(assets, building)
    if not (assets.facades and building.facade) then return false end
    local cx = building.facade.col * MapAssets.FACADE_CELL.w
    local cy = building.facade.row * MapAssets.FACADE_CELL.h
    untinted()
    love.graphics.draw(assets.facades, quad(assets.facades, cx, cy, building.w, building.h), building.x, building.y)
    return true
end

function MapAssets.drawPlayer(assets, facing, frame, x, y)
    if not assets.player then return false end
    local f = MapAssets.PLAYER_FRAME
    local row = MapAssets.PLAYER_ROWS[facing] or 0
    untinted()
    love.graphics.draw(assets.player, quad(assets.player, frame * f.w, row * f.h, f.w, f.h), x, y)
    return true
end

function MapAssets.drawIcon(assets, index, x, y)
    if not (assets.icons and index) then return false end
    untinted()
    love.graphics.draw(assets.icons, quad(assets.icons, (index - 1) * 16, 0, 16, 16), x, y)
    return true
end

return MapAssets
