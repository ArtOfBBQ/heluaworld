collision = {}

function collision.rotate_x_coord(x, y, angle)
    return x * math.cos(angle) - (y * math.sin(angle))
end

function collision.rotate_y_coord(x, y, angle)
    return x * math.sin(angle) + (y * math.cos(angle))
end

function collision.point_collides_rotated_rectangle(x,
    y,
    rect_x,
    rect_y,
    rect_width,
    rect_height,
    rect_angle)

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

function collision.point_collides_unrotated_rectangle(x,
    y,
    rect_left,
    rect_top,
    rect_width,
    rect_height)

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

    return collision.point_collides_unrotated_rectangle(x, y, object.x -
        (object.width / 2), object.y - (object.height / 2), object.width,
        object.height)

end

function collision.point_collides_rotated_object(x, y, gameobject)

    return collision.point_collides_rotated_rectangle(x, y, gameobject.x,
        gameobject.y, gameobject.width, gameobject.height, gameobject.angle)

end

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

    local i_weight_proportion = 1 -
                                    (gameobjects[i].weight /
                                        (gameobjects[i].weight +
                                            gameobjects[j].weight))
    local j_weight_proportion = 1 - i_weight_proportion

    local total_x_velocity = gameobjects[i].x_velocity + gameobjects[j].x_velocity

    local total_y_velocity = gameobjects[i].y_velocity + gameobjects[j].y_velocity

    gameobjects[i].x_velocity = total_x_velocity * i_weight_proportion * 0.9
    gameobjects[j].x_velocity = total_x_velocity * j_weight_proportion * 0.9

    gameobjects[i].y_velocity = total_y_velocity * i_weight_proportion * 0.9
    gameobjects[j].y_velocity = total_y_velocity * j_weight_proportion * 0.9

end

return collision
