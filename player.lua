function create_player(x, y)
    local self = {}

    self.position = {}
    self.position.x = x
    self.position.y = y

    self.radius = 16

    self.controller = nil

    self.image = Images:get_image("blimp")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.ox = self.width / 2
    self.oy = self.height / 2

    self.body = love.physics.newBody(Collision.world, self.position.x, self.position.y, "kinematic")
    self.body:setMass(1)
    self.body:setActive(true)
    self.shape1 = love.physics.newRectangleShape(4, 16, 40, 32)
    self.shape2 = love.physics.newRectangleShape(4, -24, 84, 32)
    self.fixture1 = love.physics.newFixture(self.body, self.shape1)
    self.fixture1:setFilterData(collision_tag_filter_data("cPlayer"))
    self.fixture1:setUserData(collision_create_tag("cPlayer", 1))
    self.fixture2 = love.physics.newFixture(self.body, self.shape2)
    self.fixture2:setFilterData(collision_tag_filter_data("cPlayer"))
    self.fixture2:setUserData(collision_create_tag("cPlayer", 1))

    self.normal_color = { 255, 255, 255 }
    self.hit_color = { 255, 0, 0 }
    self.hit_time = 0.05
    self.hit_timer = 0
    self.color = self.normal_color

    self.update = function(self, dt)
        if self.controller ~= nil then
            self.controller:update(dt)
        end

        self.body:setX(self.position.x)
        self.body:setY(self.position.y)

        if self.hit_timer > 0 then
            self.hit_timer = self.hit_timer - dt
            if self.hit_timer <= 0 then
                self.color = self.normal_color
            end
        end
    end

    self.render = function(self)
        love.graphics.setColor(unpack(self.color))
        love.graphics.draw(self.image, self.position.x, self.position.y, 0, 1, 1, self.ox, self.oy)
    end

    self.on_collision_begin = function(self, other)
        self.hit_timer = self.hit_time
        self.color = self.hit_color
    end

    return self
end

function create_player_controller(player)
    local self = {}

    self.player = player
    self.player.controller = self
    self.speed = 250

    self.fire_delay = 0.2
    self.fire_timer = 0

    self.update = function(self, dt)
        local h = Input:get_axis("horizontal")
        local v = Input:get_axis("vertical")

        self.player.position.x = self.player.position.x + Game.move_speed * dt
        self.player.position.x = self.player.position.x + (h * self.speed * dt)
        self.player.position.y = self.player.position.y + (v * self.speed * dt)

        if Input:get_button("fire") then
            self.fire_timer = self.fire_timer - dt
            if self.fire_timer <= 0 then
                local bvx = h * self.speed + Game.move_speed
                -- local bvx = Game.move_speed
                Game.bomb_manager:add(self.player.position.x, self.player.position.y + 20, bvx)
                self.fire_timer = self.fire_delay
            end
        end
    end

    return self
end