-- this is the electrical panel logic, shown on 3D cockpit panels...
size = {600, 1024} -- panel will contain a several gauges in different plases of panel texture

-- define property table
-- connect sources to bus
defineProperty("stg1_on", globalProperty("an-24/power/stg1_on")) -- generator connected if 1 and dissconnected if 0
defineProperty("stg2_on", globalProperty("an-24/power/stg2_on"))

defineProperty("stg1_on_bus", globalProperty("an-24/power/stg1_on_bus")) -- generator connected if 1 and dissconnected if 0
defineProperty("stg2_on_bus", globalProperty("an-24/power/stg2_on_bus"))
defineProperty("gs24_on_bus", globalProperty("an-24/power/gs24_on_bus"))
defineProperty("go1_on_bus", globalProperty("an-24/power/go1_on_bus"))
defineProperty("go2_on_bus", globalProperty("an-24/power/go2_on_bus"))

defineProperty("inv_PT1000_1", globalProperty("an-24/power/inv_PT1000_1")) -- inverters
defineProperty("inv_PT1000_2", globalProperty("an-24/power/inv_PT1000_2"))
defineProperty("inv_PT750", globalProperty("an-24/power/inv_PT750"))

defineProperty("bat1_on", globalProperty("an-24/power/bat1_on")) -- battery switch. 0 = OFF, 1 = ON
defineProperty("bat2_on", globalProperty("an-24/power/bat2_on"))
defineProperty("bat3_on", globalProperty("an-24/power/bat3_on"))

-- logic
defineProperty("main_on_emerg", globalProperty("an-24/power/main_on_emerg")) -- main bus connected to emergency bus
defineProperty("DC_source", globalProperty("an-24/power/DC_source")) -- source for DC27v bus. 0 = none, 1 = STG1, 2 = STG2, 3 = GS24, 4 = bat. left gen by default
defineProperty("AC_source", globalProperty("an-24/power/AC_source")) -- source for AC115 bus. 1 when generators, 2 when inverter

-- generators and bat voltage
defineProperty("stg1_volt", globalProperty("an-24/power/stg1_volt")) -- generators voltage.
defineProperty("stg2_volt", globalProperty("an-24/power/stg2_volt"))
defineProperty("gs24_volt", globalProperty("an-24/power/gs24_volt"))
defineProperty("go1_volt", globalProperty("an-24/power/go1_volt"))
defineProperty("go2_volt", globalProperty("an-24/power/go2_volt"))

defineProperty("stg1_amp", globalProperty("an-24/power/stg1_amp")) -- generators current, initial 0A
defineProperty("stg2_amp", globalProperty("an-24/power/stg2_amp"))
defineProperty("gs24_amp", globalProperty("an-24/power/gs24_amp"))
defineProperty("go1_amp", globalProperty("an-24/power/go1_amp"))
defineProperty("go2_amp", globalProperty("an-24/power/go2_amp"))

defineProperty("bat1_volt", globalProperty("an-24/power/bat1_volt")) -- battery voltage, initial 27V - full charge.
defineProperty("bat2_volt", globalProperty("an-24/power/bat2_volt"))
defineProperty("bat3_volt", globalProperty("an-24/power/bat3_volt"))

defineProperty("bat1_amp", globalProperty("an-24/power/bat1_amp")) -- battery current, initial 0A. positive - battery load, negative - battery recharge.
defineProperty("bat2_amp", globalProperty("an-24/power/bat2_amp"))
defineProperty("bat3_amp", globalProperty("an-24/power/bat3_amp"))

defineProperty("bat_all_amp", globalProperty("an-24/power/bat_all_amp")) -- overall load of batteries
defineProperty("bat_all_volt", globalProperty("an-24/power/bat_all_volt")) -- overall voltage of batteries
defineProperty("bat_amp_cc", globalProperty("an-24/power/bat_amp_cc")) -- if batteries are charging, they take current instead of give it. = 0 when bat is source

-- buses currents and voltage
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))
defineProperty("bus_DC_27_amp", globalProperty("an-24/power/bus_DC_27_amp"))
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("bus_DC_27_amp_emerg", globalProperty("an-24/power/bus_DC_27_amp_emerg"))
defineProperty("bus_AC_36_volt", globalProperty("an-24/power/bus_AC_36_volt"))
defineProperty("bus_AC_36_amp", globalProperty("an-24/power/bus_AC_36_amp"))
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))
defineProperty("bus_AC_115_amp", globalProperty("an-24/power/bus_AC_115_amp"))

