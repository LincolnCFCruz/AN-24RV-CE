-- define images
defineProperty("tapeImage", sasl.gl.loadImage("ag_tape.dds", 0, 0, 256, 1024))
defineProperty("planeImage", langImage("needles", 73, 228, 121, 27))
defineProperty("flagImage", langImage("needles", 85, 198, 58, 22))
defineProperty("triangle", sasl.gl.loadImage("triangle.png", 0, 0, 8, 8))
defineProperty("red_led", loadLED("red"))
defineProperty("green_led", loadLED("green"))
defineProperty("planka", sasl.gl.loadImage("ag_tape.dds", 0, 668, 10, 200))
-- define component property table
defineProperty("pitch_left", globalProperty("sim/flightmodel/position/theta"))
defineProperty("roll_left", globalProperty("sim/flightmodel/position/phi"))
defineProperty("pitch_right", globalProperty("sim/flightmodel/position/theta"))
defineProperty("roll_right", globalProperty("sim/flightmodel/position/phi"))
-- ias variable
defineProperty("ias", globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot"))
-- power
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("bus_AC_36_volt", globalProperty("an-24/power/bus_AC_36_volt"))
defineProperty("AGB_left", globalProperty("an-24/gauges/AGB_left"))
defineProperty("AGD_left", globalProperty("an-24/gauges/AGD_left"))
defineProperty("AGD_right", globalProperty("an-24/gauges/AGD_right"))
defineProperty("AHZ_cc", globalProperty("an-24/gauges/AHZ_cc"))
defineProperty("bkk_sw", globalProperty("an-24/gauges/bkk_sw"))
defineProperty("bkk_sw_cap", globalProperty("an-24/gauges/bkk_sw_cap"))
defineProperty("bkk_check_sw", globalProperty("an-24/gauges/bkk_check_sw"))
defineProperty("bkk_check_sw_cap", globalProperty("an-24/gauges/bkk_check_sw_cap"))
defineProperty("AP_roll", globalProperty("an-24/ap/indicated_roll")) -- roll for autopilot
defineProperty("AP_pitch", globalProperty("an-24/ap/indicated_pitch")) -- pitch for autopilot
defineProperty("roll_high", globalProperty("an-24/gauges/roll_high")) -- excessive roll
-- failures
defineProperty("left_fail", globalProperty("sim/operation/failures/rel_ss_ahz")) -- failure for pilot ahz
defineProperty("right_fail", globalProperty("sim/operation/failures/rel_cop_ahz")) -- failure for copilot ahz
-- time from simulator start
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("sim_time", globalProperty("sim/time/total_running_time_sec")) -- sim time
-- realism setting
defineProperty("set_real_ahz", globalProperty("an-24/set/real_ahz")) -- real ahz has errors and needs to be corrected
-- ag*_pitch, ag*_pitch_rot, ag3_roll declared in glbl_drfs.lua (runs once); bind below
defineProperty("ag1_roll", globalProperty("an-24/misc/ag1_roll")) -- roll for animation
defineProperty("ag2_roll", globalProperty("an-24/misc/ag2_roll")) -- roll for animation
defineProperty("ag3_roll", globalProperty("an-24/misc/ag3_roll")) -- roll for animation
defineProperty("ag1_pitch", globalProperty("an-24/misc/ag1_pitch")) -- pitch for animation
defineProperty("ag2_pitch", globalProperty("an-24/misc/ag2_pitch")) -- pitch for animation
defineProperty("ag3_pitch", globalProperty("an-24/misc/ag3_pitch")) -- pitch for animation
defineProperty("ag1_pitch_rot", globalProperty("an-24/misc/ag1_pitch_rot")) -- pitch rotary for animation
defineProperty("ag2_pitch_rot", globalProperty("an-24/misc/ag2_pitch_rot")) -- pitch rotary for animation
defineProperty("ag3_pitch_rot", globalProperty("an-24/misc/ag3_pitch_rot")) -- pitch rotary for animation
defineProperty("arrest_third", globalProperty("an-24/set/arrest_third")) -- SmartCopilot usage
defineProperty("right_agd_arrest", globalProperty("an-24/set/right_agd_arrest")) -- SmartCopilot usage
defineProperty("left_agd_arrest", globalProperty("an-24/set/left_agd_arrest")) -- SmartCopilot usage
-- SmartCopilot
defineProperty("ismaster", globalProperty("scp/api/ismaster")) -- 0 = undefined/plugin not found, 1 = slave, 2 = master
-- initial switchers values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))

