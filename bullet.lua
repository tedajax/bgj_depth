require 'objectpool'

function create_bullet()
    local self = {}

    self.active = false
    self.destroy_flag = false
    self.handle = 0

    self.position = { x = 0, y = 0 }
    self.angle = 0
    self.speed = 1000

    self.image = Images:get_image("bullet")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.ox = self.width / 2
    self.oy = self.height / 2

    self.body = love.physics.newBody(Collision.world, self.position.x, self.position.y, "dynamic")
    self.body:setMass(1)
    self.body:setActive(false)
    self.shape = love.physics.newRectangleShape(16, 16)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFilterData(collision_tag_filter_data("cEnemyBullet"))

    self.activate = function(self, x, y, angle)
        self.position.x = x
        self.position.y = y
        self.angle = angle
        self.body:setActive(true)
        self.body:setX(self.position.x)
        self.body:setY(self.position.y)
        self.fixture:setUserData(collision_create_tag("cEnemyBullet", self.handle))
    end

    self.release = function(self)
        self.body:setActive(false)
    end

    self.update = function(self, dt)
        local vx = math.cos(math.rad(self.angle)) * self.speed
        local vy = math.sin(math.rad(self.angle)) * self.speed
        self.position.x = self.position.x + vx * dt
        self.position.y = self.position.y + vy * dt

        self.body:setX(self.position.x)
        self.body:setY(self.position.y)

        if self.position.y < Game.camera.position.y then
            self.destroy_flag = true
        end
    end

    self.render = function(self)
        love.graphics.setColor(255, 255, 25)
        love.graphics.draw(self.image, self.position.x, self.position.y, math.rad(self.angle + 90), 1, 1, self.ox, self.oy)
    end

    return self
end

function create_bullet_manager(capacity)
    local self = {}

    self.pool = create_object_pool(create_bullet, capacity)

    self.add = function(self, ...)
        return self.pool:add(...)
    end

    self.remove = function(self, bomb)
        self.pool:remove(bomb)
    end

    self.update = function(self, dt)
        self.pool:remove_flagged()
        self.pool:execute_obj_func("update", dt)
    end

    self.render = function(self)
        self.pool:execute_obj_func("render")
    end

    self.on_collision_begin = function(self, handle, other, coll)
        self.pool.objects[handle].destroy_flag = true
    end

    return self
end