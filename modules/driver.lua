-- we may end up with some algorithm that sets waypoints for our units
-- this module assumes the waypoints are set already and moves the unit accordingly

driver = {}


-- "drive" to the queued waypoints by sending requests
-- to update the gameobject's acceleration and rotation
function driver.drive(gameobject)

    assert(gameobject.y ~= nil)
    
    if gameobject["waypoints"] == nil or #gameobject.waypoints == 0 then
        return
    else

        assert(elapsed ~= nil)

        local goal_angle = driver.get_goal_angle(gameobject)
        local diff_to_goal_angle = gameobject.angle - goal_angle

        local want_to_decelerate = false
        local want_to_accelerate = false

        if math.abs(gameobject.x_velocity) > 0.25 or math.abs(gameobject.y_velocity) > 0.25 then
            want_to_accelerate = false
            want_to_decelerate = true
        end

        if math.abs(diff_to_goal_angle) > gameobject.max_speed_while_rotating then
            want_to_accelerate = false
            want_to_decelerate = true
        end

        if math.abs(gameobject.x - gameobject.waypoints[#gameobject.waypoints].x) < 10 and
            math.abs(gameobject.y - gameobject.waypoints[#gameobject.waypoints].y) < 10 then
            
            gameobject.waypoints[#gameobject.waypoints] = nil

        end

        if goal_angle == gameobject.angle then
            -- already at goal angle
            want_to_decelerate = false
            want_to_accelerate = true
        elseif math.abs(diff_to_goal_angle) < gameobject.rotation_speed * elapsed then
            gameobject.angle = goal_angle
            want_to_decelerate = false
            want_to_accelerate = true
        elseif math.abs(diff_to_goal_angle) > 3.13 and diff_to_goal_angle < 0 then
            gameobject:rotate_left(elapsed)
        elseif math.abs(diff_to_goal_angle) < 3.13 and diff_to_goal_angle > 0 then
            gameobject:rotate_left(elapsed)
        else
            gameobject:rotate_right(elapsed)
        end
        
        if want_to_accelerate then
            gameobject:accelerate(elapsed)
        end

        if want_to_decelerate then
            gameobject:reverse(elapsed)
        end

    end

end


function driver.get_goal_angle(gameobject)

    assert(gameobject.y ~= nil)
    assert(gameobject.x ~= nil)
    assert(gameobject.waypoints ~= nil)
    assert(gameobject.waypoints[#gameobject.waypoints].x ~= nil)
    assert(gameobject.waypoints[#gameobject.waypoints].y ~= nil)

    if (gameobject.waypoints[#gameobject.waypoints].y < gameobject.y
        and gameobject.waypoints[#gameobject.waypoints].x > gameobject.x)
    then
        return 1.57 - math.atan(
            math.abs(gameobject.waypoints[#gameobject.waypoints].y - gameobject.y) /
            math.abs(gameobject.waypoints[#gameobject.waypoints].x - gameobject.x))
    elseif (gameobject.waypoints[#gameobject.waypoints].y > gameobject.y
        and gameobject.waypoints[#gameobject.waypoints].x > gameobject.x)
    then
        return 1.57 + math.atan(
            math.abs(gameobject.waypoints[#gameobject.waypoints].y - gameobject.y) /
            math.abs(gameobject.waypoints[#gameobject.waypoints].x - gameobject.x))
    elseif (gameobject.waypoints[#gameobject.waypoints].y > gameobject.y
        and gameobject.waypoints[#gameobject.waypoints].x < gameobject.x)
    then
        return 4.71 - math.atan(
            math.abs(gameobject.waypoints[#gameobject.waypoints].y - gameobject.y) /
            math.abs(gameobject.waypoints[#gameobject.waypoints].x - gameobject.x))
    end

    return 4.71 + math.atan(
        math.abs(gameobject.waypoints[#gameobject.waypoints].y - gameobject.y) /
        math.abs(gameobject.waypoints[#gameobject.waypoints].x - gameobject.x))
    
end

return driver
