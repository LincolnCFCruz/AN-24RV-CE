-- this is logic of whole autopilot AP28 for An24.
-- property table
-- environment
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- sim time
defineProperty("msl_alt", globalProperty("sim/flightmodel/position/elevation")) -- barometric alt. maybe in feet, maybe in meters.

-- XP12: sim/weather/barometer_sealevel_inhg is marked REPLACED.
-- Using new sim/weather/aircraft/barometer_current_pas (pascals, current pressure)
-- and converting to QNH (sea-level pressure, in inches of mercury).
--
-- Formula: P_sea_level = P_current * exp(altitude_m / 8400)
--   where 8400 m is the troposphere height scale (standard ISA atmosphere)
-- Then convert Pa to inHg: multiply by 0.000295300
--
-- The old dataref returned QNH directly in inHg. The new one gives pressure at altitude in Pa.
-- This function get_baro_press_inhg() returns the same value the old baro_press used to provide.
defineProperty("baro_press_pa", globalProperty("sim/weather/aircraft/barometer_current_pas"))
defineProperty("elevation_m", globalProperty("sim/flightmodel/position/elevation")) -- altitude in meters MSL

-- Wrapper function: returns QNH (sea-level pressure) in inHg, same as before.
local function get_baro_press()
    local current_pa = get(baro_press_pa)
    local alt_m = get(elevation_m)
    -- Reduce to sea level via barometric formula
    local sea_level_pa = current_pa * math.exp(alt_m / 8400)
    -- Pa to inHg
    return sea_level_pa * 0.000295300
end

-- sources
defineProperty("trim", globalProperty("sim/cockpit2/controls/elevator_trim"))
defineProperty("indicated_roll", globalProperty("an-24/ap/indicated_roll")) -- roll from AHZ
defineProperty("indicated_pitch", globalProperty("an-24/ap/indicated_pitch")) -- pitch from AHZ
defineProperty("curse_gik", globalProperty("an-24/ap/curse_gik")) -- course diff from GIK gauge
defineProperty("curse_gpk", globalProperty("an-24/ap/curse_gpk")) -- course diff from GPK gauge
defineProperty("curse_zk", globalProperty("an-24/ap/curse_zk")) -- course diff from ZK2 gauge

