--[[

  File: engine_logic.lua
  -----
  Engine Logic component

--]] local rud_close = gPi(pfx .. "misc/rud_close") -- created in glbl_drfs.lua
local rud_close_ru19 = gPi(pfx .. "misc/rud_close_ru19") -- created in glbl_drfs.lua
local rud_close_pos = gPi(pfx .. "misc/rud_close_pos") -- created in glbl_drfs.lua
local rud_stopor = gPf(pfx .. "misc/rud_stopor") -- created in glbl_drfs.lua
local thro_over = gPi("sim/operation/override/override_throttles")
local prop_RPM = gPf("sim/cockpit2/engine/actuators/prop_rotation_speed_rad_sec_all") -- Propeller RPM, 0 - 130.381622
-- XP12: temperature_ambient_c was replaced by aircraft/temperature_ambient_deg_c
local sim_T = gPf("sim/weather/aircraft/temperature_ambient_deg_c") -- Temperature outside aircraft, deg C
local msl_alt = gPf("sim/flightmodel/position/elevation") -- Barometric alt. maybe in feet, maybe in meters
local agl_alt = gPf("sim/flightmodel/position/y_agl") -- Height above ground, metres (water injection gate)
-- V11: use the pilot's altimeter setting (QNH) for the pressure correction instead of
-- the (REPLACED) sea-level weather dataref. Standard is 29.92 inHg.
local baro_setting = gPf("sim/cockpit/misc/barometer_setting") -- QNH in inHg as set by the pilot
local wing_ht = gPi("sim/cockpit/switches/anti_ice_surf_heat") -- On/off wing heat

local rud1_out = false
local rud2_out = false
local rud3_out = false
local left_rud_last = 0
local right_rud_last = 0
local third_rud_last = 0
local left_rud_need = 0.05
local right_rud_need = 0.05
local ru19_rud_need = 0
local initialized = false
local counter = 0
local water_coef_smooth = 0.0 -- v13: smoothed water-injection recovery term (see water_inject_table)

-- V11: KTA-24 inertia (fuel control unit of the real AI-24).
-- The KTA-24 is a hydromechanical fuel governor with inherent lag: moving the
-- throttle lever does not change fuel flow instantly (~2-3 s to reach a regime).
-- Without this the simulated engine responds far too sharply.
local left_rud_current = 0.05 -- smoothed left engine RUD
local right_rud_current = 0.05 -- smoothed right engine RUD
local KTA24_RATE = 2.5 -- KTA-24 response rate (smaller = slower)

