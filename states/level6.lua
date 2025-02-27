local level6 = {}

function level6:enter()
    self.background = love.graphics.newImage("assets/cutscenes/arabic/6.png")
end

function level6:update(dt)
end

function level6:keypressed(key)
    -- if key == "space" then
    --     GameState.switch(transition, cutscene, 0.5, true)
    -- end
end

function level6:draw()
    love.graphics.draw(self.background, 0, 0)
end

return level6
