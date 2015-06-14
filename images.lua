function create_images()
    local self = {}

    self.images = {}

    self.get_image = function(self, name)
        return self.images[name]
    end

    self.load_image = function(self, name, path)
        local image = love.graphics.newImage(path)
        if image ~= nil then
            self.images[name] = image
        end
        return self.images[name]
    end

    return self
end