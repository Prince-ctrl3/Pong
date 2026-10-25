if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end



WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

push = require 'push'
Class = require 'class'

require 'Ball'
require 'Paddle'

gamestate = "start"
activePlayer = nil
winner = nil

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('font.ttf', 16)
    largeFont = love.graphics.newFont('font.ttf', 32)

    math.randomseed(os.time())

    love.window.setTitle("PONG")

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = true,
        vsync = true,
        fullscreen = false
    })
    love.graphics.setBackgroundColor(40 / 255, 45 / 255, 52 / 255, 1)
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, {
        upscale = "normal"
    })

    Ball = Ball(4, 4)
    Player1 = Paddle(10, 10, 5, 20)
    Player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 5, 20)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/border.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/borderHit.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.mp3', 'static')
    }

end

function love.resize(w, h)
    push.resize(w, h)
end

function love.update(dt)

    if love.keyboard.isDown("up") then
        Player1:update(dt, -1)
    elseif love.keyboard.isDown("down") then
        Player1:update(dt, 1)
    end

    Player2.y = Ball.y

    if gamestate == "play" then

        Ball:update(dt)

        if Ball:collidies(Player1) then
            Ball.x = Player1.x + Player1.width
            Ball:turn()
            sounds["paddle_hit"]:play()
        elseif Ball:collidies(Player2) then
            Ball.x = Player2.x - Ball.width
            Ball:turn()
            sounds["paddle_hit"]:play()
        end

        if Ball.y <= 0 then
            Ball.y = 0
            Ball.dy = -Ball.dy
            sounds["wall_hit"]:play()
        elseif Ball.y >= VIRTUAL_HEIGHT - Ball.height then
            Ball.y = VIRTUAL_HEIGHT - Ball.height
            Ball.dy = -Ball.dy
            sounds["wall_hit"]:play()
        end

        if Ball.x <= 0 then
            activePlayer = "Player1"
            Player2.score = Player2.score + 1
            Ball:reset(1)
            sounds["score"]:play()
            gameManager()
        elseif Ball.x >= VIRTUAL_WIDTH then
            activePlayer = "Player2"
            Player1.score = Player1.score + 1
            Ball:reset(-1)
            sounds["score"]:play()
            gameManager()
        end
    end
end

function checkIfGameEnds()
    if Player1.score >= 2 then
        winner = "Player 1"
        return true
    elseif Player2.score >= 2 then
        winner = "Player 2"
        return true
    end
end

function gameManager()
    gamestate = "start"
    if (checkIfGameEnds()) then
        Ball:reset()
        Player1:reset()
        Player2:reset()
        sounds['victory']:play()
        activePlayer = nil
        gamestate = "over"
    end
end

function love.draw()
    push.start()
    love.graphics.setFont(largeFont)
    love.graphics.print(tostring(Player1.score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
    love.graphics.print(tostring(Player2.score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 2 - 50)

    love.graphics.setFont(smallFont)
    displayFps()
    if gamestate == "surf" then
        if (activePlayer) then
            love.graphics.printf(string.format("%s chance to surf", activePlayer), 0, 30, VIRTUAL_WIDTH, "center")
            love.graphics.printf("Press Enter To serve", 0, 40, VIRTUAL_WIDTH, "center")
        else
            love.graphics.printf("Get Ready!", 0, 30, VIRTUAL_WIDTH, "center")
            love.graphics.printf("Press Enter", 0, 40, VIRTUAL_WIDTH, "center")
        end
    elseif gamestate == "start" then
        love.graphics.printf("Press Enter to began", 0, 30, VIRTUAL_WIDTH, "center")
    elseif gamestate == "over" then
        love.graphics.setFont(mediumFont)
        love.graphics.printf(string.format("%s is the winner", winner), 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to restart", 0, 30, VIRTUAL_WIDTH, "center")
    end

    Player1:draw()
    Player2:draw()

    Ball:draw()

    push.finish()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "return" or key == "enter" then
        if gamestate == 'start' then
            gamestate = 'surf'
        elseif gamestate == 'surf' then
            gamestate = 'play'
        else
            gamestate = 'start'
        end
    end
end

function displayFps()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

function checkIfGameEnds()
    gamestate = "start"
    if Player1.score >= 3 then
        winner = "Player1"
        return true
    elseif Player2.score >= 3 then
        winner = "Player2"
        return true
    end
end
