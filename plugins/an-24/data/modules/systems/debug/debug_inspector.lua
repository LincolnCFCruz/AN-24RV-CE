--[[

  File: debug_inspector.lua
  -----
  AN-24 System Viewer / Debug Inspector — standalone window registration.

  This is a self-contained developer tool. It is instantiated once from
  modules/main.lua (`debug_inspector {}`, right after `panel_windows {}`) and
  does nothing but create its own floating contextWindow. It deliberately does
  NOT register in cw_panels / panel_logic.lua: the contextWindow's `command`
  parameter auto-creates a bindable X-Plane command whose handler toggles the
  window's visibility (see init/initContextWindows.lua), and `saveState` keeps
  its position/size between sessions. Bind a key to:

      An-24/Debug/inspector

  The window content is debug_inspector_view (the tabbed graphical UI), which
  reads aircraft state by dataref name only — nothing here touches systems code.

--]] 

contextWindow {
    name = "debug_inspector",
    description = "Toggle An-24 System / Debug Inspector",
    command = "An-24/Debug/inspector",
    position = {80, 120, 920, 560},
    proportional = true,
    saveState = true,
    noBackground = true, -- the view draws its own opaque background
    layer = SASL_CW_LAYER_FLOATING_WINDOWS,
    visible = false,
    components = {
        debug_inspector_view {
            position = {0, 0, 920, 560}
        }
    }
}
