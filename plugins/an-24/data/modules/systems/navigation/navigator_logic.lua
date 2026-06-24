-- Navigator-panel shared compute (single owner).
--
-- Owns the dataref-writing logic (Hard rule 7) so both the 2D and 3D panels are
-- pure render + interaction (they read these datarefs and set the raw *_dir
-- inputs), with no duplicated compute to drift between them.
--
-- Owns:
--   * USH (ushdb_3) scale integration   -- moved from instruments/ush.lua
--   * Radiocompas-big (ushdb_1) scale integration -- moved from navigation/radiocompas_big.lua
--   * CURS-MP cold-start switch reset    -- moved from navigation/curs_mp.lua
-- environment
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
-- SmartCopilot: 0 - not connected/master not set, 1 - master, 2 - slave
defineProperty("ismaster", globalProperty("scp/api/ismaster"))

-- USH-DB scale angles/directions (declared in glbl_drfs.lua; bound here)
defineProperty("ushdb_3_scale_angle", globalProperty("an-24/misc/ushdb_3_scale_angle")) -- USH scale angle
defineProperty("ushdb_3_scale_dir", globalProperty("an-24/misc/ushdb_3_scale_dir")) -- USH scale direction
defineProperty("ushdb_1_scale_angle", globalProperty("an-24/misc/ushdb_1_scale_angle")) -- radiocompas-big scale angle
defineProperty("ushdb_1_scale_dir", globalProperty("an-24/misc/ushdb_1_scale_dir")) -- radiocompas-big scale direction

-- CURS-MP cold-start reset
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("curs_mp1_sw", globalProperty("an-24/gauges/curs_mp1_sw"))
defineProperty("curs_mp2_sw", globalProperty("an-24/gauges/curs_mp2_sw"))

local time_counter = 0
local not_loaded = true

function update()
    local passed = get(frame_time)
    local active_logic = get(ismaster) ~= 1

    -- CURS-MP: on a cold load (engines not running) force both course switches
    -- off, once, in the 0.3..0.4 s startup window. Runs every frame (unguarded),
    -- matching the original curs_mp.lua behaviour.
    time_counter = time_counter + passed
    if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
        set(curs_mp1_sw, 0)
        set(curs_mp2_sw, 0)
        not_loaded = false
    end

    -- time-bug workaround: only integrate on advancing frames, and only when not
    -- a SmartCopilot slave (the master owns the shared scale angle).
    if passed > 0 and active_logic then
        -- USH (ushdb_3) scale: 5 deg/sec, clamped to +-70
        local a3 = get(ushdb_3_scale_angle) + get(ushdb_3_scale_dir) * passed * 5
        if a3 > 70 then
            a3 = 70
        elseif a3 < -70 then
            a3 = -70
        end
        set(ushdb_3_scale_angle, a3)

        -- Radiocompas-big (ushdb_1) scale: 10 deg/sec (no clamp, original behaviour)
        set(ushdb_1_scale_angle, get(ushdb_1_scale_angle) + get(ushdb_1_scale_dir) * passed * 10)
    end
end
