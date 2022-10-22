

BASEDIR = love.filesystem.getRealDirectory("/modules"):match("(.-)[^%.]+$")
BASEDIR = string.sub(BASEDIR, 1, string.len(BASEDIR)-1)
local myPath = BASEDIR..'/modules/?.lua;'..BASEDIR..'/data/?.lua'
local myPath2 = 'modules/?.lua;/data/?.lua'

package.path = myPath
love.filesystem.setRequirePath( myPath2 )


-- virtual resolution handling library
push = require 'push'
class = require 'class'
require 'Bird'
require 'Pipe'
require 'PipePair'

require 'StateMachine'
require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('images/background.png')
local backgroundScroll = 0
local ground = love.graphics.newImage('images/ground.png')
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

-- point at which we should loop our background back to X 0
local BACKGROUND_LOOPING_POINT = 413

local bird = Bird()
local pipes = {}
local pipePairs = {}

local spawnTimer = 0

local lastY = -PIPE_HEIGHT + math.random(80) + 20

local scrolling = true

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Fifty Bird')
  
    smallFont = love.graphics.newFont('/fonts/font.ttf', 8)
    mediumFont = love.graphics.newFont('/fonts/flappy.ttf', 14)
    flappyFont = love.graphics.newFont('/fonts/flappy.ttf', 28)
    hugeFont = love.graphics.newFont('/fonts/flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['explosion'] = love.audio.newSource('sounds/explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),

        -- https://freesound.org/people/xsgianni/sounds/388079/
        ['music'] = love.audio.newSource('sounds/marios_way.mp3', 'static')
    }

    sounds['music']:setLooping(true)
    sounds['music']:play()


    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true         
    })

    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end,
    }
    gStateMachine:change("title")

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end  

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true --[[ popular com key ]]
    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key) --[[  on the last frame, the key was pressed? ]]
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end   
end

function love.update(dt) 
--[[     if scrolling then ]]
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) 
            % BACKGROUND_LOOPING_POINT

        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
            % VIRTUAL_WIDTH

        gStateMachine:update(dt)

        love.keyboard.keysPressed = {}

end

function love.draw()
    push:start()
    -- draw the background starting at top left (0, 0)
        love.graphics.draw(background, -backgroundScroll, 0)
        gStateMachine:render()
        love.graphics.draw(ground, -groundScroll , VIRTUAL_HEIGHT - 16)  
    push:finish()
end