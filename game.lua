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

    self.move_speed = 100

    self.init = function(self)
    end

    self.update = function(self, dt)
        self.background:update(dt)
        self.level:update(dt)
        self.player:update(dt)
        self.explosion_manager:update(dt)
        self.bomb_manager:update(dt)
        self.enemy_manager:update(dt)
        self.bullet_manager:update(dt)

        if love.keyboard.isDown("a") then
            Game.move_speed = 1000
        else
            Game.move_speed = 100
        end

        self.camera:move(Game.move_speed * dt, 0)

        -- self.camera:zoom_in(0.1 * dt)
        -- self.camera:rotate(10 * dt)
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

        Collision:debug_draw()

        self.camera:pop()
    end

    return self
end

