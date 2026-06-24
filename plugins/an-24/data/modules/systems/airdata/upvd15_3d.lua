size = {200, 200}

-- initialize component property table
defineProperty("cabin_alt", globalProperty("sim/cockpit2/pressurization/indicators/cabin_altitude_ft"))
defineProperty("cabin_press", globalProperty("sim/cockpit2/pressurization/indicators/pressure_diffential_psi"))

-- meters needle image
defineProperty("needleImage", langImage("needles", 86, 10, 18, 173))

local alt_angle = -90
local press_angle = -90

function update()
    local alt = get(cabin_alt) * 0.0003048009 -- alt in kilometers
    local press = get(cabin_press) * 0.07030696 -- pressure in kg/cm2

    -- alt calculations
    alt_angle = alt * 140 / 15 - 70
    if alt_angle > 70 then
        alt_angle = 70
    elseif alt_angle < -70 then
        alt_angle = -70
    end

    -- press calculations
    if press >= 0 then
        press_angle = -press * 121 / 0.6 - 139
    elseif press < 0 then
        press_angle = -press * 40 / 0.04 - 139
    else
        press_angle = -140
    end

    if press_angle > -100 then
        press_angle = -100
    elseif press_angle < -260 then
        press_angle = -260
    end

end

components = { 
    -- alt needle
    needle {
        position = {10, 10, 180, 180},
        image = function()
            return get(needleImage)
        end,
        angle = function()
            return alt_angle
        end
    }, 
    
    -- press needle
    needle {
        position = {10, 10, 180, 180},
        image = function()
            return get(needleImage)
        end,
        angle = function()
            return press_angle
        end
    }
}
