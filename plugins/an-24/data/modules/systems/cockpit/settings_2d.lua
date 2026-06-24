size = {560, 610}

-- define property table
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames
defineProperty("set_real_fuel_meter", globalProperty("an-24/set/real_fuel_meter")) -- real fuel meter will show less fuel amount, then it's really is
defineProperty("set_real_ahz", globalProperty("an-24/set/real_ahz")) -- real ahz has errors and needs to be corrected
defineProperty("set_real_fire", globalProperty("an-24/set/real_fire")) -- fire will affect wings and nearest mech
defineProperty("set_real_startup", globalProperty("an-24/set/real_startup")) -- when start the engines a lot of thing must to be done
defineProperty("set_active_camera", globalProperty("an-24/set/active_camera")) -- use of moveing camera
defineProperty("set_real_generators", globalProperty("an-24/set/real_generators")) -- generators can fail if overload
defineProperty("set_real_gears", globalProperty("an-24/set/real_gears")) --  gears can fail in overspeed
defineProperty("set_real_brakes", globalProperty("an-24/set/real_brakes")) -- brakes can overheat and fail
defineProperty("set_real_tyres", globalProperty("an-24/set/real_tyres")) -- tyres can blow if too much brakes
defineProperty("switch_rud", globalProperty("an-24/set/switch_rud")) -- switch or hold rud stopors
defineProperty("rud_close", globalProperty("an-24/misc/rud_close")) -- down RUD latch when hold mode is ON
defineProperty("north_GPK", globalProperty("an-24/set/north_GPK")) -- GPK mode for north hemisphere
defineProperty("real_fuel", globalProperty("an-24/set/real_fuel")) -- switch for real fuel system or FSE compability
defineProperty("rsbn_dataset", globalProperty("an-24/rsbn/dataset")) -- dataset, 0:CIS 1:USSR
defineProperty("black_box", globalProperty("an-24/set/black_box")) -- flight data recording
defineProperty("kln90b_pri", globalProperty("an-24/set/kln90b_pri")) -- flight data recording
defineProperty("kln90b_sec", globalProperty("an-24/set/kln90b_sec")) -- flight data recording
defineProperty("gns430_pri", globalProperty("an-24/set/gns430_pri")) -- by default Garmin is hiden
defineProperty("gns430_sec", globalProperty("an-24/set/gns430_sec")) -- by default Garmin is hiden

local sound_volume = globalPropertyf("an-24/set/sound_volume") -- created in glbl_drfs.lua (drf_set.sound_volume)
local kill_en = globalPropertyi("an-24/set/lang_kill_en") -- created in glbl_drfs.lua (drf_set.lang_kill_en)
local kill_ru = globalPropertyi("an-24/set/lang_kill_ru") -- created in glbl_drfs.lua (drf_set.lang_kill_ru)

local options_subpanel = globalProperty("an-24/panels/options_subpanel")
local park_pos = globalProperty("an-24/set/park_position")
local real_hl = globalProperty("an-24/set/real_headlight")
local reflections = globalProperty("an-24/set/reflections")
local language = globalProperty("an-24/set/language")

local last_vol = 1000
local notLoaded = true

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

-- images
defineProperty("tmb_up", sasl.gl.loadImage("tumbler_up.dds", 0, 20, 32, 88))
defineProperty("tmb_dn", sasl.gl.loadImage("tumbler_down.dds", 0, 20, 32, 88))
defineProperty("lever_image", sasl.gl.loadImage("lever.dds", 0, 10, 42, 52))

-- settings table
local settings_table = {}
settings_table["fuelmet"] = 1
settings_table["ahz"] = 1
settings_table["fire"] = 1
settings_table["startup"] = 1
settings_table["camera"] = 1
settings_table["generat"] = 1
settings_table["gears"] = 1
settings_table["brakes"] = 1
settings_table["tyres"] = 1
settings_table["hlight"] = 0
settings_table["ppark"] = 0
settings_table["kln90bp"] = 0
settings_table["kln90bs"] = 0
settings_table["gns430p"] = 0
settings_table["gns430s"] = 0
settings_table["rudsw"] = 0
settings_table["gpknrth"] = 1
settings_table["fuel"] = 1
settings_table["dataset"] = 1
settings_table["reflect"] = 1
settings_table["bbox"] = 0
settings_table["lang"] = 0
settings_table["volume"] = 1000

