size = {58, 51}

-- define peoperty table
defineProperty("xpdr_code", globalProperty("sim/cockpit/radios/transponder_code"))
defineProperty("xpdr_mode", globalProperty("sim/cockpit/radios/transponder_mode"))
defineProperty("xpdr_led", globalProperty("sim/cockpit/radios/transponder_light"))
ident = findCommand("sim/transponder/transponder_ident") -- comand of transponder ident
-- XP12: rel_g_xpndr no longer exists; the transponder failure is rel_xpndr
defineProperty("xpdr_fail", globalProperty("sim/operation/failures/rel_xpndr"))

-- digits
defineProperty("digit_1", globalProperty("an-24/sq/digit_1"))
defineProperty("digit_2", globalProperty("an-24/sq/digit_2"))
defineProperty("digit_3", globalProperty("an-24/sq/digit_3"))
defineProperty("digit_4", globalProperty("an-24/sq/digit_4"))

-- switchers
defineProperty("emerg", globalProperty("an-24/sq/emerg"))
defineProperty("sq_emerg_cap", globalProperty("an-24/sq/sq_emerg_cap"))
defineProperty("sq_mode", globalProperty("an-24/sq/sq_mode"))

-- power
defineProperty("sq_sw", globalProperty("an-24/sq/sq_sw"))
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("sq_cc", globalProperty("an-24/sq/sq_cc"))

-- initial switchers values
defineProperty("N1", globalProperty("sim/flightmodel/engine/ENGN_N2_[0]"))
defineProperty("N2", globalProperty("sim/flightmodel/engine/ENGN_N2_[1]"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

local time_counter = 0
local not_loaded = true

function update()
    -- initial switchers values
    time_counter = time_counter + get(frame_time)
    if get(N1) < 70 and get(N2) < 70 and time_counter > 0.3 and time_counter < 0.4 and not_loaded then
        set(sq_sw, 0)
        not_loaded = false
    end
end

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

local emergency = false
local power = false -- transponder's power
local last_code = get(xpdr_code)

function getDigits(squawk)
    local d1 = math.floor(squawk / 1000)
    squawk = squawk - d1 * 1000
    local d2 = math.floor(squawk / 100)
    squawk = squawk - d2 * 100
    local d3 = math.floor(squawk / 10)
    local d4 = squawk - d3 * 10
    return d1, d2, d3, d4
end

-- set transponder code
function setSquawk(d1, d2, d3, d4)
    last_code = d1 * 1000 + d2 * 100 + d3 * 10 + d4
    if not emergency then
        set(xpdr_code, last_code)
    else
        set(xpdr_code, 7700)
    end
end

-- first digit of squawk code
defineProperty("code_1", function()
    local d1, d2, d3, d4 = getDigits(last_code)
    return d1
end)

-- second digit of squawk code
defineProperty("code_2", function(self, value)
    local d1, d2, d3, d4 = getDigits(last_code)
    return d2
end)

-- third digit of squawk code
defineProperty("code_3", function(self, value)
    local d1, d2, d3, d4 = getDigits(last_code)
    return d3
end)

-- last digit of squawk code
defineProperty("code_4", function(self, value)
    local d1, d2, d3, d4 = getDigits(last_code)
    return d4
end)

-- set knobs initial positions
set(digit_1, get(code_1))
set(digit_2, get(code_2))
set(digit_3, get(code_3))
set(digit_4, get(code_4))

function update()
    power = get(sq_sw) > 0 and (get(xpdr_fail) or 0) < 6 and get(bus_DC_27_volt_emerg) > 21
    if power then
        set(xpdr_mode, get(sq_mode))
        set(sq_cc, 3)
    else
        set(xpdr_mode, 0)
        set(sq_cc, 0)
    end
end

-- transponder cosist of several components

components = { 
    -- power switch
    toggleSwitch {
        position = {27, 40, 8, 8},
        drf = sq_sw,
        sound = switch_sound
    }, 
    
    -- mode knob rotary
    rotary {
        position = {29, 15, 10, 10},
        value = sq_mode,
        step = 1,
        adjuster = function(v)
            if v >= 0 and v <= 3 then
                sasl.al.playSample(plastic_sound, false)
            end
            if v > 3 then
                v = 3
            end
            if v < 0 then
                v = 0
            end
            return v
        end
    }, 
    
    -- digit rotaries
    
    -- digit 1
    rotary {
        position = {4, 2, 10, 10},
        value = digit_1,
        adjuster = function(v)
            if v >= 0 and v <= 7 then
                sasl.al.playSample(plastic_sound, false)
            end
            if 0 > v then
                v = 0;
            elseif 7 < v then
                v = 7
            end
            local d1, d2, d3, d4 = getDigits(last_code)
            setSquawk(v, d2, d3, d4)
            return v
        end
    }, 
    
    -- digit 2
    rotary {
        position = {17, 2, 10, 10},
        value = digit_2,
        adjuster = function(v)
            if v >= 0 and v <= 7 then
                sasl.al.playSample(plastic_sound, false)
            end
            if 0 > v then
                v = 0;
            elseif 7 < v then
                v = 7
            end
            local d1, d2, d3, d4 = getDigits(last_code)
            setSquawk(d1, v, d3, d4)
            return v
        end
    }, 
    
    -- digit 3
    rotary {
        position = {31, 2, 10, 10},
        value = digit_3,
        adjuster = function(v)
            if v >= 0 and v <= 7 then
                sasl.al.playSample(plastic_sound, false)
            end
            if 0 > v then
                v = 0;
            elseif 7 < v then
                v = 7
            end
            local d1, d2, d3, d4 = getDigits(last_code)
            setSquawk(d1, d2, v, d4)
            return v
        end
    }, 
    
    -- digit 4
    rotary {
        position = {45, 2, 10, 10},
        value = digit_4,
        adjuster = function(v)
            if v >= 0 and v <= 7 then
                sasl.al.playSample(plastic_sound, false)
            end
            if 0 > v then
                v = 0;
            elseif 7 < v then
                v = 7
            end
            local d1, d2, d3, d4 = getDigits(last_code)
            setSquawk(d1, d2, d3, v)
            return v
        end
    }, 
    
    -- ident button
    clickable {
        position = {10, 30, 8, 8},
        cursor = Cursors.HAND,
        onMouseDown = function()
            sasl.al.playSample(btn_click, false)
            if power then
                commandOnce(ident)
            end
            return true
        end,
        onMouseUp = function()
            sasl.al.playSample(btn_click, false)
            return true
        end
    }, 
    
    -- emergency button
    clickable {
        position = {2, 38, 8, 8},
        cursor = Cursors.HAND,
        onMouseDown = function()
            if get(sq_emerg_cap) > 0 then
                sasl.al.playSample(btn_click, false)
                emergency = not emergency
                if emergency then
                    set(emerg, 1)
                else
                    set(emerg, 0)
                end
                local d1, d2, d3, d4 = getDigits(last_code)
                setSquawk(d1, d2, d3, d4)
            end
            return true
        end,
        onMouseUp = function()
            sasl.al.playSample(btn_click, false)
            return true
        end
    }
}