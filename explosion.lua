require 'objectpool'

function create_explosion()
    local self = {}

    self.handle = 0
    self.active = false
    self.destroy_flag = false

    self.image = Images:get_image("explosion")
    self.quad = love.graphics.newQuad(0, 0, 64, 64, self.image:getDimensions())

    self.frame_count = 16
    self.frame = 0
    self.frame_delay = 0.05
    self.frame_timer = 0

    self.position = { x = 0, y = 0 }
    self.scale = 1

    self.activate = function(self, x, y, scale)
        if scale > 1.5 then
            local name = "explosion_big"--..math.random(1, 2)
            Audio:play_sfx(name)
        else
            Audio:play_sfx("explosion_small")
        end
        self.frame = 0
        self.frame_timer = self.frame_delay
        self.position.x = x
        self.position.y = y
        self.scale = scale or 1
    end

    self.release = function(self)

    end

    self.update_quad = function(self, frame)
        local x = self.frame % 4 * 64
        local y = math.floor(self.frame / 4) * 64
        self.quad:setViewport(x, y, 64, 64)
    end

    self.update = function(self, dt)
        self.frame_timer = self.frame_timer - dt
        if self.frame_timer <= 0 then
            self.frame_timer = self.frame_delay
            self.frame = self.frame + 1
            self:update_quad(self.frame)
            if self.frame == self.frame_count then self.destroy_flag = true end
        end
    end

    self.render = function(self)
        love.graphics.draw(self.image, self.quad, self.position.x, self.position.y, 0, self.scale, self.scale, 32, 32)
    end

    return self
end

function create_explosion_manager(capacity)
    local self = {}

    self.pool = create_object_pool(create_explosion, capacity)

    self.add = function(self, ...)
        return self.pool:add(...)
    end

    self.remove = function(self, explosion)
        self.pool:remove(explosion)
    end

    self.update = function(self, dt)
        self.pool:remove_flagged()
        self.pool:execute_obj_func("update", dt)
    end

    self.render = function(self)
        self.pool:execute_obj_func("render")
    end

    self.clear = function(self) self.pool:clear() end

    return self
end