-- reading file or set properties with default values
function file_read()
    local filename = pluginDataDir .. "/output/an-24_settings.ini"
    local file = io.open(filename, "r")
    -- if file exist - read it and fill the variables with new values
    if file then
        local lines = file:read("*a")
        print("Reading settings...")
        print("-------------------")
        for k, v in string.gmatch(lines, "(%w+)=(%d+)") do
            settings_table[k] = tonumber(v)
            print(k, "=", v)
        end
        file:close()
        -- update values from table
        set(set_real_fuel_meter, settings_table["fuelmet"])
        set(set_real_ahz, settings_table["ahz"])
        set(set_real_fire, settings_table["fire"])
        set(set_real_startup, settings_table["startup"])
        set(set_active_camera, settings_table["camera"])
        set(set_real_generators, settings_table["generat"])
        set(set_real_gears, settings_table["gears"])
        set(set_real_brakes, settings_table["brakes"])
        set(set_real_tyres, settings_table["tyres"])
        set(real_hl, settings_table["hlight"])
        set(park_pos, settings_table["ppark"])
        set(kln90b_pri, settings_table["kln90bp"])
        set(kln90b_sec, settings_table["kln90bs"])
        set(gns430_pri, settings_table["gns430p"])
        set(gns430_sec, settings_table["gns430s"])
        set(switch_rud, settings_table["rudsw"])
        set(north_GPK, settings_table["gpknrth"])
        set(real_fuel, settings_table["fuel"])
        set(rsbn_dataset, settings_table["dataset"])
        set(reflections, settings_table["reflect"])
        set(black_box, settings_table["bbox"])
        set(language, settings_table["lang"])
        set(sound_volume, settings_table["volume"])
        print("-------------------")
        print("Settings readed successfully!")
    else
        print("No settings .ini file found - using default values")
    end
    return true
end

-- saving file
function file_save()
    local filename = pluginDataDir .. "/output/an-24_settings.ini"
    local success = false -- check operation
    local savefile = io.open(filename, "w")
    savefile:write("fuelmet", "=", get(set_real_fuel_meter), "\n")
    savefile:write("ahz", "=", get(set_real_ahz), "\n")
    savefile:write("fire", "=", get(set_real_fire), "\n")
    savefile:write("startup", "=", get(set_real_startup), "\n")
    savefile:write("generat", "=", get(set_real_generators), "\n")
    savefile:write("gears", "=", get(set_real_gears), "\n")
    savefile:write("brakes", "=", get(set_real_brakes), "\n")
    savefile:write("tyres", "=", get(set_real_tyres), "\n")
    savefile:write("hlight", "=", get(real_hl), "\n")
    savefile:write("ppark", "=", get(park_pos), "\n")
    savefile:write("camera", "=", get(set_active_camera), "\n")
    savefile:write("kln90bp", "=", get(kln90b_pri), "\n")
    savefile:write("kln90bs", "=", get(kln90b_sec), "\n")
    savefile:write("gns430p", "=", get(gns430_pri), "\n")
    savefile:write("gns430s", "=", get(gns430_sec), "\n")
    savefile:write("rudsw", "=", get(switch_rud), "\n")
    savefile:write("gpknrth", "=", get(north_GPK), "\n")
    savefile:write("fuel", "=", get(real_fuel), "\n")
    savefile:write("dataset", "=", get(rsbn_dataset), "\n")
    savefile:write("reflect", "=", get(reflections), "\n")
    savefile:write("bbox", "=", get(black_box), "\n")
    savefile:write("lang", "=", get(language), "\n")
    savefile:write("volume", "=", get(sound_volume), "\n")
    if savefile then
        success = true
    end
    savefile:close()
    return success
end

