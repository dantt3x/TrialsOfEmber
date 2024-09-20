local stages = {
    [1] = "stage1",
    [2] = "stage2",
    [3] = "stage3",
    [4] = "stage4",
    [5] = "stage5",
    [6] = "stage6",
    [7] = "stage7",
    [8] = "stage8",
    [9] = "win",
}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- dependencies 
    windfield = require "libraries/windfield"
    rs = require "libraries/resolution_solution"

    -- modules
    projectile = require "projectile"
    transition = require "transition"
    conditions = require "conditions"
    miniboss = require "miniboss"
    player = require "player"
    music = require "music" 
    death = require "death"
    map = require "map"
    win = require "win"

    -- game values
    gameStarted = false
    gameWon = false
    isDead = false
    reset = true
    currentStage = 0

    game_start = love.audio.newSource("sounds/game_start.mp3", "static")
    player_death = love.audio.newSource("sounds/player_death.mp3", "static")
    boss_death = love.audio.newSource("sounds/boss_death.mp3", "static")

    player_death:setVolume(.5)
    boss_death:setVolume(.5)
    game_start:setVolume(.5)

    -- load
    --gameMap = sti("assets/testmap2.lua") ON HOLD FOR THE MINUTE

    rs.conf({
        game_width = 800,
        game_height = 800,
        scale_mode = 1
    })

    rs.setMode(rs.game_width, rs.game_height, {resizable = false, fullscreen = true})
    game_canvas = love.graphics.newCanvas(rs.get_game_size())
    background = love.graphics.newImage("assets/background.png")

    world = windfield.newWorld(0, 1500, false)
    world:addCollisionClass("Platform")
    world:addCollisionClass("Player")
    world:addCollisionClass("Projectile")
    world:addCollisionClass("Hitbox")
    world:addCollisionClass("Boss")

    projectile.load(world)
    miniboss.load(world)
    player.load(world)
    music.load()
    map.load(world)
end

local function resetGame()
    projectile.reset()
    miniboss.reset()
    player.reset()
    map.reset()

    gameWon = false
    gameStarted = true
    isDead = false
    currentStage = 1
end

local function checkEntityHealth()
    if player.hitPoints == 0 and isDead == false then
        if player_death:isPlaying() then
            player_death:stop()
        end

        player_death:play()

        player.playerObject:setType("static")
        death.visible = true
        isDead = true
        gameStarted = false
        reset = false
        currentStage = 1
        
        music.changeMusic("game_lost")
    end

    if miniboss.hitPoints == 0 then
        if boss_death:isPlaying() then
            boss_death:stop()
        end

        boss_death:play()

        if currentStage == #stages then
            gameWon = true
            gameStarted = false
            reset = false
            currentStage = 1
            -- reset everything
        elseif currentStage == #stages - 1 then -- final boss defeated
            win.visible = true
            
            if win.halfFinished == true then
                currentStage = currentStage + 1
                miniboss.animState = "spirit"
                miniboss.reset()
                projectile.reset()
            end
            music.changeMusic("game_won")
        else    
            player.hitPoints = player.hitPoints + 3
            currentStage = currentStage + 1
            miniboss.reset()
            map.reset()
        end
    end
end

function love.update(dt)
    death.update(dt)
    transition.update(dt)
    win.update(dt)
    music.update(dt)

    if transition.currentY >= 0 and reset == false then
        reset = true
        resetGame()
    end

    if gameStarted == false then
        if gameWon then
            if miniboss.dialogueFinished == false then
                miniboss.update(dt, stages[currentStage]) 
                return
            end
        end

        if not isDead and not gameWon then
            miniboss.update(dt, "default")
        end

        conditions.update(dt)

        if conditions.pressed == true then
            if isDead or gameWon then  
                death.visible = false
                transition.start = true
            else
                currentStage = 1
                gameStarted = true
            end

            if game_start:isPlaying() then
                game_start:stop()
            end

            music.changeMusic("main_boss_theme")

            game_start:play()
            conditions.pressed = false
        end
    end

    if gameWon == true then
        player.update(dt)
    end

    if gameStarted == true then
        checkEntityHealth()
        if isDead == true then return end

        if win.visible == true then 
            player.playerObject:setType("static") 
        else
            player.playerObject:setType("dynamic")
        end

        miniboss.update(dt, stages[currentStage]) 
        player.update(dt)

        if gameWon == false then
            projectile.update(dt)
            map.update(dt, stages[currentStage], miniboss.dialogueFinished)
        end
    end

    --tesound.cleanup()
    world:update(dt)
end

function love.draw()
    love.graphics.setCanvas(game_canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setCanvas()

    rs.push()
        love.graphics.draw(game_canvas)
        love.graphics.setColor(0,.2,.3)
        love.graphics.draw(background, 0, 0)

        --world:draw()     
        projectile.draw()
        miniboss.draw()
        player.draw()

        if gameStarted == false then
            if isDead then
                death.draw()
                if death.halfFinished == true then
                    conditions.draw(isDead, gameWon)
                end
            else
                conditions.draw(isDead, gameWon)
            end
        end

        transition.draw()
        win.draw()

    rs.pop()
end