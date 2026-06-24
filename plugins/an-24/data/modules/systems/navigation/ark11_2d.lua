size = {505, 455}

defineProperty("dev_num", 0)
defineProperty("radio", globalProperty("sim/cockpit2/radios/actuators/adf1_frequency_hz"))
defineProperty("adf", globalProperty("sim/cockpit2/radios/indicators/adf1_relative_bearing_deg"))
defineProperty("fail", globalProperty("sim/operation/failures/rel_adf1"))
defineProperty("ark_need_freq", globalProperty("an-24/ark/ark1_need_freq"))
defineProperty("ark_band_need", globalProperty("an-24/ark/ark1_band_need"))
defineProperty("ark_tune_need", globalProperty("an-24/ark/ark1_tune_need"))
defineProperty("ark_fine_tune_need", globalProperty("an-24/ark/ark1_fine_tune_need"))
defineProperty("audio_selection", globalProperty("sim/cockpit2/radios/actuators/audio_selection_adf1"))
defineProperty("cw_sw", globalProperty("an-24/ark/ark1_cw"))
defineProperty("button", globalProperty("an-24/ark/ark1_button"))
defineProperty("ark_mode", globalProperty("an-24/ark/ark1_mode"))
defineProperty("ark_band", globalProperty("an-24/ark/ark1_band"))
defineProperty("band_fix", globalProperty("an-24/ark/ark1_band_fix"))
defineProperty("ark_tune", globalProperty("an-24/ark/ark1_tune"))
defineProperty("tune_fix", globalProperty("an-24/ark/ark1_tune_fix"))
defineProperty("ark_fine_tune", globalProperty("an-24/ark/ark1_fine_tune"))
defineProperty("ant_sw", globalProperty("an-24/ark/ark1_ant_sw"))
-- images
defineProperty("digitsImage", sasl.gl.loadImage("white_digit_strip.png", 0, 60, 16, 196))
defineProperty("scale", sasl.gl.loadImage("ark_scale.png", 0, 0, 1024, 190))
defineProperty("scale_plank", sasl.gl.loadImage("ark_scale.png", 0, 191, 1, 65))
-- buttons
defineProperty("butP", sasl.gl.loadImage("radio_panel_2d_e.dds", 2, 301, 30, 30))
defineProperty("but1", sasl.gl.loadImage("radio_panel_2d_e.dds", 31, 301, 30, 30))
defineProperty("but2", sasl.gl.loadImage("radio_panel_2d_e.dds", 60, 301, 30, 30))
defineProperty("but3", sasl.gl.loadImage("radio_panel_2d_e.dds", 90, 301, 30, 30))
defineProperty("but4", sasl.gl.loadImage("radio_panel_2d_e.dds", 120, 301, 30, 30))
defineProperty("but5", sasl.gl.loadImage("radio_panel_2d_e.dds", 150, 301, 30, 30))
defineProperty("but6", sasl.gl.loadImage("radio_panel_2d_e.dds", 180, 301, 30, 30))
defineProperty("but7", sasl.gl.loadImage("radio_panel_2d_e.dds", 210, 301, 30, 30))
defineProperty("but8", sasl.gl.loadImage("radio_panel_2d_e.dds", 240, 301, 30, 30))
defineProperty("but9", sasl.gl.loadImage("radio_panel_2d_e.dds", 270, 301, 30, 30))
-- knobs
defineProperty("rot_switch", sasl.gl.loadImage("rot_switch.dds"))
defineProperty("knob_close", sasl.gl.loadImage("radio_panel_2d_e.dds", 0, 163, 116, 116))
defineProperty("knob_open", sasl.gl.loadImage("radio_panel_2d_e.dds", 132, 163, 116, 116))
defineProperty("knob_simple", sasl.gl.loadImage("radio_panel_2d_e.dds", 260, 163, 116, 116))
-- tumbler
defineProperty("tmb_left", sasl.gl.loadImage("tumbler_left.dds"))
defineProperty("tmb_right", sasl.gl.loadImage("tumbler_right.dds"))
defineProperty("tmb_ctr_hor", sasl.gl.loadImage("tumbler_center_hor.dds"))

local button_pressed = 0 -- actual pressed button
local mode_angle = -90
local band_img
local tune_img
local band_angle = 0
local tune_angle = 0
local fine_angle = 0
local tumbler_img
local band_counter = get(ark_band_need) -- width of visible window area
local winWidth = 72 / 1024 -- height of one degree in texture coord
local step = 160 / 950
local tune_pos = (0.036 - winWidth / 2) + step * (get(ark_tune_need)) / 29.09

-- click sounds (mirroring the 3D ark11)
local plastic_button = loadSample('sounds/custom/plastic_btn.wav')
local rot_click = loadSample('sounds/custom/rot_click.wav')
local cap_sound = loadSample('sounds/custom/cap.wav')

