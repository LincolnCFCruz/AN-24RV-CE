size = {200, 200}

-- needle image
defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))
defineProperty("longNeedleImage", langImage("needles", 86, 10, 18, 173))

-- caps
defineProperty("yellow_cap", langImage("covers", 140, 72, 56, 56)) -- black cap image
defineProperty("kg_cap", langImage("covers", 66, 72, 56, 56)) -- black cap image
defineProperty("term_cap", langImage("covers", 0, 72, 56, 56)) -- black cap image

-- fuel pressure
defineProperty("fuel_p", globalProperty("sim/cockpit2/engine/indicators/fuel_pressure_psi[2]"))

-- oil pressure
defineProperty("oil_p", globalProperty("sim/cockpit2/engine/indicators/oil_pressure_psi[2]"))

-- oil temperature
defineProperty("oil_t", globalProperty("sim/cockpit2/engine/indicators/oil_temperature_deg_C[2]"))

-- XP12 INSTRUMENT VIBRATION: RU-19 RPM dataref (engine [2]) for scaling
-- needle trembling. The jet RU-19 gives sharper vibration than the AI-24.
defineProperty("eng_N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[2]"))

-- power
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))

-- 1 pound/square inch = 0.07031 kilogram/square centimeter

-- local variables
local fuel_p_angle = -65
local oil_p_angle = 155
local oil_t_angle = -155

function update()
    -- check power
    local power27 = 0
    local power115 = 0

    if dcOK() then
        power27 = 1
    else
        power27 = 0
    end

    if acOK() then
        power115 = 1
    else
        power115 = 0
    end

    -- fuel and oil pressure angle
    if power27 * power115 > 0 then
        fuel_p_angle = get(fuel_p) * 0.07031 * 120 * 0.8 / 100 - 60
        oil_p_angle = -get(oil_p) * 0.07031 * 120 * 1.2 / 8 + 150
        -- set limit
        if fuel_p_angle > 120 then
            fuel_p_angle = 120
        end
        if oil_p_angle < 30 then
            oil_p_angle = 30
        end

        -- XP12 RU-19 NEEDLE VIBRATION: turbojet gives sharper vibration
        -- (amplitude slightly larger than AI-24). Proportional to RPM.
        local n1 = get(eng_N1)
        if n1 > 5 then
            -- amplitude: 0..0.8 degrees (RU-19 high-frequency vibration)
            local amp = math.min(n1 / 100, 1.0) * 0.8
            fuel_p_angle = fuel_p_angle + (math.random() - 0.5) * 2 * amp
            oil_p_angle = oil_p_angle + (math.random() - 0.5) * 2 * amp
        end
    else
        fuel_p_angle = -65
        oil_p_angle = 155
    end

    if power27 > 0 then
        oil_t_angle = get(oil_t) * 120 / 200 - 120
        -- set limits
        if oil_t_angle > -30 then
            oil_t_angle = -30
        elseif oil_t_angle < -150 then
            oil_t_angle = -150
        end
    else
        oil_t_angle = -155
    end

end

-- emi3 consists of several components
components = { 
	-- fuel pressure needle
	needle {
		position = {24, 39, 150, 150},
		image = function()
			return get(longNeedleImage)
		end,
		angle = function()
			return fuel_p_angle
		end
	}, 
	
	-- oil pressure needle
	needle {
		position = {-13, 10, 106, 106},
		image = function()
			return get(needles_1)
		end,
		angle = function()
			return oil_p_angle
		end
	}, 
	
	-- oil temperature needle
	needle {
		position = {107, 10, 106, 106},
		image = function()
			return get(needles_1)
		end,
		angle = function()
			return oil_t_angle
		end
	}, 
	
	-- yellowk cap
	texture {
		position = {74, 90, 52, 52},
		image = function()
			return get(yellow_cap)
		end
	}, 
	
	-- kg cap
	texture {
		position = {14, 36, 52, 52},
		image = function()
			return get(kg_cap)
		end
	}, 
	
	-- term cap
	texture {
		position = {133, 36, 52, 52},
		image = function()
			return get(term_cap)
		end
	}
}

