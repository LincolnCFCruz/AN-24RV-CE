size = {200, 200}

-- initialize component property table
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))

defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- sim time

-- background image

-- needle image
defineProperty("needle_N1", langImage("needles", 145, 15, 19, 163))
defineProperty("needle_N2", langImage("needles", 168, 15, 19, 163))

-- local variables
local left_angle = 50
local right_angle = 50
local left_angle_last = 50
local right_angle_last = 50
local left_angle_actual = 50
local right_angle_actual = 50

-- table of throttles
local n1_table = {
    {-100, -100}, -- bugs workaround
    {0, 0}, 
    {4, 0}, 
    {5, 5}, 
    {10, 10}, 
    {11, 11}, 
    {12, 12}, 
    {13, 13}, 
    {14, 14}, 
    {15, 15}, 
    {16, 16}, 
    {18, 18}, 
    {20, 20},
    {110, 110}, -- nominal
    {10000, 110}
} -- bugs workaround
-- interpolate(): shared helper in core/glbl_func.lua

local passed = 0

-- post frame calculations
function update()
    left_angle = interpolate(n1_table, get(N1)) * 3.07 + 50
    right_angle = interpolate(n1_table, get(N2)) * 3.07 + 50

    passed = get(frame_time)
    if passed > 0 then
        -- set smooth move
        left_angle_actual = approach(left_angle_last, left_angle, passed, 4)
        right_angle_actual = approach(right_angle_last, right_angle, passed, 4)
    end
    -- last variables

    left_angle_last = left_angle_actual
    right_angle_last = right_angle_actual

end

components = { 
    -- right needle
    needle {
        position = {10, 10, 180, 180},
        image = function()
            return get(needle_N2)
        end,
        angle = function()
            return right_angle_actual
        end
    }, 
    
    -- left needle
    needle {
        position = {10, 10, 180, 180},
        image = function()
            return get(needle_N1)
        end,
        angle = function()
            return left_angle_actual
        end
    }
}
