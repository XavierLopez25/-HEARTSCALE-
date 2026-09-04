local RunState = require("src.state.RunState")
local dragons = require("src.data.dragons")
local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")

local CharacterSelectUISystem = { name = "characterSelectUI" }

local function move(state, amount)
    state.cursor = (state.cursor - 1 + amount) % #dragons.order + 1
end

function CharacterSelectUISystem.setup(scene)
    local run = RunState.get()
    local cursor = 1
    for i, id in ipairs(dragons.order) do
        if id == run.selectedDragon then cursor = i end
    end
    scene.registry:setResource("characterSelectUI", {
        cursor = cursor,
        hint = "Select who you want to meet first.",
    })
end

function CharacterSelectUISystem.update(scene)
    local ui = scene.registry:resource("characterSelectUI")
    local run = RunState.get()
    for _, event in scene.registry:each("keyPressed") do
        if event.key == "left" or event.key == "up" then
            move(ui, -1)
        elseif event.key == "right" or event.key == "down" then
            move(ui, 1)
        elseif event.key == "return" or event.key == "space" then
            run.selectedDragon = dragons.order[ui.cursor]
            scene.registry:spawn({ switchRequest = true, to = "dialogue" })
        elseif event.key == "escape" then
            scene.registry:spawn({ switchRequest = true, to = "title" })
        end
    end
end

function CharacterSelectUISystem.draw(scene)
    local ui = scene.registry:resource("characterSelectUI")
    local run = RunState.get()
    Draw.clear()
    Draw.text("CHOOSE A DRAGON", 20, 18, 260, "left", 22)
    Draw.text("This UI writes the selected dragon into shared game state.", 282, 24, 330, "right", 11, Palette.muted)

    for i, id in ipairs(dragons.order) do
        local dragon = dragons[id]
        local x = 94 + (i - 1) * 154
        Draw.portrait(dragon, x, 78, 118, 154, ui.cursor == i)
        Draw.text("Affection " .. (run.affection[id] or 0), x, 240, 118, "center", 10, Palette.muted)
    end

    local selected = dragons[dragons.order[ui.cursor]]
    Draw.panel(90, 286, 460, 48)
    Draw.text(selected.name .. " - " .. selected.place, 108, 296, 424, "center", 13, selected.accent)
    Draw.text(selected.text, 108, 314, 424, "center", 10, Palette.muted)
    Draw.footer("Arrows: choose  |  Enter: confirm  |  Esc: back")
end

return CharacterSelectUISystem
