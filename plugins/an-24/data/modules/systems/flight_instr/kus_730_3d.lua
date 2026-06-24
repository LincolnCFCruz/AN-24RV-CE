size = {200, 200}

-- long needle image
defineProperty("longNeedleImage", langImage("needles", 86, 10, 18, 173))

-- short needle image
defineProperty("shortNeedleImage", langImage("needles", 0, 168, 16, 88))

-- ias variable
defineProperty("ias", globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot"))

-- tas variable

-- barometric altitude
defineProperty("msl_alt", globalProperty("sim/flightmodel/position/elevation")) -- barometric alt. maybe in feet, maybe in meters.
-- V11/XP12 FIX: barometer_sealevel_inhg is REPLACED — use sealevel_pressure_pas.
-- The new dataref is in Pascals; the altitude formula below works in inHg,
-- so we convert on read: inHg = Pa / 3386.39
defineProperty("baro_press_pa", globalProperty("sim/weather/region/sealevel_pressure_pas")) -- pressure at sea level in Pa (XP12)

-- interpolate(): shared helper in core/glbl_func.lua

-- tables for needed cabin alt
local alt_table = {
	{-50000, 0.5}, -- bugs workaround
	{0, 1}, -- on standard pressure zero level
	{2000, 1.0296}, 
	{4000, 1.0569}, 
	{6000, 1.0888}, 
	{8000, 1.1229}, 
	{10000, 1.1606}, 
	{12000, 1.1873}, 
	{14000, 1.2267},
	{16404, 1.2881}, -- 5 km
	{19685, 1.3478}, -- 6 km
	{22000, 1.4009}, 
	{24000, 1.4428}, 
	{26000, 1.4925}, 
	{28000, 1.5474}, 
	{30000, 1.6096}, 
	{1000000, 3}
} -- linear above

-- 50 km/h at 10 degrees
-- 350 km/h at 340 degrees

-- post frame calculations
local ias_amgle
local tas_angle

function update()
    -- calculate IAS
    local v_ias = get(ias) * 1.852
    if 750 < v_ias then
        v = 750
    end
    if 30 > v_ias then
        ias_amgle = 0
    else
        ias_amgle = (v_ias - 100) * 285 / 600 + 33
    end

    -- calculate TAS
    -- V11/XP12 FIX: baro_press_pa is in Pa, convert to inHg for Parshukov's formula (29.92 inHg = standard)
    local baro_press_inhg = get(baro_press_pa) / 3386.39
    local real_alt = get(msl_alt) * 3.28083 + (29.92 - baro_press_inhg) * 1000 -- calculate barometric altitude in feet
    local baro_coef = interpolate(alt_table, real_alt) -- get coefficient
    local v_tas = v_ias * baro_coef
    if 1100 < v_tas then
        v_tas = 1100
    end
    if 380 > v_tas then
        v_tas = 380
    end
    tas_angle = (v_tas - 400) * 340 / 700 - 170

end

-- airspeed indicator consists of several components
components = { 
	-- tas needle
	needle {
		position = {40, 40, 120, 120},
		image = function()
			return get(shortNeedleImage)
		end,
		angle = function()
			return tas_angle
		end
	}, 
	
	rectangle {
		position = {95, 35, 10, 70},
		color = {0.05, 0.05, 0.05, 1}
	}, 
	
	-- ias needle
	needle {
		position = {10, 10, 180, 180},
		image = function()
			return get(longNeedleImage)
		end,
		angle = function()
			return ias_amgle
		end
	}
}
