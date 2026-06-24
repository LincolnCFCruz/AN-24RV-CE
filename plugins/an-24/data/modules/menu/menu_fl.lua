-- Flashlight toggle button (red / white / off cycle)

size = {45, 25}

local red_fl   = globalProperty("sim/graphics/misc/red_flashlight_on")
local white_fl = globalProperty("sim/graphics/misc/white_flashlight_on")
local language = globalProperty("an-24/set/language")

local flstate   = 0
local rot_click = loadSample("sounds/custom/rot_click.wav")

local bg = {
    [0] = {
        [0] = sasl.gl.loadImage("menu_flbg1_e.png"),
              sasl.gl.loadImage("menu_flbg2_e.png"),
              sasl.gl.loadImage("menu_flbg3_e.png"),
    },
    {
        [0] = sasl.gl.loadImage("menu_flbg1_r.png"),
              sasl.gl.loadImage("menu_flbg2_r.png"),
              sasl.gl.loadImage("menu_flbg3_r.png"),
    }
}

components = {
    switch {
        position    = {0, 1, 31, 23},
        onMouseDown = function()
            if get(red_fl) == 0 and get(white_fl) == 0 then
                set(red_fl, 1)
                flstate = 1
            elseif get(red_fl) == 1 then
                set(red_fl, 0)
                set(white_fl, 1)
                flstate = 2
            else
                set(white_fl, 0)
                flstate = 0
            end
            sasl.al.playSample(rot_click, false)
            return true
        end
    }
}

function draw()
    local lang = get(language)
    sasl.gl.drawTexture(bg[lang][flstate], 0, 0, 45, 25, {1, 1, 1, 1})
end
