require 'objectpool'

function create_level()
    local self = {}

    self.tiles = create_object_pool(create_tile, 100)

    self.tile_width = 64
    self.tile_height = 64
    self.right_edge = 0

    self.furthest_enemy = love.graphics.getWidth()
    self.next_spawn = 0

    self.top = 4
    self.bottom = 5

    self.init = function(self)
        for x = -10, 10 do
            for y = self.top, self.bottom do
                local tx = x * self.tile_width
                local ty = y * self.tile_height

                if tx > self.right_edge then
                    self.right_edge = tx
                end

                local name = "dirt"
                if y == self.top then name = "grass" end
                self.tiles:add(tx, ty, name)
            end
        end
    end

    self.update = function(self, dt)
        self.tiles:remove_flagged()
        self.tiles:execute_obj_func("update", Game.camera.position.x)

        local screen_right = Game.camera.position.x + love.graphics.getWidth()
        if screen_right > self.right_edge then
            self.right_edge = self.right_edge + 64
            local tx = self.right_edge
            for y = self.top, self.bottom do
                local ty = y * self.tile_height

                local name = "dirt"
                if y == self.top then name = "grass" end
                self.tiles:add(tx, ty, name)
            end
        end

        if screen_right + 64 > self.furthest_enemy + self.next_spawn then
            self:spawn_enemy(self.furthest_enemy + self.next_spawn)
        end
    end

    self.render = function(self)
        love.graphics.setColor(255, 255, 255)
        self.tiles:execute_obj_func("render")
    end

    self.spawn_enemy = function(self, x)
        self.next_spawn = math.random(128, 512)
        Game.enemy_manager:add(x, 178)
        if x > self.furthest_enemy then
            self.furthest_enemy = x
        end
    end

    return self
end

function create_tile()
    local self = {}

    self.handle = 0
    self.active = false
    self.destroy_flag = false

    self.position = { x = tx, y = ty }
    self.ox = 0
    self.oy = 0
    self.image = nil
    self.name = nil

    self.activate = function(self, x, y, name)
        self.position.x = x
        self.position.y = y
        if self.name ~= name then
            self.name = name
            self.image = Images:get_image(name)
            self.ox = self.image:getWidth() / 2
            self.oy = self.image:getHeight() / 2
        end
    end

    self.release = function(self)
    end

    self.update = function(self, cx)
        local screen_left = cx - self.ox
        if self.position.x < screen_left then
            self.destroy_flag = true
        end
    end

    self.render = function(self)
        love.graphics.draw(self.image, self.position.x, self.position.y, 0, 1, 1, self.ox, self.oy)
    end

    return self
end