size = {266, 115}

-- define property table
-- V11/XP12 FIX: switched from dme_frequency_hz to nav2_frequency_hz (see dme_set.lua).
defineProperty("frequency", globalProperty("sim/cockpit2/radios/actuators/nav2_frequency_hz")) -- set the frequency (XP12: NAV2)
defineProperty("power_sw", globalProperty("an-24/gauges/dme_on")) -- power switcher

-- images table
defineProperty("glass_cap", sasl.gl.loadImage("scales_1.png", 142, 62, 78, 32))
defineProperty("digitsImage", sasl.gl.loadImage("white-digits.png", 3, 60, 10, 196))
defineProperty("tmb_up", sasl.gl.loadImage("tumbler_up.dds"))
defineProperty("tmb_dn", sasl.gl.loadImage("tumbler_down.dds"))

-- variables for separate manipulations
local freq_100 = 0
local freq_10 = 0
local rot_click = loadSample('sounds/custom/rot_click.wav')
local switch_sound = loadSample('sounds/custom/metal_switch.wav')

function update()
    local freq = get(frequency)

    -- calculate separate digits
    freq_100 = math.floor(freq / 100) -- cut off last two digits
    freq_10 = freq - freq_100 * 100 -- cut off first digits

end

-- device consists of several components

components = { 
    ------------
    -- images --
    ------------

    -- hundreds digits
    digitstape {
        position = {90, 70, 35, 25},
        image = digitsImage,
        digits = 3,
        showLeadingZeros = false,
        value = function()
            return freq_100
        end
    }, 
    
    -- decimals digits
    digitstape {
        position = {145, 70, 30, 25},
        image = digitsImage,
        digits = 2,
        showLeadingZeros = true,
        value = function()
            return freq_10
        end
    }, 
    
    -- glass cap image
    texture {
        position = {84, 58, 100, 50},
        image = get(glass_cap)
    }, 
    
    -- fake tumbler
    texture {
        position = {30, 57, 20, 60},
        image = get(tmb_dn)
    }, 
    
    -----------------
    -- click zones --
    -----------------

    -- DME power switch
    toggleSwitch {
        position = {212, 57, 20, 60},
        drf = power_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    -- click zones for left knob (hundreds digit: 108..117 wrap)
    stepButton {
        position = {10, 10, 30, 40},
        cursor = Cursors.ROTATE_LEFT,
        sound = rot_click,
        onStep = function()
            freq_100 = freq_100 - 1
            if freq_100 < 108 then
                freq_100 = 117
            end
            set(frequency, freq_100 * 100 + freq_10)
        end
    }, 
    
    stepButton {
        position = {40, 10, 30, 40},
        cursor = Cursors.ROTATE_RIGHT,
        sound = rot_click,
        onStep = function()
            freq_100 = freq_100 + 1
            if freq_100 > 117 then
                freq_100 = 108
            end
            set(frequency, freq_100 * 100 + freq_10)
        end
    }, 
    
    -- click zones for right knob (decimals digit: 0..95 step 5, snapped to /5)
    stepButton {
        position = {195, 10, 30, 40},
        cursor = Cursors.ROTATE_LEFT,
        sound = rot_click,
        onStep = function()
            freq_10 = freq_10 - 5
            if freq_10 < 0 then
                freq_10 = 95
            end
            local a, b = math.modf(freq_10 / 5)
            if b ~= 0 then
                freq_10 = a * 5
            end
            set(frequency, freq_100 * 100 + freq_10)
        end
    }, 
    
    stepButton {
        position = {225, 10, 30, 40},
        cursor = Cursors.ROTATE_RIGHT,
        sound = rot_click,
        onStep = function()
            freq_10 = freq_10 + 5
            if freq_10 > 95 then
                freq_10 = 0
            end
            local a, b = math.modf(freq_10 / 5)
            if b ~= 0 then
                freq_10 = a * 5
            end
            set(frequency, freq_100 * 100 + freq_10)
        end
    }
}
