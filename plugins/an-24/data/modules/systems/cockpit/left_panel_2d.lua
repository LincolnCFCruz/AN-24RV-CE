-- this is 3D panel for start engines
size = {983, 512}

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
defineProperty("fire_valve3_sw", globalProperty("an-24/fuel/fire_valve3_sw")) -- fire valve switch for engine 3
defineProperty("ru19_pk_open_lit", globalProperty("an-24/fuel/ru19_pk_open_lit")) --
defineProperty("ru19_pk_close_lit", globalProperty("an-24/fuel/ru19_pk_close_lit")) --
-- V11 "variant B" (v2): amp_volt_filter now writes BACK into the original
-- starter_amp/volt datarefs (it runs after start_logic in the component
-- order), so we read them DIRECTLY as Parshukov did — already smoothed.
defineProperty("starter_volt", globalProperty("an-24/start/starter_volt")) -- smoothed by amp_volt_filter
defineProperty("starter_amp", globalProperty("an-24/start/starter_amp")) -- smoothed by amp_volt_filter
defineProperty("apd_work_lit", globalProperty("an-24/start/apd_work_lit")) -- lamp for apd
-- hydro
defineProperty("main_press_angle_2d", globalProperty("an-24/hydro/main_press_angle"))
defineProperty("emerg_press_angle_2d", globalProperty("an-24/hydro/emerg_press_angle"))
defineProperty("store_press_angle_2d", globalProperty("an-24/hydro/store_press_angle"))
defineProperty("left_press_angle_2d", globalProperty("an-24/hydro/left_press_angle"))
defineProperty("right_press_angle_2d", globalProperty("an-24/hydro/right_press_angle"))
defineProperty("hydro_quantity_angle_2d", globalProperty("an-24/hydro/hydro_quantity_angle"))
defineProperty("hydro_circle", globalProperty("an-24/hydro/hydro_circle")) -- connect main and emergency feeds
-- ssos
defineProperty("ssos_test", globalProperty("an-24/gauges/ssos_test_sw"))
defineProperty("ssos_sw", globalProperty("an-24/gauges/ssos_sw"))
defineProperty("ssos_sw_cap", globalProperty("an-24/gauges/ssos_sw_cap"))
defineProperty("ssos_power_lit", globalProperty("an-24/gauges/ssos_power_lit")) -- ssos power lamp
-- ap
defineProperty("ap_mech_off", globalProperty("an-24/ap/ap_mech_off")) -- ap mechanic off. o = mechanics works, 1 = mech off
defineProperty("ap_mech_off_cap", globalProperty("an-24/ap/ap_mech_off_cap")) -- ap mechanic off cap
-- wiper
defineProperty("wiper_sw", globalProperty("sim/cockpit2/switches/wiper_speed")) -- 0=off,1=25%speed,2=50%speed,3=100%speed.
defineProperty("left_subpanel", globalProperty("an-24/panels/left_subpanel"))
-- images
defineProperty("white_led", loadLED("white"))
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))
defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))
defineProperty("needles_2", langImage("needles", 18, 158, 13, 98))
defineProperty("needles_3", langImage("needles", 34, 158, 13, 98))
defineProperty("needles_4", langImage("needles", 0, 26, 15, 142))
defineProperty("needles_5", langImage("needles", 16, 47, 16, 98))
defineProperty("needles_thin", langImage("needles", 336, 43, 1, 110))
defineProperty("black_cap", langImage("covers", 0, 17, 56, 56)) -- black cap image
defineProperty("small_btn_dn", sasl.gl.loadImage("fuel_panel_2d_e.dds", 181, 171, 34, 36))
defineProperty("small_btn_up", sasl.gl.loadImage("fuel_panel_2d_e.dds", 224, 171, 34, 36))
defineProperty("yellow_cap_close", sasl.gl.loadImage("fuel_panel_2d_e.dds", 369, 135, 44, 163))
defineProperty("yellow_cap_open", sasl.gl.loadImage("fuel_panel_2d_e.dds", 416, 135, 44, 163))
defineProperty("red_cap_close", sasl.gl.loadImage("fuel_panel_2d_e.dds", 272, 135, 44, 163))
defineProperty("red_cap_open", sasl.gl.loadImage("fuel_panel_2d_e.dds", 319, 135, 44, 163))
defineProperty("red_sidecap_close", sasl.gl.loadImage("fuel_panel_2d_e.dds", 43, 92, 162, 42))
defineProperty("red_sidecap_open", sasl.gl.loadImage("fuel_panel_2d_e.dds", 43, 46, 162, 42))
defineProperty("ru_cap_open", sasl.gl.loadImage("fuel_panel_2d_e.dds", 47, 148, 117, 71))
defineProperty("tmb_up", sasl.gl.loadImage("tumbler_up.dds"))
defineProperty("tmb_dn", sasl.gl.loadImage("tumbler_down.dds"))
defineProperty("tmb_ctr", sasl.gl.loadImage("tumbler_center.dds"))
defineProperty("tmb_left", sasl.gl.loadImage("tumbler_left.dds"))
defineProperty("tmb_right", sasl.gl.loadImage("tumbler_right.dds"))
defineProperty("red_vent_img", sasl.gl.loadImage("fuel_panel_2d_e.dds", 180, 218, 80, 80))
defineProperty("grey_cap", langImage("covers", 406, 72, 56, 56))
defineProperty("black_cap1", langImage("covers", 264, 2, 77, 59))
defineProperty("black_cap2", langImage("covers", 138, 9, 57, 60))
defineProperty("black_cap3", langImage("covers", 202, 8, 57, 60))

