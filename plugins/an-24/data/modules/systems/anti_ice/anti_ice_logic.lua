-- this is simple anti-ice system logic
-- define property table
-- sim datarefs
defineProperty("pitot_1", globalProperty("sim/cockpit/switches/pitot_heat_on")) -- pitot heat 1
defineProperty("pitot_2", globalProperty("sim/cockpit/switches/pitot_heat_on2")) -- pitot heat 2
defineProperty("prop_ht", globalProperty("sim/cockpit/switches/anti_ice_prop_heat")) -- propeller heat
defineProperty("wind_ht", globalProperty("sim/cockpit/switches/anti_ice_window_heat")) -- window heat
defineProperty("wing_ht", globalProperty("sim/cockpit/switches/anti_ice_surf_heat")) -- on/off wing heat
defineProperty("engine_ht", globalProperty("sim/cockpit/switches/anti_ice_inlet_heat")) -- on/off engine heat. this heats only first engine :(
defineProperty("ice_detect", globalProperty("sim/cockpit2/ice/ice_detect_on")) -- on/off ice detection
defineProperty("aoa_ht", globalProperty("sim/cockpit/switches/anti_ice_AOA_heat")) -- on/off AOA heat
defineProperty("thermo", globalProperty("sim/cockpit2/temperature/outside_air_temp_degc")) -- outside temperature
defineProperty("tas", globalProperty("sim/flightmodel/position/true_airspeed")) -- true auspeed in meters per sec
defineProperty("ice_on_plane", globalProperty("sim/cockpit2/annunciators/ice")) -- ice detected
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
--defineProperty("ice_all_on", globalProperty("sim/cockpit2/ice/ice_all_on")) -- all systems ON. this heats other engines too (Not compatible with XP12)

-- ice on parts
defineProperty("frm_ice", globalProperty("sim/flightmodel/failures/frm_ice")) -- Ratio of icing on wings/airframe
defineProperty("pitot_ice", globalProperty("sim/flightmodel/failures/pitot_ice")) -- Ratio of icing on pitot tube
defineProperty("pitot_ice2", globalProperty("sim/flightmodel/failures/pitot_ice2")) -- Ratio of icing on pitot tube2
defineProperty("prop_ice", globalProperty("sim/flightmodel/failures/prop_ice")) -- Ratio of icing on the prop
defineProperty("inlet_ice", globalProperty("sim/flightmodel/failures/inlet_ice")) -- Ratio of icing on the air inlets?
defineProperty("window_ice", globalProperty("sim/flightmodel/failures/window_ice")) -- Ratio of icing on the windshield
defineProperty("aoa_ice", globalProperty("sim/flightmodel/failures/aoa_ice")) -- Ratio of icing on alpha vane

-- filures
defineProperty("engine_ht_fail", globalProperty("sim/operation/failures/rel_ice_inlet_heat")) -- engine heat fail
defineProperty("prop_ht_fail", globalProperty("sim/operation/failures/rel_ice_prop_heat")) -- prop heat fail
defineProperty("pitot1_ht_fail", globalProperty("sim/operation/failures/rel_ice_pitot_heat1")) -- pitot 1 heat fail
defineProperty("pitot2_ht_fail", globalProperty("sim/operation/failures/rel_ice_pitot_heat2")) -- pitot 2 heat fail
defineProperty("aoa_ht_fail", globalProperty("sim/operation/failures/rel_ice_AOA_heat")) -- AOA heat fail
defineProperty("wing_ht_fail", globalProperty("sim/operation/failures/rel_ice_surf_heat")) -- AOA heat fail
defineProperty("detector_fail", globalProperty("sim/operation/failures/rel_ice_detect")) -- ice detector fail

-- custom switchers
defineProperty("pitot_1_sw", globalProperty("an-24/ice/pitot1_sw")) -- pitot heat 1
defineProperty("pitot_2_sw", globalProperty("an-24/ice/pitot2_sw")) -- pitot heat 2
defineProperty("prop_ht_sw", globalProperty("an-24/ice/prop_ht_sw")) -- propeller heat
defineProperty("wind_ht_psw1", globalProperty("an-24/ice/window_ht_psw1")) -- window heat pilot sw1 (low)
defineProperty("wind_ht_psw2", globalProperty("an-24/ice/window_ht_psw2")) -- window heat pilot sw2 (high)
defineProperty("wind_ht_cpsw1", globalProperty("an-24/ice/window_ht_cpsw1")) -- window heat copilot sw1 (low)
defineProperty("wind_ht_cpsw2", globalProperty("an-24/ice/window_ht_cpsw2")) -- window heat copilot sw2 (high)
defineProperty("wing_ht_sw", globalProperty("an-24/ice/wing_ht_sw")) -- on/off wing heat
defineProperty("engine_ht_sw", globalProperty("an-24/ice/engine_ht_sw")) -- on/off engine heat
defineProperty("ice_detect_sw", globalProperty("an-24/ice/rio_sw")) -- on/off ice detection
defineProperty("aoa_ht_sw", globalProperty("an-24/ice/aoa_ht_sw")) -- on/off AOA heat

-- power
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))
defineProperty("aa_main_cc", globalProperty("an-24/ice/aa_main_cc"))
defineProperty("aa_emerg_cc", globalProperty("an-24/ice/aa_emerg_cc"))
defineProperty("aa_115_cc", globalProperty("an-24/ice/aa_115_cc"))

