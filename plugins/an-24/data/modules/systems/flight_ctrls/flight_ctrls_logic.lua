-- Flight controls and autopilot mechanics animation.
-- XP12: autopilot commands are written to the artstab channel
-- (XP12 sums artstab + joystick → final surface deflection).
-- ═════════════════════════════════════════════════════════════════════════════
-- AUTOPILOT GAIN SETTINGS — choose one mode
-- ═════════════════════════════════════════════════════════════════════════════
-- Uncomment ONE of the variants below, leave the others commented.
--
-- MODE 1: "PARSHUKOFF" — original soft AP-28 dynamics (as in XP11)
-- AP is soft, smooth, unhurried — like the real An-24 AP-28.
-- May not hold well in sharp deviations, but that is REALISM.
-- local AP_ROLL_GAIN = 1.0
-- local AP_PITCH_GAIN = 1.0
-- local AP_YAW_GAIN = 1.0
-- MODE 2: "BALANCED" — compromise between realism and effectiveness (ACTIVE FOR XP12)
-- AP noticeably works but is not too sharp. Good for normal flights.
local AP_ROLL_GAIN = 1.5
local AP_PITCH_GAIN = 1.5
local AP_YAW_GAIN = 2.0

-- MODE 3: "ENHANCED" — aggressive (x2/x3)
-- AP holds the aircraft well, but may feel sharp in wind.
-- local AP_ROLL_GAIN = 2.0
-- local AP_PITCH_GAIN = 2.0
-- local AP_YAW_GAIN = 3.0
-- ═════════════════════════════════════════════════════════════════════════════

-- ═════════════════════════════════════════════════════════════════════════════
-- CONTROL WHEEL STEERING (CWS) — smooth AP disengagement on pilot input
-- ═════════════════════════════════════════════════════════════════════════════
-- When the pilot moves the yoke more than CWS_THRESHOLD from centre,
-- the AP smoothly reduces its authority so it does not fight the pilot.
-- When the pilot releases — AP smoothly returns to full authority.
-- Useful for fine course/altitude corrections without switching AP off.

-- Threshold: how far the yoke must be deflected for AP to "feel" input.
-- 0.10 = 10% of full travel. Lower = more sensitive.
local CWS_THRESHOLD = 0.10

-- AP authority reduction during pilot input (0 = AP fully off, 1 = no change).
-- 0.2 = AP loses 80% authority during pilot input.
local CWS_REDUCTION = 0.2

-- Speed at which AP authority recovers after pilot releases yoke (seconds).
-- Lower = faster recovery. 2.0 = fully restored in ~2 seconds.
local CWS_RECOVERY_TIME = 2.0

-- To disable CWS entirely (AP always at full authority) set threshold = 2.0:
-- local CWS_THRESHOLD = 2.0
-- ═════════════════════════════════════════════════════════════════════════════

