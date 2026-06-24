size = {1024, 557}

defineProperty("curse_needle", langImage("needles", 218, 7, 87, 179))
defineProperty("needle_1", sasl.gl.loadImage("nas1_e.dds", 463, 4, 23, 237))
defineProperty("needle_2", sasl.gl.loadImage("nas1_e.dds", 403, 8, 28, 177))
defineProperty("overlay", sasl.gl.loadImage("nas1_e.dds", 0, 355, 35, 35))
defineProperty("delta_needle", sasl.gl.loadImage("nas1_e.dds", 205, 48, 25, 146))
defineProperty("map_needle", sasl.gl.loadImage("kppm.dds", -0.5, 59.5, 196, 196))
defineProperty("speed_needle", sasl.gl.loadImage("nas1_e.dds", 252, 138, 11, 56))
defineProperty("yellow", sasl.gl.loadImage("nas1_e.dds", 0, 316, 263, 17))
defineProperty("large_scale", sasl.gl.loadImage("nas1_e.dds", 896, 338, 128, 128))
defineProperty("checker", sasl.gl.loadImage("nas1_e.dds", 791, 411, 40, 16))
defineProperty("rotary", sasl.gl.loadImage("rot_switch.dds"))
defineProperty("digitsImage", sasl.gl.loadImage("white_digit_strip.png", 0, 60, 16, 196))
defineProperty("green_led", loadLED("green"))
defineProperty("red_led", loadLED("red"))
defineProperty("tmb_up", sasl.gl.loadImage("tumbler_up.dds"))
defineProperty("tmb_dn", sasl.gl.loadImage("tumbler_down.dds"))

defineProperty("deg1", globalProperty("sim/flightmodel/position/psi"))
defineProperty("deg2", globalProperty("sim/flightmodel/position/hpath"))
defineProperty("TAS", globalProperty("sim/flightmodel/position/true_airspeed"))
defineProperty("GS", globalProperty("sim/flightmodel/position/groundspeed"))
defineProperty("pitch", globalProperty("sim/flightmodel/position/theta"))
defineProperty("roll", globalProperty("sim/flightmodel/position/phi"))
-- defineProperty("waves", globalProperty("sim/weather/wave_amplitude")) -- xp11    new dref sim/weather/region/wave_amplitude
defineProperty("waves", globalProperty("sim/weather/region/wave_amplitude")) -- xp12  dref
defineProperty("rls_power_cc", globalProperty("an-24/rls/rls_power_cc"))
defineProperty("GPK_course", globalProperty("an-24/gauges/GPK_curse"))
defineProperty("elevation", globalProperty("sim/flightmodel/position/elevation"))
defineProperty("height", globalProperty("sim/flightmodel/position/y_agl"))
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("bus_AC_115_volt", globalProperty("an-24/power/bus_AC_115_volt"))
defineProperty("run_time", globalProperty("sim/time/total_running_time_sec"))
defineProperty("nas1_subpanel", globalProperty("an-24/panels/nas1_subpanel"))
defineProperty("nas1_cc", globalProperty("an-24/nas1/nas1_cc"))
defineProperty("dst1", globalProperty("an-24/nas1/N_needle"))
defineProperty("dst2", globalProperty("an-24/nas1/E_needle"))
defineProperty("counter", globalProperty("an-24/nas1/counter"))
defineProperty("mode1", globalProperty("an-24/nas1/mode1"))
defineProperty("mode2", globalProperty("an-24/nas1/mode2"))
defineProperty("map_angle", globalProperty("an-24/nas1/map_angle"))
defineProperty("water", globalProperty("an-24/nas1/water"))
defineProperty("DISS", globalProperty("an-24/nas1/DISS"))
defineProperty("winddelta", globalProperty("an-24/nas1/windangle"))
defineProperty("windspeed", globalProperty("an-24/nas1/windspeed"))

-- local get(dst1) = 0
-- local get(dst2) = 0
local diff = 0
local slip = 0
local speed = 0
local over_land = 0
local memory = 0
local windN = 0
local windE = 0
local slipneedle = 0
local preset1 = 0
local preset2 = 0
local presetangle = 0
local power1 = 0
local power2 = 0

