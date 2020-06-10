local gameobjects = {}
local elapsed
local previous_time

local pressingup = false
local pressingdown = false
local pressingright = false
local pressingleft = false
local pressingp = false
local pressingo = false
local pressingw = false
local pressings = false
local pressinga = false
local pressingd = false

local previous_time = os.clock()
local debug_mode = false

local map = {width = 20000, height = 20000}


function love.load()


    local object = require('modules.object')
    local helper = require('modules.helper')
    local images = require('modules.imagefilenames')
    local camera = require('modules.camera')

    love.window.setMode(camera.width, camera.height, {resizable=false, vsync=false, minwidth=400, minheight=300})
    love.window.setTitle('Macro & Conquer')
    
    gameobjects[1] = object:newtank()
    assert(gameobjects[1].sprite_frame == 'tank')
    assert(gameobjects[1].sprite_top == 'tankgun')
    gameobjects[1].weapon_angle = gameobjects[1].angle + 0.4

    gameobjects[2] = object:newtree(70, 400)
    gameobjects[3] = object:newtree(80, 440)
    gameobjects[4] = object:newtree(95, 285)
    gameobjects[5] = object:newtree(50, 525)
    gameobjects[6] = object:newtree(115, 320)
    gameobjects[7] = object:newtree(335, 700)

    previous_time = os.clock()

end

function love.keypressed( key, scancode, isrepeat )

    if key == 'up' then pressingup = true end
    if key == 'down' then pressingdown = true end
    if key == 'right' then pressingright = true end
    if key == 'left' then pressingleft = true end
    if key == 'p' then pressingp = true end
    if key == 'o' then pressingo = true end
    if key == 'w' then pressingw = true end
    if key == 'd' then pressingd = true end
    if key == 'a' then pressinga = true end
    if key == 's' then pressings = true end

end

function love.keyreleased( key, scancode, isrepeat )

    if key == 'up' then pressingup = false end
    if key == 'down' then pressingdown = false end
    if key == 'right' then pressingright = false end
    if key == 'left' then pressingleft = false end
    if key == 'p' then pressingp = false end
    if key == 'o' then pressingo = false end
    if key == 'w' then pressingw = false end
    if key == 'd' then pressingd = false end
    if key == 'a' then pressinga = false end
    if key == 's' then pressings = false end

end


function love.mousepressed(x, y, button, istouch)

    if debug_mode == true then debug_mode = false else debug_mode = true end
    
end

function love.update(dt)

    elapsed = os.clock() - previous_time
    previous_time = os.clock()

    if pressingp then
        camera.zoom = camera.zoom + (1 * elapsed)
    end
    if pressingo then
        camera.zoom = camera.zoom - (1 * elapsed)
    end
    camera.cur_width = camera.width * camera.zoom
    camera.cur_height = camera.height * camera.zoom

    if pressingd then camera.left = camera.left + (camera.speed * elapsed) end
    if pressinga then camera.left = camera.left - (camera.speed * elapsed) end
    if pressingw then camera.top = camera.top - (camera.speed * elapsed) end
    if pressings then camera.top = camera.top + (camera.speed * elapsed) end

    if pressingright
        and math.abs(gameobjects[1].x_velocity) < gameobjects[1].max_speed_while_rotating 
        and math.abs(gameobjects[1].y_velocity) < gameobjects[1].max_speed_while_rotating
    then gameobjects[1]:rotate_right(elapsed) end

    if pressingleft
        and math.abs(gameobjects[1].x_velocity) < gameobjects[1].max_speed_while_rotating 
        and math.abs(gameobjects[1].y_velocity) < gameobjects[1].max_speed_while_rotating
    then gameobjects[1]:rotate_left(elapsed) end

    if pressingup then gameobjects[1]:accelerate(elapsed) end

    if pressingdown then gameobjects[1]:reverse(elapsed) end
    
    gameobjects[1].x = gameobjects[1].x + gameobjects[1].x_velocity
    gameobjects[1].y = gameobjects[1].y + gameobjects[1].y_velocity

    -- decelerate naturally
    for i = 1, #gameobjects, 1 do
        gameobjects[i]:decelerate(elapsed)
    end