-- environment
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("airspeed", globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot"))
defineProperty("overr", globalProperty("sim/operation/override/override_control_surfaces")) -- override controls

-- XP12: to physically influence the aircraft via AP, write to artstab_*_ratio.
-- XP12 sums artstab + joystick input → final surface deflection.
-- This works correctly when override = 0.

-- controls
defineProperty("head_ratio", globalProperty("sim/flightmodel2/controls/heading_ratio"))
defineProperty("pitch_ratio", globalProperty("sim/flightmodel2/controls/pitch_ratio"))
defineProperty("roll_ratio", globalProperty("sim/flightmodel2/controls/roll_ratio"))

-- XP12: direct joystick input — pure pilot commands without stability augmentation.
defineProperty("yoke_pitch_in", globalProperty("sim/joystick/yoke_pitch_ratio"))
defineProperty("yoke_roll_in", globalProperty("sim/joystick/yoke_roll_ratio"))
defineProperty("yoke_heading_in", globalProperty("sim/joystick/yoke_heading_ratio"))

-- XP12 CRITICAL FOR AUTOPILOT: artstab is the ARTIFICIAL STABILISATION channel.
-- XP12 SUMS artstab + joystick → final surface deflection.
-- Write AP commands here — they genuinely affect the physics.
-- Requires override_artstab = 1 (otherwise XP computes artstab itself).
defineProperty("artstab_pitch", globalProperty("sim/joystick/artstab_pitch_ratio"))
defineProperty("artstab_roll", globalProperty("sim/joystick/artstab_roll_ratio"))
defineProperty("artstab_heading", globalProperty("sim/joystick/artstab_heading_ratio"))
defineProperty("override_artstab", globalProperty("sim/operation/override/override_artstab"))

-- XP12: flap_ratio → flap_handle_request_ratio (old name marked REPLACED).
-- New name is more precise: this is the FLAP HANDLE position (pilot intent).
-- For actual flap position (with inertia) use flap_system_deploy_ratio.
defineProperty("flap_ratio", globalProperty("sim/cockpit2/controls/flap_handle_request_ratio"))
defineProperty("elevator_trim", globalProperty("sim/cockpit2/controls/elevator_trim")) -- sim pitch trimmer
defineProperty("aileron_trim", globalProperty("sim/cockpit2/controls/aileron_trim")) -- sim roll trimmer
defineProperty("rudder_trim", globalProperty("sim/cockpit2/controls/rudder_trim")) -- sim yaw trimmer

-- wings
defineProperty("ail_set_L", globalProperty("sim/flightmodel/controls/mwing07_ail1def")) -- inner aileron left, deg, positive = trailing-edge down
defineProperty("ail_set_R", globalProperty("sim/flightmodel/controls/mwing06_ail1def")) -- right, deg, positive = trailing-edge down
defineProperty("flap_inn_L", globalProperty("sim/flightmodel2/wing/flap1_deg[0]")) -- inner flaps left
defineProperty("flap_inn_R", globalProperty("sim/flightmodel2/wing/flap1_deg[1]")) -- inner flaps right
defineProperty("flap_out_L", globalProperty("sim/flightmodel2/wing/flap2_deg[4]")) -- outer flaps left
defineProperty("flap_out_R", globalProperty("sim/flightmodel2/wing/flap2_deg[5]")) -- outer flaps right
defineProperty("sim_flap_time", globalProperty("sim/aircraft/controls/acf_flap_deftime")) -- time for full flap cycle

-- tail
defineProperty("elevator_L", globalProperty("sim/flightmodel/controls/mwing02_elv1def")) -- deg, positive = trailing-edge down
defineProperty("elevator_R", globalProperty("sim/flightmodel/controls/mwing01_elv1def")) -- deg, positive = trailing-edge down
defineProperty("rudder", globalProperty("sim/flightmodel/controls/mwing08_rud1def"))

-- AP mechanics command datarefs
defineProperty("ap_roll_comm", globalProperty("an-24/ap/ap_roll_comm"))
defineProperty("ap_pitch_comm", globalProperty("an-24/ap/ap_pitch_comm"))
defineProperty("ap_yaw_comm", globalProperty("an-24/ap/ap_yaw_comm"))

-- AP channel enable flags — written by ap28_logic.lua.
-- Determine when the AP should physically act on the aircraft.
defineProperty("ap_roll_power", globalProperty("an-24/ap/ap_roll_power"))
defineProperty("ap_pitch_power", globalProperty("an-24/ap/ap_pitch_power"))
defineProperty("ap_hdg_power", globalProperty("an-24/ap/ap_hdg_power"))

-- yoke position datarefs (animated yoke in 3D cockpit)
defineProperty("yoke_pitch", globalProperty("an-24/controls/yoke_pitch")) -- commanded pitch: -1 = down, +1 = up
defineProperty("yoke_roll", globalProperty("an-24/controls/yoke_roll")) -- commanded roll:  -1 = left, +1 = right
defineProperty("yoke_yaw", globalProperty("an-24/controls/yoke_yaw")) -- commanded yaw:   -1 = left, +1 = right
defineProperty("hide_yokes", globalProperty("an-24/misc/hide_yokes")) -- show/hide yokes

-- FIX: override must be 0, as Parshukoff originally had it.
-- With override=1 the script controls surfaces directly (bad: cuts commands);
-- with override=0 surfaces are managed by standard X-Plane, and the script only animates.
set(overr, 0)

-- XP12 AUTOPILOT: enable override_artstab so we can write AP commands into it.
-- XP12 will sum our artstab with joystick → physical control.
set(override_artstab, 1)
set(artstab_pitch, 0)
set(artstab_roll, 0)
set(artstab_heading, 0)

local ail_actual_L = 0
local ail_actual_R = 0
local elevator_actual = 0
local rudder_actual = 0
local sync_counter = 0

-- CWS state: current "AP authority factor" per channel.
-- 1.0 = AP at full authority, CWS_REDUCTION = pilot is intervening.
-- Changes smoothly between these values.
local cws_roll_factor = 1.0
local cws_pitch_factor = 1.0
local cws_yaw_factor = 1.0

toggle_yoke_command = findCommand("sim/operation/toggle_yoke")

function toggle_yoke_handler(phase)
    if 0 == phase then
        set(hide_yokes, math.abs(get(hide_yokes) - 1))
    end
    return 0
end

registerCommandHandler(toggle_yoke_command, 0, toggle_yoke_handler)

function update()
    -- FIX: override = 0, standard X-Plane control via *_ratio
    set(overr, 0)
    -- XP12: keep override_artstab = 1 for AP via artstab channel
    set(override_artstab, 1)

    local passed = get(frame_time)
    local IAS = get(airspeed)

    -- Trim influence remains speed-dependent (standard for the model)
    local trimm_infuence = math.min(1, math.abs(IAS) / 100)

    -------------------------------------------------------
    -- AILERONS — surface animation only
    -- Physics are handled by standard X-Plane via roll_ratio
    -------------------------------------------------------
    -- Speed-dependent control weight (An-24 has no boosters).
    -- IMPORTANT: read yoke_roll_in (direct joystick), not roll_ratio (with stability
    -- augmentation), to avoid feedback loop when writing AP command back into roll_ratio.
    local ail_coef = math.max(0.4, 1 - (IAS / 500) ^ 2)
    local roll_wheel = get(yoke_roll_in) * ail_coef

    -- CWS: if pilot moves yoke beyond threshold, smoothly reduce AP authority
    local pilot_roll_input = math.abs(get(yoke_roll_in))
    if pilot_roll_input > CWS_THRESHOLD then
        -- pilot intervening → quickly reduce AP to CWS_REDUCTION
        cws_roll_factor = cws_roll_factor + (CWS_REDUCTION - cws_roll_factor) * passed * 5
    else
        -- pilot released → smoothly restore full AP authority
        cws_roll_factor = cws_roll_factor + (1.0 - cws_roll_factor) * passed / CWS_RECOVERY_TIME
    end

    -- XP12: amplify AP command by selected gain and CWS factor
    local ap_roll_amplified = get(ap_roll_comm) * AP_ROLL_GAIN * cws_roll_factor
    if ap_roll_amplified > 1 then
        ap_roll_amplified = 1
    end
    if ap_roll_amplified < -1 then
        ap_roll_amplified = -1
    end
    local roll_comm = roll_wheel + get(aileron_trim) * 0.5 * trimm_infuence + ap_roll_amplified

    if roll_comm > 1 then
        roll_comm = 1
    end
    if roll_comm < -1 then
        roll_comm = -1
    end

    set(yoke_roll, roll_comm)

    -- XP12 AUTOPILOT: write AP command to artstab_roll (NOT roll_ratio!).
    -- artstab is summed by X-Plane with joystick command → real physical control.
    -- AP channel off → artstab = 0, X-Plane controlled by joystick only.
    if math.abs(get(ap_roll_comm)) > 0.001 then
        set(artstab_roll, ap_roll_amplified)
    else
        set(artstab_roll, 0)
    end

    local left_ail_deg = 0
    local right_ail_deg = 0
    if roll_comm > 0.001 then -- roll right
        left_ail_deg = math.min(roll_comm * 16, 16)
        right_ail_deg = -math.min(roll_comm * 24, 24)
    elseif roll_comm < -0.001 then -- roll left
        right_ail_deg = -math.max(roll_comm * 16, -16)
        left_ail_deg = math.max(roll_comm * 24, -24)
    else
        left_ail_deg = 0
        right_ail_deg = 0
    end

    -- Smoothing for animation
    ail_actual_L = ail_actual_L + (left_ail_deg - ail_actual_L) * passed * 10
    ail_actual_R = ail_actual_R + (right_ail_deg - ail_actual_R) * passed * 10
    set(ail_set_L, ail_actual_L)
    set(ail_set_R, ail_actual_R)

    -------------------------------------------------------
    -- ELEVATOR — surface animation only
    -- Physics are handled by standard X-Plane via pitch_ratio
    -------------------------------------------------------
    -- Speed-dependent control weight.
    -- IMPORTANT: read yoke_pitch_in (direct joystick), not pitch_ratio.
    local elev_coef = math.max(0.35, 1 - (IAS / 450) ^ 2)
    local pitch_wheel = get(yoke_pitch_in) * elev_coef

    -- CWS for pitch
    local pilot_pitch_input = math.abs(get(yoke_pitch_in))
    if pilot_pitch_input > CWS_THRESHOLD then
        cws_pitch_factor = cws_pitch_factor + (CWS_REDUCTION - cws_pitch_factor) * passed * 5
    else
        cws_pitch_factor = cws_pitch_factor + (1.0 - cws_pitch_factor) * passed / CWS_RECOVERY_TIME
    end

    -- XP12: amplify AP command by gain and CWS factor
    local ap_pitch_amplified = get(ap_pitch_comm) * AP_PITCH_GAIN * cws_pitch_factor
    if ap_pitch_amplified > 1 then
        ap_pitch_amplified = 1
    end
    if ap_pitch_amplified < -1 then
        ap_pitch_amplified = -1
    end
    local pitch_comm = pitch_wheel + get(elevator_trim) * 0.5 * trimm_infuence + ap_pitch_amplified

    if pitch_comm > 1 then
        pitch_comm = 1
    end
    if pitch_comm < -1 then
        pitch_comm = -1
    end

    set(yoke_pitch, pitch_comm)

    -- XP12 AUTOPILOT: write AP command to artstab_pitch
    if math.abs(get(ap_pitch_comm)) > 0.001 then
        set(artstab_pitch, ap_pitch_amplified)
    else
        set(artstab_pitch, 0)
    end

    -- Elevator deflection angles (Parshukoff original convention)
    -- pitch_comm > 0 (yoke pulled back) → elevator UP (nose up)
    -- pitch_comm < 0 (yoke pushed forward) → elevator DOWN (nose down)
    local elevator_deg = 0
    if pitch_comm < -0.001 then
        elevator_deg = -pitch_comm * 15
    elseif pitch_comm > 0.001 then
        elevator_deg = -pitch_comm * 30
    else
        elevator_deg = 0
    end

    -- Smoothing for elevator animation
    elevator_actual = elevator_actual + (elevator_deg - elevator_actual) * passed * 10
    set(elevator_L, elevator_actual)
    set(elevator_R, elevator_actual)

    -------------------------------------------------------
    -- RUDDER — surface animation only, pedals only (authentic An-24)
    -- Physics are handled by standard X-Plane via head_ratio
    -------------------------------------------------------
    -- The real AP-28 is a TWO-CHANNEL autopilot (pitch + bank).
    -- Course is held by BANK (ailerons) via ap28_logic.
    -- The rudder is operated by the pilot with pedals in flight —
    -- the autopilot does NOT touch the rudder. This eliminates two bugs:
    --  1) rudder does not move on its own in manual mode (no AP contribution or drift)
    --  2) pedals do not stick in a deflected position after AP disengage
    -- IMPORTANT: read yoke_heading_in (direct joystick), not head_ratio.
    local yaw_coef = math.max(0.4, 1 - (IAS / 500) ^ 2)
    local yaw_wheel = get(yoke_heading_in) * yaw_coef

    -- CWS factor for yaw — kept for symmetry (does not affect rudder since AP
    -- never writes to it, but the variable is used in the logic below).
    local pilot_yaw_input = math.abs(get(yoke_heading_in))
    if pilot_yaw_input > CWS_THRESHOLD then
        cws_yaw_factor = cws_yaw_factor + (CWS_REDUCTION - cws_yaw_factor) * passed * 5
    else
        cws_yaw_factor = cws_yaw_factor + (1.0 - cws_yaw_factor) * passed / CWS_RECOVERY_TIME
    end

    -- Rudder = pedals + rudder trim. NO autopilot contribution.
    -- (AP-28 holds course via bank in ap28_logic; does not touch rudder in flight —
    --  as on the real An-24 where the pilot operates the rudder with pedals.)
    local yaw_comm = yaw_wheel + get(rudder_trim) * 0.5 * trimm_infuence

    if yaw_comm > 1 then
        yaw_comm = 1
    end
    if yaw_comm < -1 then
        yaw_comm = -1
    end

    set(yoke_yaw, yaw_comm)

    -- AP NEVER writes to artstab_heading — rudder is pilot-only.
    -- This prevents both jitter in manual mode and pedal sticking after AP.
    set(artstab_heading, 0)

    local yav_deg = yaw_comm * 25
    -- Smoothing for rudder animation.
    -- When pedals are at neutral (yaw_comm ~= 0) the rudder smoothly returns to 0
    -- (does not stick in a deflected position).
    rudder_actual = rudder_actual + (yav_deg - rudder_actual) * passed * 5
    set(rudder, rudder_actual)
end

function onAvionicsDone()
    set(overr, 0)
    -- Reset artstab on exit, disable override
    set(artstab_pitch, 0)
    set(artstab_roll, 0)
    set(artstab_heading, 0)
    set(override_artstab, 0)
    print("flight controls released")
end
