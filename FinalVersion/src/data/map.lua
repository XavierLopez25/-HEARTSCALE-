-- Single source of truth for the Iron Scale Guild map.
-- Coordinates are logical pixels on the 640x400 canvas. The world uses a
-- 16 px grid of 40x22 tiles (640x352); the remaining 48 px hold the footer.
-- Every rectangle is { x, y, w, h } with x/y at the top-left corner.

local map = {
    title = "Iron Scale Guild",
    tileSize = 16,
    cols = 40,
    rows = 22,
    width = 640,
    height = 352,
    returnScene = "collection",

    -- Walkable area inside the perimeter wall. The player can never leave it.
    bounds = { x = 16, y = 16, w = 608, h = 320 },

    -- The protagonist appears on the road in front of the Guild Hall door,
    -- just outside its interaction zone.
    spawn = { x = 314, y = 124, facing = "down" },

    player = { w = 12, h = 16, speed = 95 },

    -- Perimeter wall (solid).
    walls = {
        { id = "wall_north", x = 0, y = 0, w = 640, h = 16 },
        { id = "wall_south", x = 0, y = 336, w = 640, h = 16 },
        { id = "wall_west", x = 0, y = 16, w = 16, h = 320 },
        { id = "wall_east", x = 624, y = 16, w = 16, h = 320 },
    },

    -- Visual ground layers (never solid). Drawn in order over the grass.
    terrain = {
        { id = "north_road", kind = "path", x = 48, y = 96, w = 544, h = 32 },
        { id = "courtyard", kind = "plaza", x = 208, y = 128, w = 224, h = 144 },
        { id = "yard_path", kind = "path", x = 192, y = 208, w = 16, h = 32 },
        { id = "arena_path", kind = "path", x = 432, y = 208, w = 16, h = 32 },
        { id = "gate_path", kind = "path", x = 304, y = 272, w = 32, h = 16 },
    },

    -- Buildings are solid. Each one is a point of interest whose interaction
    -- zone sits in front of its door, outside every collider.
    -- facade = cell in facades_atlas.png, icon = column in poi_icons.png.
    buildings = {
        {
            id = "guild_hall",
            kind = "hall",
            label = "Guild Hall",
            action = "collection",
            x = 256, y = 16, w = 128, h = 80,
            door = { x = 312, y = 80, w = 16, h = 16, side = "bottom" },
            interaction = { x = 296, y = 96, w = 48, h = 20 },
            facade = { col = 0, row = 0 },
            icon = 6,
        },
        {
            id = "forge",
            kind = "forge",
            label = "Forge",
            dragonId = "kaela",
            x = 48, y = 16, w = 128, h = 80,
            door = { x = 104, y = 80, w = 16, h = 16, side = "bottom" },
            interaction = { x = 88, y = 96, w = 48, h = 20 },
            facade = { col = 1, row = 0 },
            icon = 1,
        },
        {
            id = "archive",
            kind = "archive",
            label = "Archive",
            dragonId = "nyxara",
            x = 464, y = 16, w = 128, h = 80,
            door = { x = 520, y = 80, w = 16, h = 16, side = "bottom" },
            interaction = { x = 504, y = 96, w = 48, h = 20 },
            facade = { col = 2, row = 0 },
            icon = 4,
        },
        {
            id = "training_yard",
            kind = "yard",
            label = "Training Yard",
            dragonId = "veyra",
            x = 48, y = 176, w = 144, h = 96,
            door = { x = 176, y = 216, w = 16, h = 16, side = "right" },
            interaction = { x = 192, y = 208, w = 20, h = 32 },
            facade = { col = 0, row = 1 },
            icon = 2,
        },
        {
            id = "arena",
            kind = "arena",
            label = "Arena",
            dragonId = "sarka",
            x = 448, y = 176, w = 144, h = 96,
            door = { x = 448, y = 216, w = 16, h = 16, side = "left" },
            interaction = { x = 428, y = 208, w = 20, h = 32 },
            facade = { col = 1, row = 1 },
            icon = 3,
        },
        {
            id = "gate",
            kind = "gate",
            label = "Gate",
            dragonId = "aurelia",
            x = 272, y = 288, w = 96, h = 48,
            door = { x = 312, y = 288, w = 16, h = 16, side = "top" },
            interaction = { x = 296, y = 268, w = 48, h = 20 },
            facade = { col = 2, row = 1 },
            icon = 5,
        },
    },

    -- Solid props. None of them blocks a door or a route between doors.
    obstacles = {
        { id = "well", kind = "well", x = 304, y = 184, w = 32, h = 32 },
        { id = "forge_crate", kind = "crate", x = 192, y = 32, w = 16, h = 16 },
        { id = "forge_barrel", kind = "barrel", x = 224, y = 56, w = 16, h = 16 },
        { id = "archive_crate", kind = "crate", x = 400, y = 56, w = 16, h = 16 },
        { id = "archive_barrel", kind = "barrel", x = 432, y = 32, w = 16, h = 16 },
        { id = "bench_west", kind = "bench", x = 224, y = 144, w = 32, h = 16 },
        { id = "bench_east", kind = "bench", x = 384, y = 144, w = 32, h = 16 },
        { id = "fence_south_west", kind = "fence", x = 208, y = 272, w = 80, h = 8 },
        { id = "fence_south_east", kind = "fence", x = 352, y = 272, w = 80, h = 8 },
        { id = "tree_sw_1", kind = "tree", x = 64, y = 296, w = 16, h = 16 },
        { id = "tree_sw_2", kind = "tree", x = 144, y = 304, w = 16, h = 16 },
        { id = "tree_sw_3", kind = "tree", x = 224, y = 296, w = 16, h = 16 },
        { id = "tree_se_1", kind = "tree", x = 416, y = 296, w = 16, h = 16 },
        { id = "tree_se_2", kind = "tree", x = 496, y = 304, w = 16, h = 16 },
        { id = "weapon_rack", kind = "rack", x = 560, y = 296, w = 32, h = 16 },
    },
}

function map.building(id)
    for _, building in ipairs(map.buildings) do
        if building.id == id then return building end
    end
end

function map.buildingForDragon(dragonId)
    for _, building in ipairs(map.buildings) do
        if building.dragonId == dragonId then return building end
    end
end

-- Every solid rectangle in the map: walls, buildings and obstacles.
function map.solids()
    local result = {}
    for _, group in ipairs({ map.walls, map.buildings, map.obstacles }) do
        for _, rect in ipairs(group) do
            result[#result + 1] = { id = rect.id, x = rect.x, y = rect.y, w = rect.w, h = rect.h }
        end
    end
    return result
end

return map
