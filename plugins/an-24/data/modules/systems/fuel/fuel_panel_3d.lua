-- Fuel system 3D-panel RENDER only.
-- Compute/indication logic + cold-start init + command handlers live in
-- fuel_panel_logic.lua (registered immediately before this in main.lua). This module
-- only renders the published an-24/fuel/* indication datarefs and handles clickables.
size = {2048, 2048}

-- input switches / knobs (clickables write these; logic reads them)
defineProperty("fire_valve1_sw", globalProperty("an-24/fuel/fire_valve1_sw"))
defineProperty("fire_valve2_sw", globalProperty("an-24/fuel/fire_valve2_sw"))
defineProperty("fire_valve3_sw", globalProperty("an-24/fuel/fire_valve3_sw"))
defineProperty("fuel_circle_valve_sw", globalProperty("an-24/fuel/fuel_circle_valve_sw"))
defineProperty("pump1_switch", globalProperty("an-24/fuel/pump1_switch"))
defineProperty("pump2_switch", globalProperty("an-24/fuel/pump2_switch"))
defineProperty("pump3_switch", globalProperty("an-24/fuel/pump3_switch"))
defineProperty("pump4_switch", globalProperty("an-24/fuel/pump4_switch"))
defineProperty("quantity_mode", globalProperty("an-24/fuel/quantity_mode"))
defineProperty("fuel_quant_button", globalProperty("an-24/fuel/fuel_quant_button"))
defineProperty("fuel_stop1", globalProperty("an-24/fuel/fuel_stop1"))
defineProperty("fuel_stop2", globalProperty("an-24/fuel/fuel_stop2"))
defineProperty("fuel_stop1_cap", globalProperty("an-24/fuel/fuel_stop1_cap"))
defineProperty("fuel_stop2_cap", globalProperty("an-24/fuel/fuel_stop2_cap"))
defineProperty("fuel_flow_left_count_rot", globalProperty("an-24/fuel/fuel_flow_left_count_rot"))
defineProperty("fuel_flow_right_count_rot", globalProperty("an-24/fuel/fuel_flow_right_count_rot"))

-- published indication datarefs (read-only; written by fuel_panel_logic.lua)
defineProperty("quant_1000_lit", globalProperty("an-24/fuel/quant_1000_lit"))
defineProperty("left_filter_block_lit", globalProperty("an-24/fuel/left_filter_block_lit"))
defineProperty("right_filter_block_lit", globalProperty("an-24/fuel/right_filter_block_lit"))
defineProperty("fuel_circle_lit", globalProperty("an-24/fuel/fuel_circle_lit"))
defineProperty("left_fuel_press_lit", globalProperty("an-24/fuel/left_fuel_press_lit"))
defineProperty("right_fuel_press_lit", globalProperty("an-24/fuel/right_fuel_press_lit"))
defineProperty("left_pk_open_lit", globalProperty("an-24/fuel/left_pk_open_lit"))
defineProperty("right_pk_open_lit", globalProperty("an-24/fuel/right_pk_open_lit"))
defineProperty("left_chip_lit", globalProperty("an-24/fuel/left_chip_lit"))
defineProperty("right_chip_lit", globalProperty("an-24/fuel/right_chip_lit"))
defineProperty("fuel_lump1_lit", globalProperty("an-24/fuel/fuel_lump1_lit"))
defineProperty("fuel_lump2_lit", globalProperty("an-24/fuel/fuel_lump2_lit"))
defineProperty("fuel_lump3_lit", globalProperty("an-24/fuel/fuel_lump3_lit"))
defineProperty("fuel_lump4_lit", globalProperty("an-24/fuel/fuel_lump4_lit"))
defineProperty("fuel_flow_left_angle", globalProperty("an-24/fuel/fuel_flow_left_angle"))
defineProperty("fuel_flow_right_angle", globalProperty("an-24/fuel/fuel_flow_right_angle"))
defineProperty("fuel_flow_left_count", globalProperty("an-24/fuel/fuel_flow_left_count"))
defineProperty("fuel_flow_right_count", globalProperty("an-24/fuel/fuel_flow_right_count"))
defineProperty("fuel_quant1_angle", globalProperty("an-24/fuel/fuel_quant1_angle"))
defineProperty("fuel_quant2_angle", globalProperty("an-24/fuel/fuel_quant2_angle"))
defineProperty("ru19_pk_open_lit", globalProperty("an-24/fuel/ru19_pk_open_lit"))
defineProperty("ru19_pk_close_lit", globalProperty("an-24/fuel/ru19_pk_close_lit"))

-- images
defineProperty("yellow_led", loadLED("yellow"))
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))
defineProperty("needle_q_left", langImage("needles", 32, 20, 17, 141))
defineProperty("needle_q_right", langImage("needles", 48, 20, 17, 141))
defineProperty("needle_long", langImage("needles", 67, 7, 16, 179))
defineProperty("digitsImage", sasl.gl.loadImage("white_digit_strip.png", 0, 60, 16, 196))
defineProperty("yellow_cap", langImage("covers", 204, 72, 56, 56)) -- yellow cap image

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

components = { 
  
    -------------------
    -- needle gauges --
    -------------------
    
    -- quantity meter. left needle
    needle {
        image = function()
            return get(needle_q_left)
        end,
        position = {230, 1275, 141, 141},
        angle = function()
            return get(fuel_quant1_angle)
        end
    }, 
    
    -- quantity meter. right needle
    needle {
        image = function()
            return get(needle_q_right)
        end,
        position = {230, 1275, 141, 141},
        angle = function()
            return get(fuel_quant2_angle)
        end
    }, 
    
    -- yellow cap
    texture {
        position = {272, 1317, 56, 56},
        image = function()
            return get(yellow_cap)
        end
    }, 
    
    -- control button (momentary)
    momentaryButton {
        position = {275, 1250, 50, 50},
        drf = fuel_quant_button,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- mode changer (4-state 0..3, auto-repeats while held)
    stepButton {
        position = {1518, 559, 35, 70},
        cursor = Cursors.ROTATE_LEFT,
        repeating = true,
        onStep = function()
            local a = get(quantity_mode)
            if a > 0 then
                playUISound(plastic_sound);
                a = a - 1
            end
            set(quantity_mode, a)
        end
    }, 
    
    stepButton {
        position = {1550, 559, 35, 70},
        cursor = Cursors.ROTATE_RIGHT,
        repeating = true,
        onStep = function()
            local a = get(quantity_mode)
            if a < 3 then
                playUISound(plastic_sound);
                a = a + 1
            end
            set(quantity_mode, a)
        end
    }, 
    
    -- fuel flow meters
    -- left counter
    digitstape {
        position = {1068, 1490, 71, 25},
        image = digitsImage,
        digits = 3,
        allowNonRound = false,
        showLeadingZeros = true,
        value = function()
            return get(fuel_flow_left_count)
        end
    }, 
    
    needle {
        image = function()
            return get(needle_long)
        end,
        position = {1012, 1457, 179, 179},
        angle = function()
            return get(fuel_flow_left_angle)
        end
    }, 
    
    -- counter rotary
    rotary {
        value = fuel_flow_left_count_rot,
        step = 10,
        position = {1068, 1450, 70, 50},
        adjuster = function(v)
            sasl.al.playSample(rot_click, false)
            return math.ceil(v / 10) * 10
        end
    }, 
    
    -- right counter
    digitstape {
        position = {1268, 1490, 71, 25},
        image = digitsImage,
        digits = 3,
        allowNonRound = false,
        showLeadingZeros = true,
        value = function()
            return get(fuel_flow_right_count)
        end
    }, 
    
    needle {
        image = function()
            return get(needle_long)
        end,
        position = {1212, 1457, 179, 179},
        angle = function()
            return get(fuel_flow_right_angle)
        end
    }, 
    
    -- counter rotary
    rotary {
        value = fuel_flow_right_count_rot,
        step = 10,
        position = {1268, 1450, 70, 50},
        adjuster = function(v)
            sasl.al.playSample(rot_click, false)
            return math.ceil(v / 10) * 10
        end
    }, 
    
    ------------------
    -- panel lights --
    ------------------
    
    -- fuel quantity less then 1000kg
    textureLit {
        image = get(red_led),
        position = {600, 368, 20, 20},
        visible = function()
            return get(quant_1000_lit) == 1
        end
    }, 
    
    -- left filter block
    textureLit {
        image = get(yellow_led),
        position = {620, 368, 20, 20},
        visible = function()
            return get(left_filter_block_lit) == 1
        end
    }, 
    
    -- right filter block
    textureLit {
        image = get(yellow_led),
        position = {640, 368, 20, 20},
        visible = function()
            return get(right_filter_block_lit) == 1
        end
    }, 
    
    -- fire valve 3 ON
    textureLit {
        image = get(green_led),
        position = {621, 428, 20, 20},
        visible = function()
            return get(ru19_pk_open_lit) == 1
        end
    }, 
    
    -- fire valve 3 OFF
    textureLit {
        image = get(red_led),
        position = {641, 428, 20, 20},
        visible = function()
            return get(ru19_pk_close_lit) == 1
        end
    }, 
    
    -- fuel circle
    textureLit {
        image = get(yellow_led),
        position = {680, 367, 20, 20},
        visible = function()
            return get(fuel_circle_lit) == 1
        end
    }, 
    
    -- fuel pressure left
    textureLit {
        image = get(green_led),
        position = {660, 367, 20, 20},
        visible = function()
            return get(left_fuel_press_lit) == 1
        end
    }, 
    
    -- fuel pressure right
    textureLit {
        image = get(green_led),
        position = {700, 367, 20, 20},
        visible = function()
            return get(right_fuel_press_lit) == 1
        end
    }, 
    
    -- fuel pump 1
    textureLit {
        image = get(green_led),
        position = {720, 367, 20, 20},
        visible = function()
            return get(fuel_lump1_lit) == 1
        end
    }, 
    
    -- fuel pump 2
    textureLit {
        image = get(green_led),
        position = {739.5, 367, 20, 20},
        visible = function()
            return get(fuel_lump2_lit) == 1
        end
    }, 
    
    -- fuel pump 3
    textureLit {
        image = get(green_led),
        position = {760, 367, 20, 20},
        visible = function()
            return get(fuel_lump3_lit) == 1
        end
    }, 
    
    -- fuel pump 4
    textureLit {
        image = get(green_led),
        position = {780.5, 367, 20, 20},
        visible = function()
            return get(fuel_lump4_lit) == 1
        end
    }, 
    
    -- fire valve 1 ON
    textureLit {
        image = get(green_led),
        position = {600.5, 347, 20, 20},
        visible = function()
            return get(left_pk_open_lit) == 1
        end
    }, 
    
    -- fire valve 2 ON
    textureLit {
        image = get(green_led),
        position = {660, 347, 20, 20},
        visible = function()
            return get(right_pk_open_lit) == 1
        end
    }, 
    
    -- chip left
    textureLit {
        image = get(red_led),
        position = {680, 347, 20, 20},
        visible = function()
            return get(left_chip_lit) == 1
        end
    }, 
    
    -- chip right
    textureLit {
        image = get(red_led),
        position = {700, 347, 20, 20},
        visible = function()
            return get(right_chip_lit) == 1
        end
    }, 
    
    ---------------------
    -- panel switchers --
    ---------------------

    -- fire valves 1 / 2 / 3
    toggleSwitch {
        position = {805, 288, 17, 17},
        drf = fire_valve1_sw,
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {918, 288, 17, 17},
        drf = fire_valve2_sw,
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {823, 364, 17, 17},
        drf = fire_valve3_sw,
        sound = switch_sound
    }, 
    
    -- fuel pump 1 (3-state 0..2)
    stepButton {
        position = {823, 288, 17, 8},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(pump1_switch)
            if a < 2 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(pump1_switch, a)
        end
    }, 
    
    stepButton {
        position = {823, 297, 17, 8},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(pump1_switch)
            if a > 0 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(pump1_switch, a)
        end
    }, 
    
    -- fuel pump 4 (3-state 0..2)
    stepButton {
        position = {897, 288, 17, 8},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(pump4_switch)
            if a < 2 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(pump4_switch, a)
        end
    }, 
    
    stepButton {
        position = {897, 297, 17, 8},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(pump4_switch)
            if a > 0 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(pump4_switch, a)
        end
    }, 
    
    -- fuel pump 2 / 3 / fuel circle valve
    toggleSwitch {
        position = {842, 288, 17, 17},
        drf = pump2_switch,
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {879, 288, 17, 17},
        drf = pump3_switch,
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {861, 288, 17, 17},
        drf = fuel_circle_valve_sw,
        sound = switch_sound
    }, 
    
    -- fuel stop caps left / right
    toggleSwitch {
        position = {34, 450, 34, 40},
        drf = fuel_stop1_cap,
        sound = cap_sound
    }, 
    
    toggleSwitch {
        position = {68, 450, 34, 40},
        drf = fuel_stop2_cap,
        sound = cap_sound
    }, 
    
    -- fuel stop left / right (only act while their cap is open)
    toggleSwitch {
        position = {1002, 372, 18, 18},
        drf = fuel_stop1,
        sound = switch_sound,
        guard = function()
            return get(fuel_stop1_cap) == 1
        end
    }, 
    
    toggleSwitch {
        position = {1020, 372, 18, 18},
        drf = fuel_stop2,
        sound = switch_sound,
        guard = function()
            return get(fuel_stop2_cap) == 1
        end
    }
}
