-- Propeller 3D-panel RENDER only — feather/pitch-stop controls + feather/KFL/stop lamps.
-- Compute (pitch, autofeather, beta range, lamp logic) lives in prop_logic.lua, registered
-- immediately before this in main.lua. The feather TEST clickables write the
-- an-24/prop/feather_left_test / feather_right_test datarefs that prop_logic reads; the lamps
-- read the an-24/prop/ind_* datarefs prop_logic publishes.
size = {2048, 2048}

-- controls
defineProperty("feather_test_cap", globalProperty("an-24/prop/feather_test_cap"))
defineProperty("pitch_stop", globalProperty("an-24/prop/pitch_stop"))
defineProperty("pitch_stop_cap", globalProperty("an-24/prop/pitch_stop_cap"))
defineProperty("feather1_test1", globalProperty("an-24/prop/feather1_test1"))
defineProperty("feather2_test1", globalProperty("an-24/prop/feather2_test1"))
defineProperty("feather1_test2", globalProperty("an-24/prop/feather1_test2"))
defineProperty("feather2_test2", globalProperty("an-24/prop/feather2_test2"))
defineProperty("feather1_button", globalProperty("an-24/prop/feather1_button"))
defineProperty("feather2_button", globalProperty("an-24/prop/feather2_button"))
-- feather-test state consumed by prop_logic (promoted from locals)
defineProperty("feather_left_test", globalProperty("an-24/prop/feather_left_test"))
defineProperty("feather_right_test", globalProperty("an-24/prop/feather_right_test"))

-- published lamp seam datarefs (read-only; written by prop_logic.lua)
defineProperty("ind_left_exit_feather", globalProperty("an-24/prop/ind_left_exit_feather"))
defineProperty("ind_right_exit_feather", globalProperty("an-24/prop/ind_right_exit_feather"))
defineProperty("ind_left_ready", globalProperty("an-24/prop/ind_left_ready"))
defineProperty("ind_right_ready", globalProperty("an-24/prop/ind_right_ready"))
defineProperty("ind_left_feather", globalProperty("an-24/prop/ind_left_feather"))
defineProperty("ind_right_feather", globalProperty("an-24/prop/ind_right_feather"))
defineProperty("ind_kfl_left", globalProperty("an-24/prop/ind_kfl_left"))
defineProperty("ind_kfl_right", globalProperty("an-24/prop/ind_kfl_right"))
defineProperty("ind_stop_lamp", globalProperty("an-24/prop/ind_stop_lamp"))

-- images
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

components = { 
	--------------
	-- controls --
	--------------

	-- feather test cap switch
	toggleSwitch {
		position = {923, 466, 22, 30},
		drf = feather_test_cap,
		sound = cap_sound
	}, 
	
	-- pitch stop cap switch (closing the cap engages the pitch stop)
	toggleSwitch {
		position = {950, 452, 50, 94},
		drf = pitch_stop_cap,
		sound = cap_sound,
		onToggle = function(nv)
			if nv == 0 then
				set(pitch_stop, 1)
			end
		end
	}, 
	
	-- pitch stop switch (only acts while its cap is open)
	toggleSwitch {
		position = {1041, 373, 16, 16},
		drf = pitch_stop,
		sound = switch_sound,
		guard = function()
			return get(pitch_stop_cap) == 1
		end
	}, 
	
	-- left test 1 switch
	clickable {
		position = {1021, 280, 17, 17},

		cursor = Cursors.HAND,

		onMouseDown = function()
			set(feather1_test1, 1)
			set(feather_left_test, 1)
			sasl.al.playSample(btn_click, false)
			return true
		end,
		onMouseUp = function()
			set(feather1_test1, 0)
			set(feather_left_test, 0)
			sasl.al.playSample(btn_click, false)
			return true
		end
	}, 
	
	-- right test 1 switch
	clickable {
		position = {1040, 280, 17, 17},

		cursor = Cursors.HAND,

		onMouseDown = function()
			set(feather2_test1, 1)
			set(feather_right_test, 1)
			sasl.al.playSample(btn_click, false)
			return true
		end,
		onMouseUp = function()
			set(feather2_test1, 0)
			set(feather_right_test, 0)
			sasl.al.playSample(btn_click, false)
			return true
		end
	}, 
	
	-- left test 2 switch
	clickable {
		position = {1059, 280, 17, 17},

		cursor = Cursors.HAND,

		onMouseDown = function()
			set(feather1_test2, 1)
			set(feather_left_test, 1)
			sasl.al.playSample(btn_click, false)
			return true
		end,
		onMouseUp = function()
			set(feather1_test2, 0)
			set(feather_left_test, 0)
			sasl.al.playSample(btn_click, false)
			return true
		end
	}, 
	
	-- right test 2 switch
	clickable {
		position = {1080, 280, 17, 17},

		cursor = Cursors.HAND,

		onMouseDown = function()
			set(feather2_test2, 1)
			set(feather_right_test, 1)
			sasl.al.playSample(btn_click, false)
			return true
		end,
		onMouseUp = function()
			set(feather2_test2, 0)
			set(feather_right_test, 0)
			sasl.al.playSample(btn_click, false)
			return true
		end
	}, 
	
	-- left / right red feather buttons
	toggleSwitch {
		position = {417, 269, 42, 84},
		drf = feather1_button,
		sound = switch_sound
	}, toggleSwitch {
		position = {460, 269, 42, 84},
		drf = feather2_button,
		sound = switch_sound
	}, 
	
	-----------
	-- lamps --
	-----------
	
	-- exit from feather left
	textureLit {
		image = get(green_led),
		position = {600, 255, 17, 17},
		visible = function()
			return get(ind_left_exit_feather) == 1
		end
	}, 
	
	-- exit from feather right
	textureLit {
		image = get(green_led),
		position = {616.5, 255, 17, 17},
		visible = function()
			return get(ind_right_exit_feather) == 1
		end
	}, 
	
	-- feather left ready
	textureLit {
		image = get(green_led),
		position = {633, 255, 17, 17},
		visible = function()
			return get(ind_left_ready) == 1
		end
	}, 
	
	-- feather right ready
	textureLit {
		image = get(green_led),
		position = {649, 255, 17, 17},
		visible = function()
			return get(ind_right_ready) == 1
		end
	}, 
	
	-- feather left
	textureLit {
		image = get(red_led),
		position = {665.5, 255, 17, 17},
		visible = function()
			return get(ind_left_feather) == 1
		end
	}, 
	
	-- feather right
	textureLit {
		image = get(red_led),
		position = {681, 255, 17, 17},
		visible = function()
			return get(ind_right_feather) == 1
		end
	}, 
	
	-- kfl left
	textureLit {
		image = get(red_led),
		position = {427, 322, 18, 18},
		visible = function()
			return get(ind_kfl_left) == 1
		end
	}, 
	
	-- kfl right
	textureLit {
		image = get(red_led),
		position = {472, 322, 18, 18},
		visible = function()
			return get(ind_kfl_right) == 1
		end
	}, 
	
	-- left prop not on stop
	textureLit {
		image = get(red_led),
		position = {680, 408, 20, 20},
		visible = function()
			return get(ind_stop_lamp) == 1
		end
	}, 
	
	-- right prop not on stop
	textureLit {
		image = get(red_led),
		position = {700, 408, 20, 20},
		visible = function()
			return get(ind_stop_lamp) == 1
		end
	}
}
