function create_audio()
    local self = {}

    self.sounds = {}
    self.music = {}

    self.max_sources_per_sfx = 8

    self.init = function(self)
        love.audio.setPosition(0, 0, 0)
    end

    self.get_sfx = function(self, name)
        return self.sounds[name]
    end

    self.get_music = function(self, name)
        return self.music[name]
    end

    self.load_sfx = function(self, name, path)
        local sound = love.audio.newSource(path, "static")
        if sound ~= nil then
            sound:setPosition(0, 0, -2)
            self.sounds[name] = {}
            table.insert(self.sounds[name], sound)
            for i = 2, self.max_sources_per_sfx do
                table.insert(self.sounds[name], sound:clone())
            end
        end
        return self.sounds[name]
    end

    self.load_music = function(self, name, path)
        local music = love.audio.newSource(path, "stream")
        if music ~= nil then
            music:setPosition(0, 0, -1)
            self.music[name] = music
        end
        return self.music[name]
    end

    self.play_sfx = function(self, name)
        for _, s in ipairs(self.sounds[name]) do
            if not s:isPlaying() then
                love.audio.play(s)
                break
            end
        end
    end

    self.play_music = function(self, name)
        love.audio.play(self.music[name])
    end

    return self
end