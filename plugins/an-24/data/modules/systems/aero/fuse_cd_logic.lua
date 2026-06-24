--[[

  File: fuse_cd_logic.lua
  -----
  Fuselage drag correction vs altitude (V11/v12)

  Tunes the aircraft speed at different altitudes to the RLE by adjusting the
  fuselage drag coefficient (acf_fuse_cd). The engine power and aerodynamics
  are calibrated to the RLE, but XP12 drag computation differs from reality —
  especially at altitude where air density is lower. This module interpolates
  a small correction over an altitude table.

  Calibration method (standard atmosphere, level cruise at 52 deg UPRT):
  measure stabilised IAS/TAS at the control altitudes, compare to the RLE
  (main checkpoint: 6000 m, TAS 460 / IAS ~325), then raise fuse_cd where the
  aircraft is too fast and lower it where too slow.

  Rollback: remove fuse_cd_logic from the component list in main.lua and the
  base value from the .acf is restored.

--]] 

defineProperty("fcd_alt_m", globalProperty("sim/flightmodel/position/elevation")) -- metres MSL
defineProperty("fcd_fuse_cd", globalProperty("sim/aircraft/bodies/acf_fuse_cd")) -- writable
defineProperty("fcd_frame_time", globalProperty("an-24/time/frame_time"))

-- Altitude (m) -> fuse_cd. Tenth iteration — final calibration against RLE
-- table 8 / chart 79 (RLE targets: Vy 7.8 m/s at 0 m / 3.0 m/s at 6000 m at
-- 21000 kg; cruise 6000 m IAS ~325; ceiling at 52 deg UPRT ~6500-7000 m).
-- Low altitudes heavily increased to bleed off excess speed; 5000-6000 m
-- relaxed (was an IAS dip); 7000 m+ near the base value so engine power
-- itself limits the ceiling.
local fuse_cd_table = { -- {altitude_m, fuse_cd}
    {-500, 0.410}, -- below sea level (margin)
    {0, 0.410}, -- sea level
    {1000, 0.390}, 
    {2000, 0.360}, -- strengthened to slow down to ~360 km/h
    {3000, 0.300}, 
    {4000, 0.240}, 
    {5000, 0.120}, -- moderate (there was an IAS dip here)
    {6000, 0.060}, -- near base — let it fly free (target IAS 325)
    {7000, 0.030}, -- base — at the ceiling power is the limit anyway
    {8000, 0.030}, 
    {9000, 0.030}, 
    {10000, 0.030}, 
    {15000, 0.030}
}

local function interpolate_table(tbl, x)
    if x <= tbl[1][1] then
        return tbl[1][2]
    end
    if x >= tbl[#tbl][1] then
        return tbl[#tbl][2]
    end

    for i = 1, #tbl - 1 do
        local x1, y1 = tbl[i][1], tbl[i][2]
        local x2, y2 = tbl[i + 1][1], tbl[i + 1][2]
        if x >= x1 and x <= x2 then
            local t = (x - x1) / (x2 - x1)
            return y1 + t * (y2 - y1)
        end
    end

    return tbl[#tbl][2]
end

-- Light smoothing so fuse_cd follows altitude changes without jumps; at a
-- ~5 m/s climb the difference is imperceptible.
local current_fuse_cd = 0.025
local FCD_SMOOTH_RATE = 0.5 -- rate per second — smooth response over ~2 s

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

function update()
    local dt = get(fcd_frame_time)
    if dt <= 0 then
        return
    end

    local alt = get(fcd_alt_m)
    local target_fuse_cd = interpolate_table(fuse_cd_table, alt)
    current_fuse_cd = lowpass(current_fuse_cd, target_fuse_cd, FCD_SMOOTH_RATE, dt)
    set(fcd_fuse_cd, current_fuse_cd)
end
