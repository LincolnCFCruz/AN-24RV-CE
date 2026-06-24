size = {2048, 2048}

-- define properties
-- switchers and buttons
defineProperty("ap_power", globalProperty("an-24/ap/ap_power")) -- power of AP
defineProperty("ap_trim", globalProperty("an-24/ap/ap_trim")) -- use trimmer of AP
defineProperty("ap_ON", globalProperty("an-24/ap/ap_ON")) -- main button for engage AP
defineProperty("ap_kv", globalProperty("an-24/ap/ap_kv")) -- button for altitude hold
defineProperty("ap_horizont", globalProperty("an-24/ap/ap_horizont")) -- button to set horizontal position of plane
defineProperty("ap_curse_stab", globalProperty("an-24/ap/ap_curse_stab")) -- switcher for curse stab. turn/GPK/GIK
defineProperty("ap_pitch", globalProperty("an-24/ap/ap_pitch")) -- pitch control
defineProperty("ap_pitch_sw", globalProperty("an-24/ap/ap_pitch_sw")) -- engage pitch control
defineProperty("ap_roll", globalProperty("an-24/ap/ap_roll")) -- roll knob
defineProperty("ap_mech_off", globalProperty("an-24/ap/ap_mech_off")) -- ap mechanic off. o = mechanics works, 1 = mech off
defineProperty("ap_mech_off_cap", globalProperty("an-24/ap/ap_mech_off_cap")) -- ap mechanic off cap

-- lights
defineProperty("ap_ready_lit", globalProperty("an-24/ap/ap_ready_lit")) -- ready light
defineProperty("ap_on_lit", globalProperty("an-24/ap/ap_on_lit")) -- AP engaged light
defineProperty("ap_kv_lit", globalProperty("an-24/ap/ap_kv_lit")) -- alt stab engaged
defineProperty("ap_up_lit", globalProperty("an-24/ap/ap_up_lit")) -- AP feels UP force on stab
defineProperty("ap_down_lit", globalProperty("an-24/ap/ap_down_lit")) -- AP feels DOWN force on stab
defineProperty("ap_ail_fail_lit", globalProperty("an-24/ap/ap_ail_fail_lit")) -- aileron trim failed lamp
defineProperty("ap_elev_fail_lit", globalProperty("an-24/ap/ap_elev_fail_lit")) -- elevator trim failed lamp

-- images
defineProperty("yellow_led", loadLED("yellow"))
defineProperty("green_led", loadLED("green"))

local ap_up_light = get(ap_up_lit) == 1
local ap_down_light = get(ap_down_lit) == 1
local ap_ready_light = get(ap_ready_lit) == 1
local ap_on_light = get(ap_on_lit) == 1
local ap_kv_light = get(ap_kv_lit) == 1
local ap_elev_fail_light = get(ap_elev_fail_lit) == 1
local ap_ail_fail_light = get(ap_ail_fail_lit) == 1

local switch_sound = loadSample('sounds/custom/metal_switch.wav')
local cap_sound = loadSample('sounds/custom/cap.wav')
local btn_click = loadSample('sounds/custom/plastic_btn.wav')
local rot_click = loadSample('sounds/custom/rot_click.wav')

function update()
    -- cold-start reset of ap_power/ap_trim/ap_pitch_sw now owned by ap28_logic.lua
    ap_up_light = get(ap_up_lit) == 1
    ap_down_light = get(ap_down_lit) == 1
    ap_ready_light = get(ap_ready_lit) == 1
    ap_on_light = get(ap_on_lit) == 1
    ap_kv_light = get(ap_kv_lit) == 1
    ap_elev_fail_light = get(ap_elev_fail_lit) == 1
    ap_ail_fail_light = get(ap_ail_fail_lit) == 1
end