-- XP12: GPS navigation. Data updated by gps_nav.lua module.
-- ap_curse_stab == 3 activates GPS route-following mode.
defineProperty("curse_gps", globalProperty("an-24/ap/curse_gps")) -- course from GPS (same format as curse_gpk)
defineProperty("gps_valid", globalProperty("an-24/ap/gps_valid")) -- whether GPS is valid
-- Additional flag: if 1, GPS mode is active REGARDLESS of the physical selector position.
-- This allows enabling GPS following with a single button without moving the physical selector.
defineProperty("gps_mode_on", globalProperty("an-24/ap/gps_mode_on"))
defineProperty("bus_AC_36_volt", globalProperty("an-24/power/bus_AC_36_volt"))
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))
defineProperty("altitude", globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_pilot"))
defineProperty("vvi", globalProperty("sim/flightmodel/position/vh_ind_fpm"))
defineProperty("slip", globalProperty("sim/cockpit2/gauges/indicators/slip_deg"))
defineProperty("pitch_force", globalProperty("an-24/ap/ap_pitch_comm"))
defineProperty("ap_power_cc", globalProperty("an-24/ap/ap_power_cc"))
defineProperty("sim_ap_mode", globalProperty("sim/cockpit/autopilot/autopilot_mode"))

-- switchers
defineProperty("ap_power", globalProperty("an-24/ap/ap_power")) -- power of AP
defineProperty("ap_trim", globalProperty("an-24/ap/ap_trim")) -- use trimmer of AP
defineProperty("ap_ON", globalProperty("an-24/ap/ap_ON")) -- main button for engage AP
defineProperty("ap_kv", globalProperty("an-24/ap/ap_kv")) -- button for altitude hold
defineProperty("ap_horizont", globalProperty("an-24/ap/ap_horizont")) -- button to set horizontal position of plane
defineProperty("ap_curse_stab", globalProperty("an-24/ap/ap_curse_stab")) -- switcher for course stab. turn/GPK/GIK
defineProperty("ap_pitch", globalProperty("an-24/ap/ap_pitch")) -- pitch control UP and DOWN
defineProperty("ap_pitch_sw", globalProperty("an-24/ap/ap_pitch_sw")) -- engage pitch control
defineProperty("ap_roll", globalProperty("an-24/ap/ap_roll")) -- roll knob

-- lights
defineProperty("ap_ready_lit", globalProperty("an-24/ap/ap_ready_lit")) -- ready light
defineProperty("ap_on_lit", globalProperty("an-24/ap/ap_on_lit")) -- AP engaged light
defineProperty("ap_kv_lit", globalProperty("an-24/ap/ap_kv_lit")) -- alt stab engaged
defineProperty("ap_up_lit", globalProperty("an-24/ap/ap_up_lit")) -- AP feels UP force on stab
defineProperty("ap_down_lit", globalProperty("an-24/ap/ap_down_lit")) -- AP feels DOWN force on stab
defineProperty("ap_ail_fail_lit", globalProperty("an-24/ap/ap_ail_fail_lit")) -- aileron trim failed lamp
defineProperty("ap_elev_fail_lit", globalProperty("an-24/ap/ap_elev_fail_lit")) -- elevator trim failed lamp

-- controls
defineProperty("ap_roll_diff", globalProperty("an-24/ap/ap_roll_diff")) -- difference between needed and current roll (bank)
defineProperty("ap_pitch_diff", globalProperty("an-24/ap/ap_pitch_diff")) -- difference between needed and current pitch
defineProperty("ap_hdg_diff", globalProperty("an-24/ap/ap_hdg_diff")) -- difference between needed and current heading
defineProperty("ap_roll_power", globalProperty("an-24/ap/ap_roll_power")) -- power for aileron mechanic
defineProperty("ap_pitch_power", globalProperty("an-24/ap/ap_pitch_power")) -- power for elevator mechanic
defineProperty("ap_hdg_power", globalProperty("an-24/ap/ap_hdg_power")) -- power for rudder mechanic
defineProperty("yaw_spd", globalProperty("an-24/ap/ap_yaw_spd")) -- current yaw speed deg/sec

defineProperty("ap_mech_off", globalProperty("an-24/ap/ap_mech_off")) -- ap mechanic off. 0 = mechanics works, 1 = mech off
defineProperty("ap_mech_off_cap", globalProperty("an-24/ap/ap_mech_off_cap")) -- ap mechanic off cap

-- failures
defineProperty("ail_fail", globalProperty("sim/operation/failures/rel_trim_ail")) -- aileron trim fail
defineProperty("elev_fail", globalProperty("sim/operation/failures/rel_trim_elv")) -- elevator trim fail

defineProperty("ail_servo", globalProperty("sim/operation/failures/rel_servo_ailn")) -- aileron servo fail
defineProperty("elev_servo", globalProperty("sim/operation/failures/rel_servo_elev")) -- elevator servo fail
defineProperty("rudd_serv", globalProperty("sim/operation/failures/rel_servo_rudd")) -- rudder servo fail
defineProperty("thro_serv", globalProperty("sim/operation/failures/rel_servo_thro")) -- throttle fail
defineProperty("PF_ApbuttonState", globalProperty("an-24/autopilot_state_PF_ApbuttonState"))
defineProperty("FO_ApbuttonState", globalProperty("an-24/autopilot_state_FO_ApbuttonState"))
local autopilot_off_onn_Sound = loadSample('sounds/alert/autopilot_disco.wav')
defineProperty("isalerton", globalProperty("an-24/isalerton"))
-- cold-start init (moved from ap28_panel.lua): force AP master switches off on a cold load
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
local cold_time_counter = 0
local cold_not_loaded = true

-- global variables
local passed = 0
local pitch_vvi = 0 -- global variable for stabilising plane in horizontal flight
local ap_state = 1 -- autopilot status. 0 - off, 1 - ready, 2 - work
local last_ap_state = 0
local ap_last_state = 0
local ap_timer_start = get(flight_time)
local ap_alt_mode = 0
local ap_roll_mode = 0
-- alt modes are:
-- 0 - using manual pitch, manual bank and course stab depending on selected source
-- 1 - horizont
-- 2 - KV - altitude hold

-- roll modes are
-- 0 - turns from knob or compass
-- 1 - horizont
-- 2 - turns from ZK
local auto_kv = false -- kv mode auto switched after horizont mode
local curse = 0

-- logic of AP channels
local autopilot_pitch = get(indicated_pitch)
local autopilot_roll = get(indicated_roll)
local msl = get(msl_alt) * 3.28083 -- MSL alt in feet
local real_alt = msl + (29.92 - get_baro_press()) * 1000 -- calculate barometric altitude in feet (XP12: via recalculation)
local baro_alt = real_alt * 0.3048 -- altitude in meters
local hold_alt = baro_alt

local ap_pitch_need = autopilot_pitch
local ap_roll_need = autopilot_roll
local ap_hdg_need = 0

local last_stab = get(ap_curse_stab)
local hdg_diff = 0
local hdg_diff_need = 0
local pitch_diff = 0
--local pitch_diff_need = 0
local roll_diff = 0
--local roll_diff_need = 0

local last_pitch_mode = ap_alt_mode
local last_roll_mode = ap_roll_mode
local curse_sat = false
local gpk_curse_last = 0
local gik_curse_last = 0

-- commands

-- turn off AP
ap_off_command = findCommand("sim/autopilot/fdir_servos_down_one")
function ap_off_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase and ap_state == 2 then
        ap_state = 1
        set(PF_ApbuttonState, 0)
        set(FO_ApbuttonState, 0)
        set(isalerton, 1)
        sasl.al.playSample(autopilot_off_onn_Sound, false)
    end
    return 0
end
registerCommandHandler(ap_off_command, 0, ap_off_handler)

-- turn ON AP
ap_on_command = findCommand("sim/autopilot/fdir_servos_up_one")
function ap_on_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 1 == phase then
        set(ap_ON, 1)
    else
        set(ap_ON, 0)
    end
    return 0
end
registerCommandHandler(ap_on_command, 0, ap_on_handler)

-- hold AP
ap_hold_command = findCommand("sim/autopilot/servos_on")
local ap_hold = false
function ap_hold_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 1 == phase and (ap_state == 2 or ap_hold) then
        ap_state = 1
        ap_hold = true
    elseif ap_hold then
        ap_state = 2
        ap_hold = false
    else
        ap_hold = false
    end
    return 0
end
registerCommandHandler(ap_hold_command, 0, ap_hold_handler)

-- left bank
ap_left_command = findCommand("sim/autopilot/override_left")
function ap_left_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        local a = get(ap_roll) - 5
        if a < -25 then
            a = -25
        end
        set(ap_roll, a)
    end
    return 0
end
registerCommandHandler(ap_left_command, 0, ap_left_handler)

-- right bank
ap_right_command = findCommand("sim/autopilot/override_right")
function ap_right_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        local a = get(ap_roll) + 5
        if a > 25 then
            a = 25
        end
        set(ap_roll, a)
    end
    return 0
end
registerCommandHandler(ap_right_command, 0, ap_right_handler)

-- pitch UP
ap_UP_command = findCommand("sim/autopilot/override_up")
function ap_UP_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 1 == phase then
        set(ap_pitch, 1)
    else
        set(ap_pitch, 0)
    end
    return 0
end
registerCommandHandler(ap_UP_command, 0, ap_UP_handler)

-- pitch DOWN
ap_DOWN_command = findCommand("sim/autopilot/override_down")
function ap_DOWN_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 1 == phase then
        set(ap_pitch, -1)
    else
        set(ap_pitch, 0)
    end
    return 0
end
registerCommandHandler(ap_DOWN_command, 0, ap_DOWN_handler)

-- KV mode
ap_KV_command = findCommand("sim/autopilot/altitude_hold")
function ap_KV_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 1 == phase then
        set(ap_kv, 1)
    else
        set(ap_kv, 0)
    end
    return 0
end
registerCommandHandler(ap_KV_command, 0, ap_KV_handler)

-- horizon mode
ap_HOR_command = findCommand("sim/autopilot/wing_leveler")
function ap_HOR_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 1 == phase then
        set(ap_horizont, 1)
    else
        set(ap_horizont, 0)
    end
    return 0
end
registerCommandHandler(ap_HOR_command, 0, ap_HOR_handler)

-- AP power switcher
ap_power_command = findCommand("sim/autopilot/fdir_on")
function ap_power_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        set(ap_power, math.abs(get(ap_power) - 1))
    end
    return 0
end
registerCommandHandler(ap_power_command, 0, ap_power_handler)

-- AP trim switcher
ap_trim_command = findCommand("sim/autopilot/servos_toggle")
function ap_trim_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        set(ap_trim, math.abs(get(ap_trim) - 1))
    end
    return 0
end
registerCommandHandler(ap_trim_command, 0, ap_trim_handler)

-- AP pitch switcher
ap_pitch_command = findCommand("sim/autopilot/pitch_sync")
function ap_pitch_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        set(ap_pitch_sw, math.abs(get(ap_pitch_sw) - 1))
    end
    return 0
end
registerCommandHandler(ap_pitch_command, 0, ap_pitch_handler)

-- AP course select UP
ap_course_UP_command = findCommand("sim/autopilot/airspeed_up")
function ap_course_UP_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        local a = get(ap_curse_stab) + 1
        if a > 3 then
            a = 3
        end -- XP12: added mode 3 (GPS)
        set(ap_curse_stab, a)
    end
    return 0
end
registerCommandHandler(ap_course_UP_command, 0, ap_course_UP_handler)

-- AP course select DOWN
ap_course_DOWN_command = findCommand("sim/autopilot/airspeed_down")
function ap_course_DOWN_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        local a = get(ap_curse_stab) - 1
        if a < 0 then
            a = 0
        end
        set(ap_curse_stab, a)
    end
    return 0
end
registerCommandHandler(ap_course_DOWN_command, 0, ap_course_DOWN_handler)

-- XP12: create our own SASL command for toggling GPS mode.
-- Assign it to a convenient key/button in X-Plane settings:
--   Settings -> Keyboard -> find "An-24: Toggle GPS NAV mode"
-- When GPS is active, the cockpit lamp (if present) will light up, and the AP will follow the route.
local gps_mode_command = createCommand("An-24/AP/gps_mode_toggle", "An-24: Toggle GPS NAV mode")
function gps_mode_handler(phase)
    if 0 == phase then
        set(gps_mode_on, math.abs(get(gps_mode_on) - 1))
    end
    return 0
end
registerCommandHandler(gps_mode_command, 0, gps_mode_handler)

-----------------

-- function for calculating roll, depending on course difference between needed and actual course
function calc_roll(curse_delta, norm_delta, max_roll)
    -- normalise delta. on delta bigger than norm_delta - bank will be maximal = max_roll
    local delta = curse_delta / norm_delta
    if delta > 1 then
        delta = 1
    elseif delta < -1 then
        delta = -1
    end

    -- return result
    return max_roll * delta
end

local alt_diff_last = 0
local pitch_step = 0.2
local pitch_need = get(indicated_pitch)
-- function for calculating pitch to maintain altitude
function calc_pitch(alt_diff, pitch_limit)

    local spd_coef = math.min(1, math.abs(alt_diff / 100)) * 5
    -- calculate approach movement to given track
    if math.abs(alt_diff) - math.abs(alt_diff_last) > 0 and alt_diff > 25 then -- climbing from hold_alt. above
        pitch_need = pitch_need - pitch_step * 2 * passed
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) < 0 and alt_diff > 25 then -- descending to hold_alt. above
        if passed > 0 then
            if (alt_diff - alt_diff_last) / passed > -spd_coef then
                pitch_need = pitch_need - pitch_step * 1 * passed
            elseif (alt_diff - alt_diff_last) / passed < -spd_coef then
                pitch_need = pitch_need + pitch_step * 1 * passed
            end
        end
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) > 0 and alt_diff < -25 then -- descending from hold_alt. below
        pitch_need = pitch_need + pitch_step * 2 * passed
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) < 0 and alt_diff < -25 then -- climbing to hold_alt. below
        if passed > 0 then
            if (alt_diff - alt_diff_last) / passed < spd_coef then
                pitch_need = pitch_need + pitch_step * 1 * passed
            elseif (alt_diff - alt_diff_last) / passed > spd_coef then
                pitch_need = pitch_need - pitch_step * 1 * passed
            end
        end
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) > 0 and alt_diff > 10 then -- climbing from hold_alt. above
        pitch_need = pitch_need - pitch_step * 1 * passed
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) < 0 and alt_diff > 10 then -- descending to hold_alt. above
        if passed > 0 then
            if (alt_diff - alt_diff_last) / passed > -spd_coef then
                pitch_need = pitch_need - pitch_step * 0.5 * passed
            elseif (alt_diff - alt_diff_last) / passed < -spd_coef then
                pitch_need = pitch_need + pitch_step * 0.5 * passed
            end
        end
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) > 0 and alt_diff < -10 then -- descending from hold_alt. below
        pitch_need = pitch_need + pitch_step * 1 * passed
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) < 0 and alt_diff < -10 then -- climbing to hold_alt. below
        if passed > 0 then
            if (alt_diff - alt_diff_last) / passed < spd_coef then
                pitch_need = pitch_need + pitch_step * 0.5 * passed
            elseif (alt_diff - alt_diff_last) / passed > spd_coef then
                pitch_need = pitch_need - pitch_step * 0.5 * passed
            end
        end
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) > 0 and alt_diff > 0 then -- climbing from hold_alt. above
        pitch_need = pitch_need - pitch_step * 0.2 * passed
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) < 0 and alt_diff > 0 then -- descending to hold_alt. above
        if passed > 0 then
            if (alt_diff - alt_diff_last) / passed > -spd_coef then
                pitch_need = pitch_need - pitch_step * 0.1 * passed
            elseif (alt_diff - alt_diff_last) / passed < -spd_coef then
                pitch_need = pitch_need + pitch_step * 0.1 * passed
            end
        end
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) > 0 and alt_diff < 0 then -- descending from hold_alt. below
        pitch_need = pitch_need + pitch_step * 0.2 * passed
    elseif math.abs(alt_diff) - math.abs(alt_diff_last) < 0 and alt_diff < 0 then -- climbing to hold_alt. below
        if passed > 0 then
            if (alt_diff - alt_diff_last) / passed < spd_coef then
                pitch_need = pitch_need + pitch_step * 0.1 * passed
            elseif (alt_diff - alt_diff_last) / passed > spd_coef then
                pitch_need = pitch_need - pitch_step * 0.1 * passed
            end
        end
    else
        -- pitch_need = (get(res_pitch_1) + get(res_pitch_2)) * 0.5 -- think about some fix for stable pitch
    end

    alt_diff_last = alt_diff

    return pitch_need

