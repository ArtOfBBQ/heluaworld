collision = {}

function collision.rotate_x_coord(x, y, angle)
    return x * math.cos(angle) - (y * math.sin(angle))
end

function collision.rotate_y_coord(x, y, angle)
    return x * math.sin(angle) + (y * math.cos(angle))
end

function collision.rotate_x_around_point(x, y, angle, rtn_center_x, rtn_center_y)

    x = x - rtn_center_x
    y = y - rtn_center_y

    return (x * math.cos(angle)) - (y * math.sin(angle)) + rtn_center_x

end

function collision.rotate_y_around_point(x, y, angle, rtn_center_x, rtn_center_y)

    local sinus = math.sin(angle)
    local cosinus = math.cos(angle)

    x = x - rtn_center_x
    y = y - rtn_center_y

    return (x * sinus) + (y * cosinus) + rtn_center_y

end

function collision.point_collides_rotated_rectangle(x, y, rect_x, rect_y,
    rect_width, rect_height, rect_angle)

    if x == nil then error("Expected x-coordinate to check, got nil.") end
    if y == nil then error("Expected y-coordinate to check, got nil.") end
    if rect_x == nil then
        error("Expected x (middle) of rectangle to check, got nil.")
    end
    if rect_y == nil then
        error("Expected y (middle) of rectangle to check, got nil.")
    end
    if rect_width == nil then
        error("Expected width of rectangle to check, got nil.")
    end
    if rect_height == nil then
        error("Expected height of rectangle to check, got nil.")
    end
    if rect_angle == nil then
        error("Expected angle of rectangle to check, got nil.")
    end

    return collision.point_collides_unrotated_rectangle(
        rect_x + collision.rotate_x_coord(x - rect_x, y - rect_y, -rect_angle),
        rect_y + collision.rotate_y_coord(x - rect_x, y - rect_y, -rect_angle),
        rect_x - (rect_width / 2), rect_y - (rect_height / 2), rect_width,
        rect_height)

end

function collision.point_collides_unrotated_rectangle(x, y, rect_left, rect_top,
    rect_width, rect_height)

    if x == nil then error("Expected x-coordinate to check, got nil.") end
    if y == nil then error("Expected y-coordinate to check, got nil.") end
    if rect_left == nil then
        error("Expected left of rectangle to check, got nil.")
    end
    if rect_top == nil then
        error("Expected top of rectangle to check, got nil.")
    end
    if rect_width == nil then
        error("Expected width of rectangle to check, got nil.")
    end
    if rect_height == nil then
        error("Expected height of rectangle to check, got nil.")
    end

    if x < rect_left then return false end

    if x > (rect_left + rect_width) then return false end

    if y < rect_top then return false end

    if y > (rect_top + rect_height) then return false end

    return true

end

function collision.point_collides_unrotated_object(x, y, object)

    -- all of our objects are rotated rectangles
    -- so this function won't work out of the box
    -- unless the object happens to be at an angle of 0
    -- you need to fix rotation issues outside of it

    return collision.point_collides_unrotated_rectangle(x, y, object.x -
        (object.width / 2), object.y - (object.height / 2), object.width,
        object.height)

end

function collision.point_collides_rotated_object(x, y, gameobject)

    return collision.point_collides_unrotated_object(
        gameobject.x +
            collision.rotate_x_coord(gameobject.x - x, gameobject.y - y,
                gameobject.angle), gameobject.y +
            collision.rotate_y_coord(gameobject.x - x, gameobject.y - y,
                gameobject.angle), gameobject)

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

    assert(i ~= nil, "nil i was passed to collision detector")
    assert(gameobjects[i] ~= nil)

    if collision.point_collides_unrotated_object(gameobjects[i].bottomleft_x,
        gameobjects[i].bottomleft_y, gameobjects[j]) then return true end

    if collision.point_collides_unrotated_object(gameobjects[i].topleft_x,
        gameobjects[i].topleft_y, gameobjects[j]) then return true end

    if collision.point_collides_unrotated_object(gameobjects[i].topright_x,
        gameobjects[i].topright_y, gameobjects[j]) then return true end

    if collision.point_collides_unrotated_object(gameobjects[i].bottomright_x,
        gameobjects[i].bottomright_y, gameobjects[j]) then return true end

end

-- are any of the corners of object i inside rotated object j?
-- this function also works if object j isn't rotated, but it's very expensive
--
-- note that it's still possible to be in collision even if all 4 corners
-- are not - the corner of object j could be inside of object i and this
-- function would still return false
function collision.are_rotated_object_corners_colliding(i, j)

    if collision.point_collides_rotated_object(gameobjects[i].bottomleft_x,
        gameobjects[i].bottomleft_y, gameobjects[j]) then return true end

    if collision.point_collides_rotated_object(gameobjects[i].topleft_x,
        gameobjects[i].topleft_y, gameobjects[j]) then return true end

    if collision.point_collides_rotated_object(gameobjects[i].topright_x,
        gameobjects[i].topright_y, gameobjects[j]) then return true end

    if collision.point_collides_rotated_object(gameobjects[i].bottomright_x,
        gameobjects[i].bottomright_y, gameobjects[j]) then return true end

    return false

end

-- Please call this function whenever a collision has been detected between
-- gameobjects of index i and j
-- this function should change the velocities of the objects
function collision.register_collision(i, j)

    gameobjects[i].colliding = true
    gameobjects[j].colliding = true

    local i_weight_proportion = 1 -
                                    (gameobjects[i].weight /
                                        (gameobjects[i].weight +
                                            gameobjects[j].weight))
    local j_weight_proportion = 1 - i_weight_proportion

    local total_x_velocity = 0.05 + gameobjects[i].x_velocity +
                                 gameobjects[j].x_velocity
    local total_y_velocity = 0.05 + gameobjects[i].y_velocity +
                                 gameobjects[j].y_velocity

    gameobjects[i].x_velocity = total_x_velocity * i_weight_proportion
    gameobjects[j].x_velocity = total_x_velocity * j_weight_proportion

    gameobjects[i].y_velocity = total_y_velocity * i_weight_proportion
    gameobjects[j].y_velocity = total_y_velocity * j_weight_proportion

end

return collision
