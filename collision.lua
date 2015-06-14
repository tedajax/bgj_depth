ColliderTag = {
    cUnknown = 0,
    cPlayer = 1,
    cEnemy = 2,
    cBomb = 3,
    cEnemyBullet = 4,
}

ColliderFilters = {}
ColliderFilters[ColliderTag.cUnknown]       = { category = 0, mask = 0, group = 0  }
ColliderFilters[ColliderTag.cPlayer]        = { category = 4, mask = 8, group = 0  }
ColliderFilters[ColliderTag.cEnemy]         = { category = 2, mask = 1, group = 0  }
ColliderFilters[ColliderTag.cBomb]          = { category = 1, mask = 2, group = -1 }
ColliderFilters[ColliderTag.cEnemyBullet]   = { category = 8, mask = 4, group = -2  }

function collision_create_tag(tag, handle)
    return { tag = ColliderTag[tag], handle = handle }
end

function collision_tag_filter_data(tag)
    local f = ColliderFilters[ColliderTag[tag]]
    return f.category, f.mask, f.group
end

function collision_on_begin(a, b, coll)
    Collision:on_begin(a, b, coll)
    Collision:on_begin(b, a, coll)
end

function collision_on_end(a, b, coll)
    Collision:on_end(a, b, coll)
    Collision:on_end(b, a, coll)
end

function collision_on_pre_solve(a, b, coll)
end

function collision_on_post_solve(a, b, coll, normal1, tangent1, normal2, tangent2)
end

function create_collision()
    local self = {}

    self.world = love.physics.newWorld(0, 0, false)

    self.world:setCallbacks(collision_on_begin,
        collision_on_end,
        collision_on_pre_solve,
        collision_on_post_solve)

    self.update = function(self, dt)
        self.world:update(dt)
    end

    self.on_begin = function(self, a, b, coll)
        local coll_tag = a:getUserData()

        if coll_tag.tag == ColliderTag.cBomb then
            Game.bomb_manager:on_collision_begin(coll_tag.handle, b)
        elseif coll_tag.tag == ColliderTag.cEnemy then
            Game.enemy_manager:on_collision_begin(coll_tag.handle, b)
        elseif coll_tag.tag == ColliderTag.cEnemyBullet then
            Game.bullet_manager:on_collision_begin(coll_tag.handle, b)
        elseif coll_tag.tag == ColliderTag.cPlayer then
            Game.player:on_collision_begin(b)
        end
    end

    self.on_end = function(self, a, b, coll)
    end

    self.debug_draw = function(self)
        love.graphics.setColor(255, 255, 0)
        local bodies = self.world:getBodyList()
        for _, b in pairs(bodies) do
            if b:isActive() then
                local fixtures = b:getFixtureList()
                for _, f in pairs(fixtures) do
                    local shape = f:getShape()
                    local tx, ty, bx, by = shape:computeAABB(b:getX(), b:getY(), 0)
                    love.graphics.rectangle("line", tx, ty, (bx - tx), (by - ty))
                end
            end
        end
    end

    return self
end