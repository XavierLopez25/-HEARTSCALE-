local RunState = require("src.state.RunState")
local dragons = require("src.data.dragons")
local Draw = require("src.ui.Draw")
local Palette = require("src.ui.Palette")

local DialogueUISystem = { name = "dialogueUI" }

local CHOICES = {
    { label = "Challenge", affection = 1, line = "You meet her energy and turn the exchange into a clean challenge." },
    { label = "Listen", affection = 1, line = "You stop trying to impress her and listen for what she actually means." },
    { label = "Joke", affection = 0, line = "You cut the tension with a joke and let the moment breathe." },
}

local function move(ui, amount)
    ui.cursor = (ui.cursor - 1 + amount) % #ui.choices + 1
end

function DialogueUISystem.setup(scene)
    scene.registry:setResource("dialogueUI", {
        cursor = 1,
        choices = CHOICES,
        phase = "choosing",
        response = "Pick a response style. The UI updates affection and stores the last choice.",
    })
end

function DialogueUISystem.update(scene)
    local ui = scene.registry:resource("dialogueUI")
    local run = RunState.get()
    for _, event in scene.registry:each("keyPressed") do
        if ui.phase == "choosing" then
            if event.key == "up" or event.key == "left" then
                move(ui, -1)
            elseif event.key == "down" or event.key == "right" then
                move(ui, 1)
            elseif event.key == "return" or event.key == "space" then
                local choice = ui.choices[ui.cursor]
                run.lastDialogueChoice = choice.label
                run.affection[run.selectedDragon] = (run.affection[run.selectedDragon] or 0) + choice.affection
                ui.response = choice.line
                ui.phase = "result"
            elseif event.key == "escape" then
                scene.registry:spawn({ switchRequest = true, to = "dragonSelect" })
            end
        elseif event.key == "return" or event.key == "space" then
            scene.registry:spawn({ switchRequest = true, to = "title" })
        end
    end
end

function DialogueUISystem.draw(scene)
    local ui = scene.registry:resource("dialogueUI")
    local run = RunState.get()
    local dragon = dragons[run.selectedDragon]

    Draw.clear()
    Draw.text("DIALOGUE UI", 20, 18, 260, "left", 22)
    Draw.text("Affection " .. (run.affection[run.selectedDragon] or 0), 446, 24, 160, "right", 12, Palette.warning)
    Draw.portrait(dragon, 34, 72, 132, 172)
    Draw.panel(194, 72, 392, 96)
    Draw.text(dragon.name .. " - " .. dragon.place, 210, 86, 360, "left", 14, dragon.accent)
    Draw.text(dragon.greeting, 210, 112, 360, "left", 11, Palette.ink)

    Draw.panel(194, 190, 392, 82, ui.phase == "result")
    Draw.text(ui.response, 210, 206, 360, "left", 11, ui.phase == "result" and Palette.ink or Palette.muted)

    for i, choice in ipairs(ui.choices) do
        Draw.button(choice.label, 108 + (i - 1) * 146, 304, 126, 28, ui.phase == "choosing" and ui.cursor == i, dragon.accent)
    end

    if ui.phase == "result" then
        Draw.footer("Enter: return to main menu")
    else
        Draw.footer("Arrows: choose response  |  Enter: select  |  Esc: back")
    end
end

return DialogueUISystem
