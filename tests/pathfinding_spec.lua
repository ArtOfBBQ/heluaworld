pathfinding = require("modules.pathfinding")

map = {}

describe("We can reverse the order of elements of a table in-place.", function()
    it("Should throw when passed nil.", function()
        assert.has_error(function()
            pathfinding.reverse_table_inplace(nil)
        end, "Expected table to reverse, got nil.")
    end)
    it("Should throw when passed a number.", function()
        assert.has_error(function() pathfinding.reverse_table_inplace(5) end,
            "Expected table to reverse, got number.")
    end)
    it("Should throw when passed a number.", function()
        assert.has_error(function()
            pathfinding.reverse_table_inplace("hello")
        end, "Expected table to reverse, got string.")
    end)
    it("Works with 1 element.", function()
        local reversable_table = {1}
        pathfinding.reverse_table_inplace(reversable_table)
        assert.are_same(reversable_table, {1})
    end)
    it("Works with 2 elements.", function()
        local reversable_table = {4, 3}
        pathfinding.reverse_table_inplace(reversable_table)
        assert.are_same(reversable_table, {3, 4})
    end)
    it("Works with 3 elements.", function()
        local reversable_table = {2, 57, 12}
        pathfinding.reverse_table_inplace(reversable_table)
        assert.are_same(reversable_table, {12, 57, 2})
    end)
    it("Works with 4 elements.", function()
        local reversable_table = {"hello", "i", "am", "jelle"}
        pathfinding.reverse_table_inplace(reversable_table)
        assert.are_same(reversable_table, {"jelle", "am", "i", "hello"})
    end)
end)

describe("We can calculate the distance between 2 points.", function()
    describe("Distance between points [2, 2] and [4, 4] should be about 2.82.",
        function()
            it(
                "Therefore distance_between_points(2, 2, 4, 4) > 2.81 should be true.",
                function()
                    assert.is_true(pathfinding.distance_between_points(2, 2, 4,
                        4) > 2.81)
                end)
            it(
                "Therefore distance_between_points(2, 2, 4, 4) < 2.83 should be true.",
                function()
                    assert.is_true(pathfinding.distance_between_points(2, 2, 4,
                        4) < 2.83)
                end)
        end)

    describe("Distance between points [2, 8] and [3, -2] should be about 10.05",
        function()
            it(
                "Therefore distance_between_points(2, 8, 3, -2) > 10.04 should be true.",
                function()
                    assert.is_true(pathfinding.distance_between_points(2, 8, 3,
                        -2) > 10.04)
                end)
            it(
                "Therefore distance_between_points(2, 8, 3, -2) < 10.06 should be true.",
                function()
                    assert.is_true(pathfinding.distance_between_points(2, 8, 3,
                        -2) < 10.06)
                end)
        end)
end)

describe("We can move an item from one table to another.", function()
    describe("We can move the 2nd element from {1, 2} to {3, 4}", function()
        it("", function()
            local table1 = {1, 2}
            local table2 = {3, 4}
            pathfinding.move_index_from_table_to_table(table1, table2, 2)
            assert.is_same(table1, {1})
            assert.is_same(table2, {3, 4, 2})
        end)
    end)
    describe("We can move the 1st element from {1, 2} to {3, 4}", function()
        it("", function()
            local table1 = {1, 2}
            local table2 = {3, 4}
            pathfinding.move_index_from_table_to_table(table1, table2, 1)
            assert.is_same(table1, {2})
            assert.is_same(table2, {3, 4, 1})
        end)
    end)
    describe("We can move the 2nd element from {1, 2, 3} to {5, 6}", function()
        it("", function()
            local table1 = {1, 2, 3}
            local table2 = {5, 6}
            pathfinding.move_index_from_table_to_table(table1, table2, 2)
            assert.is_same(table1, {1, 3})
            assert.is_same(table2, {5, 6, 2})
        end)
    end)
end)