local switch_sound = loadSample('sounds/custom/metal_switch.wav')
local cap_sound = loadSample('sounds/custom/cap.wav')
local btn_click = loadSample('sounds/custom/plastic_btn.wav')
local rot_click = loadSample('sounds/custom/rot_click.wav')

-- height of visible window area
local winHeight = 130 / 512
-- height of one degree in texture coordinates
local pitch_deg = 2.0 / 512
local now = get(sim_time)
local real_num = get(set_real_ahz)
local real = real_num == 1
-- left horizon
local initial_roll_err_left = 0 -- math.random(-50, 50) * real_num -- initial error, which will be decreased to 0 after connecting power
local roll_err_left = 0 -- cumulative error increases during flight
local roll_corr_left = 0 -- correction for errors and arrest
local roll_left_show = 0 -- result roll
local roll_off_left = 0 -- math.random(-2, 2)* real_num -- determines the fall direction for AG
local initial_pitch_err_left = 0 -- math.random(-60, 60) * real_num -- initial error, which will be decreased to 0 after connecting power
local pitch_err_left = 0 -- cumulative error increases during flight
local pitch_corr_left = 0 -- correction for errors and arrest
local pitch_left_show = 0 -- result pitch
local pitch_off_left = 0 -- math.random(-2, 2) * real_num -- determines the fall direction for AG
local arrest_left = 0 -- variable for arresting process
local pitch_rot_left = 0
local ahz_left_fail = true
local ahz_start_left = get(sim_time)

-- right horizon
local initial_roll_err_right = 0 -- math.random(-50, 50) * real_num -- initial error, which will be decreased to 0 after connecting power
local roll_err_right = 0 -- cumulative error increases during flight
local roll_corr_right = 0 -- correction for errors and arrest
local roll_right_show = 0 -- result roll
local roll_off_right = 0 -- math.random(-2, 2) * real_num -- determines the fall direction for AG
local initial_pitch_err_right = 0 -- math.random(-60, 60) * real_num -- initial error, which will be decreased to 0 after connecting power
local pitch_err_right = 0 -- cumulative error increases during flight
local pitch_corr_right = 0 -- correction for errors and arrest
local pitch_right_show = 0 -- result pitch
local pitch_off_right = 0 -- math.random(-2, 2) * real_num -- determines the fall direction for AG
local arrest_right = 0 -- variable for arresting process
local pitch_rot_right = 0
local ahz_right_fail = true
local ahz_start_right = get(sim_time)

-- third horizon
local initial_roll_err_third = 0 -- math.random(-20, 20) * real_num -- initial error, which will be decreased to 0 after connecting power
local roll_err_third = 0 -- cumulative error increases during flight
local roll_corr_third = 0 -- correction for errors and arrest
local roll_third_show = 0 -- result roll
local roll_off_third = 0 -- math.random(-2, 2) * real_num -- determines the fall direction for AG
local initial_pitch_err_third = 0 -- math.random(-30, 30) * real_num -- initial error, which will be decreased to 0 after connecting power
local pitch_err_third = 0 -- cumulative error increases during flight
local pitch_corr_third = 0 -- correction for errors and arrest
local pitch_third_show = 0 -- result pitch
local pitch_off_third = 0 -- math.random(-2, 2) * real_num -- determines the fall direction for AG
local arrest_push_third = false -- tracks whether the arrest button is pressed
local pitch_rot_third = 0
local ahz_third_fail = true
local ahz_start_third = get(sim_time)
local roll_left_big = false
local roll_right_big = false
local check_ahz = false
local check_bkk = false
local left_agd_arrest_start = now - 10
local right_agd_arrest_start = now - 10
local power_roll_left = 0 -- get(roll_left)
local power_pitch_left = 0 -- get(pitch_left)
local power_roll_right = 0 -- get(roll_right)
local power_pitch_right = 0 -- get(pitch_right)
local power_roll_third = 0 -- get(roll_right)
local power_pitch_third = 0 -- get(pitch_right)
local time_counter = 0
local notLoaded = true
local power27 = 0
local power27_main = 0
local power36 = 0
local eng_check = true

