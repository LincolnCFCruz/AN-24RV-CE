-- this is simple SPU logic
size = {140, 180}

-- define property table
defineProperty("audio_selection_com1", globalProperty("sim/cockpit2/radios/actuators/audio_selection_com1"))
defineProperty("audio_selection_com2", globalProperty("sim/cockpit2/radios/actuators/audio_selection_com2"))
defineProperty("audio_selection_nav1", globalProperty("sim/cockpit2/radios/actuators/audio_selection_nav1"))
defineProperty("audio_selection_nav2", globalProperty("sim/cockpit2/radios/actuators/audio_selection_nav2"))
defineProperty("audio_dme_enabled", globalProperty("sim/cockpit2/radios/actuators/audio_dme_enabled"))

defineProperty("spu_power_sw", globalProperty("an-24/gauges/spu_power_sw"))
defineProperty("spu_mode", globalProperty("an-24/gauges/spu_mode"))
defineProperty("bus27", globalProperty("an-24/power/bus_DC_27_volt_emerg"))

-- initial switcher values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

local time_counter = 0
local not_loaded = true

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

function update()
    -- initial switcher values
    time_counter = time_counter + get(frame_time)
    if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
        set(spu_power_sw, 0)
        not_loaded = false
    end

    local mode = get(spu_mode)
    local power = get(spu_power_sw) == 1 and get(bus27) > 21

    if mode == 4 and power then
        set(audio_selection_nav1, 1)
        set(audio_selection_nav2, 0)
    elseif mode == 5 and power then
        set(audio_selection_nav1, 0)
        set(audio_selection_nav2, 1)
    else
        set(audio_selection_nav1, 0)
        set(audio_selection_nav2, 0)
    end
end

components = { 
	-- mode rotary
	rotary {
		position = {40, 50, 60, 60},
		value = spu_mode,
		adjuster = function(v)
			if v >= 0 and v <= 5 then
				sasl.al.playSample(plastic_sound, false)
			end
			if 0 > v then
				v = 0;
			elseif 5 < v then
				v = 5
			end
			return v
		end
	}, 
	
	-- power switch
	toggleSwitch {
		position = {5, 20, 30, 40},
		drf = spu_power_sw,
		sound = switch_sound
	}
}
