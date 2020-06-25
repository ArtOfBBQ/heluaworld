object = require("modules.object")

-- stats_to_corner_coordinates(obj_x, obj_y, obj_width, obj_height, obj_angle)
describe("We can keep the radians of a given angle property between 0 and 6.28...", function()

    local test_tank = object:new()
    it("Should throw when passed a nil property.", function()
        assert.has_error(function()
            test_tank.angle = 0.5
            test_tank:fix_radians_bounds(nil)
        end, "Expected name of angle property to fix, got nil.")
    end)
    it("Should throw when passed a nonexistent property.", function()
        assert.has_error(function()
            test_tank.angle = 0.5
            test_tank:fix_radians_bounds("sexy_hip_angle")
        end, "sexy_hip_angle is not a property, can't fix radians bounds.")
    end)

    it("Should leave radians untouched when it's already a valid 0.5", function()
        test_tank.angle = 0.5
        test_tank:fix_radians_bounds("angle")
        assert.are_equal(test_tank.angle, 0.5)
    end)
    it("Should leave radians untouched when it's already a valid 6.1", function()
        test_tank.angle = 6.1
        test_tank:fix_radians_bounds("angle")
        assert.are_equal(test_tank.angle, 6.1)
    end)
    it("Should update radians to 0.2 when it's 6.48", function()
        test_tank.angle = 6.48319
        test_tank:fix_radians_bounds("angle")
        assert.is_true(test_tank.angle < 0.201 and test_tank.angle > 0.199)
    end)
    it("Should update radians to 6.08 when it's -0.2", function()
        test_tank.angle = -0.2
        test_tank:fix_radians_bounds("angle")
        assert.is_true(test_tank.angle > 6.08 and test_tank.angle < 6.084, "Expected test_tank.angle to be about 6.08, was " .. test_tank.angle)
    end)
end)