-- XP12 AMMETER VIBRATION: engine RPM datarefs used to check generator
-- activity (the needles tremble only while the generators are turning).
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))

-- switchers
defineProperty("AC36_volt_mode", globalProperty("an-24/power/AC36_volt_mode")) -- mode switcher for AC 36 voltmeter, 9 positions 0-8
defineProperty("AC115_volt_mode", globalProperty("an-24/power/AC115_volt_mode")) -- mode switcher for AC 115 voltmeter, 7 positions 0-6
defineProperty("DC_volt_mode", globalProperty("an-24/power/DC_volt_mode")) -- mode switcher for DC voltmeter, 11 positions 0-10
defineProperty("PT1000_mode", globalProperty("an-24/power/PT1000_mode")) -- switcher for PT1000. 0 = emerg, 1 = off, 2 = on
defineProperty("PO750_mode", globalProperty("an-24/power/PO750_mode")) -- switcher for PO750. 0 = ground, 1 = off, 2 = on
defineProperty("GS24_mode", globalProperty("an-24/power/GS24_mode")) -- start from: 0 = ground power, 1 = off, 2 = GS24
defineProperty("power_mode", globalProperty("an-24/power/power_mode")) -- power mode: 0 = Ground, 1 = off, 2 = airplane
defineProperty("emerg_mode", globalProperty("an-24/power/emerg_mode")) -- switcher for emergency power. 0 = auto, 1 = on main bus, 2 = emergency bus only
defineProperty("STG_disconnect_cap1", globalProperty("an-24/power/STG_disconnect_cap1")) -- red cap for STG disconnectiong button
defineProperty("STG_disconnect_cap2", globalProperty("an-24/power/STG_disconnect_cap2")) -- red cap for STG disconnectiong button
defineProperty("emerg_cap", globalProperty("an-24/power/emerg_cap")) -- red cap for emergency mode switcher

-- logic
defineProperty("ground_available", globalProperty("an-24/power/ground_available")) -- ground power available
defineProperty("electropanel_subpanel", globalProperty("an-24/panels/electropanel_subpanel"))

-- define images
defineProperty("rot_switch", sasl.gl.loadImage("rot_switch.dds"))
defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))
defineProperty("needles_2", langImage("needles", 18, 158, 13, 98))
defineProperty("needles_3", langImage("needles", 34, 158, 13, 98))
defineProperty("yellow_led", loadLED("yellow"))
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))
defineProperty("red_small_led", loadLED("red_small"))
defineProperty("black_cap", langImage("covers", 0, 17, 56, 56)) -- black cap image
defineProperty("tmb_up", sasl.gl.loadImage("tumbler_up.dds"))
defineProperty("tmb_dn", sasl.gl.loadImage("tumbler_down.dds"))
defineProperty("tmb_ctr", sasl.gl.loadImage("tumbler_center.dds"))
defineProperty("btn_press", sasl.gl.loadImage("electro_panel_2d_e.dds", 130, 104, 25, 25))
defineProperty("btn_up", sasl.gl.loadImage("electro_panel_2d_e.dds", 171, 104, 25, 25))
defineProperty("stg_cap_close", sasl.gl.loadImage("electro_panel_2d_e.dds", 4, 64, 50, 81))
defineProperty("stg_cap_open", sasl.gl.loadImage("electro_panel_2d_e.dds", 55, 64, 50, 81))
defineProperty("main_cap_open", sasl.gl.loadImage("electro_panel_2d_e.dds", 207, 47, 82, 104))
defineProperty("main_tmb_up", sasl.gl.loadImage("electro_panel_2d_e.dds", 115, 14, 24, 43))
defineProperty("main_tmb_ctr", sasl.gl.loadImage("electro_panel_2d_e.dds", 145, 14, 24, 43))
defineProperty("main_tmb_dn", sasl.gl.loadImage("electro_panel_2d_e.dds", 180, 15, 24, 43))
defineProperty("main_tmb_up_close", sasl.gl.loadImage("electro_panel_2d_e.dds", 412, 44, 50, 103))
defineProperty("main_tmb_ctr_close", sasl.gl.loadImage("electro_panel_2d_e.dds", 359, 44, 50, 103))
defineProperty("main_tmb_dn_close", sasl.gl.loadImage("electro_panel_2d_e.dds", 307, 44, 50, 103))

