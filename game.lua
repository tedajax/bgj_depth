require 'player'
require 'bomb'
require 'level'
require 'camera'
require 'enemy'
require 'bullet'
require 'background'
require 'explosion'

function create_game()
    local self = {}

    self.player = create_player(0, 0)
    create_player_controller(self.player)
    self.bomb_manager = create_bomb_manager(100)
    self.enemy_manager = create_enemy_manager(100)
    self.bullet_manager = create_bullet_manager(250)
    self.explosion_manager = create_explosion_manager(100)

    self.level = create_level()
    self.level:init()

    self.background = create_background()
    self.background:set_time(12, 0)

    self.camera = create_camera(0, 0)

    self.score = 0
    self.high_score = 0
    self.prev_high_score = 0

    self.move_speed = 150

    self.init = function(self)
        self:read_high_score()
        Audio:play_music("play")
    end

    self.read_high_score = function(self)
        local str = love.filesystem.read("score.txt")
        if str ~= nil then
            self.high_score = tonumber(str)
        else
            self.high_score = 0
        end
        self.prev_high_score = self.high_score
    end

    self.save_high_score = function(self)
        love.filesystem.write("score.txt", tostring(self.high_score))
    end

    self.reset = function(self)
        if self.high_score > self.prev_high_score then
            self:save_high_score()
            self.prev_high_score = self.high_score
        end
        self.background:set_time(12, 0)
        self.score = 0
        self.camera:look_at(0, 0)
        self.player:reset()
        self.level:reset()
        self.explosion_manager:clear()
        self.enemy_manager:clear()
        self.bullet_manager:clear()
        self.bomb_manager:clear()
        love.audio.rewind(Audio:get_music("play"))
    end

    self.update = function(self, dt)
        self.camera:update(dt)
        self.background:update(dt)
        self.level:update(dt)
        self.player:update(dt)
        self.explosion_manager:update(dt)
        self.bomb_manager:update(dt)
        self.enemy_manager:update(dt)
        self.bullet_manager:update(dt)
        self.camera:move(Game.move_speed * dt, 0)
    end

    self.render = function(self)
        self.background:render()

        self.camera:push()

        self.level:render()
        self.player:render()
        self.enemy_manager:render()
        self.bomb_manager:render()
        self.bullet_manager:render()
        self.explosion_manager:render()

        -- Collision:debug_draw()

        love.graphics.setColor(31, 31, 31)
        love.graphics.printf("Experience the 'depths' of cruelty", -250, -220, 1000, "center", 0, 1, 1)
        love.graphics.printf("Arrow keys to move...", -250, -180, 1000, "center", 0, 1, 1)
        love.graphics.printf("Press 'Z' to drop bombs", -250, -140, 1000, "center", 0, 1, 1)

        self.camera:pop()

        self.player:render_health()
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf("Score: "..self.score, love.graphics.getWidth() - 505, 10, 500, "right", 0, 1, 1)
        love.graphics.printf("High: "..self.high_score, love.graphics.getWidth() - 505, 40, 500, "right", 0, 1, 1)
    end

    self.add_score = function(self, amount)
        self.score = self.score + amount
        if self.score > self.high_score then
            self.high_score = self.score
        end
    end

    return self
end

