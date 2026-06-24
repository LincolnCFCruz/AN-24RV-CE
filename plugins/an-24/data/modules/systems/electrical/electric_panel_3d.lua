-- Electrical 3D-panel RENDER only.
-- Compute (needle inertia, LED logic, cold-start init) lives in electric_panel_logic.lua
-- (registered immediately before this in main.lua); it publishes the an-24/power/ind_*
-- seam datarefs that this module renders. Clickables here drive the input datarefs.
size = {2048, 2048}

-- input datarefs (clickables read/set these; logic consumes them)
defineProperty("stg1_on", globalProperty("an-24/power/stg1_on"))
defineProperty("stg2_on", globalProperty("an-24/power/stg2_on"))
defineProperty("stg1_on_bus", globalProperty("an-24/power/stg1_on_bus"))
defineProperty("stg2_on_bus", globalProperty("an-24/power/stg2_on_bus"))
defineProperty("gs24_on_bus", globalProperty("an-24/power/gs24_on_bus"))
defineProperty("go1_on_bus", globalProperty("an-24/power/go1_on_bus"))
defineProperty("go2_on_bus", globalProperty("an-24/power/go2_on_bus"))
defineProperty("inv_PT1000_1", globalProperty("an-24/power/inv_PT1000_1"))
defineProperty("inv_PT1000_2", globalProperty("an-24/power/inv_PT1000_2"))
defineProperty("inv_PT750", globalProperty("an-24/power/inv_PT750"))
defineProperty("AC_source", globalProperty("an-24/power/AC_source"))
defineProperty("PT1000_mode", globalProperty("an-24/power/PT1000_mode"))
defineProperty("PO750_mode", globalProperty("an-24/power/PO750_mode"))
defineProperty("GS24_mode", globalProperty("an-24/power/GS24_mode"))
defineProperty("power_mode", globalProperty("an-24/power/power_mode"))
defineProperty("emerg_mode", globalProperty("an-24/power/emerg_mode"))
defineProperty("emerg_cap", globalProperty("an-24/power/emerg_cap"))
defineProperty("main_on_emerg", globalProperty("an-24/power/main_on_emerg"))
defineProperty("AC36_volt_mode", globalProperty("an-24/power/AC36_volt_mode"))
defineProperty("AC115_volt_mode", globalProperty("an-24/power/AC115_volt_mode"))
defineProperty("DC_volt_mode", globalProperty("an-24/power/DC_volt_mode"))
defineProperty("STG_disconnect_cap1", globalProperty("an-24/power/STG_disconnect_cap1"))
defineProperty("STG_disconnect_cap2", globalProperty("an-24/power/STG_disconnect_cap2"))

-- published indication seam datarefs (read-only; written by electric_panel_logic.lua)
defineProperty("ind_go_left_amp", globalProperty("an-24/power/ind_go_left_amp"))
defineProperty("ind_go_right_amp", globalProperty("an-24/power/ind_go_right_amp"))
defineProperty("ind_stg_left_amp", globalProperty("an-24/power/ind_stg_left_amp"))
defineProperty("ind_stg_right_amp", globalProperty("an-24/power/ind_stg_right_amp"))
defineProperty("ind_gs_amp", globalProperty("an-24/power/ind_gs_amp"))
defineProperty("ind_bat_amp", globalProperty("an-24/power/ind_bat_amp"))
defineProperty("ind_ac36_volt", globalProperty("an-24/power/ind_ac36_volt"))
defineProperty("ind_ac115_volt", globalProperty("an-24/power/ind_ac115_volt"))
defineProperty("ind_ac115_freq", globalProperty("an-24/power/ind_ac115_freq"))
defineProperty("ind_dc_volt", globalProperty("an-24/power/ind_dc_volt"))
defineProperty("ind_stg_left_fail", globalProperty("an-24/power/ind_stg_left_fail"))
defineProperty("ind_stg_right_fail", globalProperty("an-24/power/ind_stg_right_fail"))
defineProperty("ind_emerg_bus", globalProperty("an-24/power/ind_emerg_bus"))
defineProperty("ind_go_left_fail", globalProperty("an-24/power/ind_go_left_fail"))
defineProperty("ind_go_right_fail", globalProperty("an-24/power/ind_go_right_fail"))
defineProperty("ind_gs24_on_bus", globalProperty("an-24/power/ind_gs24_on_bus"))
defineProperty("ind_ground", globalProperty("an-24/power/ind_ground"))
defineProperty("ind_emerg36", globalProperty("an-24/power/ind_emerg36"))

