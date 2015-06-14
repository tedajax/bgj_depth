function create_camera(x, y)
    local self = {}

    self.position = { x = x - love.graphics.getWidth() / 2, y = y - love.graphics.getHeight() / 2 }
    self.rotation = 0
    self.zoom = 1

    self.move = function(self, x, y)
        local x = x or 0
        local y = y or 0
        self.position.x = self.position.x + x
        self.position.y = self.position.y + y
    end

    self.look_at = function(self, x, y)
        self.position.x = x - love.graphics.getWidth() / 2
        self.position.y = y - love.graphics.getHeight() / 2
    end

    self.rotate = function(self, angle)
        self.rotation = self.rotation + angle
    end

    self.set_rotation = function(self, angle)
        self.rotation = angle
    end

    self.zoom_in = function(self, zoom)
        self.zoom = self.zoom - zoom
    end

    self.zoom_out = function(self, zoom)
        self.zoom = self.zoom + zoom
    end

    self.set_zoom = function(self, zoom)
        self.zoom = zoom
    end

    self.push = function(self)
        love.graphics.push()
        love.graphics.translate(-self.position.x, -self.position.y)
        love.graphics.rotate(-math.rad(self.rotation))
        love.graphics.scale(1 / self.zoom, 1 / self.zoom)
    end

    self.pop = function(self)
        love.graphics.pop()
    end

    return self
end