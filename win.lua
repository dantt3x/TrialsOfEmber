local win = {}
win.visible = false
win.halfFinished = false

local t1 = 0
local t2 = 0
local t3 = 1

function win.update(dt)
    if win.visible == true then

        if t1 < 1 then
            t1 = t1 + (2*dt)
        else
            if t2 < 1 then
                t2 = t2 + (1*dt)
            else
                win.halfFinished = true

                if t3 > 0 then
                    t3 = t3 - (1*dt)
                else
                    win.visible = false
                end
            end
        end
    else
        win.halfFinished = false
        t1 = 0
        t2 = 0
        t3 = 1
    end
end

function win.draw()
    if win.visible == true then
        if t1 < 1 then
            love.graphics.setColor(1,1,1,t1)
            love.graphics.rectangle("fill", 0 + math.random(-1, 1), 0 + math.random(-1, 1), 800, 800)
        else
            if t2 < 1 then
                love.graphics.setColor(1,1,1,1)
                love.graphics.rectangle("fill", 0 + math.random(-1, 1), 0 + math.random(-1, 1), 800, 800)
            else
                if t3 > 0 then
                    love.graphics.setColor(1,1,1,t3)
                    love.graphics.rectangle("fill", 0 + math.random(-1, 1), 0 + math.random(-1, 1), 800, 800)
                end
            end
        end
        --love.graphics.setColor(0,0,0)
        --love.graphics.print(t)
    end
end

return win