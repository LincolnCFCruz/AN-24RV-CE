size = {200, 200}

-- initialize component property table
-- new dataref x12  sim/cockpit2/engine/indicators/EGT_deg_cel -- refresh 18/05/26
-- defineProperty("EGT", globalProperty("sim/cockpit2/engine/indicators/EGT_deg_C[0]"))  -- xp11
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt")) -- power
defineProperty("temp_check", globalProperty("an-24/start/left_temp_check")) -- select temp check mode
defineProperty("egt_fail", globalProperty("sim/operation/failures/rel_EGT_ind_0")) -- gauge failure
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- flight time

defineProperty("thermo", globalProperty("sim/cockpit2/temperature/outside_air_temp_degc")) -- outside temperature
defineProperty("uprt", globalProperty("an-24/misc/virt_rud1"))
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[0]"))
defineProperty("eng_work", globalProperty("sim/flightmodel2/engines/engine_is_burning_fuel[0]"))
defineProperty("engine_on_fire", globalProperty("sim/operation/failures/rel_engfir0")) -- engine on fire
defineProperty("eng_power", globalProperty("sim/flightmodel/engine/ENGN_power[0]"))

-- needle image
defineProperty("NeedleImage", langImage("needles", 16, 47, 16, 98))

defineProperty("black_cap", langImage("covers", 0, 17, 56, 56)) -- black cap image

local last_angle = -120
local actual_angle = -120

-- tables for power to temperature conversion
local power_table = {
	{-50000, 0}, -- bugs workaround
	{0.0, 0.00}, -- zero power
	{200, 150}, -- IDLE
	{1130, 250}, -- 30% UPRT
	{1800, 350}, -- cruise power
	{2100, 370}, -- nominal power
	{2700, 350}, -- takeoff power
	{10000, 600}
} -- linear above

-- interpolate(): shared helper in core/glbl_func.lua

function update()

    local power = dcOK()
    local switch = get(temp_check)
    local fail = get(egt_fail) == 6
    local n1 = get(N1)
    local coef_uprt = 1 + get(uprt) / (1 + n1 * 0.1)
    local eng_FIRE = 0
    if get(engine_on_fire) == 6 then
        eng_FIRE = 1
    end

    local v = get(thermo) + (700 * coef_uprt - n1 * 7 + interpolate(power_table, get(eng_power) * 0.0013411)) *
                  get(eng_work) + 500 * eng_FIRE

    if switch == 0 and not fail then
        v = v
    elseif power and switch == 1 and not fail then
        v = math.max(v, 240)
    elseif power and switch == -1 and not fail then
        v = math.max(v, 360)
    end

    -- print(v, get(thermo), coef_uprt, get(eng_power), interpolate(power_table, get(eng_power) * 0.0013411))

    local angle = (v - 200) * 215 / 800 - 120

    -- set limits
    if angle < -120 then
        angle = -120
    elseif angle > 110 then
        angle = 110
    end

    local delta = angle - last_angle
    local passed = get(frame_time)

    actual_angle = actual_angle + 1 * delta * passed
    last_angle = actual_angle

    -- -120 = 200
    -- 95 = 1000
end

-- EGT indicator consists of several components
components = { 
	-- white needle
	needle {
		position = {10, 10, 180, 180},
		image = function()
			return get(NeedleImage)
		end,
		angle = function()
			return actual_angle
		end
	}, 
	
	-- black cap
	texture {
		position = {70, 70, 60, 60},
		image = function()
			return get(black_cap)
		end
	}
}
