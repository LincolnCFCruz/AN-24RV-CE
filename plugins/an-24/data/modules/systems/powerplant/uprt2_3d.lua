size = {200, 200}

-- initialize component property table
defineProperty("N1", globalProperty("an-24/misc/virt_rud1"))
defineProperty("N2", globalProperty("an-24/misc/virt_rud2"))

-- power
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))

defineProperty("uprt_cc", globalProperty("an-24/gauges/uprt_cc"))

defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- local time since aircraft was loaded

-- background image
defineProperty("black_cap", langImage("covers", 0, 17, 56, 56)) -- black cap image

-- needle image
defineProperty("needle_N1", langImage("needles", 145, 15, 19, 163))
defineProperty("needle_N2", langImage("needles", 168, 15, 19, 163))

-- local variables
local left_angle = -150
local right_angle = -150
local left_angle_last = -150
local right_angle_last = -150
local left_angle_actual = -150
local right_angle_actual = -150

-- post frame calculations
function update()
    -- check power
    if dcOK() then
        left_angle = get(N1) * 257 - 150
        right_angle = get(N2) * 257 - 150
        set(uprt_cc, 8)
    else
        left_angle = -150
        right_angle = -150
        set(uprt_cc, 0)
    end

    local passed = get(frame_time)
    if passed > 0 then
        -- set smooth move
        left_angle_actual = left_angle_last + (left_angle - left_angle_last) * passed * 10
        right_angle_actual = right_angle_last + (right_angle - right_angle_last) * passed * 10
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
	}, 
	
	-- black cap
	texture {
		position = {79, 78, 44, 44},
		image = function()
			return get(black_cap)
		end
	}
}
