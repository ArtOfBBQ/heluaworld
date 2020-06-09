local gameobjects = {}
local elapsed
local previous_time

local pressingup = false
local pressingdown = false
local pressingright = false
local pressingleft = false

local screen_width = 1200
local screen_height = 1000
local previous_time = os.clock()

function love.load()

    love.window.setMode(screen_width, screen_height, {resizable=false, vsync=false, minwidth=400, minheight=300})
    love.window.setTitle('Macro & Conquer')

    local object = require('modules.object')
    local helper = require('modules.helper')

    images = {}
    images.tank = love.graphics.newImage("assets/images/tankframe.png")
    images.tankgun = love.graphics.newImage("assets/images/tanktop.png")
    
    gameobjects[1] = object:new()
    gameobjects[1].weapon_angle = gameobjects[1].angle

    gameobjects[2] = object:new()
    gameobjects[2].x = 70
    gameobjects[2].y = 400
    gameobjects[2].angle = 0
    gameobjects[2].weapon_angle = gameobjects[2].angle

    previous_time = os.clock()

end

function love.keypressed( key, scancode, isrepeat )

    if key == 'up' then pressingup = true end
    if key == 'down' then pressingdown = true end
    if key == 'right' then pressingright = true end
    if key == 'left' then pressingleft = true end

end

function love.keyreleased( key, scancode, isrepeat )

    if key == 'up' then pressingup = false end
    if key == 'down' then pressingdown = false end
    if key == 'right' then pressingright = false end
    if key == 'left' then pressingleft = false end

end


function love.mousepressed(x, y, button, istouch)


    
end

function love.update(dt)

    elapsed = os.clock() - previous_time
    previous_time = os.clock()

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
        love.graphics.draw(
            images[gameobjects[i].sprite_frame],
            gameobjects[i].x,
            gameobjects[i].y,
            gameobjects[i].angle,
            gameobjects[i].size_modifier,
            gameobjects[i].size_modifier,
            images.tank:getWidth() / 2,
            images.tank:getHeight() / 2)
        
        if gameobjects[i]['weapon_angle'] ~= nil then
            love.graphics.draw(
                images[gameobjects[i].sprite_top],
                gameobjects[i].x,
                gameobjects[i].y,
                gameobjects[i].weapon_angle,
                gameobjects[i].size_modifier,
                gameobjects[i].size_modifier,
                (images.tankgun:getWidth() / 2),
                (images.tankgun:getHeight() / 2) + 30)
        end
        
        -- for debugging only, draw little circles to outline the object
        -- top left of object
        local rotated_x = gameobjects[i].x + helper.rotate_x_coord(-gameobjects[i].width / 2, -gameobjects[i].height / 2, gameobjects[i].angle)
        local rotated_y = gameobjects[i].y + helper.rotate_y_coord(-gameobjects[i].width / 2, -gameobjects[i].height / 2, gameobjects[i].angle)
        love.graphics.circle(
            "fill",
            rotated_x,
            rotated_y,
            2)
        love.graphics.circle("fill", gameobjects[i].x, gameobjects[i].y, 2)
        -- top right of object
        rotated_x = gameobjects[i].x + helper.rotate_x_coord(gameobjects[i].width / 2, -gameobjects[i].height / 2, gameobjects[i].angle)
        rotated_y = gameobjects[i].y + helper.rotate_y_coord(gameobjects[i].width / 2, -gameobjects[i].height / 2, gameobjects[i].angle)
        love.graphics.circle(
            "fill",
            rotated_x,
            rotated_y,
            2)
        -- bottom right of object
        rotated_x = gameobjects[i].x + helper.rotate_x_coord(gameobjects[i].width / 2, gameobjects[i].height / 2, gameobjects[i].angle)
        rotated_y = gameobjects[i].y + helper.rotate_y_coord(gameobjects[i].width / 2, gameobjects[i].height / 2, gameobjects[i].angle)
        love.graphics.circle(
            "fill",
            rotated_x,
            rotated_y,
            2)
        -- bottom left of object
        rotated_x = gameobjects[i].x + helper.rotate_x_coord(-gameobjects[i].width / 2, gameobjects[i].height / 2, gameobjects[i].angle)
        rotated_y = gameobjects[i].y + helper.rotate_y_coord(-gameobjects[i].width / 2, gameobjects[i].height / 2, gameobjects[i].angle)
        love.graphics.circle(
            "fill",
            rotated_x,
            rotated_y,
            2)
        
        
        love.graphics.print("x velocity: " .. math.floor(gameobjects[1].x_velocity * 100)/100, screen_width - 150, 50)
        love.graphics.print("y velocity: " .. math.floor(gameobjects[1].y_velocity * 100)/100, screen_width - 150, 70)
        love.graphics.print("angle: " .. math.floor(gameobjects[1].angle + 10) / 10, screen_width - 150, 90)
        love.window.setTitle(gameobjects[1].angle)
        love.graphics.print("x (center): " .. math.floor(gameobjects[1].x), screen_width - 150, 110)
        love.graphics.print("x (edge 1): " .. math.floor(rotated_x), screen_width - 150, 130)
        love.graphics.print("y (center): " .. math.floor(gameobjects[1].y), screen_width - 150, 150)
        love.graphics.print("y (edge 1): " .. math.floor(rotated_y), screen_width - 150, 170)
        love.graphics.print("elapsed: " .. elapsed, screen_width - 150, 190)
        -- end of debugging code

    end
    
end
