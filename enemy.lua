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
    self.shape = love.physics.newRectangleShape(64, 24)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFilterData(collision_tag_filter_data("cEnemy"))

    self.max_health = 3
    self.health = 0

    self.min_fire_delay = 0.5
    self.max_fire_delay = 3
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
        for i = 1, math.random(1, 3) do
            local s = math.random() * (3 - 1) + 1
            local x = self.position.x + math.random(-32, 32)
            local y = self.position.y + 24 + math.random(-12, 12)
            Game.explosion_manager:add(x, y, s)
        end
    end

    self.update = function(self, dt)
        print(self.aim_angle)
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
                    local bx = math.cos(math.rad(self.aim_angle - 90)) * 32 + self.position.x
                    local by = math.sin(math.rad(self.aim_angle - 90)) * 32 + self.position.y + 20
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

        love.graphics.draw(self.gun_image, self.position.x, self.position.y + 30, math.rad(self.aim_angle), 1, 1, 32, 64)
        love.graphics.draw(self.base_image, self.position.x, self.position.y, 0, 1, 1, 32, 32)
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