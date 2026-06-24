--[[

  File: main.lua
  -----
  Main project script

--]]

-- Project settings
size         = {2048, 2048}
panelWidth3d  = 2048
panelHeight3d = 2048
panel2d       = false
project       = "an-24"
pfx           = project.."/"

-- Aircraft root directory (strip plugins/an-24/... suffix from moduleDirectory)
aircraftDirectory = (moduleDirectory:match("^(.+)[/\\]plugins[/\\]an%-24") or moduleDirectory):gsub("[/\\]$","")

-- Plugin data directory — used for .ini preference files (output subfolder)
pluginDataDir = (moduleDirectory:match("^(.+)[/\\]modules") or moduleDirectory):gsub("[/\\]$","")

-- SASL3 render settings
setAircraftPanelRendering(true)
setInteractivity(true)
set3DRendering(true)
setRenderingMode2D(SASL_RENDER_2D_MULTIPASS)
setPanelRenderingMode(SASL_RENDER_PANEL_DEFAULT)

-- ============================================================
-- Search paths
-- ============================================================
addSearchResourcesPath(moduleDirectory)   -- resolves sounds/, images/ at module root
addSearchResourcesPath(moduleDirectory.."/../components")  -- resolves cursors.png for glbl_cursors
addSearchPath(moduleDirectory.."/core")   -- infrastructure: glbl_func, glbl_drfs, panel_logic
addSearchPath(moduleDirectory.."/images")
addSearchPath(moduleDirectory.."/fonts")
addSearchPath(moduleDirectory.."/components")

-- Floating panel windows
addSearchPath(moduleDirectory.."/panels")
addSearchPath(moduleDirectory.."/menu")

-- Avionics — by-system folders (role is the file-name suffix; see CLAUDE.md + REORG_MANIFEST.md)
addSearchPath(moduleDirectory.."/systems/electrical")
addSearchPath(moduleDirectory.."/systems/fuel")
addSearchPath(moduleDirectory.."/systems/powerplant")
addSearchPath(moduleDirectory.."/systems/hydraulics")
addSearchPath(moduleDirectory.."/systems/flight_ctrls")
addSearchPath(moduleDirectory.."/systems/aero")
addSearchPath(moduleDirectory.."/systems/fire")
addSearchPath(moduleDirectory.."/systems/anti_ice")
addSearchPath(moduleDirectory.."/systems/lights")
addSearchPath(moduleDirectory.."/systems/autopilot")
addSearchPath(moduleDirectory.."/systems/navigation")
addSearchPath(moduleDirectory.."/systems/comms")
addSearchPath(moduleDirectory.."/systems/flight_instr")
addSearchPath(moduleDirectory.."/systems/airdata")
addSearchPath(moduleDirectory.."/systems/pneumatics")
addSearchPath(moduleDirectory.."/systems/warnings")
addSearchPath(moduleDirectory.."/systems/audio")
addSearchPath(moduleDirectory.."/systems/cockpit")
addSearchPath(moduleDirectory.."/systems/debug")

-- ============================================================
-- Print loading header
-- ============================================================
print("Antonov An-24 (Twin Turboprop)")
print("---------")

-- ============================================================
-- Include foundational scripts
-- ============================================================
include "glbl_func.lua"
include "glbl_draw.lua"
include "glbl_cursors.lua"
include "glbl_sounds.lua"
include "glbl_drfs.lua"
include "glbl_controls.lua"
include "panel_logic.lua"

-- ============================================================
-- Global state table — updated every frame in update()
-- ============================================================
gvar = {
  frame_time  = 0,
  bus_dc27v   = 0,
  bus_dc27ve  = 0,
  bus_dc27a   = 0,
  bus_dc27ae  = 0,
  bus_ac36v   = 0,
  bus_ac36a   = 0,
  bus_ac115v  = 0,
  bus_ac115a  = 0,
}

-- -------------------------------------------------------
-- Floating panels — all context windows are declared in
-- panels/panel_windows.lua and registered into cw_panels
-- -------------------------------------------------------
panel_windows {}

