-- simple logic of pressurisation equipment
size = {2048, 2048}

-- sim DataRefs
defineProperty("msl_alt", globalProperty("sim/flightmodel/position/elevation")) -- barometric altitude, possibly in feet or meters
defineProperty("baro_press_pa", globalProperty("sim/weather/region/sealevel_pressure_pas")) -- XP12: barometer_sealevel_inhg replaced by sealevel_pressure_pas (Pa)
-- sim/aircraft/view/acf_has_press_controls removed in XP12 (ACF-defined, not a runtime dataref)

defineProperty("eng_rpm1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("eng_rpm2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))

defineProperty("mode", globalProperty("sim/cockpit2/pressurization/actuators/bleed_air_mode"))
defineProperty("dump", globalProperty("sim/cockpit2/pressurization/actuators/dump_to_altitude_on"))

defineProperty("sim_cab_alt", globalProperty("sim/cockpit2/pressurization/actuators/cabin_altitude_ft"))
defineProperty("sim_cab_vvi", globalProperty("sim/cockpit2/pressurization/actuators/cabin_vvi_fpm"))

defineProperty("actual_cabin_alt", globalProperty("sim/cockpit2/pressurization/indicators/cabin_altitude_ft"))

-- custom
defineProperty("bleed1_sw", globalProperty("an-24/skv/bleed1_sw"))
defineProperty("bleed2_sw", globalProperty("an-24/skv/bleed2_sw"))
defineProperty("dump_cap", globalProperty("an-24/skv/dump_cap"))
defineProperty("dump_sw", globalProperty("an-24/skv/dump_sw"))
defineProperty("skv_siren", globalProperty("an-24/skv/skv_siren"))
defineProperty("skv_siren_alarm", globalProperty("an-24/skv/skv_siren_alarm"))

defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

-- power
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))

-- failures
defineProperty("rapid_depress", globalProperty("sim/operation/failures/rel_depres_fast"))

