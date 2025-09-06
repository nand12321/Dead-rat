player = Object:extend(Object)

local JUMP_IMPULSE = -600
local FLIES_TIMER_MAX = 3
local FRICTION_THRESHOLD = 30

function player:new(world, x, y)
    self.gameStarted = false
    self.world = world
    self.x = x
    self.y = y
    self.sprite = love.graphics.newImage("assets/player/idle/right/player1.png")
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
    self.collider = world:newBSGRectangleCollider(self.x, self.y+10, self.width-20, self.height-1, 5)
    self.collider:setType("dynamic")
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass("player")
    self.maxSpeed = 130
    self.acceleration = 8000
    self.friction = 3000
    self.isGround = false
    self.isOnWall = false
    self.sleep = true
    self.isDead = false
    self.enemyWatching = false
    self.isDashActive = true
    self.facing = "right"
    self.state = "idleRight"
    self.animations = {}
    self.wasSleeping = false
    self.fliesTimer = FLIES_TIMER_MAX
    self.currentCollisionClass = "player"

    animation:loadAnimation(self.animations,"idleRight", "assets/player/idle/right")
    animation:loadAnimation(self.animations,"idleLeft", "assets/player/idle/left")
    animation:loadAnimation(self.animations,"runRight", "assets/player/run/right")
    animation:loadAnimation(self.animations,"runLeft", "assets/player/run/left")
    animation:loadAnimation(self.animations,"jumpRight", "assets/player/jump/right")
    animation:loadAnimation(self.animations,"jumpLeft", "assets/player/jump/left")
    animation:loadAnimation(self.animations,"sleep", "assets/player/sleep")
    animation:loadAnimation(self.animations,"flies", "assets/player/flies")
end

function player:update(dt)
    -- Update sprite based on state
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
    elseif self.state == "sleep" then
        self.sprite = animation:updateAnimation(self.animations.sleep, 0.07, dt)
    elseif self.state == "flies" then
        self.sprite = animation:updateAnimation(self.animations.flies, 0.02, dt)
    end

    local px, py = self.collider:getLinearVelocity()

    if not self.isOnWall and not self.sleep then
        if love.keyboard.isDown("right") and px < self.maxSpeed then
            self.facing = "right"
            self.state = "runRight"
            self.collider:applyForce(self.acceleration, 0)
        elseif love.keyboard.isDown("left") and px > -self.maxSpeed then
            self.facing = "left"
            self.state = "runLeft"
            self.collider:applyForce(-self.acceleration, 0)
        else
            if math.abs(px) < FRICTION_THRESHOLD then
                self.collider:setLinearVelocity(0, py)
            elseif px > 10 then
                self.collider:applyForce(-self.friction, 0)
            elseif px < -10 then
                self.collider:applyForce(self.friction, 0)
            end

            if self.facing == "right" and px == 0 and py == 0 then
                self.state = "idleRight"
            elseif self.facing == "left" and px == 0 and py == 0 then
                self.state = "idleLeft"
            end
        end
    end

    if self.collider:enter("ground") then
        self.isGround = true
    elseif self.collider:exit("ground") then
        self.isGround = false
    end

    if self.collider:enter("platform") then
        self.isOnWall = true
    elseif self.collider:exit("platform") then
        self.isOnWall = false
    end

    if not self.sleep and love.keyboard.isDown("up") and self.isGround then
        self.collider:applyLinearImpulse(0, JUMP_IMPULSE)
        sounds.jump:play()
    end

    if not self.isGround then
        if self.facing == "right" then
            self.state = "jumpRight"
        else
            self.state = "jumpLeft"
        end
    end

    -- handle sleep state
    local isSleepKeyPressed = love.keyboard.isDown("x")

    if self.gameStarted then
        if isSleepKeyPressed and not self.wasSleeping then
            sounds.sleep:play()
            self.sleep = true
            self.collider:setCollisionClass("sleep")
        elseif not isSleepKeyPressed then
            self.sleep = false
            self.collider:setCollisionClass("player")
        end
    else
        if isSleepKeyPressed and not self.wasSleeping then
            self.sleep = true
            self.collider:setCollisionClass("sleep")
            self.gameStarted = true
        end
    end

    -- Only set collision class when state changes
    if self.sleep and self.currentCollisionClass ~= "sleep" then
        self.collider:setCollisionClass("sleep")
        self.currentCollisionClass = "sleep"
    elseif not self.sleep and self.currentCollisionClass ~= "player" then
        self.collider:setCollisionClass("player")
        self.currentCollisionClass = "player"
    end

    -- Clamp position instead of impulse for out-of-bounds
    local px, py = self.collider:getX(), self.collider:getY()
    if px < 0 then
        self.collider:setX(0)
    elseif px + self.width > love.graphics.getWidth() then
        self.collider:setX(love.graphics.getWidth() - self.width)
    end

    -- Use constants for timer
    if self.sleep then
        self.state = "sleep"
        if self.fliesTimer < 0 then
            self.state = "flies"
        else
            self.fliesTimer = self.fliesTimer - dt
        end
    else
        self.fliesTimer = FLIES_TIMER_MAX
    end

    if self.collider:enter("enemy") then
        self.isDead = true
    elseif self.collider:enter("check area") and self.sleep == false then
        -- sounds.checkArea:play()
        self.collider:setCollisionClass("ghost")
        self.isDead = true
    end

    if self.collider:enter("spike") then
        self.isDead = true
    end

    self.wasSleeping = isSleepKeyPressed
end

function player:draw()
    love.graphics.draw(self.sprite, self.collider:getX() - self.width / 2, self.collider:getY() - self.height / 2)
end

return player