-- Interpolation table for throttles
-- v13 calibration (18-19.08.2026, 50+ test flights): the cruise point is 0.605
-- at 52 deg. The preceding v12 value (0.807) never settled — it kept
-- accelerating past the AFM cruise speed, reaching 559 km/h TAS in the teleport
-- reference test against the AFM's 460-472. 0.605 stabilises at TAS ~472
-- instead. It is bracketed: 0.575 could not hold 6000 m, 0.807 ran away.
-- This value is calibrated TOGETHER with three other things — do not retune one
-- of them in isolation:
--   1. the .acf misc-body drag, now the Bogoslavsky (1972) breakdown of the
--      An-24's Cx0 = 0.0244: fuselage body/0 Cd 0.0831 (30% of Cx0), An-26
--      nacelles body/21,22 Cd 0.0764 (15%), empennage body/1,2,3 Cd 0.0750 (10%);
--   2. alt_table below, which now holds 0.96 from 5000 m through cruise;
--   3. .acf _power_max_limit 2810, with fuse_cd_logic still not overriding
--      acf_fuse_cd at runtime.
-- Low points (0.00-0.18) set the base idle; idle_correction_table then boosts the
-- idle band toward N1 ~94% per the RLE (see Discovery #13 below).
local tro_table = {
    {0.00, 0.180}, --   0 deg UPRT: ground idle
    {0.05, 0.200}, --   5 deg UPRT: transition to idle
    {0.10, 0.200}, --  10 deg UPRT: flight idle (rud_minimum) — boosted by idle_correction_table
    {0.12, 0.220}, --  12 deg UPRT: between idle and taxi
    {0.18, 0.260}, --  18 deg UPRT: taxi low
    {0.22, 0.300}, --  22 deg UPRT: 0.4 nominal (intermediate)
    {0.26, 0.340}, --  26 deg UPRT: taxi high
    {0.34, 0.430}, --  34 deg UPRT: 0.6 nominal (intermediate)
    {0.41, 0.500}, --  41 deg UPRT: 0.7 nominal (intermediate)
    {0.52, 0.605}, --  52 deg UPRT: cruise (v13 — stabilises at TAS ~472, see above)
    {0.65, 0.700}, --  65 deg UPRT: nominal (between RLE 0.850 and old 0.555)
    {0.74, 0.770}, --  74 deg UPRT
    {0.87, 0.850}, --  87 deg UPRT: lower bound of takeoff regime
    {1.00, 0.900} -- 100 deg UPRT: takeoff (between 1.000 and 0.850)
}

-- Table of throttles for Ru19
local tro_table_ru19 = {
    {0.00, -1}, 
    {0.05, 0.10}, 
    {0.12, 0.20}, 
    {0.21, 0.25}, 
    {0.30, 0.35}, 
    {0.40, 0.45}, 
    {0.50, 0.60},
    {0.65, 0.75},
    {0.80, 0.90}, -- 0.8 of nominal
    {1.00, 1.00} -- Nominal
}

-- V11: correct AI-24 temperature correction (per RLE table 7.4).
-- The old table had 1.10 at +50 C — power GREW in the heat, contradicting
-- turboprop physics: cold air is denser (more mass flow, more thrust),
-- hot air is thinner (less thrust). At +30 C takeoff must be harder, not easier.
local t_table = {{-1000, 1.15}, -- BUG workaround (very cold)
    {-30, 1.10}, -- -30 C: dense air, 110% power
    {-10, 1.05}, -- -10 C: 105%
    {0, 1.02}, --   0 C: 102%
    {15, 1.00}, -- +15 C: ISA standard = 100%
    {25, 0.96}, -- +25 C: hot, 96%
    {30, 0.93}, -- +30 C: very hot, 93%
    {40, 0.88}, -- +40 C: tropics, 88%
    {50, 0.83}, -- +50 C: desert, 83%
    {1000, 0.80} -- BUG workaround
}

-- v13 (19.08.2026) — AI-24 WATER INJECTION, per Bogoslavsky L.E. "Prakticheskaya
-- aerodinamika An-24" (Transport, Moscow 1972), the Antonov OKB figures.
--
-- On a hot day the AI-24 loses power to thin air (that is what t_table models).
-- The real engine injects water into the compressor: it evaporates, cools the
-- charge, the denser air restores mass flow, and takeoff power comes back. This
-- table is the recovery term ADDED to t_coef, so it cancels most of t_table's
-- hot-day penalty: at +42 C, t_coef 0.88 + 0.15 = 1.03.
--
-- Automatic arming needs all three of:
--   1. OAT >= +38 C            — hot day
--   2. UPRT >= 95% (takeoff)   — averaged over both engines
--   3. AGL < 50 m              — takeoff roll / initial climb, any airfield
-- Losing any one of them fades the injection back out.
--
-- The 4 s / 3 s fade is the physical lag: water has to heat and evaporate on the
-- way in, and the hot gases have to cool down on the way out (see smooth()).
-- Limit per the RLE: above +45 C injection can no longer restore takeoff power.
local water_inject_table = { -- OAT deg C, power-recovery term added to t_coef
    {15, 0.000}, -- below +38 C: injection off
    {37, 0.000}, -- below +38 C: injection off
    {38, 0.120}, -- +38 C: restores t_coef to ~1.00
    {40, 0.130}, -- +40 C
    {42, 0.150}, -- +42 C
    {44, 0.160}, -- +44 C
    {45, 0.180}, -- +45 C: RLE limit — no recovery beyond this
    {1000, 0.180} -- BUG workaround
}
local WATER_OAT_MIN = 38.0 -- deg C — hot-day threshold
local WATER_RUD_MIN = 0.95 -- UPRT fraction — takeoff regime
local WATER_AGL_MAX = 50.0 -- metres AGL — takeoff roll / initial climb

-- Tables for temp correction
local t_table_ru19 = {{-1000, 1.00}, -- BUG workaround
    {-30, 1.00}, -- -30 C
    {0, 1.00}, -- 0 C
    {15, 1.00}, -- standard temperature
    {50, 1.00}, -- +50 C
    {1000, 1.0} -- BUG workaround
}

-- V11 idle correction (Discovery #13, 11.06.2026): hold ground/flight idle at
-- N1 ~91-94% per the An-24 RLE (Moscow 1995, pp. 53/278/288/290). With the
-- calibrated tro_table alone, UPRT 10% gave only ~66% N1. Rather than disturb the
-- cruise/climb/takeoff calibration, idle is boosted by a temperature-dependent
-- multiplier applied ONLY in the idle band (see idle_blend_factor). In the real
-- An-24 the ADT (fuel metering unit) does this automatically: hot/thin air needs
-- more fuel for the same RPM, cold/dense air needs less.
--   final_throttle = base_tro * ((1 - blend) + blend * idle_boost)
local idle_correction_table = { -- t deg C, idle_boost (multiplier on base tro to hold N1 ~94% at idle)
    {-1000, 2.50}, -- BUG workaround
    {-30, 1.44}, -- -30 C: less boost (dense air)
    {-10, 1.53}, {0, 1.60}, {15, 1.67}, -- +15 C ISA: target boost for N1 = 94%
    {25, 1.71}, -- +25 C: a touch more (compensate thinner air)
    {30, 1.78}, -- +30 C: more boost
    {40, 1.85}, -- +40 C: hot
    {50, 1.97}, -- +50 C: desert
    {1000, 2.80} -- BUG workaround
}

-- Tables for altitude correction
-- V11: raised alt_table so the aircraft can climb to 8000 m like the real An-24
-- (with the old table it barely reached 7000 m). The AI-24 is supercharged and
-- holds nearly 100% power up to its rated altitude ~5000 m, then decays smoothly.
-- v13 (18.08.2026): the 5000-6000 m band is flattened to 0.96 (was 0.95/0.90).
-- Per Bogoslavsky the AI-24's supercharger peaks around 3700 m and the decay
-- above it is far gentler than the old step to 0.90 at cruise altitude; the
-- flat shelf is what lets the aircraft still hold the 6000 m cruise level at
-- the v13 tro_table[0.52] = 0.605. The two were measured together — see the
-- tro_table header.
local alt_table = {{-50000, 1.00}, -- BUG workaround
    {0.00, 0.72}, -- sea level: full power
    {4000, 0.84}, -- ~1200 m
    {8000, 0.96}, -- ~2400 m: holds full power
    {12000, 1.00}, -- ~3700 m: supercharger hump — peak power (Bogoslavsky)
    {16000, 0.96}, -- ~5000 m: rated altitude
    {20000, 0.96}, -- ~6000 m: cruise — still on the shelf
    {24000, 0.84}, -- ~7300 m: moderate decay
    {28000, 0.78}, -- ~8500 m: near the ceiling
    {32000, 0.71}, -- ~9750 m: beyond the ceiling
    {35000, 0.64}, -- above the ceiling
    {100000, 0.50} -- BUG workaround (smooth falloff)
}

-- Tables for altitude correction
local alt_table_ru19 = {{-50000, 1}, -- BUG workaround
    {0.00, 0.8}, -- on standard pressure zero level
    {4000, 0.85}, -- 4000 ft
    {8000, 0.90}, -- 8000 ft
    {13000, 1}, -- 13000 ft
    {100000, -0.5} -- linear above 13000 ft
}

-- For all commands phase (p) equals: 0 on press; 1 while holding; 2 on release
registerCommandHandler(createCommand("An-24/Engine/rud_fix_up", "Engine RUD stoper position up one."), 0, function(p)
    if p == 0 then
        set(rud_close_pos, math.min(5, get(rud_close_pos) + 1))
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Engine/rud_fix_dn", "Engine RUD stoper position down one."), 0, function(p)
    if p == 0 then
        set(rud_close_pos, math.max(0, get(rud_close_pos) - 1))
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Engine/rud_stop", "Engine RUD stoper cap."), 0, function(p)
    if get(drf_set.switch_rud) == 1 then
        if p == 0 then
            set(rud_close, math.abs(1 - get(rud_close)))
        end
    else
        if p == 1 then
            set(rud_close, 1)
        else
            set(rud_close, 0)
        end
    end
    return 0
end)
registerCommandHandler(createCommand("An-24/Engine/rud_stop_ru19", "RU19 RUD stoper cap."), 0, function(p)
    if p == 1 then
        set(rud_close_ru19, 1)
    else
        set(rud_close_ru19, 0)
        if p == 2 then
            if get(rud_close_ru19) == 0 and math.floor(get(drf_engn.thro_comm_3) * 100) * 0.01 == 0 and
                math.floor(get(drf_engn.virt_rud3) * 100) * 0.01 == 0 then
                set(drf_engn.thro_comm_3, 0.05)
                set(drf_engn.virt_rud3, 0.05)
            elseif get(rud_close_ru19) == 0 and math.floor(get(drf_engn.thro_comm_3) * 100) * 0.01 <= 0.05 and
                math.floor(get(drf_engn.virt_rud3) * 100) * 0.01 == 0.05 then
                set(drf_engn.thro_comm_3, 0)
                set(drf_engn.virt_rud3, 0)
            end
        end
    end
    return 0
end)

-- V11: one-button RUD stop latch control commands.
-- Setting the rud_close flag alone is not enough — the virtual RUD values
-- (thro_comm_1/2 and virt_rud1/2) must also be forced, and the internal
-- rud1_out / rud2_out flags reset.
-- NOTE: rud_close values are inverted in Parshukov's code:
--   rud_close = 0 -> latch ENGAGED (RUD held at/above flight idle)
--   rud_close = 1 -> latch RELEASED (RUD free down to 0%)

-- 1) Full latch RELEASE -> RUD to 1.5% UPRT (ground idle, engine keeps running).
--    UPRT 0% would cut fuel entirely and stop the engine.
registerCommandHandler(createCommand("An-24/Engine/rud_stop_full_release",
    "RUD: full latch release (RUD to 1.5% UPRT, engine keeps running)."), 0, function(p)
    if p == 0 then
        set(rud_close, 1)
        set(rud_close_pos, 0)
        -- Reset the "RUD was above the stop" flags — the key fix
        rud1_out = false
        rud2_out = false
        set(drf_engn.thro_comm_1, 0.015)
        set(drf_engn.thro_comm_2, 0.015)
        set(drf_engn.virt_rud1, 0.015)
        set(drf_engn.virt_rud2, 0.015)
        left_rud_current = 0.015
        right_rud_current = 0.015
    end
    return 0
end)

-- 2) Full latch ENGAGE -> RUD to 10% UPRT (flight idle)
registerCommandHandler(
    createCommand("An-24/Engine/rud_stop_engage", "RUD: engage the stop latch (latched at 10% UPRT)."), 0, function(p)
        if p == 0 then
            set(rud_close, 0)
            set(rud_close_pos, 0)
            set(drf_engn.thro_comm_1, 0.10)
            set(drf_engn.thro_comm_2, 0.10)
            set(drf_engn.virt_rud1, 0.10)
            set(drf_engn.virt_rud2, 0.10)
            left_rud_current = 0.10
            right_rud_current = 0.10
            rud1_out = true
            rud2_out = true
        end
        return 0
    end)

