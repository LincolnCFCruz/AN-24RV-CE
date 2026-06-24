-- this is 3D panel for start engines
size = {2048, 2048}

-- define property table
-- custom datarefs

defineProperty("eng_start_btn", globalProperty("an-24/start/eng_start_btn")) -- start selected engine
defineProperty("start_at_ground_cap", globalProperty("an-24/start/start_at_ground_cap")) -- select start mode cap
defineProperty("start_at_ground", globalProperty("an-24/start/start_at_ground")) -- select start mode
defineProperty("sel_left_right", globalProperty("an-24/start/sel_left_right")) -- select engine to start. -1 - left, 0 - none, +1 - right
defineProperty("eng_start_mode", globalProperty("an-24/start/eng_start_mode")) -- select start mode. start or fail start
defineProperty("eng_start_stop", globalProperty("an-24/start/eng_start_stop")) -- button for stop start process
defineProperty("left_temp_check", globalProperty("an-24/start/left_temp_check")) -- select temp check mode
defineProperty("left_prt24_on", globalProperty("an-24/start/left_prt24_on")) -- PRT24 on
defineProperty("right_temp_check", globalProperty("an-24/start/right_temp_check")) -- select temp check mode
defineProperty("right_prt24_on", globalProperty("an-24/start/right_prt24_on")) -- PRT24 on

defineProperty("ru19_air_start_btn", globalProperty("an-24/start/ru19_air_start_btn")) -- start at flight button
defineProperty("ru19_ground_start_btn", globalProperty("an-24/start/ru19_ground_start_btn")) -- start on ground button
defineProperty("ru19_ground_start_cap", globalProperty("an-24/start/ru19_ground_start_cap")) -- start on ground button cap
defineProperty("ru19_start_mode", globalProperty("an-24/start/ru19_start_mode")) -- select start mode. start or fail start
defineProperty("ru19_start_stop", globalProperty("an-24/start/ru19_start_stop")) -- stop button for ru19
defineProperty("ru19_start_main_sw", globalProperty("an-24/start/ru19_start_main_sw")) --   -- main switcher for ru19
defineProperty("ru19_start_main_sw_cap", globalProperty("an-24/start/ru19_start_main_sw_cap")) -- main switcher for ru19

defineProperty("panel_cap", globalProperty("sim/cockpit2/switches/custom_slider_on[13]")) -- cap operation

defineProperty("apd_work_lit", globalProperty("an-24/start/apd_work_lit")) -- lamp for apd
defineProperty("pt29_work_lit", globalProperty("an-24/start/pt29_work_lit")) -- lamp for ru19 starter
defineProperty("strip_lit", globalProperty("an-24/start/strip_lit")) -- lamp for ru19 starter

defineProperty("starter_volt", globalProperty("an-24/start/starter_volt")) -- starter voltage for engines start
defineProperty("starter_amp", globalProperty("an-24/start/starter_amp")) -- starter amperage for engines start

defineProperty("sim_run_time", globalProperty("sim/time/total_running_time_sec")) -- flight time

-- images
defineProperty("white_led", loadLED("white"))
defineProperty("green_led", loadLED("green"))

defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))
defineProperty("needles_thin", langImage("needles", 336, 43, 1, 110))
defineProperty("black_cap", langImage("covers", 0, 17, 56, 56)) -- black cap image

local amp_angle = -110
local volt_angle = -45
local pt_work_light = get(pt29_work_lit) == 1
local apd_work_light = get(apd_work_lit) == 1
local strip_light = true

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

function update()

    amp_angle = get(starter_amp) * 217 / 1000 - 100
    volt_angle = get(starter_volt) * 90 / 75 - 45
    pt_work_light = get(pt29_work_lit) == 1
    apd_work_light = get(apd_work_lit) == 1
    strip_light = get(strip_lit) == 1

end

