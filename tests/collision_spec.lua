collision = require('modules.collision')

-- WARNING!!! This function uses top and left of the rectangle, not the x and y center
-- collision.point_collides_unrotated_rectangle(x, y, rect_left, rect_top, rect_width, rect_height)
describe("We can detect if a point is in an unrotated rectangle or not.",
    function()

        describe("Throws when passed nil values", function()
            it("Should throw when passed a nil x-coordinate.", function()
                assert.has_error(function()
                    collision.point_collides_unrotated_rectangle(nil, 20, 10,
                        40, 100, 100)
                end, "Expected x-coordinate to check, got nil.")
            end)
            it("Should throw when passed a nil y-coordinate.", function()
                assert.has_error(function()
                    collision.point_collides_unrotated_rectangle(15, nil, 10,
                        40, 100, 100)
                end, "Expected y-coordinate to check, got nil.")
            end)
            it("Should throw when passed a nil rectangle left.", function()
                assert.has_error(function()
                    collision.point_collides_unrotated_rectangle(15, 20, nil,
                        40, 100, 100)
                end, "Expected left of rectangle to check, got nil.")
            end)
            it("Should throw when passed a nil rectangle top.", function()
                assert.has_error(function()
                    collision.point_collides_unrotated_rectangle(15, 20, 40,
                        nil, 100, 100)
                end, "Expected top of rectangle to check, got nil.")
            end)
            it("Should throw when passed a nil rectangle width.", function()
                assert.has_error(function()
                    collision.point_collides_unrotated_rectangle(15, 20, 40,
                        100, nil, 100)
                end, "Expected width of rectangle to check, got nil.")
            end)
            it("Should throw when passed a nil rectangle height.", function()
                assert.has_error(function()
                    collision.point_collides_unrotated_rectangle(15, 20, 40,
                        100, 100, nil)
                end, "Expected height of rectangle to check, got nil.")
            end)
        end)

        describe("Returns true when the point lies inside of the rectangle",
            function()
                it("[20, 20] lies inside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_true(
                            collision.point_collides_unrotated_rectangle(20, 20,
                                10, 10, 50, 50))
                    end)
                it("[10, 20] lies inside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_true(
                            collision.point_collides_unrotated_rectangle(10, 20,
                                10, 10, 50, 50))
                    end)
                it("[10, 10] lies inside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_true(
                            collision.point_collides_unrotated_rectangle(10, 10,
                                10, 10, 50, 50))
                    end)
                it("[60, 45] lies inside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_true(
                            collision.point_collides_unrotated_rectangle(60, 45,
                                10, 10, 50, 50))
                    end)
                it("[60, 60] lies inside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_true(
                            collision.point_collides_unrotated_rectangle(60, 60,
                                10, 10, 50, 50))
                    end)
                it("[60, 70] lies inside rectangle [10, 10, 50, 60].",
                    function()
                        assert.is_true(
                            collision.point_collides_unrotated_rectangle(60, 70,
                                10, 10, 50, 60))
                    end)
            end)

        describe("Returns false when the point lies inside of the rectangle",
            function()
                it("[20, 5] lies outside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_false(
                            collision.point_collides_unrotated_rectangle(20, 5,
                                10, 10, 50, 50))
                    end)
                it("[9, 20] lies outside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_false(
                            collision.point_collides_unrotated_rectangle(9, 20,
                                10, 10, 50, 50))
                    end)
                it("[10, 9] lies outside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_false(
                            collision.point_collides_unrotated_rectangle(10, 9,
                                10, 10, 50, 50))
                    end)
                it("[10, 61] lies outside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_false(
                            collision.point_collides_unrotated_rectangle(10, 61,
                                10, 10, 50, 50))
                    end)
                it("[61, 60] lies outside rectangle [10, 10, 50, 50].",
                    function()
                        assert.is_false(
                            collision.point_collides_unrotated_rectangle(61, 60,
                                10, 10, 50, 50))
                    end)
                it("[60, 71] lies outside rectangle [10, 10, 50, 60].",
                    function()
                        assert.is_false(
                            collision.point_collides_unrotated_rectangle(60, 71,
                                10, 10, 50, 60))
                    end)
            end)
    end)

