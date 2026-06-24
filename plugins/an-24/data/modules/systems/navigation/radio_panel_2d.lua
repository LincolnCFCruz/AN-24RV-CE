size = {1015, 630}

-- Define commands
defineProperty("radio_subpanel", globalProperty("an-24/panels/radio_subpanel"))

-- background image

components = {
    rectangle {
        position = {0, 0, size[1], size[2]},
        color = {0, 0, 0, 0.5}
    }, 
    
    -- background image
    texture {
        image = langImage("radio_panel_2d", 0, 394, size[1], size[2]),
        position = {0, 0, size[1], size[2]}
    }, 
    
    -- com 1
    com_set_2d {
        position = {14, 515, 230, 115}
    }, 
    
    -- com 2
    com_set_2d {
        position = {275, 515, 230, 115},
        frequency = globalProperty("sim/cockpit2/radios/actuators/com2_frequency_hz")
    }, 
    
    dme_set_2d {
        position = {525, 515, 266, 115}
    }, 
    
    ark_meter_3d {
        position = {813, 532, 95, 95}
    }, 
    
    ark_meter_3d {
        position = {916, 532, 95, 95},
        signal = globalProperty("an-24/ark/ark2_signal")
    }, 
    
    ark11_2d {
        position = {0, 53, 505, 455}
    }, 
    
    ark11_2d {
        position = {510, 53, 505, 455},
        dev_num = 1,
        ark_need_freq = globalProperty("an-24/ark/ark2_need_freq"),
        radio = globalProperty("sim/cockpit2/radios/actuators/adf2_frequency_hz"),
        adf = globalProperty("sim/cockpit2/radios/indicators/adf2_relative_bearing_deg"),
        fail = globalProperty("sim/operation/failures/rel_adf2"),
        audio_selection = globalProperty("sim/cockpit2/radios/actuators/audio_selection_adf2"),
        cw_sw = globalProperty("an-24/ark/ark2_cw"),
        ark_band_need = globalProperty("an-24/ark/ark2_band_need"),
        ark_tune_need = globalProperty("an-24/ark/ark2_tune_need"),
        ark_fine_tune_need = globalProperty("an-24/ark/ark2_fine_tune_need"),
        button = globalProperty("an-24/ark/ark2_button"),
        ark_mode = globalProperty("an-24/ark/ark2_mode"),
        ark_band = globalProperty("an-24/ark/ark2_band"),
        band_fix = globalProperty("an-24/ark/ark2_band_fix"),
        ark_tune = globalProperty("an-24/ark/ark2_tune"),
        tune_fix = globalProperty("an-24/ark/ark2_tune_fix"),
        ark_fine_tune = globalProperty("an-24/ark/ark2_fine_tune"),
        ant_sw = globalProperty("an-24/ark/ark2_ant_sw")
    }
}
