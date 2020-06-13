collision = {}

function collision.rotate_x_coord(x, y, angle)
    return x * math.cos(angle) - (y * math.sin(angle))
end

function collision.rotate_y_coord(x, y, angle)
    return x * math.sin(angle) + (y * math.cos(angle))
end

function collision.rotate_x_around_point(x, y, angle, rtn_center_x, rtn_center_y)

    assert(x ~= nil)
    assert(y ~= nil)
    assert(rtn_center_x ~= nil)
    assert(rtn_center_y ~= nil)

    x = x - rtn_center_x
    y = y - rtn_center_y

    return (x * math.cos(angle)) - (y * math.sin(angle)) + rtn_center_x
end


function collision.rotate_y_around_point(x, y, angle, rtn_center_x, rtn_center_y)
   
    sinus   = math.sin(angle)
    cosinus = math.cos(angle)

    x = x - rtn_center_x
    y = y - rtn_center_y

    return (x * sinus) + (y * cosinus) + rtn_center_y
end


function collision.point_collides_object_noangle(x, y, object)

    -- all of our objects are rotated rectangles
    -- so this function won't work out of the box
    -- unless the object happens to be at an angle of 0
    -- you need to fix rotation issues outside of it

    if x < (object.x - (object.width / 2)) then
        return false
    end

    if x > (object.x + (object.width / 2)) then
        return false
    end

    if y < (object.y - (object.height / 2)) then
        return false
    end

    if y > (object.y + (object.height / 2)) then
        return false
    end

    return true
end

function collision.update_all_collisions(gameobjects)

    for i = 1, #gameobjects, 1 do

        for j = 1, #gameobjects, 1 do

            if i == j then 
                -- continue 
            else

                if collision.point_collides_object_noangle(
                        gameobjects[j].x + collision.rotate_x_coord(
                            gameobjects[j].x - gameobjects[i].bottomleft_x,
                            gameobjects[j].y - gameobjects[i].bottomleft_y,
                            gameobjects[j].angle),
                        gameobjects[j].y + collision.rotate_y_coord(
                            gameobjects[j].x - gameobjects[i].bottomleft_x,
                            gameobjects[j].y - gameobjects[i].bottomleft_y,
                            gameobjects[j].angle),
                        gameobjects[j])
                    or collision.point_collides_object_noangle(
                        gameobjects[j].x + collision.rotate_x_coord(
                            gameobjects[j].x - gameobjects[i].topleft_x,
                            gameobjects[j].y - gameobjects[i].topleft_y,
                            gameobjects[j].angle),
                        gameobjects[j].y + collision.rotate_y_coord(
                            gameobjects[j].x - gameobjects[i].topleft_x,
                            gameobjects[j].y - gameobjects[i].topleft_y,
                            gameobjects[j].angle),
                        gameobjects[j])
                    or collision.point_collides_object_noangle(
                        gameobjects[j].x + collision.rotate_x_coord(
                            gameobjects[j].x - gameobjects[i].topright_x,
                            gameobjects[j].y - gameobjects[i].topright_y,
                            gameobjects[j].angle),
                        gameobjects[j].y + collision.rotate_y_coord(
                            gameobjects[j].x - gameobjects[i].topright_x,
                            gameobjects[j].y - gameobjects[i].topright_y,
                            gameobjects[j].angle),
                        gameobjects[j])
                    or collision.point_collides_object_noangle(
                        gameobjects[j].x + collision.rotate_x_coord(
                            gameobjects[j].x - gameobjects[i].bottomright_x,
                            gameobjects[j].y - gameobjects[i].bottomright_y,
                            gameobjects[j].angle),
                        gameobjects[j].y + collision.rotate_y_coord(
                            gameobjects[j].x - gameobjects[i].bottomright_x,
                            gameobjects[j].y - gameobjects[i].bottomright_y,
                            gameobjects[j].angle),
                        gameobjects[j])
                then
                    gameobjects[i].colliding = true
                    gameobjects[j].colliding = true

                    if math.abs((gameobjects[j].x_velocity + 1) * gameobjects[j].weight) > math.abs((gameobjects[i].x_velocity + 1) * gameobjects[i].weight) then
                        gameobjects[i].x = gameobjects[i].x +  ((gameobjects[i].x - gameobjects[j].x) * 0.005 * (2 + gameobjects[i].x_velocity))
                        gameobjects[i].x_velocity = 0
                    else
                        gameobjects[j].x = gameobjects[j].x + ((gameobjects[j].x - gameobjects[i].x) * 0.005 * (2 + gameobjects[j].x_velocity))
                        gameobjects[j].x_velocity = 0
                    end

                    if math.abs((gameobjects[j].y_velocity + 1) * gameobjects[j].weight) > math.abs((gameobjects[i].y_velocity + 1) * gameobjects[i].weight) then
                        gameobjects[i].y = gameobjects[i].y + ((gameobjects[i].y - gameobjects[j].y) * 0.005 * (2 + gameobjects[i].y_velocity))
                        gameobjects[i].x_velocity = 0
                    else
                        gameobjects[j].y = gameobjects[j].y + ((gameobjects[j].y - gameobjects[i].y) * 0.005 * (2 + gameobjects[j].y_velocity))
                        gameobjects[j].y_velocity = 0
                    end
                end

            end
        end

    end

end

return collision
