-- ═══════════════════════════════════════════════════════════════════════════
-- AGD (AGB) — REAL ATTITUDE INDICATOR WITH ERRORS
-- ═══════════════════════════════════════════════════════════════════════════
-- On the real An-24, the AGD-1 attitude indicator (electro-mechanical gyro instrument)
-- has errors:
--   • SLOW GYRO DRIFT — small deviation from true angle
--     accumulates over time (up to ±2-3° per 30-60 minutes of flight)
--   • APPARENT BANK FROM ACCELERATION — when aircraft accelerates/decelerates
--     gyro shows false bank (this is a known AGD problem)
--   • CORRECTION — ARREST button resets drift (instantly brings
--     instrument to true values)
--
-- Controlled via switches in aircraft settings menu:
--   • an-24/set/real_ahz = 1 → errors ON (realistic behavior)
--   • an-24/set/real_ahz = 0 → ideal attitude indicator (simplified)
--   • an-24/set/left_agd_arrest, right_agd_arrest — ARREST buttons for
--     quick drift correction (hold button = reset error)
--
-- Script writes corrected values to custom datarefs:
--   an-24/gauges/agd_pitch_left, agd_roll_left   (for pilot)
--   an-24/gauges/agd_pitch_right, agd_roll_right (for copilot)
-- 3D instrument model in cockpit reads these custom datarefs.
-- ═══════════════════════════════════════════════════════════════════════════
-- True aircraft angles (from XP12 physics)
defineProperty("real_pitch", globalProperty("sim/flightmodel/position/theta")) -- pitch, °
defineProperty("real_roll", globalProperty("sim/flightmodel/position/phi")) -- roll, °

-- Accelerations for simulating apparent bank
defineProperty("acc_x", globalProperty("sim/flightmodel/position/local_ax")) -- longitudinal acceleration
defineProperty("acc_z", globalProperty("sim/flightmodel/position/local_az")) -- lateral acceleration

-- Realism setting
defineProperty("set_real_ahz", globalProperty("an-24/set/real_ahz"))

-- ARREST buttons (quick drift correction)
defineProperty("left_arrest", globalProperty("an-24/set/left_agd_arrest"))
defineProperty("right_arrest", globalProperty("an-24/set/right_agd_arrest"))

-- Power (for failure on power loss)
defineProperty("bus_DC", globalProperty("an-24/power/bus_DC_27_volt"))

-- Custom datarefs — instrument readings on panel
defineProperty("agd_pitch_left", globalProperty("an-24/gauges/agd_pitch_left"))
defineProperty("agd_roll_left", globalProperty("an-24/gauges/agd_roll_left"))
defineProperty("agd_pitch_right", globalProperty("an-24/gauges/agd_pitch_right"))
defineProperty("agd_roll_right", globalProperty("an-24/gauges/agd_roll_right"))

-- Frame time
defineProperty("frame_time", globalProperty("sim/operation/misc/frame_rate_period"))

-- ═══════════════════════════════════════════════════════════════════════════
-- DRIFT STATE VARIABLES (for each AGD separately)
-- ═══════════════════════════════════════════════════════════════════════════

-- Accumulated drift (slowly grows over time)
local drift_pitch_L = 0 -- left AGD pitch drift, °
local drift_roll_L = 0 -- left AGD roll drift, °
local drift_pitch_R = 0 -- right AGD pitch drift, °
local drift_roll_R = 0 -- right AGD roll drift, °

-- Random drift direction (chosen once and then preserved)
-- Each instrument drifts its own way — realistic
local drift_dir_pitch_L = (math.random() - 0.5) * 2 -- from -1 to +1
local drift_dir_roll_L = (math.random() - 0.5) * 2
local drift_dir_pitch_R = (math.random() - 0.5) * 2
local drift_dir_roll_R = (math.random() - 0.5) * 2

-- Drift rate: up to 2-3° per 60 minutes = ~0.05°/min = ~0.00083°/sec
-- Random per instrument in range 0.0005-0.0010°/sec
local DRIFT_RATE = 0.00083

-- Apparent bank smoothing (low-pass filter for accelerations)
local apparent_roll = 0 -- smoothed lateral acceleration → apparent bank
local apparent_pitch = 0 -- smoothed longitudinal acceleration → apparent pitch

-- Save arrest button state (press edge detection)
local left_arrest_last = 0
local right_arrest_last = 0

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN FUNCTION — executed every frame
-- ═══════════════════════════════════════════════════════════════════════════

