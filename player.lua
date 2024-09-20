local player = {}
local worldObj = nil

local anim8 = require "libraries/anim8"
local miniboss = require "miniboss"

-- timings
local invincTime = .8
local hitboxTime = .7

-- timers
local hitboxT = 0
local invincT = 0
local hurtT = 0
local flashT = 0

-- bools
local flash = false

-- player default values

local playerSpawnX = 400
local playerSpawnY = 500
local playerSizeX = 32
local playerSizeY = 32

local hitboxSizeX = playerSizeX
local hitboxSizeY = playerSizeY/2
local xOffset = playerSizeX/4 

local hitPoints = 20

-- sounds
local hurt = love.audio.newSource("sounds/hurt.mp3", "static")
local jump = love.audio.newSource("sounds/jump.mp3", "static")
local step = love.audio.newSource("sounds/step.mp3", "static")

local function hitboxRightColliding(c1, c2, contact)
    if c2.collision_class == "Platform" then contact:setEnabled(false) return end

    if c1.collision_class == "Hitbox" and c2.collision_class == "Boss" then
        if player.attacking == true and player.facing == "right" then
            miniboss.hurt()
        end
    end
end

local function hitboxLeftColliding(c1, c2, contact)
    if c2.collision_class == "Platform" then contact:setEnabled(false) return end

    if c1.collision_class == "Hitbox" and c2.collision_class == "Boss" then
        if player.attacking == true and player.facing == "left" then
            miniboss.hurt()
        end
    end
end

local function playerColliding(c1, c2, contact)
    if c1.collision_class == "Player" and c2.collision_class == "Platform" then
        player.canJump = true
        player.spacePressed = false
    end
    
    if c1.collision_class == "Player" and c2.collision_class == "Hitbox" then
        contact:setEnabled(false)
    end
    
    if c1.collision_class == "Player" and c2.collision_class == "Projectile" then
        if player.hurtable == true then
            hurtT = 1
            player.hitPoints = player.hitPoints - 1
            player.hurtable = false

            if hurt:isPlaying() then
                hurt:stop()
            end

            hurt:play()
        end
    end
end

local function checkInvincibility(dt)

    if player.hurtable == false then
        if invincT > invincTime then
            invincT = 0
            flashT = 0
            player.hurtable = true
            
            flash = false
        else
            flashT = flashT + (1*dt)

            if flashT > .1 then
                flash = not flash 
                flashT = 0
            end

            invincT = invincT + (1 * dt)
        end
    end
end

function player.load(world)
    worldObj = world

    jump:setVolume(.5)
    step:setVolume(.25)

    player.hitPoints = hitPoints
    player.canJump = true
    player.hurtable = true
    player.attacking = false
    player.animState = "idle"
    player.facing = "right"

    -- player obj
    player.playerObject = worldObj:newRectangleCollider(playerSpawnX, playerSpawnY, playerSizeX, playerSizeY)
    player.playerObject:setMass(1000)
    player.playerObject:setFixedRotation(true)
    player.playerObject:setCollisionClass("Player", {ignores = {"Hitbox", "Projectile"}})
    player.playerObject:setPreSolve(playerColliding)

    -- hitbox left
    player.hitboxLeft = worldObj:newRectangleCollider(
        playerSpawnX - (hitboxSizeX + xOffset), 
        playerSpawnY + (playerSizeY/4), 
        hitboxSizeX, 
        hitboxSizeY
    )
    player.hitboxLeft:setCollisionClass("Hitbox", {ignores = {"Player", "Platform"}})
    player.hitboxLeft:setFixedRotation(true)
    player.hitboxLeft:setMass(1)
    player.hitboxLeft:setPreSolve(hitboxLeftColliding)

    -- hitbox right
    player.hitboxRight = worldObj:newRectangleCollider(
        playerSpawnX + (hitboxSizeX + xOffset), 
        playerSpawnY + (playerSizeY/4), 
        hitboxSizeX, 
        hitboxSizeY
    )
    player.hitboxRight:setCollisionClass("Hitbox", {ignores = {"Player", "Platform"}})
    player.hitboxRight:setFixedRotation(true)
    player.hitboxRight:setMass(1)
    player.hitboxRight:setPreSolve(hitboxRightColliding)

    -- joints
    player.jointLeft = worldObj:addJoint(
        "RevoluteJoint", 
        player.playerObject, 
        player.hitboxLeft, 
        playerSpawnX, 
        playerSpawnY + (playerSizeY/2), 
        false
    )

    player.jointRight = worldObj:addJoint(
        "RevoluteJoint", 
        player.playerObject, 
        player.hitboxRight, 
        playerSpawnX + playerSizeX, 
        playerSpawnY + (playerSizeY/2), 
        false
    )

    -- player animations
    -- spaghetti code, DO NOT do this (the only reason this is happening is because i dont know how to upload all sprites under one sheet)

    player.animations = {}

    local walkImg = love.graphics.newImage("assets/playerSprites/walk.png")
    local walkGrid = anim8.newGrid(64, 64, walkImg:getWidth(), walkImg:getHeight())
    player.animations.walk = {
        [1] = anim8.newAnimation(walkGrid("1-8", 1), .08),
        [2] = walkImg,
    }

    local idleImg = love.graphics.newImage("assets/playerSprites/idle.png")
    local idleGrid = anim8.newGrid(64, 64, idleImg:getWidth(), idleImg:getHeight())
    player.animations.idle = {
        [1] = anim8.newAnimation(idleGrid("1-8", 1), .08),
        [2] = idleImg,
    }

    local fallImg = love.graphics.newImage("assets/playerSprites/fall.png")
    local fallGrid = anim8.newGrid(64, 64, fallImg:getWidth(), fallImg:getHeight())
    player.animations.fall = {
        [1] = anim8.newAnimation(fallGrid("1-4", 1), .12),
        [2] = fallImg,
    }

    local attackImg = love.graphics.newImage("assets/playerSprites/attack.png")
    local attackGrid = anim8.newGrid(64, 64, attackImg:getWidth(), attackImg:getHeight())
    player.animations.attack = {
        [1] = anim8.newAnimation(attackGrid("1-8", 1), .08),
        [2] = attackImg,
    }

