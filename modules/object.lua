object = {
    id = nil,
    sprite_frame = nil,
    sprite_top = nil,
    x = 100,
    y = 100,
    topleft_x = nil,
    topleft_y = nil,
    topright_x = nil,
    topright_y = nil,
    bottomleft_x = nil,
    bottomleft_y = nil,
    bottomright_x = nil,
    bottomright_y = nil,
    width = 10,
    height = 10, -- 156 at size_modifier = 1, will be downsized in new()
    weight = 50,
    x_velocity = 0,
    y_velocity = 0,
    rotation_velocity = 0,
    angle = 2,
    weapon_angle = nil,
    weapon_y_offset = 0,
    accel_speed = 0.2,
    velocity_loss_pct = 0.005,
    reverse_accel_speed = 0.125,
    rotation_speed = 1.75,
    size_modifier = 1,
    loops_since_collision = 9999
}

local latest_id = 0

function object.fix_radians_bounds(self, angle_property_name)

    if angle_property_name == nil then error("Expected name of angle property to fix, got nil.") end
    if self[angle_property_name] == nil then error(angle_property_name .. " is not a property, can't fix radians bounds.") end

    if self[angle_property_name] < 0 then
        self[angle_property_name] = self[angle_property_name] + (math.pi * 10)
    end

    if self[angle_property_name] > math.pi * 2 then
        self[angle_property_name] = self[angle_property_name] % (math.pi * 2)
    end

end

function object.rotate_left(self, elapsed)
    
    self.rotation_velocity = self.rotation_velocity - (self.rotation_speed * elapsed)
    -- if self['weapon_angle'] ~= nil then self.weapon_angle = self.weapon_angle - increment end

    self:fix_radians_bounds('angle')
    self:fix_radians_bounds('weapon_angle')

end

function object.rotate_right(self, elapsed)

    self.rotation_velocity = self.rotation_velocity + (self.rotation_speed * elapsed)
    -- if self['weapon_angle'] ~= nil then self.weapon_angle = self.weapon_angle + increment end

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

function object.get_accelerated_x_velocity(angle, cur_x_velocity, accel_speed, elapsed)

    return cur_x_velocity + (math.sin(angle) * (accel_speed * elapsed))

end

function object.get_accelerated_y_velocity(angle, cur_y_velocity, accel_speed, elapsed)

    return cur_y_velocity - (math.cos(angle) * (accel_speed * elapsed))

end

function object.accelerate(self, elapsed)

    self.x_velocity = object.get_accelerated_x_velocity(self.angle, self.x_velocity, self.accel_speed, elapsed)
    self.y_velocity = object.get_accelerated_y_velocity(self.angle, self.y_velocity, self.accel_speed, elapsed)

end

function object.decelerate(self, elapsed)

    if math.abs(self.rotation_velocity) < 0.00003 then
        self.rotation_velocity = 0
    else
        self.rotation_velocity = self.rotation_velocity *
                                     (1 - (self.velocity_loss_pct))
    end

    if math.abs(self.x_velocity) < 0.00003 then
        self.x_velocity = 0
    else
        self.x_velocity = self.x_velocity * (1 - (self.velocity_loss_pct))
    end

    if math.abs(self.y_velocity) < 0.00003 then
        self.y_velocity = 0
    else
        self.y_velocity = self.y_velocity * (1 - (self.velocity_loss_pct))
    end

end

function object.reduce_rotation_velocity(self, elapsed)

    if self.rotation_velocity > 0 then
        self.rotation_velocity = math.max(
            self.rotation_velocity - (self.rotation_speed * 2 * elapsed), 0)
    else
        self.rotation_velocity = math.min(
            self.rotation_velocity + (self.rotation_speed * 2 * elapsed), 0)
    end

end

function object.reverse(self, elapsed)

    self.x_velocity = object.get_accelerated_x_velocity(self.angle, self.x_velocity, self.reverse_accel_speed, -elapsed)
    self.y_velocity = object.get_accelerated_y_velocity(self.angle, self.y_velocity, self.reverse_accel_speed, -elapsed)

end

function object.update_position(self, map_width, map_height)

    local found_collision = false
    
    local ran_x = 0
    if self.loops_since_collision < 100 then ran_x = (math.random(-10, 10) / 300) end
    new_x = math.min(math.max(self.x + self.x_velocity, 0),
        map_width - (self.height / 4)) + ran_x

    local ran_y = 0
    if self.loops_since_collision < 30 then ran_y = (math.random(-10, 10) / 300) end
    new_y = math.min(math.max(self.y + self.y_velocity, 0),
        map_height - (self.height / 4)) + ran_y

    new_angle = self.angle + self.rotation_velocity
    if new_angle < 0 then new_angle = math.pi * 2 end
    if new_angle > math.pi * 2 then new_angle = 0 end
    
    local new_corners = object.stats_to_corner_coordinates(new_x, new_y, self.width, self.height, new_angle)
    assert(new_corners ~= nil)

    -- check if the new position and angle collide with any object
    for j = 1, #gameobjects, 1 do
        if self.id ~= j then
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
                    self.width,
                    self.height,
                    new_angle)
                
                -- x, y, rect_x, rect_y, rect_width, rect_height, rect_angle
                if i_collides_j or j_collides_i then found_collision = true
                    found_collision = true
                    collision.register_collision(self.id, j)
                    break
                end
            end
        end
    end

    -- there were no collisions, change objects's position
    if found_collision == false then
        self.loops_since_collision = self.loops_since_collision + 1
        self.x = new_x
        self.y = new_y
        self.angle = new_angle
        self:update_corner_coordinates()
        self:fix_radians_bounds("angle")
    end
