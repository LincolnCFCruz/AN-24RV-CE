-- This skript contains components for fuel system manipulation and indication
defineProperty("fire_valve1_sw", globalProperty("an-24/fuel/fire_valve1_sw")) -- fire valve switch for engine 1
defineProperty("fire_valve2_sw", globalProperty("an-24/fuel/fire_valve2_sw")) -- fire valve switch for engine 2
defineProperty("fire_valve3_sw", globalProperty("an-24/fuel/fire_valve3_sw")) -- fire valve switch for engine 3
defineProperty("fuel_circle_valve_sw", globalProperty("an-24/fuel/fuel_circle_valve_sw")) -- valve for fuel circulation between left and right tanks
defineProperty("pump1_switch", globalProperty("an-24/fuel/pump1_switch")) -- fuel pump switch tank 1
defineProperty("pump2_switch", globalProperty("an-24/fuel/pump2_switch")) -- fuel pump switch tank 2
defineProperty("pump3_switch", globalProperty("an-24/fuel/pump3_switch")) -- fuel pump switch tank 3
defineProperty("pump4_switch", globalProperty("an-24/fuel/pump4_switch")) -- fuel pump switch tank 4
defineProperty("q_meter1_switch", globalProperty("an-24/fuel/q_meter1_switch")) -- switcher for quantity meter left
defineProperty("q_meter2_switch", globalProperty("an-24/fuel/q_meter2_switch")) -- switcher for quantity meter right
defineProperty("ff_meter_switch", globalProperty("an-24/fuel/ff_meter_switch")) -- switcher for fuel flow meter
defineProperty("auto_ff_switch", globalProperty("an-24/fuel/auto_ff_switch")) -- switcher for fuel flow automat
defineProperty("quantity_mode", globalProperty("an-24/fuel/quantity_mode")) -- mode of quantity meter
defineProperty("fuel_stop1", globalProperty("an-24/fuel/fuel_stop1")) -- stops on center panel
defineProperty("fuel_stop2", globalProperty("an-24/fuel/fuel_stop2")) -- stops on center panel
defineProperty("fuel_stop1_cap", globalProperty("an-24/fuel/fuel_stop1_cap")) -- stops on center panel
defineProperty("fuel_stop2_cap", globalProperty("an-24/fuel/fuel_stop2_cap")) -- stops on center panel
defineProperty("fuel_pump_1", globalProperty("an-24/fuel/tank1_pump")) -- fuel pump for tank 1
defineProperty("fuel_pump_2", globalProperty("an-24/fuel/tank2_pump")) -- fuel pump for tank 2
defineProperty("fuel_pump_3", globalProperty("an-24/fuel/tank3_pump")) -- fuel pump for tank 3
defineProperty("fuel_pump_4", globalProperty("an-24/fuel/tank4_pump")) -- fuel pump for tank 4
defineProperty("fuel_circle_valve", globalProperty("an-24/fuel/fuel_circle_valve")) -- valve for fuel circulation between left and right tanks
defineProperty("mixt_valve1", globalProperty("an-24/fuel/fire_valve1")) -- fire valve for engine 1
defineProperty("mixt_valve2", globalProperty("an-24/fuel/fire_valve2")) -- fire valve for engine 2
defineProperty("mixt_valve3", globalProperty("an-24/fuel/fire_valve3")) -- fire valve for engine 3
defineProperty("chip_detect1", globalProperty("sim/cockpit/warnings/annunciators/chip_detected[0]")) -- chip in engine1
defineProperty("chip_detect2", globalProperty("sim/cockpit/warnings/annunciators/chip_detected[1]")) -- chip in engine1
defineProperty("tank1_q_ind", globalProperty("an-24/fuel/tank1_q_ind")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("tank2_q_ind", globalProperty("an-24/fuel/tank2_q_ind")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("tank3_q_ind", globalProperty("an-24/fuel/tank3_q_ind")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("tank4_q_ind", globalProperty("an-24/fuel/tank4_q_ind")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("FF1", globalProperty("sim/flightmodel/engine/ENGN_FF_[0]")) -- fuel flow for engine 1
defineProperty("FF2", globalProperty("sim/flightmodel/engine/ENGN_FF_[1]")) -- fuel flow for engine 2
defineProperty("FF3", globalProperty("sim/flightmodel/engine/ENGN_FF_[2]")) -- fuel flow for engine 3
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- sim time
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("bus_AC_36_volt", globalProperty("an-24/power/bus_AC_36_volt"))
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))
defineProperty("fuel_flow_cc", globalProperty("an-24/fuel/fuel_flow_cc"))
defineProperty("tank1_block_fail", globalProperty("sim/operation/failures/rel_fuel_block0")) -- fuel filter blocked
defineProperty("tank2_block_fail", globalProperty("sim/operation/failures/rel_fuel_block1")) -- fuel filter blocked
defineProperty("tank3_block_fail", globalProperty("sim/operation/failures/rel_fuel_block2")) -- fuel filter blocked
defineProperty("tank4_block_fail", globalProperty("sim/operation/failures/rel_fuel_block3")) -- fuel filter blocked
defineProperty("quant_1000_lit", globalProperty("an-24/fuel/quant_1000_lit")) --
defineProperty("left_filter_block_lit", globalProperty("an-24/fuel/left_filter_block_lit")) --
defineProperty("right_filter_block_lit", globalProperty("an-24/fuel/right_filter_block_lit")) --
defineProperty("fuel_circle_lit", globalProperty("an-24/fuel/fuel_circle_lit")) --
defineProperty("left_fuel_press_lit", globalProperty("an-24/fuel/left_fuel_press_lit")) --
defineProperty("right_fuel_press_lit", globalProperty("an-24/fuel/right_fuel_press_lit")) --
defineProperty("left_pk_open_lit", globalProperty("an-24/fuel/left_pk_open_lit")) --
defineProperty("right_pk_open_lit", globalProperty("an-24/fuel/right_pk_open_lit")) --
defineProperty("left_chip_lit", globalProperty("an-24/fuel/left_chip_lit")) --
defineProperty("right_chip_lit", globalProperty("an-24/fuel/right_chip_lit")) --
defineProperty("fuel_lump1_lit", globalProperty("an-24/fuel/fuel_lump1_lit")) --
defineProperty("fuel_lump2_lit", globalProperty("an-24/fuel/fuel_lump2_lit")) --
defineProperty("fuel_lump3_lit", globalProperty("an-24/fuel/fuel_lump3_lit")) --
defineProperty("fuel_lump4_lit", globalProperty("an-24/fuel/fuel_lump4_lit")) --
defineProperty("fuel_flow_left_angle", globalProperty("an-24/fuel/fuel_flow_left_angle")) --
defineProperty("fuel_flow_right_angle", globalProperty("an-24/fuel/fuel_flow_right_angle")) --
defineProperty("fuel_flow_left_count", globalProperty("an-24/fuel/fuel_flow_left_count")) --
defineProperty("fuel_flow_right_count", globalProperty("an-24/fuel/fuel_flow_right_count")) --
defineProperty("fuel_flow_left_count_rot", globalProperty("an-24/fuel/fuel_flow_left_count_rot")) --
defineProperty("fuel_flow_right_count_rot", globalProperty("an-24/fuel/fuel_flow_right_count_rot")) --
defineProperty("fuel_quant1_angle", globalProperty("an-24/fuel/fuel_quant1_angle")) --
defineProperty("fuel_quant2_angle", globalProperty("an-24/fuel/fuel_quant2_angle")) --
defineProperty("fuel_quant_button", globalProperty("an-24/fuel/fuel_quant_button")) --
defineProperty("ru19_pk_open_lit", globalProperty("an-24/fuel/ru19_pk_open_lit")) --
defineProperty("ru19_pk_close_lit", globalProperty("an-24/fuel/ru19_pk_close_lit")) --
defineProperty("set_real_fuel_meter", globalProperty("an-24/set/real_fuel_meter")) -- real fuel meter will show less fuel amount, then it's really is
defineProperty("yellow_led", loadLED("yellow"))
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))
defineProperty("needle_q_left", langImage("needles", 32, 20, 17, 141))
defineProperty("needle_q_right", langImage("needles", 48, 20, 17, 141))
defineProperty("needle_long", langImage("needles", 67, 7, 16, 179))
defineProperty("digitsImage", sasl.gl.loadImage("white_digit_strip.png", 0, 60, 16, 196))
defineProperty("yellow_cap", langImage("covers", 204, 72, 56, 56)) -- yellow cap image
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

