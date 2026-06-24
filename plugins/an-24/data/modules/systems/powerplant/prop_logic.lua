-- simple logic of propellers, including autofeather and beta range (render half: prop_3d.lua)
-- source
defineProperty("prop_pitch_1", globalProperty("sim/cockpit2/engine/actuators/prop_pitch_deg[0]")) -- propeller pitch
defineProperty("prop_pitch_2", globalProperty("sim/cockpit2/engine/actuators/prop_pitch_deg[1]"))

defineProperty("prop1_rpm_rads", globalProperty("sim/flightmodel2/engines/prop_rotation_speed_rad_sec[0]")) -- prop rotation rad/sec
defineProperty("prop2_rpm_rads", globalProperty("sim/flightmodel2/engines/prop_rotation_speed_rad_sec[1]"))

defineProperty("uprt1", globalProperty("an-24/misc/virt_rud1"))
defineProperty("uprt2", globalProperty("an-24/misc/virt_rud2"))

defineProperty("torq1", globalProperty("sim/cockpit2/engine/indicators/torque_n_mtr[0]")) -- take-off pressure must be 92, it's equals 1312 NM
defineProperty("torq2", globalProperty("sim/cockpit2/engine/indicators/torque_n_mtr[1]"))

defineProperty("fail1", globalProperty("sim/operation/failures/rel_engfai0"))
defineProperty("fail2", globalProperty("sim/operation/failures/rel_engfai1"))

defineProperty("apd_work_lit", globalProperty("an-24/start/apd_work_lit")) -- lamp for apd

-- controls
defineProperty("pitch_stop", globalProperty("an-24/prop/pitch_stop")) -- set up pitch mid stop
defineProperty("feather1_test1", globalProperty("an-24/prop/feather1_test1")) -- left prop feather test by IKM
defineProperty("feather2_test1", globalProperty("an-24/prop/feather2_test1")) -- right prop feather test by IKM
defineProperty("feather1_test2", globalProperty("an-24/prop/feather1_test2")) -- left prop feather test by reverse
defineProperty("feather2_test2", globalProperty("an-24/prop/feather2_test2")) -- right prop feather test by reverse
defineProperty("feather1_button", globalProperty("an-24/prop/feather1_button")) -- left prop feather button
defineProperty("feather2_button", globalProperty("an-24/prop/feather2_button")) -- right prop feather button

defineProperty("feather_test_cap", globalProperty("an-24/prop/feather_test_cap")) -- left prop feather test by IKM
defineProperty("pitch_stop_cap", globalProperty("an-24/prop/pitch_stop_cap"))
defineProperty("pitch_stop_set", globalProperty("an-24/prop/pitch_stop_set")) -- set up pitch mid stop

-- power
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))

-- time
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- sim time

-- switch prop stop
set_stop_command = findCommand("sim/engines/thrust_reverse_toggle")
function set_stop_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        if get(pitch_stop) == 1 then
            set(pitch_stop, 0)
            set(pitch_stop_cap, 1)
        else
            set(pitch_stop, 1)
            set(pitch_stop_cap, 0)
        end
    end
    return 0
end
registerCommandHandler(set_stop_command, 0, set_stop_handler)

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

local torq_coef = 92 / 1300 -- 92 kg/cm2 equals 1312 N*m

-- mininmum pitch angle = 8 deg. mid stop = 19 deg. feather = 92.5 deg
-- sim pitch is different. means real - 10 deg
-- this means that mininmum pitch angle = -2 deg. mid stop = 9 deg. feather = 82.5 deg
-- all this may change

local prop1_out_beta = false
local prop2_out_beta = false

local left_feather = false
local right_feather = false

local deg_coef = 8 + 9

local left_counter = 0
local right_counter = 0

local feather_left = false
local feather_right = false

local feather_left_test = false
local feather_right_test = false

local left_feather_ready_lamp = false
local right_feather_ready_lamp = false
local left_exit_feather = false
local right_exit_feather = false
local left_feather_lamp = false
local right_feather_lamp = false
local stop_lamp = false

local kfl_left = false
local kfl_right = false

