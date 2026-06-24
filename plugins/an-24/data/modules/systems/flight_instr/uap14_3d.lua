size = {200, 200}

-- define property table
defineProperty("ias", globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")) -- ias variable
defineProperty("gforce", globalProperty("sim/flightmodel2/misc/gforce_normal")) -- G overload
defineProperty("alpha", globalProperty("sim/flightmodel2/misc/AoA_angle_degrees")) -- angle of attack
defineProperty("alpha_fail", globalProperty("sim/operation/failures/rel_AOA")) -- angle of attack fail
defineProperty("auasp_warn", globalProperty("an-24/gauges/auasp_warning")) -- warning
defineProperty("auasp_button", globalProperty("an-24/gauges/auasp_button")) -- check button
defineProperty("aoa_sensor_angle", globalProperty("an-24/misc/aoa_sensor_angle")) -- angle of AOA sensor

-- power
defineProperty("auasp_sw", globalProperty("an-24/gauges/auasp_sw")) -- power switcher
defineProperty("auasp_cc", globalProperty("an-24/gauges/auasp_cc")) -- power current
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))

-- environment
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- local time since aircraft was loaded

-- failures
defineProperty("stall_warn_fail", globalProperty("sim/operation/failures/rel_stall_warn")) -- failure of stall warning

-- images
defineProperty("needleImage", langImage("needles", 311, 10, 18, 173))
defineProperty("scaleImage", sasl.gl.loadImage("scales_1.png", 402, 301, 106, 200))
defineProperty("sectorImage", sasl.gl.loadImage("scales_1.png", 0, 1, 94, 124))
defineProperty("red_small_led", loadLED("red_small"))

--[[
-- initial switcher values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))

if get(N1) < 70 and get(N2) < 70 then
	set(auasp_sw, 0)
end
--]]

-- local variables
local a_angle = -180
local g_angle = 135
local sector_angle = 0
local warn = false
local last_lamp_change = get(flight_time)
local actual_a = -180
local actual_g = 135

set(aoa_sensor_angle, 0)

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

function update()
    -- calculate power
    local power = dcOK() and acOK() and get(auasp_sw) == 1

    local passed = get(frame_time)

    if passed > 0 then

        if power then
            -- calculate alpha
            if get(ias) > 50 and get(alpha_fail) < 6 then
                local a = 3 + get(alpha)
                a_angle = a * 180 / 15 - 180
                set(aoa_sensor_angle, a)
            else
                a_angle = -180
            end

            -- calculate G force
            g_angle = -get(gforce) * 180 / 4 + 135

            -- set CC
            set(auasp_cc, 8)

            if get(auasp_button) == 1 then
                a_angle = -33
                g_angle = 28
            end
            -- set warning
            if (actual_a > -35 and get(stall_warn_fail) < 6) or actual_g < 30 then
                if get(flight_time) - last_lamp_change > 0.16 then
                    warn = not warn
                    last_lamp_change = get(flight_time)
                end
            else
                warn = false
            end
        else
            a_angle = -180
            g_angle = 135
            set(auasp_cc, 0)
            set(auasp_warn, 0)
            warn = false
        end
        -- set limits
        if a_angle < -180 then
            a_angle = -180
        elseif a_angle > 0 then
            a_angle = 0
        end

        if g_angle < 0 then
            g_angle = 0
        elseif g_angle > 180 then
            g_angle = 180
        end

        -- smooth move of needles
        local delta_a = a_angle - actual_a
        actual_a = actual_a + delta_a * passed * 5

        local delta_g = g_angle - actual_g
        actual_g = actual_g + delta_g * passed * 5

        if warn then
            set(auasp_warn, 1)
        else
            set(auasp_warn, 0)
        end

    end

end

components = { 
	-- sector image
	texture {
		id = "uap14-sector",
		position = {39, 79, 94, 124},
		image = get(sectorImage)

	}, 
	
	-- AOA needle
	needle {
		id = "uap14-aoa-needle",
		position = {10, 10, 180, 180},
		image = function()
			return get(needleImage)
		end,
		angle = function()
			return actual_a
		end
	}, 
	
	-- cover scale
	texture {
		id = "uap14-scale",
		position = {93, -0.5, 106, 200},
		image = get(scaleImage)

	}, 
	
	-- G-force needle
	needle {
		id = "uap14-g-needle",
		position = {10, 10, 180, 180},
		image = function()
			return get(needleImage)
		end,
		angle = function()
			return actual_g
		end
	}, 
	
	-- red led image
	textureLit {
		id = "uap14-warn-led",
		position = {0, 0, 32, 32},
		image = get(red_small_led),
		visible = function()
			return warn
		end

	}, 
	
	-- AUASP check button (momentary)
	momentaryButton {
		position = {165, 0, 35, 35},
		drf = auasp_button,
		sound = btn_click,
		soundUp = btn_click
	} 
	
	-- position gauge
}