local time_counter = 0
local not_loaded = true
local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

-- bool2int() and int2bool(): shared helpers in core/glbl_func.lua

local power_27 = 0
local power_emerg = 0
local power_36 = 0
local power_115 = 0
-- leds variables
local fire_v1_led = false
local fire_v2_led = false
local fire_v3_led = false
local fire_v3_off_led = false
local pump1_led = false
local pump2_led = false
local pump3_led = false
local pump4_led = false
local fuel_circle_led = false
local fuel_press_left_led = false
local fuel_press_right_led = false
local chip_left = false
local chip_right = false
local fuel_1000_lit = false
local left_filter_lit = false
local right_filter_lit = false
-- local variables
local q_left_last_angle = -150 -- previous position of needle for smooth movement
local q_right_last_angle = -150
local q_left_angle = -150
local q_right_angle = -150
local fuel_counter_left = 1000
local fuel_counter_right = 1000
local counter_rotary_left = get(fuel_flow_left_count_rot)
local counter_rotary_right = get(fuel_flow_right_count_rot)
local fuel_show_left = fuel_counter_left + counter_rotary_left
local fuel_show_right = fuel_counter_right + counter_rotary_right
local fuel_flow1_angle = -135
local fuel_flow2_angle = -135
local ff1_actual_angle = math.random() * 40 - 130
local ff1_last_angle = ff1_actual_angle
local ff2_actual_angle = math.random() * 40 - 130
local ff2_last_angle = ff2_actual_angle
local q_left_needed = -150
local q_right_needed = -150
local passed = 0
local fuel_corr_table = {
  {-20, 0}, 
  {0, 0}, 
  {100, 100}, 
  {260, 200}, 
  {450, 300}, 
  {650, 400}, 
  {850, 500}, 
  {1030, 600},
  {1130, 700}, 
  {1230, 800}, 
  {1350, 900}, 
  {1430, 1000}, 
  {1520, 1100}, 
  {1620, 1200}, 
  {1720, 1300},
  {1820, 1400}, 
  {1920, 1500}, 
  {2020, 1600}, 
  {2120, 1700}, 
  {2220, 1800}, 
  {2320, 1900},
  {2430, 2000},
  {2530, 2100}
}

