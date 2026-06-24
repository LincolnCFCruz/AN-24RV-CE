-- Engine fuel-access logic (pure compute; was mis-registered as a panel with size/position).
-- Combines fuel system + center-panel stops + startup-panel + service covers + fire-ext into
-- the X-Plane per-engine mixture (ENGN_mixt). No render.
-- sources
-- from fuel system
defineProperty("fuel_access1", globalProperty("an-24/fuel/fuel_access1")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("fuel_access2", globalProperty("an-24/fuel/fuel_access2")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("fuel_access3", globalProperty("an-24/fuel/fuel_access3")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich

-- from center panel
defineProperty("fuel_stop1", globalProperty("an-24/fuel/fuel_stop1")) -- stops on center panel
defineProperty("fuel_stop2", globalProperty("an-24/fuel/fuel_stop2")) -- stops on center panel
defineProperty("fuel_stop1_cap", globalProperty("an-24/fuel/fuel_stop1_cap")) -- stops on center panel
defineProperty("fuel_stop2_cap", globalProperty("an-24/fuel/fuel_stop2_cap")) -- stops on center panel

-- from startup panel and automatic cut-off
defineProperty("fuel_start1", globalProperty("an-24/start/fuel_start1")) -- fuel start from startup panel
defineProperty("fuel_start2", globalProperty("an-24/start/fuel_start2")) -- fuel start from startup panel
defineProperty("fuel_start3", globalProperty("an-24/start/fuel_start3")) -- fuel start from startup panel

-- from outside service
defineProperty("left_eng_main", globalProperty("an-24/covers/left_eng_main")) -- left engine main cover
defineProperty("left_eng_ext", globalProperty("an-24/covers/left_eng_ext")) -- left engine exhaust cover
defineProperty("right_eng_main", globalProperty("an-24/covers/right_eng_main")) -- right engine main cover
defineProperty("right_eng_ext", globalProperty("an-24/covers/right_eng_ext")) -- right engine exhaust cover
defineProperty("ru19_eng_ext", globalProperty("an-24/covers/ru19_eng_ext")) -- ru19 engine exhaust cover

-- fire extinguishers
defineProperty("sim_engine_ext1", globalProperty("sim/cockpit2/engine/actuators/fire_extinguisher_on[0]")) -- left engine fire extinguisher
defineProperty("sim_engine_ext2", globalProperty("sim/cockpit2/engine/actuators/fire_extinguisher_on[1]")) -- right engine fire extinguisher
defineProperty("sim_engine_ext3", globalProperty("sim/cockpit2/engine/actuators/fire_extinguisher_on[2]")) -- RU19 engine fire extinguisher

-- result
defineProperty("mixt_valve1", globalProperty("sim/flightmodel/engine/ENGN_mixt[0]")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("mixt_valve2", globalProperty("sim/flightmodel/engine/ENGN_mixt[1]")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("mixt_valve3", globalProperty("sim/flightmodel/engine/ENGN_mixt[2]")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich

function update()
    -- left engine fuel access
    set(mixt_valve1, get(fuel_access1) * get(fuel_stop1) * get(fuel_start1) * get(left_eng_main) * get(left_eng_ext) *
        (1 - get(sim_engine_ext1)))

    -- right engine fuel access
    set(mixt_valve2, get(fuel_access2) * get(fuel_stop2) * get(fuel_start2) * get(right_eng_main) * get(right_eng_ext) *
        (1 - get(sim_engine_ext2)))

    -- RU19 engine fuel access
    set(mixt_valve3, get(fuel_access3) * get(fuel_start3) * get(ru19_eng_ext) * (1 - get(sim_engine_ext3)))
end
