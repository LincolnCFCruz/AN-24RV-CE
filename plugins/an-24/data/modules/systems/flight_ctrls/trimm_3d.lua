-- Trim 3D-panel RENDER only — trim-off / centered lamps, elevator-trim needles, and the
-- aileron/rudder trim clickables. Compute lives in trimm_logic.lua (registered before this);
-- it publishes the an-24/trimm/ind_* seam datarefs this module renders/gates on.
size = {2048, 2048}

-- inputs the clickables drive / read
defineProperty("rudd_sw", globalProperty("an-24/trimm/rudd_sw"))
defineProperty("ail_sw", globalProperty("an-24/trimm/ail_sw"))
defineProperty("sim_rudd_trimm", globalProperty("sim/cockpit2/controls/rudder_trim"))
defineProperty("sim_ail_trimm", globalProperty("sim/cockpit2/controls/aileron_trim"))

-- published seam datarefs (read-only; written by trimm_logic.lua)
defineProperty("ind_power", globalProperty("an-24/trimm/ind_power"))
defineProperty("ind_rudd_center", globalProperty("an-24/trimm/ind_rudd_center"))
defineProperty("ind_ail_center", globalProperty("an-24/trimm/ind_ail_center"))
defineProperty("ind_rudd_trimm_off", globalProperty("an-24/trimm/ind_rudd_trimm_off"))
defineProperty("ind_ail_trimm_off", globalProperty("an-24/trimm/ind_ail_trimm_off"))
defineProperty("ind_needle_pos", globalProperty("an-24/trimm/ind_needle_pos"))

-- images
defineProperty("green_led", loadLED("green"))
defineProperty("left_needle", langImage("needles", 340, 72, 27, 35))
defineProperty("right_needle", langImage("needles", 372, 72, 27, 35))

local switch_sound = loadSample('sounds/custom/metal_switch.wav')

components = { 
	------------
	-- lights --
	------------

	-- aileron trimm off
	textureLit {
		image = get(green_led),
		position = {640, 308, 20, 20},
		visible = function()
			return get(ind_ail_trimm_off) == 1
		end
	}, 
	
	-- rudder trimm off
	textureLit {
		image = get(green_led),
		position = {620, 308, 20, 20},
		visible = function()
			return get(ind_rudd_trimm_off) == 1
		end
	}, 
	
	-- aileron trimm center
	textureLit {
		image = get(green_led),
		position = {660, 308, 20, 20},
		visible = function()
			return get(ind_ail_center) == 1
		end
	}, 
	
	-- rudder trimm center
	textureLit {
		image = get(green_led),
		position = {680, 308, 20, 20},
		visible = function()
			return get(ind_rudd_center) == 1
		end
	}, 
	
	-- elevator trimm position
	free_texture {
		image = function()
			return get(left_needle)
		end,
		position_x = 0,
		position_y = function()
			return 170 + get(ind_needle_pos)
		end,
		width = 27,
		height = 35
	}, 
	
	-- elevator trimm position
	free_texture {
		image = function()
			return get(right_needle)
		end,
		position_x = 190,
		position_y = function()
			return 170 + get(ind_needle_pos)
		end,
		width = 27,
		height = 35
	}, 
	
	----------------
	-- clickables --
	----------------

	-- aileron trimm switcher
	-- switcher left
	clickable {
		position = {1079, 373, 8, 17}, -- search and set right
		cursor = Cursors.ROTATE_LEFT,
		onMouseDown = function()
			if get(ind_power) == 1 and get(ind_ail_trimm_off) == 0 then
				local a = get(sim_ail_trimm)
				if a > -1 then
					sasl.al.playSample(switch_sound, false)
					a = a - 0.01
				end
				if math.abs(a) < 0.005 then
					a = 0
				end
				set(sim_ail_trimm, a)
			end
			set(ail_sw, -1)
			return true
		end,
		onMouseUp = function()
			set(ail_sw, 0)
			sasl.al.playSample(switch_sound, false)
			return true
		end
	}, 
	
	-- switcher right
	clickable {
		position = {1087, 373, 8, 17}, -- search and set right
		cursor = Cursors.ROTATE_RIGHT,
		onMouseDown = function()
			if get(ind_power) == 1 and get(ind_ail_trimm_off) == 0 then
				local a = get(sim_ail_trimm)
				if a < 1 then
					sasl.al.playSample(switch_sound, false)
					a = a + 0.01
				end
				if math.abs(a) < 0.005 then
					a = 0
				end
				set(sim_ail_trimm, a)
			end
			set(ail_sw, 1)
			return true
		end,
		onMouseUp = function()
			set(ail_sw, 0)
			sasl.al.playSample(switch_sound, false)
			return true
		end
	}, 
	
	-- rudder trimm switcher
	-- switcher left
	clickable {
		position = {1097, 373, 8, 17}, -- search and set right
		cursor = Cursors.ROTATE_LEFT,
		onMouseDown = function()
			if get(ind_power) == 1 and get(ind_rudd_trimm_off) == 0 then
				local a = get(sim_rudd_trimm)
				if a > -1 then
					sasl.al.playSample(switch_sound, false)
					a = a - 0.01
				end
				if math.abs(a) < 0.005 then
					a = 0
				end
				set(sim_rudd_trimm, a)
			end
			set(rudd_sw, -1)
			return true
		end,
		onMouseUp = function()
			set(rudd_sw, 0)
			sasl.al.playSample(switch_sound, false)
			return true
		end
	}, 
	
	-- switcher right
	clickable {
		position = {1106, 373, 8, 17}, -- search and set right
		cursor = Cursors.ROTATE_RIGHT,
		onMouseDown = function()
			if get(ind_power) == 1 and get(ind_rudd_trimm_off) == 0 then
				local a = get(sim_rudd_trimm)
				if a < 1 then
					sasl.al.playSample(switch_sound, false)
					a = a + 0.01
				end
				if math.abs(a) < 0.005 then
					a = 0
				end
				set(sim_rudd_trimm, a)
			end
			set(rudd_sw, 1)
			return true
		end,
		onMouseUp = function()
			set(rudd_sw, 0)
			sasl.al.playSample(switch_sound, false)
			return true
		end
	}
}
