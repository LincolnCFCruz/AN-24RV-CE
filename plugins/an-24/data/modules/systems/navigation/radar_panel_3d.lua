-- this is radar clickables
size = {2048, 2048}

defineProperty("rls_power_sw", globalProperty("an-24/rls/rls_power_sw")) -- power switch
defineProperty("rls_scan_spd", globalProperty("an-24/rls/rls_scan_spd")) -- power switch
defineProperty("rls_scan_spd_up", globalProperty("an-24/rls/rls_scan_spd_up")) -- power switch
defineProperty("rls_scan_spd_down", globalProperty("an-24/rls/rls_scan_spd_down")) -- power switch
defineProperty("rls_mode", globalProperty("an-24/rls/rls_mode")) -- power switch
defineProperty("rls_mode_lamp", globalProperty("an-24/rls/rls_mode_lamp")) -- power switch
defineProperty("rls_bright", globalProperty("an-24/rls/rls_bright")) -- power switch
defineProperty("rls_contr", globalProperty("an-24/rls/rls_contr")) -- power switch
defineProperty("rls_signs", globalProperty("an-24/rls/rls_signs")) -- power switch
defineProperty("map_range", globalProperty("sim/cockpit/switches/EFIS_map_range_selector"))
defineProperty("map_range2", globalProperty("sim/cockpit2/EFIS/map_range"))

-- initial switchers values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

local time_counter = 0
local not_loaded = true

local mode_lamp = get(rls_mode_lamp)

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

set(map_range, 2)

function update()
    -- initial switchers values
    time_counter = time_counter + get(frame_time)
    if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
        set(rls_power_sw, 0)
        not_loaded = false
    end

    mode_lamp = get(rls_mode_lamp)

    set(map_range2, get(map_range))

end

-- images
defineProperty("led", sasl.gl.loadImage("leds.dds", 100, 12, 10, 10))

local up_pressed = false
local down_pressed = false

components = { 
	-- power switcher
	toggleSwitch {
		position = {1675, 598, 17, 30},
		drf = rls_power_sw,
		sound = switch_sound
	}, 
	
	-- scan speed up
	clickable {
		position = {1617, 615, 17, 17}, -- search and set right
		cursor = Cursors.HAND,
		onMouseDown = function()
			set(rls_scan_spd_up, 1)
			if not up_pressed then
				sasl.al.playSample(btn_click, false)
				up_pressed = true
				local a = get(rls_scan_spd) + 10
				if a > 100 then
					a = 100
				end
				set(rls_scan_spd, a)
			end
			return true
		end,
		onMouseUp = function()
			sasl.al.playSample(btn_click, false)
			set(rls_scan_spd_up, 0)
			up_pressed = false
			return true
		end
	}, 
	
	-- scan speed down
	clickable {
		position = {1617, 598, 17, 17}, -- search and set right
		cursor = Cursors.HAND,
		onMouseDown = function()
			set(rls_scan_spd_down, 1)
			if not down_pressed then
				sasl.al.playSample(btn_click, false)
				down_pressed = true
				local a = get(rls_scan_spd) - 10
				if a < 20 then
					a = 20
				end
				set(rls_scan_spd, a)
			end
			return true
		end,
		onMouseUp = function()
			sasl.al.playSample(btn_click, false)
			set(rls_scan_spd_down, 0)
			down_pressed = false
			return true
		end
	}, 
	
	-- mode rotary
	rotary {
		-- image = rotaryImage;
		value = rls_mode,
		step = 1,
		position = {1610, 549, 40, 30},
		-- round inches hg to millimeters hg
		adjuster = function(v)
			sasl.al.playSample(plastic_sound, false)
			if v > 2 then
				v = 2
			elseif v < 0 then
				v = 0
			end
			return v
		end
	}, 
	
	-- range rotary
	rotary {
		-- image = rotaryImage;
		value = map_range,
		step = 1,
		position = {1660, 549, 40, 30},
		-- round inches hg to millimeters hg
		adjuster = function(v)
			sasl.al.playSample(plastic_sound, false)
			if v > 6 then
				v = 6
			elseif v < 1 then
				v = 1
			end
			return v
		end
	}, 
	
	-- brightness rotary
	rotary {
		-- image = rotaryImage;
		value = rls_bright,
		step = 0.1,
		position = {1346, 819, 26, 26},
		-- round inches hg to millimeters hg
		adjuster = function(v)
			if v < 1 and v > 0 then
				sasl.al.playSample(rot_click, false)
			end
			if v > 1 then
				v = 1
			elseif v < 0 then
				v = 0
			end
			return v
		end
	}, 
	
	-- contrast rotary
	rotary {
		-- image = rotaryImage;
		value = rls_contr,
		step = 0.1,
		position = {1346, 788, 26, 26},

		-- round inches hg to millimeters hg
		adjuster = function(v)
			if v < 1 and v > 0 then
				sasl.al.playSample(rot_click, false)
			end
			if v > 1 then
				v = 1
			elseif v < 0 then
				v = 0
			end
			return v
		end
	}, 
	
	-- signs rotary
	rotary {
		-- image = rotaryImage;
		value = rls_signs,
		step = 0.1,
		position = {1346, 756, 26, 26},
		-- round inches hg to millimeters hg
		adjuster = function(v)
			if v < 1 and v > 0 then
				sasl.al.playSample(rot_click, false)
			end
			if v > 1 then
				v = 1
			elseif v < 0 then
				v = 0
			end
			return v
		end
	}, 
	
	-- ready led
	textureLit {
		position = {1652, 566, 5, 5},
		image = get(led),
		visible = function()
			return mode_lamp == 0
		end
	}, 
	
	-- ready led
	textureLit {
		position = {1652, 559, 5, 3},
		image = get(led),
		visible = function()
			return mode_lamp == 1
		end
	}, 
	
	-- ready led
	textureLit {
		position = {1652, 551, 5, 4},
		image = get(led),
		visible = function()
			return mode_lamp == 2
		end
	}
}

