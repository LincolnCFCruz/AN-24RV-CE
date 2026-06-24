-- this script contains components for fuel system manipulation and indication
size = {600, 850}

-- Define commands
defineProperty("fuel_subpanel", globalProperty("an-24/panels/fuel_subpanel"))

-- define property table
-- switchers
defineProperty("fire_valve1_sw", globalProperty("an-24/fuel/fire_valve1_sw")) -- fire valve switch for engine 1
defineProperty("fire_valve2_sw", globalProperty("an-24/fuel/fire_valve2_sw")) -- fire valve switch for engine 2
defineProperty("fire_valve3_sw", globalProperty("an-24/fuel/fire_valve3_sw")) -- fire valve switch for engine 3
defineProperty("fuel_circle_valve_sw", globalProperty("an-24/fuel/fuel_circle_valve_sw")) -- valve for fuel circulation between left and right tanks
defineProperty("pump1_switch", globalProperty("an-24/fuel/pump1_switch")) -- fuel pump switch tank 1
defineProperty("pump2_switch", globalProperty("an-24/fuel/pump2_switch")) -- fuel pump switch tank 2
defineProperty("pump3_switch", globalProperty("an-24/fuel/pump3_switch")) -- fuel pump switch tank 3
defineProperty("pump4_switch", globalProperty("an-24/fuel/pump4_switch")) -- fuel pump switch tank 4
defineProperty("q_meter1_switch", globalProperty("an-24/fuel/q_meter1_switch")) -- switcher for quantity meter left
defineProperty("q_meter2_switch", globalProperty("an-24/fuel/q_meter2_switch")) -- switcher for quantity meter right
defineProperty("ff_meter_switch", globalProperty("an-24/fuel/ff_meter_switch")) -- switcher for fuel flow meter
defineProperty("auto_ff_switch", globalProperty("an-24/fuel/auto_ff_switch")) -- switcher for fuel flow automat
defineProperty("quantity_mode", globalProperty("an-24/fuel/quantity_mode")) -- mode of quantity meter

defineProperty("fuel_pump_1", globalProperty("an-24/fuel/tank1_pump")) -- fuel pump for tank 1
defineProperty("fuel_pump_2", globalProperty("an-24/fuel/tank2_pump")) -- fuel pump for tank 2
defineProperty("fuel_pump_3", globalProperty("an-24/fuel/tank3_pump")) -- fuel pump for tank 3
defineProperty("fuel_pump_4", globalProperty("an-24/fuel/tank4_pump")) -- fuel pump for tank 4
defineProperty("fuel_circle_valve", globalProperty("an-24/fuel/fuel_circle_valve")) -- valve for fuel circulation between left and right tanks
defineProperty("mixt_valve1", globalProperty("an-24/fuel/fuel_access1")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("mixt_valve2", globalProperty("an-24/fuel/fuel_access2")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich
defineProperty("mixt_valve3", globalProperty("an-24/fuel/fuel_access3")) -- Mixture Control (per engine), 0 = cutoff, 1 = full rich

defineProperty("quant_1000_lit", globalProperty("an-24/fuel/quant_1000_lit")) --
defineProperty("left_filter_block_lit", globalProperty("an-24/fuel/left_filter_block_lit")) --
defineProperty("right_filter_block_lit", globalProperty("an-24/fuel/right_filter_block_lit")) --
defineProperty("fuel_circle_lit", globalProperty("an-24/fuel/fuel_circle_lit")) --
defineProperty("left_fuel_press_lit", globalProperty("an-24/fuel/left_fuel_press_lit")) --
defineProperty("right_fuel_press_lit", globalProperty("an-24/fuel/right_fuel_press_lit")) --
defineProperty("left_pk_open_lit", globalProperty("an-24/fuel/left_pk_open_lit")) --
defineProperty("right_pk_open_lit", globalProperty("an-24/fuel/right_pk_open_lit")) --
defineProperty("left_chip_lit", globalProperty("an-24/fuel/left_chip_lit")) --
defineProperty("right_chip_lit", globalProperty("an-24/fuel/right_chip_lit")) --
defineProperty("fuel_lump1_lit", globalProperty("an-24/fuel/fuel_lump1_lit")) --
defineProperty("fuel_lump2_lit", globalProperty("an-24/fuel/fuel_lump2_lit")) --
defineProperty("fuel_lump3_lit", globalProperty("an-24/fuel/fuel_lump3_lit")) --
defineProperty("fuel_lump4_lit", globalProperty("an-24/fuel/fuel_lump4_lit")) --
defineProperty("fuel_flow_left_angle", globalProperty("an-24/fuel/fuel_flow_left_angle")) --
defineProperty("fuel_flow_right_angle", globalProperty("an-24/fuel/fuel_flow_right_angle")) --
defineProperty("fuel_flow_left_count", globalProperty("an-24/fuel/fuel_flow_left_count")) --
defineProperty("fuel_flow_right_count", globalProperty("an-24/fuel/fuel_flow_right_count")) --
defineProperty("fuel_flow_left_count_rot", globalProperty("an-24/fuel/fuel_flow_left_count_rot")) --
defineProperty("fuel_flow_right_count_rot", globalProperty("an-24/fuel/fuel_flow_right_count_rot")) --
defineProperty("fuel_quant1_angle", globalProperty("an-24/fuel/fuel_quant1_angle")) --
defineProperty("fuel_quant2_angle", globalProperty("an-24/fuel/fuel_quant2_angle")) --
defineProperty("fuel_quant_button", globalProperty("an-24/fuel/fuel_quant_button")) --

-- images
defineProperty("yellow_led", loadLED("yellow"))
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))

