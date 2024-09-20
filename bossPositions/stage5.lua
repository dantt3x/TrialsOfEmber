local downProjectile = {xOffset = 0, yOffset = 25, xSpeed = 0, ySpeed = 500, width = 50, height = 50}
local leftProjectile = {xOffset = 0, yOffset = 25, xSpeed = 500, ySpeed = 500, width = 50, height = 50}
local rightProjectile = {xOffset = 0, yOffset = 25, xSpeed = -500, ySpeed = 500, width = 50, height = 50}


local projectileDown = {xOffset = 0, yOffset = 0, xSpeed = 0, ySpeed = 500, width = 50, height = 50}
local projectileLeftRight1 = {xOffset = 0, yOffset = 0, xSpeed = 300, ySpeed = 500, width = 50, height = 50}
local projectileLeftRight2 = {xOffset = 0, yOffset = 0, xSpeed = 400, ySpeed = 500, width = 50, height = 50}

local projectileRightLeft1 = {xOffset = 0, yOffset = 0, xSpeed = -300, ySpeed = 500, width = 50, height = 50}
local projectileRightLeft2 = {xOffset = 0, yOffset = 0, xSpeed = -400, ySpeed = 500, width = 50, height = 50}


return {
    [1] = {x = 100, y = 100, speed = 2, projectile = projectileDown},
    [2] = {x = 100, y = 100, speed = 2, projectile = projectileLeftRight1},
    [3] = {x = 100, y = 100, speed = 2, projectile = projectileLeftRight2},
    [4] = {x = 400, y = 400, speed = 2},
    [5] = {x = 700, y = 100, speed = 2, projectile = projectileDown},
    [6] = {x = 700, y = 100, speed = 2, projectile = projectileRightLeft1},
    [7] = {x = 700, y = 100, speed = 2, projectile = projectileRightLeft2},
}