-- this is the simple logic of GPK correction panel
size = {2048, 2048}

-- define property table
-- source
defineProperty("lat", globalProperty("an-24/gauges/GPK_lat")) -- latitude position on panel
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- sim time
defineProperty("corr_switcher", globalProperty("an-24/gauges/GPK_corr_sw")) -- correction switcher ON/OFF
defineProperty("corr_rot", globalProperty("an-24/gauges/GPK_corr_rot")) -- correction rotary
defineProperty("north_GPK", globalProperty("an-24/set/north_GPK")) -- GPK mode for north hemisphere

-- power
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt")) -- power 27 volt
defineProperty("bus_AC_36_volt", globalProperty("an-24/power/bus_AC_36_volt")) -- power 36 volt
defineProperty("gpk_switch", globalProperty("an-24/gauges/GPK_sw")) -- switcher to turn ON/OFF

-- fail
defineProperty("fail", globalProperty("sim/operation/failures/rel_cop_dgy"))

-- result
defineProperty("correct", globalProperty("an-24/gauges/GPK_corr")) -- correction on GPK panel
defineProperty("correct_ap", globalProperty("an-24/gauges/ap_GPK_corr")) -- correction on GPK panel
defineProperty("lat_angle", globalProperty("an-24/gauges/GPK_lat_rotary")) -- angle for lat rotary

defineProperty("SC_master", globalProperty("scp/api/ismaster")) -- status of SmartCopilot
defineProperty("sc_corr_angle", globalProperty("an-24/gauges/sc_corr_angle")) -- SmartCopilot
defineProperty("sc_corr_ap_angle", globalProperty("an-24/gauges/sc_corr_ap_angle")) -- SmartCopilot

-- initial switcher values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

-- rotate left
left_command = findCommand("sim/autopilot/vertical_speed_up")
function left_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        local a = get(corr_rot) - 1
        if a < -5 then
            a = -5
        end
        set(corr_rot, a)
    end
    return 0
end
registerCommandHandler(left_command, 0, left_handler)

-- rotate right
right_command = findCommand("sim/autopilot/vertical_speed_down")
function right_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        local a = get(corr_rot) + 1
        if a > 5 then
            a = 5
        end
        set(corr_rot, a)
    end
    return 0
end
registerCommandHandler(right_command, 0, right_handler)

-- rotate center
center_command = findCommand("sim/autopilot/vertical_speed_sync")
function center_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        set(corr_rot, 0)
    end
    return 0
end
registerCommandHandler(center_command, 0, center_handler)

-------------

local time_counter = 0
local not_loaded = true

local passed = 0

local corr_angle = 0
local corr_ap_angle = 0
local turn_switcher = get(corr_rot)
local power = 0

-- post-frame calculations
function update()
    -- time calculations
    passed = get(frame_time)
    -- pre bug check
    if passed > 0 then

        -- initial switcher values
        time_counter = time_counter + passed
        if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
            set(gpk_switch, 0)
            set(corr_switcher, 0)
            not_loaded = false
        end

        -- check power
        if dcOK() and ac36OK() and get(gpk_switch) > 0 and get(fail) < 6 then
            power = 1
        else
            power = 0
        end

        -- earth rotation correction
        local earth_rot = 0
        if get(corr_switcher) > 0 then
            earth_rot = (2 * get(north_GPK) - 1) * 360 * math.sin(math.rad(get(lat))) * passed * power / 86164
        end -- one astronomical day equals 86164 seconds
        -- correction angle
        turn_switcher = get(corr_rot)
        local rotate = -turn_switcher * 40 * passed * power / 60
        if rotate > 180 then
            rotate = rotate - 360
        elseif rotate < -180 then
            rotate = rotate + 360
        end

        -- calculate result
        corr_angle = get(sc_corr_angle)
        corr_angle = corr_angle + earth_rot + rotate
        if corr_angle > 180 then
            corr_angle = corr_angle - 360
        elseif corr_angle < -180 then
            corr_angle = corr_angle + 360
        end
        set(sc_corr_angle, corr_angle)

        corr_ap_angle = get(sc_corr_ap_angle)
        corr_ap_angle = corr_ap_angle + earth_rot
        if corr_ap_angle > 180 then
            corr_ap_angle = corr_ap_angle - 360
        elseif corr_ap_angle < -180 then
            corr_ap_angle = corr_ap_angle + 360
        end
        set(sc_corr_ap_angle, corr_ap_angle)
        -- print(earth_rot, corr_ap_angle)

        -- set result
        set(correct, corr_angle)
        set(correct_ap, corr_ap_angle)

    end

end

components = { 
	-- correction rotary: turn left (-5..5)
	stepButton {
		position = {1605, 650, 15, 30},
		cursor = Cursors.ROTATE_LEFT,
		onStep = function()
			local a = get(corr_rot)
			if a > -5 then
				playUISound(plastic_sound);
				a = a - 1
			end
			set(corr_rot, a)
		end
	}, 
	
	-- correction rotary: turn right
	stepButton {
		position = {1620, 650, 15, 30},
		cursor = Cursors.ROTATE_RIGHT,
		onStep = function()
			local a = get(corr_rot)
			if a < 5 then
				playUISound(plastic_sound);
				a = a + 1
			end
			set(corr_rot, a)
		end
	}, 
	
	-- correction power switcher
	toggleSwitch {
		position = {1635, 670, 15, 15},
		drf = corr_switcher,
		sound = switch_sound
	}, 
	
	-- latitude rotary: turn left (0..90, left increases)
	stepButton {
		position = {1650, 650, 15, 30},
		cursor = Cursors.ROTATE_LEFT,
		onStep = function()
			local a = get(lat)
			if a < 90 then
				playUISound(rot_click);
				a = a + 5
			end
			set(lat, a)
			set(lat_angle, math.sin(math.rad(a)))
		end
	}, 
	
	-- latitude rotary: turn right
	stepButton {
		position = {1665, 650, 15, 30},
		cursor = Cursors.ROTATE_RIGHT,
		onStep = function()
			local a = get(lat)
			if a > 0 then
				playUISound(rot_click);
				a = a - 5
			end
			set(lat, a)
			set(lat_angle, math.sin(math.rad(a)))
		end
	}
}