-- for 2D
defineProperty("wing_heat_lit_2d", globalProperty("an-24/ice/wing_heat_lit")) -- for 2D panel
defineProperty("engine_heat_lit_2d", globalProperty("an-24/ice/engine_heat_lit")) -- for 2D panel
defineProperty("prop_left_lit_2d", globalProperty("an-24/ice/prop_left_lit")) -- for 2D panel
defineProperty("prop_right_lit_2d", globalProperty("an-24/ice/prop_right_lit")) -- for 2D panel
defineProperty("pitot1_lit_2d", globalProperty("an-24/ice/pitot1_lit")) -- for 2D panel
defineProperty("pitot2_lit_2d", globalProperty("an-24/ice/pitot2_lit")) -- for 2D panel
defineProperty("aoa_heat_lit_2d", globalProperty("an-24/ice/aoa_heat_lit")) -- for 2D panel
defineProperty("pitot1_test_lit_2d", globalProperty("an-24/ice/pitot1_test_lit")) -- for 2D panel
defineProperty("pitot2_test_lit_2d", globalProperty("an-24/ice/pitot2_test_lit")) -- for 2D panel
defineProperty("aoa_heat_test_lit_2d", globalProperty("an-24/ice/aoa_heat_test_lit")) -- for 2D panel
defineProperty("rio_heat_lit_2d", globalProperty("an-24/ice/rio_heat_lit")) -- for 2D panel
defineProperty("ice_left_eng_lit_2d", globalProperty("an-24/ice/ice_left_eng_lit")) -- for 2D panel
defineProperty("ice_right_eng_lit_2d", globalProperty("an-24/ice/ice_right_eng_lit")) -- for 2D panel
defineProperty("thermo_angle_2d", globalProperty("an-24/ice/thermo_angle")) -- for 2D panel
defineProperty("test_btn", globalProperty("an-24/ice/test_btn")) -- for 2D panel
-- time
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- flight time
-- images
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))
defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))
defineProperty("black_cap", langImage("covers", 0, 17, 56, 56)) -- black cap image

-- bool2int() and interpolate(): shared helpers in core/glbl_func.lua

-- table for termo gauge
local termo_table = {
    {-500, -180}, 
    {-60, -100}, 
    {-50, -90}, 
    {0, -45}, 
    {50, 8}, 
    {100, 55}, 
    {150, 97}, 
    {1000, 180}
}

-- lamps
local wing_heat_lit = false
local engine_heat_lit = false
local prop_heat_lit = false
local prop_right_lit = false
local prop_left_lit = true
local pitot1_lit = false
local pitot2_lit = false
local aoa_heat_lit = false