-- doors and windows may depressurise the plane
defineProperty("hole1", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[2]"))
defineProperty("hole2", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[3]"))
defineProperty("hole3", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[4]"))
defineProperty("hole4", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[5]"))
defineProperty("hole5", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[6]"))
defineProperty("hole6", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[8]"))
defineProperty("hole7", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[9]"))
defineProperty("hole8", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[14]"))

-- images
defineProperty("yellow_led", loadLED("yellow"))
defineProperty("blue_led", loadLED("blue"))
defineProperty("needleImage", langImage("needles", 86, 10, 18, 173))

-- initial switchers values
if get(eng_rpm1) < 70 and get(eng_rpm2) < 70 then
    set(bleed1_sw, 0)
    set(bleed2_sw, 0)

end

set(mode, 0)

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

-- acf_has_press_contr removed in XP12 (see defineProperty comment above)

-- altitude table
-- tables for required cabin altitude
local alt_table = {
    {-50000, -50000}, -- bugs workaround
    {0, 0}, -- on standard pressure zero level
    {2000, 0}, -- 2000 ft
    {11000, 0}, -- 11000 ft
    {23000, 9000}, -- 23000 ft
    {1000000, 979500}
} -- linear above 23000 ft

-- interpolate(): shared helper in core/glbl_func.lua

local use_oxy_lit = false
local door_lit = false
local angle1 = 0
local angle2 = 0
local siren_alarm = false
local counter = 0

local left_urvk_counter = 0
local right_urvk_counter = 0

function update()
    local passed = get(frame_time)

    local rpm1 = 0
    local rpm2 = 0
    if get(eng_rpm1) > 80 then
        rpm1 = 1
    end
    if get(eng_rpm2) > 80 then
        rpm2 = 1
    end

    local sys_on1 = rpm1 * get(bleed1_sw)
    local sys_on2 = rpm2 * get(bleed2_sw)

    -- gauges
    local left_coef = 0
    local right_coef = 0
    if sys_on1 == 1 then
        left_urvk_counter = left_urvk_counter + passed
    else
        left_urvk_counter = 0
    end
    if sys_on2 == 1 then
        right_urvk_counter = right_urvk_counter + passed
    else
        right_urvk_counter = 0
    end

    if (sys_on1 == 1 and left_urvk_counter > 3) or sys_on1 == 0 then
        left_coef = 1
    else
        left_coef = 0
    end
    if (sys_on2 == 1 and right_urvk_counter > 3) or sys_on2 == 0 then
        right_coef = 1
    else
        right_coef = 0
    end
    angle1 = approach(angle1, 120 * sys_on1 * left_coef, passed, 0.6)
    angle2 = approach(angle2, 120 * sys_on2 * right_coef, passed, 0.6)

    -- calculate real airplane altitude above standard pressure isoline
    -- XP12: baro_press_pa in Pascals, convert to inHg (1 Pa = 0.0002953 inHg)
    local baro_inhg = get(baro_press_pa) * 0.0002953
    local real_alt = get(msl_alt) * 3.28083 + (29.92 - baro_inhg) * 1000
    -- calculate required cabin altitude that the system can reach when working normally
    local needed_cabin_alt = real_alt
    if real_alt < 100000 then
        needed_cabin_alt = interpolate(alt_table, real_alt)
    end

    local actual_alt = get(actual_cabin_alt)

    -- calculate speed of change for cabin VVI and cabin altitude that system can really reach
    local cabin_alt = real_alt
    local vvi = 300 -- ft/min

    if angle1 + angle2 > 180 then
        cabin_alt = needed_cabin_alt
        vvi = 1500 * math.min(1, math.abs(actual_alt - cabin_alt) * 0.001)
    elseif angle1 + angle2 > 90 then
        cabin_alt = needed_cabin_alt
        if actual_alt > cabin_alt + 50 then
            vvi = 100 * math.min(1, math.abs(actual_alt - cabin_alt) * 0.001)
        elseif actual_alt < cabin_alt - 50 then
            vvi = 750 * math.min(1, math.abs(actual_alt - cabin_alt) * 0.001)
        else
            vvi = 0 * math.min(1, math.abs(actual_alt - cabin_alt) * 0.001)
        end
    else
        cabin_alt = real_alt
        vvi = 300
    end

    -- dump logic
    if get(dump_sw) == 1 then
        vvi = 2000
        cabin_alt = real_alt
    end

    -- print(cabin_alt, vvi, real_alt)

    -- rapid decompression if some door or window is opened in flight
    local doors_open =
        get(hole3) > 0.1 or get(hole4) > 0.1 or get(hole5) > 0.1 or get(hole6) > 0.1 or get(hole7) > 0.1 or get(hole8) >
            0.1
    if get(hole1) > 0.1 or get(hole2) > 0.1 or doors_open then
        set(rapid_depress, 6)
        set(mode, 0)
        vvi = 5000
    else
        set(rapid_depress, 0)
        set(mode, 2)
    end

    local power = get(bus_DC_27_volt_emerg) > 21

    -- lamps
    use_oxy_lit = actual_alt * 0.0003048009 > 3.5 and power
    door_lit = doors_open and power

    -- siren
    if use_oxy_lit then
        set(skv_siren, 1)
        counter = counter + passed
        if counter > 0.3 then
            counter = 0
            siren_alarm = not siren_alarm
        end
        if siren_alarm then
            set(skv_siren_alarm, 1)
        else
            set(skv_siren_alarm, 0)
        end
    else
        set(skv_siren, 0)
        counter = 0
        siren_alarm = false
        set(skv_siren_alarm, 0)
    end

    -- set result
    set(mode, 2)
    set(dump, 0)
    set(sim_cab_alt, cabin_alt)
    set(sim_cab_vvi, vvi)

end

components = { 
	-- dump cap switch (closing it also turns the dump switch off)
	toggleSwitch {
		position = {134, 448, 30, 40},
		drf = dump_cap,
		sound = cap_sound,
		onToggle = function(nv)
			if nv == 0 then
				set(dump_sw, 0)
			end
		end
	}, 
	
	-- dump switch (only acts while its cap is open)
	toggleSwitch {
		position = {955, 307, 17, 17},
		drf = dump_sw,
		sound = switch_sound,
		guard = function()
			return get(dump_cap) == 1
		end
	}, 
	
	-- system 1 / system 2 switches
	toggleSwitch {
		position = {1022, 429, 18, 18},
		drf = bleed1_sw,
		sound = switch_sound
	}, 
	
	toggleSwitch {
		position = {1041, 429, 18, 18},
		drf = bleed2_sw,
		sound = switch_sound
	}, 
	
	-- use oxygen light
	textureLit {
		image = get(blue_led),
		position = {641, 388, 19, 19},
		visible = function()
			return use_oxy_lit
		end
	}, 
	
	-- close doors light
	textureLit {
		image = get(yellow_led),
		position = {621, 388, 19, 19},
		visible = function()
			return door_lit
		end
	}, 
	
	-- system 1 needle
	needle {
		position = {1212, 1258, 180, 180},
		image = function()
			return get(needleImage)
		end,
		angle = function()
			return angle1
		end
	}, 
	
	-- system 2 needle
	needle {
		position = {1412, 1258, 180, 180},
		image = function()
			return get(needleImage)
		end,
		angle = function()
			return angle2
		end
	}
}