describe("The neighboring tiles of a given map tile index can be found.",
    function()
        it("get_neighbor_tile_indexes() should always return a table.",
            function()
                assert.are_equal(type(pathfinding.get_neighbor_tile_indexes(1,
                    10, 10)), "table")
            end)
        describe(
            "Tile 1 on a 10x10 map should have only 3 neighboring tiles; (1) below, (2) below & right, and (3) to the right.",
            function()
                it("We should have 3 indexes in our result.", function()
                    assert.are_equal(#(pathfinding.get_neighbor_tile_indexes(1,
                        10, 10)), 3)
                end)
                it("Tile 2 (directly below 1) should be 1 of our 3 results.",
                    function()
                        local result = pathfinding.get_neighbor_tile_indexes(1,
                            10, 10)
                        local result_included_2 = false
                        for i = 1, #result, 1 do
                            if result[i] == 2 then
                                result_included_2 = true
                            end
                        end
                        assert.is_true(result_included_2)
                    end)
                it(
                    "Tile 11 (directly to the right of 1) should be 1 of our 3 results.",
                    function()
                        local result = pathfinding.get_neighbor_tile_indexes(1,
                            10, 10)
                        local result_included_11 = false
                        for i = 1, #result, 1 do
                            if result[i] == 11 then
                                result_included_11 = true
                            end
                        end
                        assert.is_true(result_included_11)
                    end)
                it("Tile 12 (below-right of 1) should be 1 of our 3 results.",
                    function()
                        local result = pathfinding.get_neighbor_tile_indexes(1,
                            10, 10)
                        local result_included_12 = false
                        for i = 1, #result, 1 do
                            if result[i] == 12 then
                                result_included_12 = true
                            end
                        end
                        assert.is_true(result_included_12)
                    end)
            end)

        describe(
            "Tile 2 on a 10x10 map should have only 5 neighboring tiles; (1) above, (2) above & right, (3) to the right, (4) below & right, and (5) below.",
            function()
                it("We should have 3 indexes in our result.", function()
                    assert.are_equal(#(pathfinding.get_neighbor_tile_indexes(2,
                        10, 10)), 5)
                end)
                it("Tile 1 (directly above 2) should be 1 of our 5 results.",
                    function()
                        local result = pathfinding.get_neighbor_tile_indexes(2,
                            10, 10)
                        local result_included_1 = false
                        for i = 1, #result, 1 do
                            if result[i] == 1 then
                                result_included_1 = true
                            end
                        end
                        assert.is_true(result_included_1)
                    end)
                it("Tile 11 (above-right of 2) should be 1 of our 5 results.",
                    function()
                        local result = pathfinding.get_neighbor_tile_indexes(2,
                            10, 10)
                        local result_included_11 = false
                        for i = 1, #result, 1 do
                            if result[i] == 11 then
                                result_included_11 = true
                            end
                        end
                        assert.is_true(result_included_11)
                    end)
                it("Tile 12 (right of 2) should be 1 of our 5 results.",
                    function()
                        local result = pathfinding.get_neighbor_tile_indexes(2,
                            10, 10)
                        local result_included_12 = false
                        for i = 1, #result, 1 do
                            if result[i] == 12 then
                                result_included_12 = true
                            end
                        end
                        assert.is_true(result_included_12)
                    end)
                it("Tile 13 (below-right of 2) should be 1 of our 5 results.",
                    function()
                        local result = pathfinding.get_neighbor_tile_indexes(2,
                            10, 10)
                        local result_included_13 = false
                        for i = 1, #result, 1 do
                            if result[i] == 13 then
                                result_included_13 = true
                            end
                        end
                        assert.is_true(result_included_13)
                    end)
                it("Tile 3 (below 2) should be 1 of our 5 results.", function()
                    local result = pathfinding.get_neighbor_tile_indexes(2, 10,
                        10)
                    local result_included_3 = false
                    for i = 1, #result, 1 do
                        if result[i] == 3 then
                            result_included_3 = true
                        end
                    end
                    assert.is_true(result_included_3)
                end)
            end)

        describe("We can detect the cheapest fcost open node.", function()

            describe("Throws with incorrect inputs.", function()

                it(
                    "Throws when it got a string, not a table of strings as properties to compare",
                    function()

                        assert.has_error(
                            function()
                                pathfinding.find_lowest_in_nodelist(
                                    {{fcost = 2}, {fcost = 1}}, "fcost")
                            end,
                            "Expected a table of properties to compare, got string")
                    end)
                it(
                    "Throws when it got a number, not a table of strings as properties to compare",
                    function()

                        assert.has_error(
                            function()
                                pathfinding.find_lowest_in_nodelist(
                                    {{fcost = 2}, {fcost = 1}}, 5)
                            end,
                            "Expected a table of properties to compare, got number")
                    end)
                it("Throws when it got a number, not a table of nodes",
                    function()

                        assert.has_error(
                            function()
                                pathfinding.find_lowest_in_nodelist(5, {"fcost"})
                            end,
                            "Expected a table of nodes to compare, got number")
                    end)

            end)

            describe("With 1 property to compare.", function()
                it("returns 2 from {{2}, {1}", function()
                    local result = pathfinding.find_lowest_in_nodelist(
                        {{fcost = 2}, {fcost = 1}}, {"fcost"})
                    assert.is_same(result, 2)
                end)
                it("returns 1 from {{1}, {2}", function()
                    local result = pathfinding.find_lowest_in_nodelist(
                        {{fcost = 1}, {fcost = 2}}, {"fcost"})
                    assert.is_same(result, 1)
                end)
            end)

            describe("With 2 properties to compare.", function()
                it("returns 2 from {{2}, {1}", function()
                    local result = pathfinding.find_lowest_in_nodelist(
                        {{fcost = 2, gcost = 10}, {fcost = 1, gcost = 12}},
                        {"fcost", "gcost"})
                    assert.is_same(result, 2)
                end)
                it("returns 1 from {{2}, {2} because of the tiebreaker",
                    function()
                        local result = pathfinding.find_lowest_in_nodelist(
                            {{fcost = 40, gcost = 10}, {fcost = 40, gcost = 12}},
                            {"fcost", "gcost"})
                        assert.is_same(result, 1)
                    end)
                it("returns 2 from {{2}, {2} because of the tiebreaker",
                    function()
                        local result = pathfinding.find_lowest_in_nodelist(
                            {{fcost = 40, gcost = 14}, {fcost = 40, gcost = 12}},
                            {"fcost", "gcost"})
                        assert.is_same(result, 2)
                    end)
            end)

        end)

    end)

