-- each obstacle and unit in our RTS is in this array. We're using it everywhere
-- and it's a singleton, so I'm using a global variable instead of passing it around everywhere
gameobjects = {}

-- the time elapsed since the previous iteration of our game loop
elapsed = 0

local previous_time = os.clock()

-- testing code, to be removed later
local debug_mode = true
local i_player = 1
local i_grabbing = nil
local clicked_x = 0
local clicked_y = 0
local saved_text = ""
-- /to be removed later


function love.load()

    local object = require('modules.object')
    local driver = require('modules.driver')
    local collision = require('modules.collision')
    local images = require('modules.imagefilenames')
    local camera = require('modules.camera')
    local map = require('modules.map')
    local keyboard = require('modules.keyboard')

    love.window.setMode(camera.width, camera.height, {resizable=false, vsync=false, minwidth=400, minheight=300})
    love.window.setTitle('Produce & Conquer')
    
    -- testing code, to be removed later
    gameobjects[1] = object:newbuggy(500, 1000)
    gameobjects[1].angle = 0
    gameobjects[1].weapon_angle = gameobjects[1].angle
    gameobjects[1].waypoints = {
        {x = 600, y = 950}
    }
    -- /to be removed later

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

    clicked_x = camera:x_screen_to_world(x)
    clicked_y = camera:y_screen_to_world(y)

    if i_grabbing == nil then
        for i = 1, #gameobjects, 1 do
            if collision.point_collides_rotated_object(
                clicked_x,
                clicked_y,
                gameobjects[i]) then
                    i_grabbing = i
                    return
            end
        end
    else
        gameobjects[i_grabbing].x = clicked_x
        gameobjects[i_grabbing].y = clicked_y
        gameobjects[i_grabbing]:update_corner_coordinates()
        i_grabbing = nil
        return
    end

    if keyboard['pressingr'] then
        gameobjects[#gameobjects + 1] = object:newwall(camera:x_screen_to_world(x), camera:y_screen_to_world(y))
    elseif keyboard['pressingt'] then
        gameobjects[#gameobjects + 1] = object:newtree(camera:x_screen_to_world(x), camera:y_screen_to_world(y))
    elseif keyboard['pressingm'] then
        map:cycle_texture(
            camera:x_screen_to_world(x),
            camera:y_screen_to_world(y))
    elseif keyboard['pressingn'] then
        map:cycle_angle(
            camera:x_screen_to_world(x),
            camera:y_screen_to_world(y))
    elseif keyboard['pressingb'] then
        map:cycle_fit(
            camera:x_screen_to_world(x),
            camera:y_screen_to_world(y))
    else
        -- if debug_mode == false then debug_mode = true else debug_mode = false end
        gameobjects[i_player].waypoints[#gameobjects[i_player].waypoints + 1] = {
            x = camera:x_screen_to_world(x),
            y = camera:y_screen_to_world(y)}
    end
    
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

    if keyboard['pressingz'] then map:save_tiles_as_hardcode("/users/jelle//test.lua", gameobjects) end
    
    
    -- decelerate naturally and update all object coordinates
    for i = 1, #gameobjects, 1 do

        if gameobjects[i].max_speed ~= 0 then
            gameobjects[i]:decelerate(elapsed)
            gameobjects[i]:update_position(map.width, map.height)
            driver.drive(gameobjects[i])
            
            gameobjects[i]:update_corner_coordinates()

        end
        
        -- about to detect collisions so set to false 
        gameobjects[i].colliding = false
    end

    collision.update_all_collisions()

end

function love.draw()

    -- draw background tiles
    for i = 1, #map.background_tiles do

        assert(map.background_tiles[i] ~= nil)
        map.background_tiles[i].image = images.tile_to_filename(map.background_tiles[i])

        if images[map.background_tiles[i].image] ~= nil then
            local sprite_width = images[map.background_tiles[i].image]:getWidth() / 2
            local sprite_height = images[map.background_tiles[i].image]:getHeight() / 2
            
            love.graphics.draw(
                images[map.background_tiles[i].image],
                camera.x_world_to_screen(map.background_tiles[i].left),
                camera.y_world_to_screen(map.background_tiles[i].top),
                0,
                camera.zoom,
                camera.zoom,
                sprite_width,
                sprite_height)
        end
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
    love.graphics.print("x (center): " .. math.floor(gameobjects[i_player].x), camera.width - 135, 110)
    love.graphics.print("y (center): " .. math.floor(gameobjects[i_player].y), camera.width - 135, 130)
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
    if gameobjects[i_player].waypoints ~= nil and #gameobjects[i_player].waypoints > 0 then
        love.graphics.print("buggy goal angle: " .. driver.get_goal_angle(gameobjects[i_player]), camera.width - 135, 410)
    end
    love.graphics.print("grabbed object: " .. tostring(i_grabbing), camera.width - 135, 430)


    love.graphics.setColor(0.1, 0.1, 1)
    for i = 1, #gameobjects[i_player].waypoints, 1 do

        love.graphics.circle(
            "fill",
            camera.x_world_to_screen(gameobjects[i_player].waypoints[i].x),
            camera.y_world_to_screen(gameobjects[i_player].waypoints[i].y),
            5)
        
    end
    love.graphics.setColor(1, 1, 1)

end