-- -------------------------------------------------------
-- Developer tool: System Viewer / Debug Inspector. Self-contained floating
-- window (own contextWindow + bindable command "An-24/Debug/inspector").
-- Reads system datarefs read-only; does not touch systems code. See
-- systems/popups/debug_inspector.lua.
-- -------------------------------------------------------
debug_inspector {}

-- ============================================================
-- Component table
-- Mirrors Custom Avionics/avionics.lua assembly, converted to SASL3.
-- Logic components have no position; 3D-panel instruments have
-- position = {x, y, w, h} in the 2048x2048 panel texture space.
--
-- UPDATE-ORDER CONSTRAINTS (this table is also the per-frame update order —
-- do not reorder these without re-checking the dependency):
--   1. amp_volt_filter_logic MUST run AFTER start_logic — it overwrites
--      starter_amp/volt with smoothed values for the 3D gauges.
--   2. Each *_logic MUST run immediately BEFORE its paired *_3d (compute then
--      render): electric_panel, fuel_panel, prop, brake, anti_ice, trimm,
--      art_horizons, lights_addition. Reordering renders stale data silently.
--   3. art_horizons_logic MUST stay at its exact slot to preserve the
--      ap28_logic 1-frame attitude lag.
-- ============================================================
components = {

  -- -------------------------------------------------------
  -- Core animations (SASL3-only, no SASL2 equivalent)
  -- -------------------------------------------------------
  cockpit_fan_anim {},
  engine_logic     {},
  gns430_anim      {},
  klnpwr_logic     {},
  prop_anim        {},

  -- -------------------------------------------------------
  -- Aircraft logic (no panel position — update() only)
  -- -------------------------------------------------------
  sounds_logic           {},
  sounds_fmod_logic      {},
  call_ground_logic      {},
  rsbn_logic             {},
  navigator_logic        {},  -- single owner of USH/radiocompas-big scale integration + CURS-MP cold-start reset
  time_logic             {},
  flight_ctrls_logic  {},
  batteries_logic        {},
  generators_logic       {},
  bus_counter_logic      {},
  bus_logic              {},
  hydraulic_logic        {},
  gear_logic             {},
  flaps_logic            {},
  fuel_logic             {},

  gyro                   {},  -- GIK directional gyro (uses default datarefs)
  gik_logic              {},
  gyro {           -- GPK directional gyro (copilot, custom datarefs)
    bus_DC_27_volt = globalProperty("an-24/power/bus_DC_27_volt"),
    switch         = globalProperty("an-24/gauges/GPK_sw"),
    gyro_cc        = globalProperty("an-24/gauges/GPK_cc"),
    fail           = globalProperty("sim/operation/failures/rel_cop_dgy"),
    gyro_curse     = globalProperty("an-24/gauges/gyro2_curse"),
  },

  gps_nav_logic          {},
  ahz_drift_logic        {},
  ap28_logic             {},
  ap_mech_logic          {},
  misc_sounds_logic      {},
  crew_bm_logic          {},
  crew_nav_logic         {},
  start_logic            {},

  -- V11 upgrade modules (engine/prop physics for XP12)
  amp_volt_filter_logic  {},  -- MUST come AFTER start_logic — overwrites starter_amp/volt with smoothed values for the 3D gauges
  start_lock_logic       {},  -- prop low-pitch stop — protects against spontaneous feathering at low RPM
  autofeather_logic      {},  -- automatic prop feathering per RLE (by IKM/N1)
  prop_commands_logic    {},  -- prop pitch stop commands for keyboard/joystick
  fuse_cd_logic          {},  -- fuselage drag correction vs altitude (RLE speed calibration)
  n1_vibration_logic     {},  -- N1 tachometer needle shake during AI-24 start (visual, below 23%)

  fire_logic             {},
  siren_logic            {},
  noseweel_logic         {},
  aero_extra_logic       {},
  view_logic             {},
  flap_aero_logic        {},
  failures_logic         {},
  lights_logic           {},
  lights_addition_logic  {},  -- lights compute (split from lights_addition); runs just before the render
  lights_addition_3d     {},  -- test-lamp/MSRP/AP-disconnect annunciators (no position, as before)

  -- -------------------------------------------------------
  -- 3D cockpit panel overlays (full-panel or sub-area draws)
  -- -------------------------------------------------------
  msrp_3d              { position = {0,    0, 2048, 2048} },
  electric_panel_logic {},  -- electric indication compute (split from electric_panel_3d); runs just before the render
  electric_panel_3d    { position = {0,    0, 2048, 2048} },
  hydraulic_panel_3d   { position = {0,    0, 2048, 2048} },
  fuel_panel_logic     {},  -- fuel indication compute (split from fuel_panel_3d); runs just before the render
  fuel_panel_3d        { position = {0,    0, 2048, 2048} },
  prop_logic           {},  -- prop compute (split; render half is prop_3d)
  prop_3d              { position = {0,    0, 2048, 2048} },
  brake_logic          {},  -- brake/ABS compute (split; render half is brake_3d)
  brake_3d             { position = {0,    0, 2048, 2048} },
  misc_clickables_3d   { position = {0,    0, 2048, 2048} },
  misc_lamps_3d        { position = {0,    0, 2048, 2048} },
  ssos_3d              { position = {0,    0, 2048, 2048} },
  gear_panel_3d        { position = {16,  543,  169,  82} },
  ap28_3d              { position = {0,    0, 2048, 2048} },
  anti_ice_logic       {},  -- anti-ice compute (split from antiice); runs just before the render
  anti_ice_3d          { position = {0,    0, 2048, 2048} },
  mrp_3d               { position = {0,    0, 2048, 2048} },
  engine_fuel_logic    {},  -- per-engine mixture compute (was mis-registered with a position)
  start_panel_3d       { position = {0,    0, 2048, 2048} },
  fire_panel_3d        { position = {0,    0, 2048, 2048} },
  trimm_logic          {},  -- trim compute (split; render half is trimm_3d)
  trimm_3d             { position = {0,    0, 2048, 2048} },
  iv41_3d              { position = {0,    0, 2048, 2048} },
  skv_3d               { position = {0,    0, 2048, 2048} },
  radar_panel_3d       { position = {0,    0, 2048, 2048} },
  fake_3d              { position = {0,    0, 2048, 2048} },
  cowl_flaps_3d        { position = {0,    0, 2048, 2048} },

  -- -------------------------------------------------------
  -- Captain's panel instruments
  -- -------------------------------------------------------
  vd_10_3d      { position = {200, 1847, 200, 200} },
  kus_730_3d    { position = {400, 1847, 200, 200} },  -- pilot airspeed
  var_30_3d     { position = {601, 1847, 200, 200} },  -- pilot VSI
  feet_meter_3d { position = {1801,1847, 200, 200} },
  rv_2_3d       { position = {801, 1847, 200, 200} },
  achs1_3d      { position = {801, 1046, 200, 200} },
  art_horizons_logic {},  -- attitude compute (split from art_horizons); kept at this exact frame slot to preserve the ap28_logic 1-frame attitude lag
  art_horizons_3d { position = {0,  0, 2048, 2048} },
  kppm       { position = {1,   1647, 200, 200} },
  zk2_3d        { position = {401, 1647, 200, 200} },
  transponder_3d{ position = {1346, 649,  58,  51} },

  ark11_3d      { position = {453,  457, 240, 200} },  -- ARK-1 (ADF-1)
  radiocompas_3d{ position = {600, 1648, 200, 200} },
  ark_meter_3d  { position = {601,  848, 100, 100} },  -- ARK-1 signal strength

  com_set_3d    { position = {328,  360,  80,  80} },  -- COM1
  com_set_3d    {                                       -- COM2
    position  = {328, 268, 80, 80},
    frequency = globalProperty("sim/cockpit2/radios/actuators/com2_frequency_hz"),
  },
  dme_set_3d    { position = {420,  360,  80,  80} },
  dme_3d        { position = {601, 1248, 200, 200} },
  oil_ind_3d    { position = {4,    847, 100, 200} },
  spu_3d        { position = {1005, 660, 140, 180} },

  -- -------------------------------------------------------
  -- Copilot's panel instruments
  -- -------------------------------------------------------
  kus_730_3d    {                                       -- copilot airspeed
    position = {1402, 1447, 200, 200},
    ias      = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_copilot"),
  },
  var_30_3d     {                                       -- copilot VSI
    position = {1, 1246, 200, 200},
    vvi      = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_copilot"),
  },
  uvid_30_3d    { position = {401, 1247, 200, 200} },
  eup_53_3d     { position = {201, 1048, 200, 200} },
  kppm       {                                       -- copilot ILS cross-pointer
    position                 = {1, 1047, 200, 200},
    scale_angle_smartcopilot = globalProperty("an-24/gauges/scale_angle_2_smartcopilot"),
    -- NOTE: original avionics.lua referenced "rotate_dir_2_smartcopilot" (typo);
    -- the dataref actually created is rotate_dir2_smartcopilot
    rotate_dir_smartcopilot  = globalProperty("an-24/gauges/rotate_dir2_smartcopilot"),
    sc_curse_angle           = globalProperty("an-24/gauges/sc_KPPM_2_curse_angle"),
    hor_def                  = globalProperty("an-24/gauges/curs_2"),
    vert_def                 = globalProperty("an-24/gauges/glide_2"),
    curs_flag                = globalProperty("an-24/gauges/k2_flag"),
    glide_flag               = globalProperty("an-24/gauges/g2_flag"),
  },
  gpk_gauge_3d  { position = {1595, 842, 400, 400} },
  gpk_panel_3d  { position = {0,    0, 2048, 2048} },

  ark11_3d      {                                       -- ARK-2 (ADF-2)
    position          = {210, 457, 240, 200},
    dev_num           = 1,
    ark_need_freq     = globalProperty("an-24/ark/ark2_need_freq"),
    radio             = globalProperty("sim/cockpit2/radios/actuators/adf2_frequency_hz"),
    adf               = globalProperty("sim/cockpit2/radios/indicators/adf2_relative_bearing_deg"),
    fail              = globalProperty("sim/operation/failures/rel_adf2"),
    audio_selection   = globalProperty("sim/cockpit2/radios/actuators/audio_selection_adf2"),
    cw_sw             = globalProperty("an-24/ark/ark2_cw"),
    ark_band_need     = globalProperty("an-24/ark/ark2_band_need"),
    ark_tune_need     = globalProperty("an-24/ark/ark2_tune_need"),
    ark_fine_tune_need= globalProperty("an-24/ark/ark2_fine_tune_need"),
    button            = globalProperty("an-24/ark/ark2_button"),
    ark_mode          = globalProperty("an-24/ark/ark2_mode"),
    ark_band          = globalProperty("an-24/ark/ark2_band"),
    band_fix          = globalProperty("an-24/ark/ark2_band_fix"),
    ark_tune          = globalProperty("an-24/ark/ark2_tune"),
    tune_fix          = globalProperty("an-24/ark/ark2_tune_fix"),
    ark_fine_tune     = globalProperty("an-24/ark/ark2_fine_tune"),
    ant_sw            = globalProperty("an-24/ark/ark2_ant_sw"),
    res_angle         = globalProperty("an-24/ark/ark2_angle"),
    res_signal        = globalProperty("an-24/ark/ark2_signal"),
    bus27             = globalProperty("an-24/power/bus_DC_27_volt"),
    ark_cc            = globalProperty("an-24/ark/ark2_cc"),
  },
  radiocompas_big_3d { position = {1600, 1247, 400, 400} },
  ark_meter_3d       {                                  -- ARK-2 signal strength
    position = {701, 848, 100, 100},
    signal   = globalProperty("an-24/ark/ark2_signal"),
  },

  -- -------------------------------------------------------
  -- Center panel instruments
  -- -------------------------------------------------------
  ite2_3d     { position = {802,  1448, 200, 200} },
  tsa15_3d    { position = {1001, 1647, 200, 200} },
  uprt2_3d    { position = {1401, 1647, 200, 200} },

  emi3_3d     { position = {1601, 1647, 200, 200} },  -- engine 1 multi-indicator
  emi3_3d     {                                        -- engine 2 multi-indicator
    position = {1801, 1647, 200, 200},
    fuel_p   = globalProperty("sim/cockpit2/engine/indicators/fuel_pressure_psi[1]"),
    oil_p    = globalProperty("sim/cockpit2/engine/indicators/oil_pressure_psi[1]"),
    oil_t    = globalProperty("sim/cockpit2/engine/indicators/oil_temperature_deg_C[1]"),
  },
  emi3_ru19_3d{ position = {801,  1647, 200, 200} },

  tg2a_3d     { position = {1,    1447, 200, 200} },  -- engine 1 EGT
  tg2a_3d     {                                        -- engine 2 EGT
    position      = {201, 1447, 200, 200},
    temp_check    = globalProperty("an-24/start/right_temp_check"),
    egt_fail      = globalProperty("sim/operation/failures/rel_EGT_ind_1"),
    uprt          = globalProperty("an-24/misc/virt_rud2"),
    N1            = globalProperty("sim/flightmodel/engine/ENGN_N1_[1]"),
    eng_work      = globalProperty("sim/flightmodel2/engines/engine_is_burning_fuel[1]"),
    engine_on_fire= globalProperty("sim/operation/failures/rel_engfir1"),
    eng_power     = globalProperty("sim/flightmodel/engine/ENGN_power[1]"),
  },

  term_3d     { position = {1201, 1647, 200, 200} },
  dim100_3d   {                                        -- engine 1 torque
    position = {401, 1447, 200, 200},
    ikm      = globalProperty("an-24/gauges/torque_left"),
  },
  dim100_3d   {                                        -- engine 2 torque
    position = {601, 1447, 200, 200},
    torq     = globalProperty("sim/cockpit2/engine/indicators/torque_n_mtr[1]"),
    ikm      = globalProperty("an-24/gauges/torque_right"),
  },

  uap14_3d    { position = {201, 1647, 200, 200} },
  var_10_3d   { position = {801, 1247, 200, 200} },
  upvd15_3d   { position = {1001,1247, 200, 200} },
  radar_3d    { position = {217,  -51, 256, 300} },
  cowl_flap_ind_3d { position = {404, 848, 200, 200} },

  -- -------------------------------------------------------
  -- Navigator's panel instruments
  -- -------------------------------------------------------
  ush_3d            { position = {1701, 548, 300, 300} },
  nav_kursmp_digit_3d { position = {417, 648, 170, 170} },  -- NAV1 frequency display
  nav_kursmp_digit_3d {                                      -- NAV2 frequency display
    position  = {617, 648, 170, 170},
    frequency = globalProperty("sim/cockpit2/radios/actuators/nav2_frequency_hz"),
  },
  obs_kursmp_set_3d { position = {0,   648, 200, 200} },    -- NAV1 OBS knob
  obs_kursmp_set_3d {                                        -- NAV2 OBS knob
    position   = {200, 648, 200, 200},
    obs        = globalProperty("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot"),
    fromto     = globalProperty("an-24/gauges/obs2_fromto"),
    fromto_lit = globalProperty("an-24/gauges/obs2_fromto_lit"),
  },
  curs_mp_3d  { position = {800, 648, 200, 200} },
  map      { position = {1514, 5, 530, 530} },  -- navigator's table map (3D panel)
}

print("---------")

-- ============================================================
-- Main update — runs every frame
-- ============================================================
function update()
  gvar.frame_time = get(drf_main.frame_time)
  gvar.bus_dc27v  = get(drf_pwr.bus_dc27v)
  gvar.bus_dc27ve = get(drf_pwr.bus_dc27ve)
  gvar.bus_dc27a  = get(drf_pwr.bus_dc27a)
  gvar.bus_dc27ae = get(drf_pwr.bus_dc27ae)
  gvar.bus_ac36v  = get(drf_pwr.bus_ac36v)
  gvar.bus_ac36a  = get(drf_pwr.bus_ac36a)
  gvar.bus_ac115v = get(drf_pwr.bus_ac115v)
  gvar.bus_ac115a = get(drf_pwr.bus_ac115a)

  updatePanels()
  updateAll(components)
end
