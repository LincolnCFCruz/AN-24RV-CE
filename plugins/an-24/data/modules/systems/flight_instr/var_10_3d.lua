size = {200, 200}

-- initialize component property table
defineProperty("vvi", globalProperty("sim/cockpit2/pressurization/indicators/cabin_vvi_fpm"))

-- meters needle image
defineProperty("needleImage", langImage("needles", 86, 10, 18, 173))

local vvi_angle = -90

function update()
    local v = get(vvi) * 0.00508
    if 10 < v then
        v = 10
    elseif -10 > v then
        v = -10
    end
    vvi_angle = v * 18 - 90

end

components = { -- vvi needle
	needle {
		position = {10, 10, 180, 180},
		image = function()
			return get(needleImage)
		end,
		angle = function()
			return vvi_angle
		end
	}
}