function update()
    button_pressed = get(button)
    mode_angle = get(ark_mode) * 45 - 90
    if get(band_fix) == 0 then
        band_img = get(knob_close)
    else
        band_img = get(knob_open)
    end
    if get(tune_fix) == 0 then
        tune_img = get(knob_close)
    else
        tune_img = get(knob_open)
    end
    band_angle = get(ark_band) * 40 / 132.5 + 160
    tune_angle = -get(ark_tune) * 2.25 + 160
    fine_angle = -get(ark_fine_tune) - 20
    local tumbler = get(ant_sw)
    if tumbler == 0 then
        tumbler_img = get(tmb_ctr_hor)
    elseif tumbler == 1 then
        tumbler_img = get(tmb_right)
    else
        tumbler_img = get(tmb_left)
    end

    band_counter = get(ark_band_need)
    tune_pos = (0.036 - winWidth / 2) + step * (get(ark_tune_need)) / 29.09
end

-- width of visible window area
local winWidth = 72 / 1024

-- height of one degree in texture coord
local step = 160 / 950

-- Preset selector button (mirrors the 3D ark11 click). P (v=0) always
-- re-selects; 1..9 only fire when the selection changes.
local function presetBtn(v, x, y, always)
    return stepButton {
        position = {x, y, 35, 35},
        cursor = Cursors.HAND,
        onStep = function()
            if always or button_pressed ~= v then
                button_pressed = v
                set(button, button_pressed)
                playUISound(plastic_button)
            end
        end
    }
end

