function love.load()
    number = 0
    score = 0
    images = {}
    movingRight = true

    myfont = love.graphics.newFont(40)

    images.tank = love.graphics.newImage("assets/images/tankframe.png")
end

function love.mousepressed(x, y, button, istouch)
   if movingRight then
       movingRight = false
   else
       movingRight = true
   end
end

function love.update(dt)
    if movingRight then
        number = number + (dt * 30)
    else
        number = number - (dt * 30)
    end
end

function love.draw()
    
    love.graphics.draw(images.tank, 50, 50)
    
    -- love.graphics.setColor(0.5, 0.5, 1)
    love.graphics.rectangle("fill", number, 20, 20, 20)
    --  love.graphics.setColor(0.5, 1, 0.5)
    love.graphics.circle("fill", 4, 4, 100)

    love.graphics.setFont(myfont)
    love.graphics.print(score, 700, 4)
end
