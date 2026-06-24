-- indicator for cowl flaps position
size = {200, 200}

-- define property table
-- power
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))

-- source
defineProperty("flap1", globalProperty("sim/flightmodel/engine/ENGN_cowl[0]"))
defineProperty("flap2", globalProperty("sim/flightmodel/engine/ENGN_cowl[1]"))

-- images
defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))

local left_angle = -45
local right_angle = -45

function update()
    if dcOK() then
        left_angle = get(flap1) * 90 - 45
        right_angle = get(flap2) * 90 - 45
    end
end

components = { 
	-- left flap indicator
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {16, 18, 65, 65},
		angle = function()
			return left_angle
		end
	}, 
	
	-- right flap indicator
	needle {
		image = function()
			return get(needles_1)
		end,
		position = {113, 18, 65, 65},
		angle = function()
			return right_angle
		end
	}
}