-- interpolating functions
-- interpolate values to degrees of needle

local GO_amps_table = {
    {-100, -50}, 
    {0, -45}, 
    {60, -30}, 
    {90, -10}, 
    {120, 12}, 
    {150, 44}, 
    {1000, 50}
}

local AC36_volt_table = {
    {-100, -50}, 
    {0, -45}, 
    {20, -15}, 
    {40, 45}, 
    {100, 50}
}

local AC115_freq_table = {
    {0, -50}, 
    {350, -45}, 
    {380, -20}, 
    {420, 20}, 
    {450, 45}
}

-- interpolate(): shared helper in core/glbl_func.lua

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

-- local variables
local GO_left_amp = 0
local GO_right_amp = 0
local STG_left_amp = 0
local STG_right_amp = 0
local GS_amp = 0
local BAT_amp = 0
local AC36_volt = 0
local AC115_volt = 0
local AC115_freq = 0
local DC_volt = 0

-- ═══════════════════════════════════════════════════════════════════════════
-- INSTRUMENT NEEDLE INERTIA (realistic movement) — 2D cockpit
-- Same as electric_panel_3d.lua: the needles approach the value smoothly,
-- imitating the physical mechanism of the real instrument (mass + damper).
-- ═══════════════════════════════════════════════════════════════════════════
defineProperty("epnl2d_frame_time", globalProperty("an-24/time/frame_time"))
local NEEDLE_SPEED = 6.0 -- needle speed (same as in 3D, kept identical)

local GO_left_amp_sm = 0
local GO_right_amp_sm = 0
local STG_left_amp_sm = 0
local STG_right_amp_sm = 0
local GS_amp_sm = 0
local BAT_amp_sm = 0
local AC36_volt_sm = 0
local AC115_volt_sm = 0
local AC115_freq_sm = 0
local DC_volt_sm = 0

local function needle_smooth(current, target, dt)
    local k = NEEDLE_SPEED * dt
    if k > 1 then
        k = 1
    end
    return current + (target - current) * k
end
-- ═══════════════════════════════════════════════════════════════════════════

-- variables for lights
local STG_left_fail_led = false -- red leds on forvard panel
local STG_right_fail_led = false
local emerg_bus_led = false
local GO_left_fail_led = false
local GO_right_fail_led = false
local GS24_on_bus_led = false -- leds on overhead panel
local ground_led = false
local emerg36_led = false
local emerg36_ON_led = false

