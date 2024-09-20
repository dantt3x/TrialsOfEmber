local projectile = {}
local activeProjectiles = {}
local worldObj = nil
local anim8 = require "libraries/anim8"

local sound = love.audio.newSource("sounds/fireball.mp3", "static")

local function collision(c1, c2, contact)
    contact:setEnabled(false)
end

local function out_of_screen(x, y)
    return x > 800 or y > 800 or x < 0 or y < 0
end

local function createNewProjectile(x, y, xSpeed, ySpeed, width, height)
    local newProjectile = {}
    newProjectile.width = width
    newProjectile.height = height
    newProjectile.xSpeed = xSpeed
    newProjectile.ySpeed = ySpeed
    newProjectile.proj = worldObj:newRectangleCollider(x, y, width, height)
    newProjectile.proj:setFixedRotation(true)
    newProjectile.proj:setCollisionClass("Projectile", {ignores = {"Projectile", "Player"}})
    newProjectile.proj:setType("static")
    newProjectile.proj:setPreSolve(collision)
    newProjectile.animation = anim8.newAnimation(projectile.grid("1-8", 1), .08)
    table.insert(activeProjectiles, newProjectile)
end

function projectile.makeProjectile(x, y, xSpeed, ySpeed, width, height)
    local newSound = love.audio.newSource("sounds/fireball.mp3", "static")
    --newSound:setPitch(math.random(.5, .8))
    newSound:setVolume(.25)
    newSound:play()
    createNewProjectile(x, y, xSpeed, ySpeed, width, height)
end

function projectile.load(world)
    worldObj = world

    projectile.img = love.graphics.newImage("assets/fireball.png")
    projectile.grid = anim8.newGrid(64, 64, projectile.img:getWidth(), projectile.img:getHeight())
end

function projectile.reset()
    if #activeProjectiles ~= 0 then
        for index, projectile in pairs(activeProjectiles) do
            projectile.proj:destroy()
            table.remove(activeProjectiles, index)
        end
        projectile.reset()
    end
end

function projectile.update(dt)
    for index, projectileTable in ipairs(activeProjectiles) do
        local x, y = projectileTable.proj:getPosition()
        projectileTable.animation:update(dt)
        projectileTable.proj:setPosition(x + (projectileTable.xSpeed*dt), y + (projectileTable.ySpeed*dt))

        if out_of_screen(x, y, projectileTable.width, projectileTable.height) then
            projectileTable.proj:destroy()
            table.remove(activeProjectiles, index)
        end
    end
end

function projectile.draw()
    for index, projectileTable in ipairs(activeProjectiles) do
        local x, y = projectileTable.proj:getPosition()
        --love.graphics.setColor(1,0,0)
        --love.graphics.rectangle("fill", x - projectile.width/2, y - projectile.height/2, projectile.width, projectile.height)

        local r, sx, sy = 0, projectileTable.width/48, projectileTable.height/48
        local xOffset, yOffset = 32, 32

        love.graphics.setColor(.9,.9,.9)
        projectileTable.animation:draw(projectile.img, x, y, r, sx, sy, xOffset, yOffset)
    end 
end

return projectile