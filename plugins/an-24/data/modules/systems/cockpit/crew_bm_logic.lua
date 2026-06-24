-- this is engineer's sounds
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("external_view", globalProperty("sim/graphics/view/view_is_external"))

-- gear
defineProperty("gear_valve", globalProperty("an-24/hydro/gear_valve")) -- position of gear valve for hydraulic calculations and animations.
defineProperty("gear1_deploy", globalProperty("sim/aircraft/parts/acf_gear_deploy[0]")) -- deploy of front gear
defineProperty("gear2_deploy", globalProperty("sim/aircraft/parts/acf_gear_deploy[1]")) -- deploy of right gear
defineProperty("gear3_deploy", globalProperty("sim/aircraft/parts/acf_gear_deploy[2]")) -- deploy of left gear

-- flaps
defineProperty("flap_deg1", globalProperty("sim/flightmodel2/wing/flap1_deg[0]")) -- left flap deg
defineProperty("flap_deg2", globalProperty("sim/flightmodel2/wing/flap1_deg[1]")) -- right flap deg

-- fire
defineProperty("siren_fire", globalProperty("an-24/fire/fire_warinig"))

-- ice
defineProperty("ice_on_plane", globalProperty("sim/cockpit2/annunciators/ice")) -- ice detected

-- propellers
defineProperty("prop_pitch_1", globalProperty("sim/cockpit2/engine/actuators/prop_pitch_deg[0]")) -- propeller pitch
defineProperty("prop_pitch_2", globalProperty("sim/cockpit2/engine/actuators/prop_pitch_deg[1]"))
defineProperty("pitch_stop_set", globalProperty("an-24/prop/pitch_stop_set")) -- set up pitch mid stop

-- engines
defineProperty("uprt1", globalProperty("an-24/misc/virt_rud1"))
defineProperty("uprt2", globalProperty("an-24/misc/virt_rud2"))
defineProperty("eng1_N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[0]")) -- engine 1 rpm
defineProperty("eng2_N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[1]")) -- engine 2 rpm

-- power
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))

-- SmartCopilot
defineProperty("ismaster", globalProperty("scp/api/ismaster")) -- 0 - not connected/slave not active, 1 - master, 2 - slave

-- define all sounds
local gear_up = loadSample('sounds/crew/bm_gear_up.wav')
local gear_down = loadSample('sounds/crew/bm_gear_down.wav')
local gear_neutral = loadSample('sounds/crew/bm_gear_neutr.wav')
local fire = loadSample('sounds/crew/bm_fire.wav')
local icing = loadSample('sounds/crew/bm_ice.wav')
local feather_L = loadSample('sounds/crew/bm_left_feather.wav')
local feather_R = loadSample('sounds/crew/bm_right_feather.wav')
local takeoff = loadSample('sounds/crew/bm_to_mode.wav')
local nominal = loadSample('sounds/crew/bm_nom_mode.wav')
local fly_idle = loadSample('sounds/crew/bm_fly_idle.wav')
local ground_idle = loadSample('sounds/crew/bm_idle_mode.wav')
local prop_lease = loadSample('sounds/crew/bm_prop_lease.wav')
local flaps_up = loadSample('sounds/crew/bm_flaps_up.wav')
local flaps_5 = loadSample('sounds/crew/bm_flaps_5.wav')
local flaps_10 = loadSample('sounds/crew/bm_flaps_10.wav')
local flaps_15 = loadSample('sounds/crew/bm_flaps_15.wav')
local flaps_30 = loadSample('sounds/crew/bm_flaps_30.wav')
local flaps_35 = loadSample('sounds/crew/bm_flaps_35.wav')

-- played marks
local gear_up_was = false --
local gear_down_was = true --
local gear_neutral_was = true --
local fire_was = false --
local icing_was = false --
local feather_L_was = false --
local feather_R_was = false --
local takeoff_was = false --
local nominal_was = false --
local fly_idle_was = true --
local ground_idle_was = true --
local prop_lease_was = true --
local flaps_up_was = true --
local flaps_5_was = false --
local flaps_10_was = false --
local flaps_15_was = false --
local flaps_30_was = false --
local flaps_35_was = false --

local speech_timer = 20 -- if this timer > 0 then there is some phrase playing and other phrases have to wait.

