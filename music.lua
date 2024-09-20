local music = {}
music.currentSong = "main_theme"
music.nextSong = "none"

local tracks = {}
local fade = false
local volume = .25

function music.load()
    tracks = {
        ["main_boss_theme"] = love.audio.newSource("sounds/main_boss_theme.mp3", "stream"),
        ["main_theme"] = love.audio.newSource("sounds/main_theme.mp3", "stream"),
        ["game_lost"] = love.audio.newSource("sounds/game_lost.mp3", "stream"),
        ["game_won"] = love.audio.newSource("sounds/game_won.mp3", "stream"),
    }    
end

function music.update(dt)
    if fade == true then
        if volume > 0 then
            volume = volume - (.5*dt)
        else
            tracks[music.currentSong]:stop()
            music.currentSong = music.nextSong
            music.nextSong = "none"
            fade = false
        end
    else
        if volume <= 0 or volume < .25 then
            volume = volume + (.5*dt)
        end
    end

    tracks[music.currentSong]:setVolume(volume)
    tracks[music.currentSong]:play()
end

function music.changeMusic(newSong)
    music.nextSong = newSong
    fade = true
end

return music