local pitot1_test_lit = false
local pitot2_test_lit = false
local aoa_heat_test_lit = false
local rio_heat_lit = false

local ice_on_plane_lit = false
local pos_not_work_lit = false
local ice_left_eng_lit = false
local ice_right_eng_lit = false
local pitot_left_fail_lit = false
local pitot_right_fail_lit = false

local plane_must_heat = false

local test_button = false
local test_pressed = false
local termo_angle = -90

-- seam datarefs for the 3D render (anti_ice_3d): the values that are NOT already
-- published as *_2d. (The 3D render reads the existing *_2d datarefs for the rest.)
local ind_prop_a = cGPi(pfx .. "ice/ind_prop_a") -- prop blink phase A
local ind_prop_b = cGPi(pfx .. "ice/ind_prop_b") -- prop blink phase B
local ind_prop_test = cGPi(pfx .. "ice/ind_prop_test") -- prop test lamp
local ind_pos_not_work = cGPi(pfx .. "ice/ind_pos_not_work")
local ind_ice_on_plane = cGPi(pfx .. "ice/ind_ice_on_plane")

local switch_sound = loadSample('sounds/custom/metal_switch.wav')
local cap_sound = loadSample('sounds/custom/cap.wav')
local btn_click = loadSample('sounds/custom/plastic_btn.wav')

-- temporal variables
local window_heat_timer = 0
local eng_heat_timer = 0
local prop_heat_counter = 0
local pos_lamp_counter = 0

registerCommandHandler(createCommand("An-24/Instruments/Pilot/window_heat_low_pilot_on", "Window heat low pilot on."),
    0, function(p)
        if p == 0 and get(wind_ht_psw1) ~= 1 then
            set(wind_ht_psw1, 1)
        end
        return 0
    end)
    
registerCommandHandler(createCommand("An-24/Instruments/Pilot/window_heat_low_pilot_off", "Window heat low pilot off."),
    0, function(p)
        if p == 0 and get(wind_ht_psw1) ~= 0 then
            set(wind_ht_psw1, 0)
        end
        return 0
    end)

registerCommandHandler(createCommand("An-24/Instruments/Pilot/window_heat_low_pilot_toggle",
    "Window heat low pilot toggle."), 0, function(p)
    if p == 0 then
        if get(wind_ht_psw1) ~= 1 then
            set(wind_ht_psw1, 1)
        else
            set(wind_ht_psw1, 0)
        end
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Pilot/window_heat_high_pilot_on", "Window heat high pilot on."),
    0, function(p)
        if p == 0 and get(wind_ht_psw2) ~= 1 then
            set(wind_ht_psw2, 1)
        end
        return 0
    end)

registerCommandHandler(
    createCommand("An-24/Instruments/Pilot/window_heat_high_pilot_off", "Window heat high pilot off."), 0, function(p)
        if p == 0 and get(wind_ht_psw2) ~= 0 then
            set(wind_ht_psw2, 0)
        end
        return 0
    end)

