-- this is the electrical panel logic, shown on 3D cockpit panels...
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

-- define images
defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))
defineProperty("needles_2", langImage("needles", 18, 158, 13, 98))
defineProperty("needles_3", langImage("needles", 34, 158, 13, 98))

defineProperty("yellow_led", loadLED("yellow"))
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))
defineProperty("red_small_led", loadLED("red_small"))
defineProperty("black_cap", langImage("covers", 0, 17, 56, 56)) -- black cap image

-- initial switchers values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

local time_counter = 0
local not_loaded = true

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
-- INSTRUMENT NEEDLE INERTIA (realistic movement)
-- ═══════════════════════════════════════════════════════════════════════════
-- Real An-24 voltmeters/ammeters are physical mechanisms with mass
-- and a damper. The needle does not jump instantly, it approaches the value smoothly.
-- These variables smoothly "catch up" with the computed values, imitating inertia.
--
-- NEEDLE_SPEED — needle movement speed (higher = faster response).
-- ~6 gives the lively but smooth movement of a real needle instrument.
-- Lower (3-4) = a more "viscous" heavy needle. Higher (10+) = snappier.
local NEEDLE_SPEED = 6.0

-- Smoothed (displayed) needle values — catch up with the target with inertia
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

-- Smooth approach of a value to its target (time-based exponential smoothing)
local function needle_smooth(current, target, dt)
    local k = NEEDLE_SPEED * dt
    if k > 1 then
        k = 1
    end -- protection at low FPS / large dt
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

-- seam datarefs: indication state published for the 3D render (electric_panel_3d reads these).
-- (electric_panel_2d still computes independently; it can be pointed at these later.)
local ind_go_left_amp = cGPf(pfx .. "power/ind_go_left_amp")
local ind_go_right_amp = cGPf(pfx .. "power/ind_go_right_amp")
local ind_stg_left_amp = cGPf(pfx .. "power/ind_stg_left_amp")
local ind_stg_right_amp = cGPf(pfx .. "power/ind_stg_right_amp")
local ind_gs_amp = cGPf(pfx .. "power/ind_gs_amp")
local ind_bat_amp = cGPf(pfx .. "power/ind_bat_amp")
local ind_ac36_volt = cGPf(pfx .. "power/ind_ac36_volt")
local ind_ac115_volt = cGPf(pfx .. "power/ind_ac115_volt")
local ind_ac115_freq = cGPf(pfx .. "power/ind_ac115_freq")
local ind_dc_volt = cGPf(pfx .. "power/ind_dc_volt")
local ind_stg_left_fail = cGPi(pfx .. "power/ind_stg_left_fail")
local ind_stg_right_fail = cGPi(pfx .. "power/ind_stg_right_fail")
local ind_emerg_bus = cGPi(pfx .. "power/ind_emerg_bus")
local ind_go_left_fail = cGPi(pfx .. "power/ind_go_left_fail")
local ind_go_right_fail = cGPi(pfx .. "power/ind_go_right_fail")
local ind_gs24_on_bus = cGPi(pfx .. "power/ind_gs24_on_bus")
local ind_ground = cGPi(pfx .. "power/ind_ground")
local ind_emerg36 = cGPi(pfx .. "power/ind_emerg36")

-- pverall calculations per frame
function update()
    -- initial switchers values
    time_counter = time_counter + get(frame_time)
    if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
        set(stg1_on_bus, 0)
        set(stg2_on_bus, 0)
        set(gs24_on_bus, 0)
        set(go1_on_bus, 0)
        set(go2_on_bus, 0)
        set(PT1000_mode, 1)
        set(inv_PT1000_1, 0)
        set(inv_PT1000_2, 0)
        set(PO750_mode, 1)
        set(inv_PT750, 0)
        set(power_mode, 1)
        set(GS24_mode, 1)
        set(emerg_mode, 1)
        set(bus_AC_36_volt, 0)
        set(bus_AC_115_volt, 0)
        not_loaded = false
    end

    GO_left_amp = interpolate(GO_amps_table, get(go1_amp)) -- calculate angle for GO left ampermeter needle
    GO_right_amp = interpolate(GO_amps_table, get(go2_amp)) -- calculate angle for GO right ampermeter needle
    STG_left_amp = get(stg1_amp) * 220 / 1000 - 100 -- calculate angle for STG left ampermeter needle
    -- print(STG_left_amp, get(get(stg1_amp)))

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

    -- NEEDLE INERTIA: the smoothed values smoothly catch up with the computed ones.
    -- The instrument needles (needle components below) use the *_sm variables.
    local dt = get(frame_time)
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

        -- XP12 AMMETER VIBRATION FROM GENERATOR COMMUTATION.
        -- On the real An-24 the ammeter needles tremble slightly from the current ripple
        -- of the generators (STG-12TM40, GS-24) — normal behaviour of a brushed
        -- commutator generator. Vibration only while the engines run (the generators
        -- are turning). The amplitude is small — realism without annoyance.
        local gen_active = (get(N1) > 40 or get(N2) > 40)
        if gen_active then
            -- ammeter needles pulse slightly (~0.3° = ~3-5 A on the scale)
            GO_left_amp_sm = GO_left_amp_sm + (math.random() - 0.5) * 0.6
            GO_right_amp_sm = GO_right_amp_sm + (math.random() - 0.5) * 0.6
            STG_left_amp_sm = STG_left_amp_sm + (math.random() - 0.5) * 0.6
            STG_right_amp_sm = STG_right_amp_sm + (math.random() - 0.5) * 0.6
            GS_amp_sm = GS_amp_sm + (math.random() - 0.5) * 0.6
            BAT_amp_sm = BAT_amp_sm + (math.random() - 0.5) * 0.4
        end
    end

    -- publish indication state for the 3D render (electric_panel_3d)
    set(ind_go_left_amp, GO_left_amp_sm)
    set(ind_go_right_amp, GO_right_amp_sm)
    set(ind_stg_left_amp, STG_left_amp_sm)
    set(ind_stg_right_amp, STG_right_amp_sm)
    set(ind_gs_amp, GS_amp_sm)
    set(ind_bat_amp, BAT_amp_sm)
    set(ind_ac36_volt, AC36_volt_sm)
    set(ind_ac115_volt, AC115_volt_sm)
    set(ind_ac115_freq, AC115_freq_sm)
    set(ind_dc_volt, DC_volt_sm)
    set(ind_stg_left_fail, bool2int(STG_left_fail_led))
    set(ind_stg_right_fail, bool2int(STG_right_fail_led))
    set(ind_emerg_bus, bool2int(emerg_bus_led))
    set(ind_go_left_fail, bool2int(GO_left_fail_led))
    set(ind_go_right_fail, bool2int(GO_right_fail_led))
    set(ind_gs24_on_bus, bool2int(GS24_on_bus_led))
    set(ind_ground, bool2int(ground_led))
    set(ind_emerg36, bool2int(emerg36_led))
end