end

-- function to select autopilot power status, depending on power, switchers and start time
function autopilot_state()
    -- set default AP fail
    set(ail_servo, 6)
    set(elev_servo, 6)
    set(rudd_serv, 6)
    set(thro_serv, 6)

    -- calculate power
    local autopilot_power = ac36OK() and acOK() and get(ap_power) == 1
    -- set timer for AP to get ready
    local sim_time = get(flight_time)
    if autopilot_power then
        -- set ready status
        if ap_state == 0 and sim_time - ap_timer_start > 10 then -- AP is ready after 10 sec
            ap_state = 1
        elseif ap_state == 1 and get(ap_ON) == 1 then -- AP engaged
            ap_state = 2
        end
    else
        ap_state = 0
        ap_timer_start = sim_time
    end
    if ap_state > 0 then
        set(ap_power_cc, 5)
    else
        set(ap_power_cc, 0)
    end

    return true
end

-- function for automatic selection of modes
function autopilot_mode()

    if ap_state == 1 and get(ap_horizont) == 1 then -- horizon mode when AP not connected
        ap_alt_mode = 1
        ap_roll_mode = 1
    elseif ap_state == 1 and math.abs(get(indicated_roll)) < 1 and math.abs(get(indicated_pitch)) < 5 and
        math.abs(get(vvi) * 0.00508) < 0.5 then -- out of horizon mode
        ap_alt_mode = 0
        ap_roll_mode = 0
    elseif ap_state == 2 then
        -- logic of pitch mode
        if ap_alt_mode == 1 and math.abs(get(indicated_roll)) < 1 and math.abs(get(indicated_pitch)) < 5 and
            math.abs(get(vvi) * 0.00508) < 0.5 then -- automatic switch to KV mode
            auto_kv = true
            ap_alt_mode = 2
        elseif ap_alt_mode ~= 2 and get(ap_kv) == 1 then -- manual switch to KV mode
            ap_alt_mode = 2
            auto_kv = false
        elseif ap_alt_mode ~= 1 and get(ap_horizont) == 1 then -- switch to horizon mode
            ap_alt_mode = 1
        elseif get(ap_ON) == 1 or get(ap_pitch_sw) == 0 or (not auto_kv and get(ap_pitch) ~= 0 and ap_alt_mode == 2) then -- switch to manual mode
            ap_alt_mode = 0
            auto_kv = false
        end

        -- logic of roll mode
        if get(ap_horizont) == 1 then
            ap_roll_mode = 1
        elseif get(ap_curse_stab) == 0 and ap_alt_mode ~= 1 and math.abs(get(curse_zk)) < 120 then
            ap_roll_mode = 2
        elseif get(ap_curse_stab) ~= 0 and ap_alt_mode ~= 1 then
            ap_roll_mode = 0
        end
    elseif ap_state == 0 then
        ap_alt_mode = 0
        ap_roll_mode = 0
    end