registerCommandHandler(createCommand("An-24/Instruments/Pilot/window_heat_high_pilot_toggle",
    "Window heat high pilot toggle."), 0, function(p)
    if p == 0 then
        if get(wind_ht_psw2) ~= 1 then
            set(wind_ht_psw2, 1)
        else
            set(wind_ht_psw2, 0)
        end
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Copilot/window_heat_low_copilot_on",
    "Window heat low copilot on."), 0, function(p)
    if p == 0 and get(wind_ht_cpsw1) ~= 1 then
        set(wind_ht_cpsw1, 1)
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Copilot/window_heat_low_copilot_off",
    "Window heat low copilot off."), 0, function(p)
    if p == 0 and get(wind_ht_cpsw1) ~= 0 then
        set(wind_ht_cpsw1, 0)
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Copilot/window_heat_low_copilot_toggle",
    "Window heat low copilot toggle."), 0, function(p)
    if p == 0 then
        if get(wind_ht_cpsw1) ~= 1 then
            set(wind_ht_cpsw1, 1)
        else
            set(wind_ht_cpsw1, 0)
        end
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Copilot/window_heat_high_copilot_on",
    "Window heat high copilot on."), 0, function(p)
    if p == 0 and get(wind_ht_cpsw2) ~= 1 then
        set(wind_ht_cpsw2, 1)
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Copilot/window_heat_high_copilot_off",
    "Window heat high copilot off."), 0, function(p)
    if p == 0 and get(wind_ht_cpsw2) ~= 0 then
        set(wind_ht_cpsw2, 0)
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Copilot/window_heat_high_copilot_toggle",
    "Window heat high copilot toggle."), 0, function(p)
    if p == 0 then
        if get(wind_ht_cpsw2) ~= 1 then
            set(wind_ht_cpsw2, 1)
        else
            set(wind_ht_cpsw2, 0)
        end
    end
    return 0
end)

