size = {512, 380}

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
defineProperty("gear_valve", globalProperty("an-24/hydro/gear_valve")) -- position of gear valve for gydraulic calculations and animations maximum 160.
defineProperty("flaps_valve", globalProperty("an-24/hydro/flaps_valve")) -- position of flaps valve for gydraulic calculations and animations.
defineProperty("ap_panel_subpanel", globalProperty("an-24/panels/ap_panel_subpanel"))

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
defineProperty("tmb_up", sasl.gl.loadImage("tumbler_up.dds"))
defineProperty("tmb_dn", sasl.gl.loadImage("tumbler_down.dds"))
defineProperty("tmb_ctr", sasl.gl.loadImage("tumbler_center.dds"))
defineProperty("small_btn_dn", sasl.gl.loadImage("ap_panel_2d_e.dds", 122, 37, 36, 36))
defineProperty("small_btn_up", sasl.gl.loadImage("ap_panel_2d_e.dds", 164, 37, 36, 36))
defineProperty("flap_up_img", sasl.gl.loadImage("right_panel_2d_e.dds", 831, 329, 66, 66))
defineProperty("flap_ctr_img", sasl.gl.loadImage("right_panel_2d_e.dds", 831, 116, 66, 66))
defineProperty("flap_dn_img", sasl.gl.loadImage("right_panel_2d_e.dds", 831, 187, 66, 66))
defineProperty("gear_up_img", sasl.gl.loadImage("right_panel_2d_e.dds", 906, 329, 66, 66))
defineProperty("gear_ctr_img", sasl.gl.loadImage("right_panel_2d_e.dds", 906, 259, 66, 66))
defineProperty("gear_dn_img", sasl.gl.loadImage("right_panel_2d_e.dds", 906, 187, 66, 66))

-- commands
flaps_command_up = findCommand("sim/flight_controls/flaps_up")
flaps_command_down = findCommand("sim/flight_controls/flaps_down")
gear_command_up = findCommand("sim/flight_controls/landing_gear_up")
gear_command_down = findCommand("sim/flight_controls/landing_gear_down")

local flap_up_clicked = false
local flap_down_clicked = false

local ap_up_light = get(ap_up_lit) == 1
local ap_down_light = get(ap_down_lit) == 1
local ap_ready_light = get(ap_ready_lit) == 1
local ap_on_light = get(ap_on_lit) == 1
local ap_kv_light = get(ap_kv_lit) == 1
local roll_angle = get(ap_roll) * 3
local ap_on_img = get(small_btn_up)
local pitch_img = get(tmb_ctr)
local stab_img = get(tmb_up)
local hor_btn_img = get(small_btn_up)
local kv_btn_img = get(small_btn_up)
local flap_img = get(flap_ctr_img)
local gear_img = get(gear_ctr_img)

local switch_sound = loadSample('sounds/custom/metal_switch.wav')
local cap_sound = loadSample('sounds/custom/cap.wav')
local btn_click = loadSample('sounds/custom/plastic_btn.wav')
local rot_click = loadSample('sounds/custom/rot_click.wav')

function update()
    ap_up_light = get(ap_up_lit) == 1
    ap_down_light = get(ap_down_lit) == 1
    ap_ready_light = get(ap_ready_lit) == 1
    ap_on_light = get(ap_on_lit) == 1
    ap_kv_light = get(ap_kv_lit) == 1
    roll_angle = get(ap_roll) * 3

    if get(ap_ON) == 1 then
        ap_on_img = get(small_btn_dn)
    else
        ap_on_img = get(small_btn_up)
    end

    local a = get(ap_pitch)
    if a == 1 then
        pitch_img = get(tmb_dn)
    elseif a == -1 then
        pitch_img = get(tmb_up)
    else
        pitch_img = get(tmb_ctr)
    end

    local b = get(ap_curse_stab)
    if b == 0 then
        stab_img = get(tmb_dn)
    elseif b == 2 then
        stab_img = get(tmb_up)
    else
        stab_img = get(tmb_ctr)
    end

    if get(ap_horizont) == 1 then
        hor_btn_img = get(small_btn_dn)
    else
        hor_btn_img = get(small_btn_up)
    end

    if get(ap_kv) == 1 then
        kv_btn_img = get(small_btn_dn)
    else
        kv_btn_img = get(small_btn_up)
    end

    local c = get(flaps_valve)
    if c == 1 then
        flap_img = get(flap_dn_img)
    elseif c == -1 then
        flap_img = get(flap_up_img)
    else
        flap_img = get(flap_ctr_img)
    end

    local d = get(gear_valve)
    if d == 1 then
        gear_img = get(gear_dn_img)
    elseif d == -1 then
        gear_img = get(gear_up_img)
    else
        gear_img = get(gear_ctr_img)
    end

end

