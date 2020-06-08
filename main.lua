local gameobjects = {}

local pressingup = false
local pressingdown = false
local pressingright = false
local pressingleft = false

function love.load()
    local object = require('modules.object')

    images = {}
    images.tank = love.graphics.newImage("assets/images/tankframe.png")
    images.tankgun = love.graphics.newImage("assets/images/tanktop.png")
    
    gameobjects[1] = object:new()
    gameobjects[1].weapon_angle = gameobjects[1].angle
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

    if rotating == true and accelerating == true then
        rotating = false
    elseif rotating == false and accelerating == true then
        accelerating = false
    elseif rotating == false and accelerating == false then
        rotating = true
    elseif rotating == true and accelerating == false then
        accelerating = true
    end

    -- if accelerating == false then accelerating = true else accelerating = false end
    
end

function love.update(dt)

    local i = 1

    if pressingright then gameobjects[i]:rotate_right() end

    if pressingleft then gameobjects[i]:rotate_left() end

    if pressingup then gameobjects[i]:accelerate() end

    if pressingdown then gameobjects[i]:decelerate(0.04) end

    gameobjects[i].x = gameobjects[i].x + gameobjects[i].x_velocity
    gameobjects[i].y = gameobjects[i].y + gameobjects[i].y_velocity

    -- decelerate naturally
    gameobjects[i]:decelerate(0.003)

end

function love.draw()
    
    local i = 1

    -- love.graphics.draw(imageobject, x, y, rotation, somescaleparam, somescaleparam, originx, originy)
    love.graphics.draw(
        images.tank,
        gameobjects[i].x,
        gameobjects[i].y,
        gameobjects[i].angle,
        1,
        1,
        images.tank:getWidth() / 2,
        images.tank:getHeight() / 2)
    
    if gameobjects[i]['weapon_angle'] ~= nil then
        love.graphics.draw(
            images.tankgun,
            gameobjects[i].x,
            gameobjects[i].y,
            gameobjects[i].weapon_angle,
            1,
            1,
            (images.tankgun:getWidth() / 2),
            (images.tankgun:getHeight() / 2) + 30)
    end

    love.graphics.print("x velocity: " .. gameobjects[i].x_velocity, 700, 50)
    love.graphics.print("y velocity: " .. gameobjects[i].y_velocity, 700, 60)
    love.graphics.print("angle: " .. gameobjects[i].angle, 700, 70)
    
end
