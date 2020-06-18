map = require("maps.map1")

function map.coords_to_tile(self, x, y)

    local tiles_per_row = math.ceil(self.width / 50)
    local tiles_per_col = math.ceil(self.height / 50)
    assert(tiles_per_col == 30)

    local target_left = math.floor(x / 50)
    local target_top = math.floor(y / 50)

    return 1 + (target_left * (tiles_per_col + 1)) + (target_top)

end

function map.cycle_fit(self, x, y)

    local i = map:coords_to_tile(x, y)

    if self.background_tiles[i].fit == "straight" then
            self.background_tiles[i].fit = "curve_in"
        elseif self.background_tiles[i].fit == "curve_in" then
            self.background_tiles[i].fit = "curve_out"
        elseif self.background_tiles[i].fit == "curve_out" then
            self.background_tiles[i].fit = "straight"
    end

end

function map.cycle_texture(self, x, y)

    local i = map:coords_to_tile(x, y)

    if self.background_tiles[i].texture == "grass" then
            self.background_tiles[i].texture = "grassbeach"
        elseif self.background_tiles[i].texture == "grassbeach" then
            self.background_tiles[i].texture = "beach"
        elseif self.background_tiles[i].texture == "beach" then
            self.background_tiles[i].texture = "beachshallow"
        elseif self.background_tiles[i].texture == "beachshallow" then
            self.background_tiles[i].texture = "shallow"
        elseif self.background_tiles[i].texture == "shallow" then
            self.background_tiles[i].texture = "grass"
    end

end

function map.cycle_angle(self, x, y)

    local i = map:coords_to_tile(x, y)

    if self.background_tiles[i].angle == "0" then
        self.background_tiles[i].angle = "90"
    elseif self.background_tiles[i].angle == "90" then
        self.background_tiles[i].angle = "180"
    elseif self.background_tiles[i].angle == "180" then
        self.background_tiles[i].angle = "270"
    else
        self.background_tiles[i].angle = "0"
    end

end

function map.cycle_variation(self, x, y)

    local i = map:coords_to_tile(x, y)

    if self.background_tiles[i].image ~= "grass" then
        self.background_tiles[i].variation = 0
    else
        self.background_tiles[i].variation = self.background_tiles[i].variation + 1
        if self.background_tiles[i].variation > 5 then self.background_tiles[i].variation = 0 end
    end

end

function map.save_tiles_as_hardcode(self, filename, gameobjects)

    assert(filename ~= nil)

    local file = io.open(filename, "w")
    assert(file ~= nil)

    for i = 1, #self.background_tiles, 1 do
        if map.background_tiles[i].image ~= "sand" then
            -- return tile.texture .. "_" .. tostring(tile.variation) .. "_" .. tile.fit .. "_0_" .. tile.angle

            file:write('map.background_tiles[' .. i .. '].texture = "' .. map.background_tiles[i].texture .. '"\n')
            file:write('map.background_tiles[' .. i .. '].variation = ' .. map.background_tiles[i].variation .. '\n')
            file:write('map.background_tiles[' .. i .. '].fit = "' .. map.background_tiles[i].fit .. '"\n')
            file:write('map.background_tiles[' .. i .. '].angle = "' .. map.background_tiles[i].angle .. '"\n')
        end
    end

    for i = 1, #gameobjects, 1 do
        if gameobjects[i].max_speed == 0 then

            file:write('gameobjects[#gameobjects + 1] = object:new()\n')
            file:write('gameobjects[#gameobjects].sprite_frame = "' .. gameobjects[i].sprite_frame .. '"\n')
            file:write('gameobjects[#gameobjects].size_modifier = ' .. gameobjects[i].size_modifier .. '\n')
            file:write('gameobjects[#gameobjects].x = ' .. math.round(gameobjects[i].x) .. '\n')
            file:write('gameobjects[#gameobjects].y = ' .. math.round(gameobjects[i].y) .. '\n')
            file:write('gameobjects[#gameobjects].width = ' .. math.round(gameobjects[i].width) .. '\n')
            file:write('gameobjects[#gameobjects].height = ' .. math.round(gameobjects[i].height) .. '\n')
            file:write('gameobjects[#gameobjects].weight = ' .. math.round(gameobjects[i].weight) .. '\n')
            file:write('gameobjects[#gameobjects].angle = ' .. gameobjects[i].angle .. '\n')
            
        end
    end

    io.close(file)

end


return map
