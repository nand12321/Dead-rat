-- simple animation library created by Icee

-- note: animation images must be alone in the same directory

local animation = {}

function animation:loadAnimation(animationsTable ,animation, imagesfolder)
    animationsTable[animation] = {}
    
    local files = love.filesystem.getDirectoryItems(imagesfolder)
    for i, filename in ipairs(files) do
        local image = love.graphics.newImage(imagesfolder .. "/" .. filename)
        table.insert(animationsTable[animation], image)
    end
end

function animation:updateAnimation(animation, animationSpeed, dt)
    animation.timer = animation.timer or animationSpeed
    animation.frameIndex = animation.frameIndex or 1
    
    animation.timer = animation.timer - 1 * dt
    if animation.timer <= 0 then
        animation.frameIndex = animation.frameIndex + 1
        if animation.frameIndex > #animation then
            animation.frameIndex = 1
        end
        animation.timer = animationSpeed
    end

    return animation[animation.frameIndex]
end

return animation