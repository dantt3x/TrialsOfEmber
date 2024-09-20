local transition = {}
transition.start = false
transition.visible = false
transition.currentY = -800
transition.add = 0

function transition.update(dt)
    if transition.start == true then
        transition.visible = true
        transition.add = 2200
        transition.currentY = -800
        transition.start = false
    end

    transition.currentY = transition.currentY + (transition.add*dt)

    if transition.currentY >= 800 then
        transition.visible = false
        transition.add = 0
        transition.currentY = -800
    end
end

function transition.draw()
   if transition.visible == true then
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 0, transition.currentY, 800, 1200)
        love.graphics.setColor(1,1,1)
        --love.graphics.print(transition.currentY, 50, 50)
   end
end

return transition