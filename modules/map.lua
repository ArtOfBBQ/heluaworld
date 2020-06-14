map = {
    width = 1500,
    height = 1500,
    background_tiles = {}
}


for i = 0, map.width, 50 do
    for j = 0, map.height, 50 do
        
        local cur_image = "sand"
        
        map.background_tiles[#map.background_tiles + 1] = 
        {
            left = i,
            top = j,
            width = 50,
            height = 50,
            image = cur_image
        }

    end
end

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


return map
