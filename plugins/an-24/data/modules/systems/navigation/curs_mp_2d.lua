-- this is simple logic for KursMP system
size = {200, 200}

-- define property table
-- sources
defineProperty("obs1_fromto", globalProperty("an-24/gauges/obs1_fromto")) -- obs from-to switcher
defineProperty("obs2_fromto", globalProperty("an-24/gauges/obs2_fromto")) -- obs from-to switcher
defineProperty("sp_ils", globalProperty("an-24/gauges/sp_ils")) -- switcher between SP-50 and ILS system
defineProperty("nav_select", globalProperty("an-24/gauges/nav_select")) -- selector between NAV1 and NAV2
defineProperty("mrp_mode", globalProperty("an-24/gauges/mrp_mode")) -- 0 - landing, 1 = navigation

defineProperty("v_plank_1", globalProperty("sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot")) -- horizontal deflection on course
defineProperty("h_plank_1", globalProperty("sim/cockpit2/radios/indicators/nav1_vdef_dots_pilot")) -- vertical deflection on glideslope
defineProperty("cr_flag_1", globalProperty("sim/cockpit2/radios/indicators/nav1_flag_from_to_pilot")) -- Nav-To-From indication, nav1, pilot, 0 is flag, 1 is to, 2 is from.
defineProperty("gs_flag_1", globalProperty("sim/cockpit/radios/nav1_CDI")) -- glideslope flag. 0 - flag is shown

defineProperty("v_plank_2", globalProperty("sim/cockpit2/radios/indicators/nav2_hdef_dots_pilot")) -- horizontal deflection on course
defineProperty("h_plank_2", globalProperty("sim/cockpit2/radios/indicators/nav2_vdef_dots_pilot")) -- vertical deflection on glideslope
defineProperty("cr_flag_2", globalProperty("sim/cockpit2/radios/indicators/nav2_flag_from_to_pilot")) -- Nav-To-From indication, nav1, pilot, 0 is flag, 1 is to, 2 is from.
defineProperty("gs_flag_2", globalProperty("sim/cockpit/radios/nav2_CDI")) -- glideslope flag. 0 - flag is shown

-- fail
defineProperty("fail1", globalProperty("sim/operation/failures/rel_nav1"))
defineProperty("fail2", globalProperty("sim/operation/failures/rel_nav2"))

-- power
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))
defineProperty("curs_mp1_sw", globalProperty("an-24/gauges/curs_mp1_sw"))
defineProperty("curs_mp2_sw", globalProperty("an-24/gauges/curs_mp2_sw"))
defineProperty("curs_mp_cc", globalProperty("an-24/gauges/curs_mp_cc"))

-- images
defineProperty("red_small_led", loadLED("red_small"))
defineProperty("rot_switch", sasl.gl.loadImage("rot_switch.dds", 0, 0, 64, 128))

local switch_sound = loadSample('sounds/custom/plastic_switch.wav')

-- local variables
local k1_lamp = false
local k2_lamp = false
local g1_lamp = false
local g2_lamp = false
local bearing1 = 0
local bearing2 = 0
local sp_ils_angle = 110 - get(sp_ils) * 45
local mrp_angle = -65 - get(mrp_mode) * 45
local nav_angle = -60 + get(nav_select) * 30

function update()
    -- power calculations
    local power1 = 0
    local power2 = 0
    local power27 = get(bus_DC_27_volt) > 21
    if power27 and acOK() then
        if get(curs_mp1_sw) == 1 and get(fail1) < 6 then
            power1 = 1
        else
            power1 = 0
        end
        if get(curs_mp2_sw) == 1 and get(fail2) < 6 then
            power2 = 1
        else
            power2 = 0
        end
    else
        power1 = 0
        power2 = 0
    end
    local ils_sp = get(sp_ils)
    -- calculate lamps and flags
    k1_lamp = (get(cr_flag_1) == 0 or (get(gs_flag_1) == 1 and ils_sp == 0)) and power1 == 1 -- lamps will glow when required and there is power for them
    k2_lamp = (get(cr_flag_2) == 0 or (get(gs_flag_2) == 1 and ils_sp == 0)) and power2 == 1
    g1_lamp = (get(gs_flag_1) == 0 or ils_sp == 0) and power1 == 1
    g2_lamp = (get(gs_flag_2) == 0 or ils_sp == 0) and power2 == 1

    sp_ils_angle = 110 - get(sp_ils) * 45
    mrp_angle = -65 - get(mrp_mode) * 45
    nav_angle = -50 + get(nav_select) * 25

end

components = {
	needle {
		position = {5, 115, 64, 64},
		image = get(rot_switch),
		angle = function()
			return sp_ils_angle
		end
	}, 
	
	needle {
		position = {135, 115, 64, 64},
		image = get(rot_switch),
		angle = function()
			return mrp_angle
		end
	}, 
	
	needle {
		position = {71, 0, 64, 64},
		image = get(rot_switch),
		angle = function()
			return nav_angle
		end
	}, 
	
	-- K1 led
	textureLit {
		image = get(red_small_led),
		position = {30, 92, 11, 11},
		visible = function()
			return k1_lamp
		end
	}, 
	
	-- G1 led
	textureLit {
		image = get(red_small_led),
		position = {30, 49, 11, 11},
		visible = function()
			return g1_lamp
		end
	}, 
	
	-- K2 led
	textureLit {
		image = get(red_small_led),
		position = {156, 92, 11, 11},
		visible = function()
			return k2_lamp
		end
	}, 
	
	-- G2 led
	textureLit {
		image = get(red_small_led),
		position = {156, 49, 11, 11},
		visible = function()
			return g2_lamp
		end
	}, 
	
	-- switcher SP-50/ILS
	toggleSwitch {
		position = {10, 120, 50, 60},
		drf = sp_ils,
		sound = switch_sound
	}, 
	
	-- switcher for MRP mode
	toggleSwitch {
		position = {140, 120, 50, 60},
		drf = mrp_mode,
		sound = switch_sound
	}, 
	
	-- nav selector (0..4)
	stepButton {
		position = {60, 10, 40, 50},
		cursor = Cursors.ROTATE_LEFT,
		onStep = function()
			local a = get(nav_select)
			if a > 0 then
				playUISound(switch_sound);
				a = a - 1
			end
			set(nav_select, a)
		end
	}, 
	
	stepButton {
		position = {100, 10, 40, 50},
		cursor = Cursors.ROTATE_RIGHT,
		onStep = function()
			local a = get(nav_select)
			if a < 4 then
				playUISound(switch_sound);
				a = a + 1
			end
			set(nav_select, a)
		end
	}
}
