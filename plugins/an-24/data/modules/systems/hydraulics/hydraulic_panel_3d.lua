-- this is indication of hydraulic system
size = {2048, 2048} -- panel will contain a several gauges in different plases of panel texture

-- define properties
defineProperty("main_press", globalProperty("an-24/hydro/main_press")) -- pressure in main system. initial 120 kg per square sm. maximum 160.
defineProperty("emerg_press", globalProperty("an-24/hydro/emerg_press")) -- pressure in emergency system. initial 120 kg per square sm. maximum 160.
defineProperty("hydro_quantity", globalProperty("an-24/hydro/hydro_quantity")) -- quantity of hydraulic liquid. initially 28 liters. in work downs to 21 liters. also can flow out in come case of failure.
defineProperty("hydro_store", globalProperty("an-24/hydro/hydro_store")) -- pressure in main hydro storage
defineProperty("hydro_circle", globalProperty("an-24/hydro/hydro_circle")) -- connect main and emergency feeds
defineProperty("brake1", globalProperty("an-24/hydro/brake_left")) -- gear brake ratio. 0 = min, 1 = max
defineProperty("brake2", globalProperty("an-24/hydro/brake_right")) -- gear brake ratio. 0 = min, 1 = max
defineProperty("block_brake", globalProperty("an-24/hydro/park_brake")) -- blocks brakes
defineProperty("brake_press", globalProperty("an-24/hydro/brake_press")) -- pressure in braking system
defineProperty("flap_deg1", globalProperty("sim/flightmodel2/wing/flap1_deg[0]")) -- left flap deg
defineProperty("flap_deg2", globalProperty("sim/flightmodel2/wing/flap1_deg[1]")) -- right flap deg

defineProperty("gear_valve", globalProperty("an-24/hydro/gear_valve")) -- position of gear valve for gydraulic calculations and animations.
defineProperty("gear_rotary", globalProperty("an-24/hydro/gear_rotary")) -- position of gear valve for gydraulic calculations and animations.
defineProperty("gear_unblock", globalProperty("an-24/hydro/gear_unblock")) -- remove block from gear retraction on ground
defineProperty("gear_unblock_cap", globalProperty("an-24/hydro/gear_unblock_cap")) -- remove block from gear retraction on ground
defineProperty("flaps_valve", globalProperty("an-24/hydro/flaps_valve")) -- position of flaps valve for gydraulic calculations and animations.
defineProperty("flaps_rotary", globalProperty("an-24/hydro/flaps_rotary")) -- position of flaps valve for gydraulic calculations and animations.
defineProperty("flaps_valve_emerg", globalProperty("an-24/hydro/flaps_valve_emerg")) -- position of emergency flaps valve for gydraulic calculations and animations.
defineProperty("flaps_valve_emerg_cap", globalProperty("an-24/hydro/flaps_valve_emerg_cap")) -- position of emergency flaps valve for gydraulic calculations and animations.
defineProperty("emerg_pump_sw", globalProperty("an-24/hydro/emerg_pump_sw")) -- emergency hydro pump switcher. if its ON and power exist - emergency bus will gain pressure

defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))
-- for 2D
defineProperty("main_press_angle_2d", globalProperty("an-24/hydro/main_press_angle"))
defineProperty("emerg_press_angle_2d", globalProperty("an-24/hydro/emerg_press_angle"))
defineProperty("store_press_angle_2d", globalProperty("an-24/hydro/store_press_angle"))
defineProperty("left_press_angle_2d", globalProperty("an-24/hydro/left_press_angle"))
defineProperty("right_press_angle_2d", globalProperty("an-24/hydro/right_press_angle"))
defineProperty("hydro_quantity_angle_2d", globalProperty("an-24/hydro/hydro_quantity_angle"))

-- define images
defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))
defineProperty("needles_2", langImage("needles", 18, 158, 13, 98))
defineProperty("needles_3", langImage("needles", 34, 158, 13, 98))
defineProperty("needles_4", langImage("needles", 0, 26, 15, 142))
defineProperty("needles_5", langImage("needles", 16, 47, 16, 98))

defineProperty("yellow_led", loadLED("yellow"))
defineProperty("grey_cap", langImage("covers", 406, 72, 56, 56))

defineProperty("black_cap1", langImage("covers", 264, 2, 77, 59))
defineProperty("black_cap2", langImage("covers", 138, 9, 57, 60))
defineProperty("black_cap3", langImage("covers", 202, 8, 57, 60))

