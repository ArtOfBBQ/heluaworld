local gameobjects = {}
local elapsed
local previous_time = os.clock()
local debug_mode = false

local i_player = 1

local clicked_x = 0
local clicked_y = 0
local saved_text = ""


function love.load()

    local object = require('modules.object')
    local collision = require('modules.collision')
    local images = require('modules.imagefilenames')
    local camera = require('modules.camera')
    local map = require('modules.map')
    local keyboard = require('modules.keyboard')

    love.window.setMode(camera.width, camera.height, {resizable=false, vsync=false, minwidth=400, minheight=300})
    love.window.setTitle('Macro & Conquer')
    
    gameobjects[1] = object:newbuggy(1500, 1500)
    gameobjects[1].angle = 0
    gameobjects[1].weapon_angle = gameobjects[1].angle
    
    previous_time = os.clock()

end

function love.keypressed( key, scancode, isrepeat )

    keyboard.lastkeypressed = key
    keyboard['pressing' .. key] = true

end

function love.keyreleased( key, scancode, isrepeat )

    keyboard['pressing' .. key] = false

end


function love.mousepressed(x, y, button, istouch)

    clicked_x = camera.x_screen_to_world(x)
    clicked_y = camera.y_screen_to_world(y)

    map:cycle_tile(
        camera.x_screen_to_world(x),
        camera.y_screen_to_world(y))
    
end

function love.update(dt)

    elapsed = os.clock() - previous_time
    previous_time = os.clock()

    if keyboard.pressingp then
        camera:zoom_in(elapsed)
    end

    if keyboard.pressingo then
        camera:zoom_out(elapsed)
    end
    camera.cur_width = camera.width * camera.zoom
    camera.cur_height = camera.height * camera.zoom

    if keyboard.pressingd then camera:scroll_right(elapsed, map.width) end
    if keyboard.pressinga then camera:scroll_left(elapsed) end
    if keyboard.pressingw then camera:scroll_up(elapsed) end
    if keyboard.pressings then camera:scroll_down(elapsed, map.height) end

    if keyboard.pressingright
        and math.abs(gameobjects[i_player].x_velocity) < gameobjects[i_player].max_speed_while_rotating 
        and math.abs(gameobjects[i_player].y_velocity) < gameobjects[i_player].max_speed_while_rotating
        and gameobjects[i_player].colliding == false
    then 
        gameobjects[i_player]:rotate_right(elapsed) 
    end

    if keyboard.pressingleft
        and math.abs(gameobjects[i_player].x_velocity) < gameobjects[i_player].max_speed_while_rotating 
        and math.abs(gameobjects[i_player].y_velocity) < gameobjects[i_player].max_speed_while_rotating
        and gameobjects[i_player].colliding == false
    then 
        gameobjects[i_player]:rotate_left(elapsed)
    end

    if keyboard.pressingup then gameobjects[i_player]:accelerate(elapsed) end

    if keyboard.pressingdown then gameobjects[i_player]:reverse(elapsed) end
    
    if keyboard['pressing_'] then gameobjects[i_player]:rotate_weapon_right(elapsed) end
    if keyboard['pressing/'] then gameobjects[i_player]:rotate_weapon_left(elapsed) end
    
    
    -- decelerate naturally and update all object coordinates
    for i = 1, #gameobjects, 1 do
        gameobjects[i]:decelerate(elapsed)
        gameobjects[i]:update_position(map.width, map.height)

        -- this big code block updates the 4 vital coordinates of our rectangular object
        -- given the center and the angle they're currently rotated at
        gameobjects[i].topleft_x = gameobjects[i].x + collision.rotate_x_coord(
            -gameobjects[i].width / 2,
            -gameobjects[i].height / 2,
            gameobjects[i].angle)
        gameobjects[i].topleft_y = gameobjects[i].y + collision.rotate_y_coord(
            -gameobjects[i].width / 2,
            -gameobjects[i].height / 2,
            gameobjects[i].angle)
        gameobjects[i].topright_x = gameobjects[i].x + collision.rotate_x_coord(
            gameobjects[i].width / 2,
            -gameobjects[i].height / 2,
            gameobjects[i].angle)
        gameobjects[i].topright_y = gameobjects[i].y + collision.rotate_y_coord(
            gameobjects[i].width / 2,
            -gameobjects[i].height / 2,
            gameobjects[i].angle)
        gameobjects[i].bottomright_x = gameobjects[i].x + collision.rotate_x_coord(
            gameobjects[i].width / 2,
            gameobjects[i].height / 2,
            gameobjects[i].angle)
        gameobjects[i].bottomright_y = gameobjects[i].y + collision.rotate_y_coord(
            gameobjects[i].width / 2,
            gameobjects[i].height / 2,
            gameobjects[i].angle)
        gameobjects[i].bottomleft_x = gameobjects[i].x + collision.rotate_x_coord(
            -gameobjects[i].width / 2,
            gameobjects[i].height / 2,
            gameobjects[i].angle)
        gameobjects[i].bottomleft_y = gameobjects[i].y + collision.rotate_y_coord(
            -gameobjects[i].width / 2,
            gameobjects[i].height / 2,
            gameobjects[i].angle)
        
        -- about to detect collisions so set to false 
        gameobjects[i].colliding = false
    end

    collision.update_all_collisions(gameobjects)

