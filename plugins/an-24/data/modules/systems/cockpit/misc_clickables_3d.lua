-- this is component for all clickables on panel, that don't included with gauges
size = {2048, 2048}

-- datarefs
defineProperty("rv2_sw", globalProperty("an-24/gauges/rv_2_sw")) -- switch for radioaltimeter
defineProperty("feet_meter_sw", globalProperty("an-24/gauges/feet_meter_sw")) -- gauge switcher ON/OF
defineProperty("GIK_button", globalProperty("an-24/gauges/GIK_button")) -- button for sync GIK with mag compass
defineProperty("GIK_sw", globalProperty("an-24/gauges/GIK_sw")) -- ON/OFF GIK
defineProperty("GPK_sw", globalProperty("an-24/gauges/GPK_sw")) -- ON/OFF GPK
defineProperty("uvid_30_sw", globalProperty("an-24/gauges/uvid_30_sw")) -- UVID-30 switcher ON/OF
defineProperty("sq_emerg_cap", globalProperty("an-24/sq/sq_emerg_cap"))
defineProperty("curs_mp1_sw", globalProperty("an-24/gauges/curs_mp1_sw"))
defineProperty("curs_mp2_sw", globalProperty("an-24/gauges/curs_mp2_sw"))
defineProperty("ark_vor", globalProperty("an-24/gauges/ark_vor")) -- switcher ARK/VOR
defineProperty("weel_switch", globalProperty("an-24/gauges/noseweel")) -- nosewheel mode
defineProperty("nav_light_sw", globalProperty("an-24/misc/nav_light_sw")) -- nav lights and beacons switch
defineProperty("lan_light_sw", globalProperty("an-24/misc/lan_light_sw")) -- landing lights switch
defineProperty("lan_light_open_sw", globalProperty("an-24/misc/lan_light_open_sw")) -- landing lights switch
defineProperty("cockpit_red", globalProperty("an-24/misc/cockpit_red")) -- red cockpit light rotary
defineProperty("cockpit_spot1", globalProperty("an-24/misc/cockpit_spot1")) -- cockpit spotlight rotary
defineProperty("cockpit_spot2", globalProperty("an-24/misc/cockpit_spot2")) -- cockpit spotlight rotary
defineProperty("cockpit_panel", globalProperty("an-24/misc/cockpit_panel")) -- cockpit spotlight rotary
defineProperty("wiper_sw", globalProperty("sim/cockpit2/switches/wiper_speed")) -- 0=off,1=25%speed,2=50%speed,3=100%speed.
defineProperty("siren_button", globalProperty("an-24/gauges/siren_button")) -- button for temporary OFF sirene
defineProperty("cabin_left_window", globalProperty("sim/cockpit2/switches/custom_slider_on[2]")) -- open/close cabin_left_window
defineProperty("cabin_right_window", globalProperty("sim/cockpit2/switches/custom_slider_on[3]")) -- open/close cabin_right_window
defineProperty("cabin_left_glass", globalProperty("sim/cockpit2/switches/custom_slider_on[0]")) -- open/close cabin_left_glass
defineProperty("cabin_right_glass", globalProperty("sim/cockpit2/switches/custom_slider_on[1]")) -- open/close cabin_right_glass
defineProperty("nl10m_subpanel", globalProperty("an-24/panels/nl10m_subpanel"))
--defineProperty("rud_stopor", globalProperty("sim/cockpit2/switches/custom_slider_on[19]")) -- stopor lever, that fixes RUDs

local snd = loadUISounds()
local switch_sound, cap_sound, btn_click, rot_click = snd.switch, snd.cap, snd.btn, snd.rot

