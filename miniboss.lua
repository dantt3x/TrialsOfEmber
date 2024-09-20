local miniboss = {}
local worldObj = nil

local anim8 = require "libraries/anim8"
local projectileModule = require "projectile"
local previousStage = "default"

local font = love

local hurtT = 0
local flashT = 0
local spiritT = 1

local flash = false
local hitPoints = 12

local dialogueSound = love.audio.newSource("sounds/dialogue.mp3", "static")
local hit = love.audio.newSource("sounds/hit.mp3", "static")


local positionModules = {
    ["default"] = require "bossPositions/default",
    ["stage1"] = require "bossPositions/stage1",
    ["stage2"] = require "bossPositions/stage2",
    ["stage3"] = require "bossPositions/stage3",
    ["stage4"] = require "bossPositions/stage4",
    ["stage5"] = require "bossPositions/stage5",
    ["stage6"] = require "bossPositions/stage6",
    ["stage7"] = require "bossPositions/stage7",
    ["stage8"] = require "bossPositions/stage8",
}

local dialogueModules = {
    ["stage1"] = require "dialogue/stage1",
    ["stage2"] = require "dialogue/stage2",
    ["stage3"] = require "dialogue/stage3",
    ["stage4"] = require "dialogue/stage4",
    ["stage5"] = require "dialogue/stage5",
    ["stage6"] = require "dialogue/stage6",
    ["stage7"] = require "dialogue/stage7",
    ["stage8"] = require "dialogue/stage8",
    ["win"] = require "dialogue/win"
}

local function collision(c1, c2, contact)
    contact:setEnabled(false)
end

local function updateHurtTimer(dt)
    if miniboss.hurtable == false then
        flashT = flashT + (1*dt)
        miniboss.hurtTime = miniboss.hurtTime + (1*dt)

        if flashT > .2 then
            flash = not flash
            flashT = 0
        end

        if miniboss.hurtTime > .7 then
            miniboss.hurtable = true
            miniboss.hurtTime = 0
            flash = false
            flashT = 0
        end
    end
end

local function moveMiniboss(dt, positions)
    if miniboss.attacking == true then
        miniboss.animState = "attack"
        miniboss.attackingTime = miniboss.attackingTime + (1*dt)

        if miniboss.attackingTime > miniboss.attackingDelay then
            miniboss.attackingTime = 0
            miniboss.attacking = false
            miniboss.animState = "idle"
            miniboss.animations.attack[1]:gotoFrame(1)
        end
    end

    if #positions == 1 then
        miniboss.add = 0 
    else
        if miniboss.currentPosition == #positions then
            miniboss.add = -1
        elseif miniboss.currentPosition == 1 then
            miniboss.add = 1
        end
    end

    local positionalInfo = positions[miniboss.currentPosition]

    if positionalInfo["speed"] == -1 then
        miniboss.bossObj:setPosition(positionalInfo["x"], positionalInfo["y"])
    else
        if miniboss.attacking == true then
            if miniboss.attackingTime < .3 or miniboss.attackingTime ~= 0 then 
                return
            end
        end

        local x, y = miniboss.bossObj:getPosition()
        local newX = x + (positionalInfo["x"] - x) * (positionalInfo["speed"] * dt)
        local newY = y + (positionalInfo["y"] - y) * (positionalInfo["speed"] * dt) 
        miniboss.bossObj:setPosition(newX, newY)
        
    
        if x < positionalInfo["x"] + miniboss.buffer and x > positionalInfo["x"] - miniboss.buffer 
            and y < positionalInfo["y"] + miniboss.buffer and y > positionalInfo["y"] - miniboss.buffer then

            if positionalInfo["projectile"] then
                miniboss.attacking = true
                
                
                    local projectileInfo = positionalInfo["projectile"]

                    projectileModule.makeProjectile(
                        x + projectileInfo["xOffset"], 
                        y + projectileInfo["yOffset"], 
                        projectileInfo["xSpeed"], 
                        projectileInfo["ySpeed"], 
                        projectileInfo["width"], 
                        projectileInfo["height"]
                    )
                
            end

            miniboss.currentPosition = miniboss.currentPosition + miniboss.add
        end
    end
end

local textChars = {}
local textString = ""
local currentIndex = 1
local delayTime = 0
local currentDialogue = 1

local function playDialogue(dt, dialogue, textSpeed, finishingDelay)
    if #textChars == 0 then
        local index = 1

        for char in dialogue:gmatch(".") do
            textChars[index] = char
            index = index + 1
        end
    end

    if currentIndex ~= #textChars + 1 then
        if delayTime >= textSpeed then
            textString = textString..tostring(textChars[currentIndex])
            currentIndex = currentIndex + 1
            delayTime = 0
        else
            delayTime = delayTime + (1*dt)
        end
    else
        if delayTime >= finishingDelay then
            textChars = {}
            textString = ""
            currentIndex = 1
            delayTime = 0
            currentDialogue = currentDialogue + 1  
        else
            delayTime = delayTime + (1*dt)
        end
    end
end

