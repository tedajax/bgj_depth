require 'objectpool'

function create_bomb()
    local self = {}

    self.active = false
    self.destroy_flag = false
    self.handle = 0

    self.position = { x = 0, y = 0 }
    self.velocity = { x = 0, y = 0 }

    self.gravity = 1000
    self.friction = 0

    self.image = Images:get_image("bomb")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.ox = self.width / 2
    self.oy = self.height / 2

    self.body = love.physics.newBody(Collision.world, self.position.x, self.position.y, "dynamic")
    self.body:setMass(1)
    self.body:setActive(false)
    self.shape = love.physics.newRectangleShape(16, 16)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFilterData(collision_tag_filter_data("cBomb"))

    self.activate = function(self, x, y, vx)
        self.position.x = x
        self.position.y = y
        self.velocity.x = vx or 0
        self.body:setActive(true)
        self.body:setX(self.position.x)
        self.body:setY(self.position.y)
        self.fixture:setUserData(collision_create_tag("cBomb", self.handle))
        -- Audio:play_sfx("bomb_drop")
    end

    self.release = function(self)
        self.velocity.x = 0
        self.velocity.y = 0
        self.body:setActive(false)
    end

    self.on_release = function(self)
        local s = math.random() * (1 - 1) + 1
        Game.explosion_manager:add(self.position.x, self.position.y, s)
    end

    self.update = function(self, dt)
        self.velocity.x = self.velocity.x * (1 - self.friction)
        self.velocity.y = self.velocity.y + self.gravity * dt
        self.position.x = self.position.x + self.velocity.x * dt
        self.position.y = self.position.y + self.velocity.y * dt

        self.body:setX(self.position.x)
        self.body:setY(self.position.y)

        if self.position.y > 210 then
            self.destroy_flag = true
        end
    end

    self.render = function(self)
        love.graphics.setColor(255, 255, 25)
        love.graphics.draw(self.image, self.position.x, self.position.y, 0, 1, 1, self.ox, self.oy)
    end

    return self
end

function create_bomb_manager(capacity)
    local self = {}

    self.pool = create_object_pool(create_bomb, capacity)

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