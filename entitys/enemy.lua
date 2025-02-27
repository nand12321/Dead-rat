enemy = Object:extend(Object)

function enemy:new(world, x, y, movement, watchArea, direction)
    self.world = world
    self.x = x
    self.y = y
    self.sprite = love.graphics.newImage("assets/player/idle/right/player1.png")
    self.sprite:setFilter("nearest", "nearest")
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
    self.collider = world:newBSGRectangleCollider(self.x, self.y-20, self.width-50, self.height-1, 5)
    self.collider:setType("dynamic")
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass("enemy")
    self.maxSpeed = 30
    self.acceleration = 2100
    self.friction = 3000
    self.dir = direction
    self.movement = movement
    self.spot = self.collider:getX()
    self.timer = 3

    self.animations = {}
    animation:loadAnimation(self.animations,"idleRight", "assets/player/idle/right")
    animation:loadAnimation(self.animations,"idleLeft", "assets/player/idle/left")
    animation:loadAnimation(self.animations,"runRight", "assets/player/run/right")
    animation:loadAnimation(self.animations,"runLeft", "assets/player/run/left")
    animation:loadAnimation(self.animations,"jumpRight", "assets/player/jump/right")
    animation:loadAnimation(self.animations,"jumpLeft", "assets/player/jump/left")

    if self.dir == "right" then
        self.state = "runRight"
    else
        self.state = "runLeft"
    end
    -- check area stuff
    self.checkAreaWidth = watchArea
    self.checkArea = world:newRectangleCollider(self.x+self.checkAreaWidth-self.checkAreaWidth/5, self.y, self.checkAreaWidth, self.height-20)
    self.checkArea:setCollisionClass("check area")
    self.checkArea:setType("static")
end

function enemy:update(dt)
    if self.state == "idleRight" then
        self.sprite = animation:updateAnimation(self.animations.idleRight, 0.07, dt)
    elseif self.state == "idleLeft" then
        self.sprite = animation:updateAnimation(self.animations.idleLeft, 0.07, dt)
    elseif self.state == "runRight" then
        self.sprite = animation:updateAnimation(self.animations.runRight, 0.07, dt)
    elseif self.state == "runLeft" then
        self.sprite = animation:updateAnimation(self.animations.runLeft, 0.07, dt)
    elseif self.state == "jumpRight" then
        self.sprite = animation:updateAnimation(self.animations.jumpRight, 0.07, dt)
    elseif self.state == "jumpLeft" then
        self.sprite = animation:updateAnimation(self.animations.jumpLeft, 0.07, dt)
    end

    local px, py = self.collider:getLinearVelocity()
    local cx, cy = self.collider:getPosition()

    -- update movement direction
    if self.dir == "right" then
        if cx < self.spot + self.movement then
            self.collider:applyForce(self.acceleration, 0)
        else
            if self.timer < 0 then
                self.dir = "left"
                self.state = "runLeft"
                self.timer = 3
            else
                self.state = "idleRight"
                self.timer = self.timer - dt
            end
        end
    elseif self.dir == "left" then
        if cx > self.spot - self.movement then
            self.collider:applyForce(-self.acceleration, 0)
        else
            if self.timer < 0 then
                self.dir = "right"
                self.state = "runRight"
                self.timer = 3
            else
                self.state = "idleLeft"
                self.timer = self.timer - dt
            end
        end
    end

    -- apply friction
    if math.abs(px) > 10 then
        self.collider:applyForce(-px * self.friction * 0.0005, 0)
    elseif math.abs(px) < 10 then
        self.collider:setLinearVelocity(0, py)
    end
    
    -- limit speed
    local speed = math.sqrt(px^2 + py^2)
    if speed > self.maxSpeed then
        local scale = self.maxSpeed / speed
        self.collider:setLinearVelocity(px * scale, py * scale)
    end

    -- update check areas positions
    if self.dir == "right" then
        self.checkArea:setPosition(self.collider:getX() + self.width / 2 + self.checkAreaWidth / 2, self.collider:getY())
    elseif self.dir == "left" then
        self.checkArea:setPosition(self.collider:getX() - self.width / 2 - self.checkAreaWidth / 2, self.collider:getY())
    end
end

function enemy:draw()
    love.graphics.draw(self.sprite, self.collider:getX() - self.width / 2, self.collider:getY() - self.height / 2)
end

return enemy