end

-- logic of mechanics power
function mech_power()
    if (ap_state == 1 and ap_alt_mode == 1) or ap_state == 2 then
        set(ap_roll_power, (1 - get(ap_ail_fail_lit)) * (1 - get(ap_mech_off)))
        set(ap_pitch_power, get(ap_pitch_sw) * (1 - get(ap_elev_fail_lit)) * (1 - get(ap_mech_off)))
        set(ap_hdg_power, (1 - get(ap_mech_off)))
    else
        set(ap_roll_power, 0)
        set(ap_pitch_power, 0)
        set(ap_hdg_power, 0)
    end
end

-- logic of mechanics
function mech_logic()
    -- calculate altitude to hold
    msl = get(msl_alt) * 3.28083 -- MSL alt in feet
    real_alt = msl + (29.92 - get_baro_press()) * 1000 -- calculate barometric altitude in feet (XP12: via recalculation)

    baro_alt = real_alt * 0.3048 -- altitude in meters

    -- pitch logic
    if ap_state < 2 and ap_alt_mode ~= 1 then
        autopilot_pitch = get(indicated_pitch)
    end -- set new pitch to hold
    if last_pitch_mode ~= ap_alt_mode or ap_state ~= ap_last_state then
        last_pitch_mode = ap_alt_mode
        ap_last_state = ap_state
        if ap_alt_mode == 0 then
            autopilot_pitch = get(indicated_pitch) -- set new pitch to hold
        elseif ap_alt_mode == 1 then
            autopilot_pitch = 0
        elseif ap_alt_mode == 2 then
            hold_alt = baro_alt -- set new alt to hold
        end
    end

    if ap_alt_mode ~= 2 then -- save some variables, while they are not used as parameters
        pitch_need = get(indicated_pitch)
        hold_alt = baro_alt
    end

    -- pitch modes
    local KV_pitch = calc_pitch(baro_alt - hold_alt, 10) -- initialisation of function variables due to actual flight situation
    if get(ap_pitch_sw) == 1 then
        if ap_alt_mode == 0 then
            autopilot_pitch = autopilot_pitch + get(ap_pitch) * passed * 1
        elseif ap_alt_mode == 1 then
            autopilot_pitch = 0
        elseif ap_alt_mode == 2 then
            autopilot_pitch = KV_pitch
        end
    end

    if autopilot_pitch > 20 then
        autopilot_pitch = 20
    elseif autopilot_pitch < -20 then
        autopilot_pitch = -20
    end

    -- smooth movement of needed pitch
    if autopilot_pitch > ap_pitch_need + 0.1 then
        ap_pitch_need = ap_pitch_need + 5 * passed
    elseif autopilot_pitch < ap_pitch_need - 0.1 then
        ap_pitch_need = ap_pitch_need - 5 * passed
    end

    -- calculate pitch difference for mechanic
    pitch_diff = ap_pitch_need - get(indicated_pitch)

    set(ap_pitch_diff, pitch_diff)

    -- roll logic
    -- XP12 GPS: check GPS mode early (needed for bank logic)
    local gps_active_roll = (get(gps_mode_on) == 1 and get(gps_valid) == 1)

    if gps_active_roll then
        -- In GPS mode, bank is proportional to deviation from GPS course (like turn mode).
        -- calc_roll(delta, norm, max_bank): when delta >= norm, bank = max.
        -- Use GPS course (difference between needed and current), bank to turn toward waypoint.
        local gps_c = get(curse_gps)
        if gps_c > 180 then
            gps_c = gps_c - 360
        elseif gps_c < -180 then
            gps_c = gps_c + 360
        end
        autopilot_roll = calc_roll(gps_c, 20, 22) -- norm 20 deg, max bank 22 deg
    elseif ap_roll_mode == 1 then
        autopilot_roll = 0 -- horizon mode
    elseif ap_roll_mode == 2 then
        autopilot_roll = calc_roll(-get(curse_zk), 15, 15) -- turns mode
    else
        autopilot_roll = get(ap_roll) -- manual roll mode
    end

    -- smooth movement of roll
    if autopilot_roll > ap_roll_need + 0.1 then
        ap_roll_need = ap_roll_need + 5 * passed
    elseif autopilot_roll < ap_roll_need - 0.1 then
        ap_roll_need = ap_roll_need - 5 * passed
    end

    -- calculate roll difference for mechanic
    roll_diff = ap_roll_need - get(indicated_roll)

    set(ap_roll_diff, roll_diff)

    -- heading logic
    local stab = get(ap_curse_stab)
    -- XP12: check whether GPS mode is active. If so, the pilot is allowed more "help" from the controls,
    -- and the course is not "forgotten" during banks up to 10 deg (GPS constantly recalculates course to waypoint).
    local gps_active = (get(gps_mode_on) == 1 and get(gps_valid) == 1)
    local forget_threshold = 3 -- standard "forget course" threshold
    local pilot_assist_threshold = 1 -- standard threshold for disabling course stabilisation
    if gps_active then
        forget_threshold = 10 -- in GPS mode the threshold is higher (pilot can correct)
        pilot_assist_threshold = 10 -- in GPS mode can bank up to 10 deg manually
    end

    -- set new course after manoeuvres
    if math.abs(autopilot_roll) > forget_threshold or stab ~= last_stab or ap_state ~= last_ap_state or get(ap_ON) == 1 then
        curse_sat = false
    end
    last_stab = stab
    last_ap_state = ap_state

    if math.abs(get(indicated_roll)) < forget_threshold and not curse_sat then -- final course set
        if stab == 1 then
            curse = get(curse_gpk)
        elseif stab == 2 then
            curse = get(curse_gik)
            -- XP12 GPS: in GPS mode there is no need to "remember" current course — GPS provides the diff directly.
        end
        curse_sat = true
    end

    -- set needed hdg

    local gpk_curse = get(curse_gpk) - curse
    if gpk_curse > 180 then
        gpk_curse = gpk_curse - 360
    elseif gpk_curse < -180 then
        gpk_curse = gpk_curse + 360
    end

    local gik_curse = get(curse_gik) - curse
    if gik_curse > 180 then
        gik_curse = gik_curse - 360
    elseif gik_curse < -180 then
        gik_curse = gik_curse + 360
    end

    -- XP12 GPS: course from GPS already arrives as a ready difference (curse_gps).
    -- No recalculation from a "remembered" course point is needed.
    local gps_curse = get(curse_gps)
    if gps_curse > 180 then
        gps_curse = gps_curse - 360
    elseif gps_curse < -180 then
        gps_curse = gps_curse + 360
    end

    -- XP12 GPS-OVERRIDE: if gps_mode_on flag is set AND GPS is valid — GPS course takes priority,
    -- regardless of ap_curse_stab selector position. This simplifies enabling GPS navigation
    -- with a single button (e.g. via command an-24/cmd/gps_mode_toggle).
    -- The course stabilisation disable threshold in GPS mode is expanded to 10 deg (see pilot_assist_threshold).
    if gps_active and math.abs(autopilot_roll) <= pilot_assist_threshold then
        hdg_diff = gps_curse
    elseif math.abs(autopilot_roll) > 1 or stab == 0 then
        hdg_diff = get(slip)
    elseif stab == 1 then
        hdg_diff = gpk_curse
    elseif stab == 2 then
        hdg_diff = gik_curse
        -- XP12: mode 3 — GPS via selector (if it exists in the cockpit).
    elseif stab == 3 then
        if get(gps_valid) == 1 then
            hdg_diff = gps_curse
        else
            hdg_diff = gpk_curse
        end
    end

    -- smooth movement of hdg diff
    if ap_state < 2 then
        hdg_diff_need = 0
    end
    -- limit course
    if hdg_diff > 180 then
        hdg_diff = hdg_diff - 360
    elseif hdg_diff < -180 then
        hdg_diff = hdg_diff + 360
    end

    if hdg_diff_need < hdg_diff - 0.01 then
        hdg_diff_need = hdg_diff_need + 5 * passed
    elseif hdg_diff_need > hdg_diff + 0.01 then
        hdg_diff_need = hdg_diff_need - 5 * passed
    else
        hdg_diff_need = hdg_diff
    end
    if ap_state < 2 then
        hdg_diff_need = 0
    end

    set(ap_hdg_diff, hdg_diff_need)

    -- XP12 GPS: in GPS mode, turns are performed ONLY by bank (ailerons),
    -- the rudder does NOT participate (as requested). The An-24 is well
    -- coordinated aerodynamically — the fin's directional stability itself counteracts
    -- sideslip in turns. Zero the heading command for the rudder channel.
    if gps_active_roll then
        set(ap_hdg_diff, 0)
    end

    -- calculate current hdg speed
    local hdg_spd = 0
    if passed > 0 then
        -- XP12 GPS: in GPS mode the heading speed disable threshold is expanded to 10 deg (see pilot_assist_threshold)
        if gps_active and math.abs(autopilot_roll) <= pilot_assist_threshold then
            hdg_spd = -(get(curse_gpk) - gpk_curse_last) / passed -- speed via GPK — more stable
        elseif math.abs(autopilot_roll) > 1 or stab == 0 then
            hdg_spd = -get(slip)
        elseif stab == 1 then
            hdg_spd = -(get(curse_gpk) - gpk_curse_last) / passed
        elseif stab == 2 then
            hdg_spd = -(get(curse_gik) - gik_curse_last) / passed
            -- XP12 GPS: heading speed calculated via GPK (gives real angular rate of the aircraft,
            -- not GPS update jitter).
        elseif stab == 3 then
            hdg_spd = -(get(curse_gpk) - gpk_curse_last) / passed
        end
    end

    -- XP12 RUDDER FIX: the real AP-28 on the An-24 is a TWO-CHANNEL autopilot
    -- (pitch + bank). Course is held by BANK (ailerons), the rudder in flight
    -- is operated by the pilot with pedals — the autopilot does NOT touch the rudder.
    -- Therefore the yaw command from the AP is FULLY zeroed at source —
    -- the AP never moves the rudder (removes jitter and pedal sticking).
    -- hdg_spd above is still computed (used for bank/course logic),
    -- but is not passed to the rudder channel (yaw_spd).
    set(yaw_spd, 0)

    gpk_curse_last = get(curse_gpk)
    gik_curse_last = get(curse_gik)

