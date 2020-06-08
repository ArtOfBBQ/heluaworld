object = {
    x = 200,
    y = 200,
    x_velocity = 0.50,
    y_velocity = 0.50,
    can_move_while_rotating = false,
    angle = 0.5,
    angle2 = 0.6
}

-- allGameObjects[iPlayer].xVelocity += Math.sin(allGameObjects[iPlayer].angle) * 0.2;
-- if (allGameObjects[iPlayer].xVelocity > 1) {allGameObjects[iPlayer].xVelocity = 1};
-- allGameObjects[iPlayer].yVelocity += -Math.cos(allGameObjects[iPlayer].angle) * 0.2;
-- if (allGameObjects[iPlayer].yVelocity > 0.7) {allGameObjects[iPlayer].yVelocity = 0.7};


function object.fix_radians_bounds(self, angle_property_name)

    if self[angle_property_name] == nil then return end

    if self[angle_property_name] < 0 then self[angle_property_name] = self[angle_property_name] + 6.28318 end
    if self[angle_property_name] > 6.28319 then self[angle_property_name] = self[angle_property_name] - 6.28319 end

end

function object.rotate_left(self, increment)
    
    increment = increment or 0.005

    self.angle = self.angle - increment
    if self['weapon_angle'] ~= nil then self.weapon_angle = self.weapon_angle - increment end

    self:fix_radians_bounds('angle')
    self:fix_radians_bounds('weapon_angle')

end

function object.rotate_right(self, increment)
    
    increment = increment or 0.005

    self.angle = self.angle + increment
    if self['weapon_angle'] ~= nil then self.weapon_angle = self.weapon_angle + increment end

    self:fix_radians_bounds('angle')
    self:fix_radians_bounds('weapon_angle')

end

function object.accelerate(self, increment)

    increment = increment or 0.03
    
    self.x_velocity = self.x_velocity + (math.sin(self.angle) * increment)
    self.y_velocity = self.y_velocity - (math.cos(self.angle) * increment)

end

function object.decelerate(self, increment)

    increment = increment or 0.02
    
    if self.x_velocity > 0 then
        self.x_velocity = math.max(
            -- self.x_velocity - (math.sin(self.angle) * increment),
            self.x_velocity - increment,
            0)
    else
        self.x_velocity = math.min(
            -- self.x_velocity - (math.sin(self.angle) * increment),
            self.x_velocity + increment,
            0)
    end
    
    if self.y_velocity > 0 then
        self.y_velocity = math.max(
            self.y_velocity - increment,
            0)
    else
        self.y_velocity = math.min(
            self.y_velocity + increment,
            0)
    end

end

function object:new(o)

    o = o or {}

    setmetatable(o, self)
    self.__index = self
    return o
end

return object