function update()

    if notLoaded then
        file_read()
        notLoaded = false
    end

    if get(frame_time) == 0 then
        setMasterGain(0)
    else
        setMasterGain(get(sound_volume))
    end

    if get(language) == 0 then
        set(kill_en, 0)
        set(kill_ru, 1)
    else
        set(kill_en, 1)
        set(kill_ru, 0)
    end
end

components = { 
    -- background EN
    textureLit {
        image = langImage("settings", nil, nil, nil, nil, ".png"),
        position = {0, 0, size[1], size[2]}
    }, 
    
    lever {
        position = {515, 60, 40, 290},
        value = {sound_volume},
        lever_img = get(lever_image),
        minimum = 0,
        maximum = 1000
    }, 
    
    -- save file clickable
    clickable {
        position = {38, 15, 202, 40},
        cursor = Cursors.HAND,
        onMouseDown = function()
            local file_saved = file_save()
            if file_saved then
                print("Saving preferences - success!!!")
            else
                print("Saving preferences - error!!!")
            end
            return true
        end
    }, 
    
    -- RE-READ file clickable
    clickable {
        position = {280, 15, 202, 40},
        cursor = Cursors.HAND,
        onMouseDown = function()
            file_read()
            return true
        end
    }, 
    
    -- realism / camera option toggles (backlit)
    toggleSwitch {
        position = {220, 512, 22, 50},
        drf = set_real_fuel_meter,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {220, 462, 22, 50},
        drf = set_real_ahz,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {220, 412, 22, 50},
        drf = set_real_fire,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {220, 362, 22, 50},
        drf = set_real_startup,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {220, 312, 22, 50},
        drf = set_real_generators,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {220, 262, 22, 50},
        drf = set_real_gears,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {220, 212, 22, 50},
        drf = set_real_brakes,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {220, 162, 22, 50},
        drf = set_real_tyres,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {220, 112, 22, 50},
        drf = real_hl,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {220, 62, 22, 50},
        drf = park_pos,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {470, 512, 22, 50},
        drf = set_active_camera,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    -- GPS / GNS selection (backlit, inverted display; selecting one clears its peer)
    toggleSwitch {
        position = {470, 462, 22, 50},
        drf = kln90b_pri,
        state = function()
            return get(kln90b_pri) ~= 1
        end,
        btnOn = get(tmb_dn),
        btnOff = get(tmb_up),
        sound = switch_sound,
        lit = true,
        onToggle = function(nv)
            if nv ~= 0 and get(gns430_pri) == 1 then
                set(gns430_pri, 0)
            end
        end
    }, 
    
    toggleSwitch {
        position = {493, 462, 22, 50},
        drf = kln90b_sec,
        state = function()
            return get(kln90b_sec) ~= 1
        end,
        btnOn = get(tmb_dn),
        btnOff = get(tmb_up),
        sound = switch_sound,
        lit = true,
        onToggle = function(nv)
            if nv ~= 0 and get(gns430_sec) == 1 then
                set(gns430_sec, 0)
            end
        end
    }, 
    
    toggleSwitch {
        position = {470, 412, 22, 50},
        drf = gns430_pri,
        state = function()
            return get(gns430_pri) ~= 1
        end,
        btnOn = get(tmb_dn),
        btnOff = get(tmb_up),
        sound = switch_sound,
        lit = true,
        onToggle = function(nv)
            if nv ~= 0 and get(kln90b_pri) == 1 then
                set(kln90b_pri, 0)
            end
        end
    }, 
    
    -- misc option toggles (backlit)
    toggleSwitch {
        position = {470, 362, 22, 50},
        drf = switch_rud,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {470, 312, 22, 50},
        drf = north_GPK,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {470, 262, 22, 50},
        drf = real_fuel,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {470, 212, 22, 50},
        drf = rsbn_dataset,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {470, 162, 22, 50},
        drf = reflections,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    toggleSwitch {
        position = {470, 112, 22, 50},
        drf = black_box,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }, 
    
    -- Language (EN/RU; inverted display)
    toggleSwitch {
        position = {470, 62, 22, 50},
        drf = language,
        state = function()
            return get(language) ~= 1
        end,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound,
        lit = true
    }
}
