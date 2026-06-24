-- Main menu strip — panel visibility toggles
-- Converted from SASL2: movePanelToTop() removed (SASL3 contextWindow handles
-- z-order). Buttons write the an-24/panels/* datarefs; panel_logic.lua syncs
-- them with the contextWindows, exactly like the SASL2 popup logic.

size = {65, 512}

-- define panels datarefs
defineProperty("main_menu_subpanel", globalProperty("an-24/panels/main_menu_subpanel"))
defineProperty("menu_logo", globalProperty("an-24/panels/menu_logo"))
defineProperty("nav1_subpanel", globalProperty("an-24/panels/nav1_subpanel"))
defineProperty("nav2_subpanel", globalProperty("an-24/panels/nav2_subpanel"))
defineProperty("electropanel_subpanel", globalProperty("an-24/panels/electropanel_subpanel"))
defineProperty("left_subpanel", globalProperty("an-24/panels/left_subpanel"))
defineProperty("ap_panel_subpanel", globalProperty("an-24/panels/ap_panel_subpanel"))
defineProperty("right_subpanel", globalProperty("an-24/panels/right_subpanel"))
defineProperty("nl10m_subpanel", globalProperty("an-24/panels/nl10m_subpanel"))
defineProperty("radio_subpanel", globalProperty("an-24/panels/radio_subpanel"))
defineProperty("service_subpanel", globalProperty("an-24/panels/service_subpanel"))
defineProperty("payload_subpanel", globalProperty("an-24/panels/payload_subpanel"))
defineProperty("options_subpanel", globalProperty("an-24/panels/options_subpanel"))
defineProperty("fuel_subpanel", globalProperty("an-24/panels/fuel_subpanel"))
defineProperty("map_subpanel", globalProperty("an-24/panels/map_subpanel"))
defineProperty("info_subpanel", globalProperty("an-24/panels/info_subpanel"))
defineProperty("camera_subpanel", globalProperty("an-24/panels/camera_subpanel"))
defineProperty("rsbn_subpanel", globalProperty("an-24/panels/rsbn_subpanel"))
defineProperty("nas1_subpanel", globalProperty("an-24/panels/nas1_subpanel"))
defineProperty("uphone_subpanel", globalProperty("an-24/panels/uphone_subpanel"))
defineProperty("fplan_subpanel", globalProperty("an-24/panels/fplan_subpanel"))

local rot_click = loadSample("sounds/custom/rot_click.wav")
local bg = langImages("menu_panelbg", nil, nil, nil, nil, ".png")

-- toggles a panel dataref (panel_logic.lua syncs the contextWindow)
local function togglePanel(drf)
    if get(drf) ~= 0 then
        set(drf, 0)
    else
        set(drf, 1)
    end
    sasl.al.playSample(rot_click, false)
    return true
end

-- Panel toggle switches, top-to-bottom in on-screen / draw (z-) order, 23px
-- tall and spaced 25px apart starting at y = 486. Each toggles its panel
-- dataref; panel_logic.lua syncs the contextWindow. Order MUST be preserved.
local toggles = {
    payload_subpanel, service_subpanel, fplan_subpanel, info_subpanel, map_subpanel,
    nl10m_subpanel,   uphone_subpanel,  electropanel_subpanel, fuel_subpanel, left_subpanel,
    right_subpanel,   radio_subpanel,   nav1_subpanel, nav2_subpanel, rsbn_subpanel,
    nas1_subpanel,    ap_panel_subpanel, camera_subpanel, options_subpanel,
}

components = {}
for i, drf in ipairs(toggles) do
    components[#components + 1] = switch {
        position    = {0, 486 - (i - 1) * 25, 45, 23},
        state       = function() return get(drf) ~= 0 end,
        onMouseDown = function() return togglePanel(drf) end
    }
end

-- logo closer (hides menu, shows logo) — special: own size and action
components[#components + 1] = switch {
    position = {0, 1, 65, 33},
    state    = function() return get(main_menu_subpanel) ~= 0 end,
    onMouseDown = function()
        if get(main_menu_subpanel) ~= 0 then
            set(main_menu_subpanel, 0)
            set(menu_logo, 1)
        end
        sasl.al.playSample(rot_click, false)
        return true
    end
}

function draw()
    drawLangBackground(bg, size[1], size[2])
end
