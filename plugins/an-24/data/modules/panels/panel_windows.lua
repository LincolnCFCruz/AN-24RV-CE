--[[

  File: panel_windows.lua
  -----
  All floating context windows, built from one declarative table.
  Replaces the 22 near-identical wrapper files that used to live here.

  Each entry creates a contextWindow and registers its handle in cw_panels
  under `key`, which MUST match the dataref key in core/panel_logic.lua —
  that module bidirectionally syncs window visibility with the
  an-24/panels/* datarefs every frame (see CLAUDE.md, "Panel system").

  command is the An-24/Panels/panel_<N> toggle number (omit for windows
  without a command, e.g. the flashlight button).

  children is a function (not a plain table) so the child component
  constructors are resolved lazily through SASL's component loader when
  the window is built.

  NOTE on the 100x100 minimum: SASL3/XP12 floating windows can't be smaller
  than 100x100 — a window declared narrower is snapped to 100px and its
  content stretched (the "menu expands" bug). The three menu windows are
  therefore declared 100px wide/tall with their art anchored 1:1 at the
  bottom-left and the rest left transparent.

--]] 

local windows = { 
    
    -- menu strip, logo and flashlight ------------------------------------
    {
        key = "main_menu",
        name = "menu_panel",
        position = {0, 100, 100, 512},
        command = 1,
        description = "Toggle An-24 main menu",
        noMove = true,
        noResize = true,
        noDecore = true,
        noBackground = true,
        children = function()
            return {menu_panel {
                position = {0, 0, 45, 512}
            }}
        end
    },

    {
        key = "menu_logo",
        name = "menu_logo",
        position = {0, 100, 100, 100},
        noMove = true,
        noResize = true,
        noDecore = true,
        noBackground = true,
        visible = true,
        children = function()
            return {menu_logo {
                position = {0, 0, 45, 35}
            }}
        end
    }, 
    
    {
        key = "menu_fl",
        name = "menu_fl",
        position = {0, 610, 100, 100},
        noMove = true,
        noResize = true,
        noDecore = true,
        noBackground = true,
        children = function()
            return {menu_fl {
                position = {0, 0, 45, 25}
            }}
        end
    }, 
    
    -- cockpit panels ------------------------------------------------------
    {
        key = "left",
        name = "left_panel",
        position = {60, 100, 983, 512},
        command = 6,
        description = "Toggle An-24 left instrument panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {left_panel_2d {
                position = {0, 0, 983, 512}
            }, oil_ind_3d {
                position = {575, 360, 60, 120}
            }}
        end
    }, 
    
    {
        key = "right",
        name = "right_panel",
        position = {60, 100, 825, 430},
        command = 7,
        description = "Toggle An-24 right instrument panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {right_panel_2d {
                position = {0, 0, 825, 430}
            }}
        end
    }, 
    
    {
        key = "electro",
        name = "electropanel",
        position = {60, 100, 512, 870},
        command = 4,
        description = "Toggle An-24 electrical panel",
        proportional = true,
        saveState = true,
        children = function()
            return {electric_panel_2d {
                position = {0, 0, 512, 870}
            }}
        end
    }, 
    
    {
        key = "fuel",
        name = "fuel_panel",
        position = {60, 100, 512, 725},
        command = 5,
        description = "Toggle An-24 fuel panel",
        proportional = true,
        saveState = true,
        children = function()
            return {fuel_panel_2d {
                position = {0, 0, 512, 725}
            }}
        end
    }, 
    
    {
        key = "nav1",
        name = "nav_panel1",
        position = {60, 100, 532, 631},
        command = 2,
        description = "Toggle An-24 navigation panel 1",
        proportional = true,
        saveState = true,
        children = function()
            return {nav_panel_2d_1 {
                position = {0, 0, 532, 631}
            }}
        end
    }, 
    
    {
        key = "nav2",
        name = "nav_panel2",
        position = {60, 100, 493, 687},
        command = 3,
        description = "Toggle An-24 navigation panel 2",
        proportional = true,
        saveState = true,
        children = function()
            return {nav_panel_2d_2 {
                position = {0, 0, 493, 687}
            }}
        end
    }, 
    
    {
        key = "radio",
        name = "radio_panel",
        position = {60, 100, 1015, 630},
        command = 9,
        description = "Toggle An-24 radio panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {radio_panel_2d {
                position = {0, 0, 1015, 630}
            }}
        end
    }, 
    
    {
        key = "ap",
        name = "ap_panel",
        position = {60, 100, 512, 380},
        command = 8,
        description = "Toggle An-24 autopilot panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {ap_panel_2d {
                position = {0, 0, 512, 380}
            }}
        end
    }, 
    
    -- service and information windows ------------------------------------
    {
        key = "info",
        name = "info_panel",
        position = {60, 100, 454, 512},
        command = 15,
        description = "Toggle An-24 info panel",
        proportional = true,
        saveState = true,
        children = function()
            return {info_panel_2d {
                position = {0, 0, 454, 512}
            }}
        end
    }, 
    
    {
        key = "service",
        name = "service_panel",
        position = {60, 100, 512, 512},
        command = 10,
        description = "Toggle An-24 service panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {service_panel_2d {
                position = {0, 0, 512, 512}
            }}
        end
    }, 
    
    {
        key = "payload",
        name = "payload",
        position = {60, 100, 600, 837},
        command = 11,
        description = "Toggle An-24 payload panel",
        proportional = true,
        saveState = true,
        children = function()
            return {payload_panel_2d {
                position = {0, 0, 600, 837}
            }}
        end
    }, 
    
    {
        key = "options",
        name = "options",
        position = {60, 100, 560, 610},
        command = 14,
        description = "Toggle An-24 options panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {settings_2d {
                position = {0, 0, 560, 610}
            }}
        end
    }, 
    
    -- navigation displays --------------------------------------------------
    {
        key = "nas1",
        name = "nas1",
        position = {60, 100, 1024, 557},
        command = 18,
        description = "Toggle An-24 NAS-1 panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {nas1_2d {
                position = {0, 0, 1024, 557}
            }}
        end
    }, 
    
    {
        key = "map",
        name = "map_panel",
        position = {60, 100, 530, 530},
        command = 13,
        description = "Toggle An-24 moving map",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {map {
                position = {0, 0, 530, 530}
            }}
        end
    }, 
    
    {
        key = "rsbn",
        name = "rsbn",
        position = {60, 100, 1024, 724},
        command = 17,
        description = "Toggle An-24 RSBN panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {rsbn_2d {
                position = {0, 0, 1024, 724}
            }}
        end
    }, 
    
    {
        key = "nl10m",
        name = "nl10m_panel",
        position = {60, 100, 1280, 330},
        command = 12,
        description = "Toggle An-24 NL-10M display",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {nl10m_2d {
                position = {0, 0, 1280, 330}
            }}
        end
    }, 
    
    -- misc ------------------------------------------------------------------
    {
        key = "uphone",
        name = "uphone",
        position = {60, 100, 241, 446},
        command = 19,
        description = "Toggle An-24 UPhone panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {UPhone_2d {
                position = {0, 0, 241, 446}
            }}
        end
    }, 
    
    {
        key = "fplan",
        name = "flightplan",
        position = {60, 100, 560, 400},
        command = 20,
        description = "Toggle An-24 flight plan viewer",
        proportional = true,
        saveState = true,
        children = function()
            return {flightplan_2d {
                position = {0, 0, 560, 400}
            }}
        end
    }, 
    
    {
        key = "camera",
        name = "camera",
        position = {60, 100, 256, 240},
        command = 16,
        description = "Toggle An-24 camera panel",
        proportional = true,
        saveState = true,
        noBackground = true,
        children = function()
            return {camera_panel_2d {
                position = {0, 0, 256, 240}
            }}
        end
    }
}

for _, w in ipairs(windows) do
    cw_panels[w.key] = contextWindow {
        name = w.name,
        position = w.position,
        noMove = w.noMove,
        noResize = w.noResize,
        noDecore = w.noDecore,
        noBackground = w.noBackground,
        proportional = w.proportional,
        saveState = w.saveState,
        layer = SASL_CW_LAYER_FLOATING_WINDOWS,
        command = w.command and ("An-24/Panels/panel_" .. w.command) or nil,
        description = w.description,
        visible = w.visible or false,
        components = w.children()
    }
end