components = { 
	-------------------
	-- needle gauges --
	-------------------

	-- ampermeter
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1305, 1150, 90, 90},
		angle = function()
			return amp_angle
		end
	}, 
	
	-- black cap
	texture {
		position = {1330, 1175, 42, 42},
		image = function()
			return get(black_cap)
		end
	}, 
	
	-- start voltmeter
	needle {
		image = function()
			return get(needles_thin)
		end,
		position = {196, 916, 110, 110},
		angle = function()
			return volt_angle
		end
	}, 
	
	-- prt24 voltmeter
	needle {
		image = function()
			return get(needles_thin)
		end,
		position = {196, 817, 110, 110},
		angle = function()
			return -45
		end
	}, 
	
	-- prt24 voltmeter
	needle {
		image = function()
			return get(needles_thin)
		end,
		position = {296, 817, 110, 110},
		angle = function()
			return -45
		end
	}, 
	
	------------
	-- lights --
	------------

	-- pt29 work
	textureLit {
		image = get(green_led),
		position = {740, 407, 20, 20},
		visible = function()
			return pt_work_light
		end
	}, 
	
	-- strip open work
	textureLit {
		image = get(green_led),
		position = {760, 407, 20, 20},
		visible = function()
			return strip_light
		end
	}, 
	
	-- apd work
	textureLit {
		image = get(white_led),
		position = {660, 428, 20, 20},
		visible = function()
			return apd_work_light
		end
	}, 
	
	-------------------
	-- engines start --
	-------------------

	-- big cap (closing it also re-caps the ground/air selector)
	toggleSwitch {
		position = {869, 201, 20, 44},
		drf = panel_cap,
		onToggle = function(nv)
			if nv == 0 then
				set(start_at_ground_cap, 0)
			end
		end
	}, 
	
	-- engine start button (momentary)
	momentaryButton {
		position = {689, 523, 20, 20},
		drf = eng_start_btn,
		sound = btn_click,
		soundUp = btn_click
	}, 
	
	-- cap for ground/air start selector (closing it also turns the selector off)
	toggleSwitch {
		position = {34, 491, 32, 40},
		drf = start_at_ground_cap,
		sound = cap_sound,
		onToggle = function(nv)
			if nv == 0 then
				set(start_at_ground, 0)
			end
		end
	}, 
	
	-- ground/air start selector (only acts while its cap is open)
	toggleSwitch {
		position = {880, 364, 18, 18},
		drf = start_at_ground,
		sound = switch_sound,
		guard = function()
			return get(start_at_ground_cap) == 1
		end
	}, 
	
	-- engine selector (3-state, only acts while the big cap is open)
	
	-- select left
	stepButton {
		position = {908, 364, 8, 18},
		cursor = Cursors.UP,
		onStep = function()
			local a = get(sel_left_right)
			if a > -1 and get(panel_cap) ~= 0 then
				playUISound(switch_sound);
				a = a - 1
			end
			set(sel_left_right, a)
		end
	}, 
	
	-- select right
	stepButton {
		position = {900, 364, 8, 18},
		cursor = Cursors.DOWN,
		onStep = function()
			local a = get(sel_left_right)
			if a < 1 and get(panel_cap) ~= 0 then
				playUISound(switch_sound);
				a = a + 1
			end
			set(sel_left_right, a)
		end
	}, 
	
	-- engine start mode - cold rotate/start (only acts while the big cap is open)
	toggleSwitch {
		position = {918, 364, 18, 18},
		drf = eng_start_mode,
		sound = switch_sound,
		guard = function()
			return get(panel_cap) ~= 0
		end
	}, 
	
	-- stop button
	clickable {
		position = {876, 511, 30, 30}, -- search and set right
		cursor = Cursors.HAND,
		onMouseDown = function()
			set(eng_start_stop, 1)
			if get(panel_cap) ~= 0 then
				sasl.al.playSample(btn_click, false)
			end
			return true
		end,
		onMouseUp = function()
			set(eng_start_stop, 0)
			sasl.al.playSample(btn_click, false)
			return true
		end
	}, 
	
	-- left PRT24 (only acts while the big cap is open)
	toggleSwitch {
		position = {956, 364, 18, 18},
		drf = left_prt24_on,
		sound = switch_sound,
		guard = function()
			return get(panel_cap) ~= 0
		end
	}, 
	
	-- right PRT24 (only acts while the big cap is open)
	toggleSwitch {
		position = {975, 364, 18, 18},
		drf = right_prt24_on,
		sound = switch_sound,
		guard = function()
			return get(panel_cap) ~= 0
		end
	}, 
	
	-- left engine temp check (3-state, only acts while the big cap is open)
	
	-- select up
	stepButton {
		position = {936, 373, 18, 8},
		cursor = Cursors.UP,
		onStep = function()
			local a = get(left_temp_check)
			if a > -1 and get(panel_cap) ~= 0 then
				playUISound(switch_sound);
				a = a - 1
			end
			set(left_temp_check, a)
		end
	}, 
	
	-- select down
	stepButton {
		position = {936, 365, 18, 8},
		cursor = Cursors.DOWN,
		onStep = function()
			local a = get(left_temp_check)
			if a < 1 and get(panel_cap) ~= 0 then
				playUISound(switch_sound);
				a = a + 1
			end
			set(left_temp_check, a)
		end
	}, 
	
	-- right engine temp check (3-state, only acts while the big cap is open)
	
	-- select up
	stepButton {
		position = {813, 345, 8, 18},
		cursor = Cursors.UP,
		onStep = function()
			local a = get(right_temp_check)
			if a > -1 and get(panel_cap) ~= 0 then
				playUISound(switch_sound);
				a = a - 1
			end
			set(right_temp_check, a)
		end
	}, 
	
	-- select down
	stepButton {
		position = {805, 345, 8, 18},
		cursor = Cursors.DOWN,
		onStep = function()
			local a = get(right_temp_check)
			if a < 1 and get(panel_cap) ~= 0 then
				playUISound(switch_sound);
				a = a + 1
			end
			set(right_temp_check, a)
		end
	}, 
	
	-----------------
	-- RU-19 start --
	-----------------

	-- start button cap
	toggleSwitch {
		position = {802, 506, 22, 39},
		drf = ru19_ground_start_cap,
		sound = cap_sound
	}, 

