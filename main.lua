local title = "Game"

function love.load()
    love.graphics.setBackgroundColor(0.08, 0.09, 0.12)
end

function love.update(dt)
    -- Game logic goes here.
end

function love.draw()
    local width, height = love.graphics.getDimensions()

    love.graphics.printf(title, 0, height / 2 - 24, width, "center")
    love.graphics.printf("Edit main.lua to start building.", 0, height / 2 + 12, width, "center")
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