add_roll_left = 0
add_roll_right = 0
add_roll_third = 0

add_pitch_left = 0
add_pitch_right = 0
add_pitch_third = 0

flag1 = 0
flag2 = 0
flag3 = 0

-- ahz_start_right promoted to a dataref so the AGD-right switch (render) can stamp it,
-- while this logic reads it for the 15-sec spin-up. Init to current sim time (matches the
-- old `local ahz_start_right = get(sim_time)`).
-- NOTE: declared via defineProperty (module globals), NOT `local`, to avoid blowing Lua's
-- 60-upvalue-per-function limit in update() (this module has ~50 attitude-state locals).
defineProperty("d_ahz_start_right", cGPf(pfx .. "gauges/ahz_start_right", get(sim_time)))
-- seam datarefs: lamp/flag states published for the 3D render (art_horizons_3d)
defineProperty("ind_ahz_left_fail", cGPi(pfx .. "gauges/ind_ahz_left_fail"))
defineProperty("ind_ahz_right_fail", cGPi(pfx .. "gauges/ind_ahz_right_fail"))
defineProperty("ind_ahz_third_fail", cGPi(pfx .. "gauges/ind_ahz_third_fail"))
defineProperty("ind_roll_left_big", cGPi(pfx .. "gauges/ind_roll_left_big"))
defineProperty("ind_roll_right_big", cGPi(pfx .. "gauges/ind_roll_right_big"))
defineProperty("ind_check_ahz", cGPi(pfx .. "gauges/ind_check_ahz"))
defineProperty("ind_check_bkk", cGPi(pfx .. "gauges/ind_check_bkk"))
defineProperty("ind_power27", cGPi(pfx .. "gauges/ind_power27"))

registerCommandHandler(createCommand("An-24/Instruments/Pilot/agb_left_sw_on", "AGB 1 on."), 0, function(p)
    if p == 0 and get(AGB_left) ~= 1 then
        set(AGB_left, 1)
        ahz_start_third = get(sim_time)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Instruments/Pilot/agb_left_sw_off", "AGB 1 off."), 0, function(p)
    if p == 0 and get(AGB_left) ~= 0 then
        set(AGB_left, 0)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Instruments/Pilot/agb_left_sw_toggle", "AGB 1 toggle."), 0, function(p)
    if p == 0 then
        if get(AGB_left) == 0 then
            set(AGB_left, 1)
            ahz_start_third = get(sim_time)
        else
            set(AGB_left, 0)
        end
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Pilot/agd_left_sw_on", "AGD 1 on."), 0, function(p)
    if p == 0 and get(AGD_left) ~= 1 then
        set(AGD_left, 1)
        ahz_start_left = get(sim_time)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Instruments/Pilot/agd_left_sw_off", "AGD 1 off."), 0, function(p)
    if p == 0 and get(AGD_left) ~= 0 then
        set(AGD_left, 0)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Instruments/Pilot/agd_left_sw_toggle", "AGD 1 toggle."), 0, function(p)
    if p == 0 then
        if get(AGD_left) == 0 then
            set(AGD_left, 1)
            ahz_start_left = get(sim_time)
        else
            set(AGD_left, 0)
        end
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Pilot/bkk_cap_open", "BKK CAP open."), 0, function(p)
    if p == 0 and get(bkk_sw_cap) ~= 1 then
        set(bkk_sw_cap, 1)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Instruments/Pilot/bkk_cap_close", "BKK CAP close."), 0, function(p)
    if p == 0 and get(bkk_sw_cap) ~= 0 then
        set(bkk_sw_cap, 0)
        set(bkk_sw, 1)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Instruments/Pilot/bkk_cap_toggle", "BKK CAP toggle."), 0, function(p)
    if p == 0 then
        if get(bkk_sw_cap) ~= 1 then
            set(bkk_sw_cap, 1)
        else
            set(bkk_sw_cap, 0)
            set(bkk_sw, 1)
        end
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Instruments/Pilot/bkk_on", "BKK on."), 0, function(p)
    if p == 0 and get(bkk_sw) ~= 1 then
        set(bkk_sw, 1)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Instruments/Pilot/bkk_off", "BKK off."), 0, function(p)
    if p == 0 and get(bkk_sw) ~= 0 then
        set(bkk_sw, 0)
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Instruments/Pilot/bkk_toggle", "BKK toggle."), 0, function(p)
    if p == 0 then
        if get(bkk_sw) ~= 1 then
            set(bkk_sw, 1)
        else
            set(bkk_sw, 0)
        end
    end
    return 0
end)