end

function love.draw()
    
    for i = 1, #gameobjects, 1 do

        -- love.graphics.draw(imageobject, x, y, rotation, somescaleparam, somescaleparam, originx, originy)
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
            -- top left of object
            local rotated_x = camera.x_world_to_screen(
                gameobjects[i].x + helper.rotate_x_coord(
                    (-gameobjects[i].width / 2),
                    (-gameobjects[i].height / 2),
                    gameobjects[i].angle))
            local rotated_y = camera.y_world_to_screen(
                gameobjects[i].y + helper.rotate_y_coord(
                    (-gameobjects[i].width / 2),
                    (-gameobjects[i].height / 2),
                    gameobjects[i].angle))
            love.graphics.circle(
                "fill",
                rotated_x,
                rotated_y,
                2)
            -- center of object
            love.graphics.circle(
                "fill",
                camera.x_world_to_screen(gameobjects[i].x),
                camera.y_world_to_screen(gameobjects[i].y),
                2)
            -- top right of object
            rotated_x = camera.x_world_to_screen(
                gameobjects[i].x + helper.rotate_x_coord(
                    (gameobjects[i].width / 2),
                    (-gameobjects[i].height / 2),
                    gameobjects[i].angle))
            rotated_y = camera.y_world_to_screen(
                gameobjects[i].y + helper.rotate_y_coord(
                    (gameobjects[i].width / 2),
                    (-gameobjects[i].height / 2),
                    gameobjects[i].angle))
            love.graphics.circle(
                "fill",
                rotated_x,
                rotated_y,
                2)
            -- bottom right of object
            rotated_x = camera.x_world_to_screen(
                gameobjects[i].x + helper.rotate_x_coord(
                    (gameobjects[i].width / 2),
                    (gameobjects[i].height / 2),
                    gameobjects[i].angle))
            rotated_y = camera.y_world_to_screen(
                gameobjects[i].y + helper.rotate_y_coord(
                    (gameobjects[i].width / 2),
                    (gameobjects[i].height / 2),
                    gameobjects[i].angle))
            love.graphics.circle(
                "fill",
                rotated_x,
                rotated_y,
                2)
            -- bottom left of object
            rotated_x = camera.x_world_to_screen(
                gameobjects[i].x + helper.rotate_x_coord(
                    (-gameobjects[i].width / 2),
                    (gameobjects[i].height / 2),
                    gameobjects[i].angle))
            rotated_y = camera.y_world_to_screen(
                gameobjects[i].y + helper.rotate_y_coord(
                    (-gameobjects[i].width / 2),
                    (gameobjects[i].height / 2),
                    gameobjects[i].angle))
            love.graphics.circle(
                "fill",
                rotated_x,
                rotated_y,
                2)
        end
        
        love.graphics.print("x velocity: " .. math.floor(gameobjects[1].x_velocity * 100)/100, camera.width - 150, 50)
        love.graphics.print("y velocity: " .. math.floor(gameobjects[1].y_velocity * 100)/100, camera.width - 150, 70)
        love.graphics.print("angle: " .. math.floor(gameobjects[1].angle * 100) / 100, camera.width - 150, 90)
        love.window.setTitle(gameobjects[1].angle)
        love.graphics.print("x (center): " .. math.floor(gameobjects[1].x), camera.width - 150, 110)
        love.graphics.print("y (center): " .. math.floor(gameobjects[1].y), camera.width - 150, 130)
        love.graphics.print("elapsed: " .. math.floor(elapsed * 1000) / 1000, camera.width - 150, 150)
        love.graphics.print("size modifier: " .. gameobjects[1].size_modifier, camera.width - 150, 170)
        love.graphics.print("width: " .. gameobjects[1].width, camera.width - 150, 190)
        love.graphics.print("height: " .. gameobjects[1].width, camera.width - 150, 210)
        love.graphics.print("camera left: " .. camera.left, camera.width - 150, 230)
        love.graphics.print("camera top: " .. camera.top, camera.width - 150, 250)

        -- end of debugging code

    end
    
end
