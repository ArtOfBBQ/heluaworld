-- we may end up with some algorithm that sets waypoints for our units
-- this module assumes the waypoints are set already and moves the unit accordingly
driver = {}

-- "drive" to the queued waypoints by sending requests
-- to update the gameobject's acceleration and rotation
function driver.drive(gameobject)

    assert(gameobject.y ~= nil)
    gameobject:fix_radians_bounds("angle")

    if gameobject["waypoints"] == nil or #gameobject.waypoints == 0 then
        gameobject:decelerate(elapsed * 150)
        return
    else

        assert(elapsed ~= nil)

        goal_angle = driver.get_goal_angle(
            gameobject.x,
            gameobject.y,
            gameobject.waypoints[#gameobject.waypoints].x,
            gameobject.waypoints[#gameobject.waypoints].y)
        
        
        local final_goal_angle = driver.get_goal_angle(
            gameobject.x,
            gameobject.y,
            gameobject.waypoints[1].x,
            gameobject.waypoints[1].y)

        assert(gameobject.angle >= 0, gameobject.angle)
        assert(gameobject.angle <= (math.pi * 2))
        assert(goal_angle > 0)
        assert(goal_angle <= (math.pi * 2))

        diff_to_goal_angle = driver.get_diff_angles(goal_angle, gameobject.angle)
        assert(math.abs(diff_to_goal_angle) < math.pi, diff_to_goal_angle)

        -- rotation speed should be highest when diff_to_goal_angle is 3.14 or -3.14
        -- and lowest when diff_to_goal_angle is 0 or 6.28
        local ideal_rotation_velocity = driver.get_ideal_rotation_velocity(diff_to_goal_angle)
        
        if gameobject.rotation_velocity > ideal_rotation_velocity then
            gameobject:rotate_left(elapsed)
        else
            gameobject:rotate_right(elapsed)
        end

        -- to rate current speed vs ideal speed
        local ideal_x_vel = driver.get_ideal_x_velocity(goal_angle) / 3
        local ideal_y_vel = driver.get_ideal_y_velocity(goal_angle) / 3
        
        -- to rate acceleration vs ideal speed
        local accel_x_vel = object.get_accelerated_x_velocity(gameobject.angle, gameobject.x_velocity, gameobject.accel_speed, elapsed)
        local accel_y_vel = object.get_accelerated_y_velocity(gameobject.angle, gameobject.y_velocity, gameobject.accel_speed, elapsed)

        -- to rate reversing the acceleration (to break or go backwards) vs ideal speed
        local reverse_x_vel = object.get_accelerated_x_velocity(gameobject.angle, gameobject.x_velocity, gameobject.reverse_accel_speed, -elapsed)
        local reverse_y_vel = object.get_accelerated_y_velocity(gameobject.angle, gameobject.y_velocity, gameobject.reverse_accel_speed, -elapsed)

        local dist_cur_vs_ideal = (ideal_x_vel - gameobject.x_velocity)^2 + ((ideal_y_vel - gameobject.y_velocity)^2)
        local dist_accel_vs_ideal = (ideal_x_vel - accel_x_vel)^2 + ((ideal_y_vel - accel_y_vel)^2)
        local dist_reverse_vs_ideal = (ideal_x_vel - reverse_x_vel)^2 + ((ideal_y_vel - reverse_y_vel)^2)

        if dist_accel_vs_ideal < dist_cur_vs_ideal and dist_accel_vs_ideal < dist_reverse_vs_ideal then
            gameobject:accelerate(elapsed)
        elseif dist_reverse_vs_ideal < dist_cur_vs_ideal then
            gameobject:reverse(elapsed)
        end
        
    end
end

function driver.get_ideal_rotation_velocity(diff_to_goal_angle)

        return math.min(diff_to_goal_angle / 15, 0.009)

end

function driver.get_diff_angles(angle1, angle2)

    if angle1 == nil then error("Expected 1st radians angle to calculate the difference for, got nil.") end
    if angle2 == nil then error("Expected 2nd radians angle to calculate the difference for, got nil.") end
    if angle1 < 0 or angle1 > (math.pi * 2) then error("Expected 1st radians angle (0 to 2x pi) to calculate the difference for, got " .. angle1 .. ".") end
    if angle2 < 0 or angle2 > (math.pi * 2) then error("Expected 2nd radians angle (0 to 2x pi) to calculate the difference for, got " .. angle2 .. ".") end

    local result_one = (angle1 + (math.pi * 2)) - angle2
    local result_two = angle1 - angle2
    local result_three = angle1 - (angle2 + (math.pi * 2))

    if math.abs(result_one) < math.abs(result_two) and math.abs(result_one) < math.abs(result_three) then
        return  result_one
    elseif math.abs(result_three) < math.abs(result_two) then
        return result_three
    else
        return result_two
    end

end

function driver.get_ideal_x_velocity(angle_to_goal)

    if angle_to_goal == nil then error("Expected radians angle to the goal, got nil.") end
    if angle_to_goal < 0 or angle_to_goal > (math.pi * 2) then error("Expected radians angle to the goal, got " .. angle_to_goal .. ".") end

    return math.sin(angle_to_goal)

end

function driver.get_ideal_y_velocity(angle_to_goal)

    if angle_to_goal == nil then error("Expected radians angle to the goal, got nil.") end
    if angle_to_goal < 0 or angle_to_goal > (math.pi * 2) then error("Expected radians angle to the goal, got " .. angle_to_goal .. ".") end

    return -math.cos(angle_to_goal)

end

function driver.get_goal_angle(cur_x, cur_y, target_x, target_y)

    assert(cur_y ~= nil)
    assert(cur_x ~= nil)
    assert(target_x ~= nil)
    assert(target_y ~= nil)
    
    if (target_y < cur_y and target_x > cur_x) then
        return (math.pi * 0.5) -
                   math.atan(math.abs(target_y - cur_y) /
                                 math.abs(target_x - cur_x))
    elseif (target_y > cur_y and target_x > cur_x) then
        return (math.pi * 0.5) +
                   math.atan(math.abs(target_y - cur_y) /
                                 math.abs(target_x - cur_x))
    elseif (target_y > cur_y and target_x < cur_x) then
        return (math.pi * 1.5) -
                   math.atan(math.abs(target_y - cur_y) /
                                 math.abs(target_x - cur_x))
    end

    return (math.pi * 1.5) + math.atan(math.abs(target_y - cur_y) / math.abs(target_x - cur_x))
    
end

return driver
