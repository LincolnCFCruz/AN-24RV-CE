-- Brake/ABS 3D-panel RENDER only — the two ABS "anti-skid active" lamps.
-- Logic (brake limits, ABS, park-brake, pressure) lives in brake_logic.lua, registered
-- immediately before this in main.lua; it publishes an-24/hydro/ind_left_abs / ind_right_abs.
size = {2048, 2048}

defineProperty("yellow_led", loadLED("yellow"))
defineProperty("ind_left_abs", globalProperty("an-24/hydro/ind_left_abs"))
defineProperty("ind_right_abs", globalProperty("an-24/hydro/ind_right_abs"))

components = { 
    -- left gear led
    textureLit {
        image = get(yellow_led),
        position = {781, 328, 19, 19},
        visible = function()
            return get(ind_left_abs) == 1
        end
    }, 
    
    -- right gear led
    textureLit {
        image = get(yellow_led),
        position = {601, 308, 19, 19},
        visible = function()
            return get(ind_right_abs) == 1
        end
    }
}
