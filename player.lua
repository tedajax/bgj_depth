PlayerState = {
    cAlive = 0,
    cDead = 1,
    cExploded = 2
}

function create_player(x, y)
    local self = {}

    self.position = {}
    self.position.x = x
    self.position.y = y
    self.rotation = 0

    self.radius = 16

    self.controller = nil

    self.state = PlayerState.cAlive

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

    self.max_health = 1
    self.health = self.max_health

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
        love.graphics.draw(self.image, self.position.x, self.position.y, math.rad(self.rotation), 1, 1, self.ox, self.oy)
    end

    self.render_health = function(self)
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", 5, 5, 202, 17)

        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", 6, 6, (self.health / self.max_health) * 200, 15)
    end

    self.on_collision_begin = function(self, other)
        if self.health > 0 then
            self.hit_timer = self.hit_time
            self.color = self.hit_color
            self.health = self.health - 1

            Game.camera:shake(0.2, 5)

            Audio:play_sfx("player_hit")

            if self.health <= 0 then
                self.state = PlayerState.cDead
            end
        end
    end

    return self
end

function create_player_controller(player)
    local self = {}

    self.player = player
    self.player.controller = self
    self.speed = 350

    self.fire_delay = 0.2
    self.fire_timer = 0

    self.update = function(self, dt)
        if self.player.state == PlayerState.cAlive then
            local h = Input:get_axis("horizontal")
            local v = Input:get_axis("vertical")

            self.player.position.x = self.player.position.x + Game.move_speed * dt
            self.player.position.x = self.player.position.x + (h * self.speed * dt)
            self.player.position.y = self.player.position.y + (v * self.speed * dt)
        elseif self.player.state == PlayerState.cDead then
            self.player.rotation = 45
            self.player.position.x = self.player.position.x + Game.move_speed * dt
            self.player.position.y = self.player.position.y + 75 * dt
            self.player.color = {255, 191, 63}

            if self.player.position.y > 220 then
                self.player.state = PlayerState.cExploded
                local min_scale = 1.5
                local max_scale = 5
                local minx = -48
                local maxx = 48
                local miny = -48
                local maxy = 48
                local yoff = 0
                local s = math.random() * (max_scale - min_scale) + min_scale
                local x = self.player.position.x + math.random(minx, maxx)
                local y = self.player.position.y + yoff + math.random(miny, maxy)
                local px = self.player.position.x
                local py = self.player.position.y
                Game.explosion_manager:add(x, y, s)
                Game.camera:shake(0.1, 5)
                Timer:add_periodic(0.33, function()
                    local es = math.random() * (max_scale - min_scale) + min_scale
                    local ex = px + math.random(minx, maxx)
                    local ey = py + yoff + math.random(miny, maxy)
                    Game.explosion_manager:add(ex, ey, es)
                    Game.camera:shake(0.1, 5)
                end, math.random(3, 7))
            end
        else
        end

        if self.player.position.x < Game.camera.position.x + 64 then
            self.player.position.x = Game.camera.position.x + 64
        end

        if self.player.position.x > Game.camera.position.x + (love.graphics.getWidth() - 72) then
            self.player.position.x = Game.camera.position.x + (love.graphics.getWidth() - 72)
        end

        if self.player.position.y < -220 then
            self.player.position.y = -220
        end

        if Input:get_button("fire") then
            self.fire_timer = self.fire_timer - dt
            if self.fire_timer <= 0 then
                local bvx = h * self.speed + Game.move_speed
                -- local bvx = Game.move_speed
                Game.bomb_manager:add(self.player.position.x, self.player.position.y + 20, bvx)
                self.fire_timer = self.fire_delay
            end
        else
            self.fire_timer = 0
        end
    end

    return self
end