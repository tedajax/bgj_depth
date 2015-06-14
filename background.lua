function create_background()
    local self = {}

    self.day_hours = 24
    self.time = 0
    self.time_scale = 240
    self.cSecondsToHour = 1 / 3600

    self.skybox_gradient = Images:get_image("daynight")
    self.sky_width, self.sky_height = self.skybox_gradient:getDimensions()
    self.skybox_quad = love.graphics.newQuad(0, 0,
                                             1, self.sky_height,
                                             self.sky_width, self.sky_height)
    self.skybox_height_scale = love.graphics.getHeight() / self.sky_height
    self.skybox_delay = 2

    self.color_image = Images:get_image("daynight_colors")
    self.color_data = self.color_image:getData()

    self.time_colors = {}
    for i = 0, self.color_data:getWidth() - 1 do
        local r, g, b = self.color_data:getPixel(i, 0)
        table.insert(self.time_colors, { r = r, g = g, b = b })
    end

    self.bg_layers = {}
    table.insert(self.bg_layers, create_bg_layer("bg2", 8, 50, 0.3, 1))
    table.insert(self.bg_layers, create_bg_layer("bg1", 2, 270, 0.3, 1))

    self.multiply_color = { r = 255, g = 255, b = 255 }

    self.set_time = function(self, hours, minutes)
        while minutes < 0 do
            hours = hours - 1
            minutes = minutes + 60
        end

        while minutes >= 60 do
            hours = hours + 1
            minutes = minutes - 60
        end

        self.time = hours + (minutes / 60)

        while self.time < 0 do self.time = self.time + 24 end
        while self.time >= 24 do self.time = self.time - 24 end
    end

    self.get_time_string = function(self)
        local hours = math.floor(self.time)
        local minutes = math.floor((self.time - hours) * 60)

        return string.format("%02.0f:%02.0f", hours, minutes)
    end

    self.update = function(self, dt)
        self.time = self.time + dt * self.time_scale * self.cSecondsToHour

        while self.time >= self.day_hours do self.time = self.time - self.day_hours end
        while self.time < 0 do self.time = self.time + 24 end

        local time_ratio = self.time / self.day_hours
        local position = math.floor(time_ratio * self.sky_width)

        self.skybox_quad:setViewport(position, 0,
                                     1, self.sky_height)

        local color_position = math.floor(time_ratio * #self.time_colors) + 1
        self.multiply_color = self.time_colors[color_position]

        for _, bg in ipairs(self.bg_layers) do
            bg:set_horizontal_position(Game.camera.position.x)
        end
    end

    self.render = function(self)
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.skybox_gradient,
                           self.skybox_quad,
                           0, 0,
                           0,
                           love.graphics.getWidth(), self.skybox_height_scale)



        local r, g, b = self.multiply_color.r, self.multiply_color.g, self.multiply_color.b
        for _, bg in ipairs(self.bg_layers) do
            bg:render(r, g, b)
        end
    end

    return self
end

function create_bg_layer(imagename, ratio, vertanchor, offset, scale)
    local self = {}

    self.image = Images:get_image(imagename)
    self.ratio = ratio or 1
    self.vert_anchor = vertanchor or 0
    self.offset = offset or 0
    self.scale = scale or 1

    self.image:setWrap("repeat", "repeat")

    self.vert_anchor = self.vert_anchor / self.scale

    self.width, self.height = self.image:getDimensions()
    self.width = self.width * self.scale
    self.height = self.height * self.scale
    self.quad = love.graphics.newQuad(0, 0,
                                      love.graphics.getWidth(),
                                      self.height,
                                      self.width,
                                      self.height)

    self.set_horizontal_position = function(self, x)
        local sx = x / self.ratio + (self.offset * self.width)
        self.quad:setViewport(sx, 0, love.graphics.getWidth(), self.height)
    end

    self.render = function(self, r, g, b)
        local r = r or 255
        local g = g or 255
        local b = b or 255

        --love.graphics.setColor(r, g, b)
        love.graphics.draw(self.image, self.quad, 0, self.vert_anchor)
    end

    return self
end