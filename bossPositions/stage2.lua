local downProjectile = {xOffset = 0, yOffset = 25, xSpeed = 0, ySpeed = 500, width = 50, height = 50}
local leftProjectile = {xOffset = 0, yOffset = 25, xSpeed = 500, ySpeed = 500, width = 50, height = 50}
local rightProjectile = {xOffset = 0, yOffset = 25, xSpeed = -500, ySpeed = 500, width = 50, height = 50}

return {
    [1] = {x = 100, y = 400, speed = 2},
    [2] = {x = 400, y = 100, speed = 1, projectile = downProjectile},
    [3] = {x = 400, y = 100, speed = 1, projectile = leftProjectile},
    [4] = {x = 400, y = 100, speed = 1, projectile = rightProjectile},
    [5] = {x = 700, y = 400, speed = 2},
}