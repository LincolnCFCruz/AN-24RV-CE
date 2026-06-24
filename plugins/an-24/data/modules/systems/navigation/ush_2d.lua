size = {350, 350}

-- define property table
-- source
defineProperty("gyro_curse", globalProperty("an-24/gauges/GIK_curse")) -- gyro course from GIK
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("flight_time", globalProperty("sim/time/total_running_time_sec")) -- local time since aircraft was loaded

defineProperty("ushdb_3_scale_angle", globalProperty("an-24/misc/ushdb_3_scale_angle")) -- scale rotation angle
defineProperty("ushdb_3_scale_dir", globalProperty("an-24/misc/ushdb_3_scale_dir")) -- scale rotation direction

-- images
defineProperty("curse_needle", langImage("needles", 152.5, 194, 267, 36))

-- set(obs, 0)

-- local variables
local curse_angle = 0
local rotate_dir = 0

-- post-frame calculations
function update()
    -- time calculations
    local passed = get(frame_time)
    -- time bug workaround
    if passed > 0 then
        -- scale rotation (ushdb_3_scale_angle) is integrated by navigator_logic.lua
        local v = get(gyro_curse)
        local delta = v - curse_angle
        if delta > 180 then
            delta = delta - 360
        elseif delta < -180 then
            delta = delta + 360
        end
        curse_angle = curse_angle + 5 * delta * passed
        if curse_angle > 180 then
            curse_angle = curse_angle - 360
        elseif curse_angle < -180 then
            curse_angle = curse_angle + 360
        end

    end

end

components = { 
	-- inner scale
	texture {
		position = {50, 100, 200, 200},
		image = langImage("navigator_panel_2d", 691, 54, 196, 196)
	}, 
	
	-- big scale
	needle {
		position = {10, 60, 280, 280},
		image = langImage("navigator_panel_2d", 0, 1, 341, 341),
		angle = function()
			return get(ushdb_3_scale_angle)
		end
	}, 
	
	-- course needle
	needle {
		position = {10, 60, 280, 280},
		image = function()
			return get(curse_needle)
		end,
		angle = function()
			return curse_angle + 90
		end
	}, 
	
	-- scale rotary
	clickable {
		position = {120, 0, 30, 40}, -- search and set right
		cursor = Cursors.ROTATE_LEFT,
		onMouseDown = function()
			set(ushdb_3_scale_dir, -1)
			return true
		end,
		onMouseUp = function()
			set(ushdb_3_scale_dir, 0)
			return true
		end

	}, 
	
	clickable {
		position = {150, 0, 30, 40}, -- search and set right
		cursor = Cursors.ROTATE_RIGHT,
		onMouseDown = function()
			set(ushdb_3_scale_dir, 1)
			return true
		end,
		onMouseUp = function()
			set(ushdb_3_scale_dir, 0)
			return true
		end
	}
}