-- define images
defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))
defineProperty("needles_2", langImage("needles", 18, 158, 13, 98))
defineProperty("needles_3", langImage("needles", 34, 158, 13, 98))
defineProperty("yellow_led", loadLED("yellow"))
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))
defineProperty("red_small_led", loadLED("red_small"))
defineProperty("black_cap", langImage("covers", 0, 17, 56, 56)) -- black cap image

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

-- PT1000 inverter wiring follows the selector position (identical for up/down).
local function setPT1000(a)
    set(PT1000_mode, a)
    if a == 1 then
        set(inv_PT1000_1, 0);
        set(inv_PT1000_2, 0)
    elseif a == 2 then
        set(inv_PT1000_1, 1);
        set(inv_PT1000_2, 0)
    else
        set(inv_PT1000_1, 0);
        set(inv_PT1000_2, 1)
    end
end

-- PO750 inverter + AC-source wiring follows the selector position.
local function setPO750(a)
    set(PO750_mode, a)
    if a == 1 then
        set(inv_PT750, 0);
        set(AC_source, 3)
    elseif a == 2 then
        set(inv_PT750, 1);
        set(AC_source, 3)
    else
        set(inv_PT750, 0);
        set(AC_source, 0)
    end
end

-- components of electric panel
components = { 
	
	------------------
	-- panel lights --
	------------------

--[[
	-- emergency feed on 36v bus
	textureLit {
		image = get(yellow_led),
		position = {698, 270, 17, 17},
		visible = function()
			return emerg36_ON_led
		end,
	},
	textureLit {
		image = get(yellow_led),
		position = {714, 270, 17, 17},
		visible = function()
			return emerg36_ON_led
		end,
	},
--]]

	-- turn on emerg feed
	textureLit {
		image = get(yellow_led),
		position = {731, 270, 17, 17},
		visible = function()
			return get(ind_emerg36) == 1
		end
	}, 
	
	-- GS24 on bus
	textureLit {
		image = get(green_led),
		position = {747, 270, 17, 17},
		visible = function()
			return get(ind_gs24_on_bus) == 1
		end
	}, 
	
	-- ground available
	textureLit {
		image = get(green_led),
		position = {763, 270, 17, 17},
		visible = function()
			return get(ind_ground) == 1
		end
	}, 
	
	textureLit {
		image = get(green_led),
		position = {780, 270, 17, 17},
		visible = function()
			return get(ind_ground) == 1
		end
	}, 
	
	-- STG left fail
	textureLit {
		image = get(red_small_led),
		position = {700, 388, 20, 20},
		visible = function()
			return get(ind_stg_left_fail) == 1
		end
	}, 
	
	-- STG right fail
	textureLit {
		image = get(red_small_led),
		position = {720, 388, 20, 20},
		visible = function()
			return get(ind_stg_right_fail) == 1
		end
	}, 
	
	-- emergency bus
	textureLit {
		image = get(red_small_led),
		position = {740, 388, 20, 20},
		visible = function()
			return get(ind_emerg_bus) == 1
		end
	}, 
	
	-- GO left fail
	textureLit {
		image = get(red_small_led),
		position = {760, 388, 20, 20},
		visible = function()
			return get(ind_go_left_fail) == 1
		end
	}, 
	
	-- GO right fail
	textureLit {
		image = get(red_small_led),
		position = {780, 388, 20, 20},
		visible = function()
			return get(ind_go_right_fail) == 1
		end
	}, 
	
	---------------
	-- switchers --
	---------------

	-- PT1000 switcher (3-state 0..2)
	
	-- switch up
	stepButton {
		position = {1040, 325, 15, 7},
		cursor = Cursors.UP,
		onStep = function()
			local a = get(PT1000_mode)
			if a < 2 then
				playUISound(switch_sound);
				a = a + 1
			end
			setPT1000(a)
		end
	}, 
	
	-- switch down
	stepButton {
		position = {1040, 318, 15, 7},
		cursor = Cursors.DOWN,
		onStep = function()
			local a = get(PT1000_mode)
			if a > 0 then
				playUISound(switch_sound);
				a = a - 1
			end
			setPT1000(a)
		end
	}, 
	
	-- PO750 switcher (3-state 0..2)
	
	-- switcher up
	stepButton {
		position = {1059, 325, 15, 7},
		cursor = Cursors.UP,
		onStep = function()
			local a = get(PO750_mode)
			if a < 2 then
				playUISound(switch_sound);
				a = a + 1
			end
			setPO750(a)
		end
	}, 
	
	-- switcher down
	stepButton {
		position = {1059, 318, 15, 7},
		cursor = Cursors.DOWN,
		onStep = function()
			local a = get(PO750_mode)
			if a > 0 then
				playUISound(switch_sound);
				a = a - 1
			end
			setPO750(a)
		end
	}, 
	
	-- main emergency switcher
	-- switcher cap
	-- cap open
	clickable {
		position = {566, 366, 33, 41}, -- search and set right
		cursor = Cursors.HAND,
		onMouseDown = function()
			sasl.al.playSample(cap_sound, false)
			if get(emerg_cap) < 1 then
				set(emerg_cap, 1)
			elseif get(emerg_cap) == 1 then
				if get(emerg_mode) == 2 then
					set(emerg_cap, 0.1)
				else
					set(emerg_cap, 0)
				end
			end
			return true
		end
	}, 
	
	-- switcher up (cap closed: 0..1; cap open: 0..2)
	stepButton {
		position = {1154, 325, 15, 7},
		cursor = Cursors.UP,
		onStep = function()
			local a = get(emerg_mode)
			if a < 1 and get(emerg_cap) < 0.2 then
				a = a + 1
				playUISound(switch_sound)
			elseif a < 2 and get(emerg_cap) > 0.2 then
				a = a + 1
				playUISound(switch_sound)
			end
			set(emerg_mode, a)
			if a == 1 then
				set(main_on_emerg, 1)
			else
				set(main_on_emerg, 0)
			end
		end
	}, 
	
	-- switcher down
	stepButton {
		position = {1154, 318, 15, 7},
		cursor = Cursors.DOWN,
		onStep = function()
			local a = get(emerg_mode)
			if a < 2 and a > 0 and get(emerg_cap) < 0.2 then
				a = a - 1
				playUISound(switch_sound)
			elseif a > 0 and get(emerg_cap) > 0.2 then
				a = a - 1
				playUISound(switch_sound)
			end
			set(emerg_mode, a)
			if a == 1 then
				set(main_on_emerg, 1)
			else
				set(main_on_emerg, 0)
			end
		end
	}, 
	
	-- GO left / right bus switchers
	toggleSwitch {
		position = {1078, 318, 15, 14},
		drf = go1_on_bus,
		sound = switch_sound
	}, 
	
	toggleSwitch {
		position = {1097, 318, 15, 14},
		drf = go2_on_bus,
		sound = switch_sound
	}, 
	
	-- STG left / right bus switchers
	toggleSwitch {
		position = {1003, 299, 15, 14},
		drf = stg1_on_bus,
		sound = switch_sound
	}, 
	
	toggleSwitch {
		position = {1021, 299, 15, 14},
		drf = stg2_on_bus,
		sound = switch_sound
	}, 
	
	-- GS24 bus switcher
	toggleSwitch {
		position = {1040, 299, 15, 14},
		drf = gs24_on_bus,
		sound = switch_sound
	}, 
	
	-- STG on engine cap left
	toggleSwitch {
		position = {825, 507, 20, 35},
		drf = STG_disconnect_cap1,
		sound = cap_sound
	}, 
	
	-- STG on engine left switcher (only acts while its cap is open)
	toggleSwitch {
		position = {757, 498, 20, 20},
		drf = stg1_on,
		sound = btn_click,
		guard = function()
			return get(STG_disconnect_cap1) > 0
		end
	}, 
	
	-- STG on engine cap right
	toggleSwitch {
		position = {849, 507, 20, 35},
		drf = STG_disconnect_cap2,
		sound = cap_sound
	}, -- STG on engine right switcher (only acts while its cap is open)
	toggleSwitch {
		position = {778, 498, 20, 20},
		drf = stg2_on,
		sound = btn_click,
		guard = function()
			return get(STG_disconnect_cap2) > 0
		end
	}, 
	
	-- AC36_volt_mode voltmeter switcher (0..8, auto-repeats)
	-- switcher up
	stepButton {
		position = {879, 240, 13, 26},
		cursor = Cursors.ROTATE_RIGHT,
		repeating = true,
		onStep = function()
			local a = get(AC36_volt_mode)
			if a < 8 then
				playUISound(plastic_sound);
				a = a + 1
			end
			set(AC36_volt_mode, a)
		end
	}, 
	
	-- switcher down
	stepButton {
		position = {866, 240, 13, 26},
		cursor = Cursors.ROTATE_LEFT,
		repeating = true,
		onStep = function()
			local a = get(AC36_volt_mode)
			if a > 0 then
				playUISound(plastic_sound);
				a = a - 1
			end
			set(AC36_volt_mode, a)
		end
	}, 
	
	-- AC115_volt_mode voltmeter switcher (0..6, wraps, auto-repeats)
	-- switcher up
	stepButton {
		position = {972, 240, 13, 26},
		cursor = Cursors.ROTATE_RIGHT,
		repeating = true,
		onStep = function()
			local a = get(AC115_volt_mode)
			playUISound(plastic_sound)
			a = a + 1
			if a > 6 then
				a = 0
			end
			set(AC115_volt_mode, a)
		end
	}, 
	
	-- switcher down
	stepButton {
		position = {960, 240, 13, 26},
		cursor = Cursors.ROTATE_LEFT,
		repeating = true,
		onStep = function()
			local a = get(AC115_volt_mode)
			playUISound(plastic_sound)
			a = a - 1
			if a < 0 then
				a = 6
			end
			set(AC115_volt_mode, a)
		end
	}, 
	
	-- DC_volt_mode voltmeter switcher (0..10, auto-repeats)
	-- switcher up
	stepButton {
		position = {1003, 240, 13, 26},
		cursor = Cursors.ROTATE_RIGHT,
		repeating = true,
		onStep = function()
			local a = get(DC_volt_mode)
			if a < 10 then
				playUISound(plastic_sound);
				a = a + 1
			end
			set(DC_volt_mode, a)
		end
	}, 
	
	-- switcher down
	stepButton {
		position = {990, 240, 13, 26},
		cursor = Cursors.ROTATE_LEFT,
		repeating = true,
		onStep = function()
			local a = get(DC_volt_mode)
			if a > 0 then
				playUISound(plastic_sound);
				a = a - 1
			end
			set(DC_volt_mode, a)
		end
	}, 
	
	-- power mode / GS24 (3-state 0..2; also drives power_mode)
	-- switcher up
	stepButton {
		position = {1061, 306, 30, 7},
		cursor = Cursors.UP,
		onStep = function()
			local a = get(GS24_mode)
			if a < 2 then
				playUISound(switch_sound);
				a = a + 1
			end
			set(GS24_mode, a)
			set(power_mode, a)
		end
	}, 
	
	-- switcher down
	stepButton {
		position = {1061, 299, 30, 7},
		cursor = Cursors.DOWN,
		onStep = function()
			local a = get(GS24_mode)
			if a > 0 then
				playUISound(switch_sound);
				a = a - 1
			end
			set(GS24_mode, a)
			set(power_mode, a)
		end
	}, 
	
	-----------------------
	-- needle indicators --
	-----------------------
	
	-- GO left ampermeter
	needle {
		image = function()
			return get(needles_3)
		end,
		position = {1301, 920, 98, 98},
		angle = function()
			return get(ind_go_left_amp)
		end
	}, 
	
	-- GO right ampermeter
	needle {
		image = function()
			return get(needles_3)
		end,
		position = {1202, 823, 98, 98},
		angle = function()
			return get(ind_go_right_amp)
		end
	}, 
	
	-- STG left ampermeter
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1305, 853, 88, 88},
		angle = function()
			return get(ind_stg_left_amp)
		end
	}, 
	
	-- black cap
	texture {
		position = {1332, 876, 42, 42},
		image = function()
			return get(black_cap)
		end
	}, 
	
	-- STG right ampermeter
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1405, 952, 88, 88},
		angle = function()
			return get(ind_stg_right_amp)
		end
	}, 
	
	-- black cap
	texture {
		position = {1432, 975, 42, 42},
		image = function()
			return get(black_cap)
		end
	}, 
	
	-- GS24 ampermeter
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1505, 952, 88, 88},
		angle = function()
			return get(ind_gs_amp)
		end
	}, 
	
	-- black cap
	texture {
		position = {1532, 975, 42, 42},
		image = function()
			return get(black_cap)
		end
	}, 
	
	-- BAT ampermeter
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1405, 853, 88, 88},
		angle = function()
			return get(ind_bat_amp)
		end
	}, 
	
	-- black cap
	texture {
		position = {1432, 875, 42, 42},
		image = function()
			return get(black_cap)
		end
	}, 
	
	-- AC36 voltmeter
	needle {
		image = function()
			return get(needles_3)
		end,
		position = {1002, 822, 98, 98},
		angle = function()
			return get(ind_ac36_volt)
		end
	}, 
	
	-- AC115 voltmeter
	needle {
		image = function()
			return get(needles_3)
		end,
		position = {1202, 920, 98, 98},
		angle = function()
			return get(ind_ac115_volt)
		end
	}, 
	
	-- AC115 freq-meter
	needle {
		image = function()
			return get(needles_3)
		end,
		position = {1100, 822, 98, 98},
		angle = function()
			return get(ind_ac115_freq)
		end
	}, 
	
	-- DC27 voltmeter
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1507, 853, 88, 88},
		angle = function()
			return get(ind_dc_volt)
		end
	}, 
	
	-- black cap
	texture {
		position = {1532, 875, 42, 42},
		image = function()
			return get(black_cap)
		end
	}
}