local language = globalProperty("an-24/set/language")

local ru_cap_close = langImages("fuel_panel_2d", 47, 224, 117, 71)

local amp_angle = -100
local volt_angle = -45

-- V11 "variant B": the smoothing now lives in amp_volt_filter.lua
-- (rate limiter + lowpass); this panel just displays the values directly
-- with Parshukov's original needle formulas restored.
-- Needle angle variables; initial values = the "0" mark of each scale:
--   ammeter:   "0" of the scale = -100 deg from the texture centre
--   voltmeter: "0" of the scale = -45 deg
local amp_angle_sm = -100 -- ammeter angle (needle at "0")
local volt_angle_sm = -45 -- voltmeter angle (needle at "0")

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

local ssos_tmb_pos = 0

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

function update()
    -- ═══ V11 variant B: DIRECT display from the filter ═══
    -- Smoothing is ALREADY done in amp_volt_filter.lua (rate limit + lowpass).

    local starter_amp_val = get(starter_amp) -- from amp_volt_filter
    local starter_volt_val = get(starter_volt) -- from amp_volt_filter

    -- Hard input guard: values must NEVER be negative or off the scale BEFORE
    -- the formula — last line of defence if the filter somehow yields a minus.
    if starter_amp_val < 0 then
        starter_amp_val = 0
    end
    if starter_volt_val < 0 then
        starter_volt_val = 0
    end
    if starter_amp_val > 1000 then
        starter_amp_val = 1000
    end
    if starter_volt_val > 75 then
        starter_volt_val = 75
    end

    -- Parshukov's original value -> needle angle formulas, restored — they work
    -- correctly now because starter_amp/volt are pre-smoothed by the filter.
    -- The 3D cockpit gauges read the same datarefs directly.
    --   ammeter:   0 A -> -100 deg, 1000 A -> +117 deg
    --   voltmeter: 0 V -> -45 deg,  75 V   -> +45 deg
    local amp_raw = starter_amp_val * 217 / 1000 - 100
    local volt_raw = starter_volt_val * 90 / 75 - 45

    -- Hard scale limits: the needle does not pass "0" leftwards nor fly off the dial.
    if amp_raw < -100 then
        amp_raw = -100
    end
    if amp_raw > 122 then
        amp_raw = 122
    end
    if volt_raw < -45 then
        volt_raw = -45
    end
    if volt_raw > 50 then
        volt_raw = 50
    end

    -- Direct values into the drawing variables
    amp_angle = amp_raw
    volt_angle = volt_raw
    amp_angle_sm = amp_raw
    volt_angle_sm = volt_raw

    -- ═══ LIGHT VIBRATION (only while the starter is working) ═══
    if starter_amp_val > 50 then
        amp_angle_sm = amp_angle_sm + (math.random() - 0.5) * 0.4
        volt_angle_sm = volt_angle_sm + (math.random() - 0.5) * 0.2
    end

    -- calculate emergency pressure indicator
    emerg_press_angle = get(emerg_press_angle_2d)

    -- calculate main pressure indicator
    main_press_angle = get(main_press_angle_2d)

    -- calculate hydro storage pressure
    store_press_angle = get(store_press_angle_2d)

    -- calculate hydraulic quantity
    quantity_angle = get(hydro_quantity_angle_2d)

    -- calculate left brake pressure indicator
    brake_1_angle = get(left_press_angle_2d)

    -- calculate right brake pressure indicator
    brake_2_angle = get(right_press_angle_2d)

    -- ssos tumbler
    ssos_tmb_pos = get(ssos_test)