-- commands
flaps_command_up = findCommand("sim/flight_controls/flaps_up")
flaps_command_down = findCommand("sim/flight_controls/flaps_down")
gear_command_up = findCommand("sim/flight_controls/landing_gear_up")
gear_command_down = findCommand("sim/flight_controls/landing_gear_down")

-- initial switchers values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

local time_counter = 0
local not_loaded = true

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

local emerg_press_angle = -60
local store_press_angle = -105
local main_press_angle = 195
local quantity_angle = -110
local brake_1_angle = 195
local brake_2_angle = -105
local power = 0
local power115 = 0
local flap_ind_angle = 0
local emerg_pump_led = false

-- ═══════════════════════════════════════════════════════════════════════════
-- HYDRAULIC PRESSURE GAUGE NEEDLE INERTIA (realistic movement)
-- ═══════════════════════════════════════════════════════════════════════════
-- Real An-24 pressure gauges are Bourdon-tube mechanisms: the needle has
-- inertia, approaches the value smoothly and pulses slightly from the pump.
-- We smooth the needle angles (the underlying values are untouched — smoothing only).
-- NEEDLE_SPEED kept the same as the electric panels (6.0) for instrument consistency.
local NEEDLE_SPEED = 6.0
local emerg_press_sm = -60
local store_press_sm = -105
local main_press_sm = 195
local quantity_sm = -110
local brake_1_sm = 195
local brake_2_sm = -105
local flap_ind_sm = 0

local function needle_smooth(current, target, dt)
    local k = NEEDLE_SPEED * dt
    if k > 1 then
        k = 1
    end
    return current + (target - current) * k
end
-- ═══════════════════════════════════════════════════════════════════════════

local flap_up_clicked = false
local flap_down_clicked = false

registerCommandHandler(createCommand("An-24/Instruments/emerg_pump_sw_on", "Emergency hydro pump switch on."), 0,
    function(p)
        if p == 0 and get(emerg_pump_sw) ~= 1 then
            set(emerg_pump_sw, 1)
        end
        return 0
    end)
registerCommandHandler(createCommand("An-24/Instruments/emerg_pump_sw_off", "Emergency hydro pump switch off."), 0,
    function(p)
        if p == 0 and get(emerg_pump_sw) ~= 0 then
            set(emerg_pump_sw, 0)
        end
        return 0
    end)
registerCommandHandler(createCommand("An-24/Instruments/emerg_pump_sw_toggle", "Emergency hydro pump switch toggle."),
    0, function(p)
        if p == 0 then
            if get(emerg_pump_sw) == 0 then
                set(emerg_pump_sw, 1)
            else
                set(emerg_pump_sw, 0)
            end
        end
        return 0
    end)

