--[[

  File: autofeather_logic.lua
  -----
  Automatic propeller feathering (per the An-24RV RLE, AI-24 series 2) — V11

  System 1 — by IKM (torque meter oil pressure) drop:
    fires on an engine failure at high UPRT regimes. Failure signature:
    RPM collapse while the throttle lever stays high.
  System 2 — by negative thrust: DISABLED in v11.2 (transients during UPRT
    changes produce negative thrust that is NOT a failure; System 1 by N1 is
    far more reliable and a real failure always drops N1 below its threshold).

  When fired: prop goes to FEATHER (ENGN_propmode = 0) and the "Engine
  failure" lamp in the KFL-37 button lights up.

  Blocked (per RLE): during start/shutdown (low RPM), on the ground, and
  below the UPRT threshold. The module only intervenes on an EXPLICIT
  failure; in normal flight it does nothing.

--]] 

-- Engine state (XP12):
defineProperty("af_n1_left", globalProperty("sim/flightmodel/engine/ENGN_N1_[0]")) -- left RPM, %
defineProperty("af_n1_right", globalProperty("sim/flightmodel/engine/ENGN_N1_[1]")) -- right RPM, %
defineProperty("af_thrust_left", globalProperty("sim/flightmodel/engine/POINT_thrust[0]")) -- left thrust, N
defineProperty("af_thrust_right", globalProperty("sim/flightmodel/engine/POINT_thrust[1]")) -- right thrust, N
defineProperty("af_thro_left", globalProperty("sim/flightmodel/engine/ENGN_thro_use[0]")) -- left RUD, 0..1
defineProperty("af_thro_right", globalProperty("sim/flightmodel/engine/ENGN_thro_use[1]")) -- right RUD, 0..1

-- IKM (torque meter oil pressure — custom dataref):
defineProperty("af_ikm_left", globalProperty("an-24/gauges/torque_left"))
defineProperty("af_ikm_right", globalProperty("an-24/gauges/torque_right"))

-- Prop control output (XP12): 0 = feather, 1 = normal
defineProperty("af_propmode_left", globalProperty("sim/flightmodel/engine/ENGN_propmode[0]"))
defineProperty("af_propmode_right", globalProperty("sim/flightmodel/engine/ENGN_propmode[1]"))

defineProperty("af_on_ground", globalProperty("sim/flightmodel/failures/onground_any"))
defineProperty("af_frame_time", globalProperty("an-24/time/frame_time"))

-- KFL-37 "Engine failure" lamps:
defineProperty("af_lamp_left", globalProperty("an-24/prop/feather1_lamp"))
defineProperty("af_lamp_right", globalProperty("an-24/prop/feather2_lamp"))

-- Manual feather buttons (already in the project):
defineProperty("af_button_left", globalProperty("an-24/prop/feather1_button"))
defineProperty("af_button_right", globalProperty("an-24/prop/feather2_button"))

-- ============================================================
-- Tuning (history: see V11_patch changelog; final v11.2 values)
-- ============================================================

-- UPRT thresholds as throttle fraction 0..1 (UPRT 0-100 deg ~ RUD 0-1).
local UPRT_NEG_THRUST = 0.50 -- below this the system is inactive: in descent/
-- cruise the prop may brake from inertia — not a failure
local UPRT_IKM = 0.80 -- System 1 active only at takeoff regimes (>= 80 deg UPRT),
-- where the engine MUST run at full power and low N1 = real failure

-- v11.2 ("percent below idle is far more reliable"): the AI-24 idles at
-- N1 = 75-80%. Threshold = idle - 25% = 50%:
--   running engine  N1 >= 70-80%  -> no trigger
--   transients      N1 >= 60-65%  -> no trigger
--   real failure: flame out, N1 drops fast below 50% -> TRIGGERS
local N1_FAILURE = 50 -- %
local N1_RUNNING = 70 -- % — above this the engine is definitely running

-- Negative thrust threshold (System 2, disabled): transients during climbs
-- above 3000 m can briefly reach -10000 N; only a real prop failure
-- (windmilling) produces more than -15000 N.
local NEG_THRUST_THRESHOLD = -15000 -- N

-- Trigger delays (per RLE):
local DELAY_IKM = 0.5 -- s — IKM system is fast
local DELAY_NEG_THRUST = 6.0 -- s — negative thrust system (5-7 s)

-- Minimum RPM for the system to be armed (below = start/shutdown):
local MIN_N1_ACTIVE = 40 -- %

