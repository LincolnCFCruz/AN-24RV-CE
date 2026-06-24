-- this is fire panel
size = {2048, 2048}
-- define property table
-- switchers and buttons
defineProperty("fire_main_switcher", globalProperty("an-24/fire/fire_main_switcher")) -- main switcher for fire system.
defineProperty("fire_left_wing_btn", globalProperty("an-24/fire/fire_left_wing_btn")) -- fire in left wing button
defineProperty("fire_left_wing_lit", globalProperty("an-24/fire/fire_left_wing_lit")) -- fire in left wing light
defineProperty("fire_right_wing_btn", globalProperty("an-24/fire/fire_right_wing_btn")) -- fire in right wing button
defineProperty("fire_right_wing_lit", globalProperty("an-24/fire/fire_right_wing_lit")) -- fire in right wing light
defineProperty("fire_left_nacelle_btn", globalProperty("an-24/fire/fire_left_nacelle_btn")) -- fire in left nacelle button
defineProperty("fire_left_nacelle_lit", globalProperty("an-24/fire/fire_left_nacelle_lit")) -- fire in left nacelle light
defineProperty("fire_right_nacelle_btn", globalProperty("an-24/fire/fire_right_nacelle_btn")) -- fire in right nacelle button
defineProperty("fire_right_nacelle_lit", globalProperty("an-24/fire/fire_right_nacelle_lit")) -- fire in right nacelle light
defineProperty("fire_ru19_btn", globalProperty("an-24/fire/fire_ru19_btn")) -- fire in ru19 button
defineProperty("fire_ru19_lit", globalProperty("an-24/fire/fire_ru19_lit")) -- fire in ru19 light
-- engines lamps and buttons
defineProperty("fire_left_eng_lit", globalProperty("an-24/fire/fire_left_eng_lit")) -- fire in left engine light
defineProperty("fire_right_eng_lit", globalProperty("an-24/fire/fire_right_eng_lit")) -- fire in right engine light
defineProperty("ext_left_ready_lit", globalProperty("an-24/fire/ext_left_ready_lit")) -- left engine extinguisher ready
defineProperty("ext_right_ready_lit", globalProperty("an-24/fire/ext_right_ready_lit")) -- right engine extinguisher ready
defineProperty("ext_first_ready_lit", globalProperty("an-24/fire/ext_first_ready_lit")) -- furst turn extinguisher ready
defineProperty("ext_second_ready_lit", globalProperty("an-24/fire/ext_second_ready_lit")) -- second turn extinguisher ready
defineProperty("fire_left_eng_ext", globalProperty("an-24/fire/fire_left_eng_ext")) -- button for left engine fire extinguisher
defineProperty("fire_left_eng_ext_cap", globalProperty("an-24/fire/fire_left_eng_ext_cap")) -- cap for button for left engine fire extinguisher
defineProperty("fire_right_eng_ext", globalProperty("an-24/fire/fire_right_eng_ext")) -- button for right engine fire extinguisher
defineProperty("fire_right_eng_ext_cap", globalProperty("an-24/fire/fire_right_eng_ext_cap")) -- cap for button for right engine fire extinguisher
defineProperty("fire_second_ext", globalProperty("an-24/fire/fire_second_ext")) -- button for second turn fire extinguisher
defineProperty("fire_second_ext_cap", globalProperty("an-24/fire/fire_second_ext_cap")) -- cap for button for second turn fire extinguisher
-- images
defineProperty("red_led", loadLED("red"))
defineProperty("yellow_small_led", loadLED("yellow_small"))
defineProperty("left_wing_fire_led", langImage("fire_lamps", 0, 0, 80, 64))
defineProperty("left_nacelle_fire_led", langImage("fire_lamps", 103, 0, 80, 64))
defineProperty("right_nacelle_fire_led", langImage("fire_lamps", 202, 0, 80, 64))
defineProperty("ru19_eng_fire_led", langImage("fire_lamps", 301, 0, 80, 64))
defineProperty("right_wing_fire_led", langImage("fire_lamps", 400, 0, 80, 64))

local left_wing_fire_light = get(fire_left_wing_lit) == 1
local left_nacelle_fire_light = get(fire_left_nacelle_lit) == 1
local right_nacelle_fire_light = get(fire_right_nacelle_lit) == 1
local ru19_fire_light = get(fire_ru19_lit) == 1
local right_wing_fire_light = get(fire_right_wing_lit) == 1
local left_eng_fire_light = get(fire_left_eng_lit) == 1
local right_eng_fire_light = get(fire_right_eng_lit) == 1
local left_eng_ext_ready_light = get(ext_left_ready_lit) == 1
local right_eng_ext_ready_light = get(ext_right_ready_lit) == 1
local first_turn_ext_light = get(ext_first_ready_lit) == 1
local second_turn_ext_light = get(ext_second_ready_lit) == 1

-- initial switchers values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

local time_counter = 0
local not_loaded = true

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

function update()
    -- initial switchers values
    time_counter = time_counter + get(frame_time)
    if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
        set(fire_main_switcher, 0)
        not_loaded = false
    end

    left_wing_fire_light = get(fire_left_wing_lit) == 1
    left_nacelle_fire_light = get(fire_left_nacelle_lit) == 1
    right_nacelle_fire_light = get(fire_right_nacelle_lit) == 1
    ru19_fire_light = get(fire_ru19_lit) == 1
    right_wing_fire_light = get(fire_right_wing_lit) == 1
    left_eng_fire_light = get(fire_left_eng_lit) == 1
    right_eng_fire_light = get(fire_right_eng_lit) == 1
    left_eng_ext_ready_light = get(ext_left_ready_lit) == 1
    right_eng_ext_ready_light = get(ext_right_ready_lit) == 1
    first_turn_ext_light = get(ext_first_ready_lit) == 1
    second_turn_ext_light = get(ext_second_ready_lit) == 1

