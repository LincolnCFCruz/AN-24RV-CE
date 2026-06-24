--[[

  File: panel_logic.lua
  -----
  Panel visibility logic (port of Custom Avionics/panel_logic.lua).

  In SASL2 the popups were driven by the an-24/panels/* datarefs (every frame
  panel.visible was set from its dataref; menu buttons / 3D hotspots / close
  buttons wrote the datarefs). In SASL3 the popups are contextWindows (created by
  panels/*.lua wrappers, which store their handles in cw_panels); this module
  keeps the dataref-driven behaviour with a bidirectional sync:
    - dataref changed (menu button, 3D hotspot, close button) -> window follows
    - window changed (An-24/Panels/panel_N command, decoration close) -> dataref follows

--]]

-- Panel visibility datarefs (0 = hidden, 1 = visible)
drf_panels = {
    main_menu = cGPi(pfx .. "panels/main_menu_subpanel"),
    menu_logo = cGPi(pfx .. "panels/menu_logo", 1),
    nav1 = cGPi(pfx .. "panels/nav1_subpanel"),
    nav2 = cGPi(pfx .. "panels/nav2_subpanel"),
    electro = cGPi(pfx .. "panels/electropanel_subpanel"),
    left = cGPi(pfx .. "panels/left_subpanel"),
    ap = cGPi(pfx .. "panels/ap_panel_subpanel"),
    right = cGPi(pfx .. "panels/right_subpanel"),
    nl10m = cGPi(pfx .. "panels/nl10m_subpanel"),
    radio = cGPi(pfx .. "panels/radio_subpanel"),
    service = cGPi(pfx .. "panels/service_subpanel"),
    payload = cGPi(pfx .. "panels/payload_subpanel"),
    options = cGPi(pfx .. "panels/options_subpanel"),
    fuel = cGPi(pfx .. "panels/fuel_subpanel"),
    map = cGPi(pfx .. "panels/map_subpanel"),
    info = cGPi(pfx .. "panels/info_subpanel"),
    camera = cGPi(pfx .. "panels/camera_subpanel"),
    rsbn = cGPi(pfx .. "panels/rsbn_subpanel"),
    nas1 = cGPi(pfx .. "panels/nas1_subpanel"),
    uphone = cGPi(pfx .. "panels/uphone_subpanel"),
    fplan = cGPi(pfx .. "panels/fplan_subpanel")
}

local hdr_setting = globalProperty("sim/graphics/settings/HDR_on")

-- Context window handles, filled by the panels/*.lua wrappers during load.
-- Keys match drf_panels; menu_fl is handled separately (no dataref).
cw_panels = {}

-- last seen dataref state per panel, used to tell which side changed
local last_state = {}

function updatePanels()
    for key, drf in pairs(drf_panels) do
        local win = cw_panels[key]
        if win then
            local drfV = get(drf) ~= 0
            local winV = win:isVisible()
            if last_state[key] == nil then
                -- first frame: the window state (initial visible / saved state) wins
                if winV ~= drfV then
                    setbool(drf, winV)
                end
                last_state[key] = winV
            elseif drfV ~= last_state[key] then
                -- dataref changed (menu button, 3D hotspot, close button)
                if winV ~= drfV then
                    win:setIsVisible(drfV)
                end
                last_state[key] = drfV
            elseif winV ~= drfV then
                -- window changed (panel command or decoration close button)
                setbool(drf, winV)
                last_state[key] = winV
            end
        end
    end

    -- flashlight button: shown while the main menu is open and HDR is enabled
    local fl = cw_panels.menu_fl
    if fl then
        local flVisible = get(drf_panels.main_menu) == 1 and get(hdr_setting) == 1
        if fl:isVisible() ~= flVisible then
            fl:setIsVisible(flVisible)
        end
    end
end
