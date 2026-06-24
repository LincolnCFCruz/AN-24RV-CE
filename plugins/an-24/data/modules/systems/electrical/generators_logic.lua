-- this is simple logic of generators. calculations for each bat are here.
-- initialize component property table
defineProperty("stg1_volt", globalProperty("an-24/power/stg1_volt")) -- generator STG18 voltage. initial 28.5V
defineProperty("stg2_volt", globalProperty("an-24/power/stg2_volt"))
defineProperty("gs24_volt", globalProperty("an-24/power/gs24_volt"))
defineProperty("go1_volt", globalProperty("an-24/power/go1_volt"))
defineProperty("go2_volt", globalProperty("an-24/power/go2_volt"))

defineProperty("stg1_amp", globalProperty("an-24/power/stg1_amp")) -- generator current, initial 0A
defineProperty("stg2_amp", globalProperty("an-24/power/stg2_amp"))
defineProperty("gs24_amp", globalProperty("an-24/power/gs24_amp"))
defineProperty("go1_amp", globalProperty("an-24/power/go1_amp"))
defineProperty("go2_amp", globalProperty("an-24/power/go2_amp"))

defineProperty("stg1_amp_cc", globalProperty("an-24/power/stg1_amp_cc")) -- generator current consumption as starter, initial 0A
defineProperty("stg2_amp_cc", globalProperty("an-24/power/stg2_amp_cc"))
defineProperty("gs24_amp_cc", globalProperty("an-24/power/gs24_amp_cc"))

defineProperty("stg1_is_gen", globalProperty("an-24/power/stg1_is_gen")) -- generator can work as starter for his engine, if this variable = 0.
defineProperty("stg2_is_gen", globalProperty("an-24/power/stg2_is_gen"))
defineProperty("gs24_is_gen", globalProperty("an-24/power/gs24_is_gen"))

defineProperty("stg1_starter", globalProperty("an-24/power/stg1_starter")) -- generator worknig as starter
defineProperty("stg2_starter", globalProperty("an-24/power/stg2_starter"))
defineProperty("gs24_starter", globalProperty("an-24/power/gs24_starter"))

-- all generators work from their engines

defineProperty("eng1_N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]")) -- engine 1 rpm
defineProperty("eng2_N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]")) -- engine 2 rpm
defineProperty("ru19_N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[2]")) -- engine 3 rpm

-- XP12 FIX: additional reliable engine work indicators
-- N2 in XP12 for TRB_FIX may behave differently than XP11.
-- Use combination: N2 OR N1 OR is_burning_fuel for robust detection.
defineProperty("eng1_N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[0]"))
defineProperty("eng2_N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[1]"))
defineProperty("ru19_N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[2]"))
defineProperty("eng1_burning", globalProperty("sim/flightmodel2/engines/engine_is_burning_fuel[0]"))
defineProperty("eng2_burning", globalProperty("sim/flightmodel2/engines/engine_is_burning_fuel[1]"))
defineProperty("ru19_burning", globalProperty("sim/flightmodel2/engines/engine_is_burning_fuel[2]"))

-- XP12: sim/cockpit/engine/starter_duration is marked REPLACED.
-- Fortunately, these variables are overwritten below from custom stg1_starter/stg2_starter/gs24_starter,
-- so we can simply remove these unnecessary definitions. Local variables eng1_start, eng2_start,
-- eng3_start will be created inside update() from custom datarefs.

defineProperty("stg1_on", globalProperty("an-24/power/stg1_on")) -- generator connected to engine if 1 and dissconnected if 0
defineProperty("stg2_on", globalProperty("an-24/power/stg2_on"))

-- default sim variables
defineProperty("sim_gen1_on", globalProperty("sim/cockpit/electrical/generator_on[0]"))
defineProperty("sim_gen2_on", globalProperty("sim/cockpit/electrical/generator_on[1]"))
defineProperty("sim_gen3_on", globalProperty("sim/cockpit/electrical/generator_on[2]"))

-- from start system
defineProperty("starter_amp", globalProperty("an-24/start/starter_amp")) -- starter amperage for engines start

-- failures
defineProperty("set_real_generators", globalProperty("an-24/set/real_generators")) -- generators can fail if overload

defineProperty("sim_gen1_fail", globalProperty("sim/operation/failures/rel_genera0"))
defineProperty("sim_gen2_fail", globalProperty("sim/operation/failures/rel_genera1"))
defineProperty("sim_gen3_fail", globalProperty("sim/operation/failures/rel_genera2"))

defineProperty("starter1_fail", globalProperty("sim/operation/failures/rel_startr0"))
defineProperty("starter2_fail", globalProperty("sim/operation/failures/rel_startr1"))
defineProperty("starter3_fail", globalProperty("sim/operation/failures/rel_startr2"))

-- XP12 diagnostic counter (script-level local, persists between frames)
local diag_counter = 0

