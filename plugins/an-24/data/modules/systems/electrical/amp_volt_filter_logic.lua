--[[

  File: amp_volt_filter.lua
  -----
  Isolated starter gauge filter (V11, "variant B")

  Filters the starter current/voltage produced by start_logic.lua before they
  reach the left panel gauges. Fixes needle jitter of the ammeter/voltmeter
  under XP12 without touching start_logic.lua itself.

  Pipeline:
    start_logic.lua -> starter_amp / starter_volt   (may jump 470A -> 0 -> 470A)
    amp_volt_filter -> clamps, rate-limits and low-passes the values, then
                       writes them BACK into starter_amp/volt (this component
                       must run AFTER start_logic) and also into the
                       *_filtered datarefs for the 2D panel.

--]] 

-- Inputs — raw values from start_logic.lua:
defineProperty("starter_amp_in", globalProperty("an-24/start/starter_amp"))
defineProperty("starter_volt_in", globalProperty("an-24/start/starter_volt"))

-- Outputs — smoothed values for the gauges:
defineProperty("starter_amp_filtered", globalProperty("an-24/start/starter_amp_filtered"))
defineProperty("starter_volt_filtered", globalProperty("an-24/start/starter_volt_filtered"))

-- Frame time (FPS-independent smoothing)
defineProperty("avf_frame_time", globalProperty("an-24/time/frame_time"))

-- Filter parameters
local FILTER_RATE = 1.0 -- smoothing rate per second (~1 s full travel)

-- Spike protection: if the source jumps more than MAX_JUMP per frame
-- (start_logic can emit 470A -> 0A -> 470A across rpm phase boundaries),
-- only a limited change is taken.
local AMP_MAX_JUMP = 100 -- A per frame
local VOLT_MAX_JUMP = 10 -- V per frame

-- Scale limits (needles must not leave the dial):
local AMP_MIN = 0 -- A
local AMP_MAX = 1000 -- A — "8 x 100A" scale maximum
local VOLT_MIN = 0 -- V
local VOLT_MAX = 65 -- V — practical maximum (RLE start norm is ~60V)

local amp_filtered = 0 -- current smoothed amperage
local volt_filtered = 0 -- current smoothed voltage

-- Intermediate values after rate limiting (before the lowpass)
local amp_rate_limited = 0
local volt_rate_limited = 0

local function clamp(value, min_val, max_val)
    if value < min_val then
        return min_val
    end
    if value > max_val then
        return max_val
    end
    return value
end

-- First-order lowpass; dt capped so FPS lags do not make the needle jump
local function lowpass(current, target, rate, dt)
    if dt > 0.05 then
        dt = 0.05
    end
    if dt < 0 then
        dt = 0
    end
    local k = rate * dt
    if k > 1 then
        k = 1
    end
    return current + (target - current) * k
end

-- Rate limiter: take at most max_change per frame towards the target
local function rate_limit(current, target, max_change)
    local diff = target - current
    if diff > max_change then
        return current + max_change
    elseif diff < -max_change then
        return current - max_change
    else
        return target
    end
end

function update()
    local dt = get(avf_frame_time)
    if dt <= 0 then
        return
    end -- pause / first frame protection

    -- 1: raw values from start_logic
    local amp_raw = get(starter_amp_in)
    local volt_raw = get(starter_volt_in)

    -- 2: clamp to the allowed scale range
    amp_raw = clamp(amp_raw, AMP_MIN, AMP_MAX)
    volt_raw = clamp(volt_raw, VOLT_MIN, VOLT_MAX)

    -- 3: rate-limit source spikes
    amp_rate_limited = rate_limit(amp_rate_limited, amp_raw, AMP_MAX_JUMP)
    volt_rate_limited = rate_limit(volt_rate_limited, volt_raw, VOLT_MAX_JUMP)

    -- 4: lowpass for the final smoothness
    amp_filtered = lowpass(amp_filtered, amp_rate_limited, FILTER_RATE, dt)
    volt_filtered = lowpass(volt_filtered, volt_rate_limited, FILTER_RATE, dt)

    -- 5: final clamp — guarantee in-range output
    amp_filtered = clamp(amp_filtered, AMP_MIN, AMP_MAX)
    volt_filtered = clamp(volt_filtered, VOLT_MIN, VOLT_MAX)

    -- 6: write the smoothed values BACK into the original datarefs.
    -- This component is registered AFTER start_logic, so it overwrites the
    -- values each frame; the 3D cockpit ammeter reads starter_amp/volt
    -- directly and now gets smooth values automatically.
    set(starter_amp_in, amp_filtered)
    set(starter_volt_in, volt_filtered)

    -- Also publish to *_filtered for the 2D panel compatibility.
    set(starter_amp_filtered, amp_filtered)
    set(starter_volt_filtered, volt_filtered)
end