-- every frame calculations.
function update()

    -- initial switchers values
    time_counter = time_counter + get(frame_time)
    if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
        set(emerg_pump_sw, 0)
        not_loaded = false
    end

    -- calculate power
    if get(bus_DC_27_volt_emerg) > 21 then
        power = 1
    else
        power = 0
    end
    if acOK() then
        power115 = 1
    else
        power115 = 0
    end

    -- calculate emergency pump led shine
    if get(emerg_pump_sw) * power * power115 > 0 then
        emerg_pump_led = true
    else
        emerg_pump_led = false
    end
    -- calculate emergency pressure indicator
    emerg_press_angle = get(emerg_press) * power115 * 120 / 240 - 60

    -- calculate main pressure indicator
    main_press_angle = -get(main_press) * power115 * 120 / 240 + 195

    -- calculate hydro storage pressure
    store_press_angle = get(hydro_store) * power115 * 120 / 240 - 105

    -- calculate hydraulic quantity
    if power == 1 then
        quantity_angle = get(hydro_quantity) * 180 / 30 - 90
    else
        quantity_angle = -110
    end

    -- calculate left brake pressure indicator
    -- brake_1_angle = -math.max(get(brake1), get(block_brake)) * power115 * 120 / 1.5 + 195
    if get(block_brake) > 0 then
        brake_1_angle = (-math.max(get(brake1), get(block_brake)) * power115 * 120 / 1.5) +
                            (-math.min(get(brake1), get(block_brake)) * power115 * 20) + 195
    else
        brake_1_angle = -math.max(get(brake1), get(block_brake)) * power115 * 120 / 1.5 + 195
    end

    -- calculate right brake pressure indicator
    -- brake_2_angle = math.max(get(brake2), get(block_brake)) * power115 * 120 / 1.5 - 105
    if get(block_brake) > 0 then
        brake_2_angle = (math.max(get(brake2), get(block_brake)) * power115 * 120 / 1.5) +
                            (math.min(get(brake2), get(block_brake)) * power115 * 20) - 105
    else
        brake_2_angle = math.max(get(brake2), get(block_brake)) * power115 * 120 / 1.5 - 105
    end

    -- calculate flaps indicator
    if power > 0 then
        flap_ind_angle = math.max(get(flap_deg1), get(flap_deg2)) * 180 / 45
    end

    -- INERTIA: smooth the needle angles (the smooth movement of a real pressure gauge).
    -- The 3D needles and the 2D values use the smoothed *_sm variables.
    local dt = get(frame_time)
    if dt > 0 then
        emerg_press_sm = needle_smooth(emerg_press_sm, emerg_press_angle, dt)
        main_press_sm = needle_smooth(main_press_sm, main_press_angle, dt)
        store_press_sm = needle_smooth(store_press_sm, store_press_angle, dt)
        quantity_sm = needle_smooth(quantity_sm, quantity_angle, dt)
        brake_1_sm = needle_smooth(brake_1_sm, brake_1_angle, dt)
        brake_2_sm = needle_smooth(brake_2_sm, brake_2_angle, dt)
        flap_ind_sm = needle_smooth(flap_ind_sm, flap_ind_angle, dt)

        -- XP12 HYDRAULIC GAUGE PULSATION FROM THE PUMP.
        -- The real main and emergency hydraulic system gauges of the An-24 pulse
        -- from the gear pump (the characteristic needle flutter).
        -- Pulsation only with the engines running (the hydraulic pump is mounted
        -- on the engine) and under load (pressure present). The amplitude is small — realism.
        local pump_active = (get(N1) > 30 or get(N2) > 30) and power115 == 1
        if pump_active then
            -- amplitude ~0.4° on the main gauges (pressure 120-160 kgf/cm²)
            main_press_sm = main_press_sm + (math.random() - 0.5) * 0.8
            emerg_press_sm = emerg_press_sm + (math.random() - 0.5) * 0.8
            -- the brake gauge pulses less (a separate accumulator smooths it)
            brake_1_sm = brake_1_sm + (math.random() - 0.5) * 0.4
            brake_2_sm = brake_2_sm + (math.random() - 0.5) * 0.4
        end
    end

    -- set vars for 2D panel (pass the SMOOTHED values — the 2D panel is smooth too)
    set(main_press_angle_2d, main_press_sm)
    set(emerg_press_angle_2d, emerg_press_sm)
    set(store_press_angle_2d, store_press_sm)
    set(left_press_angle_2d, brake_1_sm)
    set(right_press_angle_2d, brake_2_sm)
    set(hydro_quantity_angle_2d, quantity_sm)

end

-- components
components = { 
	-----------------------
	-- needle indicators --
	-----------------------

	-- emergency pressure indicator
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1206, 1136, 88, 88},
		angle = function()
			return emerg_press_sm
		end
	}, 
	
	-- cap for emergency pressure indicator
	texture {
		image = function()
			return get(black_cap1)
		end,
		position = {1210, 1138, 77, 59}
	}, 
	
	-- main pressure indicator
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {979, 1180, 88, 88},
		angle = function()
			return main_press_sm
		end
	}, 
	
	-- cap for main pressure indicator
	texture {
		image = function()
			return get(black_cap2)
		end,
		position = {1001, 1199, 40, 45}
	}, 
	
	-- storage pressure indicator
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1050, 1108, 88, 88},
		angle = function()
			return store_press_sm
		end
	}, 
	
	-- cap for storage pressure indicator
	texture {
		image = function()
			return get(black_cap3)
		end,
		position = {1073, 1128, 40, 45}
	}, 
	
	-- hydraulic quantity indicator
	needle {
		image = function()
			return get(needles_4)
		end,
		position = {1428, 1050, 142, 142},
		angle = function()
			return quantity_sm
		end
	}, 
	
	-- cap for hydraulic quantity indicator
	texture {
		image = function()
			return get(grey_cap)
		end,
		position = {1472, 1093, 56, 56}
	}, 
	
	-- left brake indicator
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1062, 1097, 88, 88},
		angle = function()
			return brake_1_sm
		end
	}, 
	
	-- cap for left brake indicator
	texture {
		image = function()
			return get(black_cap2)
		end,
		position = {1087, 1117, 40, 45}
	}, 
	
	-- right brake indicator
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {1133, 1024, 88, 88},
		angle = function()
			return brake_2_sm
		end
	}, 
	
	-- cap for right brake indicator
	texture {
		image = function()
			return get(black_cap3)
		end,
		position = {1155, 1045, 40, 45}
	}, 
	
	-- flap position indicator
	needle {
		image = function()
			return get(needles_5)
		end,
		position = {1250, 1055, 98, 98},
		angle = function()
			return flap_ind_sm
		end
	}, 
	
	----------
	-- leds --
	----------

	textureLit {
		image = get(yellow_led),
		position = {600, 387, 20, 20},
		visible = function()
			return emerg_pump_led
		end
	}, 
	
	----------------------
	-- panel clickables --
	----------------------

	-- hydro circle valve
	toggleSwitch {
		position = {880, 449, 38, 49},
		drf = hydro_circle,
		sound = switch_sound
	}, 

