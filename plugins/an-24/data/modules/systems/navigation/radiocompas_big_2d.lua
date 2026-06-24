size = {300, 300}

-- define property table
defineProperty("adf1", globalProperty("an-24/ark/ark1_angle")) -- bearing to NDB
defineProperty("adf2", globalProperty("an-24/ark/ark2_angle"))

defineProperty("vor1", globalProperty("an-24/gauges/vor_1")) -- bearing to VOR
defineProperty("vor2", globalProperty("an-24/gauges/vor_2")) -- bearing to VOR

defineProperty("ark_vor", globalProperty("an-24/gauges/ark_vor")) -- switcher ARK/VOR

defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- sim time

-- ushdb_2_scale_angle / ushdb_2_scale_dir created in glbl_drfs.lua
defineProperty("ushdb_1_scale_angle", globalProperty("an-24/misc/ushdb_1_scale_angle")) -- scale angle (integrated by navigator_logic.lua)
defineProperty("ushdb_1_scale_dir", globalProperty("an-24/misc/ushdb_1_scale_dir")) -- scale direction (set by this panel's knobs)

-- images
defineProperty("needle1", langImage("needles", 463, 4, 23, 237))
defineProperty("needle2", langImage("needles", 488, 4, 23, 237))
defineProperty("scale", sasl.gl.loadImage("navigator_panel_2d_e.dds", 359, 1, 305, 305))

defineProperty("adf1_test", globalProperty("sim/cockpit2/radios/indicators/adf1_relative_bearing_deg"))

defineProperty("knob_img", langImage("needles", 344, 116, 51, 51))

local angle1 = 0
local angle2 = 0
local last_angle1 = 0
local last_angle2 = 0
local rotate_dir = 0
set(ushdb_1_scale_angle, 0)
set(ushdb_1_scale_dir, 0)

function update()
    -- time calculations
    local passed = get(frame_time)
    -- time bug workaround
    if passed > 0 then

        -- scale rotation (ushdb_1_scale_angle) is integrated by navigator_logic.lua

        local switch = get(ark_vor)

        -- needle 1 smooth
        local v1 = 0
        if switch == 0 then
            v1 = get(adf1)
        else
            v1 = get(vor1)
        end
        local delta1 = v1 - last_angle1
        if delta1 > 180 then
            delta1 = delta1 - 360
        elseif delta1 < -180 then
            delta1 = delta1 + 360
        end
        angle1 = angle1 + 2 * delta1 * passed
        if angle1 > 180 then
            angle1 = angle1 - 360
        elseif angle1 < -180 then
            angle1 = angle1 + 360
        end

        -- needle 2 smooth
        local v2 = 0
        if switch == 0 then
            v2 = get(adf2)
        else
            v2 = get(vor2)
        end

        local delta2 = v2 - last_angle2
        if delta2 > 180 then
            delta2 = delta2 - 360
        elseif delta2 < -180 then
            delta2 = delta2 + 360
        end
        angle2 = angle2 + 2 * delta2 * passed
        if angle2 > 180 then
            angle2 = angle2 - 360
        elseif angle2 < -180 then
            angle2 = angle2 + 360
        end

    end
    last_angle1 = angle1
    last_angle2 = angle2
end

components = { 
	-- scale
	needle {
		position = {0, 0, 285, 285},
		image = get(scale),
		angle = function()
			return get(ushdb_1_scale_angle)
		end
	}, 
	
	-- needle 1
	needle {
		position = {9, 9, 265, 265},
		image = function()
			return get(needle1)
		end,
		angle = function()
			return angle1
		end
	}, 
	
	-- needle 2
	needle {
		position = {9, 9, 265, 265},
		image = function()
			return get(needle2)
		end,
		angle = function()
			return angle2
		end
	}, 
	
	-- rotary knob
	needle {
		position = {250, 250, 50, 50},
		image = function()
			return get(knob_img)
		end,
		angle = function()
			return -get(ushdb_1_scale_angle) * 5
		end
	}, 
	
	-- scale rotary
	clickable {
		position = {250, 250, 25, 50}, -- find and set correct position
		cursor = Cursors.ROTATE_LEFT,
		onMouseDown = function()
			set(ushdb_1_scale_dir, 1)
			return true
		end,
		onMouseUp = function()
			set(ushdb_1_scale_dir, 0)
			return true
		end

	}, 
	
	clickable {
		position = {275, 250, 25, 50}, -- find and set correct position
		cursor = Cursors.ROTATE_RIGHT,
		onMouseDown = function()
			set(ushdb_1_scale_dir, -1)
			return true
		end,
		onMouseUp = function()
			set(ushdb_1_scale_dir, 0)
			return true
		end
	}
}
