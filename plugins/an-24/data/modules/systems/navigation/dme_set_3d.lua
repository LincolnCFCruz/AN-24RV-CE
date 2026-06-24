size = {80, 80}

-- define property table
-- V11/XP12 FIX: switched from dme_frequency_hz to nav2_frequency_hz. In XP11
-- tuning NAV2 also tuned the DME; XP12 separated them — restore XP11 behaviour.
defineProperty("frequency", globalProperty("sim/cockpit2/radios/actuators/nav2_frequency_hz")) -- set the frequency (XP12: NAV2)

-- images table
defineProperty("glass_cap", sasl.gl.loadImage("scales_1.png", 142, 62, 78, 32))
defineProperty("digitsImage", sasl.gl.loadImage("white-digits.png", 3, 60, 10, 196))

-- variables for separate manipulations
local freq_100 = 0
local freq_10 = 0

local rot_click = loadSample('sounds/custom/rot_click.wav')

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
        position = {5, 50, 30, 20},
        image = digitsImage,
        digits = 3,
        showLeadingZeros = false,
        value = function()
            return freq_100
        end
    }, 
    
    -- decimals digits
    digitstape {
        position = {45, 50, 30, 20},
        image = digitsImage,
        digits = 2,
        showLeadingZeros = true,
        value = function()
            return freq_10
        end
    }, 
    
    -- glass cap image
    texture {
        position = {0, 43, 80, 36},
        image = get(glass_cap)
    }, 
    
    -----------------
    -- click zones --
    -----------------

    -- click zones for left knob (hundreds digit: 108..117 wrap)
    stepButton {
        position = {0, 0, 18, 35},
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
        position = {19, 0, 18, 35},
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
        position = {43, 0, 18, 35},
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
        position = {62, 0, 18, 35},
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