end

components = { 
    -- background
    texture {
        image = langImage("left_panel_2d", 0, 0, 983, 512),
        position = {0, 0, size[1], size[2]}
    }, 
    
    -------------------
    -- needle gauges --
    -------------------

    -- ampermeter (XP12: smoothed needle with inertia)
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {717, 339, 60, 60},
        angle = function()
            return amp_angle_sm
        end
    }, 
    
    -- black cap
    texture {
        position = {733, 353, 30, 30},
        image = function()
            return get(black_cap)
        end
    }, 
    
    -- start voltmeter (XP12: smoothed needle with inertia)
    needle {
        image = function()
            return get(needles_thin)
        end,
        position = {795, 266, 200, 200},
        angle = function()
            return volt_angle_sm
        end
    }, 
    
    -- emergency pressure indicator
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {14, 392, 60, 60},
        angle = function()
            return emerg_press_angle
        end
    }, 
    
    -- main pressure indicator
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {85, 428, 60, 60},
        angle = function()
            return main_press_angle
        end
    }, 
    
    -- storage pressure indicator
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {135, 378, 60, 60},
        angle = function()
            return store_press_angle
        end
    }, 
    
    -- left brake indicator
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {188, 428, 60, 60},
        angle = function()
            return brake_1_angle
        end
    }, 
    
    -- right brake indicator
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {238, 378, 60, 60},
        angle = function()
            return brake_2_angle
        end
    }, 
    
    -- hydraulic quantity indicator
    needle {
        image = function()
            return get(needles_4)
        end,
        position = {400, 350, 105, 105},
        angle = function()
            return quantity_angle
        end
    }, 
    
    -- caps

    -- cap for emergency pressure indicator
    texture {
        image = function()
            return get(black_cap1)
        end,
        position = {26, 400, 40, 30}
    }, 
    
    -- cap for main pressure indicator
    texture {
        image = function()
            return get(black_cap2)
        end,
        position = {96, 439, 32, 32}
    }, 
    
    -- cap for storage pressure indicator
    texture {
        image = function()
            return get(black_cap3)
        end,
        position = {150, 390, 32, 32}
    }, 
    
    -- cap for left pressure indicator
    texture {
        image = function()
            return get(black_cap2)
        end,
        position = {200, 439, 32, 32}
    }, 
    
    -- cap for right pressure indicator
    texture {
        image = function()
            return get(black_cap3)
        end,
        position = {250, 390, 32, 32}
    }, 
    
    -- cap for hydraulic quantity indicator
    texture {
        image = function()
            return get(grey_cap)
        end,
        position = {433, 380, 40, 40}
    }, 
    
    ------------
    -- lights --
    ------------

    -- apd work
    textureLit {
        image = get(white_led),
        position = {172, 225, 17, 17},
        visible = function()
            return get(apd_work_lit) == 1
        end
    }, 
    
    -- Ru19 PK open
    textureLit {
        image = get(green_led),
        position = {346, 464, 18, 18},
        visible = function()
            return get(ru19_pk_open_lit) == 1
        end
    }, 
    
    -- Ru19 PK open
    textureLit {
        image = get(red_led),
        position = {347, 352, 18, 18},
        visible = function()
            return get(ru19_pk_close_lit) == 1
        end
    }, 
    
    -- SSOS work
    textureLit {
        image = get(green_led),
        position = {643, 254, 18, 18},
        visible = function()
            return get(ssos_power_lit) == 1
        end
    }, 
    
    -----------------
    -- SSOS system --
    -----------------

    -- image
    texture {
        position = {550, 248, 120, 30},
        image = function()
            if get(ssos_sw_cap) == 1 then
                return get(red_sidecap_open)
            else
                return get(red_sidecap_close)
            end
        end
    }, 
    
    -- ssos switch (only acts/visible while its cap is open)
    toggleSwitch {
        position = {540, 249, 80, 25},
        drf = ssos_sw,
        btnOn = get(tmb_left),
        btnOff = get(tmb_right),
        visible = function()
            return get(ssos_sw_cap) == 1
        end,
        guard = function()
            return get(ssos_sw_cap) == 1
        end,
        sound = switch_sound
    }, 
    
    -- ssos switch cap (closing the cap arms the SSOS switch)
    toggleSwitch {
        position = {570, 280, 40, 30},
        drf = ssos_sw_cap,
        sound = cap_sound,
        onToggle = function(nv)
            if nv == 0 then
                set(ssos_sw, 1)
            end
        end
    }, 
    
    -- test switcher
    
    -- images
    texture {
        position = {735, 405, 20, 80},
        image = get(tmb_up),
        visible = function()
            return ssos_tmb_pos == 1
        end
    }, 
    
    texture {
        position = {735, 405, 20, 80},
        image = get(tmb_ctr),
        visible = function()
            return ssos_tmb_pos == 0
        end
    }, 
    
    texture {
        position = {705, 435, 80, 20},
        image = get(tmb_left),
        visible = function()
            return ssos_tmb_pos == 2
        end
    }, 
    
    texture {
        position = {705, 435, 80, 20},
        image = get(tmb_right),
        visible = function()
            return ssos_tmb_pos == 3
        end
    }, 
    
    -- test switcher (momentary: up=1, left=2, right=3)
    momentaryButton {
        position = {725, 470, 40, 40},
        drf = ssos_test,
        onValue = 1,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {705, 430, 40, 40},
        drf = ssos_test,
        onValue = 2,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {745, 430, 40, 40},
        drf = ssos_test,
        onValue = 3,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    -------------------
    -- engines start --
    -------------------
    
    -- image
    texture {
        position = {137, 263, 30, 30},
        image = function()
            if get(eng_start_btn) == 1 then
                return get(small_btn_dn)
            else
                return get(small_btn_up)
            end
        end
    }, 
    
    -- engine start button (momentary)
    momentaryButton {
        position = {135, 260, 30, 30},
        drf = eng_start_btn,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- cap for ground/air start selector
    texture {
        position = {215, 225, 30, 120},
        image = function()
            if get(start_at_ground_cap) == 1 then
                return get(yellow_cap_open)
            else
                return get(yellow_cap_close)
            end
        end
    }, 
    
    -- cap for ground/air start selector (closing it also turns the selector off)
    toggleSwitch {
        position = {180, 240, 30, 40},
        drf = start_at_ground_cap,
        sound = cap_sound,
        onToggle = function(nv)
            if nv == 0 then
                set(start_at_ground, 0)
            end
        end
    }, 
    
    -- ground/air start selector (only acts/visible while its cap is open)
    toggleSwitch {
        position = {217, 230, 25, 80},
        drf = start_at_ground,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        visible = function()
            return get(start_at_ground_cap) == 1
        end,
        guard = function()
            return get(start_at_ground_cap) == 1
        end,
        sound = switch_sound
    }, 
    
    -- engine selector
    
    -- image
    texture {
        position = {290, 215, 25, 80},
        image = function()
            local a = get(sel_left_right)
            if a == 1 then
                return get(tmb_dn)
            elseif a == -1 then
                return get(tmb_up)
            else
                return get(tmb_ctr)
            end
        end
    }, 
    
    -- engine selector (3-state)
    
    -- select left
    stepButton {
        position = {285, 255, 30, 40},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(sel_left_right)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(sel_left_right, a)
        end
    }, 
    
    -- select right
    stepButton {
        position = {285, 215, 30, 40},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(sel_left_right)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(sel_left_right, a)
        end
    }, 
    
    -- engine start mode - cold rotate/start
    toggleSwitch {
        position = {355, 215, 25, 80},
        drf = eng_start_mode,
        btnOn = get(tmb_dn),
        btnOff = get(tmb_up),
        sound = switch_sound
    }, 
    
    -- stop button (momentary)
    momentaryButton {
        position = {417, 250, 40, 40},
        drf = eng_start_stop,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- left / right PRT24
    toggleSwitch {
        position = {210, 135, 25, 80},
        drf = left_prt24_on,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {375, 135, 25, 80},
        drf = right_prt24_on,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    -- left engine temp check
    
    -- image
    texture {
        position = {149, 135, 25, 80},
        image = function()
            local a = get(left_temp_check)
            if a == 1 then
                return get(tmb_dn)
            elseif a == -1 then
                return get(tmb_up)
            else
                return get(tmb_ctr)
            end
        end
    }, 
    
    -- select up / down (3-state)
    stepButton {
        position = {149, 175, 25, 40},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(left_temp_check)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(left_temp_check, a)
        end
    }, 
    
    stepButton {
        position = {149, 135, 25, 40},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(left_temp_check)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(left_temp_check, a)
        end
    }, 
    
    -- right engine temp check
    
    -- image
    texture {
        position = {437, 135, 25, 80},
        image = function()
            local a = get(right_temp_check)
            if a == 1 then
                return get(tmb_dn)
            elseif a == -1 then
                return get(tmb_up)
            else
                return get(tmb_ctr)
            end
        end
    }, 
    
    -- select up / down (3-state)
    stepButton {
        position = {437, 175, 25, 40},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(right_temp_check)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(right_temp_check, a)
        end
    }, 
    
    stepButton {
        position = {437, 135, 25, 40},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(right_temp_check)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(right_temp_check, a)
        end
    }, 
    
    -----------------
    -- RU-19 start --
    -----------------
    
    -- image
    texture {
        position = {145, 70, 30, 30},
        image = function()
            if get(ru19_ground_start_btn) == 1 then
                return get(small_btn_dn)
            else
                return get(small_btn_up)
            end
        end
    }, 
    
    -- start button
    clickable {
        position = {145, 70, 30, 30}, -- search and set right
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
    
    -- start button cap
    texture {
        position = {85, 47, 100, 65},
        image = function()
            if get(ru19_ground_start_cap) == 1 then
                return get(ru_cap_open)
            else
                return ru_cap_close[get(language)]
            end
        end
    }, 
    
    toggleSwitch {
        position = {90, 60, 40, 40},
        drf = ru19_ground_start_cap,
        sound = cap_sound
    }, 
    
    -- mode selector
    toggleSwitch {
        position = {195, 37, 25, 80},
        drf = ru19_start_mode,
        btnOn = get(tmb_dn),
        btnOff = get(tmb_up),
        sound = switch_sound
    }, 
    
    -- fiction
    texture {
        position = {300, 37, 25, 80},
        image = get(tmb_dn)
    }, 
    
    -- stop button (momentary)
    momentaryButton {
        position = {417, 60, 40, 40},
        drf = ru19_start_stop,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- main switcher cap
    texture {
        position = {352, 20, 35, 140},
        image = function()
            if get(ru19_start_main_sw_cap) == 1 then
                return get(red_cap_open)
            else
                return get(red_cap_close)
            end
        end
    }, 
    
    -- main switcher cap (closing it also turns the main switcher off)
    toggleSwitch {
        position = {320, 50, 30, 40},
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
        position = {357, 37, 25, 80},
        drf = ru19_start_main_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        visible = function()
            return get(ru19_start_main_sw_cap) == 1
        end,
        guard = function()
            return get(ru19_start_main_sw_cap) == 1
        end,
        sound = switch_sound
    }, 
    
    -- fire valve 3
    toggleSwitch {
        position = {340, 380, 25, 80},
        drf = fire_valve3_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    -- hydro valve
    needle {
        image = get(red_vent_img),
        position = {742, 202, 80, 80},
        angle = function()
            return 45 * get(hydro_circle)
        end
    }, 
    
    -- hydro circle valve
    toggleSwitch {
        position = {742, 202, 80, 80},
        drf = hydro_circle,
        sound = switch_sound
    }, 
    
    -- image
    texture {
        position = {740, 98, 120, 30},
        image = function()
            if get(ap_mech_off_cap) == 1 then
                return get(red_sidecap_open)
            else
                return get(red_sidecap_close)
            end
        end
    }, 
    
    -- AP mechanic off cap (closing it also re-enables the mechanics)
    toggleSwitch {
        position = {770, 140, 40, 30},
        drf = ap_mech_off_cap,
        sound = cap_sound,
        onToggle = function(nv)
            if nv == 0 then
                set(ap_mech_off, 0)
            end
        end
    }, 
    
    -- AP mechanic off (only acts/visible while its cap is open)
    toggleSwitch {
        position = {740, 100, 80, 25},
        drf = ap_mech_off,
        btnOn = get(tmb_right),
        btnOff = get(tmb_left),
        visible = function()
            return get(ap_mech_off_cap) ~= 0
        end,
        guard = function()
            return get(ap_mech_off_cap) == 1
        end,
        sound = switch_sound
    }, 
    
    -- wiper (off = 0, on = 2)
    toggleSwitch {
        position = {540, 70, 100, 100},
        drf = wiper_sw,
        onValue = 2
    }
}

