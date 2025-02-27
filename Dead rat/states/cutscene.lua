local cutscene = {}

function cutscene:enter()
    self.sprites = {
        love.graphics.newImage("assets/cutscenes/arabic/1.png"),
        love.graphics.newImage("assets/cutscenes/arabic/2.png"),
        love.graphics.newImage("assets/cutscenes/arabic/3.png"),
        love.graphics.newImage("assets/cutscenes/arabic/4.png"),
        love.graphics.newImage("assets/cutscenes/arabic/5.png")
    }
    self.spriteIndex = 1
    self.currentSprite = self.sprites[self.spriteIndex]
end

function cutscene:update(dt)
    self.currentSprite = self.sprites[self.spriteIndex]
end

function cutscene:keypressed(key)
    if key == "space" then
        if self.spriteIndex < 5 then
            self.spriteIndex = self.spriteIndex + 1
        else
            GameState.switch(transition, level1, 2, true)
        end
    end
end

function cutscene:draw()
    love.graphics.draw(self.currentSprite, 0, 0)
end

return cutscene
