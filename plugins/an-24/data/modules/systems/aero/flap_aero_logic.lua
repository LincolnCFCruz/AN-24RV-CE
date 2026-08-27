--[[

  File: flap_aero_logic.lua
  -----
  Single owner of the flap aerodynamic coefficients acf_flap_cl / _cd / _cm.

  Two layers, computed in one pass every frame:

    1. BASE — the flap contribution itself, scaled by flap handle position.
       Unchanged from the original module.

    2. AIRFRAME CORRECTIONS (v13, ported from Evgeny Gimaev's standalone
       an24_aero.lua, 17-20.08.2026) — ISA correction of flap effectiveness,
       sideslip drag, CG pitching moment and ground effect. These ride the same
       datarefs, which is why they live here: hard rule 7 wants exactly one
       writer per computed value, and recomputing the base from flap_ratio each
       frame is also what keeps the corrections from accumulating into the
       dataref they were read from (the failure mode of the original module,
       which did get() + add + set() on values nobody reset).

  NOT ported from an24_aero.lua, deliberately:
    * Landing-gear pitching moment — aero_extra_logic already models it via
      M_plug_acf (koef_landgear), and the an24_aero version has the opposite
      sign, so porting it would fight the tuned one.
    * Anti-ice power extraction — already in engine_logic (heat_loss).
    * acf_flap2_* writes — this airframe has acf/_flap2_type 0 and all-zero
      flap2 coefficients, so a second flap system does not exist here and
      writing to it does nothing.

  NOTE: X-Plane applies these as the flap system's coefficients, so the
  corrections are strongest with the flaps out — which is where the effects
  they model (takeoff/landing speeds, float in the flare, crosswind drag)
  actually matter.

--]]

defineProperty("cl", globalProperty("sim/aircraft/controls/acf_flap_cl"))
defineProperty("cd", globalProperty("sim/aircraft/controls/acf_flap_cd"))
defineProperty("cm", globalProperty("sim/aircraft/controls/acf_flap_cm"))
defineProperty("flap", globalProperty("sim/cockpit2/controls/flap_ratio"))

-- Correction inputs
defineProperty("oat", globalProperty("sim/weather/aircraft/temperature_ambient_deg_c")) -- deg C
defineProperty("alt_m", globalProperty("sim/flightmodel/position/elevation")) -- metres MSL
defineProperty("beta", globalProperty("sim/flightmodel/position/beta")) -- sideslip, degrees
defineProperty("agl", globalProperty("sim/flightmodel/position/y_agl")) -- metres AGL
defineProperty("cg_mac", globalProperty("sim/flightmodel2/misc/cg_offset_z_mac")) -- CG, percent MAC

-- ═══════════════════════════════════════════════════════════════════════════
-- CORRECTION SWITCHES — flip one to false to isolate an effect in flight test
-- ═══════════════════════════════════════════════════════════════════════════
local ISA_ENABLED = true -- 1. ISA deviation -> flap effectiveness
local BETA_ENABLED = true -- 2. sideslip -> drag
local CG_ENABLED = true -- 3. CG position -> pitching moment
local GROUND_EFFECT_ENABLED = true -- 4. ground effect -> +CL, -CDi

-- Tuning constants (Gimaev, 17.08.2026)
local ISA_CL_PER_DEG = -0.003 -- CL factor per deg of ISA deviation
local ISA_CORR_MIN = 0.85 -- clamp: hot-day floor on flap effectiveness
local ISA_CORR_MAX = 1.10 -- clamp: cold-day ceiling
local FLAP_OUT_RATIO = 0.03 -- flaps count as "out" above this (~1 deg of 38)

local BETA_CD_SCALE = 0.0004 -- Cd per deg^2 of sideslip
local BETA_CD_MAX = 0.050 -- cap: ~11 deg of slip, about 2x the An-24's Cx0

local CG_CM_SCALE = 0.15 -- pitching moment per unit of MAC offset
local CG_REF = 0.27 -- reference CG, 27% MAC = neutral column
local CG_CM_LIMIT = 0.05 -- clamp on the CG contribution

local GE_MAX_CL_BONUS = 0.08 -- max CL gain in ground effect (+8%)
local GE_MAX_CD_RED = 0.005 -- max induced-drag reduction in ground effect
local GE_HEIGHT_M = 10.0 -- height band of the ground effect, metres

-- ISA standard temperature at a given altitude.
local function isa_temp(alt_m)
    return 15.0 - 0.0065 * alt_m
end

-- CG as a fraction of MAC. XP12 reports cg_offset_z_mac in PERCENT MAC (27.0),
-- while CG_REF/CG_CM_SCALE above are written in fractions; a real transport CG
-- is never below 1.5% MAC, so that threshold safely tells the two apart even if
-- a future X-Plane build changes the unit. Falls back to the reference (no
-- correction) when the dataref is unavailable.
local function cg_fraction()
    local v = get(cg_mac)
    if v == nil then
        return CG_REF
    end
    if v > 1.5 then
        v = v * 0.01
    end
    return v
end

function update()
    -- ─── BASE: flap contribution ────────────────────────────────────────────
    local flapratio = get(flap)
    local flapcl = 0.5 * flapratio
    local flapcd = 0.005 * flapratio
    local flapcm = -0.4 * flapratio

    -- ─── 1. ISA CORRECTION OF FLAP EFFECTIVENESS ────────────────────────────
    -- Hot air is thinner, so the flaps do less for you and the takeoff/landing
    -- speeds go up (+30 C is worth roughly +10 km/h on V1); cold air does the
    -- reverse. Only applied with the flaps actually out.
    if ISA_ENABLED and flapratio > FLAP_OUT_RATIO then
        local isa_dev = get(oat) - isa_temp(get(alt_m))
        local isa_corr = math.clamp(ISA_CORR_MIN, 1.0 + ISA_CL_PER_DEG * isa_dev, ISA_CORR_MAX)
        flapcl = flapcl * isa_corr
    end

    -- ─── 2. SIDESLIP -> DRAG ────────────────────────────────────────────────
    -- In a slip the fuselage presents its flank to the flow and drag climbs,
    -- which is felt as braking in a crosswind. Capped so a large excursion
    -- cannot produce an absurd coefficient.
    if BETA_ENABLED then
        local beta_deg = get(beta)
        flapcd = flapcd + math.min(BETA_CD_SCALE * beta_deg * beta_deg, BETA_CD_MAX)
    end

    -- ─── 3. CG -> PITCHING MOMENT ───────────────────────────────────────────
    -- 27% MAC is the neutral An-24 loading; aft of it the nose wants to rise,
    -- forward of it the nose wants to drop.
    if CG_ENABLED then
        flapcm = flapcm + math.clamp(-CG_CM_LIMIT, CG_CM_SCALE * (cg_fraction() - CG_REF), CG_CM_LIMIT)
    end

    -- ─── 4. GROUND EFFECT ───────────────────────────────────────────────────
    -- Below ~10 m the wing gains lift and sheds induced drag, so the aircraft
    -- floats over the runway — miss the throttle reduction and you land long.
    if GROUND_EFFECT_ENABLED then
        local agl_m = get(agl)
        if agl_m >= 0 and agl_m < GE_HEIGHT_M then
            local ge_factor = 1.0 - agl_m / GE_HEIGHT_M
            flapcl = flapcl + GE_MAX_CL_BONUS * ge_factor
            flapcd = flapcd - GE_MAX_CD_RED * ge_factor
        end
    end

    set(cl, flapcl)
    set(cd, flapcd)
    set(cm, flapcm)
end
