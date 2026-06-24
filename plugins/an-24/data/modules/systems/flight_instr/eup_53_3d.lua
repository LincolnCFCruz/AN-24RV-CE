size = {200, 200}

-- define property table
defineProperty("turn", globalProperty("sim/cockpit2/gauges/indicators/turn_rate_heading_deg_copilot"))

-- needle image
defineProperty("NeedleImage", langImage("needles", 105, 42, 16, 110))

-- power
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg")) --- power bus
defineProperty("eup53_sw", globalProperty("an-24/gauges/eup53_sw")) -- gauge switch
defineProperty("eup53_cc", globalProperty("an-24/gauges/eup53_cc")) -- current consumption

-- failures
defineProperty("fail", globalProperty("sim/operation/failures/rel_cop_tsi")) -- gauge failure

-- initial switchers values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

local time_counter = 0
local not_loaded = true

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

-- local variables
local turn_ind_angle = 0

-- post frame calculations

function update()
    -- initial switchers values
    time_counter = time_counter + get(frame_time)
    if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
        set(eup53_sw, 0)
        not_loaded = false
    end

    -- check power and current
    local power = 0
    if get(bus_DC_27_volt_emerg) > 21 and get(eup53_sw) > 0 then
        power = 1
        set(eup53_cc, 2)
    else
        power = 0
        set(eup53_cc, 0)
    end
    -- print("work here")
    if power > 0 then
        turn_ind_angle = get(turn) * 0.6
    else
        turn_ind_angle = 0
    end

    -- set limits
    if turn_ind_angle > 35 then
        turn_ind_angle = 35
    elseif turn_ind_angle < -35 then
        turn_ind_angle = -35
    end

    return true
end

components = { 
	-- needle
	needle {
		position = {-20, -87, 240, 240},
		image = function()
			return get(NeedleImage)
		end,
		angle = function()
			return turn_ind_angle
		end
	}, 
	
	-- power switch
	toggleSwitch {
		position = {0, 0, 25, 27},
		drf = eup53_sw,
		sound = switch_sound
	}
}