end

components = {
    ------------------
    -- panel lights --
    ------------------

    -- left wing fire
    textureLit {
        image = function()
            return get(left_wing_fire_led)
        end,
        position = {1012, 566, 80, 64},
        visible = function()
            return left_wing_fire_light
        end
    }, 
    
    -- left nacelle fire
    textureLit {
        image = function()
            return get(left_nacelle_fire_led)
        end,
        position = {1114, 566, 80, 64},
        visible = function()
            return left_nacelle_fire_light
        end
    }, 
    
    -- right nacelle fire
    textureLit {
        image = function()
            return get(right_nacelle_fire_led)
        end,
        position = {1214, 566, 80, 64},
        visible = function()
            return right_nacelle_fire_light
        end
    }, 
    
    -- ru19 fire
    textureLit {
        image = function()
            return get(ru19_eng_fire_led)
        end,
        position = {1314, 566, 80, 64},
        visible = function()
            return ru19_fire_light
        end
    }, 
    
    -- right wing fire
    textureLit {
        image = function()
            return get(right_wing_fire_led)
        end,
        position = {1413, 566, 80, 64},
        visible = function()
            return right_wing_fire_light
        end
    }, 
    
    -- left engine fire
    textureLit {
        image = get(red_led),
        position = {698, 254, 17, 17},
        visible = function()
            return left_eng_fire_light
        end
    }, 
    
    -- right engine fire
    textureLit {
        image = get(red_led),
        position = {714, 254, 17, 17},
        visible = function()
            return right_eng_fire_light
        end
    }, 
    
    -- left engine ext ready
    textureLit {
        image = get(yellow_small_led),
        position = {510, 381, 27, 27},
        visible = function()
            return left_eng_ext_ready_light
        end
    }, 
    
    -- right engine ext ready
    textureLit {
        image = get(yellow_small_led),
        position = {510, 327, 27, 27},
        visible = function()
            return right_eng_ext_ready_light
        end
    }, 
    
    -- first turn ext ready
    textureLit {
        image = get(yellow_small_led),
        position = {510, 275, 27, 27},
        visible = function()
            return first_turn_ext_light
        end
    }, 
    
    -- second turn ext ready
    textureLit {
        image = get(yellow_small_led),
        position = {537, 381, 27, 27},
        visible = function()
            return second_turn_ext_light
        end
    }, 
    
    ----------------
    -- clickables --
    ----------------

    -- main switcher (3-state: -1..1)
    -- switch up
    stepButton {
        position = {1156, 261, 35, 17},
        cursor = Cursors.UP,
        onStep = function()
            local a = get(fire_main_switcher)
            if a < 1 then
                playUISound(switch_sound);
                a = a + 1
            end
            set(fire_main_switcher, a)
        end
    }, 
    
    -- switch down
    stepButton {
        position = {1156, 278, 35, 17},
        cursor = Cursors.DOWN,
        onStep = function()
            local a = get(fire_main_switcher)
            if a > -1 then
                playUISound(switch_sound);
                a = a - 1
            end
            set(fire_main_switcher, a)
        end
    }, 
    
    -- left engine ext cap
    toggleSwitch {
        position = {503, 412, 30, 35},
        drf = fire_left_eng_ext_cap,
        sound = cap_sound
    }, 
    
    -- left engine extinguisher (only acts while its cap is open)
    toggleSwitch {
        position = {1095, 280, 18, 18},
        drf = fire_left_eng_ext,
        sound = btn_click,
        guard = function()
            return get(fire_left_eng_ext_cap) == 1
        end
    }, 
    
    -- right engine ext cap
    toggleSwitch {
        position = {534, 412, 30, 35},
        drf = fire_right_eng_ext_cap,
        sound = cap_sound
    }, 
    
    -- right engine extinguisher (only acts while its cap is open)
    toggleSwitch {
        position = {1115, 280, 18, 18},
        drf = fire_right_eng_ext,
        sound = btn_click,
        guard = function()
            return get(fire_right_eng_ext_cap) == 1
        end
    }, 
    
    -- second turn ext cap
    toggleSwitch {
        position = {565, 412, 30, 35},
        drf = fire_second_ext_cap,
        sound = cap_sound
    }, 
    
    -- second turn extinguisher (only acts while its cap is open)
    toggleSwitch {
        position = {1134, 280, 18, 18},
        drf = fire_second_ext,
        sound = btn_click,
        guard = function()
            return get(fire_second_ext_cap) == 1
        end
    }, 
    
    -- fire-extinguisher discharge buttons (momentary)
    momentaryButton {
        position = {1011, 553, 90, 90},
        drf = fire_left_wing_btn,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {1105, 553, 90, 90},
        drf = fire_left_nacelle_btn,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {1202, 553, 90, 90},
        drf = fire_right_nacelle_btn,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {1302, 553, 90, 90},
        drf = fire_ru19_btn,
        sound = switch_sound,
        soundUp = switch_sound
    }, 
    
    momentaryButton {
        position = {1402, 553, 90, 90},
        drf = fire_right_wing_btn,
        sound = switch_sound,
        soundUp = switch_sound
    }
}