-- ============================================================
-- Internal state
-- ============================================================

local fail_timer_left = 0
local fail_timer_right = 0

local feathered_left = false
local feathered_right = false

local was_running_left = false
local was_running_right = false

-- Previous-frame UPRT (to detect quick throttle changes) and cooldowns
-- during which the failure detection is suppressed.
local prev_thro_left = 0
local prev_thro_right = 0
local quick_throttle_cooldown_left = 0
local quick_throttle_cooldown_right = 0
local QUICK_THROTTLE_RATE = 0.005 -- per frame; catches even slow lever movements (3 deg/s)
local QUICK_THROTTLE_COOLDOWN = 20.0 -- s; at altitude the engine takes up to ~15 s to spool

-- One-shot log flags
local was_feathered_left_log = false
local was_feathered_right_log = false

-- Returns: new fail_timer, feathered flag, running flag
local function process_engine(n1, thrust, thro, ikm, fail_timer, feathered, dt, on_ground, quick_throttle_cooldown)
    local running = (n1 >= N1_RUNNING)

    -- System blocked: on the ground, during start/shutdown, or below the
    -- UPRT threshold. Timer resets but an already-feathered prop stays so.
    if on_ground == 1 or n1 < MIN_N1_ACTIVE or thro < UPRT_NEG_THRUST then
        return 0, feathered, running
    end

    if feathered then
        return fail_timer, true, running
    end

    local failure_detected = false
    local required_delay = DELAY_IKM

    -- System 1 — by N1/IKM: throttle high but RPM collapsed.
    -- Suppressed during the quick-throttle cooldown: after a fast lever
    -- movement IKM/N1 sag temporarily while the engine stabilises — not a failure.
    if thro >= UPRT_IKM and n1 < N1_FAILURE and quick_throttle_cooldown <= 0 then
        failure_detected = true
        required_delay = DELAY_IKM
    end

    -- System 2 — by negative thrust: DISABLED in v11.2 (see header).
    -- if thro >= UPRT_NEG_THRUST and thrust < NEG_THRUST_THRESHOLD and quick_throttle_cooldown <= 0 then
    --     failure_detected = true
    --     required_delay = DELAY_NEG_THRUST
    -- end

    if failure_detected then
        fail_timer = fail_timer + dt
        if fail_timer >= required_delay then
            return fail_timer, true, running -- FEATHER!
        end
    else
        fail_timer = 0
    end

    return fail_timer, false, running
end