components = { 
    ------------
    -- lights --
    ------------

    -- AP force light
    textureLit {
        image = langImage("lamps", 0, 38, 50, 30),
        position = {1229, 517, 50, 30},
        visible = function()
            return ap_up_light or ap_down_light
        end
    }, 
    
    -- Elevator trim fail light
    textureLit {
        image = langImage("lamps", 150, 68, 50, 30),
        position = {1284, 517, 50, 30},
        visible = function()
            return ap_elev_fail_light
        end
    }, 
    
    -- Elevator trim fail light
    textureLit {
        image = langImage("lamps", 200, 68, 50, 30),
        position = {1340, 517, 50, 30},
        visible = function()
            return ap_ail_fail_light
        end
    }, 
    
    -- AP up light
    textureLit {
        image = get(yellow_led),
        position = {751, 290, 17, 17},
        visible = function()
            return ap_up_light
        end
    }, 
    
    -- AP down light
    textureLit {
        image = get(yellow_led),
        position = {767, 290, 17, 17},
        visible = function()
            return ap_down_light
        end
    }, 
    
    -- AP ready light
    textureLit {
        image = get(yellow_led),
        position = {720, 290, 17, 17},
        visible = function()
            return ap_ready_light
        end
    }, 
    
    -- AP ON light
    textureLit {
        image = get(green_led),
        position = {736, 289, 17, 17},
        visible = function()
            return ap_on_light
        end
    }, 
    
    -- KV mode
    textureLit {
        image = get(green_led),
        position = {783, 289, 17, 17},
        visible = function()
            return ap_kv_light
        end
    }, 
    
    ----------------
    -- clickables --
    ----------------

    -- manual pitch (momentary: up = +1, down = -1)
    momentaryButton {
        position = {1175, 373, 15, 7},
        drf = ap_pitch,
        onValue = 1,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {1175, 380, 15, 7},
        drf = ap_pitch,
        onValue = -1,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    -- autotrim / power / pitch switchers
    toggleSwitch {
        position = {1004, 356, 15, 15},
        drf = ap_trim,
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {1022, 356, 15, 15},
        drf = ap_power,
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {1059, 356, 15, 15},
        drf = ap_pitch_sw,
        sound = switch_sound
    }, 
    
    -- stab selector (3-state 0..2)
    stepButton {
        position = {1041, 364, 15, 7},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(ap_curse_stab)
            if a > 0 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(ap_curse_stab, a)
        end
    }, 
    
    stepButton {
        position = {1041, 355, 15, 7},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(ap_curse_stab)
            if a < 2 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(ap_curse_stab, a)
        end
    }, 
    
    -- roll knob (-25..25, step 5)
    stepButton {
        position = {145, 10, 20, 30},
        cursor = Cursors.ROTATE_LEFT,
        onStep = function()
            local a = get(ap_roll)
            if a > -25 then
                playUISound(rot_click);
                a = a - 5
            end
            set(ap_roll, a)
        end
    }, 
    
    stepButton {
        position = {175, 10, 20, 30},
        cursor = Cursors.ROTATE_RIGHT,
        onStep = function()
            local a = get(ap_roll)
            if a < 25 then
                playUISound(rot_click);
                a = a + 5
            end
            set(ap_roll, a)
        end
    }, 
    
    -- roll center (single-action reset)
    stepButton {
        position = {155, 40, 30, 20},
        cursor = Cursors.HAND,
        sound = rot_click,
        onStep = function()
            set(ap_roll, 0)
        end
    }, 
    
    -- engage AP / horizont / alt-hold (momentary)
    momentaryButton {
        position = {803, 426, 20, 20},
        drf = ap_ON,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    momentaryButton {
        position = {827, 427, 20, 20},
        drf = ap_horizont,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    momentaryButton {
        position = {850, 427, 20, 20},
        drf = ap_kv,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- mechanic off cap
    toggleSwitch {
        position = {167, 490, 35, 44},
        drf = ap_mech_off_cap,
        sound = cap_sound
    }, 
    
    -- mechanic off (only acts while its cap is open)
    toggleSwitch {
        position = {917, 345, 18, 18},
        drf = ap_mech_off,
        sound = switch_sound,
        guard = function()
            return get(ap_mech_off_cap) == 1
        end
    }
}