--[[
	-- start button
	clickable {
		position = {709, 523, 20, 20},  -- search and set right
		cursor = Cursors.HAND,
		onMouseDown = function()
			if get(ru19_ground_start_cap) == 1 then
				set(ru19_ground_start_btn, 1)
				sasl.al.playSample(btn_click, false)
			end
			return true
		end,
		onMouseUp = function()
			set(ru19_ground_start_btn, 0)
			sasl.al.playSample(btn_click, false)
			return true
		end
	},
--]] 
	
	-- mode selector
	toggleSwitch {
		position = {822, 345, 18, 18},
		drf = ru19_start_mode,
		sound = switch_sound
	}, 
	
	-- stop button (momentary)
	momentaryButton {
		position = {913, 511, 30, 30},
		drf = ru19_start_stop,
		sound = btn_click,
		soundUp = btn_click
	}, 
	
	-- main switcher cap (closing it also turns the main switcher off)
	toggleSwitch {
		position = {94, 491, 32, 40},
		drf = ru19_start_main_sw_cap,
		sound = cap_sound,
		onToggle = function(nv)
			if nv == 0 then
				set(ru19_start_main_sw, 0)
			end
		end
	}, 
	
	-- main switcher (only acts/visible while its cap is open)
	toggleSwitch {
		position = {879, 345, 18, 18},
		drf = ru19_start_main_sw,
		sound = switch_sound,
		guard = function()
			return get(ru19_start_main_sw_cap) == 1
		end,
		visible = function()
			return get(ru19_start_main_sw_cap) == 1
		end
	}
}