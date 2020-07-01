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

-- Called whenever a collision has been detected between
-- gameobjects of index i and j
function collision.register_collision(i, j)

    gameobjects[i].x_velocity = gameobjects[i].x_velocity * -0.35
    gameobjects[i].y_velocity = gameobjects[i].y_velocity * -0.35
    gameobjects[j].x_velocity = gameobjects[i].x_velocity * -0.35
    gameobjects[j].y_velocity = gameobjects[i].y_velocity * -0.35

    if math.abs(gameobjects[i].rotation_velocity) > 0 then gameobjects[i].rotation_velocity = gameobjects[i].rotation_velocity * -0.75 end
    if math.abs(gameobjects[j].rotation_velocity) > 0 then gameobjects[j].rotation_velocity = gameobjects[j].rotation_velocity * -0.75 end    
end

function collision.stats_to_corner_coordinates(obj_x, obj_y, obj_width, obj_height, obj_angle)

    if obj_x == nil then error("Expected x of rectangle to convert, got nil.") end
    if obj_y == nil then error("Expected y of rectangle to convert, got nil.") end
    if obj_width == nil then error("Expected width of rectangle to convert, got nil.") end
    if obj_height == nil then error("Expected height of rectangle to convert, got nil.") end
    if obj_angle == nil then error("Expected angle of rectangle to convert, got nil.") end

    return_values = {}

    return_values["topleft"] = {
        x = obj_x + collision.rotate_x_coord(-obj_width / 2, -obj_height / 2, obj_angle),
        y = obj_y + collision.rotate_y_coord(-obj_width / 2, -obj_height / 2, obj_angle)
    }

    return_values["topright"] = {
        x = obj_x + collision.rotate_x_coord(obj_width / 2, -obj_height / 2, obj_angle),
        y = obj_y + collision.rotate_y_coord(obj_width / 2, -obj_height / 2, obj_angle)
    }

    return_values["bottomright"] = {
        x = obj_x + collision.rotate_x_coord(obj_width / 2, obj_height / 2, obj_angle),
        y = obj_y + collision.rotate_y_coord(obj_width / 2, obj_height / 2, obj_angle)
    }

    return_values["bottomleft"] = {
        x = obj_x + collision.rotate_x_coord(-obj_width / 2, obj_height / 2, obj_angle),
        y = obj_y + collision.rotate_y_coord(-obj_width / 2, obj_height / 2, obj_angle)
    }

    return return_values
end

-- i is the index of the gameobject we're considering moving
-- new_corners contains the new top left, top right, etc... coordinates
function collision.can_move_to_position(i, new_x, new_y, new_angle)

    local new_corners = collision.stats_to_corner_coordinates(new_x, new_y, gameobjects[i].width, gameobjects[i].height, new_angle)
    assert(new_corners ~= nil)

    -- check if the new position and angle collide with any object
    for j = 1, #gameobjects, 1 do
        if i ~= j then
            for current_property, current_corner in pairs(new_corners) do
                
                local i_collides_j = collision.point_collides_rotated_rectangle(
                    current_corner.x,
                    current_corner.y,
                    gameobjects[j].x,
                    gameobjects[j].y,
                    gameobjects[j].width,
                    gameobjects[j].height,
                    gameobjects[j].angle)

                local j_collides_i = collision.point_collides_rotated_rectangle(
                    gameobjects[j][current_property .. "_x"],
                    gameobjects[j][current_property .. "_y"],
                    new_x,
                    new_y,
                    gameobjects[i].width,
                    gameobjects[i].height,
                    new_angle)
                
                -- x, y, rect_x, rect_y, rect_width, rect_height, rect_angle
                if i_collides_j or j_collides_i then found_collision = true
                    collision.register_collision(i, j)
                    return false
                end
            end
        end
    end

    return true
end

return collision
