-- lib --
Object = require("lib.classic")
sti = require("lib.sti")
wf = require("lib.windfield")
GameState = require("lib.hump.gamestate")

-- systems --
animation = require("systems.animation")

-- entitys --
require("entitys.player")
require("entitys.enemy")

-- states --
startMenu = require("states.startMenu")
transition = require("states.transition")
cutscene = require("states.cutscene")
level1 = require("states.level1")
level2 = require("states.level2")
level3 = require("states.level3")
level4 = require("states.level4")
level5 = require("states.level5")
level6 = require("states.level6")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    GameState.registerEvents()
    GameState.switch(cutscene)

    sounds = {
        jump = love.audio.newSource("assets/sounds/jump.wav", "static"),
        sleep = love.audio.newSource("assets/sounds/sleep.wav", "static"),
        door = love.audio.newSource("assets/sounds/door.wav", "static"),
        checkArea = love.audio.newSource("assets/sounds/checkarea.wav", "static")
    }
end

function love.update(dt)
end

function love.draw()
end
