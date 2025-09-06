local level5 = {}

-- Constants
local BG_LIGHT_START_X = 1300
local BG_LIGHT_START_Y = 1300
local BG_LIGHT_SPEED = 100
local BG_LIGHT_REMOVE_X = -1300
local BG_LIGHT_MAX = 120
local BG_LIGHT_INTERVAL = 1

function level5:enter()
    self.gamePlay = true
    self.restartTimer = 2

    -- Initialize world and map
    self.world = wf.newWorld(0, 2000, true)
    self.world:addCollisionClass("ground")
    self.world:addCollisionClass("platform")
    self.world:addCollisionClass("spike")
    self.world:addCollisionClass("door")
    self.world:addCollisionClass("player")
    self.world:addCollisionClass("enemy")
    self.world:addCollisionClass("sleep")
    self.world:addCollisionClass("ghost")
    self.world:addCollisionClass('check area', {ignores = {'ground', "platform", "sleep", "enemy", "ghost"}})

    -- Initialize the tilemap
    self.map = sti("states/levelsData/level5.lua")
    self.background = love.graphics.newImage("assets/tileset/background.png")
    self.backgroundLight = love.graphics.newImage("assets/tileset/background-light.png")
    self.backgroundLights = {}
    self.backgroundTimer = 0

    -- Pre-populate background lights
    local x, y = BG_LIGHT_START_X, BG_LIGHT_START_Y
    for i = 1, 100 do
        table.insert(self.backgroundLights, {x = x, y = y, sprite = self.backgroundLight})
        x = x - BG_LIGHT_SPEED
        y = y - BG_LIGHT_SPEED
    end

    -- Static objects --
    self.grounds = {}
    if self.map.layers["ground"].objects then
        for i, obj in ipairs(self.map.layers["ground"].objects) do
            if obj.width > 0 and obj.height > 0 then
                local ground = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
                ground:setType("static")
                ground:setCollisionClass("ground")
                table.insert(self.grounds, ground)
            else
                print("Invalid dimensions for object at index " .. i)
            end
        end
    end

    self.platforms = {}
    if self.map.layers["wall"].objects then
        for i, obj in ipairs(self.map.layers["wall"].objects) do
            if obj.width > 0 and obj.height > 0 then
                local platform = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
                platform:setType("static")
                platform:setCollisionClass("platform")
                table.insert(self.platforms, platform)
            else
                print("Invalid dimensions for object at index " .. i)
            end
        end
    end

    self.spikes = {}
    if self.map.layers["spike"].objects then
        for i, obj in ipairs(self.map.layers["spike"].objects) do
            if obj.width > 0 and obj.height > 0 then
                local spike = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
                spike:setType("static")
                spike:setCollisionClass("spike")
                table.insert(self.spikes, spike)
            else
                print("Invalid dimensions for object at index " .. i)
            end
        end
    end

    -- door
    if self.map.layers["door"].objects then
        local obj = self.map.layers["door"].objects[1]
        self.door = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        self.door:setType("static")
    end

    -- Entities --
    self.player = player(self.world, 50, 0)
    self.enemys = {
        enemy(self.world, 200, 100, 100, 400, "right"),
        enemy(self.world, 500, 200, 40, 400, "left")
    }
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

function level5:update(dt)
    self.world:update(dt)
    if self.gamePlay then
        self.player:update(dt)
        for _, enemy in ipairs(self.enemys) do
            enemy:update(dt)
        end

        if self.player.collider:getY() > love.graphics.getHeight() then
            self.player.isDead = true
        end

        if self.door:enter("player") then
            sounds.door:play()
            GameState.switch(transition, level6, 0.5, true)
        end
    end

    if self.player.isDead == true then
        if self.restartTimer < 0 then
            GameState.switch(transition, level5, 0.5, true)
        else
            self.player.collider:setCollisionClass("ghost")
            self.gamePlay = false
            self.restartTimer = self.restartTimer - dt
        end
    end

    updateBackgroundLights(self, dt)
end

function level5:draw()
    love.graphics.push()
    love.graphics.scale(2)

    love.graphics.draw(self.background, 0, 0)
    for _, v in ipairs(self.backgroundLights) do
        love.graphics.draw(v.sprite, v.x, v.y)
    end

    self.map:drawLayer(self.map.layers["map"])
    self.player:draw()
    for _, enemy in ipairs(self.enemys) do
        enemy:draw()
    end

    love.graphics.pop()
end

return level5
