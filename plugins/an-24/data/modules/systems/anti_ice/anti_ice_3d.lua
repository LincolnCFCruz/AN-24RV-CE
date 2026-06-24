-- Anti-ice 3D-panel RENDER only.
-- Compute, cold-state handling, command handlers and 2D-lamp publishing live in
-- anti_ice_logic.lua (registered immediately before this in main.lua). This module renders
-- the published an-24/ice/* datarefs (the existing *_2d lamps + the new ind_* seam values)
-- and handles the panel's clickables.

size = {2048, 2048}

-- input switches (clickables write these; logic reads them)
defineProperty("test_btn", globalProperty("an-24/ice/test_btn"))
defineProperty("engine_ht_sw", globalProperty("an-24/ice/engine_ht_sw"))
defineProperty("wing_ht_sw", globalProperty("an-24/ice/wing_ht_sw"))
defineProperty("ice_detect_sw", globalProperty("an-24/ice/rio_sw"))
defineProperty("pitot_1_sw", globalProperty("an-24/ice/pitot1_sw"))
defineProperty("pitot_2_sw", globalProperty("an-24/ice/pitot2_sw"))
defineProperty("aoa_ht_sw", globalProperty("an-24/ice/aoa_ht_sw"))
defineProperty("prop_ht_sw", globalProperty("an-24/ice/prop_ht_sw"))

-- published indication datarefs (read-only; written by anti_ice_logic.lua)
defineProperty("wing_heat_lit_2d", globalProperty("an-24/ice/wing_heat_lit"))
defineProperty("engine_heat_lit_2d", globalProperty("an-24/ice/engine_heat_lit"))
defineProperty("aoa_heat_lit_2d", globalProperty("an-24/ice/aoa_heat_lit"))
defineProperty("pitot1_lit_2d", globalProperty("an-24/ice/pitot1_lit"))
defineProperty("pitot2_lit_2d", globalProperty("an-24/ice/pitot2_lit"))
defineProperty("pitot1_test_lit_2d", globalProperty("an-24/ice/pitot1_test_lit"))
defineProperty("pitot2_test_lit_2d", globalProperty("an-24/ice/pitot2_test_lit"))
defineProperty("aoa_heat_test_lit_2d", globalProperty("an-24/ice/aoa_heat_test_lit"))
defineProperty("rio_heat_lit_2d", globalProperty("an-24/ice/rio_heat_lit"))
defineProperty("ice_left_eng_lit_2d", globalProperty("an-24/ice/ice_left_eng_lit"))
defineProperty("ice_right_eng_lit_2d", globalProperty("an-24/ice/ice_right_eng_lit"))
defineProperty("thermo_angle_2d", globalProperty("an-24/ice/thermo_angle"))

-- new seam values (not part of the *_2d set)
defineProperty("ind_prop_a", globalProperty("an-24/ice/ind_prop_a"))
defineProperty("ind_prop_b", globalProperty("an-24/ice/ind_prop_b"))
defineProperty("ind_prop_test", globalProperty("an-24/ice/ind_prop_test"))
defineProperty("ind_pos_not_work", globalProperty("an-24/ice/ind_pos_not_work"))
defineProperty("ind_ice_on_plane", globalProperty("an-24/ice/ind_ice_on_plane"))

-- images
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))
defineProperty("needles_1", langImage("needles", 0, 168, 16, 88))
defineProperty("black_cap", langImage("covers", 0, 17, 56, 56)) -- black cap image

local switch_sound = loadSample('sounds/custom/metal_switch.wav')
local btn_click = loadSample('sounds/custom/plastic_btn.wav')

components = { 
    -- gauges --
    -- thermoneter
    needle {
        image = function()
            return get(needles_1)
        end,
        position = {610, 1055, 180, 180},
        angle = function()
            return get(thermo_angle_2d)
        end
    }, 
    
    -- black cap
    texture {
        position = {675, 1115, 60, 60},
        image = function()
            return get(black_cap)
        end
    }, 
    
    ------------
    -- lights --
    ------------

    -- wing heat
    textureLit {
        image = get(green_led),
        position = {661, 328, 19, 19},
        visible = function()
            return get(wing_heat_lit_2d) == 1
        end
    }, 
    
    -- engine heat
    textureLit {
        image = get(green_led),
        position = {681, 328, 19, 19},
        visible = function()
            return get(engine_heat_lit_2d) == 1
        end
    }, 
    
    -- prop left
    textureLit {
        image = get(green_led),
        position = {700, 328, 19, 19},
        visible = function()
            return get(ind_prop_a) == 1
        end
    }, 
    
    textureLit {
        image = get(green_led),
        position = {700, 328, 19, 19},
        visible = function()
            return get(ind_prop_test) == 1
        end
    }, 
    
    -- prop right
    textureLit {
        image = get(green_led),
        position = {721, 328, 19, 19},
        visible = function()
            return get(ind_prop_b) == 1
        end
    }, 
    
    -- pitot left light
    textureLit {
        image = get(green_led),
        position = {761, 308, 19, 19},
        visible = function()
            return get(pitot1_lit_2d) == 1
        end
    }, 
    
    -- pitot left test light
    textureLit {
        image = get(green_led),
        position = {622, 289, 19, 19},
        visible = function()
            return get(pitot1_test_lit_2d) == 1
        end
    }, 
    
    -- pitot right light
    textureLit {
        image = get(green_led),
        position = {602, 289, 19, 19},
        visible = function()
            return get(pitot2_lit_2d) == 1
        end
    }, 
    
    -- pitot right test light
    textureLit {
        image = get(green_led),
        position = {661, 289, 19, 19},
        visible = function()
            return get(pitot2_test_lit_2d) == 1
        end
    }, 
    
    -- AOA light
    textureLit {
        image = get(green_led),
        position = {781, 308, 19, 19},
        visible = function()
            return get(aoa_heat_lit_2d) == 1
        end
    }, 
    
    -- AOA test light
    textureLit {
        image = get(green_led),
        position = {641, 289, 19, 19},
        visible = function()
            return get(aoa_heat_test_lit_2d) == 1
        end
    }, 
    
    -- RIO heat light
    textureLit {
        image = get(green_led),
        position = {781, 348, 19, 19},
        visible = function()
            return get(rio_heat_lit_2d) == 1
        end
    }, 
    
    -- left engine in ice light
    textureLit {
        image = get(red_led),
        position = {621, 328, 19, 19},
        visible = function()
            return get(ice_left_eng_lit_2d) == 1
        end
    }, 
    
    -- right engine in ice light
    textureLit {
        image = get(red_led),
        position = {641, 328, 19, 19},
        visible = function()
            return get(ice_right_eng_lit_2d) == 1
        end
    }, 
    
    -- pos not work light
    textureLit {
        image = langImage("lamps", 50, 38, 50, 30),
        position = {1004, 516, 50, 30},
        visible = function()
            return get(ind_pos_not_work) == 1
        end
    }, 
    
    -- ice on plane light
    textureLit {
        image = langImage("lamps", 100, 38, 50, 30),
        position = {1060, 516, 50, 30},
        visible = function()
            return get(ind_ice_on_plane) == 1
        end
    }, 
    
    ----------------
    -- clickables --
    ----------------

    -- test button (momentary)
    momentaryButton {
        position = {781, 522, 19, 19},
        drf = test_btn,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- engines heat switch
    toggleSwitch {
        position = {918, 272, 35, 15},
        drf = engine_ht_sw,
        sound = switch_sound
    }, 
    
    -- wing heat (3-state; up = decrement, down = increment)
    stepButton {
        position = {954, 272, 35, 7},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(wing_ht_sw)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(wing_ht_sw, a)
        end
    }, 
    
    stepButton {
        position = {954, 280, 35, 7},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(wing_ht_sw)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(wing_ht_sw, a)
        end
    }, 
    
    -- ice detect (3-state)
    stepButton {
        position = {937, 299, 35, 7},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(ice_detect_sw)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(ice_detect_sw, a)
        end
    }, 
    
    stepButton {
        position = {937, 290, 35, 7},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(ice_detect_sw)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(ice_detect_sw, a)
        end
    }, 
    
    -- pitot 1 heat (3-state)
    stepButton {
        position = {1136, 439, 15, 7},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(pitot_1_sw)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(pitot_1_sw, a)
        end
    }, 
    
    stepButton {
        position = {1136, 430, 15, 7},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(pitot_1_sw)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(pitot_1_sw, a)
        end
    }, 
    
    -- aoa sensor heat (3-state)
    stepButton {
        position = {1154, 439, 15, 7},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(aoa_ht_sw)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(aoa_ht_sw, a)
        end
    }, 
    
    stepButton {
        position = {1154, 430, 15, 7},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(aoa_ht_sw)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(aoa_ht_sw, a)
        end
    }, 
    
    -- pitot 2 heat (3-state)
    stepButton {
        position = {1173, 439, 15, 7},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(pitot_2_sw)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(pitot_2_sw, a)
        end
    }, 
    
    stepButton {
        position = {1173, 430, 15, 7},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(pitot_2_sw)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(pitot_2_sw, a)
        end
    }, 
    
    -- prop heat (3-state)
    stepButton {
        position = {805, 261, 15, 7},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(prop_ht_sw)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(prop_ht_sw, a)
        end
    }, 
    
    stepButton {
        position = {805, 252, 15, 7},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(prop_ht_sw)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(prop_ht_sw, a)
        end
    }
}
