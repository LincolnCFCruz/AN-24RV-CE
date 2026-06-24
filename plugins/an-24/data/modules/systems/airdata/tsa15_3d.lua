size = {200, 200}

-- initialize component property table
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[2]"))
defineProperty("ru19_N1", globalProperty("an-24/start/ru19_N1"))

defineProperty("msl_alt", globalProperty("sim/flightmodel/position/elevation")) -- barometric alt. maybe in feet, maybe in meters.
defineProperty("baro_press", globalProperty("sim/weather/barometer_sealevel_inhg")) -- pressure at sea level in.Hg

defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("sim_run_time", globalProperty("sim/time/total_running_time_sec")) -- sim time

-- needle image
defineProperty("needle_long", langImage("needles", 67, 7, 16, 179))

-- local variables
local left_angle = 50
--local right_angle = 50
local left_angle_last = 50
--local right_angle_last = 50
local left_angle_actual = 50
--local right_angle_actual = 50

local passed = 0

local tro_table = {
	{0.0, 0.0}, -- OFF
	{37, 38}, -- idle
	{87, 100}, -- takeoff
	{1000, 1000}
} -- bugs

-- tables for altitude correction
local alt_table_ru19 = {
	{-50000, 1}, -- bugs workaround
	{0.00, 1}, -- on standard pressure zero level
	{4000, 0.9756}, -- 4000 ft
	{8000, 0.9434}, -- 8000 ft
	{13000, 0.89}, -- 13000 ft
	{100000, 0.7} -- linear above 13000 ft
}

-- interpolate(): shared helper in core/glbl_func.lua

-- post frame calculations
function update()
    -- altitude calculations
    local alt = get(msl_alt) * 3.28083 -- MSL alt in feet
    local alt_baro = (29.92 - get(baro_press)) * 1000
    local alt_coef = interpolate(alt_table_ru19, alt + alt_baro)

    -- recalculate N1
    local n1 = interpolate(tro_table, get(N1)) * alt_coef
    set(ru19_N1, n1)

    left_angle = n1 * 3.07 + 50

    passed = get(frame_time)
    if passed > 0 then
        -- set smooth move
        left_angle_actual = left_angle_last + (left_angle - left_angle_last) * passed * 4
        -- right_angle_actual = right_angle_last + (right_angle - right_angle_last) * passed * 4
    end
    -- last variables
    left_angle_last = left_angle_actual
    -- right_angle_last = right_angle_actual

end

components = { 
    
--[[
    -- right needle
    needle {
        position = { 10, 10, 180, 180 },
        image = get(needle_N2),
        angle = function()
            return right_angle_actual
        end
    }, 
--]]
    -- left needle
    needle {
        position = {10, 10, 180, 180},
        image = function()
            return get(needle_long)
        end,
        angle = function()
            return left_angle_actual
        end
    }
}
