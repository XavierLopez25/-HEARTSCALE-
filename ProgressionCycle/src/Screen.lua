local Screen = {
    width = 640,
    height = 400,
    scale = 1,
    ox = 0,
    oy = 0,
    canvas = nil,
}

function Screen.setup(width, height)
    Screen.width = width
    Screen.height = height
    Screen.canvas = love.graphics.newCanvas(width, height)
    Screen.resize(love.graphics.getDimensions())
end

function Screen.resize(windowWidth, windowHeight)
    Screen.scale = math.max(1, math.floor(math.min(windowWidth / Screen.width, windowHeight / Screen.height)))
    Screen.ox = math.floor((windowWidth - Screen.width * Screen.scale) / 2)
    Screen.oy = math.floor((windowHeight - Screen.height * Screen.scale) / 2)
end

function Screen.begin()
    love.graphics.setCanvas(Screen.canvas)
    love.graphics.clear()
end

function Screen.finish()
    love.graphics.setCanvas()
    love.graphics.setColor(0.02, 0.02, 0.025, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Screen.canvas, Screen.ox, Screen.oy, 0, Screen.scale, Screen.scale)
end

return Screen
