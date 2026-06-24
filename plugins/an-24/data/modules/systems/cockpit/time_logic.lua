-- this is time logic for all scripts
-- XP12 FIX: more robust frame_time calculation with pause detection and diagnostics
-- sim time
defineProperty("M", globalProperty("sim/flightmodel/position/M")) -- some momentum of aircraft. it's remein one value, when sim paused
defineProperty("sim_run_time", globalProperty("sim/time/total_running_time_sec")) -- sim time
defineProperty("sim_paused", globalProperty("sim/time/paused")) -- XP pause state (0 = running, 1 = paused)

defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- flight time

-- XP12 FIX: initialize time_last lazily on first update() call,
-- not at script load time (when sim time may not be ready yet)
local time_last = -1
local first_run = true

-- diagnostic: print frame_time every 5 sec to see if script is alive
local diag_counter = 0
local diag_interval = 5.0

function update()
    local time_now = get(sim_run_time)

    -- XP12 FIX: lazy init on first real update
    if first_run then
        time_last = time_now
        first_run = false
        set(frame_time, 0) -- safe default for first frame
        return
    end

    -- XP12 FIX: if sim is paused, frame_time = 0 so dependent scripts pause too
    if get(sim_paused) == 1 then
        set(frame_time, 0)
        time_last = time_now
        return
    end

    -- normal frame time calculation
    local passed = math.abs(time_now - time_last)

    -- safety clamp: limit huge jumps (loading, slow frame, etc.)
    if passed > 0.1 then
        passed = 0.1
    end

    set(frame_time, passed)
    time_last = time_now
end
