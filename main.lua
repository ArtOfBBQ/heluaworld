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

local camera = {width = 1200, height = 1000, left = 0, top = 0, speed = 200}
local map = {width = 20000, height = 20000}


function love.load()

    love.window.setMode(camera.width, camera.height, {resizable=false, vsync=false, minwidth=400, minheight=300})
    love.window.setTitle('Macro & Conquer')

    local object = require('modules.object')
    local helper = require('modules.helper')
    local images = require('modules.imagefilenames')
    
    gameobjects[1] = object:newtank()
    assert(gameobjects[1].sprite_frame == 'tank')
    assert(gameobjects[1].sprite_top == 'tankgun')
    gameobjects[1].weapon_angle = gameobjects[1].angle + 0.4

    gameobjects[2] = object:newtree(70, 400)
    gameobjects[3] = object:newtree(80, 410)
    gameobjects[4] = object:newtree(95, 385)
    gameobjects[5] = object:newtree(50, 425)
    gameobjects[6] = object:newtree(115, 370)
    gameobjects[7] = object:newtree(135, 400)

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

        -- zoom in
        -- for i = 1, #gameobjects, 1 do
            -- gameobjects[i]:adjust_size(gameobjects[i].size_modifier + (0.1 * elapsed))
        -- end
    end

    if pressingo then
        -- zoom out
        for i = 1, #gameobjects, 1 do
            gameobjects[i]:adjust_size(gameobjects[i].size_modifier - (0.1 * elapsed))
        end
    end

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
            gameobjects[i].x - camera.left,
            gameobjects[i].y - camera.top,
            gameobjects[i].angle,
            gameobjects[i].size_modifier,
            gameobjects[i].size_modifier,
            images.tank:getWidth() / 2,
            images.tank:getHeight() / 2)
        
        if gameobjects[i]['weapon_angle'] ~= nil then
            love.graphics.draw(
                images[gameobjects[i].sprite_top],
                gameobjects[i].x - camera.left,
                gameobjects[i].y - camera.top,
                gameobjects[i].weapon_angle,
                gameobjects[i].size_modifier,
                gameobjects[i].size_modifier,
                (images.tankgun:getWidth() / 2),
                (images.tankgun:getHeight() / 2) + 30)
        end
        
        -- for debugging only, draw little circles to outline the object
        -- -- top left of object
        if debug_mode then
            local rotated_x = gameobjects[i].x + helper.rotate_x_coord(-gameobjects[i].width / 2, -gameobjects[i].height / 2, gameobjects[i].angle)
            local rotated_y = gameobjects[i].y + helper.rotate_y_coord(-gameobjects[i].width / 2, -gameobjects[i].height / 2, gameobjects[i].angle)
            love.graphics.circle(
                "fill",
                rotated_x - camera.left,
                rotated_y - camera.top,
                2)
            love.graphics.circle("fill", gameobjects[i].x - camera.left, gameobjects[i].y - camera.top, 2)
            -- top right of object
            rotated_x = gameobjects[i].x + helper.rotate_x_coord(gameobjects[i].width / 2, -gameobjects[i].height / 2, gameobjects[i].angle)
            rotated_y = gameobjects[i].y + helper.rotate_y_coord(gameobjects[i].width / 2, -gameobjects[i].height / 2, gameobjects[i].angle)
            love.graphics.circle(
                "fill",
                rotated_x - camera.left,
                rotated_y - camera.top,
                2)
            -- bottom right of object
            rotated_x = gameobjects[i].x + helper.rotate_x_coord(gameobjects[i].width / 2, gameobjects[i].height / 2, gameobjects[i].angle)
            rotated_y = gameobjects[i].y + helper.rotate_y_coord(gameobjects[i].width / 2, gameobjects[i].height / 2, gameobjects[i].angle)
            love.graphics.circle(
                "fill",
                rotated_x - camera.left,
                rotated_y - camera.top,
                2)
            -- bottom left of object
            rotated_x = gameobjects[i].x + helper.rotate_x_coord(-gameobjects[i].width / 2, gameobjects[i].height / 2, gameobjects[i].angle)
            rotated_y = gameobjects[i].y + helper.rotate_y_coord(-gameobjects[i].width / 2, gameobjects[i].height / 2, gameobjects[i].angle)
            love.graphics.circle(
                "fill",
                rotated_x - camera.left,
                rotated_y - camera.top,
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