function update()
    -- time variables
    local active_logic = get(ismaster) ~= 1
    local passed = get(frame_time)
    now = get(sim_time)

    if get(left_agd_arrest) == 1 then
        left_agd_arrest_start = now
    end
    if get(right_agd_arrest) == 1 then
        right_agd_arrest_start = now
    end

    -- main func
    if passed > 0 then
        real_num = get(set_real_ahz)
        real = real_num == 1
        -- initial switchers values
        if get(N1) < 70 and get(N2) < 70 and eng_check and time_counter > 0.3 and time_counter < 0.4 then
            set(AGB_left, 0)
            set(AGD_left, 0)
            set(AGD_right, 0)
            set(bkk_sw, 0)
            set(bkk_sw_cap, 1)
            eng_working = true
            eng_check = false
        end
        -- set initial AHZ position
        time_counter = time_counter + passed
        if real and time_counter > 0.3 and time_counter < 0.4 and notLoaded and get(N1) < 70 and get(N2) < 70 then
            initial_roll_err_left = math.random(-50, 50)
            roll_off_left = math.random(-2, 2)
            initial_pitch_err_left = math.random(-60, 60)
            pitch_off_left = math.random(-2, 2)

            initial_roll_err_right = math.random(-50, 50)
            roll_off_right = math.random(-2, 2)
            initial_pitch_err_right = math.random(-60, 60)
            pitch_off_right = math.random(-2, 2)

            initial_roll_err_third = math.random(-20, 20)
            roll_off_third = math.random(-1, 1)
            initial_pitch_err_third = math.random(-30, 30)
            pitch_off_third = math.random(-1, 1)

            notLoaded = false
        elseif real and time_counter > 0.3 and time_counter < 0.4 and notLoaded then
            roll_off_left = math.random(-2, 2)
            pitch_off_left = math.random(-2, 2)

            roll_off_right = math.random(-2, 2)
            pitch_off_right = math.random(-2, 2)

            roll_off_third = math.random(-1, 1)
            pitch_off_third = math.random(-1, 1)

            notLoaded = false
        end

        -- calculate power
        if get(bus_DC_27_volt_emerg) > 21 then
            power27 = 1
        else
            power27 = 0
        end
        if dcOK() then
            power27_main = 1
        else
            power27_main = 0
        end
        if get(bus_AC_36_volt) > 28 then
            power36 = 1
        else
            power36 = 0
        end

        local fail_left = get(left_fail)
        local fail_right = get(right_fail)

        if now - left_agd_arrest_start < 4 then
            arrest_left = 1
        else
            arrest_left = 0
        end
        if now - right_agd_arrest_start < 4 then
            arrest_right = 1
        else
            arrest_right = 0
        end

        local AGD_left_sw = get(AGD_left)
        local AGD_right_sw = get(AGD_right)
        local AGB_left_sw = get(AGB_left)

        -------------------
        -- left --

        if active_logic then

            -- calculate roll and pitch for power off
            if power27 * power36 * get(AGD_left) ~= 0 and flag1 == 1 then
                add_roll_left = power_roll_left - get(roll_left)
                add_pitch_left = power_pitch_left - get(pitch_left)
                flag1 = 0
            end

            if power27 * power36 * get(AGD_left) == 0 or fail_left == 6 then
                flag1 = 1
            else
                power_roll_left = get(roll_left) + add_roll_left
                power_pitch_left = get(pitch_left) + add_pitch_left
            end

            -- calculate power ON and OFF initial roll and pitch
            if power27 * power36 * AGD_left_sw == 0 or fail_left == 6 then
                if math.abs(initial_roll_err_left) < 50 then
                    initial_roll_err_left = initial_roll_err_left + passed * roll_off_left * real_num
                end
                if math.abs(initial_pitch_err_left) < 60 then
                    initial_pitch_err_left = initial_pitch_err_left + passed * pitch_off_left * real_num
                end
            else
                if initial_roll_err_left > 0.1 then
                    initial_roll_err_left = initial_roll_err_left - passed
                elseif initial_roll_err_left < -0.1 then
                    initial_roll_err_left = initial_roll_err_left + passed
                else
                    initial_roll_err_left = 0
                end
                if initial_pitch_err_left > 0.1 then
                    initial_pitch_err_left = initial_pitch_err_left - passed
                elseif initial_pitch_err_left < -0.1 then
                    initial_pitch_err_left = initial_pitch_err_left + passed
                else
                    initial_pitch_err_left = 0
                end
            end

            -- calculate cumulative error
            if math.abs(roll_err_left) < 20 then
                roll_err_left = roll_err_left + roll_err_left * (math.random() - 0.49999) * passed * 0.001 * real_num
            end
            if math.abs(pitch_err_left) < 20 then
                pitch_err_left = pitch_err_left + pitch_err_left * (math.random() - 0.49999) * passed * 0.001 * real_num
            end

            -- arresting mechanism
            if power27 * power36 * arrest_left * get(AGD_left) > 0 and fail_left < 6 then
                -- set new correction
                if roll_left_show > 0.1 then
                    roll_corr_left = roll_corr_left + 10 * passed
                elseif roll_left_show < -0.1 then
                    roll_corr_left = roll_corr_left - 10 * passed
                end
                -- end
                if math.abs(initial_pitch_err_left) < 0.1 then
                    if pitch_left_show > 0.1 then
                        pitch_corr_left = pitch_corr_left + 5 * passed
                    elseif pitch_left_show < -0.1 then
                        pitch_corr_left = pitch_corr_left - 5 * passed
                    end
                end
                -- reset errors
                if power_roll_left > 0.1 then
                    power_roll_left = power_roll_left - passed
                elseif power_roll_left < -0.1 then
                    power_roll_left = power_roll_left + passed
                end
                if power_pitch_left > 0.1 then
                    power_pitch_left = power_pitch_left - passed
                elseif power_pitch_left < -0.1 then
                    power_pitch_left = power_pitch_left + passed
                end

                if initial_roll_err_left > 0.1 then
                    initial_roll_err_left = initial_roll_err_left - passed * 2
                elseif initial_roll_err_left < -0.1 then
                    initial_roll_err_left = initial_roll_err_left + passed * 2
                end
                if initial_pitch_err_left > 0.1 then
                    initial_pitch_err_left = initial_pitch_err_left - passed * 12
                elseif initial_pitch_err_left < -0.1 then
                    initial_pitch_err_left = initial_pitch_err_left + passed * 12
                end

                if roll_err_left > 0.1 then
                    roll_err_left = roll_err_left - passed
                elseif roll_err_left < -0.1 then
                    roll_err_left = roll_err_left + passed
                end
                if pitch_err_left > 0.1 then
                    pitch_err_left = pitch_err_left - passed
                elseif pitch_err_left < 0.1 then
                    pitch_err_left = pitch_err_left + passed
                end
            end

            -- main formula for current position
            roll_left_show = power_roll_left - roll_corr_left -- + roll_err_left+ initial_roll_err_left
            pitch_left_show = power_pitch_left - pitch_corr_left -- + pitch_err_left + initial_pitch_err_left
            -- final result is a sum of power position, initial gauge error, cumulative gauge error, and correction of this error
            -- limit pitch
            if pitch_left_show > 80 then
                pitch_left_show = 80
            elseif pitch_left_show < -80 then
                pitch_left_show = -80
            end

            set(ag1_pitch, pitch_left_show)
            set(ag1_roll, roll_left_show)

            -----------------------
            -- right --
            -- calculate roll and pitch for power off
            if power27 * power36 * get(AGD_right) ~= 0 and flag2 == 1 then
                add_roll_right = power_roll_right - get(roll_right)
                add_pitch_right = power_pitch_right - get(pitch_right)
                flag2 = 0
            end

            if power27 * power36 * get(AGD_right) == 0 or fail_right == 6 then
                flag2 = 1
            else
                power_roll_right = get(roll_right) + add_roll_right
                power_pitch_right = get(pitch_right) + add_pitch_right
            end

            -- calculate power ON and OFF initial roll and pitch
            if power27_main * power36 * AGD_right_sw == 0 or fail_right == 6 then
                if math.abs(initial_roll_err_right) < 50 then
                    initial_roll_err_right = initial_roll_err_right + passed * roll_off_right * real_num
                end
                if math.abs(initial_pitch_err_right) < 60 then
                    initial_pitch_err_right = initial_pitch_err_right + passed * pitch_off_right * real_num
                end
            else
                if initial_roll_err_right > 0.1 then
                    initial_roll_err_right = initial_roll_err_right - passed
                elseif initial_roll_err_right < -0.1 then
                    initial_roll_err_right = initial_roll_err_right + passed
                else
                    initial_roll_err_right = 0
                end
                if initial_pitch_err_right > 0.1 then
                    initial_pitch_err_right = initial_pitch_err_right - passed
                elseif initial_pitch_err_right < -0.1 then
                    initial_pitch_err_right = initial_pitch_err_right + passed
                else
                    initial_pitch_err_right = 0
                end
            end

            -- calculate cumulative error
            if math.abs(roll_err_right) < 20 then
                roll_err_right = roll_err_right + roll_err_right * (math.random() - 0.49999) * passed * 0.001 * real_num
            end
            if math.abs(pitch_err_right) < 20 then
                pitch_err_right = pitch_err_right + pitch_err_right * (math.random() - 0.49999) * passed * 0.001 *
                                      real_num
            end

            -- arresting mechanism
            if power27_main * power36 * arrest_right * get(AGD_right) > 0 and fail_right < 6 then
                -- set new correction
                -- set new correction
                if roll_right_show > 0.1 then
                    roll_corr_right = roll_corr_right + 10 * passed
                elseif roll_right_show < -0.1 then
                    roll_corr_right = roll_corr_right - 10 * passed
                end
                -- end
                if math.abs(initial_pitch_err_right) < 0.1 then
                    if pitch_right_show > 0.1 then
                        pitch_corr_right = pitch_corr_right + 5 * passed
                    elseif pitch_right_show < -0.1 then
                        pitch_corr_right = pitch_corr_right - 5 * passed
                    end
                end

                -- reset errors
                if power_roll_right > 0.1 then
                    power_roll_right = power_roll_right - passed
                elseif power_roll_right < -0.1 then
                    power_roll_right = power_roll_right + passed
                end
                if power_pitch_right > 0.1 then
                    power_pitch_right = power_pitch_right - passed
                elseif power_pitch_right < -0.1 then
                    power_pitch_right = power_pitch_right + passed
                end

                if initial_roll_err_right > 0.1 then
                    initial_roll_err_right = initial_roll_err_right - passed * 2
                elseif initial_roll_err_right < -0.1 then
                    initial_roll_err_right = initial_roll_err_right + passed * 2
                end
                if initial_pitch_err_right > 0.1 then
                    initial_pitch_err_right = initial_pitch_err_right - passed * 12
                elseif initial_pitch_err_right < -0.1 then
                    initial_pitch_err_right = initial_pitch_err_right + passed * 15
                end

                if roll_err_right > 0.1 then
                    roll_err_right = roll_err_right - passed
                elseif roll_err_right < -0.1 then
                    roll_err_right = roll_err_right + passed
                end
                if pitch_err_right > 0.1 then
                    pitch_err_right = pitch_err_right - passed
                elseif pitch_err_right < 0.1 then
                    pitch_err_right = pitch_err_right + passed
                end
            end

            -- main formula for current position
            roll_right_show = power_roll_right - roll_corr_right -- + roll_err_right + initial_roll_err_right
            pitch_right_show = power_pitch_right - pitch_corr_right -- + pitch_err_right + initial_pitch_err_right
            -- final result is a sum of power position, initial gauge error, cumulative gauge error, and correction of this error
            -- limit pitch
            if pitch_right_show > 80 then
                pitch_right_show = 80
            elseif pitch_right_show < -80 then
                pitch_right_show = -80
            end

            -- set variables for AP
            set(AP_roll, roll_right_show)
            set(AP_pitch, pitch_right_show)

            set(ag2_pitch, pitch_right_show)
            set(ag2_roll, roll_right_show)

            -----------------------
            -- third --
            -- calculate roll and pitch for power off
            if power27 * power36 * get(AGB_left) ~= 0 and flag3 == 1 then
                add_roll_third = power_roll_third - get(roll_left)
                add_pitch_third = power_pitch_third - get(pitch_left)
                flag3 = 0
            end

            if power27 * power36 * get(AGB_left) == 0 or fail_left == 6 then
                flag3 = 1
            else
                power_roll_third = get(roll_left) + add_roll_third
                power_pitch_third = get(pitch_left) + add_pitch_third
            end

            -- calculate power ON and OFF initial roll and pitch
            if power27_main * power36 * AGB_left_sw == 0 or fail_right == 6 then
                if math.abs(initial_roll_err_third) < 20 then
                    initial_roll_err_third = initial_roll_err_third + passed * roll_off_third * 0.01 * real_num
                end
                if math.abs(initial_pitch_err_third) < 30 then
                    initial_pitch_err_third = initial_pitch_err_third + passed * pitch_off_third * 0.01 * real_num
                end
            else
                if initial_roll_err_third > 0.1 then
                    initial_roll_err_third = initial_roll_err_third - passed * 0.01
                elseif initial_roll_err_third < -0.1 then
                    initial_roll_err_third = initial_roll_err_third + passed * 0.01
                else
                    initial_roll_err_third = 0
                end
                if initial_pitch_err_third > 0.1 then
                    initial_pitch_err_third = initial_pitch_err_third - passed * 0.01
                elseif initial_pitch_err_third < -0.1 then
                    initial_pitch_err_third = initial_pitch_err_third + passed * 0.01
                else
                    initial_pitch_err_third = 0
                end
            end

            -- calculate cumulative error
            if math.abs(roll_err_third) < 20 then
                roll_err_third = roll_err_third + roll_err_third * (math.random() - 0.49999) * passed * 0.001 * real_num
            end
            if math.abs(pitch_err_third) < 20 then
                pitch_err_third = pitch_err_third + pitch_err_third * (math.random() - 0.49999) * passed * 0.001 *
                                      real_num
            end

            -- arresting mechanism
            if get(arrest_third) * get(AGB_left) > 0 and fail_right < 6 then
                -- set new correction
                if math.abs(initial_roll_err_third) < 0.1 then
                    if roll_third_show > 0.1 then
                        roll_corr_third = roll_corr_third + 6 * passed
                    elseif roll_third_show < -0.1 then
                        roll_corr_third = roll_corr_third - 6 * passed
                    end
                end
                if math.abs(initial_pitch_err_third) < 0.1 then
                    if pitch_third_show > 0.1 then
                        pitch_corr_third = pitch_corr_third + 6 * passed
                    elseif pitch_third_show < -0.1 then
                        pitch_corr_third = pitch_corr_third - 6 * passed
                    end
                end

                -- reset errors
                if power_roll_third > 0.1 then
                    power_roll_third = power_roll_third - passed
                elseif power_roll_third < -0.1 then
                    power_roll_third = power_roll_third + passed
                end
                if power_pitch_third > 0.1 then
                    power_pitch_third = power_pitch_third - passed
                elseif power_pitch_third < -0.1 then
                    power_pitch_third = power_pitch_third + passed
                end

                if initial_roll_err_third > 0.1 then
                    initial_roll_err_third = initial_roll_err_third - passed * 12
                elseif initial_roll_err_third < -0.1 then
                    initial_roll_err_third = initial_roll_err_third + passed * 12
                end
                if initial_pitch_err_third > 0.1 then
                    initial_pitch_err_third = initial_pitch_err_third - passed * 12
                elseif initial_pitch_err_third < -0.1 then
                    initial_pitch_err_third = initial_pitch_err_third + passed * 12
                end

                if roll_err_third > 0.1 then
                    roll_err_third = roll_err_third - passed
                elseif roll_err_third < -0.1 then
                    roll_err_third = roll_err_third + passed
                end
                if pitch_err_third > 0.1 then
                    pitch_err_third = pitch_err_third - passed
                elseif pitch_err_third < 0.1 then
                    pitch_err_third = pitch_err_third + passed
                end
            end

            -- print(AGB_left_sw, initial_pitch_err_third, pitch_err_third, power_pitch_third)

            -- main formula for current position
            roll_third_show = power_roll_third - roll_corr_third -- + roll_err_third + initial_roll_err_third
            pitch_third_show = power_pitch_third - pitch_corr_third -- + pitch_err_third + initial_pitch_err_third
            -- final result is a sum of power position, initial gauge error, cumulative gauge error, and correction of this error
            -- limit pitch
            if pitch_third_show > 80 then
                pitch_third_show = 80
            elseif pitch_third_show < -80 then
                pitch_third_show = -80
            end

            set(ag3_pitch, pitch_third_show)
            set(ag3_roll, roll_third_show)

        end
        ----------------------------

        -- lamp and flag logic
        if power27 > 0 then
            if power36 == 0 or fail_left == 6 or AGD_left_sw == 0 or arrest_left > 0 then
                ahz_left_fail = true
            else
                ahz_left_fail = false
            end
            if power36 == 0 or fail_right == 6 or AGD_right_sw == 0 or arrest_right > 0 or power27_main == 0 then
                ahz_right_fail = true
            else
                ahz_right_fail = false
            end
            if power36 == 0 or fail_left == 6 or AGB_left_sw == 0 or get(arrest_third) > 0 or power27_main == 0 then
                ahz_third_fail = true
            else
                ahz_third_fail = false
            end
        else
            ahz_left_fail = false
            ahz_right_fail = false
            ahz_third_fail = false
        end

        -- power consumption
        local agb_left_cc = 0
        local agd_left_cc = 0
        local agd_right_cc = 0

        if power27 > 0 then
            if not ahz_left_fail then
                agd_left_cc = 1
            else
                agd_left_cc = 0
            end
            if not ahz_right_fail then
                agd_right_cc = 1
            else
                agd_right_cc = 0
            end
            if not ahz_third_fail then
                agb_left_cc = 1
            else
                agb_left_cc = 0
            end
        end

        local bkk = get(bkk_sw) * power27 * power36 -- check if BKK unit is working

        set(AHZ_cc, agb_left_cc + agd_left_cc + agd_right_cc + bkk)

        -- lamps for 15 sec after turn ON
        if power27 > 0 then
            local bkk_check_switch = get(bkk_check_sw)
            if bkk > 0 and power36 == 1 and (bkk_check_switch == 0 or bkk_check_switch == 2) then
                check_bkk = true
            else
                check_bkk = false
            end

            if (now - ahz_start_left < 15 and now - ahz_start_left > 0) or check_bkk then
                ahz_left_fail = true
            end
            if (now - get(d_ahz_start_right) < 15 and now - get(d_ahz_start_right) > 0) or check_bkk then
                ahz_right_fail = true
            end
            if (now - ahz_start_third < 15 and now - ahz_start_third > 0) or check_bkk then
                ahz_third_fail = true
            end

            roll_left_show = get(ag1_roll)
            roll_right_show = get(ag2_roll)
            roll_third_show = get(ag3_roll)

            -- excessive roll indication
            if get(ias) * 1.852 < 230 and bkk > 0 then
                if roll_left_show < -15 then
                    roll_left_big = true
                    roll_right_big = false
                elseif roll_left_show > 15 then
                    roll_left_big = false
                    roll_right_big = true
                else
                    roll_left_big = false
                    roll_right_big = false
                end
            elseif bkk > 0 then
                if roll_left_show < -32 then
                    roll_left_big = true
                    roll_right_big = false
                elseif roll_left_show > 32 then
                    roll_left_big = false
                    roll_right_big = true
                else
                    roll_left_big = false
                    roll_right_big = false
                end
            end
            if roll_left_big or roll_right_big then
                set(roll_high, 1)
            else
                set(roll_high, 0)
            end
            check_ahz =
                math.abs(roll_left_show - roll_right_show) > 7 or math.abs(roll_left_show - roll_third_show) > 7 or
                    math.abs(roll_right_show - roll_third_show) > 7 or bkk == 0
        else
            roll_left_big = false
            roll_right_big = false
            check_ahz = false
            check_bkk = false
            ahz_left_fail = false
            ahz_right_fail = false
            ahz_third_fail = false
            set(roll_high, 0)
        end
        -- set animation
        --set(ag1_roll, roll_left_show)
        --set(ag2_roll, roll_right_show)

        -- publish lamp/flag state for the 3D render (art_horizons_3d)
        set(ind_ahz_left_fail, bool2int(ahz_left_fail))
        set(ind_ahz_right_fail, bool2int(ahz_right_fail))
        set(ind_ahz_third_fail, bool2int(ahz_third_fail))
        set(ind_roll_left_big, bool2int(roll_left_big))
        set(ind_roll_right_big, bool2int(roll_right_big))
        set(ind_check_ahz, bool2int(check_ahz))
        set(ind_check_bkk, bool2int(check_bkk))
        set(ind_power27, power27)
    end
end
