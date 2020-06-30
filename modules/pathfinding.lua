pathfinding = {}

local open_nodes = {}
local closed_nodes = {}
local neighboring_nodes = {}
local i_pathfinder = 1  -- We only handle 1 object each game loop

local i_cur_tile = nil
local i_target_tile = nil

function pathfinding.reverse_table_inplace(table_to_reverse)

    if table_to_reverse == nil then
        error("Expected table to reverse, got nil.")
    end
    if type(table_to_reverse) ~= "table" then
        error("Expected table to reverse, got " .. type(table_to_reverse) .. ".")
    end

    for i = 1, math.floor(#table_to_reverse / 2), 1 do
        local j = (#table_to_reverse + 1) - i
        local temp = table_to_reverse[i]
        table_to_reverse[i] = table_to_reverse[j]
        table_to_reverse[j] = temp
    end
end

function pathfinding.move_index_from_table_to_table(
    table1,
    table2,
    i_in_table1)

    table2[#table2 + 1] = table1[i_in_table1]

    if i_in_table1 == #table1 then
        table1[i_in_table1] = nil
    else
        -- we moved an item from the middle of table1,
        -- so now we have an unwanted nil value somewhere in the middle
        table1[i_in_table1] = nil
        table1[i_in_table1] = table1[#table1]
        table1[#table1] = nil
    end
end

function pathfinding.distance_between_points(x1, y1, x2, y2)

    return math.sqrt(((x1 - x2) ^ 2) + ((y1 - y2) ^ 2))

end

-- fills out the field "contains_obstacle" for each background_tile
-- on the map. We don't need to do this every game update.
function pathfinding.update_map_tiles_contains_obstacle(map)

    for i = 1, #map.background_tiles, 1 do

        map.background_tiles[i].contains_obstacle = nil

        for j = 1, #gameobjects, 1 do
            if gameobjects[j].max_speed == 0 then
                for _, property_names in
                    pairs({
                        {"x", "y"}, {"topleft_x", "topleft_y"},
                        {"topright_x", "topright_y"},
                        {"bottomleft_x", "bottomright_y"},
                        {"bottomright_x", "bottomright_y"}
                    }) do
                    if collision.point_collides_unrotated_rectangle(
                        gameobjects[j][property_names[1]],
                        gameobjects[j][property_names[2]],
                        map.background_tiles[i].left,
                        map.background_tiles[i].top,
                        map.background_tiles[i].width,
                        map.background_tiles[i].height) then

                        map.background_tiles[i].contains_obstacle = true
                    end
                end
            end
        end

        if map.background_tiles[i]["contains_obstacle"] == nil then
            map.background_tiles.contains_obstacle = false
        end

    end
end

function pathfinding.get_direct_neighbor_tile_indexes(i_tile,
    tiles_per_row,
    tiles_per_col)

    local return_values = {}

    local is_in_row_one = (i_tile % tiles_per_col) == 1
    local is_in_col_one = i_tile <= tiles_per_row

    local is_in_final_col = i_tile >=
                                ((tiles_per_row * tiles_per_col) - tiles_per_col)
    local is_in_final_row = i_tile % tiles_per_col == 0

    -- directly left
    if is_in_col_one == false then
        return_values[#return_values + 1] = i_tile - tiles_per_col
    end

    -- directly above
    if is_in_row_one == false then
        return_values[#return_values + 1] = i_tile - 1
    end

    -- directly to the right
    if is_in_final_col == false then
        return_values[#return_values + 1] = i_tile + tiles_per_row
    end

    -- directly below
    if is_in_final_row == false then
        return_values[#return_values + 1] = i_tile + 1
    end

    return return_values
end

function pathfinding.get_diagonal_neighbor_tile_indexes(i_tile,
    tiles_per_row,
    tiles_per_col)

    local return_values = {}

    local is_in_row_one = (i_tile % tiles_per_col) == 1
    local is_in_col_one = i_tile <= tiles_per_row

    local is_in_final_col = i_tile >=
                                ((tiles_per_row * tiles_per_col) - tiles_per_col)
    local is_in_final_row = i_tile % tiles_per_col == 0

    -- left above
    if is_in_col_one == false and is_in_row_one == false then
        return_values[#return_values + 1] = i_tile - tiles_per_col - 1
    end

    -- right above
    if is_in_final_col == false and is_in_row_one == false then
        return_values[#return_values + 1] = i_tile + tiles_per_col - 1
    end

    -- left below
    if is_in_final_row == false and is_in_col_one == false then
        return_values[#return_values + 1] = i_tile - tiles_per_col + 1
    end

    -- right below
    if is_in_final_row == false and is_in_final_col == false then
        return_values[#return_values + 1] = i_tile + tiles_per_row + 1
    end

    return return_values
end

-- Given an index in map.background_tiles, return a table
-- with each index of the neighboring tiles
function pathfinding.get_neighbor_tile_indexes(i_tile,
    tiles_per_row,
    tiles_per_col)

    local straight = pathfinding.get_direct_neighbor_tile_indexes(i_tile,
        tiles_per_row, tiles_per_col)

    local diagonal = pathfinding.get_diagonal_neighbor_tile_indexes(i_tile,
        tiles_per_row, tiles_per_col)

    for i = 1, #diagonal, 1 do straight[#straight + 1] = diagonal[i] end

    return straight

end

-- Given a table of tables, return the element with the lowest value
-- of some property or set of properties. The smallest properties_to_compare[1]
-- will be returned, and properties_to_compare[2] will be used in case of a tie, etc.
function pathfinding.find_lowest_in_nodelist(nodelist,
    properties_to_compare)

    if type(nodelist) ~= "table" then
        error("Expected a table of nodes to compare, got " .. type(nodelist))
    end

    if type(properties_to_compare) ~= "table" then
        error("Expected a table of properties to compare, got " ..
                  type(properties_to_compare))
    end

    -- find node with lowest fcost in nodelist
    lowest_node = nil
    for i = 1, #nodelist, 1 do
        if nodelist[i][properties_to_compare[1]] == nil then
            error("Property to compare: " .. properties_to_compare[1] ..
                      " wasn't found in node " .. i .. "!")
        end

        if nodelist[i] ~= nil and lowest_node == nil then
            lowest_node = i
        elseif nodelist[i] ~= nil and nodelist[i][properties_to_compare[1]] <
            nodelist[lowest_node][properties_to_compare[1]] then
            lowest_node = i
        else
            if #properties_to_compare > 1 then

                if nodelist[i] ~= nil and nodelist[i][properties_to_compare[1]] <=
                    nodelist[lowest_node][properties_to_compare[1]] and
                    nodelist[i][properties_to_compare[2]] <
                    nodelist[lowest_node][properties_to_compare[2]] then
                        lowest_node = i
                elseif nodelist[i] ~= nil and nodelist[i][properties_to_compare[1]] ==
                    nodelist[lowest_node][properties_to_compare[1]] and
                    nodelist[i][properties_to_compare[2]] ==
                    nodelist[lowest_node][properties_to_compare[2]] then
                        if math.random() > 0.5 then lowest_node = i end
                end

            end
        end
    end

    return lowest_node
end

function pathfinding.request_fill_waypoints(gameobject, target_x, target_y)

    request_queue[#request_queue + 1] = {i_obj = gameobject.id, target_x = target_x, target_y = target_y}

end

function pathfinding.set_one_path()

    assert(i_pathfinder ~= nil)

    if i_pathfinder >= #gameobjects then
        i_pathfinder = 1
    else
        i_pathfinder = i_pathfinder + 1
    end

    assert(gameobjects[i_pathfinder] ~= nil, "couldn't find i_pathfinder " .. i_pathfinder .. " in gameobjects with #gameobjects being " .. #gameobjects)
    if gameobjects[i_pathfinder]["goal_x"] ~= nil and gameobjects[i_pathfinder]["goal_y"] ~= nil and gameobjects[i_pathfinder].max_speed > 0 then
        pathfinding.fill_waypoints(gameobjects[i_pathfinder])
    end
end

-- given a final destination,
-- find a path to it and set the waypoints of the gameobject accordingly
-- the driver module will send him there if we only set the waypoints correctly
function pathfinding.fill_waypoints(gameobject)

    i_cur_tile = map:coords_to_tile(gameobject.goal_x, gameobject.goal_y)
    i_target_tile = map:coords_to_tile(gameobject.x, gameobject.y)

    open_nodes = {
        {
            i_tile = i_cur_tile,
            i_closed_nodes_parent = nil,
            hcost = pathfinding.distance_between_points(
                map.background_tiles[i_cur_tile].left + (map.tile_width / 2),
                map.background_tiles[i_cur_tile].top + (map.tile_height / 2),
                gameobject.x,
                gameobject.y),
            gcost = 0
        }
    }
    open_nodes[1].fcost = open_nodes[1].gcost + open_nodes[1].hcost

    closed_nodes = {}

    repeat pathfinding.single_astar_step(gameobject, gameobject.target_x, gameobject.target_y) until #closed_nodes >
        500 or #open_nodes < 1 or (gameobject.waypoints ~=nil
        and gameobject.waypoints[#gameobject.waypoints] ~= nil and gameobject.waypoints[#gameobject.waypoints].x == gameobject.goal_x
        and gameobject.waypoints[#gameobject.waypoints].y == gameobject.goal_y)
end

-- this is the "a-star" path-finding algorithm
-- almost as described in this youtube video:
-- https://www.youtube.com/watch?v=-L-WgKMFuhE&t=207s
function pathfinding.single_astar_step(gameobject, target_x, target_y)

    i_cur_tile = pathfinding.find_lowest_in_nodelist(open_nodes,
        {"fcost", "gcost"})
    pathfinding.move_index_from_table_to_table(open_nodes, closed_nodes,
        i_cur_tile)
    i_cur_tile = #closed_nodes

    -- check if we've found the correct answer
    if closed_nodes[i_cur_tile].i_tile == i_target_tile then

        gameobject.waypoints = {}
        while closed_nodes[i_cur_tile].i_closed_nodes_parent ~= nil do
            i_cur_tile = closed_nodes[i_cur_tile].i_closed_nodes_parent
            gameobject.waypoints[#gameobject.waypoints + 1] =
                {
                    x = map.background_tiles[closed_nodes[i_cur_tile].i_tile]
                        .left + 25,
                    y = map.background_tiles[closed_nodes[i_cur_tile].i_tile]
                        .top + 25
                }
        end
        -- we need to reverse the order of the waypoints if there are 2 or more
        if #gameobject.waypoints > 1 then
            pathfinding.reverse_table_inplace(gameobject.waypoints)
        end
        return
    end

    local direct_neighbors_contain_obstacle = false
    local direct_neighbors = pathfinding.get_direct_neighbor_tile_indexes(
        closed_nodes[i_cur_tile].i_tile, map.width / map.tile_width,
        map.height / map.tile_height)
    for i = 1, #direct_neighbors, 1 do
        if map.background_tiles[direct_neighbors[i]].contains_obstacle then
            direct_neighbors_contain_obstacle = true
        end
    end

    if direct_neighbors_contain_obstacle then
        neighboring_nodes = direct_neighbors
    else
        neighboring_nodes = pathfinding.get_neighbor_tile_indexes(
            closed_nodes[i_cur_tile].i_tile, map.width / map.tile_width,
            map.height / map.tile_height)
    end

    -- make sure the neighbor is eligible
    -- 1. it can't contain an obstacle
    local i = #neighboring_nodes
    repeat
        if map.background_tiles[neighboring_nodes[i]].contains_obstacle == true then
            table.remove(neighboring_nodes, i)
        end

        i = i - 1
    until i == 0

    -- 2. It can't, if we're moving diagonally, be surrounded by obstacles
    -- if T is target, N is neighbor, and O is obstacle,
    --
    -- T O
    -- O N
    -- The above is a bad pattern, because moving from N to T will probably be impossible

    -- 3. it can't be in closed_nodes (already evaluated)
    local i = #neighboring_nodes
    repeat
        assert(neighboring_nodes[i] ~= nil, "i was: " .. i ..
            ", #neighboring_nodes was: " .. #neighboring_nodes)
        assert(map.background_tiles[neighboring_nodes[i]] ~= nil)
        for j = 1, #closed_nodes, 1 do
            if closed_nodes[j].i_tile == neighboring_nodes[i] then

                table.remove(neighboring_nodes, i)
            end
        end

        i = i - 1
    until i == 0

    -- calculate costs for each remaining neighbor
    for i = 1, #neighboring_nodes, 1 do

        neighboring_nodes[i] = {
            i_tile = neighboring_nodes[i],
            i_closed_nodes_parent = i_cur_tile
        }

        neighboring_nodes[i]["hcost"] = pathfinding.distance_between_points(
            map.background_tiles[neighboring_nodes[i].i_tile].left +
                (map.tile_width / 2), map.background_tiles[neighboring_nodes[i]
                .i_tile].top + (map.tile_height / 2), gameobject.x, gameobject.y)

        neighboring_nodes[i]["gcost"] = pathfinding.distance_between_points(
            map.background_tiles[neighboring_nodes[i].i_tile].left +
                (map.tile_width / 2), map.background_tiles[neighboring_nodes[i]
                .i_tile].top + (map.tile_height / 2),
            map.background_tiles[closed_nodes[i_cur_tile].i_tile].left +
                (map.tile_width / 2),
            map.background_tiles[closed_nodes[i_cur_tile].i_tile].top +
                (map.tile_height / 2)) + closed_nodes[i_cur_tile].gcost

        neighboring_nodes[i]["fcost"] = neighboring_nodes[i].gcost +
                                            neighboring_nodes[i].hcost
    end

    -- check if the neighbor was already in the list of open_nodes nodes
    -- if it was already in, overwrite it if the path to it is shorter than previously recorded
    -- if it wasn't in yet, add it
    for i = 1, #neighboring_nodes, 1 do
        local i_in_open_nodes = nil
        for j = 1, #open_nodes, 1 do
            if open_nodes[j].i_tile == neighboring_nodes[i].i_tile then
                if open_nodes[j].gcost > neighboring_nodes[i].gcost then
                    i_in_open_nodes = j
                else
                    i_in_open_nodes = -1
                end
            end
        end

        i_in_open_nodes = i_in_open_nodes or (#open_nodes + 1)

        if i_in_open_nodes ~= -1 then
            open_nodes[i_in_open_nodes] = neighboring_nodes[i]
        end
    end
end

return pathfinding
