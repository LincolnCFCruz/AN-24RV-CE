-- this is first part of nav panel
size = {493, 687}

-- Define commands
defineProperty("nav2_subpanel", globalProperty("an-24/panels/nav2_subpanel"))

-- define property table
defineProperty("curs_mp1_sw", globalProperty("an-24/gauges/curs_mp1_sw"))
defineProperty("curs_mp2_sw", globalProperty("an-24/gauges/curs_mp2_sw"))
defineProperty("ark_vor", globalProperty("an-24/gauges/ark_vor")) -- switcher ARK/VOR
defineProperty("vent_1_sw", globalProperty("an-24/misc/vent_1_sw"))

-- background image
defineProperty("tmb_up", sasl.gl.loadImage("tumbler_up.dds"))
defineProperty("tmb_dn", sasl.gl.loadImage("tumbler_down.dds"))
defineProperty("tmb_ctr", sasl.gl.loadImage("tumbler_center.dds"))

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click, plastic_sound = snd.switch, snd.cap, snd.btn, snd.rot, snd.plastic

components = { 
    -- background image
    texture {
        position = {0, 0, size[1], size[2]},
        image = langImage("navigator_panel_2d", 532, 337, 493, 687)
    }, 
    
    ush_2d {
        position = {55, 10, 295, 295}
    }, 
    
    radiocompas_big_2d {
        position = {60, 393, 253, 253}
    }, 
    
    dme_3d {
        position = {357, 63, 80, 80}
    }, 
    
    -- cockpit vents switch (intentionally silent)
    toggleSwitch {
        position = {332, 523, 20, 80},
        drf = vent_1_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn)
    }, 
    
    -- ARK/VOR switcher
    toggleSwitch {
        position = {382, 523, 20, 80},
        drf = ark_vor,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    texture {
        position = {435, 523, 20, 80},
        image = get(tmb_dn)
    }
}