end

-- function to set status lights
function set_lights()
    if ap_state == 1 then
        set(ap_ready_lit, 1)
    else
        set(ap_ready_lit, 0)
    end
    if ap_state == 2 then
        set(ap_on_lit, 1)
        if get(pitch_force) > 0.2 then
            set(ap_up_lit, 0)
            set(ap_down_lit, 1)
        elseif get(pitch_force) < -0.2 then
            set(ap_up_lit, 1)
            set(ap_down_lit, 0)
        else
            set(ap_up_lit, 0)
            set(ap_down_lit, 0)
        end
    else
        set(ap_on_lit, 0)
        set(ap_up_lit, 0)
        set(ap_down_lit, 0)
    end
    if ap_alt_mode == 2 and ap_state == 2 then
        set(ap_kv_lit, 1)
    else
        set(ap_kv_lit, 0)
    end

    if ap_state > 0 then
        if get(ail_fail) == 6 then
            set(ap_ail_fail_lit, 1)
        else
            set(ap_ail_fail_lit, 0)
        end
        if get(elev_fail) == 6 then
            set(ap_elev_fail_lit, 1)
        else
            set(ap_elev_fail_lit, 0)
        end
    else
        set(ap_ail_fail_lit, 0)
        set(ap_elev_fail_lit, 0)
    end

end

-- every frame calculations
function update()

    -- set default AP
    set(sim_ap_mode, 0)
    passed = get(frame_time)

    -- cold-start: zero AP master switches once in the 0.3..0.4 s window (engines off)
    cold_time_counter = cold_time_counter + passed
    if get(N1) < 70 and get(N2) < 70 and cold_time_counter > 0.3 and cold_time_counter < 0.4 and cold_not_loaded then
        set(ap_power, 0)
        set(ap_trim, 0)
        set(ap_pitch_sw, 0)
        cold_not_loaded = false
    end

    if passed > 0 then

        -- check AP power state
        autopilot_state()

        -- select AP mode
        autopilot_mode()

        -- set mechanics power
        mech_power()

        -- set mechanic commands
        mech_logic()

        -- lights
        set_lights()

    else
        passed = 0
    end
end