function update()
    local dt = get(af_frame_time)
    if dt <= 0 then
        return
    end

    local on_ground = get(af_on_ground)

    -- Left engine
    local n1_l = get(af_n1_left)
    local thrust_l = get(af_thrust_left)
    local thro_l = get(af_thro_left)
    local ikm_l = get(af_ikm_left)

    -- Quick throttle change detection — both directions: a fast UPRT increase
    -- after a descent leaves N1 lagging ~5-7 s, which used to false-trigger.
    if (prev_thro_left - thro_l) > QUICK_THROTTLE_RATE then
        quick_throttle_cooldown_left = QUICK_THROTTLE_COOLDOWN
    elseif (thro_l - prev_thro_left) > QUICK_THROTTLE_RATE then
        quick_throttle_cooldown_left = QUICK_THROTTLE_COOLDOWN
    else
        quick_throttle_cooldown_left = math.max(0, quick_throttle_cooldown_left - dt)
    end
    prev_thro_left = thro_l

    fail_timer_left, feathered_left, was_running_left = process_engine(n1_l, thrust_l, thro_l, ikm_l, fail_timer_left,
        feathered_left, dt, on_ground, quick_throttle_cooldown_left)

    -- Right engine
    local n1_r = get(af_n1_right)
    local thrust_r = get(af_thrust_right)
    local thro_r = get(af_thro_right)
    local ikm_r = get(af_ikm_right)

    if (prev_thro_right - thro_r) > QUICK_THROTTLE_RATE then
        quick_throttle_cooldown_right = QUICK_THROTTLE_COOLDOWN
    elseif (thro_r - prev_thro_right) > QUICK_THROTTLE_RATE then
        quick_throttle_cooldown_right = QUICK_THROTTLE_COOLDOWN
    else
        quick_throttle_cooldown_right = math.max(0, quick_throttle_cooldown_right - dt)
    end
    prev_thro_right = thro_r

    fail_timer_right, feathered_right, was_running_right = process_engine(n1_r, thrust_r, thro_r, ikm_r,
        fail_timer_right, feathered_right, dt, on_ground, quick_throttle_cooldown_right)

    -- Manual feathering via the KFL-37 overhead buttons.
    -- These are TEST switches meant for ground checks of the autofeather
    -- system; in the air they are ignored (use the An-24/Prop/feather_*
    -- commands for manual feathering in flight).
    if on_ground == 1 then
        if get(af_button_left) == 1 then
            feathered_left = true
            -- print("AUTOFEATHER: left feathered by the KFL-37 test button (on ground)")
        end
        if get(af_button_right) == 1 then
            feathered_right = true
            -- print("AUTOFEATHER: right feathered by the KFL-37 test button (on ground)")
        end
    end

    -- Diagnostics: log every autofeather event once
    if feathered_left and not was_feathered_left_log then
        -- print(string.format("AUTOFEATHER: LEFT feathered! n1=%.1f%%, thrust=%.0fN, UPRT=%.0f%%, IKM=%.1f, on_ground=%d, cooldown=%.1f",
        --    get(af_n1_left), get(af_thrust_left), get(af_thro_left)*100, get(af_ikm_left), on_ground, quick_throttle_cooldown_left))
        was_feathered_left_log = true
    end
    if not feathered_left then
        was_feathered_left_log = false
    end

    if feathered_right and not was_feathered_right_log then
        -- print(string.format("AUTOFEATHER: RIGHT feathered! n1=%.1f%%, thrust=%.0fN, UPRT=%.0f%%, IKM=%.1f, on_ground=%d, cooldown=%.1f",
        --    get(af_n1_right), get(af_thrust_right), get(af_thro_right)*100, get(af_ikm_right), on_ground, quick_throttle_cooldown_right))
        was_feathered_right_log = true
    end
    if not feathered_right then
        was_feathered_right_log = false
    end

    -- Apply: propmode 0 = feather, 1 = normal
    if feathered_left then
        set(af_propmode_left, 0)
        set(af_lamp_left, 1)
    else
        set(af_lamp_left, 0)
    end

    if feathered_right then
        set(af_propmode_right, 0)
        set(af_lamp_right, 1)
    else
        set(af_lamp_right, 0)
    end
end

-- ============================================================
-- Manual feather commands (bind in Settings -> Keyboard/Joystick).
-- Emulate pressing the KFL-37 "Feather" button in the cockpit.
-- ============================================================

registerCommandHandler(createCommand("An-24/Prop/feather_left", "Left propeller: feather (manual)."), 0, function(p)
    if p == 0 then
        feathered_left = true -- immediate, no delay
        set(af_propmode_left, 0)
        set(af_lamp_left, 1)
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Prop/feather_right", "Right propeller: feather (manual)."), 0, function(p)
    if p == 0 then
        feathered_right = true
        set(af_propmode_right, 0)
        set(af_lamp_right, 1)
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Prop/feather_both", "Both propellers: feather (manual)."), 0, function(p)
    if p == 0 then
        feathered_left = true
        set(af_propmode_left, 0)
        set(af_lamp_left, 1)
        feathered_right = true
        set(af_propmode_right, 0)
        set(af_lamp_right, 1)
    end
    return 0
end)

-- ============================================================
-- Unfeather commands — emergency reset without reloading the sim
-- (e.g. after a false trigger or a ground test).
-- NOTE: to physically leave feather the engine must be turning (running or
-- cranked by the starter) — the command only PERMITS the exit.
-- ============================================================

registerCommandHandler(createCommand("An-24/Prop/unfeather_left", "Left propeller: unfeather."), 0, function(p)
    if p == 0 then
        feathered_left = false
        fail_timer_left = 0
        set(af_propmode_left, 1)
        set(af_lamp_left, 0)
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Prop/unfeather_right", "Right propeller: unfeather."), 0, function(p)
    if p == 0 then
        feathered_right = false
        fail_timer_right = 0
        set(af_propmode_right, 1)
        set(af_lamp_right, 0)
    end
    return 0
end)

registerCommandHandler(createCommand("An-24/Prop/unfeather_both", "Both propellers: unfeather."), 0, function(p)
    if p == 0 then
        feathered_left = false
        fail_timer_left = 0
        set(af_propmode_left, 1)
        set(af_lamp_left, 0)
        feathered_right = false
        fail_timer_right = 0
        set(af_propmode_right, 1)
        set(af_lamp_right, 0)
    end
    return 0
end)