-- local get(mode1) = 0
-- 0:off 1:on 2:Memory 3:High
-- local get(mode2) = 0
-- 0:land 1:sea 2:Contr1 3:contr2
local timer = get(run_time)

local windangle = 0

function update()
    -- automatic switching into memory mode
    if get(mode1) == 3 and get(DISS) == 1 then
        if get(pitch) > 10 or get(roll) > 10 or get(pitch) < -10 or get(roll) < -10 or get(rls_power_cc) < 1.5 then
            memory = 1
        else
            memory = 0
        end
    elseif get(mode1) == 2 then
        memory = 1
    else
        memory = 0
    end

    -- when flying over sea, the groundspeed is different
    over_land = math.abs(get(elevation) - get(height) - 3)
    if over_land > 1.1 then
        over_land = 1
    elseif over_land < 0.5 then
        over_land = 0
    else
        over_land = (over_land - 0.5) * 5 / 3
    end

    set(water, over_land)

    -- if the waves are to small, the radar signal is invalid
    if over_land < 1 and get(waves) < 0.1 and get(mode1) == 3 and get(DISS) == 1 then
        memory = 1
    end

    if presetangle > 359 then
        presetangle = presetangle - 360
    elseif presetangle < 0 then
        presetangle = presetangle + 360
    end

    if get(map_angle) > 360 then
        set(map_angle, get(map_angle) - 360)
    elseif get(map_angle) < 0 then
        set(map_angle, get(map_angle) + 360)
    end

    if get(windspeed) > 170 then
        set(windspeed, get(windspeed) - 175)
    elseif get(windspeed) < 0 then
        set(windspeed, get(windspeed) + 175)
    end

    if get(winddelta) > 360 then
        set(winddelta, get(winddelta) - 360)
    elseif get(winddelta) < 0 then
        set(winddelta, get(winddelta) + 360)
    end

    if get(mode1) < 0 then
        set(mode1, 0)
    elseif get(mode1) > 3 then
        set(mode1, 3)
    end

    if get(mode2) < 0 then
        set(mode2, 0)
    elseif get(mode2) > 3 then
        set(mode2, 3)
    end

    -- handle power
    local power27 = get(bus_DC_27_volt) > 21
    if power27 and acOK() then
        if get(counter) == 1 then
            power1 = 1
        else
            power1 = 0
        end
        if get(DISS) == 0 then
            power2 = 1
        else
            if get(mode1) == 1 or get(mode1) == 2 then
                power2 = 1
            elseif get(mode1) == 3 then
                power2 = 3
            else
                power2 = 0
            end
        end
    else
        power1 = 0
        power2 = 0
    end
    set(nas1_cc, (power1 + power2) * 3)

    -- THESE CALCULATION ARE DONE EVERY 0.05 SEC!
    if get(run_time) > timer then
        -- get(DISS) mode
        if get(DISS) == 1 and power2 > 0 then
            -- high mode: GS and slip are provide by the radar

            if get(mode1) < 2 then
                slip = 0
                speed = 0
            end

            -- get(DISS) all systems nominal
            if get(mode1) == 3 and memory == 0 then
                if get(mode2) == 0 then
                    speed = get(GS) * (1 - 0.025 * math.abs(over_land - 1))
                elseif get(mode2) == 1 then
                    speed = get(GS) * (1 + 0.025 * over_land)
                end
                slip = (get(deg2) - get(deg1))
            end

            -- test modes
            if get(mode1) == 3 and get(mode2) == 2 then
                speed = 176.4
                slip = 0
            elseif get(mode1) == 3 and get(mode2) == 3 then
                speed = 279.7
                slip = 9
            end

            -- In ANU (Automatic navigation device) we use TAS and windgauge to calculate path
        elseif get(DISS) == 0 and power2 > 0 then
            windangle = (get(map_angle) + get(winddelta)) * math.pi / 180
            if windangle > 2 * math.pi then
                windangle = windangle - 2 * math.pi
            end
            speed = math.sqrt((get(windspeed) / 3.6) ^ 2 + get(TAS) ^ 2 - 2 * get(windspeed) / 3.6 * get(TAS) *
                                  math.cos(get(GPK_course) * (math.pi / 180) - windangle))
            slip = math.atan2(get(windspeed) / 3.6 * math.sin(get(GPK_course) * (math.pi / 180) - windangle),
                get(TAS) - get(windspeed) / 3.6 * math.cos(get(GPK_course) * (math.pi / 180) - windangle)) * 180 /
                       math.pi
            -- no power? no indications!
        else
            speed = 0
            slip = 0
        end

        if slip < -180 then
            slip = slip + 360
        elseif slip > 180 then
            slip = slip - 360
        end

        diff = (get(GPK_course) + slip - get(map_angle)) * math.pi / 180

        -- now we calculate the deviation
        if get(counter) == 1 and power1 == 1 then
            set(dst1, get(dst1) + (math.cos(diff) * speed / 20000))
            set(dst2, get(dst2) + (math.sin(diff) * speed / 20000))
        end

        timer = timer + 0.05

        -- slip needs to be limited for the gauge
        slipneedle = slip * 6
        if slipneedle < -120 then
            slipneedle = -120
        elseif slipneedle > 120 then
            slipneedle = 120
        end

    end