-- seam datarefs for the 3D render (prop_3d): test inputs (set by clickables) + lamp outputs
local d_feather_left_test = cGPi(pfx .. "prop/feather_left_test")
local d_feather_right_test = cGPi(pfx .. "prop/feather_right_test")
local ind_left_exit_feather = cGPi(pfx .. "prop/ind_left_exit_feather")
local ind_right_exit_feather = cGPi(pfx .. "prop/ind_right_exit_feather")
local ind_left_ready = cGPi(pfx .. "prop/ind_left_ready")
local ind_right_ready = cGPi(pfx .. "prop/ind_right_ready")
local ind_left_feather = cGPi(pfx .. "prop/ind_left_feather")
local ind_right_feather = cGPi(pfx .. "prop/ind_right_feather")
local ind_kfl_left = cGPi(pfx .. "prop/ind_kfl_left")
local ind_kfl_right = cGPi(pfx .. "prop/ind_kfl_right")
local ind_stop_lamp = cGPi(pfx .. "prop/ind_stop_lamp")

function update()
    local passed = get(frame_time)

    if passed > 0 then
        -- sync feather-test state set by the prop_3d clickables
        feather_left_test = get(d_feather_left_test) == 1
        feather_right_test = get(d_feather_right_test) == 1
        local stop = get(pitch_stop)

        -- left prop calculations
        local left_rpm = get(prop1_rpm_rads) / 0.10471975511966
        local pitch_left = get(prop_pitch_1) + deg_coef
        local left_torq = get(torq1) * torq_coef
        local left_uprt = get(uprt1)
        local left_button = get(feather1_button)

        if left_rpm > 30 then
            -- limit pitch at beta
            if prop1_out_beta and pitch_left <= 21 then
                pitch_left = 21
                set(prop_pitch_1, pitch_left - deg_coef)
            end

            -- check if prop is out beta
            if pitch_left >= 21 and stop == 1 then
                prop1_out_beta = true
            else
                prop1_out_beta = false
            end

            -- autofeather and feather test
            if get(feather1_test1) == 1 then
                left_torq = 9
            elseif get(feather1_test2) == 1 then
                left_torq = -1
            end

            left_feather = ((left_torq < 10 and left_uprt > 0.32) or (left_torq < 0 and left_uprt > 0.26)) or
                               left_button == 1

            if left_feather then
                left_counter = left_counter + passed
            else
                left_counter = 0
            end

            if left_feather and left_counter > 1 and left_rpm > 400 then
                feather_left = true
                set(feather1_button, 1) -- need to test it
            end
            if left_button == 0 then
                feather_left = false
            end -- unfeather the prop, when button is unpressed

            -- feathering prop
            if feather_left and not feather_left_test and pitch_left < 92 then
                pitch_left = pitch_left + passed * 40
                set(prop_pitch_1, pitch_left - deg_coef)
            elseif feather_left_test and pitch_left < 30 then
                pitch_left = pitch_left + passed * 40
                set(prop_pitch_1, pitch_left - deg_coef)
            end

        else
            if left_button == 0 then
                feather_left = false
            end -- unfeather the prop, when button is unpressed

            if feather_left and pitch_left < 92 then
                pitch_left = pitch_left + passed * 40
                set(prop_pitch_1, pitch_left - deg_coef)
            elseif pitch_left > 8 and not feather_left then
                pitch_left = pitch_left - passed
                set(prop_pitch_1, pitch_left - deg_coef)
            elseif not feather_left then
                pitch_left = 8
                set(prop_pitch_1, pitch_left - deg_coef)
            end

        end

        -- right prop calculations
        local right_rpm = get(prop2_rpm_rads) / 0.10471975511966
        local pitch_right = get(prop_pitch_2) + deg_coef
        local right_torq = get(torq2) * torq_coef
        local right_uprt = get(uprt2)
        local right_button = get(feather2_button)

        if right_rpm > 30 then
            -- limit pitch at beta
            if prop2_out_beta and pitch_right <= 21 then
                pitch_right = 21
                set(prop_pitch_2, pitch_right - deg_coef)
            end

            -- check if prop is out beta
            if pitch_right >= 21 and stop == 1 then
                prop2_out_beta = true
            else
                prop2_out_beta = false
            end

            -- autofeather and feather test
            if get(feather2_test1) == 1 then
                right_torq = 9
            elseif get(feather2_test2) == 1 then
                right_torq = -1
            end

            right_feather = ((right_torq < 10 and right_uprt > 0.32) or (right_torq < 0 and right_uprt > 0.26)) or
                                right_button == 1

            if right_feather then
                right_counter = right_counter + passed
            else
                right_counter = 0
            end

            if right_feather and right_counter > 1 and right_rpm > 400 then
                feather_right = true
                set(feather2_button, 1) -- need to test it
            end

            if right_button == 0 then
                feather_right = false
            end -- unfeather the prop, when button is unpressed

            -- feathering prop
            if feather_right and not feather_right_test and pitch_right < 92 then
                pitch_right = pitch_right + passed * 40
                set(prop_pitch_2, pitch_right - deg_coef)
            elseif feather_right_test and pitch_right < 30 then
                pitch_right = pitch_right + passed * 40
                set(prop_pitch_2, pitch_right - deg_coef)
            end

        else
            if right_button == 0 then
                feather_right = false
            end -- unfeather the prop, when button is unpressed

            if feather_right and pitch_right < 92 then
                pitch_right = pitch_right + passed * 40
                set(prop_pitch_2, pitch_right - deg_coef)
            elseif pitch_right > 8 and not feather_right then
                pitch_right = pitch_right - passed
                set(prop_pitch_2, pitch_right - deg_coef)
            elseif not feather_right then
                pitch_right = 8
                set(prop_pitch_2, pitch_right - deg_coef)
            end
        end

        -- lamp logic
        left_feather_ready_lamp = false
        right_feather_ready_lamp = false
        left_exit_feather = false
        right_exit_feather = false
        left_feather_lamp = false
        right_feather_lamp = false
        stop_lamp = false
        kfl_left = false
        kfl_right = false

        local starter = get(apd_work_lit) == 1

        if get(bus_DC_27_volt_emerg) > 21 then
            if feather_left or feather_left_test then
                left_feather_lamp = true
            end
            if feather_right or feather_right_test then
                right_feather_lamp = true
            end

            if left_feather_lamp or get(fail1) == 6 or (left_rpm < 225 and not starter) then
                kfl_left = true
            end
            if right_feather_lamp or get(fail2) == 6 or (right_rpm < 225 and not starter) then
                kfl_right = true
            end

            if pitch_left < 90 and pitch_left > 60 and not left_feather_lamp then
                left_exit_feather = true
            end
            if pitch_right < 90 and pitch_right > 60 and not right_feather_lamp then
                right_exit_feather = true
            end

            if left_rpm > 1200 and left_uprt > 0.26 and get(prop_pitch_1) > 18 - deg_coef and not left_exit_feather and
                not left_feather_lamp then
                left_feather_ready_lamp = true
            end
            if right_rpm > 1200 and right_uprt > 0.26 and get(prop_pitch_2) > 18 - deg_coef and not right_exit_feather and
                not right_feather_lamp then
                right_feather_ready_lamp = true
            end

            if stop == 0 then
                stop_lamp = true
                set(pitch_stop_set, 0)
            else
                stop_lamp = false
                set(pitch_stop_set, 1)
            end
        end

        -- publish lamp state for the 3D render (prop_3d)
        set(ind_left_exit_feather, bool2int(left_exit_feather))
        set(ind_right_exit_feather, bool2int(right_exit_feather))
        set(ind_left_ready, bool2int(left_feather_ready_lamp))
        set(ind_right_ready, bool2int(right_feather_ready_lamp))
        set(ind_left_feather, bool2int(left_feather_lamp))
        set(ind_right_feather, bool2int(right_feather_lamp))
        set(ind_kfl_left, bool2int(kfl_left))
        set(ind_kfl_right, bool2int(kfl_right))
        set(ind_stop_lamp, bool2int(stop_lamp))
    end
end
