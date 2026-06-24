size = {2048, 2048}

-- define property table
-- datarefs
defineProperty("outer_marker", globalProperty("sim/cockpit/misc/outer_marker_lit")) -- runway markers
defineProperty("middle_marker", globalProperty("sim/cockpit/misc/middle_marker_lit"))
defineProperty("inner_marker", globalProperty("sim/cockpit/misc/inner_marker_lit"))

defineProperty("alt", globalProperty("sim/flightmodel/position/y_agl"))
defineProperty("mrp_mode", globalProperty("an-24/gauges/mrp_mode")) -- 0 - landing, 1 = navigation

-- power
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("mrp_cc", globalProperty("an-24/gauges/mrp_cc"))

-- fail
defineProperty("fail", globalProperty("sim/operation/failures/rel_marker"))

-- images
defineProperty("white_led", loadLED("white"))
defineProperty("blue_led", loadLED("blue"))
defineProperty("yellow_led", loadLED("yellow"))

local out_lit = false
local mid_lit = false
local in_lit = false

function update()
    local mode = get(mrp_mode)
    -- print(mode)
    if get(bus_DC_27_volt_emerg) > 21 and ((get(alt) < 5000 and mode == 0) or mode == 1) then
        set(mrp_cc, 2)
        set(fail, 0)
        out_lit = get(outer_marker) > 0
        mid_lit = get(middle_marker) > 0
        in_lit = get(inner_marker) > 0
    else
        set(mrp_cc, 0)
        set(fail, 6)
        out_lit = false
        mid_lit = false
        in_lit = false
    end
end

components = { 
    -- outer marker light
    textureLit {
        image = get(blue_led),
        position = {641, 408, 19, 19},
        visible = function()
            return out_lit
        end
    }, 
    
    -- middle marker light
    textureLit {
        image = get(yellow_led),
        position = {720, 349, 19, 19},
        visible = function()
            return mid_lit
        end
    }, 
    
    -- inner marker light
    textureLit {
        image = get(white_led),
        position = {660, 408, 19, 19},
        visible = function()
            return in_lit
        end
    }
}