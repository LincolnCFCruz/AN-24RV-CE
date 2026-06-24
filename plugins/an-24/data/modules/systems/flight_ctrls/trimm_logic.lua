-- this is simple trimmer logic (compute only; render half is trimm_3d.lua)
-- define property table
-- sources
defineProperty("ap_roll_power", globalProperty("an-24/ap/ap_roll_power")) -- power for aileron mechanic
defineProperty("ap_pitch_power", globalProperty("an-24/ap/ap_pitch_power")) -- power for elevator mechanic
defineProperty("ap_hdg_power", globalProperty("an-24/ap/ap_hdg_power")) -- power for rudder mechanic
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))

-- result (read here; written by the trimm_3d clickables)
defineProperty("sim_rudd_trimm", globalProperty("sim/cockpit2/controls/rudder_trim")) -- sim rudder trimmer
defineProperty("sim_ail_trimm", globalProperty("sim/cockpit2/controls/aileron_trim")) -- sim aileron trimmer
defineProperty("sim_elev_trimm", globalProperty("sim/cockpit2/controls/elevator_trim")) -- sim elevator trimmer

local power = false
local needle_pos = 0
local rudd_center_lit = false
local ail_center_lit = false

local rudd_trimm_off = false
local ail_trimm_off = false
local elev_trimm_off = false

-- seam datarefs published for the 3D render (trimm_3d)
local ind_power = cGPi(pfx .. "trimm/ind_power")
local ind_rudd_center = cGPi(pfx .. "trimm/ind_rudd_center")
local ind_ail_center = cGPi(pfx .. "trimm/ind_ail_center")
local ind_rudd_trimm_off = cGPi(pfx .. "trimm/ind_rudd_trimm_off")
local ind_ail_trimm_off = cGPi(pfx .. "trimm/ind_ail_trimm_off")
local ind_needle_pos = cGPf(pfx .. "trimm/ind_needle_pos")

function update()
    -- power calculations
    power = get(bus_DC_27_volt_emerg) > 21

    -- led calculations
    if power then
        rudd_center_lit = math.abs(get(sim_rudd_trimm)) < 0.01
        ail_center_lit = math.abs(get(sim_ail_trimm)) < 0.01
        rudd_trimm_off = get(ap_hdg_power) == 1
        ail_trimm_off = get(ap_roll_power) == 1
        elev_trimm_off = get(ap_pitch_power) == 1
    else
        rudd_center_lit = false
        ail_center_lit = false
        rudd_trimm_off = false
        ail_trimm_off = false
        elev_trimm_off = false
    end
    local elev_trim = get(sim_elev_trimm)
    needle_pos = (155 - elev_trim * 40) -- interpolate(pos_table, elev_trim)

    if needle_pos < 0 then
        needle_pos = 0
    elseif needle_pos > 235 then
        needle_pos = 235
    end

    -- needle_pos = 130 -- test

    -- 180 = 32% MAC
    -- 130 = 18% MAC

    -- publish state for the 3D render (trimm_3d)
    set(ind_power, bool2int(power))
    set(ind_rudd_center, bool2int(rudd_center_lit))
    set(ind_ail_center, bool2int(ail_center_lit))
    set(ind_rudd_trimm_off, bool2int(rudd_trimm_off))
    set(ind_ail_trimm_off, bool2int(ail_trimm_off))
    set(ind_needle_pos, needle_pos)
end
