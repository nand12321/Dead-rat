local transition = {}

function transition:enter(previous, state, time, fadeOut)
    if fadeOut == true then
        self.previousState = previous
    end
    self.nextState = state
    self.duration = time
    self.alpha = 0
    self.transitioning = true
    self.fadeOut = true
end

function transition:update(dt)
    if self.transitioning then
        if self.fadeOut then
            self.alpha = self.alpha + dt / self.duration
            if self.alpha >= 1 then
                self.alpha = 1
                self.fadeOut = false
                GameState.switch(self.nextState)
            end
        else
            self.alpha = self.alpha - dt / self.duration
            if self.alpha <= 0 then
                self.alpha = 0
                self.transitioning = false
            end
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
