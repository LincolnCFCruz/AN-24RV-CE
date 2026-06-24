size = {2048, 2048}
-- define dataref
defineProperty("auasp_warn", globalProperty("an-24/gauges/auasp_warning")) -- warning
defineProperty("xpdr_led", globalProperty("sim/cockpit/radios/transponder_light"))
defineProperty("nosewheel_mode_lamp", globalProperty("an-24/gauges/nosewheel_mode_lamp"))
defineProperty("oil_lamp1", globalProperty("an-24/gauges/oil_lamp1")) -- low quantity lamp
defineProperty("oil_lamp2", globalProperty("an-24/gauges/oil_lamp2")) -- low quantity lamp
defineProperty("tiredeflectionNose", globalProperty("sim/flightmodel2/gear/tire_vertical_deflection_mtr[0]"))
-- images
defineProperty("green_led", loadLED("green"))
defineProperty("yellow_led", loadLED("yellow"))
defineProperty("red_led", loadLED("red"))

local auasp_light = get(auasp_warn) == 1
local xpdr_light = get(xpdr_led) == 1
local nosewheel_mode = get(nosewheel_mode_lamp)
local oil_light1 = get(oil_lamp1) == 1
local oil_light2 = get(oil_lamp2) == 1

function update()
    auasp_light = get(auasp_warn) == 1
    xpdr_light = get(xpdr_led) == 1
    nosewheel_mode = get(nosewheel_mode_lamp)
    oil_light1 = get(oil_lamp1) == 1
    oil_light2 = get(oil_lamp2) == 1
end

components = { 
    -- critical mode lamp
    textureLit {
        position = {1116, 516, 50, 30},
        image = langImage("lamps", 50, 68, 50, 30),
        visible = function()
            return auasp_light
        end
    }, 
    
    -- transponder light
    textureLit {
        position = {601, 271, 16, 16},
        image = get(green_led),
        visible = function()
            return xpdr_light
        end
    }, 
    
    -- nosewheel taxi mode
    textureLit {
        position = {740, 428, 20, 20},
        image = get(green_led),
        visible = function()
            return nosewheel_mode == 1
        end
    }, 
    
    -- nosewheel off mode
    textureLit {
        position = {760, 428, 20, 20},
        image = get(yellow_led),
        visible = function()
            return nosewheel_mode == 3
        end
    }, 
    
    -- nosewheel takeoff mode
    textureLit {
        position = {780, 428, 20, 20},
        image = get(green_led),
        visible = function()
            return nosewheel_mode == 3 and get(tiredeflectionNose) > 0
        end
    }, 
    
    -- left oil low
    textureLit {
        position = {660, 388, 20, 20},
        image = get(red_led),
        visible = function()
            return oil_light1
        end
    }, 
    
    -- right oil low
    textureLit {
        position = {680, 388, 20, 20},
        image = get(red_led),
        visible = function()
            return oil_light2
        end
    }
}
