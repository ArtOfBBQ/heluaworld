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
    
    local sinus   = math.sin(angle)
    local cosinus = math.cos(angle)

    x = x - rtn_center_x
    y = y - rtn_center_y

    return (x * sinus) + (y * cosinus) + rtn_center_y

end

function collision.point_collides_unrotated_rectangle(x, y, rect_left, rect_top, rect_width, rect_height)

    if x < rect_left then
        return false
    end

    if x > (rect_left + rect_width) then
        return false
    end

    if y < rect_top then
        return false
    end

    if y > (rect_top + rect_height) then
        return false
    end

    return true

end

function collision.point_collides_unrotated_object(x, y, object)

    -- all of our objects are rotated rectangles
    -- so this function won't work out of the box
    -- unless the object happens to be at an angle of 0
    -- you need to fix rotation issues outside of it

    return collision.point_collides_unrotated_rectangle(
        x,
        y,
        object.x - (object.width / 2),
        object.y - (object.height / 2),
        object.width,
        object.height)

end

function collision.point_collides_rotated_object(x, y, gameobject)

    return collision.point_collides_unrotated_object(
        gameobject.x + collision.rotate_x_coord(
            gameobject.x - x,
            gameobject.y - y,
            gameobject.angle),
        gameobject.y + collision.rotate_y_coord(
            gameobject.x - x,
            gameobject.y - y,
            gameobject.angle),
        gameobject)

end

-- are any of the corners of object i inside unrotated object j?
-- object j must be an 'unrotated' rectangle
-- so the edges of the rectangle must be parallel with the screen
-- edges. This is true when the gameobject[j].angle is 0 (facing up) or 3.14 (facing down), 
--
-- note that it's still possible to be in collision even if all 4 corners
-- are not - the corner of object j could be inside of object i and this
-- function would still return false
function collision.are_unrotated_object_corners_colliding(i, j)

    if collision.point_collides_unrotated_object(
        gameobjects[i].bottomleft_x,
        gameobjects[i].bottomleft_y,
        gameobjects[j])
    then
        return true
    end

    if collision.point_collides_unrotated_object(
        gameobjects[i].topleft_x,
        gameobjects[i].topleft_y,
        gameobjects[j])
    then
        return true
    end

    if collision.point_collides_unrotated_object(
        gameobjects[i].topright_x,
        gameobjects[i].topright_y,
        gameobjects[j])
    then
        return true
    end

    if collision.point_collides_unrotated_object(
        gameobjects[i].bottomright_x,
        gameobjects[i].bottomright_y,
        gameobjects[j])
    then
        return true
    end

end


-- are any of the corners of object i inside rotated object j?
-- this function also works if object j isn't rotated, but it's very expensive
--
-- note that it's still possible to be in collision even if all 4 corners
-- are not - the corner of object j could be inside of object i and this
-- function would still return false
function collision.are_rotated_object_corners_colliding(i, j)

    if collision.point_collides_rotated_object(
        gameobjects[i].bottomleft_x,
        gameobjects[i].bottomleft_y,
        gameobjects[j])
    then
        return true
    end
    
    if collision.point_collides_rotated_object(
        gameobjects[i].topleft_x,
        gameobjects[i].topleft_y,
        gameobjects[j])
    then
        return true
    end
    
    if collision.point_collides_rotated_object(
        gameobjects[i].topright_x,
        gameobjects[i].topright_y,
        gameobjects[j])
    then
        return true
    end
    
    if collision.point_collides_rotated_object(
        gameobjects[i].bottomright_x,
        gameobjects[i].bottomright_y,
        gameobjects[j])
    then
        return true
    end
    
    return false

end


function collision.update_all_collisions()

    for i = 1, #gameobjects, 1 do

        for j = 1, #gameobjects, 1 do

            if i == j then 
                -- an object can't collide with itself
                -- do nothing
            else
                
                if gameobjects[j].angle == 0 or gameobjects[j].angle == 3.14 then

                    -- object j is not rotated at an angle
                    -- it's cheap to check if any of i's corners are inside j
                    if
                        collision.are_unrotated_object_corners_colliding(i, j)
                    then
                        collision.register_collision(i, j)
                    end
                else

                    -- object j is rotated at an angle
                    -- we need to do a more computationally expensive process
                    -- to find if any of i's corners are inside j
                    if
                        collision.are_rotated_object_corners_colliding(i, j)
                    then
                        collision.register_collision(i, j)
                    end
                end

            end
        end

    end

end

-- Please call this function whenever a collision has been detected between
-- gameobjects of index i and j
function collision.register_collision(i, j)

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


return collision