function update()
    local cpl_active = get(ismaster) == 1 or get(ismaster) == 2

    local passed = get(frame_time)
    local power = get(bus_DC_27_volt_emerg) > 20
    local flaps = (get(flap_deg1) + get(flap_deg2)) / 2
    local external = get(external_view) == 1

    speech_timer = speech_timer - passed
    if speech_timer < 0 then
        speech_timer = 0
    end

    if speech_timer == 0 and not external and not cpl_active then -- here goes speech logic

        -- gear callout
        if not gear_up_was and get(gear1_deploy) + get(gear2_deploy) + get(gear3_deploy) < 0.01 and get(gear_valve) ==
            -1 then
            sasl.al.playSample(gear_up, false)
            speech_timer = 1
            gear_up_was = true
            gear_down_was = false
            gear_neutral_was = false
        elseif not gear_down_was and get(gear1_deploy) + get(gear2_deploy) + get(gear3_deploy) > 0.99 and
            get(gear_valve) == 1 then
            sasl.al.playSample(gear_down, false)
            speech_timer = 1
            gear_up_was = false
            gear_down_was = true
            gear_neutral_was = false
        elseif not gear_neutral_was and get(gear_valve) == 0 then
            sasl.al.playSample(gear_neutral, false)
            speech_timer = 1
            gear_up_was = false
            gear_down_was = false
            gear_neutral_was = true
        end

        -- flaps callout
        if not flaps_up_was and flaps < 0.5 and speech_timer == 0 then
            sasl.al.playSample(flaps_up, false)
            speech_timer = 1
            flaps_up_was = true
        elseif not flaps_5_was and flaps < 5.2 and flaps > 4.7 and speech_timer == 0 then
            sasl.al.playSample(flaps_5, false)
            speech_timer = 1
            flaps_5_was = true
        elseif not flaps_10_was and flaps < 10 and flaps > 9.5 and speech_timer == 0 then
            sasl.al.playSample(flaps_10, false)
            speech_timer = 1
            flaps_10_was = true
        elseif not flaps_15_was and flaps < 15.5 and flaps > 14.5 and speech_timer == 0 then
            sasl.al.playSample(flaps_15, false)
            speech_timer = 1
            flaps_15_was = true
        elseif not flaps_30_was and flaps < 30 and flaps > 29.5 and speech_timer == 0 then
            sasl.al.playSample(flaps_30, false)
            speech_timer = 1
            flaps_30_was = true
        elseif not flaps_35_was and flaps > 34.5 and speech_timer == 0 then
            sasl.al.playSample(flaps_35, false)
            speech_timer = 1
            flaps_35_was = true
        end

        if (flaps > 3 and flaps < 4) or (flaps > 7 and flaps < 9) or (flaps > 11 and flaps < 14) or
            (flaps > 16 and flaps < 27) or (flaps > 32 and flaps < 34) and speech_timer == 0 then
            flaps_up_was = false
            flaps_5_was = false
            flaps_10_was = false
            flaps_15_was = false
            flaps_30_was = false
            flaps_35_was = false
        end

        -- fire
        if get(siren_fire) == 1 and not fire_was and speech_timer == 0 then
            sasl.al.playSample(fire, false)
            speech_timer = 1
            fire_was = true
        elseif get(siren_fire) == 0 and speech_timer == 0 then
            fire_was = false
        end

        -- ice
        if get(ice_on_plane) == 1 and not icing_was and speech_timer == 0 then
            sasl.al.playSample(icing, false)
            speech_timer = 1
            icing_was = true
        elseif get(ice_on_plane) == 0 and speech_timer == 0 then
            icing_was = false
        end

        -- prop feather
        if get(prop_pitch_1) > 60 and not feather_L_was and speech_timer == 0 then
            sasl.al.playSample(feather_L, false)
            speech_timer = 1
            feather_L_was = true
        elseif get(prop_pitch_1) < 50 and speech_timer == 0 then
            feather_L_was = false
        end

        if get(prop_pitch_2) > 60 and not feather_R_was and speech_timer == 0 then
            sasl.al.playSample(feather_R, false)
            speech_timer = 1
            feather_R_was = true
        elseif get(prop_pitch_2) < 50 then
            feather_R_was = false
        end

        -- prop release
        if get(pitch_stop_set) == 0 and not prop_lease_was and speech_timer == 0 then
            sasl.al.playSample(prop_lease, false)
            speech_timer = 1
            prop_lease_was = true
        elseif get(pitch_stop_set) == 1 and speech_timer == 0 then
            prop_lease_was = false
        end

        -- engine modes
        if get(eng1_N1) > 80 and get(eng2_N1) > 80 and speech_timer == 0 then
            local uprt = (get(uprt1) + get(uprt2)) * 0.5
            if not takeoff_was and uprt > 0.9 then
                sasl.al.playSample(takeoff, false)
                speech_timer = 1
                takeoff_was = true
                nominal_was = false
                fly_idle_was = false
                ground_idle_was = false
            elseif not nominal_was and uprt > 0.55 and uprt < 0.7 then
                sasl.al.playSample(nominal, false)
                speech_timer = 1
                takeoff_was = false
                nominal_was = true
                fly_idle_was = false
                ground_idle_was = false
            elseif not fly_idle_was and uprt > 0.10 and uprt < 0.2 then
                sasl.al.playSample(fly_idle, false)
                speech_timer = 1
                takeoff_was = false
                nominal_was = false
                fly_idle_was = true
                ground_idle_was = false
            elseif not ground_idle_was and uprt < 0.05 then
                sasl.al.playSample(ground_idle, false)
                speech_timer = 1
                takeoff_was = false
                nominal_was = true
                fly_idle_was = true
                ground_idle_was = true
            end
        end
    end
end
