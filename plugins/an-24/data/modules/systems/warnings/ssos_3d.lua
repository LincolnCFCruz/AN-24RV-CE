-- this is simple logic of SSOS
size = {2048, 2048}

-- sources
defineProperty("vvi", globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot"))
defineProperty("radioalt", globalProperty("an-24/gauges/radioalt"))
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_thro[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_thro[1]"))
defineProperty("gear1_deploy", globalProperty("sim/aircraft/parts/acf_gear_deploy[0]")) -- deploy of front gear
defineProperty("ssos_test", globalProperty("an-24/gauges/ssos_test_sw"))
defineProperty("auasp_warn", globalProperty("an-24/gauges/auasp_warning")) -- warning from AUASP
defineProperty("rv2_cc", globalProperty("an-24/gauges/rv_2_cc")) -- rv work
defineProperty("ssos_warning", globalProperty("an-24/gauges/ssos_warning")) -- warning from SSOS
defineProperty("ssos_power_lit", globalProperty("an-24/gauges/ssos_power_lit")) -- ssos power lamp
defineProperty("SSOS_alarm", globalProperty("an-24/gauges/SSOS_alarm")) -- alarm for MSRP
-- time
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- sim time
-- power
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))
defineProperty("ssos_cc", globalProperty("an-24/gauges/ssos_cc"))
defineProperty("ssos_sw", globalProperty("an-24/gauges/ssos_sw"))
defineProperty("ssos_sw_cap", globalProperty("an-24/gauges/ssos_sw_cap"))
-- images
defineProperty("green_led", loadLED("green"))

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

local passed = 0
local alt_last = get(radioalt)
local test_start_time = get(flight_time)
local test_started = false
local lamp_last_time = get(flight_time)
local LAMP_PERIOD = 0.18
local lamp_vis = false
local power = false
local alarm = false

set(ssos_sw, 1)

function update()
    local sim_time = get(flight_time)
    passed = get(frame_time)

    local alt = get(radioalt)
    if passed > 0 then

        -- power calculations
        power = acOK() and get(ssos_sw) == 1 and get(rv2_cc) > 0
        if power then
            set(ssos_cc, 2)
            set(ssos_power_lit, 1)
        else
            set(ssos_cc, 0)
            set(ssos_power_lit, 0)
        end

        -- local sources
        local vv = get(vvi) * 0.00508
        local radiovv = (alt - alt_last) / passed
        local gear_1 = get(gear1_deploy)
        -- print(radiovv)
        -- test
        local test = get(ssos_test)
        -- save test start time and mark test is runing
        if test ~= 0 and not test_started then
            test_started = true
            test_start_time = sim_time
        elseif test == 0 then
            test_started = false
        end
        -- test
        if test_started and (sim_time - test_start_time > 4 and test == 1) then
            vv = -20
            alt = 100
        elseif test_started and (sim_time - test_start_time > 8 and test == 2) then
            radiovv = -30
            alt = 100
        elseif test_started and (sim_time - test_start_time > 12 and test == 3) then
            gear_1 = 1
            alt = 100
        end

        -- baro vertical speed
        local baroalarm = alt > 50 and alt < 600 and vv < -(alt + 382.5) / 66.6
        -- if baroalarm then print("baro", alt, vv, -(alt + 382.5) / 66.6) end -- test

        -- radio vertical speed
        local radioalarm = alt > 50 and alt < 400 and radiovv < -(alt + 30.64) / 15.38
        -- if radioalarm then print("radio", alt, radiovv, -(alt + 30.64) / 15.38) end  -- test

        -- takeoff alarm
        local throttle = (get(N1) + get(N2)) / 2
        local toalarm = alt > 50 and alt < 250 and radiovv < -1.6 and throttle > 0.76 and gear_1 == 1
        -- if toalarm then print("take-off", alt, radiovv, throttle, gear_1) end  -- test

        -- landing alarm
        local lanalarm = alt > 50 and alt < 250 and gear_1 < 1 and radiovv < 0
        -- if lanalarm then print("landing", alt, gear_1, radiovv) end  -- test

        -- overall alarm
        alarm = (baroalarm or radioalarm or toalarm or lanalarm) and power

        -- if alarm then print(baroalarm, radioalarm, toalarm, lanalarm) end

        if alarm then
            set(SSOS_alarm, 1)
        else
            set(SSOS_alarm, 0)
        end

        -- lamp blinking
        if alarm and get(auasp_warn) < 1 then
            if sim_time - lamp_last_time > LAMP_PERIOD then
                lamp_last_time = sim_time
                lamp_vis = not lamp_vis
            end
        else
            lamp_vis = false
            lamp_last_time = sim_time
        end

        if lamp_vis then
            set(ssos_warning, 1)
        else
            set(ssos_warning, 0)
        end

    end
    -- last variables
    alt_last = alt
end

components = { 
    -- power led
    textureLit {
        position = {681, 427, 18, 18},
        image = get(green_led),
        visible = function()
            return power
        end
    }, 
    
    -- warning lamp
    textureLit {
        position = {1170, 516, 50, 30},
        image = langImage("lamps", 100, 68, 50, 30),
        visible = function()
            return lamp_vis
        end
    }, 
    
    -- ssos switch cap (closing the cap arms the SSOS switch)
    toggleSwitch {
        position = {132, 490, 35, 44},
        drf = ssos_sw_cap,
        sound = cap_sound,
        onToggle = function(nv)
            if nv == 0 then
                set(ssos_sw, 1)
            end
        end
    }, 
    
    -- ssos switch (only acts while its cap is open)
    toggleSwitch {
        position = {899, 345, 17, 17},
        drf = ssos_sw,
        sound = switch_sound,
        guard = function()
            return get(ssos_sw_cap) == 1
        end
    }, 
    
    -- test switcher (momentary: up=1, left=2, right=3)
    momentaryButton {
        position = {805, 373, 15, 7},
        drf = ssos_test,
        onValue = 1,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {805, 364, 7, 7},
        drf = ssos_test,
        onValue = 2,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {813, 364, 7, 7},
        drf = ssos_test,
        onValue = 3,
        sound = switch_sound,
        soundUp = switch_sound
    }
}
