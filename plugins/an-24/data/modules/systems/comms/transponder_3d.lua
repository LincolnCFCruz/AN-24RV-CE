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

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

local emergency = false
local power = false -- transponder's power

-- Shadow of the crew-set code, edited/shown while an emergency 7700 is squawked.
local current_code = get(xpdr_code)

function getDigits(squawk)
    local thousands = math.floor(squawk / 1000)
    local hundreds  = math.floor(squawk / 100) % 10
    local tens      = math.floor(squawk / 10) % 10
    local ones      = squawk % 10

    return thousands, hundreds, tens, ones
end

local function getCode()
    if emergency then 
        return current_code 
    else 
        return get(xpdr_code) 
    end
end

local function setCode(code)
    if emergency then
        current_code = code
    else
        set(xpdr_code, code)
    end
end

-- Sets one squawk digit (1..4). Value is clamped to 0..7.
local function setDigit(index, value)
    local clamped = math.clamp(0, value, 7)

    local digits = { getDigits(getCode()) }
    digits[index] = clamped

    setCode(
        digits[1] * 1000 +
        digits[2] * 100 +
        digits[3] * 10 +
        digits[4]
    )

    return clamped
end

function update()
    power = get(sq_sw) > 0 and (get(xpdr_fail) or 0) < 6 and get(bus_DC_27_volt_emerg) > 21
    if power then
        set(xpdr_mode, get(sq_mode))
        set(sq_cc, 3)
    else
        set(xpdr_mode, 0)
        set(sq_cc, 0)
    end

    -- mirror the live code onto the public digit datarefs (3D knobs + 2D readout)
    local d1, d2, d3, d4 = getDigits(getCode())
    set(digit_1, d1)
    set(digit_2, d2)
    set(digit_3, d3)
    set(digit_4, d4)
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
            return setDigit(1, v)
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
            return setDigit(2, v)
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
            return setDigit(3, v)
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
            return setDigit(4, v)
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
                    current_code = get(xpdr_code)
                    set(xpdr_code, 7700)
                else
                    set(emerg, 0)
                    set(xpdr_code, current_code)
                end
            end
            return true
        end,
        onMouseUp = function()
            sasl.al.playSample(btn_click, false)
            return true
        end
    }
}