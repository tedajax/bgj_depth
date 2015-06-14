require 'game'
require 'player'
require 'input'
require 'images'
require 'bomb'
require 'collision'

function love.load()
    Input = create_input()

    Input:add_axis("horizontal")
    Input:add_axis("vertical")
    Input:add_button("fire")

    Input:create_axis_binding("horizontal", "left", -1)
    Input:create_axis_binding("horizontal", "right", 1)
    Input:create_axis_binding("vertical", "up", -1)
    Input:create_axis_binding("vertical", "down", 1)

    Input:create_button_binding("fire", "z")

    Images = create_images()
    Images:load_image("blimp", "assets/nuclear_blimp.png")
    Images:load_image("bomb", "assets/bomb.png")
    Images:load_image("dirt", "assets/dirt.png")
    Images:load_image("grass", "assets/grass.png")
    Images:load_image("turret_base", "assets/turret_base.png")
    Images:load_image("turret_gun", "assets/turret_gun.png")
    Images:load_image("bullet", "assets/bullet.png")
    Images:load_image("daynight", "assets/daynight.png")
    Images:load_image("daynight_colors", "assets/daynightcolors.png")
    Images:load_image("bg1", "assets/bg1.png")
    Images:load_image("bg2", "assets/bg2.png")
    Images:load_image("explosion", "assets/explosion.png")

    Collision = create_collision()
    Game = create_game()
    Game:init()

    love.graphics.setBackgroundColor(100, 149, 237)
end

function love.update(dt)
    Collision:update(dt)
    Game:update(dt)
    Input:update()
end

function love.draw(dt)
    Game:render()

    local fps = love.timer.getFPS()
    love.graphics.setColor(0, 255, 0)
    love.graphics.print("FPS: "..fps, 5, 5)
    love.graphics.print("Time: "..Game.background:get_time_string(), 5, 25)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "e" then
        Game.explosion_manager:add(Game.camera.position.x + math.random(800), Game.camera.position.y + math.random(600), math.random() * 3 + 1)
    end

    Input:on_key_down(key)
end

function love.keyreleased(key)
    Input:on_key_up(key)
end