-- overall calculations per frame
function update()
    GO_left_amp = interpolate(GO_amps_table, get(go1_amp)) -- calculate angle for GO left ampermeter needle
    GO_right_amp = interpolate(GO_amps_table, get(go2_amp)) -- calculate angle for GO right ampermeter needle
    STG_left_amp = get(stg1_amp) * 220 / 1000 - 100 -- calculate angle for STG left ampermeter needle
    STG_right_amp = get(stg2_amp) * 220 / 1000 - 100 -- calculate angle for STG right ampermeter needle
    if get(GS24_mode) == 0 then
        if get(ground_available) == 1 then
            GS_amp = get(bus_DC_27_amp) * 220 / 1000 - 100
        end
    else
        GS_amp = get(gs24_amp) * 220 / 1000 - 100
    end -- calculate angle for GS24 ampermeter needle
    if get(DC_source) == 4 then
        BAT_amp = get(bat_all_amp)
    else
        BAT_amp = -get(bat_amp_cc)
    end -- calculate angle for batteries ampermeter needle
    BAT_amp = BAT_amp * 220 / 1000 - 100
    local AC36_mode = get(AC36_volt_mode) -- calculate angle for AC36 voltmeter
    local AC36_volts = 0
    if AC36_mode == 0 then
        AC36_volts = get(bus_AC_36_volt)
    else
        AC36_volts = get(bus_AC_36_volt)
    end
    AC36_volt = interpolate(AC36_volt_table, AC36_volts)

    local AC115_mode = get(AC115_volt_mode) -- calculate angle for AC115 voltmeter
    local AC115_volts = 0
    if AC115_mode == 0 then
        AC115_volts = get(bus_AC_115_volt) -- select source for voltmeter. add here variable to define emergency bus
    elseif AC115_mode == 1 then
        if get(ground_available) == 1 then
            AC115_volts = 115
        end -- ground power
    elseif AC115_mode == 2 then
        AC115_volts = get(go1_volt)
    elseif AC115_mode == 3 then
        AC115_volts = get(go2_volt)
    elseif AC115_mode == 4 then
        AC115_volts = get(bus_AC_115_volt) * 1 -- add autopilot variable
    elseif AC115_mode == 5 then
        AC115_volts = get(bus_AC_115_volt) * 1 -- emergency bus here
    elseif AC115_mode == 6 then
        AC115_volts = get(bus_AC_115_volt) * 1 -- prop heat here
    end
    AC115_volt = interpolate(GO_amps_table, AC115_volts) -- AC115 voltmeter scale similar to GO ampermeter
    local AC115_exist
    if get(AC115_volts) > 0 then
        AC115_exist = 400
    else
        AC115_exist = 0
    end
    AC115_freq = interpolate(AC115_freq_table, AC115_exist)

    local DC_volts = 0 -- calculate angle for DC voltmeter
    local DC_mode = get(DC_volt_mode)
    -- DC_mode = 0 -- test modes
    if DC_mode == 0 then
        if get(ground_available) == 1 then
            DC_volts = 27
        end
    elseif DC_mode == 1 then
        if get(ground_available) == 1 then
            DC_volts = 27
        end
    elseif DC_mode == 2 then
        DC_volts = get(bat1_volt)
    elseif DC_mode == 3 then
        DC_volts = get(bat2_volt)
    elseif DC_mode == 4 then
        DC_volts = get(bat3_volt)
    elseif DC_mode == 5 then
        DC_volts = get(gs24_volt)
    elseif DC_mode == 6 then
        DC_volts = get(stg1_volt)
    elseif DC_mode == 7 then
        DC_volts = get(stg2_volt)
    elseif DC_mode == 8 then
        DC_volts = get(bus_DC_27_volt)
    elseif DC_mode == 9 then
        DC_volts = get(bus_DC_27_volt)
    elseif DC_mode == 10 then
        DC_volts = get(bus_DC_27_volt_emerg)
    end
    DC_volt = DC_volts * 240 / 30 - 120

    -- leds logic
    if get(bus_DC_27_volt_emerg) > 21 then -- all lamps will not work if even emergency bus down
        STG_left_fail_led = get(stg1_volt) < 20
        STG_right_fail_led = get(stg2_volt) < 20
        GO_left_fail_led = get(go1_volt) < 100 and get(go1_on_bus) > 0
        GO_right_fail_led = get(go2_volt) < 100 and get(go2_on_bus) > 0
        emerg_bus_led = get(DC_source) == 4
        GS24_on_bus_led = get(gs24_on_bus) > 0 and get(gs24_volt) > 21
        ground_led = get(ground_available) == 1 and get(power_mode) == 0
        emerg36_led = emerg_bus_led
        emerg36_ON_led = get(inv_PT1000_2) > 0
    else
        STG_left_fail_led = false -- red leds on forvard panel
        STG_right_fail_led = false
        emerg_bus_led = false
        GO_left_fail_led = false
        GO_right_fail_led = false
        GS24_on_bus_led = false -- leds on overhead panel
        ground_led = false
        emerg36_led = false
        emerg36_ON_led = false
    end

    -- print(get(GS24_mode))

    -- NEEDLE INERTIA (2D): the smoothed values smoothly catch up with the computed ones.
    local dt = get(epnl2d_frame_time)
    if dt > 0 then
        GO_left_amp_sm = needle_smooth(GO_left_amp_sm, GO_left_amp, dt)
        GO_right_amp_sm = needle_smooth(GO_right_amp_sm, GO_right_amp, dt)
        STG_left_amp_sm = needle_smooth(STG_left_amp_sm, STG_left_amp, dt)
        STG_right_amp_sm = needle_smooth(STG_right_amp_sm, STG_right_amp, dt)
        GS_amp_sm = needle_smooth(GS_amp_sm, GS_amp, dt)
        BAT_amp_sm = needle_smooth(BAT_amp_sm, BAT_amp, dt)
        AC36_volt_sm = needle_smooth(AC36_volt_sm, AC36_volt, dt)
        AC115_volt_sm = needle_smooth(AC115_volt_sm, AC115_volt, dt)
        AC115_freq_sm = needle_smooth(AC115_freq_sm, AC115_freq, dt)
        DC_volt_sm = needle_smooth(DC_volt_sm, DC_volt, dt)

        -- XP12 AMMETER VIBRATION FROM GENERATOR COMMUTATION (2D).
        -- On the real An-24 the ammeter needles tremble slightly from the current ripple
        -- of the brushed generators. Matched with the 3D panel (same amplitude).
        local gen_active = (get(N1) > 40 or get(N2) > 40)
        if gen_active then
            GO_left_amp_sm = GO_left_amp_sm + (math.random() - 0.5) * 0.6
            GO_right_amp_sm = GO_right_amp_sm + (math.random() - 0.5) * 0.6
            STG_left_amp_sm = STG_left_amp_sm + (math.random() - 0.5) * 0.6
            STG_right_amp_sm = STG_right_amp_sm + (math.random() - 0.5) * 0.6
            GS_amp_sm = GS_amp_sm + (math.random() - 0.5) * 0.6
            BAT_amp_sm = BAT_amp_sm + (math.random() - 0.5) * 0.4
        end
    end
