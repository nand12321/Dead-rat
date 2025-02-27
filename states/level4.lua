local level4 = {}

function level4:enter()
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
    self.map = sti("states/levelsData/level4.lua")
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

    -- Static objects --
    self.grounds = {} -- Grounds player can jump on
    if self.map.layers["ground"].objects then
        for i, obj in pairs(self.map.layers["ground"].objects) do
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

    self.platforms = {} -- Player cannot jump on these
    if self.map.layers["wall"].objects then
        for i, obj in pairs(self.map.layers["wall"].objects) do
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

    self.spikes = {} -- spikes will kill the player
    if self.map.layers["spike"].objects then
        for i, obj in pairs(self.map.layers["spike"].objects) do
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
    self.player = player(self.world, 600, 200)
    -- self.player.sleep = false
    self.enemys = {
        enemy(self.world, 320, 200, 35, 400, "left"),
        enemy(self.world, 90, 100, 40, 340, "right")
    }
end

function level4:update(dt)
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
            GameState.switch(transition, level5, 0.5, true)
        end
    end
    
    if self.player.isDead == true then
        if self.restartTimer < 0 then
            GameState.switch(transition, level4, 0.5, true)
        else
            self.player.collider:setCollisionClass("ghost")
            self.gamePlay = false
            self.restartTimer = self.restartTimer - dt
        end
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
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

function level4:draw()
    love.graphics.push()
    love.graphics.scale(2)

    love.graphics.draw( self.background, 0, 0)
    for i, v in ipairs(self.backgroundLights) do
        love.graphics.draw(v.sprite, v.x, v.y)
    end

    self.map:drawLayer(self.map.layers["map"])
    self.player:draw()
    for _, enemy in ipairs(self.enemys) do
        enemy:draw()
    end
    -- self.world:draw()
    love.graphics.pop()
end

return level4
