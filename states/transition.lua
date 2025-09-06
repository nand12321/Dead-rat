local transition = {}

function transition:enter(previous, state, time, fadeOut)
    self.previousState = fadeOut and previous or nil
    self.nextState = state
    self.duration = time or 0.5
    self.alpha = 0
    self.transitioning = true
    self.fadeOut = fadeOut
end

function transition:update(dt)
    if not self.transitioning then return end

    if self.fadeOut then
        self.alpha = math.min(self.alpha + dt / self.duration, 1)
        if self.alpha >= 1 then
            self.fadeOut = false
            GameState.switch(self.nextState)
        end
    else
        self.alpha = math.max(self.alpha - dt / self.duration, 0)
        if self.alpha <= 0 then
            self.transitioning = false
        end
    end
end

function transition:draw()
    if self.fadeOut then
        if self.previousState and self.previousState.draw then
            self.previousState:draw()
        end
    else
        if self.nextState and self.nextState.draw then
            self.nextState:draw()
        end
    end

    love.graphics.setColor(0, 0, 0, self.alpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end

return transition