end

-- components of electric panel
-- Two-state bus toggle switch (tmb_up/tmb_dn art, switch_sound). Five bus
-- switches share this body; only position and the bus dataref vary. Now a thin
-- wrapper over the shared toggleSwitch factory (core/glbl_controls.lua).
local function busSwitch(pos, drf)
    return toggleSwitch {
        position = pos,
        drf = drf,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }
end

components = { 
    
    -- background
    texture {
        image = langImage("electro_panel_2d", 0, 154, 512, 870),
        position = {0, 0, size[1], size[2]}
    }, 
    
    ------------------
    -- panel lights --
    ------------------
    
--[[
    -- emergency feed on 36v bus
    textureLit {
        image = get(yellow_led),
        position = {181, 986, 24, 24},
        visible = function()
        return emerg36_ON_led
        end,
    },

    textureLit {
        image = get(yellow_led),
        position = {253, 986, 24, 24},
        visible = function()
        return emerg36_ON_led
        end,
    },
--]]

    -- turn on emerg feed
    textureLit {
        image = get(yellow_led),
        position = {515, 886, 24, 24},
        visible = function()
            return emerg36_led
        end
    }, 
    
    -- GS24 on bus
    textureLit {
        image = get(green_led),
        position = {105, 518, 30, 30},
        visible = function()
            return GS24_on_bus_led
        end
    }, 
    
    -- ground available
    textureLit {
        image = get(green_led),
        position = {215, 518, 30, 30},
        visible = function()
            return ground_led
        end
    }, 
    
    textureLit {
        image = get(green_led),
        position = {320, 518, 30, 30},
        visible = function()
            return ground_led
        end
    }, 
    
    ---------------
    -- switchers --
    ---------------
    
    -- PT1000 switcher
    texture {
        position = {515, 907, 25, 100},
        image = function()
            local a = get(PT1000_mode)
            local pic
            if a == 0 then
                pic = get(tmb_dn)
            elseif a == 1 then
                pic = get(tmb_ctr)
            else
                pic = get(tmb_up)
            end
            return pic
        end
    }, 
    
    -- switch up / down (3-state 0..2)
    stepButton {
        position = {500, 960, 50, 50},
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
    
    stepButton {
        position = {500, 910, 50, 50},
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
    
    -- PO750 switcher
    texture {
        position = {283, 735, 25, 100},
        image = function()
            local a = get(PO750_mode)
            local pic
            if a == 0 then
                pic = get(tmb_dn)
            elseif a == 1 then
                pic = get(tmb_ctr)
            else
                pic = get(tmb_up)
            end
            return pic
        end
    }, 
    
    -- switcher up / down (3-state 0..2)
    stepButton {
        position = {270, 790, 50, 50},
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
    
    stepButton {
        position = {270, 740, 50, 50},
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
        position = {525, 130, 50, 60}, -- search and set right
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
        position = {475, 170, 50, 50},
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
        position = {475, 120, 50, 50},
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
    
    -- GO left switcher
    busSwitch({371, 612, 25, 100}, go1_on_bus), -- GO right switcher
    busSwitch({423, 612, 25, 100}, go2_on_bus), -- STG left switcher
    busSwitch({39, 64, 25, 100}, stg1_on_bus), -- STG right switcher
    busSwitch({85, 64, 25, 100}, stg2_on_bus), -- GS24 switcher
    busSwitch({132, 64, 25, 100}, gs24_on_bus), -- STG on engine cap left
    
    toggleSwitch {
        position = {335, 160, 50, 30},
        drf = STG_disconnect_cap1,
        sound = cap_sound
    }, 
    
    -- button image
    texture {
        position = {400, 95, 29, 29},
        image = function()
            local a
            if get(stg2_on) == 1 then
                a = get(btn_up)
            else
                a = get(btn_press)
            end
            return a
        end
    }, 
    
    -- cap image
    texture {
        position = {388, 70, 60, 97},
        image = function()
            local a
            if get(STG_disconnect_cap2) == 1 then
                a = get(stg_cap_open)
            else
                a = get(stg_cap_close)
            end
            return a
        end
    }, 
    
    -- button image
    texture {
        position = {350, 95, 29, 29},
        image = function()
            local a
            if get(stg1_on) == 1 then
                a = get(btn_up)
            else
                a = get(btn_press)
            end
            return a
        end
    }, 
    
    -- cap image
    texture {
        position = {338, 70, 60, 97},
        image = function()
            local a
            if get(STG_disconnect_cap1) == 1 then
                a = get(stg_cap_open)
            else
                a = get(stg_cap_close)
            end
            return a
        end
    }, 
    
    -- STG on engine left switcher (only acts while its cap is open)
    toggleSwitch {
        position = {335, 90, 50, 50},
        drf = stg1_on,
        sound = btn_click,
        guard = function()
            return get(STG_disconnect_cap1) > 0
        end
    }, 
    
    -- STG on engine cap right
    toggleSwitch {
        position = {385, 160, 50, 30},
        drf = STG_disconnect_cap2,
        sound = cap_sound
    }, 
    
    -- STG on engine right switcher (only acts while its cap is open)
    toggleSwitch {
        position = {385, 90, 50, 50},
        drf = stg2_on,
        sound = btn_click,
        guard = function()
            return get(STG_disconnect_cap2) > 0
        end
    }, 
    
    -- AC36_volt_mode voltmeter switcher
    needle {
        position = {187, 867, 80, 80},
        image = get(rot_switch),
        angle = function()
            return -135 + get(AC36_volt_mode) * 270 / 8
        end
    }, 
    
    -- switcher up / down (0..8, auto-repeats)
    stepButton {
        position = {230, 870, 40, 80},
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
    
    stepButton {
        position = {185, 870, 40, 80},
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
    
    needle {
        position = {45, 620, 80, 80},
        image = get(rot_switch),
        angle = 0
    }, 
    
    needle {
        position = {142, 620, 80, 80},
        image = get(rot_switch),
        angle = 0
    }, 
    
    -- AC115_volt_mode voltmeter switcher
    needle {
        position = {242, 620, 80, 80},
        image = get(rot_switch),
        angle = function()
            return -60 + get(AC115_volt_mode) * 320 / 7
        end
    }, 
    
    -- switcher up / down (0..6, wraps, auto-repeats)
    stepButton {
        position = {290, 620, 40, 80},
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
    
    stepButton {
        position = {240, 620, 40, 80},
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
    
    -- DC_volt_mode voltmeter switcher
    needle {
        position = {463, 281, 80, 80},
        image = get(rot_switch),
        angle = function()
            return -150 + get(DC_volt_mode) * 300 / 10
        end
    }, 
    
    -- switcher up / down (0..10, auto-repeats)
    stepButton {
        position = {510, 280, 40, 80},
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
    
    stepButton {
        position = {460, 280, 40, 80},
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
    
    -- power mode
    texture {
        position = {193, 65, 25, 100},
        image = function()
            local a = get(GS24_mode)
            local pic
            if a == 0 then
                pic = get(tmb_dn)
            elseif a == 1 then
                pic = get(tmb_ctr)
            else
                pic = get(tmb_up)
            end
            return pic
        end
    }, 
    
    texture {
        position = {265, 65, 25, 100},
        image = function()
            local a = get(GS24_mode)
            local pic
            if a == 0 then
                pic = get(tmb_dn)
            elseif a == 1 then
                pic = get(tmb_ctr)
            else
                pic = get(tmb_up)
            end
            return pic
        end
    }, 
    
    -- switcher up / down (3-state 0..2; also drives power_mode)
    stepButton {
        position = {195, 120, 100, 50},
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
    
    stepButton {
        position = {195, 70, 100, 50},
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
        position = {338, 719, 90, 90},
        angle = function()
            return GO_left_amp_sm
        end
    }, 
    
    -- GO right ampermeter
    needle {
        image = function()
            return get(needles_3)
        end,
        position = {450, 719, 90, 90},
        angle = function()
            return GO_right_amp_sm
        end
    }, 
    
    -- STG left ampermeter
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {60, 412, 65, 65},
        angle = function()
            return STG_left_amp_sm
        end
    }, 
    
    -- STG right ampermeter
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {162, 412, 65, 65},
        angle = function()
            return STG_right_amp_sm
        end
    }, 
    
    -- GS24 ampermeter
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {265, 412, 65, 65},
        angle = function()
            return GS_amp_sm
        end
    }, 
    
    -- BAT ampermeter
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {367, 412, 65, 65},
        angle = function()
            return BAT_amp_sm
        end
    }, 
    
    -- AC36 voltmeter
    needle {
        image = function()
            return get(needles_3)
        end,
        position = {310, 854, 90, 90},
        angle = function()
            return AC36_volt_sm
        end
    }, 
    
    -- AC115 voltmeter
    needle {
        image = function()
            return get(needles_3)
        end,
        position = {161, 719, 90, 90},
        angle = function()
            return AC115_volt_sm
        end
    }, 
    
    -- AC115 freq-meter
    needle {
        image = function()
            return get(needles_3)
        end,
        position = {49, 719, 90, 90},
        angle = function()
            return AC115_freq_sm
        end
    }, 
    
    -- DC27 voltmeter
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {469, 412, 65, 65},
        angle = function()
            return DC_volt_sm
        end
    }, 
    
    -- black cap
    texture {
        position = {79, 428, 30, 30},
        image = function()
            return get(black_cap)
        end
    }, 
    
    -- black cap
    texture {
        position = {180, 428, 30, 30},
        image = function()
            return get(black_cap)
        end
    },
    
    -- black cap
    texture {
        position = {283, 428, 30, 30},
        image = function()
            return get(black_cap)
        end
    }, 
    
    -- black cap
    texture {
        position = {385, 428, 30, 30},
        image = function()
            return get(black_cap)
        end
    }, 
    
    -- black cap
    texture {
        position = {487, 428, 30, 30},
        image = function()
            return get(black_cap)
        end
    }, 
    
    -- main cap open img
    texture {
        position = {471, 0, 102, 130},
        image = get(main_cap_open),
        visible = function()
            return get(emerg_cap) == 1
        end
    }, 
    
    -- main tmb img
    texture {
        position = {492, 135, 29, 53},
        image = function()
            local a = get(emerg_mode)
            local pic
            if a == 0 then
                pic = get(main_tmb_dn)
            elseif a == 1 then
                pic = get(main_tmb_ctr)
            else
                pic = get(main_tmb_up)
            end
            return pic
        end,
        visible = function()
            return get(emerg_cap) == 1
        end
    }, 
    
    -- main tmb with cap close
    texture {
        position = {478, 88, 58, 116},
        image = function()
            local a = get(emerg_mode)
            local pic
            if a == 0 then
                pic = get(main_tmb_dn_close)
            elseif a == 1 then
                pic = get(main_tmb_ctr_close)
            else
                pic = get(main_tmb_up_close)
            end
            return pic
        end,
        visible = function()
            return get(emerg_cap) ~= 1
        end
    }
}