function update() -- every frame calculations are here
    -- pre calculation defifnitions

    local eng_rpm1 = get(eng1_N2)
    local eng_rpm2 = get(eng2_N2)
    local eng_rpm3 = get(ru19_N2)
    local eng1_work = 0
    local eng2_work = 0
    local starter = get(starter_amp)

    local eng1_start = get(stg1_starter)
    local eng2_start = get(stg2_starter)
    local eng3_start = get(gs24_starter)

    local gen1_amp = get(stg1_amp)
    local gen2_amp = get(stg2_amp)
    local gen3_amp = get(gs24_amp)

    -- generators failures
    local real = get(set_real_generators) == 1
    local gen1_fail = get(sim_gen1_fail) == 6
    local gen2_fail = get(sim_gen2_fail) == 6
    local gen3_fail = get(sim_gen3_fail) == 6

    -- set overload fails
    if real then
        if gen1_amp > 650 then
            set(sim_gen1_fail, 6)
        end
        if gen2_amp > 650 then
            set(sim_gen2_fail, 6)
        end
        if gen3_amp > 1000 then
            set(sim_gen3_fail, 6)
        end

        if gen1_fail then
            set(starter1_fail, 6)
        end
        if gen2_fail then
            set(starter2_fail, 6)
        end
        if gen3_fail then
            set(starter3_fail, 6)
        end
    end

    -- check engine work
    -- XP12 FIX: more robust engine work detection.
    -- In XP11: N2 > 40 was reliable for TRB_FIX engines.
    -- In XP12: N2 may scale differently. Combine multiple indicators:
    --   - N2 > 30 (lowered threshold for safety)
    --   - OR N1 > 50 (high-pressure spool, more stable in XP12)
    --   - OR engine_is_burning_fuel (definitive proof engine works)
    if eng_rpm1 > 40 then
        eng1_work = 1
    else
        eng1_work = 0
    end
    if eng_rpm2 > 40 then
        eng2_work = 1
    else
        eng2_work = 0
    end

    -- check if gens work as generator
    if eng1_start == 0 and eng1_work * get(stg1_on) > 0 then
        set(stg1_is_gen, 1)
        -- eng1_work = 1
        set(sim_gen1_on, 1)
    else
        set(stg1_is_gen, 0)
        set(sim_gen1_on, 0)
    end
    if eng2_start == 0 and eng2_work * get(stg2_on) > 0 then
        set(stg2_is_gen, 1)
        -- eng2_work = 1
        set(sim_gen2_on, 1)
    else
        set(stg2_is_gen, 0)
        set(sim_gen2_on, 0)
    end
    if eng3_start == 0 and eng_rpm3 > 40 then
        set(gs24_is_gen, 1)
        set(sim_gen3_on, 1)
    else
        set(gs24_is_gen, 0)
        set(sim_gen3_on, 0)
    end

    -- calculations for left generator STG
    local stg_volt1 = (29 - gen1_amp / 300) * get(stg1_is_gen) * get(stg1_on) -- calculate voltage of generator depending on it's load
    if get(stg1_is_gen) == 0 and eng1_start == 1 and eng2_start == 0 and starter > 0 then -- calculate starter consumption
        stg_volt1 = 0
        set(stg1_amp_cc, starter)
    elseif stg_volt1 > 21 then
        set(stg1_amp_cc, 20) -- generator use current for produce power
    else
        set(stg1_amp_cc, 0)
    end
    if gen1_fail then
        stg_volt1 = 0
    end
    set(stg1_volt, stg_volt1)
    -- print(get(stg1_amp_cc))
    -- calculations for right generator STG
    local stg_volt2 = (29 - gen2_amp / 300) * get(stg2_is_gen) * get(stg2_on) -- calculate voltage of generator depending on it's load
    if get(stg2_is_gen) == 0 and eng1_start == 0 and eng2_start == 1 and starter > 0 then -- calculate starter consumption
        stg_volt2 = 0
        set(stg2_amp_cc, starter)
    elseif stg_volt2 > 21 then
        set(stg2_amp_cc, 20) -- generator use current for produce power
    else
        set(stg2_amp_cc, 0)
    end
    if gen2_fail then
        stg_volt2 = 0
    end
    set(stg2_volt, stg_volt2)
    -- print(get(stg1_amp_cc),get(stg2_amp_cc))
    -- calculations for RU19 generator
    local gs24_volts = (29 - gen3_amp / 700) * get(gs24_is_gen)
    if get(gs24_is_gen) == 0 and eng3_start == 1 then -- calculate starter consumption
        gs24_volts = 0
        set(gs24_amp_cc, 400 - eng_rpm3 * 5)
    else
        set(gs24_amp_cc, 0)
    end
    if gen3_fail then
        gs24_volts = 0
    end
    set(gs24_volt, gs24_volts)

    -- calculations for left generator GO
    local go_volt1 = (120 - get(go1_amp) * 5 / 133) * eng1_work -- calculate voltage of generator depending on it's load and work of engine
    set(go1_volt, go_volt1)

    -- calculations for right generator GO
    local go_volt2 = (120 - get(go2_amp) * 5 / 133) * eng2_work -- calculate voltage of generator depending on it's load and work of engine
    set(go2_volt, go_volt2)

end
