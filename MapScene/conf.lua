local Screen = require("src.Screen")

function love.conf(t)
    t.identity = "heartscale"
    t.window.title = "Heartscale"
    t.window.width = Screen.w * 2
    t.window.height = Screen.h * 2
    t.window.resizable = true
    t.version = "11.5"
end