registerCommandHandler(createCommand("An-24/Fuel/fg_left_sw_on", "Fuel gauge left on."), 0, function(p)
    if p == 0 and get(q_meter1_switch) ~= 1 then
        set(q_meter1_switch, 1)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/fg_left_sw_off", "Fuel gauge left off."), 0, function(p)
    if p == 0 and get(q_meter1_switch) ~= 0 then
        set(q_meter1_switch, 0)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/fg_left_sw_toggle", "Fuel gauge left toggle."), 0, function(p)
    if p == 0 then
        if get(q_meter1_switch) == 0 then
            set(q_meter1_switch, 1)
        else
            set(q_meter1_switch, 0)
        end
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/fg_right_sw_on", "Fuel gauge right on."), 0, function(p)
    if p == 0 and get(q_meter2_switch) ~= 1 then
        set(q_meter2_switch, 1)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/fg_right_sw_off", "Fuel gauge right off."), 0, function(p)
    if p == 0 and get(q_meter2_switch) ~= 0 then
        set(q_meter2_switch, 0)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/fg_right_sw_toggle", "Fuel gauge right toggle."), 0, function(p)
    if p == 0 then
        if get(q_meter2_switch) == 0 then
            set(q_meter2_switch, 1)
        else
            set(q_meter2_switch, 0)
        end
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/ff_meter_sw_on", "Fuel flow meter on."), 0, function(p)
    if p == 0 and get(ff_meter_switch) ~= 1 then
        set(ff_meter_switch, 1)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/ff_meter_sw_off", "Fuel flow meter off."), 0, function(p)
    if p == 0 and get(ff_meter_switch) ~= 0 then
        set(ff_meter_switch, 0)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/ff_meter_sw_toggle", "Fuel flow meter toggle."), 0, function(p)
    if p == 0 then
        if get(ff_meter_switch) == 0 then
            set(ff_meter_switch, 1)
        else
            set(ff_meter_switch, 0)
        end
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/auto_ff_sw_on", "Automatic fuel flow on."), 0, function(p)
    if p == 0 and get(auto_ff_switch) ~= 1 then
        set(auto_ff_switch, 1)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/auto_ff_sw_off", "Automatic fuel flow off."), 0, function(p)
    if p == 0 and get(auto_ff_switch) ~= 0 then
        set(auto_ff_switch, 0)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Fuel/auto_ff_sw_toggle", "Automatic fuel flow toggle."), 0, function(p)
    if p == 0 then
        if get(auto_ff_switch) == 0 then
            set(auto_ff_switch, 1)
        else
            set(auto_ff_switch, 0)
        end
    end
    return 0
end)

-- interpolate(): shared helper in core/glbl_func.lua