end

function object.adjust_size(self, new_size_modifier)

    local orig_width = (1 / self.size_modifier) * self.width
    local orig_height = (1 / self.size_modifier) * self.height

    self.width = new_size_modifier * orig_width
    self.height = new_size_modifier * orig_height
    self.size_modifier = new_size_modifier

end

function object.update_corner_coordinates(self)
    self.topleft_x = self.x +
                         collision.rotate_x_coord(-self.width / 2,
            -self.height / 2, self.angle)
    self.topleft_y = self.y +
                         collision.rotate_y_coord(-self.width / 2,
            -self.height / 2, self.angle)
    self.topright_x = self.x +
                          collision.rotate_x_coord(self.width / 2,
            -self.height / 2, self.angle)
    self.topright_y = self.y +
                          collision.rotate_y_coord(self.width / 2,
            -self.height / 2, self.angle)
    self.bottomright_x = self.x +
                             collision.rotate_x_coord(self.width / 2,
            self.height / 2, self.angle)
    self.bottomright_y = self.y +
                             collision.rotate_y_coord(self.width / 2,
            self.height / 2, self.angle)
    self.bottomleft_x = self.x +
                            collision.rotate_x_coord(-self.width / 2,
            self.height / 2, self.angle)
    self.bottomleft_y = self.y +
                            collision.rotate_y_coord(-self.width / 2,
            self.height / 2, self.angle)
end

function object.stats_to_corner_coordinates(obj_x, obj_y, obj_width, obj_height, obj_angle)

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

function object:new(o)

    o = o or {}

    setmetatable(o, self)
    self.__index = self

    latest_id = latest_id + 1
    o.id = latest_id

    o.width = o.width * o.size_modifier
    o.height = o.height * o.size_modifier

    return o
end

function object:newtank(x, y)

    o = object:new()

    o.x = x
    o.y = y
    o.sprite_frame = 'tank'
    o.sprite_top = 'tankgun'
    o.max_speed = 5
    o.max_reverse_speed = 0.35
    o.accel_speed = 2
    o.velocity_loss_pct = 0.01
    o.reverse_accel_speed = 0.4
    o.weapon_angle = 0.3
    o.size_modifier = 0.25
    o.rotation_speed = 0.01
    o.weapon_y_offset = 2

    o.weight = 500

    o.width = 80 * o.size_modifier
    o.height = 156 * o.size_modifier

    return o
end

function object:newbuggy(x, y)

    o = object:new()

    o.x = x
    o.y = y
    o.sprite_frame = 'buggy'
    o.sprite_top = 'buggygun'
    o.max_speed = 10
    o.max_reverse_speed = 1.6
    o.accel_speed = 3
    o.velocity_loss_pct = 0.01
    o.reverse_accel_speed = 1
    o.weapon_angle = 0.3
    o.size_modifier = 0.04
    o.rotation_speed = 0.03
    o.weapon_y_offset = 8

    o.weight = 20

    o.width = 376 * o.size_modifier
    o.height = 720 * o.size_modifier

    return o
end

function object:newwall(x, y)

    o = object:new()

    o.x = x
    o.y = y
    o.sprite_frame = "wall1"
    o.sprite_top = nil
    o.max_speed = 0
    o.max_reverse_speed = 0
    o.accel_speed = 0
    o.velocity_loss_pct = 0
    o.angle = 0
    o.size_modifier = 0.25

    o.weight = 2000

    o.width = 533 * o.size_modifier
    o.height = 111 * o.size_modifier

    o:update_corner_coordinates()

    return o

end

local tree_images = {
    'tree1', 'tree2', 'tree3', 'tree4', 'tree5', 'tree6', 'tree7', 'tree8',
    'tree9'
}

function object:newtree(x, y)

    o = object:new()

    o.x = x
    o.y = y
    o.sprite_frame = tree_images[math.random(#tree_images)]
    o.sprite_top = nil
    o.max_speed = 0
    o.max_reverse_speed = 0
    o.accel_speed = 0
    o.velocity_loss_pct = 0
    o.angle = math.random() * 6.28
    o.size_modifier = 0.33 * ((1 + math.random()) / 1.5)

    o.weight = 200

    o.width = 128 * o.size_modifier
    o.height = 128 * o.size_modifier

    o:update_corner_coordinates()

    return o
end

local rock_images = {'rock1'} -- , 'rock2', 'rock3', 'rock4', 'rock5', 'rock6', 'rock7', 'rock8', 'rock9'}

function object.newrock(x, y)

    assert(x ~= nil)
    assert(y ~= nil)

    o = object:new()

    o.x = x
    o.y = y
    o.sprite_frame = rock_images[math.random(#rock_images)]
    o.sprite_top = nil
    o.max_speed = 0
    o.max_reverse_speed = 0
    o.accel_speed = 0
    o.velocity_loss_pct = 0
    o.angle = math.random() * 6.28
    o.size_modifier = 0.05 * (1 + 0.05)

    o.width = 646 * o.size_modifier
    o.height = 534 * o.size_modifier

    o.weight = 100 * (o.width + o.height)

    return o
end

return object