-- post frame calculations
function update()
    local passed = get(frame_time)
    if passed > 0 then
        -- power calculations
        local power27 = dcOK()
        local power27_em = get(bus_DC_27_volt_emerg) > 21
        local power115 = acOK()

        local bus27_cc = 0
        local bus27_em_cc = 0
        local bus115_cc = 0

        local eng1 = get(N1)
        local eng2 = get(N2)

        test_button = test_pressed or get(test_btn) == 1
        ------------------
        if power27_em then

            -- wing heat
            if ((get(wing_ht_sw) < 0 and plane_must_heat) or get(wing_ht_sw) > 0) and window_heat_timer < 1 then
                window_heat_timer = window_heat_timer + passed / 40
                bus27_em_cc = bus27_em_cc + 5
            elseif get(wing_ht_sw) == 0 and window_heat_timer > 0 then
                window_heat_timer = window_heat_timer - passed / 40
                bus27_em_cc = bus27_em_cc + 5
            end

            if window_heat_timer > 0.75 and (eng1 > 50 or eng2 > 50) and get(wing_ht_fail) < 6 then
                set(wing_ht, 1)
            else
                set(wing_ht, 0)
            end

            if get(wing_ht) == 1 then
                wing_heat_lit = true
            else
                wing_heat_lit = false
            end
            ---

            -- left PVD
            if get(pitot_1_sw) == 1 then
                set(pitot_1, 1)
                bus27_em_cc = bus27_em_cc + 10
                pitot1_lit = true
                pitot1_test_lit = false
            elseif get(pitot_1_sw) == -1 then
                set(pitot_1, 0)
                pitot1_test_lit = true
                pitot1_lit = false
            else
                set(pitot_1, 0)
                pitot1_lit = false
                pitot1_test_lit = false
            end

            pitot_left_fail_lit = get(pitot1_ht_fail) == 6
            pitot1_lit = pitot1_lit and not pitot_left_fail_lit
            pitot1_test_lit = pitot1_test_lit and not pitot_left_fail_lit

            -- right PVD
            if get(pitot_2_sw) == 1 then
                set(pitot_2, 1)
                bus27_em_cc = bus27_em_cc + 10
                pitot2_lit = true
                pitot2_test_lit = false
            elseif get(pitot_2_sw) == -1 then
                set(pitot_2, 0)
                pitot2_test_lit = true
                pitot2_lit = false
            else
                set(pitot_2, 0)
                pitot2_lit = false
                pitot2_test_lit = false
            end

            pitot_right_fail_lit = get(pitot1_ht_fail) == 6
            pitot1_lit = pitot1_lit and not pitot_right_fail_lit
            pitot1_test_lit = pitot1_test_lit and not pitot_right_fail_lit

            -- angle of atack sensor heat
            if get(aoa_ht_sw) == 1 then
                set(aoa_ht, 1)
                bus27_em_cc = bus27_em_cc + 10
                aoa_heat_lit = true
                aoa_heat_test_lit = false
            elseif get(aoa_ht_sw) == -1 then
                set(aoa_ht, 0)
                aoa_heat_lit = false
                aoa_heat_test_lit = true
            else
                set(aoa_ht, 0)
                aoa_heat_lit = false
                aoa_heat_test_lit = false
            end

            local aoa_fail = get(aoa_ht_fail) == 6
            aoa_heat_lit = aoa_heat_lit and not aoa_fail
            aoa_heat_test_lit = aoa_heat_test_lit and not aoa_fail

            -- lamps logic
            local speed = get(tas) * 0.25
            -- left engine heat lamp
            if (eng1 + speed > 5 and eng1 + speed < 50) or (plane_must_heat and get(engine_ht) == 0) then
                ice_left_eng_lit = true
            else
                ice_left_eng_lit = false
            end

            -- right engine heat lamp
            if (eng2 + speed > 5 and eng2 + speed < 50) or (plane_must_heat and get(engine_ht) == 0) then
                ice_right_eng_lit = true
            else
                ice_right_eng_lit = false
            end

            -- plane in ice lamp
            ice_on_plane_lit = plane_must_heat

            -- POS not work lamp
            if plane_must_heat and not wing_heat_lit or (ice_left_eng_lit or ice_right_eng_lit) then
                pos_lamp_counter = pos_lamp_counter + passed
                if pos_lamp_counter > 0.5 then
                    pos_lamp_counter = 0
                    pos_not_work_lit = not pos_not_work_lit
                end
            else
                pos_not_work_lit = false
                pos_lamp_counter = 0
            end

        else
            set(ice_detect, 0)
            set(pitot_1, 0)
            set(pitot_2, 0)
            set(aoa_ht, 0)
            wing_heat_lit = false
            pitot1_lit = false
            pitot2_lit = false
            aoa_heat_lit = false
            if eng1 < 50 and eng2 < 50 then
                set(wing_ht, 0)
            end
            pitot1_test_lit = false
            pitot2_test_lit = false
            aoa_heat_test_lit = false
            ice_left_eng_lit = false
            ice_right_eng_lit = false
            ice_on_plane_lit = false
            pos_not_work_lit = false
            pitot_right_fail_lit = false
            pitot_left_fail_lit = false
        end

        ----------------
        if power27 then

            -- engines heat. can be changed only if power
            if get(engine_ht_sw) == 1 and eng_heat_timer < 1 then
                eng_heat_timer = eng_heat_timer + passed / 6
                bus27_cc = bus27_cc + 10
            elseif get(engine_ht_sw) == 0 and eng_heat_timer > 0 then
                eng_heat_timer = eng_heat_timer - passed / 6
                bus27_cc = bus27_cc + 10
            end

            if eng_heat_timer > 0.8 and (eng1 > 50 or eng2 > 50) and get(engine_ht_fail) < 6 then
                set(engine_ht, 1)
                --set(ice_all_on, 1) -- temporal solution for heating all engines (Not needed in XP12)
            else
                set(engine_ht, 0)
                --set(ice_all_on, 0) -- temporal solution for heating all engines (Not needed in XP12)
            end

            if get(engine_ht) == 1 then
                engine_heat_lit = true
            else
                engine_heat_lit = false
            end
            -------

            -- RIO-3 logic
            local rio_switcher = get(ice_detect_sw)
            local ice_detected = get(frm_ice) + get(pitot_ice) + get(pitot_ice2) + get(prop_ice) + get(inlet_ice) +
                                     get(window_ice) + get(aoa_ice) > 0.01

            -- RIO mode
            if rio_switcher == 1 then
                set(ice_detect, 1)
            else
                set(ice_detect, 0)
            end

            -- RIO lamps
            if (rio_switcher == -1 or (rio_switcher == 1 and ice_detected)) and get(detector_fail) < 6 then
                rio_heat_lit = true
            else
                rio_heat_lit = false
            end

            -- RIO signal
            if ice_detected then
                plane_must_heat = true
            else
                plane_must_heat = false
            end

            -- plane_must_heat = true  -- test

        else
            set(ice_detect, 0)
            engine_heat_lit = false
            rio_heat_lit = false
            plane_must_heat = false
        end

        ----------------
        if power115 then

            -- prop heat
            if ((get(prop_ht_sw) == 1 and plane_must_heat) or get(prop_ht_sw) == -1) and get(prop_ht_fail) < 6 then
                set(prop_ht, 1)
                bus115_cc = bus115_cc + 30
                prop_heat_lit = true
            elseif get(prop_ht_sw) == 0 or get(prop_ht_fail) == 6 then
                set(prop_ht, 0)
                prop_heat_lit = false
            end

            if get(wind_ht_psw1) == 1 or get(wind_ht_psw2) == 1 or get(wind_ht_cpsw1) == 1 or get(wind_ht_cpsw2) == 1 then -- window heat
                set(wind_ht, 1)
                bus115_cc = bus115_cc + 4
            else
                set(wind_ht, 0)
            end

            -- prop heat lamps
            prop_heat_counter = prop_heat_counter + passed
            -- switch lamps
            if prop_heat_counter > 25 then
                prop_heat_counter = 0
                prop_left_lit = not prop_left_lit
            end

        else
            set(prop_ht, 0)
            set(wind_ht, 0)
            prop_heat_lit = false
        end

        -- set currents
        set(aa_main_cc, bus27_cc)
        set(aa_emerg_cc, bus27_em_cc)
        set(aa_115_cc, bus115_cc)

        -- test lamp button
        if test_button and power27_em then
            wing_heat_lit = true
            engine_heat_lit = true
            -- pitot1_lit = true
            -- pitot2_lit = true
            -- aoa_heat_lit = true
            -- pitot1_test_lit = true
            -- pitot2_test_lit = true
            -- aoa_heat_test_lit = true
            -- rio_heat_lit = true -- RIO sensor heating monitor
            -- prop_left_lit = true
            prop_heat_lit = true
            prop_right_lit = true
            -- ice_left_eng_lit = true
            -- ice_right_eng_lit = true
            -- ice_on_plane_lit = true
            pos_not_work_lit = true
        else
            prop_right_lit = false
        end

        -- thermometer gauge
        termo_angle = interpolate(termo_table, get(thermo))

    end

    -- set 2D lamps
    set(wing_heat_lit_2d, bool2int(wing_heat_lit))
    set(engine_heat_lit_2d, bool2int(engine_heat_lit))
    set(prop_left_lit_2d, bool2int(prop_left_lit and prop_heat_lit))
    set(prop_right_lit_2d, bool2int(not prop_left_lit and prop_heat_lit))
    set(aoa_heat_lit_2d, bool2int(aoa_heat_lit))
    set(pitot1_lit_2d, bool2int(pitot1_lit))
    set(pitot2_lit_2d, bool2int(pitot2_lit))
    set(pitot1_test_lit_2d, bool2int(pitot1_test_lit))
    set(pitot2_test_lit_2d, bool2int(pitot2_test_lit))
    set(aoa_heat_test_lit_2d, bool2int(aoa_heat_test_lit))
    set(rio_heat_lit_2d, bool2int(rio_heat_lit))
    set(ice_left_eng_lit_2d, bool2int(ice_left_eng_lit))
    set(ice_right_eng_lit_2d, bool2int(ice_right_eng_lit))
    set(thermo_angle_2d, termo_angle)

    -- seam values for the 3D render (anti_ice_3d) — match the original component expressions
    set(ind_prop_a, bool2int(not prop_left_lit and prop_heat_lit))
    set(ind_prop_b, bool2int(prop_left_lit and prop_heat_lit))
    set(ind_prop_test, bool2int(prop_right_lit))
    set(ind_pos_not_work, bool2int(pos_not_work_lit))
    set(ind_ice_on_plane, bool2int(ice_on_plane_lit))

end