-- post frame calculations
function update()
    local sim_time = get(flight_time)
    passed = get(frame_time)
    if passed > 0 then
        -- initial switchers values
        time_counter = time_counter + passed
        if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
            set(fire_valve1_sw, 0)
            set(fire_valve2_sw, 0)
            set(pump1_switch, 1)
            set(pump2_switch, 0)
            set(pump3_switch, 0)
            set(pump4_switch, 1)
            set(q_meter1_switch, 0)
            set(q_meter2_switch, 0)
            set(ff_meter_switch, 0)
            set(auto_ff_switch, 0)
            not_loaded = false
        end
        -- power calculations
        if dcOK() then
            power_27 = 1
        else
            power_27 = 0
        end
        if get(bus_DC_27_volt_emerg) > 21 then
            power_emerg = 1
        else
            power_emerg = 0
        end
        if get(bus_AC_36_volt) > 34 then
            power_36 = 1
        else
            power_36 = 0
        end
        if get(bus_AC_115_volt) > 112 then
            power_115 = 1
        else
            power_115 = 0
        end
        -- fire valve leds calculations
        fire_v1_led = power_emerg * get(mixt_valve1) > 0.7
        fire_v2_led = power_emerg * get(mixt_valve2) > 0.7
        fire_v3_led = power_emerg * get(mixt_valve3) > 0.7
        fire_v3_off_led = power_emerg > 0 and get(mixt_valve3) < 0.3
        -- fuel pump leds
        pump1_led = power_27 * get(fuel_pump_1) > 0
        pump2_led = power_27 * get(fuel_pump_2) > 0
        pump3_led = power_27 * get(fuel_pump_3) > 0
        pump4_led = power_27 * get(fuel_pump_4) > 0

        -- fuel circle led
        fuel_circle_led = power_27 * get(fuel_circle_valve) > 0

        -- fuel pressure leds
        if fuel_circle_led and power_36 * power_115 > 0 then
            if pump1_led or pump2_led or pump3_led or pump4_led then
                fuel_press_left_led = true
                fuel_press_right_led = true
            else
                fuel_press_left_led = false
                fuel_press_right_led = false
            end
        elseif not fuel_circle_led and power_36 * power_115 > 0 then
            if pump1_led or pump2_led then
                fuel_press_left_led = true
            else
                fuel_press_left_led = false
            end
            if pump3_led or pump4_led then
                fuel_press_right_led = true
            else
                fuel_press_right_led = false
            end
        else
            fuel_press_left_led = false
            fuel_press_right_led = false
        end
        fuel_press_left_led = fuel_press_left_led and fire_v1_led
        fuel_press_right_led = fuel_press_right_led and fire_v2_led

        -- chip detect led
        chip_left = power_27 * get(chip_detect1) > 0 or (get(mixt_valve1) < 0.3 and power_emerg == 1)
        chip_right = power_27 * get(chip_detect2) > 0 or (get(mixt_valve2) < 0.3 and power_emerg == 1)

        -- fuel quantity indicators
        local real = get(set_real_fuel_meter) == 1
        local q_mode = get(quantity_mode)
        local tank1q = get(tank1_q_ind)
        local tank2q = get(tank2_q_ind)
        local tank3q = get(tank3_q_ind)
        local tank4q = get(tank4_q_ind)
        if real then
            tank1q = interpolate(fuel_corr_table, tank1q)
            tank2q = interpolate(fuel_corr_table, tank2q)
            tank3q = interpolate(fuel_corr_table, tank3q)
            tank4q = interpolate(fuel_corr_table, tank4q)
        end

        local power_mode = 0

        -- determine needed angles
        if get(fuel_quant_button) == 1 then
            q_left_needed = -150
            q_right_needed = -150
            if q_mode == 0 then
                power_mode = 0
            else
                power_mode = 1
            end
        else
            if q_mode == 0 then
                power_mode = 0
            elseif q_mode == 1 then
                q_left_needed = (tank1q + tank2q) * 300 / 2400 - 150
                q_right_needed = (tank3q + tank4q) * 300 / 2400 - 150
                power_mode = 1
            elseif q_mode == 2 then
                q_left_needed = tank1q * 300 / 2400 - 150
                q_right_needed = tank4q * 300 / 2400 - 150
                power_mode = 1
            elseif q_mode == 3 then
                q_left_needed = tank2q * 300 / 1600 - 150
                q_right_needed = tank3q * 300 / 1600 - 150
                power_mode = 1
            end
        end

        -- smooth movement of q-meter needles
        q_left_angle =
            q_left_last_angle + (q_left_needed - q_left_last_angle) * passed * 1 * power_115 * math.random() *
                get(q_meter1_switch) * power_mode
        q_right_angle = q_right_last_angle + (q_right_needed - q_right_last_angle) * passed * 1 * power_115 *
                            math.random() * get(q_meter2_switch) * power_mode

        -- fuel quantity less then 1000kg lamp
        fuel_1000_lit = power_115 == 1 and tank1q + tank2q + tank3q + tank4q < 750 and power_27 == 1

        -- fuel filters lamps
        left_filter_lit = power_27 == 1 and (get(tank1_block_fail) == 6 or get(tank2_block_fail) == 6)
        right_filter_lit = power_27 == 1 and (get(tank3_block_fail) == 6 or get(tank4_block_fail) == 6)

        -- fuel flow meters and fuel counters
        if get(ff_meter_switch) * power_115 > 0 then
            -- fuel_counter_left = fuel_counter_left - get(FF1) * passed
            set(fuel_flow_left_count_rot, get(fuel_flow_left_count_rot) - get(FF1) * passed)
            -- fuel_counter_right = fuel_counter_right - get(FF2) * passed
            set(fuel_flow_right_count_rot, get(fuel_flow_right_count_rot) - get(FF2) * passed)
            fuel_flow1_angle = (get(FF1) * 3600 - 200) * 240 / 600 - 120
            fuel_flow2_angle = (get(FF2) * 3600 - 200) * 240 / 600 - 120
            set(fuel_flow_cc, 4)
        else
            set(fuel_flow_cc, 0)

        end
        fuel_show_left = get(fuel_flow_left_count_rot)
        if fuel_show_left < 0 then
            set(fuel_flow_left_count_rot, get(fuel_flow_left_count_rot) + 1)
        end
        if fuel_show_left > 9990 then
            set(fuel_flow_left_count_rot, get(fuel_flow_left_count_rot) - 5)
        end

        fuel_show_right = get(fuel_flow_right_count_rot)
        if fuel_show_right < 0 then
            set(fuel_flow_right_count_rot, get(fuel_flow_right_count_rot) + 1)
        end
        if fuel_show_right > 9990 then
            set(fuel_flow_right_count_rot, get(fuel_flow_right_count_rot) - 5)
        end

        if fuel_flow1_angle < -135 then
            fuel_flow1_angle = -135
        end
        if fuel_flow2_angle < -135 then
            fuel_flow2_angle = -135
        end

        -- smooth moves of angles
        ff1_actual_angle = ff1_last_angle + (fuel_flow1_angle - ff1_last_angle) * passed * 1
        ff2_actual_angle = ff2_last_angle + (fuel_flow2_angle - ff2_last_angle) * passed * 1

        -- set results for 2D panel
        set(quant_1000_lit, bool2int(fuel_1000_lit))
        set(left_filter_block_lit, bool2int(left_filter_lit))
        set(right_filter_block_lit, bool2int(right_filter_lit))
        set(fuel_circle_lit, bool2int(fuel_circle_led))
        set(left_fuel_press_lit, bool2int(fuel_press_left_led))
        set(right_fuel_press_lit, bool2int(fuel_press_right_led))
        set(left_pk_open_lit, bool2int(fire_v1_led))
        set(right_pk_open_lit, bool2int(fire_v2_led))
        set(left_chip_lit, bool2int(chip_left))
        set(right_chip_lit, bool2int(chip_right))
        set(fuel_lump1_lit, bool2int(pump1_led))
        set(fuel_lump2_lit, bool2int(pump2_led))
        set(fuel_lump3_lit, bool2int(pump3_led))
        set(fuel_lump4_lit, bool2int(pump4_led))
        set(fuel_flow_left_angle, ff1_actual_angle)
        set(fuel_flow_right_angle, ff2_actual_angle)

--[[
        if get(SC_master) == 1 then
            fuel_show_left = get(sc_fuel_show_left)
            fuel_show_right = get(sc_fuel_show_right)
        else
            set(sc_fuel_show_left, fuel_show_left)
            set(sc_fuel_show_right, fuel_show_right)
        end
--]]

        set(fuel_flow_left_count, fuel_show_left / 10)
        set(fuel_flow_right_count, fuel_show_right / 10)
        set(fuel_quant1_angle, q_left_angle)
        set(fuel_quant2_angle, q_right_angle)
        set(ru19_pk_open_lit, bool2int(fire_v3_led))
        set(ru19_pk_close_lit, bool2int(fire_v3_off_led))

        -- last variables
        q_left_last_angle = q_left_angle
        q_right_last_angle = q_right_angle
        ff1_last_angle = ff1_actual_angle
        ff2_last_angle = ff2_actual_angle
    end

end
