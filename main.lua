local gameobjects = {}
local elapsed
local previous_time = os.clock()
local debug_mode = false

local map = {width = 20000, height = 20000}


function love.load()


    local object = require('modules.object')
    local collision = require('modules.collision')
    local images = require('modules.imagefilenames')
    local camera = require('modules.camera')
    local keyboard = require('modules.keyboard')

    love.window.setMode(camera.width, camera.height, {resizable=false, vsync=false, minwidth=400, minheight=300})
    love.window.setTitle('Macro & Conquer')
    
    gameobjects[1] = object:newtank()
    assert(gameobjects[1].sprite_frame == 'tank')
    assert(gameobjects[1].sprite_top == 'tankgun')
    gameobjects[1].weapon_angle = gameobjects[1].angle + 0.4

    gameobjects[2] = object:newtank(300, 100)
    gameobjects[2].angle = 0.15

    gameobjects[3] = object.newtree(50, 660)
    gameobjects[4] = object.newtree(65, 600)
    gameobjects[5] = object.newtree(45, 580)
    gameobjects[6] = object.newtree(70, 670)
    
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

    if debug_mode == true then debug_mode = false else debug_mode = true end
    
end

function love.update(dt)

    elapsed = os.clock() - previous_time
    previous_time = os.clock()

    if keyboard.pressingp then
        camera.zoom = camera.zoom + (camera.zoomspeed * elapsed)
    end
    if keyboard.pressingo then
        camera.zoom = camera.zoom - (camera.zoomspeed * elapsed)
    end
    camera.cur_width = camera.width * camera.zoom
    camera.cur_height = camera.height * camera.zoom

    if keyboard.pressingd then camera.left = camera.left + (camera.speed * elapsed) end
    if keyboard.pressinga then camera.left = camera.left - (camera.speed * elapsed) end
    if keyboard.pressingw then camera.top = camera.top - (camera.speed * elapsed) end
    if keyboard.pressings then camera.top = camera.top + (camera.speed * elapsed) end

    if keyboard.pressingright
        and math.abs(gameobjects[1].x_velocity) < gameobjects[1].max_speed_while_rotating 
        and math.abs(gameobjects[1].y_velocity) < gameobjects[1].max_speed_while_rotating
        and gameobjects[1].colliding == false
    then 
        gameobjects[1]:rotate_right(elapsed) 
    end

    if keyboard.pressingleft
        and math.abs(gameobjects[1].x_velocity) < gameobjects[1].max_speed_while_rotating 
        and math.abs(gameobjects[1].y_velocity) < gameobjects[1].max_speed_while_rotating
        and gameobjects[1].colliding == false
    then 
        gameobjects[1]:rotate_left(elapsed)
    end

    if keyboard.pressingup then gameobjects[1]:accelerate(elapsed) end

    if keyboard.pressingdown then gameobjects[1]:reverse(elapsed) end
    
    if keyboard['pressing_'] then gameobjects[1]:rotate_weapon_right(elapsed) end
    if keyboard['pressing/'] then gameobjects[1]:rotate_weapon_left(elapsed) end
    
    if gameobjects[1].colliding == false then
        gameobjects[1].x = gameobjects[1].x + gameobjects[1].x_velocity
        gameobjects[1].y = gameobjects[1].y + gameobjects[1].y_velocity
    end

    -- decelerate naturally and update all object coordinates
    for i = 1, #gameobjects, 1 do
        gameobjects[i]:decelerate(elapsed)

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
                camera.x_world_to_screen(gameobjects[i].x),
                camera.y_world_to_screen(gameobjects[i].y),
                gameobjects[i].weapon_angle,
                gameobjects[i].size_modifier * camera.zoom,
                gameobjects[i].size_modifier * camera.zoom,
                images[gameobjects[i].sprite_top]:getWidth() / 2,
                (images[gameobjects[i].sprite_top]:getHeight() / 2) + 30)
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
    love.graphics.print("x velocity: " .. math.floor(gameobjects[1].x_velocity * 100)/100, camera.width - 135, 50)
        love.graphics.print("y velocity: " .. math.floor(gameobjects[1].y_velocity * 100)/100, camera.width - 135, 70)
        love.graphics.print("angle: " .. math.floor(gameobjects[1].angle * 100) / 100, camera.width - 135, 90)
        love.window.setTitle(gameobjects[1].angle)
        love.graphics.print("x (center): " .. math.floor(gameobjects[1].x), camera.width - 135, 110)
        love.graphics.print("y (center): " .. math.floor(gameobjects[1].y), camera.width - 135, 130)
        love.graphics.print("elapsed: " .. math.floor(elapsed * 1000) / 1000, camera.width - 135, 150)
        love.graphics.print("size modifier: " .. gameobjects[1].size_modifier, camera.width - 135, 170)
        love.graphics.print("width: " .. gameobjects[1].width, camera.width - 135, 190)
        love.graphics.print("height: " .. gameobjects[1].width, camera.width - 135, 210)
        love.graphics.print("camera left: " .. camera.left, camera.width - 135, 230)
        love.graphics.print("camera top: " .. camera.top, camera.width - 135, 250)
        love.graphics.print("last key: " .. keyboard.lastkeypressed, camera.width - 135, 270)
        love.graphics.print("player colliding: " .. tostring(gameobjects[1].colliding), camera.width - 135, 290)
    
end
