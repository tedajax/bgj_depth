function create_timer()
    local self = {}

    self.functions = {}

    self._noop_ = function() print("noop") end

    self.update = function(self, dt)
        local remove_queue = {}

        for handle, delay in pairs(self.functions) do
            delay = delay - dt
            if delay <= 0 then
                table.insert(remove_queue, handle)
            end
            self.functions[handle] = delay
            if handle.func ~= nil then
                handle.func(dt, delay)
            end
        end

        for _, handle in ipairs(remove_queue) do
            self.functions[handle] = nil
            handle.after(handle.after)
        end
    end

    self.do_for = function(self, delay, func, after)
        local handle = { func = func, after = after }
        self.functions[handle] = delay
        return handle
    end

    self.add = function(self, delay, func)
        return self:do_for(delay, nil, func)
    end

    self.add_periodic = function(self, delay, func, count)
        local count = count or math.huge
        return self:add(delay, function(f)
            if func(func) == false then return end

            count = count - 1
            if count > 0 then
                self:add(delay, f)
            end
        end)
    end

    self.cancel = function(self, handle)
        self.functions[handle] = nil
    end

    self.clear = function(self)
        self.functions = {}
    end

    return self
end