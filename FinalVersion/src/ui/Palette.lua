local function hex(value)
    local r = tonumber(value:sub(2, 3), 16)
    local g = tonumber(value:sub(4, 5), 16)
    local b = tonumber(value:sub(6, 7), 16)
    return { r / 255, g / 255, b / 255 }
end

return {
    bg = { 0.063, 0.063, 0.078 },
    panel = { 0.102, 0.102, 0.125 },
    panel2 = { 0.14, 0.14, 0.17 },
    ink = { 0.91, 0.91, 0.91 },
    muted = { 0.66, 0.66, 0.70 },
    dim = { 0.34, 0.34, 0.38 },
    black = { 0.02, 0.02, 0.025 },
    challenge = { 0.94, 0.28, 0.10 },
    wit = { 0.14, 0.62, 0.91 },
    connection = { 0.22, 0.78, 0.45 },
    warning = { 0.96, 0.77, 0.20 },
    bad = { 0.90, 0.20, 0.26 },

    -- Map placeholder tokens. These hex values match assets/map/heartscale_map.gpl,
    -- so placeholder and final art stay compatible.
    grass = hex("#26352A"),
    grassDark = hex("#1F2C23"),
    path = hex("#6B5843"),
    pathEdge = hex("#54453A"),
    plaza = hex("#45454F"),
    plazaLine = hex("#55555F"),
    wall = hex("#363040"),
    wallTop = hex("#544C5E"),
    wood = hex("#7A5636"),
    leaf = hex("#2F5E3A"),
    water = hex("#2E5E8C"),
    door = hex("#140F12"),
}
