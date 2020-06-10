object = {
    sprite_frame = 'tank',
    sprite_top = 'tankgun',
    x = 100,
    y = 100,
    width = 80, -- 80 at size_modifier = 1, will be downsized in new()
    height = 156, -- 156 at size_modifier = 1, will be downsized in new()
    x_velocity = 0,
    y_velocity = 0,
    max_speed_while_rotating = 0.75,
    angle = 2,
    angle2 = 0.6,
    max_speed = 20,
    max_reverse_speed = 5,
    accel_speed = 0.125,
    decel_speed = 0.1,
    reverse_accel_speed = 0.125,
    rotation_speed = 0.75,
    size_modifier = 0.1666
}

function object.fix_radians_bounds(self, angle_property_name)

    if self[angle_property_name] == nil then return end

    if self[angle_property_name] < 0 then self[angle_property_name] = self[angle_property_name] + 6.28318 end
    if self[angle_property_name] > 6.28319 then self[angle_property_name] = self[angle_property_name] - 6.28319 end

end

function object.rotate_left(self, elapsed)
    
    local increment = self.rotation_speed * elapsed

    self.angle = self.angle - increment
    if self['weapon_angle'] ~= nil then self.weapon_angle = self.weapon_angle - increment end

    self:fix_radians_bounds('angle')
    self:fix_radians_bounds('weapon_angle')

end

function object.rotate_right(self, elapsed)
    
    local increment = self.rotation_speed * elapsed

    self.angle = self.angle + increment
    if self['weapon_angle'] ~= nil then self.weapon_angle = self.weapon_angle + increment end

    self:fix_radians_bounds('angle')
    self:fix_radians_bounds('weapon_angle')

end

function object.accelerate(self, elapsed)

    local increment = self.accel_speed * elapsed
    
    self.x_velocity = self.x_velocity + (math.sin(self.angle) * increment)
    self.y_velocity = self.y_velocity - (math.cos(self.angle) * increment)

end

function object.decelerate(self, elapsed)

    local increment = self.decel_speed * elapsed
    local total_speed = math.abs(self.x_velocity) + math.abs(self.y_velocity)
    
    if self.x_velocity > 0 then
        self.x_velocity = math.max(
            self.x_velocity - math.abs((self.x_velocity / total_speed) * increment),
            0)
    else
        self.x_velocity = math.min(
            self.x_velocity + math.abs((self.x_velocity / total_speed) * increment),
            0)
    end
    
    if self.y_velocity > 0 then
        self.y_velocity = math.max(
            self.y_velocity - math.abs((self.y_velocity / total_speed) * increment),
            0)
    else
        self.y_velocity = math.min(
            self.y_velocity + math.abs((self.y_velocity / total_speed) * increment),
            0)
    end
end

function object.reverse(self, elapsed)

    local increment = self.reverse_accel_speed * elapsed
    
    self.x_velocity = self.x_velocity - (math.sin(self.angle) * increment)
    self.y_velocity = self.y_velocity + (math.cos(self.angle) * increment)

end

function object:new(o)

    o = o or {}

    setmetatable(o, self)
    self.__index = self

    o.width = o.width * o.size_modifier
    o.height = o.height * o.size_modifier

    return o
end

return object