defineProperty("needle_q_left", langImage("needles", 32, 20, 17, 141))
defineProperty("needle_q_right", langImage("needles", 48, 20, 17, 141))
defineProperty("needle_long", langImage("needles", 67, 7, 16, 179))

defineProperty("digitsImage", sasl.gl.loadImage("white_digit_strip.png", 0, 60, 16, 196))

defineProperty("yellow_cap", langImage("covers", 204, 72, 56, 56)) -- yellow cap image

defineProperty("tmb_up", sasl.gl.loadImage("tumbler_up.dds"))
defineProperty("tmb_dn", sasl.gl.loadImage("tumbler_down.dds"))
defineProperty("tmb_ctr", sasl.gl.loadImage("tumbler_center.dds"))

local mode_ndl_img = sasl.gl.loadImage("fuel_panel_2d_e.dds", 6, 103, 30, 142) -- mode switcher needle

-- bool2int(): shared helper in core/glbl_func.lua

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

local mode_angle = 0
local left_filter_lit = false
local right_filter_lit = false
-- post frame calculations
function update()
    q_left_angle = get(fuel_quant1_angle)
    q_right_angle = get(fuel_quant2_angle)

    fuel_show_left = get(fuel_flow_left_count)
    ff1_actual_angle = get(fuel_flow_left_angle)
    fuel_show_right = get(fuel_flow_right_count)
    ff2_actual_angle = get(fuel_flow_right_angle)

    mode_angle = -50 + get(quantity_mode) * 33
    fuel_1000_lit = get(quant_1000_lit) == 1
    left_filter_lit = get(left_filter_block_lit) == 1
    right_filter_lit = get(right_filter_block_lit) == 1

    fuel_circle_led = get(fuel_circle_lit) == 1
    fuel_press_left_led = get(left_fuel_press_lit) == 1
    fuel_press_right_led = get(right_fuel_press_lit) == 1

    pump1_led = get(fuel_lump1_lit) == 1
    pump2_led = get(fuel_lump2_lit) == 1
    pump3_led = get(fuel_lump3_lit) == 1
    pump4_led = get(fuel_lump4_lit) == 1

    fire_v1_led = get(left_pk_open_lit) == 1
    fire_v2_led = get(right_pk_open_lit) == 1
    chip_left = get(left_chip_lit) == 1
    chip_right = get(right_chip_lit) == 1
