-- this is DME gauge with simple logic of power
size = {200, 200}

-- define properties
-- XP12: the DME is a separate receiver with its own frequency (dme_set_3d.lua
-- tunes it), so read its own distance here (nm x 1.852 = km). Reading NAV2's
-- DME instead forced the rangefinder to share the 2nd Курс-МП frequency.
defineProperty("distance", globalProperty("sim/cockpit2/radios/indicators/dme_dme_distance_nm")) -- distance in NM (standalone DME)
defineProperty("power_sw", globalProperty("an-24/gauges/dme_on")) -- power switcher
defineProperty("dme_power", globalProperty("sim/cockpit2/radios/actuators/dme_power")) -- XP12 receiver on/off, follows power_sw + bus
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))
defineProperty("dme_cc", globalProperty("an-24/gauges/dme_cc"))

-- images
defineProperty("digitsImage", sasl.gl.loadImage("white_digit_strip.png", 0, 60, 16, 196))
defineProperty("flagImg", langImage("needles", 360, 250, 90, 6))

-- initial switcher values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

local time_counter = 0
local not_loaded = true

local switch_sound = loadSample('sounds/custom/metal_switch.wav')
local cap_sound = loadSample('sounds/custom/cap.wav')
local btn_click = loadSample('sounds/custom/plastic_btn.wav')
local rot_click = loadSample('sounds/custom/rot_click.wav')

local dist_km = 0
local dist_m = 0
local power = 0
local red_flag = true

function update()
    time_counter = time_counter + get(frame_time)
	
    if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
        set(power_sw, 0)
        not_loaded = false
    end

    if get(bus_DC_27_volt) * get(power_sw) > 21 then
        power = 1
    else
        power = 0
    end

    -- the XP12 receiver only ranges while it is switched on and the bus is live
    set(dme_power, power)

    if power > 0 then
        set(dme_cc, 5)
    else
        set(dme_cc, 0)
    end

    local dist = get(distance) * power
    if dist > 0 then
        dist_km = dist * 1.852
        if dist_km > 999.9 then
            dist_km = 999.9
        end

        dist_m = dist_km * 10 -- math.floor(dist_km) * 10
        dist_km = math.floor(dist_km + 0.05)
        red_flag = false
    else
        red_flag = true
    end
end

components = { 
	-- distance digits
	digitstape {
		position = {8, 85, 130, 50},
		image = digitsImage,
		digits = 3,
		showLeadingZeros = true,
		allowNonRound = true,
		value = function()
			return dist_km
		end
	}, 
	
	-- distance digits
	digitstape {
		position = {145, 85, 40, 50},
		image = digitsImage,
		digits = 1,
		showLeadingZeros = true,
		allowNonRound = false,
		value = function()
			return dist_m
		end
	}, 
	
	texture {
		position = {8, 103, 184, 12},
		image = function()
			return get(flagImg)
		end,
		visible = function()
			return red_flag
		end
	}, 
	
	-- DME power switch
	toggleSwitch {
		position = {180, 0, 20, 20},
		drf = power_sw,
		sound = switch_sound
	}
}