components = { 
    ----------------
    -- indicators --
    ----------------

    -- band counter
    digitstape {
        position = {113, 143, 50, 22},
        image = digitsImage,
        digits = 4,
        allowNonRound = true,
        showLeadingZeros = false,
        value = function()
            return band_counter
        end
    }, 
    
    -- tune
    tape {
        position = {205, 310, 100, 140},
        image = get(scale),
        window = {winWidth, 1.0},
        -- calculate pitch level
        scrollX = function()
            return tune_pos;
        end
    }, 
    
    -- scale plank
    texture {
        position = {254, 310, 2, 140},
        image = get(scale_plank)
    }, 
    
    ------------
    -- images --
    ------------

    -- P
    texture {
        position = {44, 234, 30, 30},
        image = get(butP),
        visible = function()
            return button_pressed ~= 0
        end
    }, 
    
    -- 1
    texture {
        position = {9, 209, 30, 30},
        image = get(but1),
        visible = function()
            return button_pressed ~= 1
        end
    }, 
    
    -- 2
    texture {
        position = {9, 164, 30, 30},
        image = get(but2),
        visible = function()
            return button_pressed ~= 2
        end
    }, 
    
    -- 3
    texture {
        position = {9, 119, 30, 30},
        image = get(but3),
        visible = function()
            return button_pressed ~= 3
        end
    }, 
    
    -- 4
    texture {
        position = {9, 74, 30, 30},
        image = get(but4),
        visible = function()
            return button_pressed ~= 4
        end
    }, 
    
    -- 5
    texture {
        position = {9, 25, 30, 30},
        image = get(but5),
        visible = function()
            return button_pressed ~= 5
        end
    }, 
    
    -- 6
    texture {
        position = {44, 50, 30, 30},
        image = get(but6),
        visible = function()
            return button_pressed ~= 6
        end
    }, 
    
    -- 7
    texture {
        position = {44, 100, 30, 30},
        image = get(but7),
        visible = function()
            return button_pressed ~= 7
        end
    }, 
    
    -- 8
    texture {
        position = {44, 145, 30, 30},
        image = get(but8),
        visible = function()
            return button_pressed ~= 8
        end
    }, 
    
    -- 9
    texture {
        position = {44, 190, 30, 30},
        image = get(but9),
        visible = function()
            return button_pressed ~= 9
        end
    }, 
    
    -- mode switcher
    needle {
        position = {25, 340, 80, 80},
        image = get(rot_switch),
        angle = function()
            return mode_angle
        end
    }, 
    
    -- band switcher
    needle {
        position = {82, 33, 116, 116},
        image = function()
            return band_img
        end,
        angle = function()
            return band_angle
        end
    }, 
    
    -- tune switcher
    needle {
        position = {198, 205, 116, 116},
        image = function()
            return tune_img
        end,
        angle = function()
            return tune_angle
        end
    }, 
    
    -- fine tune switcher
    needle {
        position = {380, 325, 116, 116},
        image = get(knob_simple),
        angle = function()
            return fine_angle
        end
    }, 
    
    -- antenna switcher
    texture {
        position = {342, 45, 100, 30},
        image = function()
            return tumbler_img
        end
    }, 
    
    -------------
    -- buttons --
    -------------
    presetBtn(0, 40, 230, true), -- P (always re-selects)
    presetBtn(1, 5, 205), 
    presetBtn(2, 5, 160), 
    presetBtn(3, 5, 115), 
    presetBtn(4, 5, 70), 
    presetBtn(5, 5, 25),
    presetBtn(6, 40, 50), 
    presetBtn(7, 40, 95), 
    presetBtn(8, 40, 140), 
    presetBtn(9, 40, 185), 
    
    ----------
    -- mode --
    ----------

    rotary {
        position = {25, 340, 80, 70},
        value = ark_mode,
        adjuster = function(v)
            playUISound(plastic_button)
            if 0 > v then
                v = 0;
            elseif 4 < v then
                v = 4
            end
            return v
        end
    }, 
    
    ---------------
    -- band knob --
    ---------------

    -- rotate left
    stepButton {
        position = {90, 40, 50, 100},
        cursor = Cursors.ROTATE_LEFT,
        sound = rot_click,
        -- bands are 120, 280, 420, 580, 720, 880, 1020, 1180
        onStep = function()
            local B = get(ark_band_need)
            local T = get(ark_tune_need)
            if B == 120 then
                B = 1180
            elseif B == 280 or B == 580 or B == 880 or B == 1180 then
                B = B - 160
            else
                B = B - 140
            end
            set(ark_band_need, B)
            set(ark_need_freq, B + T)
        end
    }, 
    
    -- rotate right
    stepButton {
        position = {140, 40, 50, 100},
        cursor = Cursors.ROTATE_RIGHT,
        sound = rot_click,
        onStep = function()
            local B = get(ark_band_need)
            local T = get(ark_tune_need)
            if B == 1180 then
                B = 120
            elseif B == 120 or B == 420 or B == 720 or B == 1020 then
                B = B + 160
            else
                B = B + 140
            end
            set(ark_band_need, B)
            set(ark_need_freq, B + T)
        end
    }, 
    
    ---------------
    -- tune knob --
    ---------------

    -- rotate left
    stepButton {
        position = {205, 210, 50, 100},
        cursor = Cursors.ROTATE_LEFT,
        sound = rot_click,
        onStep = function()
            local B = get(ark_band_need)
            local T = get(ark_tune_need)
            T = T + 4
            if T > 160 then
                T = 160
            end
            set(ark_tune_need, T)
            set(ark_need_freq, B + T)
        end
    }, 
    
    -- rotate right
    stepButton {
        position = {255, 210, 50, 100},
        cursor = Cursors.ROTATE_RIGHT,
        sound = rot_click,
        onStep = function()
            local B = get(ark_band_need)
            local T = get(ark_tune_need)
            T = T - 4
            if T < 0 then
                T = 0
            end
            set(ark_tune_need, T)
            set(ark_need_freq, B + T)
        end
    }, 
    
    --------------------
    -- fine tune knob --
    --------------------

    -- rotate left
    stepButton {
        position = {390, 330, 50, 100},
        cursor = Cursors.ROTATE_LEFT,
        sound = rot_click,
        onStep = function()
            local B = get(ark_band_need)
            local T = get(ark_tune_need)
            local FT = get(ark_fine_tune)
            T = T + 1
            if T > 160 then
                T = 160
            else
                FT = FT + 5
            end
            set(ark_tune_need, T)
            set(ark_need_freq, B + T)
            set(ark_fine_tune, FT)
        end
    }, 
    
    -- rotate right
    stepButton {
        position = {440, 330, 50, 100},
        cursor = Cursors.ROTATE_RIGHT,
        sound = rot_click,
        onStep = function()
            local B = get(ark_band_need)
            local T = get(ark_tune_need)
            local FT = get(ark_fine_tune)
            T = T - 1
            if T < 0 then
                T = 0
            else
                FT = FT - 5
            end
            set(ark_tune_need, T)
            set(ark_need_freq, B + T)
            set(ark_fine_tune, FT)
        end
    }, 
    
    ---------------------
    -- save freq fixes --
    ---------------------

    -- save switch band (click-only, cap sound)
    toggleSwitch {
        position = {90, 160, 100, 50},
        drf = band_fix,
        sound = cap_sound
    }, 
    
    -- save switch tune (click-only, cap sound)
    toggleSwitch {
        position = {205, 160, 100, 50},
        drf = tune_fix,
        sound = cap_sound
    }, 
    
    -- frame tumbler (momentary: hold to slew the loop antenna, release to stop)
    
    -- rotate right
    momentaryButton {
        position = {395, 35, 50, 50},
        cursor = Cursors.ROTATE_RIGHT,
        drf = ant_sw,
        onValue = 1
    }, 
    -- rotate left
    momentaryButton {
        position = {340, 35, 50, 50},
        cursor = Cursors.ROTATE_LEFT,
        drf = ant_sw,
        onValue = -1
    }
}
