function create_enemy()
    local self = {}

    self.active = false
    self.destroy_flag = false
    self.handle = 0

    self.position = { x = 0, y = 0 }
    self.target = nil
    self.aim_angle = 0

    self.base_image = Images:get_image("turret_base")
    self.gun_image = Images:get_image("turret_gun")

    self.delta = 1

    self.body = love.physics.newBody(Collision.world, self.position.x, self.position.y, "kinematic")
    self.body:setMass(1)
    self.body:setActive(false)
    self.shape = love.physics.newRectangleShape(0, 12, 96, 30)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFilterData(collision_tag_filter_data("cEnemy"))

    self.max_health = 3
    self.health = 0

    self.min_fire_delay = 0.25
    self.max_fire_delay = 1.5
    self.fire_delay = 0

    self.activate = function(self, x, y)
        self.position.x = x
        self.position.y = y
        self.body:setActive(true)
        self.body:setX(self.position.x)
        self.body:setY(self.position.y)
        self.fixture:setUserData(collision_create_tag("cEnemy", self.handle))
        self.health = self.max_health
        self.target = Game.player.position
        self.fire_delay = math.random(self.min_fire_delay, self.max_fire_delay)
        self.aim_angle = 315
    end

    self.release = function(self)
        self.aim_angle = 0
        self.body:setActive(false)
    end

    self.on_release = function(self)
        local min_scale = 1.5
        local max_scale = 3
        local minx = -32
        local maxx = 32
        local miny = -12
        local maxy = 12
        local yoff = 24
        local s = math.random() * (max_scale - min_scale) + min_scale
        local x = self.position.x + math.random(minx, maxx)
        local y = self.position.y + yoff + math.random(miny, maxy)
        local px = self.position.x
        local py = self.position.y
        Game.explosion_manager:add(x, y, s)
        Timer:add_periodic(0.25, function()
            local es = math.random() * (max_scale - min_scale) + min_scale
            local ex = px + math.random(minx, maxx)
            local ey = py + yoff + math.random(miny, maxy)
            Game.explosion_manager:add(ex, ey, es)
        end, math.random(3, 5))
    end

    self.update = function(self, dt)
        self.body:setX(self.position.x)
        self.body:setY(self.position.y + 20)

        if self.target ~= nil then
            local diffx = self.position.x - self.target.x
            local diffy = self.position.y - self.target.y

            if self.position.x > Game.camera.position.x - 64 and
               self.position.x < Game.camera.position.x + love.graphics.getWidth() + 64 then
                local a = math.atan2(diffy, diffx)
                a = math.deg(a) + 270
                self.aim_angle = self.aim_angle + (a - self.aim_angle) * 0.1

                if self.fire_delay > 0 then
                    self.fire_delay = self.fire_delay - dt
                else
                    local bx = math.cos(math.rad(self.aim_angle - 90)) * 48 + self.position.x + 0
                    local by = math.sin(math.rad(self.aim_angle - 90)) * 48 + self.position.y + 36
                    self.fire_delay = math.random(self.min_fire_delay, self.max_fire_delay)
                    Game.bullet_manager:add(bx, by, self.aim_angle - 90)
                end
            else

            end
        end

        if self.position.x < Game.camera.position.x - 64 then
            self.destroy_flag = true
        end
    end

    self.render = function(self)
        love.graphics.setColor(255, 255, 255)

        love.graphics.draw(self.gun_image, self.position.x, self.position.y + 44, math.rad(self.aim_angle), 1, 1, 48, 96)
        love.graphics.draw(self.base_image, self.position.x, self.position.y, 0, 1, 1, 48, 48)
    end

    self.take_damage = function(self, amount)
        self.health = self.health - amount
        if self.health <= 0 then
            self.destroy_flag = true
        end
    end

    return self
end

function create_enemy_manager(capacity)
    local self = {}

    self.pool = create_object_pool(create_enemy, capacity)

    self.add = function(self, ...)
        return self.pool:add(...)
    end

    self.remove = function(self, enemy)
        self.pool:remove(enemy)
    end

    self.update = function(self, dt)
        self.pool:remove_flagged()
        self.pool:execute_obj_func("update", dt)
    end

    self.render = function(self)
        self.pool:execute_obj_func("render")
    end

    self.on_collision_begin = function(self, handle, other, coll)
        self.pool.objects[handle]:take_damage(1)
    end

    return self
end