end

components = { 
    -- background
    texture {
        image = langImage("fuel_panel_2d", 0, 299, 512, 725),
        position = {0, 0, size[1], size[2]}
    }, 
    
    -------------------
    -- needle gauges --
    -------------------

    -- quantity meter. left needle
    needle {
        image = function()
            return get(needle_q_left)
        end,
        position = {442, 418, 130, 130},
        angle = function()
            return q_left_angle
        end
    }, 
    
    -- quantity meter. right needle
    needle {
        image = function()
            return get(needle_q_right)
        end,
        position = {442, 418, 130, 130},
        angle = function()
            return q_right_angle
        end
    }, 
    
    -- yellow cap
    texture {
        position = {482, 458, 50, 50},
        image = function()
            return get(yellow_cap)
        end
    }, 
    
    -- quantity mode
    needle {
        image = get(mode_ndl_img),
        position = {422, 200, 166, 166},
        angle = function()
            return mode_angle
        end
    }, 
    
    -- control button (momentary)
    momentaryButton {
        position = {483, 390, 50, 50},
        drf = fuel_quant_button,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- mode changer (4-state 0..3)
    stepButton {
        position = {470, 240, 35, 70},
        cursor = Cursors.ROTATE_LEFT,
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
        position = {505, 240, 35, 70},
        cursor = Cursors.ROTATE_RIGHT,
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
        position = {75, 167, 65, 20},
        image = digitsImage,
        digits = 3,
        allowNonRound = false,
        showLeadingZeros = true,
        value = function()
            return fuel_show_left;
        end
    }, 
    
    needle {
        image = function()
            return get(needle_long)
        end,
        position = {21, 132, 170, 170},
        angle = function()
            return ff1_actual_angle
        end
    }, 
    
    -- counter rotary
    rotary {
        -- image = rotaryImage;
        value = fuel_flow_left_count_rot,
        step = 10,
        position = {75, 100, 70, 50},

        -- round counter
        adjuster = function(v)
            sasl.al.playSample(rot_click, false)
            return math.ceil(v / 10) * 10
        end
    }, 
    
    -- right counter
    digitstape {
        position = {280, 167, 65, 20},
        image = digitsImage,
        digits = 3,
        allowNonRound = false,
        showLeadingZeros = true,
        value = function()
            return fuel_show_right;
        end
    }, 
    
    needle {
        image = function()
            return get(needle_long)
        end,
        position = {227, 132, 170, 170},
        angle = function()
            return ff2_actual_angle
        end
    }, 
    
    -- counter rotary
    rotary {
        -- image = rotaryImage;
        value = fuel_flow_right_count_rot,
        step = 10,
        position = {280, 100, 70, 50},

        -- round counter
        adjuster = function(v)
            sasl.al.playSample(rot_click, false)
            return math.ceil(v / 10) * 10
        end
    }, 
    
    ------------------
    -- panel lights --
    ------------------
    
    -- fuel quantity less than 1000kg
    textureLit {
        image = get(red_led),
        position = {484, 726, 38, 38},
        visible = function()
            return fuel_1000_lit
        end
    }, 
    
    -- left filter block
    textureLit {
        image = get(yellow_led),
        position = {442, 634, 38, 38},
        visible = function()
            return left_filter_lit
        end
    }, 
    
    -- right filter block
    textureLit {
        image = get(yellow_led),
        position = {529, 634, 38, 38},
        visible = function()
            return right_filter_lit
        end
    }, 
    
    -- fuel circle
    textureLit {
        image = get(yellow_led),
        position = {189, 782, 32, 32},
        visible = function()
            return fuel_circle_led
        end
    }, 
    
    -- fuel pressure left
    textureLit {
        image = get(green_led),
        position = {22, 755, 32, 32},
        visible = function()
            return fuel_press_left_led
        end
    }, 
    
    -- fuel pressure right
    textureLit {
        image = get(green_led),
        position = {357, 755, 32, 32},
        visible = function()
            return fuel_press_right_led
        end
    }, 
    
    -- fuel pump 1
    textureLit {
        image = get(green_led),
        position = {75, 660, 32, 32},
        visible = function()
            return pump1_led
        end
    }, 
    
    -- fuel pump 2
    textureLit {
        image = get(green_led),
        position = {139, 660, 32, 32},
        visible = function()
            return pump2_led
        end
    }, 
    
    -- fuel pump 3
    textureLit {
        image = get(green_led),
        position = {240, 560, 32, 32},
        visible = function()
            return pump3_led
        end
    }, 
    
    -- fuel pump 2
    textureLit {
        image = get(green_led),
        position = {139, 560, 32, 32},
        visible = function()
            return pump2_led
        end
    }, 
    
    -- fuel pump 3
    textureLit {
        image = get(green_led),
        position = {240, 660, 32, 32},
        visible = function()
            return pump3_led
        end
    }, 
    
    -- fuel pump 4
    textureLit {
        image = get(green_led),
        position = {304, 660, 32, 32},
        visible = function()
            return pump4_led
        end
    }, 
    
    -- fire valve 1 ON
    textureLit {
        image = get(green_led),
        position = {22, 560, 32, 32},
        visible = function()
            return fire_v1_led
        end
    }, 
    
    -- fire valve 2 ON
    textureLit {
        image = get(green_led),
        position = {357, 560, 32, 32},
        visible = function()
            return fire_v2_led
        end
    }, 
    
    -- chip left
    textureLit {
        image = get(red_led),
        position = {20, 348, 35, 35},
        visible = function()
            return chip_left
        end
    }, 
    
    -- chip right
    textureLit {
        image = get(red_led),
        position = {357, 350, 35, 35},
        visible = function()
            return chip_right
        end
    }, 
    
    ---------------------
    -- panel switchers --
    ---------------------
    
    
    -- fire valves 1 / 2
    toggleSwitch {
        position = {25, 420, 30, 100},
        drf = fire_valve1_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {360, 420, 30, 100},
        drf = fire_valve2_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    -- fuel pump 1 (3-state 0..2)
    texture {
        position = {85, 420, 30, 100},
        image = function()
            local a = get(pump1_switch)
            local pic
            if a == 0 then
                pic = get(tmb_dn)
            elseif a == 1 then
                pic = get(tmb_ctr)
            else
                pic = get(tmb_up)
            end
            return pic
        end
    }, 
    
    stepButton {
        position = {85, 470, 30, 50},
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
        position = {85, 420, 30, 50},
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
    texture {
        position = {301, 420, 30, 100},
        image = function()
            local a = get(pump4_switch)
            local pic
            if a == 0 then
                pic = get(tmb_dn)
            elseif a == 1 then
                pic = get(tmb_ctr)
            else
                pic = get(tmb_up)
            end
            return pic
        end
    }, 
    
    stepButton {
        position = {301, 470, 30, 50},
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
        position = {301, 420, 30, 50},
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
        position = {140, 420, 30, 100},
        drf = pump2_switch,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {247, 420, 30, 100},
        drf = pump3_switch,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {195, 420, 30, 100},
        drf = fuel_circle_valve_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    -- fuel q-meters / flow meter / flow automat (intentionally silent)
    toggleSwitch {
        position = {32, -15, 30, 100},
        drf = q_meter1_switch,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn)
    }, 
    
    toggleSwitch {
        position = {135, -15, 30, 100},
        drf = q_meter2_switch,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn)
    }, 
    
    toggleSwitch {
        position = {232, -15, 30, 100},
        drf = ff_meter_switch,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn)
    }, 
    
    toggleSwitch {
        position = {467, -15, 30, 100},
        drf = auto_ff_switch,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn)
    }
}
