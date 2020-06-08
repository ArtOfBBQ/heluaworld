local gameobjects = {}

function love.load()
    local object = require('modules.object')

    images = {}
    images.tank = love.graphics.newImage("assets/images/tankframe.png")
    images.tankgun = love.graphics.newImage("assets/images/tanktop.png")
    
    gameobjects[1] = object:new()
    gameobjects[1].weapon_angle = 0.40
end

function love.mousepressed(x, y, button, istouch)
end

function love.update(dt)

    local i = 1
    
    gameobjects[i]:rotate_right(0.02)

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
            (images.tankgun:getWidth() / 2) - 30,
            images.tankgun:getHeight() / 2)
    end
    
end
