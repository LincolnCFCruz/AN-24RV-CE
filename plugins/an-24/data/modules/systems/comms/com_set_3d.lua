size = {80, 80}

-- define property table
defineProperty("frequency", globalProperty("sim/cockpit2/radios/actuators/com1_frequency_hz")) -- set the frequency

-- images table
defineProperty("glass_cap", sasl.gl.loadImage("scales_1.png", 142, 62, 78, 32))
defineProperty("digitsImage", sasl.gl.loadImage("white-digits.png", 3, 60, 10, 196))

-- variables for separate manipulations
local freq_100 = 0 -- digits before period
local freq_10 = 0 -- digits after period

local freq_10_show = 0

local rot_click = loadSample('sounds/custom/rot_click.wav')

function update()
    local freq = get(frequency)

    -- calculate separate digits
    freq_100 = math.floor(freq / 100) -- cut off last two digits
    freq_10 = freq - freq_100 * 100 -- cut off first digits

    local freq_last = freq_10 - math.floor(freq_10 / 10) * 10
    if freq_last == 2 or freq_last == 7 then
        freq_last = 5
    else
        freq_last = 0
    end

    freq_10_show = freq_10 * 10 + freq_last
end

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
        digits = 3,
        showLeadingZeros = true,
        value = function()
            return freq_10_show
        end
    }, 
    
    -- glass cap image
    texture {
        position = {0, 43, 80, 36},
        image = get(glass_cap)
    }, 
    
--[[
    -- left knob
    needle {
        position = { 17, 49, 43, 43 },
        image = get(small_knob),
        angle = function()
           return (freq_100 - 118) * 40
        end,

    },

    -- right knob
    needle {
        position = { 139, 49, 43, 43 },
        image = get(small_knob),
        angle = function()
           return freq_10 * 36 / 5
        end,
    },
--]]

    -----------------
    -- click zones --
    -----------------

    -- click zones for left knob (hundreds digit: 118..136 wrap)
    stepButton {
        position = {0, 0, 18, 35},
        cursor = Cursors.ROTATE_LEFT,
        sound = rot_click,
        onStep = function()
            freq_100 = freq_100 - 1
            if freq_100 < 118 then
                freq_100 = 136
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
            if freq_100 > 136 then
                freq_100 = 118
            end
            set(frequency, freq_100 * 100 + freq_10)
        end
    }, 
    
    -- click zones for right knob (decimals digit: 0..97 wrap)
    stepButton {
        position = {43, 0, 18, 35},
        cursor = Cursors.ROTATE_LEFT,
        sound = rot_click,
        onStep = function()
            freq_10 = math.floor((freq_10_show - 25) / 10)
            if freq_10 < 0 then
                freq_10 = 97
            end
            set(frequency, freq_100 * 100 + freq_10)
        end
    }, 
    
    stepButton {
        position = {62, 0, 18, 35},
        cursor = Cursors.ROTATE_RIGHT,
        sound = rot_click,
        onStep = function()
            freq_10 = math.floor((freq_10_show + 25) / 10)
            if freq_10 > 97 then
                freq_10 = 0
            end
            set(frequency, freq_100 * 100 + freq_10)
        end
    }
}
