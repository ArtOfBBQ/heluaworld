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

    collision_count = collision_count + 1

    -- I can't figure out how to do elastic collision by myself,
    -- so I'm copying this C++ code line by line from Javidx9's public 'balls' repository

    -- // Distance between balls
    -- float fDistance = sqrtf((b1->px - b2->px)*(b1->px - b2->px) + (b1->py - b2->py)*(b1->py - b2->py));
    -- local dist_objects = math.sqrt(
    --     ((gameobjects[i].x - gameobjects[j].x)^2) +
    --     ((gameobjects[i].y - gameobjects[j].y)^2) )

    -- -- // Normal
    -- -- float nx = (b2->px - b1->px) / fDistance;
    -- -- float ny = (b2->py - b1->py) / fDistance;
    -- local nx = (gameobjects[j].x - gameobjects[i].x) / dist_objects
    -- local ny = (gameobjects[j].y - gameobjects[i].y) / dist_objects
    -- if nx < 0.2 then
    --     nx = 0.2
    --     ny = 0.8
    -- elseif ny < 0.2 then
    --     nx = 0.8
    --     ny = 0.2
    -- end

    -- -- // Tangent
    -- -- float tx = -ny;
    -- -- float ty = nx;
    -- local tx = -ny
    -- local ty = nx

    -- -- // Dot Product Tangent
    -- -- float dpTan1 = b1->vx * tx + b1->vy * ty;
    -- -- float dpTan2 = b2->vx * tx + b2->vy * ty;
    -- local dpTan1 = (gameobjects[i].x_velocity * tx) +
    --                    (gameobjects[i].y_velocity * ty)
    -- local dpTan2 = (gameobjects[j].x_velocity * tx) +
    --                    (gameobjects[j].y_velocity * ty)

    -- -- // Dot Product Normal
    -- -- float dpNorm1 = b1->vx * nx + b1->vy * ny;
    -- -- float dpNorm2 = b2->vx * nx + b2->vy * ny;
    -- local dpNorm1 = (gameobjects[i].x_velocity * nx) +
    --                     (gameobjects[i].y_velocity * ny)
    -- local dpNorm2 = (gameobjects[j].x_velocity * nx) +
    --                     (gameobjects[j].y_velocity * ny)

    -- -- // Conservation of momentum in 1D
    -- -- float m1 = (dpNorm1 * (b1->mass - b2->mass) + 2.0f * b2->mass * dpNorm2) / (b1->mass + b2->mass);
    -- -- float m2 = (dpNorm2 * (b2->mass - b1->mass) + 2.0f * b1->mass * dpNorm1) / (b1->mass + b2->mass);
    -- local m1 =
    --     ((dpNorm1 * (gameobjects[i].weight - gameobjects[j].weight)) + 2 *
    --         gameobjects[j].weight * dpNorm2) /
    --         (gameobjects[i].weight + gameobjects[j].weight)
    -- local m2 =
    --     ((dpNorm2 * (gameobjects[j].weight - gameobjects[i].weight)) + 2 *
    --         gameobjects[i].weight * dpNorm1) /
    --         (gameobjects[i].weight + gameobjects[j].weight)

    -- -- // Update ball velocities
    -- -- b1->vx = tx * dpTan1 + nx * m1;
    -- -- b1->vy = ty * dpTan1 + ny * m1;
    -- -- b2->vx = tx * dpTan2 + nx * m2;
    -- -- b2->vy = ty * dpTan2 + ny * m2;
    -- gameobjects[i].x_velocity = (tx * dpTan1 + nx * m1) * 0.95
    -- gameobjects[i].y_velocity = (ty * dpTan1 + ny * m1) * 0.95
    -- gameobjects[j].x_velocity = (tx * dpTan2 + nx * m2) * 0.95
    -- gameobjects[j].y_velocity = (ty * dpTan2 + ny * m2) * 0.95

    gameobjects[i].x_velocity = gameobjects[i].x_velocity * -0.85
    gameobjects[i].y_velocity = gameobjects[i].y_velocity * -0.85
    gameobjects[j].x_velocity = gameobjects[i].x_velocity * -0.85
    gameobjects[j].y_velocity = gameobjects[i].y_velocity * -0.85

    -- I have no idea how the objects are supposed to rotate,
    -- after colliding, but this feels better than nothing
    if math.abs(gameobjects[i].rotation_velocity) > 0 then gameobjects[i].rotation_velocity = gameobjects[i].rotation_velocity * -0.75 end
    if math.abs(gameobjects[j].rotation_velocity) > 0 then gameobjects[j].rotation_velocity = gameobjects[j].rotation_velocity * -0.75 end

    -- keep track of latest collision
    gameobjects[i].loops_since_collision = 0
    gameobjects[j].loops_since_collision = 0
end

return collision
