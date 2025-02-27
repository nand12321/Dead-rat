local startMenu = {}

function startMenu:enter()
    self.background = love.graphics.newImage("assets/tileset/background.png")
    self.backgroundLight = love.graphics.newImage("assets/tileset/background-light.png")
    self.backgroundLights = {}
    self.backgroundTimer = 0
    self.backgroundStartX = 1300
    self.backgroundStartY = 1300
    for i = 0, 100 do
        table.insert(self.backgroundLights, {x = self.backgroundStartX, y = self.backgroundStartY, sprite = self.backgroundLight})
        self.backgroundStartX = self.backgroundStartX - 100
        self.backgroundStartY = self.backgroundStartY - 100
    end
end

function startMenu:update(dt)
    -- background stuff --
    if self.backgroundTimer < 0 then
        table.insert(self.backgroundLights, {x = 1300, y = 1300, sprite = self.backgroundLight})
        self.backgroundTimer = 1
    else
        self.backgroundTimer = self.backgroundTimer - dt
    end

    for i = #self.backgroundLights, 1, -1 do
        local v = self.backgroundLights[i]
        if v.x < -1300 then
            table.remove(self.backgroundLights, i)
        else
            v.x = v.x - 100 * dt
            v.y = v.y - 100 * dt
        end
    end
end

function startMenu:keypressed(key)
    if key == "space" then
        GameState.switch(transition, cutscene, 0.5, true)
    end
end

function startMenu:draw()
    love.graphics.push()
    love.graphics.scale(2)

    love.graphics.draw( self.background, 0, 0)
    for i, v in ipairs(self.backgroundLights) do
        love.graphics.draw(v.sprite, v.x, v.y)
    end

    love.graphics.print("Press Space to Start", 100, 100)

    love.graphics.pop()
end

return startMenu
