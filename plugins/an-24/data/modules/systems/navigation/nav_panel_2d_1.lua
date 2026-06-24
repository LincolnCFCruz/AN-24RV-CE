-- this is first part of nav panel
size = {532, 671}

-- Define commands
defineProperty("nav1_subpanel", globalProperty("an-24/panels/nav1_subpanel"))

-- define property table
defineProperty("curs_mp1_sw", globalProperty("an-24/gauges/curs_mp1_sw"))
defineProperty("curs_mp2_sw", globalProperty("an-24/gauges/curs_mp2_sw"))

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
        image = langImage("navigator_panel_2d", 0, 353, 532, 671)
    }, 
    nav_kursmp_set_2d {
        position = {40, 263, 130, 130}
    }, 
    
    nav_kursmp_set_2d {
        position = {340, 263, 130, 130},
        frequency = globalProperty("sim/cockpit2/radios/actuators/nav2_frequency_hz")
    }, 
    
    obs_kursmp_set_2d {
        position = {30, 30, 200, 200}
    }, 
    
    obs_kursmp_set_2d {
        position = {285, 30, 200, 200},
        obs = globalProperty("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot"),
        fromto = globalProperty("an-24/gauges/obs2_fromto"),
        fromto_lit = globalProperty("an-24/gauges/obs2_fromto_lit")
    }, 
    
    curs_mp_2d {
        position = {177, 456, 170, 170}
    }, 
    
    -- left / right CursMP switchers
    toggleSwitch {
        position = {215, 295, 20, 80},
        drf = curs_mp1_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {295, 295, 20, 80},
        drf = curs_mp2_sw,
        btnOn = get(tmb_up),
        btnOff = get(tmb_dn),
        sound = switch_sound
    }
}
