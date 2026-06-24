-- Lights 3D-panel RENDER only — test-lamp annunciators, MSRP lamp, and AP-disconnect
-- flash lamps. All light-driving logic (overhead lamps, cabin lights, panel lights, AP-button
-- animation, MSRP, prefs I/O, commands) lives in lights_addition_logic.lua (registered
-- immediately before this in main.lua). This module only renders datarefs the logic publishes.
defineProperty("test_lamp_pilot", globalProperty("an-24/test_lamp_pilot"))
defineProperty("msrplight", globalProperty("an-24/msrplight"))
defineProperty("isalerton", globalProperty("an-24/isalerton"))
defineProperty("green_led", loadLED("green"))

local language = globalProperty("an-24/set/language")
local elev_fail_led = langImages("lamps", 150, 68, 50, 30)
local ail_fail_led = langImages("lamps", 200, 68, 50, 30)
local elev_force_led = langImages("lamps", 0, 38, 50, 30)
local left_ahz_fail_txt = langImages("lamps", 0, 98, 50, 30)
local right_ahz_fail_txt = langImages("lamps", 100, 98, 50, 30)
local third_ahz_fail_txt = langImages("lamps", 50, 98, 50, 30)
local roll_left_txt = langImages("lamps", 150, 98, 50, 30)
local roll_right_txt = langImages("lamps", 200, 98, 50, 30)
local check_ahz_txt = langImages("lamps", 0, 68, 50, 30)

components = {
    textureLit {
        position = {1284, 517, 50, 30},
        image = function()
            return elev_fail_led[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    textureLit {
        position = {1340, 517, 50, 30},
        image = function()
            return ail_fail_led[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    textureLit {
        position = {1116, 450, 50, 30},
        image = function()
            return elev_fail_led[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    textureLit {
        position = {1061, 450, 50, 30},
        image = function()
            return ail_fail_led[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    textureLit {
        position = {1229, 517, 50, 30},
        image = function()
            return elev_force_led[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    textureLit {
        position = {1172, 450, 50, 30},
        image = function()
            return elev_force_led[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    textureLit {
        position = {1398, 518, 45, 27},
        image = function()
            return left_ahz_fail_txt[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    textureLit {
        position = {1455, 518, 43, 27},
        image = function()
            return third_ahz_fail_txt[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    textureLit {
        position = {1007, 484, 45, 27},
        image = function()
            return right_ahz_fail_txt[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    -- left roll indicator
    textureLit {
        position = {1062, 484, 45, 27},
        image = function()
            return roll_left_txt[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    -- right roll indicator
    textureLit {
        position = {1119, 484, 43, 27},
        image = function()
            return roll_right_txt[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    -- check ahz
    textureLit {
        position = {1174, 484, 43, 27},
        image = function()
            return check_ahz_txt[get(language)]
        end,
        visible = function()
            return get(test_lamp_pilot) == 1
        end
    }, 
    
    textureLit {
        position = {740, 309, 20, 20},
        image = get(green_led),
        visible = function()
            return get(msrplight) == 1
        end
    }, 
    
    textureLit {
        image = function()
            return elev_fail_led[get(language)]
        end,
        position = {1284, 517, 50, 30},
        visible = function()
            return get(isalerton) == 2 -- (get(autopilot_state_PF) > 0 or get(autopilot_state_FO) > 0) and get(isalerton)==2

        end
    }, 
    
    textureLit {
        image = function()
            return elev_fail_led[get(language)]
        end,
        position = {1116, 450, 50, 30},
        visible = function()
            return get(isalerton) == 2 -- (get(autopilot_state_PF) > 0 or get(autopilot_state_FO) > 0) and get(isalerton)==2
        end
    }, 
    
    textureLit {
        image = function()
            return ail_fail_led[get(language)]
        end,
        position = {1340, 517, 50, 30},
        visible = function()
            return get(isalerton) == 2 -- (get(autopilot_state_PF) >0 or get(autopilot_state_FO) > 0) and get(isalerton)==2
        end
    }, 
    
    textureLit {
        image = function()
            return ail_fail_led[get(language)]
        end,
        position = {1061, 450, 50, 30},
        visible = function()
            return get(isalerton) == 2 -- (get(autopilot_state_PF) >0 or get(autopilot_state_FO) > 0) and get(isalerton)==2
        end
    }
}