components = { 
	
--[[
    -- rud_stopor
    switch {
        position = { 680, 115, 17, 45},
        state = function()
            return get(rud_stopor) ~= 0
        end,
        --btnOn = get(tmb_up),
        --btnOff = get(tmb_dn),
        onMouseDown = function()
            if get(rud_stopor) ~= 0 then
                set(rud_stopor, 0)
            else
                set(rud_stopor, 1)
            end
            return true;
        end
    },
--]]

    -- NL10
    toggleSwitch {
        position = {0, 1850, 48, 70},
        drf = nl10m_subpanel
    }, 
    
    -- cabin window / glass switchers (no sound)
    toggleSwitch {
        position = {677, 235, 15, 15},
        drf = cabin_left_window
    }, 
    
    toggleSwitch {
        position = {677, 218, 15, 15},
        drf = cabin_right_window
    }, 
    
    toggleSwitch {
        position = {694, 235, 15, 15},
        drf = cabin_left_glass
    }, 
    
    toggleSwitch {
        position = {694, 218, 15, 15},
        drf = cabin_right_glass
    }, 
    
    -- siren_button (momentary: hold to silence the siren)
    momentaryButton {
        position = {690, 500, 17, 17},
        drf = siren_button,
        sound = btn_click,
        soundUp = btn_click
    }, 
    
--[[
	-- RV2 switcher
    switch {
        position = { 805, 327, 15, 15},
        state = function()
            return get(rv2_sw) ~= 0
        end,
        --btnOn = get(tmb_up),
        --btnOff = get(tmb_dn),
        onMouseDown = function()
            if not switcher_pushed then
			sasl.al.playSample(switch_sound, false)
			switcher_pushed = true
			if get(rv2_sw) ~= 0 then
                set(rv2_sw, 0)
            else
                set(rv2_sw, 1)
            end
		end
            return true;

        end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },
	-- feet meter switch
    switch {
        position = { 786, 253, 15, 15},
        state = function()
            return get(feet_meter_sw) ~= 0
        end,
        --btnOn = get(tmb_up),
        --btnOff = get(tmb_dn),
        onMouseDown = function()
            if not switcher_pushed then
			sasl.al.playSample(switch_sound, false)
			switcher_pushed = true
			if get(feet_meter_sw) ~= 0 then
                set(feet_meter_sw, 0)
            else
                set(feet_meter_sw, 1)
            end
		end
            return true;

        end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },
	-- GIK sync button
    clickable {
        position = {737, 522, 40, 23},  -- search and set right

       cursor = Cursors.HAND,

       	onMouseDown = function()
			set(GIK_button, 1)
			if not switcher_pushed then
				sasl.al.playSample(btn_click, false)
			end
			switcher_pushed = true
			return true
		end,
		onMouseUp  = function()
			set(GIK_button, 0)
			switcher_pushed = false
			sasl.al.playSample(btn_click, false)
			return true
		end,
    },
--]]

    -- GIK / GPK / UVID30 switchers
    toggleSwitch {
        position = {806, 272, 15, 15},
        drf = GIK_sw,
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {843, 272, 15, 15},
        drf = GPK_sw,
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {862, 272, 15, 15},
        drf = uvid_30_sw,
        sound = switch_sound
    }, 
    
    -- transponder emerg button cap
    toggleSwitch {
        position = {568, 304, 30, 60},
        drf = sq_emerg_cap,
        sound = cap_sound
    }, 
    
    -- left / right CursMP switchers
    toggleSwitch {
        position = {843, 384, 17, 17},
        drf = curs_mp1_sw,
        sound = switch_sound
    }, 
    
    toggleSwitch {
        position = {860, 384, 17, 17},
        drf = curs_mp2_sw,
        sound = switch_sound
    }, 
    
    -- ARK/VOR switcher
    toggleSwitch {
        position = {937, 384, 17, 17},
        drf = ark_vor,
        sound = switch_sound
    }, 
    
--[[
	-- nosewheel switch up
    clickable {
        position = {823, 335, 18, 8},  -- search and set right

       cursor = Cursors.HAND,

       	onMouseDown = function()
			local a = get(weel_switch)
			if not switcher_pushed and a > -1 then
				sasl.al.playSample(switch_sound, false)
				a = a - 1
			end
			switcher_pushed = true
			set(weel_switch, a)
			return true
		end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },

	-- nosewheel switch up
    clickable {
        position = {823, 326, 18, 8},  -- search and set right

       cursor = Cursors.HAND,

       	onMouseDown = function()
			local a = get(weel_switch)
			if not switcher_pushed and a < 1 then
				sasl.al.playSample(switch_sound, false)
				a = a + 1
			end
			switcher_pushed = true
			set(weel_switch, a)
			return true
		end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },

	-- ANO switcher
    switch {
        position = { 805, 307, 17, 17},
        state = function()
            return get(nav_light_sw) ~= 0
        end,
        --btnOn = get(tmb_up),
        --btnOff = get(tmb_dn),
        onMouseDown = function()
            if not switcher_pushed then
			sasl.al.playSample(switch_sound, false)
			switcher_pushed = true
			if get(nav_light_sw) ~= 0 then
                set(nav_light_sw, 0)
            else
                set(nav_light_sw, 1)
            end
		end
            return true;

        end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },
	-- landing light
    clickable {
        position = { 823, 315, 17, 8},  -- search and set right

       cursor = Cursors.HAND,

       	onMouseDown = function()
			local a = get(lan_light_sw)
			if not switcher_pushed and a < 1 then
				sasl.al.playSample(switch_sound, false)
				a = a + 1
			end
			switcher_pushed = true
			set(lan_light_sw, a)
			return true
		end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },
    clickable {
        position = { 823, 307, 17, 8},  -- search and set right

       cursor = Cursors.HAND,

       	onMouseDown = function()
			local a = get(lan_light_sw)
			if not switcher_pushed and a > -1 then
				sasl.al.playSample(switch_sound, false)
				a = a - 1
			end
			switcher_pushed = true
			set(lan_light_sw, a)
			return true
		end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },


	-- landing light open switch
    switch {
        position = { 823, 250, 17, 17},
        state = function()
            return get(lan_light_open_sw) ~= 0
        end,
        --btnOn = get(tmb_up),
        --btnOff = get(tmb_dn),
        onMouseDown = function()
            if not switcher_pushed then
			sasl.al.playSample(switch_sound, false)
			switcher_pushed = true
			if get(lan_light_open_sw) ~= 0 then
                set(lan_light_open_sw, 0)
            else
                set(lan_light_open_sw, 1)
            end
		end
            return true;

        end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },

	-- panel light

    clickable {
        position = { 937, 326, 17, 8},  -- search and set right

       cursor = Cursors.HAND,

       	onMouseDown = function()
			local a = get(cockpit_panel)
			if not switcher_pushed and a < 1 then
				sasl.al.playSample(switch_sound, false)
				a = a + 1
			end
			switcher_pushed = true
			set(cockpit_panel, a)
			return true
		end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },
    clickable {
        position = { 937, 335, 17, 8},  -- search and set right

       cursor = Cursors.HAND,

       	onMouseDown = function()
			local a = get(cockpit_panel)
			if not switcher_pushed and a > -1 then
				sasl.al.playSample(switch_sound, false)
				a = a - 1
			end
			switcher_pushed = true
			set(cockpit_panel, a)
			return true
		end,
		onMouseUp = function()
			switcher_pushed = false
			return true
		end,
    },
--]]

    -- cockpit red light
    rotary {
        -- image = rotaryImage;
        value = cockpit_red,
        step = 0.1,
        position = {482, 224, 18, 18},

        -- round inches hg to millimeters hg
        adjuster = function(v)
            sasl.al.playSample(rot_click, false)
            if v > 1 then
                v = 1
            elseif v < 0 then
                v = 0
            end
            return v
        end
    }, 
    
    -- cockpit spotlight1
    rotary {
        -- image = rotaryImage;
        value = cockpit_spot1,
        step = 0.1,
        position = {503, 224, 18, 18},

        -- round inches hg to millimeters hg
        adjuster = function(v)
            sasl.al.playSample(rot_click, false)
            if v > 1 then
                v = 1
            elseif v < 0 then
                v = 0
            end
            return v
        end
    }, 
    
    -- cockpit spotlight2
    rotary {
        -- image = rotaryImage;
        value = cockpit_spot2,
        step = 0.1,
        position = {523, 224, 18, 18},

        -- round inches hg to millimeters hg
        adjuster = function(v)
            sasl.al.playSample(rot_click, false)
            if v > 1 then
                v = 1
            elseif v < 0 then
                v = 0
            end
            return v
        end
    }, 
    
    -- wiper (off = 0, on = 2 = 50% speed)
    toggleSwitch {
        position = {785, 450, 90, 47},
        drf = wiper_sw,
        onValue = 2
    }
}
