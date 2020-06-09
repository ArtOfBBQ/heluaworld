helper = {}

function helper.rotate_x_coord(x, y, angle)
    return x * math.cos(angle) - (y * math.sin(angle))
end

function helper.rotate_y_coord(x, y, angle)
    return x * math.sin(angle) + (y * math.cos(angle))
end

return helper