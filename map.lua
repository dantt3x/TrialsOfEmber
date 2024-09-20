local map = {}
local worldObj = nil
local projectileModule = require "projectile"

local mapProjectiles = {
    ["stage1"] = require "mapProjectiles/stage1",
    ["stage2"] = require "mapProjectiles/stage2",
    ["stage3"] = require "mapProjectiles/stage3",
    ["stage4"] = require "mapProjectiles/stage4",
    ["stage5"] = require "mapProjectiles/stage5",
    ["stage6"] = require "mapProjectiles/stage6",
    ["stage7"] = require "mapProjectiles/stage7",
    ["stage8"] = require "mapProjectiles/stage8",
}

function map.load(world)
    local width = love.graphics.getWidth()
    worldObj = world

    map.roof = world:newRectangleCollider(0, 0, 800, 1)
    map.roof:setType('static')
    map.roof:setCollisionClass("Platform")

    map.floor = world:newRectangleCollider(0, 500, 800, 300)
    map.floor:setType('static')
    map.floor:setCollisionClass("Platform")

    map.leftWall = world:newRectangleCollider(0, 0, 1, 800)
    map.leftWall:setType("static")
    map.leftWall:setCollisionClass("Platform")

    map.rightWall = world:newRectangleCollider(799, 0, 1, 800)
    map.rightWall:setType("static")
    map.rightWall:setCollisionClass("Platform")
end

local startingPositions = {}
local currentIndex = 1
local delayTime = 0

local canContinue = false
local loaded = false

function map.reset()
   currentIndex = 1
   delayTime = 0
   startingPositions = {} 
end

local function loadPositions(projectiles)
    if loaded == false then
        loaded = true

        for i, v in pairs(projectiles) do
            local projectileTable = v["projectile"]
            local xPos, yPos = projectileTable["x"], projectileTable["y"]

            table.insert(startingPositions, {x = xPos, y = yPos})
        end
    end
end

local function updateTimer(dt, delay)
    delayTime = delayTime + (1*dt)

    if delayTime >= delay then
        canContinue = true
        delayTime = 0
    end
end

function map.update(dt, stage, dialogueFinished)
    local projectiles = mapProjectiles[stage]

    if not projectiles or stage == "win" then else
        loadPositions(projectiles)

        if dialogueFinished == true then
            local projectileTable = projectiles[currentIndex]["projectile"]
            local delay = projectiles[currentIndex]["delay"]
        
            if canContinue == true then
                canContinue = false

                projectileModule.makeProjectile(
                    projectileTable.x,
                    projectileTable.y,
                    projectileTable.xSpeed,
                    projectileTable.ySpeed,
                    projectileTable.width,
                    projectileTable.height
                )

                currentIndex = currentIndex + 1

                if currentIndex > #projectiles then
                    currentIndex = 1
                    canContinue = false
                end
            else
                updateTimer(dt, delay)
            end
            
        end
    end
end

function map.draw()

end

return map