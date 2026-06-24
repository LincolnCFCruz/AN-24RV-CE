--[[

  File: n1_vibration.lua
  -----
  N1 tachometer needle shake during AI-24 start (V11, v2 — phased realism)

  Emulates the real tachometer behaviour during engine start:
    Phase 1: needle KICKS energetically 0 -> 10% (starter impulse)
    Phase 2: returns towards 0 (rotor load after the impulse)
    Phase 3: climb 0 -> 23% with HIGH shake amplitude (unstable combustion)
    Phase 4: amplitude decays towards 23% (stabilisation)
    Above 23%: smooth climb without shake

  Safety: active only while the starter is engaged and N1 < 23%; affects the
  displayed value only, not engine physics. Rollback: remove n1_vibration
  from the component list in main.lua.

--]] 

defineProperty("n1v_starter_l", globalProperty("sim/cockpit2/engine/actuators/starter_hit[0]"))
defineProperty("n1v_starter_r", globalProperty("sim/cockpit2/engine/actuators/starter_hit[1]"))
defineProperty("n1v_n1_left", globalProperty("sim/flightmodel/engine/ENGN_N1_[0]"))
defineProperty("n1v_n1_right", globalProperty("sim/flightmodel/engine/ENGN_N1_[1]"))
defineProperty("n1v_frame_time", globalProperty("an-24/time/frame_time"))

-- Phase parameters
local VIBRATION_THRESHOLD = 23 -- below this N1 the effects are active
local INITIAL_SPIKE_MAX = 10 -- maximum of the phase-1 needle kick
local SPIKE_DURATION = 0.5 -- kick duration (s)
local RETURN_DURATION = 1.0 -- return-to-0 duration (s)
local VIBRATION_AMPLITUDE = 4.0 -- maximum shake amplitude (+-4%)
local VIBRATION_FREQ = 10.0 -- oscillation frequency (Hz)

-- Per-engine state
local engines = {
    { -- engine 0 (left)
        phase = 0, -- sine phase
        spike_timer = 0, -- time since starter engagement (kick phases)
        starter_was_on = false -- starter state in the previous frame
    }, 
    { -- engine 1 (right)
        phase = math.pi / 3, -- slight offset
        spike_timer = 0,
        starter_was_on = false
    }
}

local function process_engine(eng, starter, n1, dt, n1_dataref)
    -- Advance the sine phase
    eng.phase = eng.phase + dt * VIBRATION_FREQ * 2 * math.pi

    -- Reset the timer when the starter engages
    if starter == 1 and not eng.starter_was_on then
        eng.spike_timer = 0
    end
    eng.starter_was_on = (starter == 1)

    -- No starter or N1 above the threshold — do not interfere
    if starter ~= 1 or n1 >= VIBRATION_THRESHOLD then
        return
    end

    eng.spike_timer = eng.spike_timer + dt

    local n1_displayed = n1

    -- Phase 1: energetic kick 0 -> 10%
    if eng.spike_timer < SPIKE_DURATION then
        local t = eng.spike_timer / SPIKE_DURATION -- 0 -> 1
        local spike = INITIAL_SPIKE_MAX * (t * t) * (3 - 2 * t) -- smoothstep
        n1_displayed = n1 + spike

        -- Phase 2: needle falls back towards 0
    elseif eng.spike_timer < SPIKE_DURATION + RETURN_DURATION then
        local t = (eng.spike_timer - SPIKE_DURATION) / RETURN_DURATION -- 0 -> 1
        local return_val = INITIAL_SPIKE_MAX * (1 - t) * (1 - t)
        n1_displayed = n1 + return_val

        -- Phases 3-4: climb with shake, amplitude decaying towards 23%
    else
        -- Two sines plus random noise
        local vibration = math.sin(eng.phase) * VIBRATION_AMPLITUDE + math.sin(eng.phase * 1.7) * VIBRATION_AMPLITUDE *
                              0.5 + (math.random() - 0.5) * VIBRATION_AMPLITUDE * 0.4

        -- Damping as N1 grows (full at N1=0, zero at N1=23)
        local damping = 1.0 - (n1 / VIBRATION_THRESHOLD)
        if damping < 0 then
            damping = 0
        end

        n1_displayed = n1 + vibration * damping
    end

    if n1_displayed < 0 then
        n1_displayed = 0
    end

    set(n1_dataref, n1_displayed)
end

function update()
    -- nil protection
    local starter_l = get(n1v_starter_l)
    local starter_r = get(n1v_starter_r)
    local n1_l = get(n1v_n1_left)
    local n1_r = get(n1v_n1_right)
    local dt = get(n1v_frame_time)

    if starter_l == nil or starter_r == nil then
        return
    end

    if n1_l == nil or n1_r == nil then
        return
    end

    if dt == nil or dt <= 0 then
        return
    end
    
    if dt > 0.1 then
        dt = 0.1
    end -- large-step protection

    process_engine(engines[1], starter_l, n1_l, dt, n1v_n1_left)
    process_engine(engines[2], starter_r, n1_r, dt, n1v_n1_right)
end