components = { 
    -- background
    texture {
        image = langImage("ap_panel_2d", 0, 132, size[1], size[2]),
        position = {0, 0, size[1], size[2]}
    }, 
    
    ------------
    -- lights --
    ------------

    -- AP up light
    textureLit {
        image = get(yellow_led),
        position = {127, 29, 20, 20},
        visible = function()
            return ap_up_light
        end
    }, 
    
    -- AP down light
    textureLit {
        image = get(yellow_led),
        position = {185, 29, 20, 20},
        visible = function()
            return ap_down_light
        end
    }, 
    
    -- AP ready light
    textureLit {
        image = get(yellow_led),
        position = {182, 345, 20, 20},
        visible = function()
            return ap_ready_light
        end
    }, 
    
    -- AP ON light
    textureLit {
        image = get(green_led),
        position = {297, 345, 20, 20},
        visible = function()
            return ap_on_light
        end
    }, 
    
    -- KV mode
    textureLit {
        image = get(green_led),
        position = {299, 29, 20, 20},
        visible = function()
            return ap_kv_light
        end
    }, 
    
    ----------------
    -- clickables --
    ----------------

    -- manual pitch
    -- image
    texture {
        position = {125, 255, 25, 80},
        image = function()
            return pitch_img
        end
    }, 
    
    texture {
        position = {350, 255, 25, 80},
        image = function()
            return pitch_img
        end
    }, 
    
    -- pitch UP (left + right buttons)
    momentaryButton {
        position = {115, 250, 40, 40},
        drf = ap_pitch,
        onValue = 1,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {345, 250, 40, 40},
        drf = ap_pitch,
        onValue = 1,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    -- pitch DOWN (left + right buttons)
    momentaryButton {
        position = {115, 300, 40, 40},
        drf = ap_pitch,
        onValue = -1,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {345, 300, 40, 40},
        drf = ap_pitch,
        onValue = -1,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    -- autotrim / power / pitch switchers
    toggleSwitch {
        position = {120, 90, 25, 80},
        drf = ap_trim,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {180, 90, 25, 80},
        drf = ap_power,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {355, 90, 25, 80},
        drf = ap_pitch_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    -- stab selector
    texture {
        position = {298, 90, 25, 80},
        image = function()
            return stab_img
        end
    }, 
    
    -- switch down / up (3-state 0..2)
    stepButton {
        position = {295, 90, 30, 40},
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
        position = {295, 130, 30, 40},
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
    
    -- roll knob
    -- image
    needle {
        position = {202, 245, 95, 95},
        image = langImage("ap_panel_2d", 6, 7, 95, 95),
        angle = function()
            return roll_angle
        end
    }, 
    
    -- roll left / right (-25..25, step 5, auto-repeats)
    stepButton {
        position = {190, 250, 50, 60},
        cursor = Cursors.ROTATE_LEFT,
        repeating = true,
        onStep = function()
            local a = get(ap_roll)
            if a > -25 then
                playUISound(rot_click);
                a = a - 5
            end
            set(ap_roll, a)
        end
    }, 
    
    -- roll right (-25..25, step 5, auto-repeats)
    stepButton {
        position = {260, 250, 50, 60},
        cursor = Cursors.ROTATE_RIGHT,
        repeating = true,
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
        position = {225, 320, 50, 40},
        cursor = Cursors.HAND,
        sound = rot_click,
        onStep = function()
            set(ap_roll, 0)
        end
    }, 
    
    -- button images
    texture {
        position = {233, 115, 36, 36},
        image = function()
            return ap_on_img
        end
    }, 
    
    -- engage AP (momentary)
    momentaryButton {
        position = {230, 110, 40, 40},
        drf = ap_ON,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- button images
    texture {
        position = {233, 20, 36, 36},
        image = function()
            return hor_btn_img
        end
    }, 
    
    -- button images
    texture {
        position = {349, 20, 36, 36},
        image = function()
            return kv_btn_img
        end
    }, 
    
    -- engage horizont mode (momentary)
    momentaryButton {
        position = {230, 15, 40, 40},
        drf = ap_horizont,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- engage alt hold mode (momentary)
    momentaryButton {
        position = {345, 15, 40, 40},
        drf = ap_kv,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
    -- flap images
    texture {
        position = {20, 200, 80, 80},
        image = function()
            return flap_img
        end
    }, 
    
    -- turn flaps UP
    clickable {
        position = {20, 250, 60, 60}, -- search and set right
        cursor = Cursors.HAND,
        onMouseDown = function()
            if not flap_up_clicked then
                sasl.al.playSample(switch_sound, false)
                commandBegin(flaps_command_up)
                flap_up_clicked = true
            end
            return true
        end,
        onMouseUp = function()
            sasl.al.playSample(switch_sound, false)
            commandEnd(flaps_command_up)
            flap_up_clicked = false
            return true
        end
    }, 
    
    -- turn flaps DOWN
    clickable {
        position = {20, 180, 60, 60}, -- search and set right
        cursor = Cursors.HAND,
        onMouseDown = function()
            if not flap_down_clicked then
                sasl.al.playSample(switch_sound, false)
                commandBegin(flaps_command_down)
                flap_down_clicked = true
            end
            return true
        end,
        onMouseUp = function()
            sasl.al.playSample(switch_sound, false)
            commandEnd(flaps_command_down)
            flap_down_clicked = false
            return true
        end
    }, 
    
    -- gear images
    texture {
        position = {410, 200, 80, 80},
        image = function()
            return gear_img
        end
    }, 
    
    -- turn gears UP / DOWN (single-action)
    stepButton {
        position = {420, 250, 60, 60},
        cursor = Cursors.HAND,
        sound = switch_sound,
        onStep = function()
            commandOnce(gear_command_up)
        end
    }, 
    
    stepButton {
        position = {420, 180, 60, 60},
        cursor = Cursors.HAND,
        sound = switch_sound,
        onStep = function()
            commandOnce(gear_command_down)
        end
    }
}