-- WARNING!!! This function uses the center (x, y) of the rectangle, not the top and left as before
-- collision.point_collides_rotated_rectangle(x, y, rect_x, rect_y, rect_width, rect_height, rect_angle)
describe("We can detect if a point is in an rotated rectangle or not.",
    function()

        describe("Throws when passed nil values", function()
            it("Should throw when passed a nil x.", function()
                assert.has_error(function()
                    collision.point_collides_rotated_rectangle(nil, 20, 10, 40,
                        100, 100, 1.5)
                end, "Expected x-coordinate to check, got nil.")
            end)
            it("Should throw when passed a nil y.", function()
                assert.has_error(function()
                    collision.point_collides_rotated_rectangle(20, nil, 10, 40,
                        100, 100, 1.5)
                end, "Expected y-coordinate to check, got nil.")
            end)
            it("Should throw when passed a nil rect_x.", function()
                assert.has_error(function()
                    collision.point_collides_rotated_rectangle(20, 20, nil, 40,
                        100, 100, 1.5)
                end, "Expected x (middle) of rectangle to check, got nil.")
            end)
            it("Should throw when passed a nil rect_y", function()
                assert.has_error(function()
                    collision.point_collides_rotated_rectangle(20, 20, 10, nil,
                        100, 100, 1.5)
                end, "Expected y (middle) of rectangle to check, got nil.")
            end)
            it("Should throw when passed a nil rect_width", function()
                assert.has_error(function()
                    collision.point_collides_rotated_rectangle(20, 20, 10, 40,
                        nil, 100, 1.5)
                end, "Expected width of rectangle to check, got nil.")
            end)
            it("Should throw when passed a nil rect_height", function()
                assert.has_error(function()
                    collision.point_collides_rotated_rectangle(20, 20, 10, 40,
                        100, nil, 1.5)
                end, "Expected height of rectangle to check, got nil.")
            end)
            it("Should throw when passed a nil rect_angle", function()
                assert.has_error(function()
                    collision.point_collides_rotated_rectangle(20, 20, 10, 40,
                        100, 100, nil)
                end, "Expected angle of rectangle to check, got nil.")
            end)
        end)

        describe("Returns true when the point lies inside of the rectangle",
            function()
                it(
                    "[20, 20] lies inside rectangle [10, 10, 50, 50] regardless of rotation.",
                    function()
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(20, 20,
                                10, 10, 50, 50, 0))
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(20, 20,
                                10, 10, 50, 50, 0.5))
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(20, 20,
                                10, 10, 50, 50, 1))
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(20, 20,
                                10, 10, 50, 50, 1.5))
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(20, 20,
                                10, 10, 50, 50, 2))
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(20, 20,
                                10, 10, 50, 50, 3))
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(20, 20,
                                10, 10, 50, 50, 4))
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(20, 20,
                                10, 10, 50, 50, 5))
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(20, 20,
                                10, 10, 50, 50, 6.27))
                    end)
                it(
                    "[60, 60] lies inside rectangle [67.52, 74.4, 15.04, 28.8] at angle 0, because top left is 60, 60, but strays outside as the rectangle rotates.",
                    function()
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(60, 60,
                                67.52, 74.4, 15.04, 28.8, 0)) -- very close
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(60.5,
                                60.5, 67.52, 74.4, 15.04, 28.8, 0)) -- very close

                        assert.is_false(
                            collision.point_collides_rotated_rectangle(60, 60,
                                67.52, 74.4, 15.04, 28.8, 0.5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(60, 60,
                                67.52, 74.4, 15.04, 28.8, 1)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(60, 60,
                                67.52, 74.4, 15.04, 28.8, 1.5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(60, 60,
                                67.52, 74.4, 15.04, 28.8, 1.9)) -- confirmed visually
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(60.1,
                                60.1, 67.52, 74.4, 15.04, 28.8, 3.14)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(60.1,
                                60.1, 67.52, 74.4, 15.04, 28.8, 4)) -- confirmed visually
                    end)
                it(
                    "[60, 60] rotated to 0.5 becomes [52.175, 61.84] is outside rectangle [67.52, 74.4, 15.04, 28.8] at all angles.",
                    function()
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 0)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 0.5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 1)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 1.5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 2)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 2.5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 3)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 3.5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 4)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 4.5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 5.5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(52.175,
                                61.84, 67.52, 74.4, 15.04, 28.8, 6)) -- confirmed visually
                    end)
                it(
                    "[82.52, 88.8] tested against a buggy at [95, 100] will collide on many angles and miss on many others.",
                    function()
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 0.5)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 0.6)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 0.7)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 0.9)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 1)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 1.1)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 1.3)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 1.45)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 1.55)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 1.6)) -- confirmed visually
                        assert.is_false(
                            collision.point_collides_rotated_rectangle(82.52,
                                88.8, 95, 100, 15.04, 28.8, 1.85)) -- very close
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(86.5,
                                92.78, 95, 100, 15.04, 28.8, 1.85)) -- clearly colliding
                        assert.is_true(
                            collision.point_collides_rotated_rectangle(86.52,
                                92.8, 95, 100, 15.04, 28.8, 1.85)) -- clearly colliding
                    end)
            end)
    end)
