local death = {}
death.visible = false

local delayT = 0
local textT = 0
local textT2 = 0

local font = love.graphics.newFont("assets/pixelfont.ttf", 150)
local font2 = love.graphics.newFont("assets/pixelfont.ttf", 50)

function death.update(dt)
    if death.visible == false then
        delayT = 0
        textT = 0
        textT2 = 0
        death.halfFinished = false
    end 

    if death.visible == true then
        if delayT < 1 then
            delayT = delayT + (1*dt)
        else
            if textT < 1 then
                textT = textT + (1*dt)
            end

            death.halfFinished = true

            if textT2 < .7 then
                textT2 = textT2 + (.1*dt)
            end
        end
    end

end


function death.draw()
    if death.visible == true then
        love.graphics.setColor(0,0,0, textT)
        love.graphics.rectangle("fill", 0, 0, 800, 800)

        love.graphics.setColor(1,1,1, textT)
        love.graphics.setFont(font)
        love.graphics.printf("YOU DIED!", 0, 150, 800, "center")

        love.graphics.setColor(1,1,1, textT2)
        love.graphics.setFont(font2)
        love.graphics.printf("you must prevail...", 0, 300, 800, "center")
    end
end

return death