-- each obstacle and unit in our RTS is in this array. We're using it everywhere
-- and it's a singleton, so I'm using a global variable instead of passing it around everywhere
gameobjects = {}

-- the time elapsed since the previous iteration of our game loop
elapsed = 0

local previous_time = os.clock()

-- testing code, to be removed later
local debug_mode = false
local i_player = 1
local i_grabbing = nil
local clicked_x = 0
local clicked_y = 0
-- /to be removed later


function love.load()

    local object = require('modules.object')
    local driver = require('modules.driver')
    local collision = require('modules.collision')
    local images = require('modules.imagefilenames')
    local camera = require('modules.camera')
    local map = require('modules.map')
    local pathfinding = require("modules.pathfinding")
    local keyboard = require('modules.keyboard')

    love.window.setMode(camera.width, camera.height, {resizable=false, vsync=false, minwidth=400, minheight=300})
    love.window.setTitle("Build & conquer")
    
    -- testing code, to be removed later
    gameobjects[1] = object:newtank(500, 900)
    gameobjects[1].angle = 0
    gameobjects[1].weapon_angle = gameobjects[1].angle
    -- /to be removed later

    for i = 1, #gameobjects, 1 do
        gameobjects[i]:update_corner_coordinates()
    end
    pathfinding.update_map_tiles_contains_obstacle(map)

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
        local clicked_tile = map:coords_to_tile(camera:x_screen_to_world(x), camera:y_screen_to_world(y))
        if map.background_tiles[clicked_tile].contains_obstacle == false then
            pathfinding.fill_waypoints(
                gameobjects[i_player],
                map.background_tiles[clicked_tile].left + (map.background_tiles[clicked_tile].width / 2),
                map.background_tiles[clicked_tile].top + (map.background_tiles[clicked_tile].height / 2))
        end
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
            local sprite_width = images[map.background_tiles[i].image]:getWidth()
            local sprite_height = images[map.background_tiles[i].image]:getHeight()
            
            love.graphics.draw(
                images[map.background_tiles[i].image],
                camera.x_world_to_screen(map.background_tiles[i].left + (map.background_tiles[i].width / 2)),
                camera.y_world_to_screen(map.background_tiles[i].top + (map.background_tiles[i].height / 2)),
                0,
                (map.background_tiles[i].width /sprite_width) * camera.zoom,
                (map.background_tiles[i].height /sprite_height) * camera.zoom,
                sprite_width / 2,
                sprite_height / 2
            )
        end

        if debug_mode then 

            if map.background_tiles[i].contains_obstacle then
                love.graphics.setColor(0.2, 0.2, 0.5)
            else
                love.graphics.setColor(0.5, 0.2, 0.2)
            end

            love.graphics.rectangle(
                "line",
                camera.x_world_to_screen(map.background_tiles[i].left),
                camera.y_world_to_screen(map.background_tiles[i].top),
                map.background_tiles[i].width * camera.zoom,
                map.background_tiles[i].height * camera.zoom)
            
            love.graphics.setColor(1, 1, 1)

        end
    end
    
    for i = 1, #gameobjects, 1 do

        love.graphics.setColor(1, 1, 1)
        assert(gameobjects[i].sprite_frame ~= nil)
        assert(images[gameobjects[i].sprite_frame] ~= nil)
        love.graphics.draw(
            images[gameobjects[i].sprite_frame],
            camera.x_world_to_screen(gameobjects[i].topleft_x),
            camera.y_world_to_screen(gameobjects[i].topleft_y),
            gameobjects[i].angle,
            gameobjects[i].size_modifier * camera.zoom,
            gameobjects[i].size_modifier * camera.zoom)
        
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

    -- greenish border at the edge of the screen
    -- love.graphics.setColor(0.2, 0.25, 0)
    -- love.graphics.rectangle("fill", camera.x_world_to_screen(map.width), 0, 50 * camera.zoom, camera.y_world_to_screen(map.height) )   
    -- love.graphics.rectangle("fill", 0, camera.y_world_to_screen(map.height), camera.x_world_to_screen(map.width) + (50 * camera.zoom),  50 * camera.zoom)
    -- love.graphics.setColor(1, 1, 1)
    
    -- if we're dragging a terrain piece, draw a red rectangle
    if i_grabbing ~= nil then
        love.graphics.setColor(0.4, 0.05, 0.05)
        love.graphics.rectangle(
            "line",
            love.mouse.getX() - ((gameobjects[i_grabbing].width * camera.zoom) / 2),
            love.mouse.getY() - ((gameobjects[i_grabbing].height * camera.zoom) / 2),
            gameobjects[i_grabbing].width * camera.zoom,
            gameobjects[i_grabbing].height  * camera.zoom)  
    end
    
    -- blue points to represent the player's waypoints
    -- this is temporary code for debugging only
    if gameobjects[i_player]["waypoints"] ~= nil then
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

    love.graphics.setColor(1, 1, 1)    

end