function update()
    local dt = get(frame_time)
    if dt <= 0 then
        return
    end -- protection against pause

    local pitch_true = get(real_pitch)
    local roll_true = get(real_roll)
    local real_mode = get(set_real_ahz) == 1
    local powered = get(bus_DC) > 21 -- AGD works only with power

    -- ─── FAILURE ON POWER LOSS ───
    -- AGD-1 — electro-mechanical, tilts over without power
    -- (gradually loses angle at ~3°/sec, simulates slow topple)
    if not powered then
        -- When de-energized the instrument does not show true angles.
        -- Here we leave the last values 'frozen' — gyroscope
        -- continues to spin by inertia but does not correct position without power.
        return
    end

    if real_mode then
        -- ═══ REAL MODE — WITH ERRORS ═══

        -- 1. DRIFT ACCUMULATION (slow, in its own direction)
        drift_pitch_L = drift_pitch_L + DRIFT_RATE * drift_dir_pitch_L * dt
        drift_roll_L = drift_roll_L + DRIFT_RATE * drift_dir_roll_L * dt
        drift_pitch_R = drift_pitch_R + DRIFT_RATE * drift_dir_pitch_R * dt
        drift_roll_R = drift_roll_R + DRIFT_RATE * drift_dir_roll_R * dt

        -- Limit drift to maximum ±3°
        local function limit_drift(d)
            if d > 3.0 then
                return 3.0
            elseif d < -3.0 then
                return -3.0
            else
                return d
            end
        end
        drift_pitch_L = limit_drift(drift_pitch_L)
        drift_roll_L = limit_drift(drift_roll_L)
        drift_pitch_R = limit_drift(drift_pitch_R)
        drift_roll_R = limit_drift(drift_roll_R)

        -- 2. APPARENT BANK FROM ACCELERATION
        -- When accelerating (acc_x < 0 — forward) gyro shows false bank
        -- Smoothed with low-pass filter — real gyro is inertial
        local target_apparent_roll = get(acc_z) * 0.5 -- lateral → bank
        local target_apparent_pitch = -get(acc_x) * 0.3 -- longitudinal → pitch (nose up when accelerating)

        -- First-order filter: tau ~2 sec
        local k = math.min(dt / 2.0, 1.0)
        apparent_roll = apparent_roll + (target_apparent_roll - apparent_roll) * k
        apparent_pitch = apparent_pitch + (target_apparent_pitch - apparent_pitch) * k

        -- Limit apparent bank ±5°
        if apparent_roll > 5.0 then
            apparent_roll = 5.0
        end
        if apparent_roll < -5.0 then
            apparent_roll = -5.0
        end
        if apparent_pitch > 3.0 then
            apparent_pitch = 3.0
        end
        if apparent_pitch < -3.0 then
            apparent_pitch = -3.0
        end

        -- 3. ARREST BUTTONS (quick drift correction)
        local left_arrest_now = get(left_arrest)
        local right_arrest_now = get(right_arrest)

        -- On press (edge 0→1) reset drift for this instrument
        if left_arrest_now == 1 and left_arrest_last == 0 then
            drift_pitch_L = 0
            drift_roll_L = 0
        end
        if right_arrest_now == 1 and right_arrest_last == 0 then
            drift_pitch_R = 0
            drift_roll_R = 0
        end
        left_arrest_last = left_arrest_now
        right_arrest_last = right_arrest_now

        -- 4. FINAL READINGS = true angle + drift + apparent
        set(agd_pitch_left, pitch_true + drift_pitch_L + apparent_pitch)
        set(agd_roll_left, roll_true + drift_roll_L + apparent_roll)
        set(agd_pitch_right, pitch_true + drift_pitch_R + apparent_pitch)
        set(agd_roll_right, roll_true + drift_roll_R + apparent_roll)

    else
        -- ═══ IDEAL MODE — WITHOUT ERRORS (simplified) ═══
        -- Show true angles one-to-one
        set(agd_pitch_left, pitch_true)
        set(agd_roll_left, roll_true)
        set(agd_pitch_right, pitch_true)
        set(agd_roll_right, roll_true)

        -- When realistic mode is off, reset accumulated drift
        -- (so when switched back on, instrument starts from zero)
        drift_pitch_L = 0
        drift_roll_L = 0
        drift_pitch_R = 0
        drift_roll_R = 0
    end
end
