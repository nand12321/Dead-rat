local startMenu = {}

local BG_LIGHT_START_X = 1300
local BG_LIGHT_START_Y = 1300
local BG_LIGHT_SPEED = 100
local BG_LIGHT_REMOVE_X = -1300
local BG_LIGHT_MAX = 120
local BG_LIGHT_INTERVAL = 1

function startMenu:enter()
    self.background = love.graphics.newImage("assets/tileset/background.png")
    self.backgroundLight = love.graphics.newImage("assets/tileset/background-light.png")
    self.backgroundLights = {}
    self.backgroundTimer = 0
    local x, y = BG_LIGHT_START_X, BG_LIGHT_START_Y
    for i = 1, 100 do
        table.insert(self.backgroundLights, {x = x, y = y, sprite = self.backgroundLight})
        x = x - BG_LIGHT_SPEED
        y = y - BG_LIGHT_SPEED
    end
end

local function updateBackgroundLights(self, dt)
    if self.backgroundTimer < 0 and #self.backgroundLights < BG_LIGHT_MAX then
        table.insert(self.backgroundLights, {x = BG_LIGHT_START_X, y = BG_LIGHT_START_Y, sprite = self.backgroundLight})
        self.backgroundTimer = BG_LIGHT_INTERVAL
    else
        self.backgroundTimer = self.backgroundTimer - dt
    end

    for i = #self.backgroundLights, 1, -1 do
        local v = self.backgroundLights[i]
        if v.x < BG_LIGHT_REMOVE_X then
            table.remove(self.backgroundLights, i)
        else
            v.x = v.x - BG_LIGHT_SPEED * dt
            v.y = v.y - BG_LIGHT_SPEED * dt
        end
    end
end

function startMenu:update(dt)
    updateBackgroundLights(self, dt)
end

function startMenu:keypressed(key)
    if key == "space" then
        GameState.switch(transition, cutscene, 0.5, true)
    end
end

function startMenu:draw()
    love.graphics.push()
    love.graphics.scale(2)

    love.graphics.draw(self.background, 0, 0)
    for _, v in ipairs(self.backgroundLights) do
        love.graphics.draw(v.sprite, v.x, v.y)
    end

    love.graphics.print("Press Space to Start", 100, 100)

    love.graphics.pop()
end

return startMenu