-- interpolate(): shared helper in core/glbl_func.lua

-- Smooth interpolation. V11: optional rate parameter (default 1.0) sets the
-- response speed: rate=2.5 — KTA-24 fuel governor lag, rate=4.0 — output thrust smoothing.
local function smooth(thro, need, rate)
    local k = rate or 1.0
    return thro + (need - thro) * gvar.frame_time * k
end

-- Idle correction blend: full at idle, fading out by taxi so the boost never
-- touches the cruise/climb/takeoff calibration.
--   UPRT <= 10% (ground/flight idle): blend = 1.0 (full correction)
--   UPRT 10%..30%: linear fade
--   UPRT >= 30% (above taxi): blend = 0.0 (no correction)
-- v12 fix (13.06.2026): the fade used to end at UPRT 18%, which left a power
-- dip across UPRT 10-30% while taxiing — the boost was gone before tro_table
-- had risen to meet it. Ending at 30% closes the gap and still finishes far
-- below the 52 deg cruise point, so the cruise calibration is untouched.
local function idle_blend_factor(rud)
    if rud <= 0.10 then
        return 1.0
    end
    if rud >= 0.30 then
        return 0.0
    end
    return 1.0 - (rud - 0.10) / 0.20
end

function update()
    if not initialized and counter > 0.3 and counter < 0.5 then
        set(thro_over, 1) -- Used for take control via plugin. Inside update, bacause XPUIPC reseting overrides on load.
        set(drf_engn.thro_need_1, 0.2)
        set(drf_engn.thro_need_2, 0.2)
        set(drf_engn.thro_need_3, 0.2)
        initialized = true
    elseif not initialized then
        counter = counter + gvar.frame_time
    end

    -- Time BUG workaround
    if gvar.frame_time > 0 then
        -- Set prop RPM to max
        set(prop_RPM, 130.381622)

        -- Altitude calculations
        local alt = get(msl_alt) * 3.28083 -- MSL alt in feet
        -- V11: pressure correction from the pilot's altimeter setting (QNH).
        -- Deviation from standard 29.92 inHg gives ~1000 ft per inHg.
        local alt_baro = (29.92 - get(baro_setting)) * 1000
        local alt_coef = interpolate(alt_table, alt + alt_baro) -- Altitude coeficient for limit power under crit alt
        local oat = get(sim_T) -- outside air temperature, deg C
        local t_coef = interpolate(t_table, oat)

        -- RUD calculations
        -- V11: rud_minimum = 0.10 so the UPRT-2 shows 10% at flight idle
        -- (after latch release), matching the real An-24 gauge reading.
        local rud_minimum = 0.10 + get(rud_close_pos) * 2 / 100
        local stop_active = get(rud_close) == 0
        local stop_active_ru19 = get(rud_close_ru19) == 0
        local stopor_active = get(rud_stopor) > 0.5
        local heat = get(wing_ht) or 0 -- Wing heat takes some power from engines

        -- Limit left rud
        -- V11 "spring-back" fix: the limiter used to act whenever rud1_out=true,
        -- springing the RUD back to 10% even after rud_stop_full_release. Now it
        -- only acts while the latch is engaged (stop_active); with the latch
        -- released the RUD is free in 0-100%.
        local left_rud = get(drf_engn.thro_comm_1)
        if not stop_active then
            rud1_out = true
        end
        if left_rud < rud_minimum and rud1_out and stop_active then
            left_rud = rud_minimum
        end
        -- Check if rud were out from stop
        if left_rud >= rud_minimum and stop_active then
            rud1_out = true
        elseif stop_active then
            rud1_out = false
        end
        -- V11 KTA-24 inertia: smooth the RUD to emulate the AI-24 fuel governor lag
        left_rud_current = smooth(left_rud_current, left_rud, KTA24_RATE)
        -- Set result (smoothed value)
        if not stopor_active then
            left_rud_last = left_rud_current
        end
        set(drf_engn.virt_rud1, left_rud_last)

        -- Limit right rud
        local right_rud = get(drf_engn.thro_comm_2)
        if not stop_active then
            rud2_out = true
        end
        if right_rud < rud_minimum and rud2_out and stop_active then
            right_rud = rud_minimum
        end
        -- Check if rud were out from stop
        if right_rud >= rud_minimum and stop_active then
            rud2_out = true
        elseif stop_active then
            rud2_out = false
        end
        -- KTA-24 inertia for the right engine
        right_rud_current = smooth(right_rud_current, right_rud, KTA24_RATE)
        -- Set result
        if not stopor_active then
            right_rud_last = right_rud_current
        end
        set(drf_engn.virt_rud2, right_rud_last)

        -- Limit third RUD
        local third_rud = get(drf_engn.thro_comm_3)
        -- Check if RUD were out from stop
        if third_rud < 0.05 and get(drf_engn.virt_rud3) ~= 0 and rud3_out then
            third_rud = 0.05
            set(drf_engn.thro_comm_3, 0.05)
        end
        if third_rud >= 0.05 and stop_active_ru19 then
            rud3_out = true
        else
            rud3_out = false
        end
        if not stopor_active then
            third_rud_last = third_rud
        end
        if get(drf_engn.virt_rud3) < 0.05 and stop_active_ru19 then
            third_rud_last = 0
            set(drf_engn.thro_comm_3, 0)
        end
        set(drf_engn.virt_rud3, third_rud_last)

        -- V11: honest anti-ice power extraction.
        -- The wing heat system bleeds power from the engines; the bleed grows with
        -- regime (more exhaust heat = more load). heat_loss = remaining power share
        -- (1.0 = no bleed). At idle ~0%, at nominal ~5%.
        local average_rud = (left_rud_last + right_rud_last) * 0.5
        local heat_loss = 1.0 - (heat * 0.05 * average_rud)

        -- v13 AI-24 water injection (Bogoslavsky 1972) — see water_inject_table.
        -- Armed automatically on a hot day at takeoff power near the ground; the
        -- recovery term is added to t_coef so it cancels most of t_table's
        -- hot-day penalty. The gate uses average_rud, so it behaves the same on
        -- both engines and stays off with one engine at idle.
        local water_target = 0.0
        if oat >= WATER_OAT_MIN and average_rud >= WATER_RUD_MIN and get(agl_alt) < WATER_AGL_MAX then
            water_target = interpolate(water_inject_table, oat)
        end
        -- Asymmetric fade: ~4 s to come on (water heating and evaporating),
        -- ~3 s to fade out (hot gases cooling down).
        local water_rate = water_target > water_coef_smooth and 4.0 or 3.0
        water_coef_smooth = smooth(water_coef_smooth, water_target, water_rate)
        t_coef = t_coef + water_coef_smooth

        -- V11 idle correction (Discovery #13): boost idle toward N1 ~94% per the RLE.
        -- idle_boost depends only on OAT, so it is the same for both engines; the blend
        -- fades it out above the idle band so cruise/climb/takeoff stay as calibrated.
        local idle_boost = interpolate(idle_correction_table, oat)

        -- Left engine (with anti-ice bleed, idle correction and output thrust smoothing)
        local blend_left = idle_blend_factor(left_rud_last)
        local idle_mult_left = (1 - blend_left) + blend_left * idle_boost
        local left_throttle = interpolate(tro_table, left_rud_last) * idle_mult_left * alt_coef * t_coef * heat_loss
        set(drf_engn.thro_need_1, smooth(get(drf_engn.thro_need_1), left_throttle, 4.0))

        -- Right engine
        local blend_right = idle_blend_factor(right_rud_last)
        local idle_mult_right = (1 - blend_right) + blend_right * idle_boost
        local right_throttle = interpolate(tro_table, right_rud_last) * idle_mult_right * alt_coef * t_coef * heat_loss
        set(drf_engn.thro_need_2, smooth(get(drf_engn.thro_need_2), right_throttle, 4.0))

        -- RU19
        local alt_coef_ru19 = interpolate(alt_table_ru19, alt + alt_baro) -- Altitude coeficient for limit power under crit alt
        local t_coef_ru19 = interpolate(t_table_ru19, oat)
        local ru19_throttle = interpolate(tro_table_ru19, third_rud_last) * alt_coef_ru19 * t_coef_ru19
        set(drf_engn.thro_need_3, smooth(get(drf_engn.thro_need_3), ru19_throttle, 4.0))
    end
end

function onModuleDone()
    set(thro_over, 0) -- Release engine control via plugin to let other models fly :)
    print("All throttles released...")
end
