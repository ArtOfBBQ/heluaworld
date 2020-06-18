-- we may end up with some algorithm that sets waypoints for our units
-- this module assumes the waypoints are set already and moves the unit accordingly

driver = {}


-- "drive" to the queued waypoints by sending requests
-- to update the gameobject's acceleration and rotation
function driver.drive(gameobject)

    assert(gameobject.y ~= nil)
    
    if gameobject["waypoints"] == nil or #gameobject.waypoints == 0 then
        gameobject:decelerate(elapsed * 150)
        return
    else

        assert(elapsed ~= nil)

        local goal_angle = driver.get_goal_angle(gameobject, #gameobject.waypoints)
        local final_goal_angle = 0
        if #gameobject.waypoints == 1 then
            final_goal_angle = goal_angle
        else
            final_goal_angle = driver.get_goal_angle(gameobject, 1)
        end

        local diff_to_goal_angle = gameobject.angle - goal_angle

        local want_to_decelerate = false
        local want_to_accelerate = false

        if math.abs(gameobject.x_velocity + gameobject.y_velocity) > 0.25 then want_to_decelerate = true end

        if math.abs(gameobject.x - gameobject.waypoints[#gameobject.waypoints].x) < ((gameobject.width + gameobject.height)/2) and
            math.abs(gameobject.y - gameobject.waypoints[#gameobject.waypoints].y) < ((gameobject.width + gameobject.height)/2) then
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

        if final_goal_angle == gameobject.weapon_angle then
            -- already at goal, do nothing
        elseif math.abs(final_goal_angle - gameobject.weapon_angle) < 0.1 then
            gameobject.weapon_angle = final_goal_angle
        else
            gameobject:rotate_weapon_left(elapsed)
        end
        
        if want_to_accelerate then
            gameobject:accelerate(elapsed)
        end

        if want_to_decelerate then
            gameobject:reverse(elapsed)
        end

    end

end


function driver.get_goal_angle(gameobject, i_waypoint)

    assert(gameobject.y ~= nil)
    assert(gameobject.x ~= nil)
    assert(gameobject.waypoints ~= nil)
    assert(gameobject.waypoints[i_waypoint].x ~= nil)
    assert(gameobject.waypoints[i_waypoint].y ~= nil)

    if (gameobject.waypoints[i_waypoint].y < gameobject.y
        and gameobject.waypoints[i_waypoint].x > gameobject.x)
    then
        return 1.57 - math.atan(
            math.abs(gameobject.waypoints[i_waypoint].y - gameobject.y) /
            math.abs(gameobject.waypoints[i_waypoint].x - gameobject.x))
    elseif (gameobject.waypoints[i_waypoint].y > gameobject.y
        and gameobject.waypoints[i_waypoint].x > gameobject.x)
    then
        return 1.57 + math.atan(
            math.abs(gameobject.waypoints[i_waypoint].y - gameobject.y) /
            math.abs(gameobject.waypoints[i_waypoint].x - gameobject.x))
    elseif (gameobject.waypoints[i_waypoint].y > gameobject.y
        and gameobject.waypoints[i_waypoint].x < gameobject.x)
    then
        return 4.71 - math.atan(
            math.abs(gameobject.waypoints[i_waypoint].y - gameobject.y) /
            math.abs(gameobject.waypoints[i_waypoint].x - gameobject.x))
    end

    return 4.71 + math.atan(
        math.abs(gameobject.waypoints[i_waypoint].y - gameobject.y) /
        math.abs(gameobject.waypoints[i_waypoint].x - gameobject.x))
    
end

return driver
