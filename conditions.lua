local conditions = {}
local showText = true
local font = love.graphics.newFont("assets/pixelfont.ttf", 75)

local delay = 0
local currentT = 0

function conditions.update(dt)
    currentT = currentT + (1*dt)
    delay = delay + (1*dt)

    if currentT >= .5 then
        showText = not showText
        currentT = 0
    end

    if love.keyboard.isDown("p") then
        if delay > .8 then
            conditions.pressed = true
            delay = 0
        end
    end
end

function conditions.draw(isDead, gameWon)
    local titleText = "Trials Of Ember"
    local inputText = "Press P to Play!"

    if gameWon == true then
        titleText = "You Won!"
        inputText = "Press P to Restart.."
    elseif isDead == true then 
        titleText = ""
        inputText = "Press P to Retry.."
    end 

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(font)
    love.graphics.printf(titleText, 0, 150, 800, "center")

    if showText == true then
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(font)
        love.graphics.printf(inputText, 0, 500, 800, "center")
    end
end

return conditions