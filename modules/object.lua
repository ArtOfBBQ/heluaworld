object = {
    x = 200,
    y = 200,
    angle = 0.5,
    angle2 = 0.6
}

function object.fix_radians_bounds(self, angle_property_name)

    if self[angle_property_name] == nil then return end

    if self[angle_property_name] < 0 then self[angle_property_name] = self[angle_property_name] + 6.28318 end
    if self[angle_property_name] > 6.28319 then self[angle_property_name] = self[angle_property_name] - 6.28319 end

end

function object.rotate_left(self, increment)
    
    increment = increment or 0.02

    self.angle = self.angle + increment
    if self['weapon_angle'] ~= nil then self.weapon_angle = self.weapon_angle + increment end

    self:fix_radians_bounds('angle')
    self:fix_radians_bounds('weapon_angle')

end

function object.rotate_right(self, increment)
    
    increment = increment or 0.02

    self.angle = self.angle - increment
    if self['weapon_angle'] ~= nil then self.weapon_angle = self.weapon_angle - increment end
    
    self:fix_radians_bounds('angle')
    self:fix_radians_bounds('weapon_angle')

end

function object:new(o)

    o = o or {}

    setmetatable(o, self)
    self.__index = self
    return o
end

return object