end

components = {
    needle {
        position = {873, 440, 60, 60},
        image = get(large_scale),
        angle = function()
            return get(dst1) / -13.8889
        end,
        visible = true
    }, 
    
    texture {
        image = get(overlay),
        position = {854, 144, 60, 36},
        visible = true
    }, 
    
    texture {
        image = get(checker),
        position = {859, 149, 40, 16},
        visible = function()
            return memory == 1
        end
    }, 
    
    texture {
        position = {0, 0, 1024, 557},
        image = langImage("nas1", 0, 467, 1024, 557),
        visible = true
    }, 
    
    switch {
        position = {114, 261, 20, 80},
        state = function()
            return get(counter) ~= 0
        end,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        onMouseDown = function()
            if get(counter) ~= 0 then
                set(counter, 0)
            else
                set(counter, 1)
            end
            return true;
        end
    }, 
    
    switch {
        position = {892, 261, 20, 80},
        state = function()
            return get(DISS) ~= 0
        end,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        onMouseDown = function()
            if get(DISS) ~= 0 then
                set(DISS, 0)
            else
                set(DISS, 1)
            end
            return true;
        end
    }, 
    
    -- map angle
    needle {
        position = {16, 357, 168, 168},
        image = function()
            return get(curse_needle)
        end,
        angle = function()
            return get(map_angle)
        end,
        visible = true
    }, 
    
    texture {
        position = {82, 421, 35, 35},
        image = get(overlay),
        visible = true
    }, 
    
    clickable {
        position = {178, 430, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(map_angle, get(map_angle) - 2)
            return true
        end
    }, 
    
    clickable {
        position = {202, 430, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(map_angle, get(map_angle) + 2)
            return true
        end
    }, 
    
    -- big needle north
    needle {
        position = {233, 293, 237, 237},
        image = get(needle_1),
        angle = function()
            return get(dst1) / 0.0027778
        end,
        visible = true
    }, 
    
    needle {
        position = {285, 343, 136, 136},
        image = get(needle_2),
        angle = function()
            return get(dst1) / 0.27778
        end,
        visible = true
    }, 
    
    clickable {
        position = {464, 400, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst1, get(dst1) - 0.010)
            return true
        end
    }, 
    
    clickable {
        position = {488, 400, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst1, get(dst1) + 0.010)
            return true
        end
    }, 
    
    clickable {
        position = {476, 422, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst1, get(dst1) + 1)
            return true
        end
    }, 
    
    clickable {
        position = {476, 378, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst1, get(dst1) - 1)
            return true
        end
    }, 
    
    texture {
        position = {334, 393, 35, 35},
        image = langImage("nas1", 0, 427, 35, 35),
        visible = true
    }, 
    
    -- big needle east
    needle {
        position = {518, 293, 237, 237},
        image = get(needle_1),
        angle = function()
            return get(dst2) / 0.0027778
        end,
        visible = true
    }, 
    
    needle {
        position = {570, 343, 136, 136},
        image = get(needle_2),
        angle = function()
            return get(dst2) / 0.27778
        end,
        visible = true
    }, 
    
    clickable {
        position = {750, 400, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst2, get(dst2) - 0.010)
            return true
        end
    }, 
    
    clickable {
        position = {774, 400, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst2, get(dst2) + 0.010)
            return true
        end
    }, 
    
    clickable {
        position = {762, 422, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst2, get(dst2) + 1)
            return true
        end
    },
    
    clickable {
        position = {762, 378, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst2, get(dst2) - 1)
            return true
        end
    }, 
    
    texture {
        position = {620, 393, 35, 35},
        image = langImage("nas1", 0, 391, 35, 35),
        visible = true
    }, 
    
    -- combined
    needle {
        position = {819, 356, 168, 168},
        image = langImage("nas1", 48, 20, 17, 141),
        angle = function()
            return get(dst2) / 2.7778
        end,
        visible = true
    }, 
    
    needle {
        position = {819, 356, 168, 168},
        image = langImage("nas1", 32, 20, 17, 141),
        angle = function()
            return get(dst1) / 2.7778
        end,
        visible = true
    }, 
    
    texture {
        position = {886, 421, 35, 35},
        image = get(overlay),
        visible = true
    }, 
    
    clickable {
        position = {982, 443, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst1, get(dst1) - 10)
            return true
        end
    }, 
    
    clickable {
        position = {1006, 443, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst1, get(dst1) + 10)
            return true
        end
    }, 
    
    clickable {
        position = {982, 419, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst2, get(dst2) - 10)
            return true
        end
    }, 
    
    clickable {
        position = {1006, 419, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(dst2, get(dst2) + 10)
            return true
        end
    }, 
    
    -- TAS and slip
    digitstape {
        position = {850, 53, 56, 17},
        image = digitsImage,
        digits = 4,
        allowNonRound = false,
        showLeadingZeros = true,
        --	fractional = 0;
        showSign = false,
        value = function()
            return speed * 3.6
        end,
        visible = true
    }, 
    
    needle {
        position = {796, 35, 168, 168},
        image = function()
            return get(curse_needle)
        end,
        angle = function()
            return slipneedle
        end,
        visible = true
    }, 
    
    texture {
        position = {861, 101, 35, 35},
        image = get(overlay),
        visible = true
    }, 
    
    -- wind
    needle {
        position = {549, 34, 168, 168},
        image = get(map_needle),
        angle = function()
            return -get(map_angle)
        end,
        visible = true
    }, 
    
    needle {
        position = {560, 46, 146, 146},
        image = get(delta_needle),
        angle = function()
            return get(winddelta)
        end,
        visible = true
    }, 
    
    texture {
        position = {587, 74, 90, 116},
        image = langImage("nas1", 142, 300, 90, 116),
        visible = true
    }, 
    
    needle {
        position = {603, 91, 56, 56},
        image = get(speed_needle),
        angle = function()
            return get(windspeed) * 360 / 175 - 50
        end,
        visible = true
    }, 
    
    texture {
        position = {609, 98, 42, 42},
        image = langImage("nas1", 0, 220, 42, 42),
        visible = true
    }, 
    
    -- set windangle
    clickable {
        position = {710, 106, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(winddelta, get(winddelta) - 2)
            return true
        end
    }, 
    
    clickable {
        position = {734, 106, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(winddelta, get(winddelta) + 2)
            return true
        end
    }, 
    
    -- set get(windspeed)
    clickable {
        position = {610, 99, 20, 40},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(windspeed, get(windspeed) - 5)
            return true
        end
    }, 
    
    clickable {
        position = {634, 99, 20, 40},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(windspeed, get(windspeed) + 5)
            return true
        end
    }, 
    
    -- Mode panel
    needle {
        position = {71, 5, 120, 120},
        image = get(rotary),
        angle = function()
            return get(mode1) * 40 - 60
        end
    }, 
    
    clickable {
        position = {18, 25, 110, 110},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(mode1, get(mode1) - 1)
            return true
        end
    }, 
    
    clickable {
        position = {132, 25, 110, 110},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(mode1, get(mode1) + 1)

            return true
        end
    }, 
    
    needle {
        position = {305, 5, 120, 120},
        image = get(rotary),
        angle = function()
            return get(mode2) * 40 - 60
        end
    }, 
    
    clickable {
        position = {253, 25, 110, 110},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(mode2, get(mode2) - 1)
            return true
        end
    }, 
    
    clickable {
        position = {368, 25, 110, 110},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            set(mode2, get(mode2) + 1)
            return true
        end
    }, 
    
    textureLit {
        image = get(green_led),
        position = {45, 188, 32, 32},
        visible = function()
            return get(mode1) > 0 and power2 > 0
        end
    }, 
    
    textureLit {
        image = get(red_led),
        position = {444, 188, 32, 32},
        visible = function()
            return get(mode1) == 3 and power2 > 0
        end
    }, 
    
    -- preset map angle
    clickable {
        position = {82, 421, 35, 35},

        cursor = Cursors.HAND,

        onMouseDown = function()
            set(map_angle, presetangle)
            return true
        end
    }, 
    
    digitstape {
        position = {82, 534, 42, 17},
        image = digitsImage,
        digits = 3,
        allowNonRound = false,
        showLeadingZeros = true,
        --	fractional = 0;
        showSign = false,
        value = function()
            return presetangle
        end,
        visible = function()
            if presetangle == 0 then
                return false
            else
                return true
            end
        end
    }, 
    
    clickable {
        position = {82, 534, 42, 17},
        cursor = Cursors.HAND,
        onMouseDown = function()
            presetangle = 0
            return true
        end
    }, 
    
    clickable {
        position = {16, 500, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            presetangle = presetangle - 1
            return true
        end
    }, 
    
    clickable {
        position = {165, 500, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            presetangle = presetangle + 1
            return true
        end
    }, 
    
    -- preset get(dst1)
    clickable {
        position = {334, 393, 35, 35},
        cursor = Cursors.HAND,
        onMouseDown = function()
            set(dst1, preset1)
            return true
        end
    }, 
    
    digitstape {
        position = {334, 534, 56, 17},
        image = digitsImage,
        digits = 4,
        allowNonRound = false,
        showLeadingZeros = true,
        fractional = 1,
        showSign = true,
        value = function()
            return preset1
        end,
        visible = function()
            if preset1 == 0 then
                return false
            else
                return true
            end
        end
    }, 
    
    clickable {
        position = {334, 534, 56, 17},
        cursor = Cursors.HAND,
        onMouseDown = function()
            preset1 = 0
            return true
        end
    }, 
    
    clickable {
        position = {240, 494, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            preset1 = preset1 - 0.1
            return true
        end
    }, 
    
    clickable {
        position = {442, 494, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            preset1 = preset1 + 0.1
            return true
        end
    }, 
    
    -- preset get(dst2)
    clickable {
        position = {620, 393, 35, 35},
        cursor = Cursors.HAND,
        onMouseDown = function()
            set(dst2, preset2)

            return true
        end
    }, 
    
    digitstape {
        position = {620, 534, 56, 17},
        image = digitsImage,
        digits = 4,
        allowNonRound = false,
        showLeadingZeros = true,
        fractional = 1,
        showSign = true,
        value = function()
            return preset2
        end,
        visible = function()
            if preset2 == 0 then
                return false
            else
                return true
            end
        end
    }, 
    
    clickable {
        position = {620, 534, 56, 17},
        cursor = Cursors.HAND,
        onMouseDown = function()
            preset2 = 0
            return true
        end
    }, 
    
    clickable {
        position = {526, 494, 20, 20},
        cursor = Cursors.ROTATE_LEFT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            preset2 = preset2 - 0.1
            return true
        end
    }, 
    
    clickable {
        position = {728, 494, 20, 20},
        cursor = Cursors.ROTATE_RIGHT,
        onMouseHold = holdToRepeat(),
        onMouseDown = function()
            preset2 = preset2 + 0.1
            return true
        end
    }
}
