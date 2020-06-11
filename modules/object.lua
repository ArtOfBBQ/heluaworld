object = {
    sprite_frame = nil,
    sprite_top = nil,
    x = 100,
    y = 100,
    width = 10,
    height = 10, -- 156 at size_modifier = 1, will be downsized in new()
    x_velocity = 0,
    y_velocity = 0,
    max_speed_while_rotating = 0.75,
    angle = 2,
    weapon_angle = nil,
    max_speed = 20,
    max_reverse_speed = 5,
    accel_speed = 0.125,
    decel_speed = 0.1,
    reverse_accel_speed = 0.125,
    rotation_speed = 1.25,
    size_modifier = 1
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

function object.rotate_weapon_left(self, elapsed)
    
    local increment = self.rotation_speed * elapsed

    self.weapon_angle = self.weapon_angle - increment

    self:fix_radians_bounds('weapon_angle')

end

function object.rotate_weapon_right(self, elapsed)
    
    local increment = self.rotation_speed * elapsed

    self.weapon_angle = self.weapon_angle + increment
    
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

function object.adjust_size(self, new_size_modifier)

    local orig_width = (1/self.size_modifier) * self.width
    local orig_height = (1/self.size_modifier) * self.height

    self.width = new_size_modifier * orig_width
    self.height = new_size_modifier * orig_height
    self.size_modifier = new_size_modifier

end

function object:new(o)

    o = o or {}

    setmetatable(o, self)
    self.__index = self

    o.width = o.width * o.size_modifier
    o.height = o.height * o.size_modifier

    return o
end

function object:newtank()

    o = object:new()

    o.sprite_frame = 'tank'
    o.sprite_top = 'tankgun'
    o.max_speed = 20
    o.max_reverse_speed = 5
    o.accel_speed = 0.125
    o.decel_speed = 0.1
    o.weapon_angle = 0.3
    o.size_modifier = 0.25

    o.width = 80 * o.size_modifier
    o.height = 156 * o.size_modifier

    return o
end


local tree_images = {'tree1', 'tree2', 'tree3', 'tree4', 'tree5', 'tree6', 'tree7', 'tree8', 'tree9'}

function object:newtree(x, y)

    o = object:new()

    o.x = x
    o.y = y
    o.sprite_frame = tree_images[ math.random( #tree_images ) ]
    o.sprite_top = nil
    o.max_speed = 0
    o.max_reverse_speed = 0
    o.accel_speed = 0
    o.decel_speed = 0
    o.angle = math.random() * 6.28
    o.size_modifier = 0.33 * ((1 + math.random()) / 1.5)

    o.width = 128 * o.size_modifier
    o.height = 128 * o.size_modifier

    return o
end

return object