function miniboss.load(world)   
    worldObj = world

    dialogueSound:setVolume(.25)

    miniboss.bossObj = worldObj:newRectangleCollider(410, 100, 100, 100)
    miniboss.bossObj:setFixedRotation(true)
    miniboss.bossObj:setCollisionClass("Boss", {ignores = {"Projectile", "Player", "Platform"}})
    miniboss.bossObj:setType("static")
    miniboss.bossObj:setPreSolve(collision)

    miniboss.animState = "idle"
    miniboss.attackingTime = 0
    miniboss.attackingDelay = .7
    miniboss.projectileShot = false

    miniboss.hurtable = true
    miniboss.hurtTime = 0
    miniboss.hitPoints = hitPoints

    miniboss.currentPosition = 1
    miniboss.add = 1
    miniboss.buffer = 50 -- how close should the boss be to the target point for it to move to the next point? (prevents lerp from slowing down)

    miniboss.dialogueFinished = false

    -- animations
    miniboss.animations = {}

    local idleImg = love.graphics.newImage("assets/bossSprites/bossIdle.png")
    local idleGrid = anim8.newGrid(64, 64, idleImg:getWidth(), idleImg:getHeight())
    miniboss.animations.idle = {
        [1] = anim8.newAnimation(idleGrid("1-8", 1), .08),
        [2] = idleImg,
    }

    local talkImg = love.graphics.newImage("assets/bossSprites/bossTalk.png")
    local talkGrid = anim8.newGrid(64, 64, talkImg:getWidth(), talkImg:getHeight())
    miniboss.animations.talk = {
        [1] = anim8.newAnimation(talkGrid("1-8", 1), .08),
        [2] = talkImg,
    }

    local attackImg = love.graphics.newImage("assets/bossSprites/bossAttack.png")
    local attackGrid = anim8.newGrid(64, 64, attackImg:getWidth(), attackImg:getHeight())
    miniboss.animations.attack = {
        [1] = anim8.newAnimation(attackGrid("1-8", 1), .08),
        [2] = attackImg,
    }

    local spiritImg = love.graphics.newImage("assets/bossSprites/bossSpirit.png")
    local spiritGrid = anim8.newGrid(64, 64, spiritImg:getWidth(), spiritImg:getHeight())
    miniboss.animations.spirit = {
        [1] = anim8.newAnimation(spiritGrid("1-8", 1), .08),
        [2] = spiritImg,
    }
end

function miniboss.reset()
    miniboss.bossObj:setPosition(410, 100)
    miniboss.hitPoints = hitPoints
    miniboss.currentPosition = 1
    miniboss.add = 1
    miniboss.dialogueFinished = false

    textChars = {}
    textString = ""
    currentIndex = 1
    delayTime = 0
    currentDialogue = 1
    spiritT = 1
end



function miniboss.update(dt, currentStage)
    local positions = nil
    miniboss.animState = "idle"

    if miniboss.dialogueFinished == false or currentStage == "default" or currentStage == "win" and miniboss.dialogueFinished == false then
        positions = positionModules["default"]

        if currentStage ~= "default" then
            if currentDialogue > #dialogueModules[currentStage] then
                if currentStage == "win" then -- spirit disappear
                    if spiritT > 0 then
                        spiritT = spiritT - (1*dt)
                    else
                        miniboss.dialogueFinished = true
                    end
                else
                    miniboss.dialogueFinished = true
                end
            else
                miniboss.animState = "talk"
                local dialogueTable = dialogueModules[currentStage][currentDialogue]
                dialogueSound:play()
                playDialogue(dt, dialogueTable["text"], dialogueTable["textSpeed"], dialogueTable["finishingDelay"])
            end
        end
    elseif miniboss.dialogueFinished == true then
        dialogueSound:stop()
        updateHurtTimer(dt)
        if currentStage == "win" then
            miniboss.hitPoints = 0
            positions = positionModules["default"]
        else
            positions = positionModules[currentStage]
        end
    end

    moveMiniboss(dt, positions)
    if currentStage == "win" then
        miniboss.animState = "spirit"
    end
    miniboss.animations[miniboss.animState][1]:update(dt)
end

function miniboss.draw()
    local x, y = miniboss.bossObj:getPosition()
    --love.graphics.setColor(1,1,1)
    --love.graphics.print("position: "..miniboss.currentPosition, 2, 15)
    --love.graphics.print("add: "..miniboss.add, 2, 30)
    --love.graphics.print(x, 2, 40)
    --love.graphics.print(y, 2, 50)
    --love.graphics.setColor(1,0,0)
    --love.graphics.print(miniboss.hitPoints, x, y) 

    local xOffset, yOffset = 32,32
    local r, sx, sy = 0, 2, 2

    if miniboss.add == -1 then
        xOffset = 32
        sx = -2
    else
        xOffset = 32
        sx = 2
    end

    if flash == false then
        love.graphics.setColor(1,1,1, spiritT)
        miniboss.animations[miniboss.animState][1]:draw(miniboss.animations[miniboss.animState][2], x, y, r, sx, sy, xOffset, yOffset)
    end

    if hurtT > 0 then
        love.graphics.setColor(1,1,1,hurtT)
        love.graphics.circle("fill", x, y, 64, 64)
        hurtT = hurtT - .15
    end

    if textString ~= "" then
        local font = love.graphics.newFont("assets/pixelfont.ttf", 30)
        love.graphics.setColor(.1,.5,.8)
        love.graphics.printf(textString, 0, 150, 800, "center")
    end
end

function miniboss.hurt()
    if miniboss.hurtable == true and miniboss.dialogueFinished == true then
        if hit:isPlaying() then
            hit:stop()
        end

        hit:play()
        
        miniboss.hitPoints = miniboss.hitPoints - 1
        miniboss.hurtable = false
        hurtT = 1
    end
end

return miniboss