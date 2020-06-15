map = require("maps.map1")

-- this is a temporary function to edit the map
-- it cycles the image sprite for whatever tile is at position x,y
--
-- [x1, y1] [x2, y1]
-- [x1, y2] [x2, y2]
-- [x1, y3]
-- [x1, y4]
-- [x1, y5]
-- [x1, y6]
function map.cycle_tile(self, x, y)

    local tiles_per_row = math.ceil(self.width / 50)
    local tiles_per_col = math.ceil(self.height / 50)
    assert(tiles_per_col == 30)

    local target_left = math.floor(x / 50)
    local target_top = math.floor(y / 50)

    local i = 1 + (target_left * (tiles_per_col + 1)) + (target_top)
    assert(math.abs(self.background_tiles[i].left - x) < 51, "found tile with x: " .. self.background_tiles[i].left .. " but clicked x:" .. x)

    if self.background_tiles[i].image == "sand" then
            self.background_tiles[i].image = "grass2"
        elseif self.background_tiles[i].image == "grass2" then
            self.background_tiles[i].image = "grass1"
        elseif self.background_tiles[i].image == "grass1" then
            self.background_tiles[i].image = "grassbeach1"
        elseif self.background_tiles[i].image == "grassbeach1" then
            self.background_tiles[i].image = "grassbeach2"
        elseif self.background_tiles[i].image == "grassbeach2" then
            self.background_tiles[i].image = "grassbeach3"
        elseif self.background_tiles[i].image == "grassbeach3" then
            self.background_tiles[i].image = "grassbeach4"
        elseif self.background_tiles[i].image == "grassbeach4" then
            self.background_tiles[i].image = "grassbeach5"
        elseif self.background_tiles[i].image == "grassbeach5" then
            self.background_tiles[i].image = "grassbeach6"
        elseif self.background_tiles[i].image == "grassbeach6" then
            self.background_tiles[i].image = "grassbeach7"
        elseif self.background_tiles[i].image == "grassbeach7" then
            self.background_tiles[i].image = "grassbeach8"
        else
            self.background_tiles[i].image = "sand"
    end
end

function map.save_tiles_as_hardcode(self, filename, gameobjects)

    assert(filename ~= nil)

    local file = io.open(filename, "w")

    assert(file ~= nil)


    for i = 1, #self.background_tiles, 1 do
        if map.background_tiles[i].image ~= "sand" then
            file:write('map.background_tiles[' .. i .. '].image = "' .. map.background_tiles[i].image .. '"\n')
        end
    end

    for i = 1, #gameobjects, 1 do
        if gameobjects[i].max_speed == 0 then

            file:write('map.gameobjects[#map.gameobjects + 1] = {}\n')
            file:write('map.gameobjects[#map.gameobjects].sprite_frame = "' .. gameobjects[i].sprite_frame .. '"\n')
            file:write('map.gameobjects[#map.gameobjects].size_modifier = "' .. gameobjects[i].size_modifier .. '"\n')
            file:write('map.gameobjects[#map.gameobjects].x = "' .. gameobjects[i].x .. '"\n')
            file:write('map.gameobjects[#map.gameobjects].y = "' .. gameobjects[i].y .. '"\n')
            file:write('map.gameobjects[#map.gameobjects].weight = "' .. gameobjects[i].weight .. '"\n')
            file:write('map.gameobjects[#map.gameobjects].angle = "' .. gameobjects[i].angle .. '"\n')
        
        end
    end

    io.close(file)

end


return map