--[[
	-- emergency hydraulic pump switcher
	switch {
		position = { 955, 325, 17, 17},
		state = function()
			return get(emerg_pump_sw) ~= 0
		end,
		--btnOn = get(tmb_up),
		--btnOff = get(tmb_dn),
		onMouseDown = function()
            if not switcher_pushed then
			sasl.al.playSample(switch_sound, false)
			switcher_pushed = true
			if get(emerg_pump_sw) ~= 0 then
                set(emerg_pump_sw, 0)
            else
                set(emerg_pump_sw, 1)
            end
            return true;
			end
        end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    }, 
--]]
	
	-- emergency flap valve cap (closing it also turns the emerg valve off)
	toggleSwitch {
		position = {102, 449, 33, 39},
		drf = flaps_valve_emerg_cap,
		sound = cap_sound,
		onToggle = function(nv)
			if nv == 0 then
				set(flaps_valve_emerg, 0)
			end
		end
	}, 
	
	-- emergency flap valve pump switcher (only acts while its cap is open)
	toggleSwitch {
		position = {1116, 371, 18, 18},
		drf = flaps_valve_emerg,
		sound = switch_sound,
		guard = function()
			return get(flaps_valve_emerg_cap) == 1
		end
	}, 
	
	-- turn OFF gear retract block cap (closing it also re-blocks the gear)
	toggleSwitch {
		position = {655, 457, 31, 45},
		drf = gear_unblock_cap,
		sound = cap_sound,
		onToggle = function(nv)
			if nv == 0 then
				set(gear_unblock, 0)
			end
		end
	}, 
	
	-- turn OFF gear retract block (only acts while its cap is open)
	toggleSwitch {
		position = {1134, 371, 18, 18},
		drf = gear_unblock,
		sound = switch_sound,
		guard = function()
			return get(gear_unblock_cap) == 1
		end
	}, 
	
	-- turn flaps UP
	clickable {
		position = {1135, 410, 30, 15}, -- search and set right
		cursor = Cursors.HAND,
		onMouseDown = function()
			if not flap_up_clicked then
				sasl.al.playSample(switch_sound, false)
				commandBegin(flaps_command_up)
				flap_up_clicked = true
			end
			return true
		end,
		onMouseUp = function()
			sasl.al.playSample(switch_sound, false)
			commandEnd(flaps_command_up)
			flap_up_clicked = false
			return true
		end
	}, 
	
	-- turn flaps DOWN
	clickable {
		position = {1135, 395, 30, 15}, -- search and set right
		cursor = Cursors.HAND,
		onMouseDown = function()
			if not flap_down_clicked then
				sasl.al.playSample(switch_sound, false)
				commandBegin(flaps_command_down)
				flap_down_clicked = true
			end
			return true
		end,
		onMouseUp = function()
			sasl.al.playSample(switch_sound, false)
			commandEnd(flaps_command_down)
			flap_down_clicked = false
			return true
		end
	}, 
	
	rectangle {
		position = {1168, 410, 30, 15},
		color = {0, 1, 0, 1}
	}, 
	
	-- turn gears UP (single-action)
	stepButton {
		position = {1168, 410, 30, 15},
		cursor = Cursors.HAND,
		sound = switch_sound,
		onStep = function()
			commandOnce(gear_command_up)
		end
	}, 
	
	rectangle {
		position = {1168, 395, 30, 15},
		color = {1, 0, 0, 1}
	}, 
	
	-- turn gears DOWN (single-action)
	stepButton {
		position = {1168, 395, 30, 15},
		cursor = Cursors.HAND,
		sound = switch_sound,
		onStep = function()
			commandOnce(gear_command_down)
		end
	}
}