end

function love.draw()

    -- draw background tiles
    for i = 1, #map.background_tiles do

        assert(map.background_tiles[i] ~= nil)
        assert(map.background_tiles[i].image ~= nil)

        love.graphics.draw(
            images[map.background_tiles[i].image],
            camera.x_world_to_screen(map.background_tiles[i].left),
            camera.y_world_to_screen(map.background_tiles[i].top),
            0,
            camera.zoom,
            camera.zoom
        )
    end
    
    for i = 1, #gameobjects, 1 do

        love.graphics.setColor(1, 1, 1)
        assert(gameobjects[i].sprite_frame ~= nil)
        assert(images[gameobjects[i].sprite_frame] ~= nil)
        love.graphics.draw(
            images[gameobjects[i].sprite_frame],
            camera.x_world_to_screen(gameobjects[i].x),
            camera.y_world_to_screen(gameobjects[i].y),
            gameobjects[i].angle,
            gameobjects[i].size_modifier * camera.zoom,
            gameobjects[i].size_modifier * camera.zoom,
            images[gameobjects[i].sprite_frame]:getWidth() / 2,
            images[gameobjects[i].sprite_frame]:getHeight() / 2)
        
        if gameobjects[i]['weapon_angle'] ~= nil then
            love.graphics.draw(
                images[gameobjects[i].sprite_top],
                camera.x_world_to_screen(gameobjects[i].x + collision.rotate_x_coord(0, gameobjects[i].weapon_y_offset, gameobjects[i].angle)),
                camera.y_world_to_screen(gameobjects[i].y + collision.rotate_y_coord(0, gameobjects[i].weapon_y_offset, gameobjects[i].angle)),
                gameobjects[i].weapon_angle,
                gameobjects[i].size_modifier * camera.zoom,
                gameobjects[i].size_modifier * camera.zoom,
                images[gameobjects[i].sprite_top]:getWidth() / 2,
                images[gameobjects[i].sprite_top]:getHeight() / 2)
        end
        
        -- for debugging only, draw little circles to outline the object
        if debug_mode then

            if gameobjects[i].colliding then love.graphics.setColor(1, 0.15, 0.15) else love.graphics.setColor(1, 1, 1) end

            love.graphics.circle(
                "fill",
                camera.x_world_to_screen(gameobjects[i].topleft_x),
                camera.y_world_to_screen(gameobjects[i].topleft_y),
                2)

            love.graphics.circle(
                "fill",
                camera.x_world_to_screen(gameobjects[i].x),
                camera.y_world_to_screen(gameobjects[i].y),
                2)
            
            love.graphics.circle(
                "fill",
                camera.x_world_to_screen(gameobjects[i].topright_x),
                camera.y_world_to_screen(gameobjects[i].topright_y),
                2)
            
            love.graphics.circle(
                "fill",
                camera.x_world_to_screen(gameobjects[i].bottomright_x),
                camera.y_world_to_screen(gameobjects[i].bottomright_y),
                2)
            
            love.graphics.circle(
                "fill",
                camera.x_world_to_screen(gameobjects[i].bottomleft_x),
                camera.y_world_to_screen(gameobjects[i].bottomleft_y),
                2)
        end
        -- end of debugging code

    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("x velocity: " .. math.floor(gameobjects[i_player].x_velocity * 100)/100, camera.width - 135, 50)
    love.graphics.print("y velocity: " .. math.floor(gameobjects[i_player].y_velocity * 100)/100, camera.width - 135, 70)
    love.graphics.print("angle: " .. math.floor(gameobjects[i_player].angle * 100) / 100, camera.width - 135, 90)
    love.window.setTitle(gameobjects[i_player].angle)
    love.graphics.print("x (center): " .. math.floor(gameobjects[i_player].x), camera.width - 135, 110)
    love.graphics.print("y (center): " .. math.floor(gameobjects[i_player].y), camera.width - 135, 130)
    love.graphics.print("elapsed: " .. math.floor(elapsed * 1000) / 1000, camera.width - 135, 150)
    love.graphics.print("size modifier: " .. gameobjects[i_player].size_modifier, camera.width - 135, 170)
    love.graphics.print("width: " .. gameobjects[i_player].width, camera.width - 135, 190)
    love.graphics.print("height: " .. gameobjects[i_player].width, camera.width - 135, 210)
    love.graphics.print("camera left: " .. camera.left, camera.width - 135, 230)
    love.graphics.print("camera top: " .. camera.top, camera.width - 135, 250)
    love.graphics.print("last key: " .. keyboard.lastkeypressed, camera.width - 135, 270)
    love.graphics.print("player colliding: " .. tostring(gameobjects[i_player].colliding), camera.width - 135, 290)
    love.graphics.print("camera width: " .. camera.width, camera.width - 135, 310)
    love.graphics.print("map width: " .. map.width, camera.width - 135, 330)
    love.graphics.print("last clicked x: " .. clicked_x, camera.width - 135, 350)
    love.graphics.print("last clicked y: " .. clicked_y, camera.width - 135, 370)
    love.graphics.print("file was: " .. saved_text, camera.width - 135, 390)

    
end
