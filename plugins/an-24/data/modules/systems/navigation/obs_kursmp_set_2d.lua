size = {200, 200}

-- define property table
defineProperty("obs", globalProperty("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot")) -- set the course
defineProperty("fromto", globalProperty("an-24/gauges/obs1_fromto")) -- set the from or to course
defineProperty("fromto_lit", globalProperty("an-24/gauges/obs1_fromto_lit")) -- Nav-To-From indication, nav1, pilot, 0 is flag, 1 is to, 2 is from.
-- images table
defineProperty("digitsImage", sasl.gl.loadImage("white-digits.png", 3, 60, 10, 196))
defineProperty("tmb_up", sasl.gl.loadImage("tumbler_up.dds"))
defineProperty("tmb_dn", sasl.gl.loadImage("tumbler_down.dds"))

local obs_num = get(obs)
local fromto_light = get(fromto_lit)

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

function update()
    obs_num = get(obs)
    fromto_light = get(fromto_lit)
end

-- device consist of several components

components = { 
    ------------
    -- images --
    ------------

    -- black hole
    rectangle {
        position = {50, 82, 40, 17},
        color = {0, 0, 0, 1}
    }, 
    
    -- digits
    digitstape {
        position = {50, 80, 40, 20},
        image = digitsImage,
        digits = 3,
        showLeadingZeros = true,
        allowNonRound = true,
        -- fractional = 2,
        value = function()
            return obs_num
        end
    }, 
    
    -- to lamp
    textureLit {
        position = {117, 117, 17, 12},
        image = langImage("navigator_panel_2d", 1000, 304, 17, 12),
        visible = function()
            return fromto_light == 1
        end

    }, 
    
    -- from lamp
    textureLit {
        position = {110, 69, 30, 12},
        image = langImage("navigator_panel_2d", 994, 288, 30, 12),
        visible = function()
            return fromto_light == 2
        end

    }, 
    
    -----------------
    -- click zones --
    -----------------

    -- from/to switcher
    toggleSwitch {
        position = {115, 55, 20, 80},
        drf = fromto,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    -- rotary for curse set
    rotary {
        -- image = rotaryImage;
        value = obs,
        step = 1,
        position = {100, 35, 55, 40},
        adjuster = function(v)
            sasl.al.playSample(rot_click, false)
            v = math.floor(v + 0.5)
            if v > 359 then
                v = v - 360
            elseif v < 0 then
                v = v + 360
            end
            return v
        end
    }
}