end

function player.reset()
    invincT = 0
    hitboxT = 0

    player.hitPoints = hitPoints
    player.canJump = true
    player.hurtable = true
    player.attacking = false
    player.animState = "idle"
    player.facing = "right"

    player.playerObject:setType("dynamic")
    player.playerObject:setPosition(playerSpawnX, playerSpawnY)
end

function player.update(dt)
    checkInvincibility(dt)

    player.canJump = false
    player.animState = "idle"
    player.playerObject:setMass(1000)

    local px, py = player.playerObject:getLinearVelocity()

    if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
        player.facing = "left"
        player.animState = "walk"
        player.playerObject:setLinearVelocity(-500, py)
        step:play()
    end

    if love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
        player.facing = "right"
        player.animState = "walk"
        player.playerObject:setLinearVelocity(500, py)
        step:play()
    end

    if py > 1 then
        player.animState = "fall"
    end

    if player.attacking == true then
        player.animState = "attack"
        hitboxT = hitboxT + (1*dt)

        if hitboxT >= hitboxTime then
            player.activeHitbox = "none"
            player.attacking = false
            hitboxT = 0
        end
    end

    if player.animState == "idle" or player.animState == "fall" then
        if step:isPlaying() then
            step:stop()
        end
    end

    player.animations[player.animState][1]:update(dt)
end

function player.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.print("HP:", 10, 5)
    love.graphics.setColor(0,1,0)
    love.graphics.print(player.hitPoints, 80, 5)

    local playerX, playerY = player.playerObject:getPosition()
    local xOffset, yOffset = 32, 32
    local r, sx, sy = 0, 1, 1

    if player.facing == "left" then
        sx = -1
    else
        sx = 1
    end

    if flash == false then
        love.graphics.setColor(1,1,1)
        player.animations[player.animState][1]:draw(player.animations[player.animState][2], playerX, playerY, r, sx, sy, xOffset, yOffset)
    end
    
    if hurtT > 0 then
        love.graphics.setColor(.8,0,0,hurtT)
        love.graphics.circle("fill", playerX, playerY, 32 + hurtT, 32 + hurtT)
        hurtT = hurtT - .15
    end
end

function love.keypressed(key)
    if key == "space" then
        if player.canJump == false then 
            return 
        end
        if jump:isPlaying() then
            jump:stop()
        end

        jump:play()
        player.playerObject:applyLinearImpulse(0, player.playerObject:getMass() * -950)
    end
    
    if key == "s" then
        if player.canJump == true then 
            return 
        end

        local px, py = player.playerObject:getLinearVelocity()
        player.playerObject:setLinearVelocity(px, 350)
    end
    
    if key == "p" then
        if player.attacking == false then
            player.animations.attack[1]:gotoFrame(1)
            player.attacking = true
        end
    end
end

function love.keyreleased(key)
    if key == "a" or key == "d" then
        local px, py = player.playerObject:getLinearVelocity()
        player.playerObject:setLinearVelocity(0, py)
    end
end

return player