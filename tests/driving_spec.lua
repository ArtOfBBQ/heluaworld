driving = require("modules.driver")

describe("We can find the shortest difference between 2 radians angles.", function()
    it("Should throw when passed nil.", function()
        assert.has_error(function()
            driver.get_diff_angles(nil, 3.14)
        end, "Expected 1st radians angle to calculate the difference for, got nil.")
        assert.has_error(function()
            driver.get_diff_angles(4.4, nil)
        end, "Expected 2nd radians angle to calculate the difference for, got nil.")
    end)
    it("Should throw when passed invalid radians angle.", function()
        assert.has_error(function()
            driver.get_diff_angles(8, 3.14)
        end, "Expected 1st radians angle (0 to 2x pi) to calculate the difference for, got 8.")
        assert.has_error(function()
            driver.get_diff_angles(2, -5)
        end, "Expected 2nd radians angle (0 to 2x pi) to calculate the difference for, got -5.")
    end)
    
    it("Diff between 3.28 and 3.14 should be 0.14.", function()
        local result = driver.get_diff_angles(3.28, 3.14)
        assert.is_true(result > 0.139 and result < 0.141, "Expected about 0.14, got " .. result)
    end)
    it("Diff between 3.14 and 3.28 should be about -0.14.", function()
        result = driver.get_diff_angles(3.14, 3.28)
        assert.is_true(result > -0.141 and result < -0.139, "Expected about -0.14, got " .. result)
    end)

    it("Diff between 0.1 and 6.28 should be about 0.1.", function()
        result = driver.get_diff_angles(0.1, 6.28)
        assert.is_true(result > 0.09 and result < 0.11, "Expected about 0.1, got " .. result)
    end)
    it("Diff between 6.28 and 0.1 should be about -0.1.", function()
        result = driver.get_diff_angles(6.28, 0.1)
        assert.is_true(result > -0.11 and result < -0.09, "Expected about -0.1, got " .. result)
    end)
end)

describe("We can find the ideal x-velocity given an angle to the goal.", function()
    it("Should throw when passed nil.", function()
        assert.has_error(function()
            driver.get_ideal_x_velocity(nil)
        end, "Expected radians angle to the goal, got nil.")
        assert.has_error(function()
            driver.get_ideal_x_velocity(8)
        end, "Expected radians angle to the goal, got 8.")
        assert.has_error(function()
            driver.get_ideal_x_velocity(-0.5)
        end, "Expected radians angle to the goal, got -0.5.")
    end)
    it("Should return 0 when we need to move to angle 0 (directly upwards).", function()
        assert.is_same(driver.get_ideal_x_velocity(0), 0)
    end)
    it("Should return 1 when we need to move to angle 1.57 (directly right).", function()
        assert.is_same(driver.get_ideal_x_velocity(math.pi / 2), 1)
    end)
    it("Should return about 0.7 when we need to move to angle 0.785 (right/up).", function()
        assert.is_same(driver.get_ideal_x_velocity(math.pi / 4), 0.70710678118654746172)
    end)
    it("Should return about 0.7 when we need to move to angle 2.356 (right/down).", function()
        assert.is_same(driver.get_ideal_x_velocity(math.pi * 0.75), 0.70710678118654757274)
    end)
    it("Should return about -0.7 when we need to move to angle 3.9269 (left/down).", function()
        assert.is_same(driver.get_ideal_x_velocity(math.pi * 1.25), -0.70710678118654746172)
    end)
    it("Should return about -0.7 when we need to move to angle 5.49778 (left/up).", function()
        assert.is_same(driver.get_ideal_x_velocity(math.pi * 1.75), -0.70710678118654768376)
    end)
end)

describe("We can find the ideal y-velocity given an angle to the goal.", function()
    it("Should throw when passed nil.", function()
        assert.has_error(function()
            driver.get_ideal_y_velocity(nil)
        end, "Expected radians angle to the goal, got nil.")
        assert.has_error(function()
            driver.get_ideal_y_velocity(8)
        end, "Expected radians angle to the goal, got 8.")
        assert.has_error(function()
            driver.get_ideal_y_velocity(-0.5)
        end, "Expected radians angle to the goal, got -0.5.")
    end)
    it("Should return -1 when we need to move to angle 0 (directly upwards).", function()
        assert.is_same(driver.get_ideal_y_velocity(0), -1)
    end)
    it("Should return 1 when we need to move to angle pi (directly downward).", function()
        assert.is_same(driver.get_ideal_y_velocity(math.pi), 1)
    end)
    it("Should return about 0 when we need to move to angle 1.57 (directly right).", function()
        result = driver.get_ideal_y_velocity(math.pi / 2)
        assert.is_true(
             result > -0.05 and result < 0.05, "expected y velocity of about 0, got " .. result)
    end)
    it("Should return about 0 when we need to move to angle 4.712 (directly left).", function()
        result = driver.get_ideal_y_velocity(math.pi * 1.5)
        assert.is_true(
             result > -0.05 and result < 0.05, "expected y velocity of about 0, got " .. result)
    end)
    it("Should return about -0.7 when we need to move to angle 0.785 (right/up).", function()
        assert.is_same(driver.get_ideal_y_velocity(math.pi / 4), -0.70710678118654757274)
    end)
    it("Should return about 0.7 when we need to move to angle 2.356 (right/down).", function()
        assert.is_same(driver.get_ideal_y_velocity(math.pi * 0.75), 0.70710678118654746172)
    end)
    it("Should return about 0.7 when we need to move to angle 3.9269 (left/down).", function()
        assert.is_same(driver.get_ideal_y_velocity(math.pi * 1.25), 0.70710678118654768376)
    end)
    it("Should return about -0.7 when we need to move to angle 5.49778 (left/up).", function()
        assert.is_same(driver.get_ideal_y_velocity(math.pi * 1.75), -0.70710678118654746172)
    end)
end)

describe("We can find a good rotation velocity given an angle and a goal angle.", function()
    it("Should return about 0 when the angle difference is 0.", function()
        assert.is_same(driver.get_ideal_rotation_velocity(0), 0)
    end)
    it("Should return a high value when the angle difference is bigger than 0.5", function()
        assert.is_same(driver.get_ideal_rotation_velocity(0.5), 0.009)
        assert.is_same(driver.get_ideal_rotation_velocity(1), 0.009)
        assert.is_same(driver.get_ideal_rotation_velocity(1.2), 0.009)
        assert.is_same(driver.get_ideal_rotation_velocity(-0.5), -0.009)
        assert.is_same(driver.get_ideal_rotation_velocity(-1), -0.009)
        assert.is_same(driver.get_ideal_rotation_velocity(-1.2), -0.009)
    end)
    it("Should return a lower value when the angle difference is smaller than 0.5", function()
        assert.is_true(driver.get_ideal_rotation_velocity(0.49) < 0.1)
        assert.is_true(driver.get_ideal_rotation_velocity(-0.49) > -0.1)
    end)
    it("Should return a much lower value when the angle difference is smaller than 0.2", function()
        assert.is_true(driver.get_ideal_rotation_velocity(0.3) < 0.1)
        assert.is_true(driver.get_ideal_rotation_velocity(-0.3) > -0.1)
    end)

end)


