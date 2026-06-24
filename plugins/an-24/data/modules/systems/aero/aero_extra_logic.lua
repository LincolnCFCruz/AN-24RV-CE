defineProperty("gear1_deflect", globalProperty("sim/flightmodel2/gear/tire_vertical_deflection_mtr[0]")) -- 0.15 = full tire deflection
defineProperty("gear2_deflect", globalProperty("sim/flightmodel2/gear/tire_vertical_deflection_mtr[1]"))
defineProperty("gear3_deflect", globalProperty("sim/flightmodel2/gear/tire_vertical_deflection_mtr[2]"))

defineProperty("thrust1", globalProperty("sim/flightmodel/engine/POINT_thrust[0]")) -- Newtons
defineProperty("thrust2", globalProperty("sim/flightmodel/engine/POINT_thrust[1]"))
defineProperty("thrust3", globalProperty("sim/flightmodel/engine/POINT_thrust[2]"))

defineProperty("M_roll", globalProperty("sim/flightmodel/forces/L_plug_acf")) -- pos right
defineProperty("M_pitch", globalProperty("sim/flightmodel/forces/M_plug_acf")) -- pos up
defineProperty("M_yaw", globalProperty("sim/flightmodel/forces/N_plug_acf")) -- pos right

defineProperty("F_side", globalProperty("sim/flightmodel/forces/fside_plug_acf")) -- pos right
defineProperty("F_vert", globalProperty("sim/flightmodel/forces/fnrml_plug_acf")) -- pos up
defineProperty("F_long", globalProperty("sim/flightmodel/forces/faxil_plug_acf")) -- pos aft

defineProperty("ias", globalProperty("sim/flightmodel/position/indicated_airspeed"))
defineProperty("slip", globalProperty("sim/flightmodel/misc/slip"))

defineProperty("gear1_deploy", globalProperty("sim/aircraft/parts/acf_gear_deploy[0]")) -- deploy of front gear
defineProperty("gear2_deploy", globalProperty("sim/aircraft/parts/acf_gear_deploy[1]")) -- deploy of right gear
defineProperty("gear3_deploy", globalProperty("sim/aircraft/parts/acf_gear_deploy[2]")) -- deploy of left gear

--------------
-- SETTINGS --
--------------
-- ═══════════════════════════════════════════════════════════════════════════
-- AERODYNAMICS MODES — pick ONE, comment out the others
-- ═══════════════════════════════════════════════════════════════════════════

-- MODE A: "PARSHUKOV" — original values as in XP11
-- The full An-24 character: sensitive to sideslip (roll develops by itself),
-- strong yaw moment on engine failure, fin blown by the propellers.
-- V11: in XP12 this produces excessive sideslip — the rudder visibly deflects
-- when banking. Switched to mode B.
-- koef_groundforce = 3         -- ground turning moment from engine thrust
-- koef_stabforce_air = 0.8     -- stabilising fin blow-over in the air
-- koef_stabforce_ground = 0.2  -- stabilising fin blow-over on the ground
-- koef_propforce = 0           -- roll moment from the propeller (Parshukov did not use it)
-- koef_slipforce = 100         -- roll moment from sideslip (the main An-24 "character")
-- koef_landgear = 0.5          -- pitch-up moment from extended landing gear

-- MODE B: "BALANCED" — half of Parshukov values (ACTIVE FOR XP12)
-- V11: XP12 reworked the aerodynamics and the stock sideslip effect is already
-- enough. This mode reduces the induced sideslip so the rudder no longer moves
-- when banking, while keeping the An-24 "character" (moderate slip sensitivity).
koef_groundforce = 1.5
koef_stabforce_air = 0.4
koef_stabforce_ground = 0.1
koef_propforce = 0
koef_slipforce = 50 -- was 100, reduced for XP12 (no rudder motion when banking)
koef_landgear = 0.25

-- MODE C: "SAFE" — one tenth (as used during the control checks)
-- The aircraft behaves predictably, but without the distinct An-24 character.
-- koef_groundforce = 0.3
-- koef_stabforce_air = 0.08
-- koef_stabforce_ground = 0.02
-- koef_propforce = 0
-- koef_slipforce = 10
-- koef_landgear = 0.05
-- ═══════════════════════════════════════════════════════════════════════════

function update()
    delta_thrust = (get(thrust2) + get(thrust3)) - get(thrust1)
    if get(gear1_deflect) > 0.05 then
        stab_force = get(thrust2) * koef_stabforce_ground
        ground_force = delta_thrust * koef_groundforce
    else
        ground_force = 0
        stab_force = get(thrust2) * koef_stabforce_air
    end

    if stab_force < 0 then
        stab_force = 0
    end

    thr1 = get(thrust1)
    thr2 = get(thrust2)
    if thr1 < 0 then
        thr1 = 0
    end
    if thr2 < 0 then
        thr2 = 0
    end
    
    prop_force = (thr1 + thr2) * koef_propforce
    slip_force = get(slip) * get(ias) * koef_slipforce

    result_roll = prop_force + slip_force
    result_yaw = ground_force + stab_force

    set(M_roll, result_roll)
    set(M_yaw, result_yaw)

    -- landgear pitch moment
    result_pitch = get(ias) ^ 2 * (get(gear1_deploy) + get(gear2_deploy) + get(gear3_deploy)) / 3 * koef_landgear
    set(M_pitch, result_pitch)

end
