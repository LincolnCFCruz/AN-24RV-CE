--[[

  File: glbl_drfs.lua
  -----
  Central dataref registry: declares every an-24/... dataref (plus a few sim/
  custom handles), grouped by system. Dataref names are a frozen public contract
  (rule 1) -- never rename one.

--]]

-- Main
drf_main = {
  frame_time_old = cGPf(pfx.."time/frame_time"),
  frame_time = gPf("sim/operation/misc/frame_rate_period"),
}

-- Settings
drf_set = {
  gns430_pri = cGPi(pfx.."set/gns430_pri"), -- Primary GNS430 for pilot
  gns430_sec = cGPi(pfx.."set/gns430_sec"), -- Secondary GNS430 for copilot
  kln90b_pri = cGPi(pfx.."set/kln90b_pri"), -- Primary KLN90B for pilot
  kln90b_sec = cGPi(pfx.."set/kln90b_sec"), -- Secondary KLN90B for copilot
  kln_init = cGPi(pfx.."set/kln_init"), -- KLN90B init status
  lang = cGPi(pfx.."set/language"), -- Language selector: 0 - ENG, 1 - RUS
  park_pos = cGPi(pfx.."set/park_position"), -- Prop park position: 0 - X, 1 - +
  real_hl = cGPi(pfx.."set/real_headlight"), -- Headlight Taxi/Landing: 0 - instant, 1 - holding
  reflect = cGPi(pfx.."set/reflections"), -- Inside reflections: 0 - disable, 1 - enable (default)
  switch_rud = cGPi(pfx.."set/switch_rud"), -- switch or hold RUD stopers
  -- Simulation realism toggles
  real_fuel_meter = cGPi(pfx.."set/real_fuel_meter", 1), -- real fuel meter shows less than actual
  real_ahz        = cGPi(pfx.."set/real_ahz",        1), -- AHZ has errors requiring correction
  real_fire       = cGPi(pfx.."set/real_fire",        1), -- fire affects wings and nearby mechanisms
  real_startup    = cGPi(pfx.."set/real_startup",     1), -- engines require full startup procedure
  active_camera   = cGPi(pfx.."set/active_camera",    1), -- moving camera enabled
  real_generators = cGPi(pfx.."set/real_generators",  1), -- generators can fail on overload
  real_gears      = cGPi(pfx.."set/real_gears",       1), -- gear can fail at overspeed
  real_brakes     = cGPi(pfx.."set/real_brakes",      1), -- brakes can overheat and fail
  real_tyres      = cGPi(pfx.."set/real_tyres",       1), -- tyres can blow from excessive braking
  north_GPK       = cGPi(pfx.."set/north_GPK",        1), -- GPK mode for northern hemisphere
  real_fuel       = cGPi(pfx.."set/real_fuel",        1), -- real fuel system (vs FSE compatibility)
  black_box       = cGPi(pfx.."set/black_box",        0), -- flight data recording
  -- Sound and language
  sound_volume    = cGPf(pfx.."set/sound_volume",  1000), -- master sound volume
  lang_kill_en    = cGPi(pfx.."set/lang_kill_en",     0), -- mute English callouts
  lang_kill_ru    = cGPi(pfx.."set/lang_kill_ru",     1), -- mute Russian callouts
}

-- Power
drf_pwr = {
  bus_dc27v = cGPf(pfx.."power/bus_DC_27_volt", 27),
  bus_dc27ve = cGPf(pfx.."power/bus_DC_27_volt_emerg", 27),
  bus_dc27a = cGPf(pfx.."power/bus_DC_27_amp"),
  bus_dc27ae = cGPf(pfx.."power/bus_DC_27_amp_emerg"),
  bus_ac36v = cGPf(pfx.."power/bus_AC_36_volt", 36),
  bus_ac36a = cGPf(pfx.."power/bus_AC_36_amp"),
  bus_ac115v = cGPf(pfx.."power/bus_AC_115_volt", 115),
  bus_ac115a = cGPf(pfx.."power/bus_AC_115_amp"),
}

-- Power-presence thresholds + helpers, centralising the common bus-voltage gates
-- (vs inlining literals like "get(bus_DC_27_volt) > 21"). MAIN buses only --
-- sites with divergent literals (>20, >112) or the EMERGENCY bus stay inline
-- (changing a threshold/bus is a behaviour change).
PWR = { DC27_MIN = 21, AC115_MIN = 110, AC36_MIN = 30 }
function _G.dcOK() return get(drf_pwr.bus_dc27v)  > PWR.DC27_MIN  end
function _G.acOK() return get(drf_pwr.bus_ac115v) > PWR.AC115_MIN end
-- ac36OK() covers ONLY the uniform >30 AC-36 checks (ap28/gpk/gyro/radar).
-- fuel_logic/fuel_panel_logic (>34) and art_horizons_logic (>28) use divergent
-- thresholds on purpose and stay inline.
function _G.ac36OK() return get(drf_pwr.bus_ac36v) > PWR.AC36_MIN end

-- Engine
drf_engn = {
  engine_park = cGPfa(pfx.."covers/engine_park", 2),
  thro_comm_1 = gP("sim/flightmodel/engine/ENGN_thro[0]"),
  thro_comm_2 = gP("sim/flightmodel/engine/ENGN_thro[1]"),
  thro_comm_3 = gP("sim/flightmodel/engine/ENGN_thro[2]"),
  thro_need_1 = gP("sim/flightmodel/engine/ENGN_thro_use[0]"),
  thro_need_2 = gP("sim/flightmodel/engine/ENGN_thro_use[1]"),
  thro_need_3 = gP("sim/flightmodel/engine/ENGN_thro_use[2]"),
  virt_rud1 = cGPf(pfx.."misc/virt_rud1"), -- virtual rud ENGN #1
  virt_rud2 = cGPf(pfx.."misc/virt_rud2"), -- virtual rud ENGN #2
  virt_rud3 = cGPf(pfx.."misc/virt_rud3"), -- virtual rud RU19
}

-- Lights. The cGP* calls register the an-24/lights/* datarefs (the only
-- side-effect that matters here); consumers bind those by name via
-- globalProperty(), so these handles are grouped for namespacing only.
drf_lights = {
  cfdlamp = cGPfa(pfx.."lights/CFDLAMP", 10),
  ccfdlamp = cGPfa(pfx.."lights/CCFDLAMP", 10),
  lfdlamp = cGPfa(pfx.."lights/LFDLAMP", 10),
  rfdlamp = cGPfa(pfx.."lights/RFDLAMP", 10),
  lfdgdl = cGPfa(pfx.."lights/LFDGaugesDownLeft", 10),
  lfdgdr = cGPfa(pfx.."lights/LFDGaugesDownRight", 10),
  lfdgul = cGPfa(pfx.."lights/LFDGaugesUpLeft", 10),
  lfdgur = cGPfa(pfx.."lights/LFDGaugesUpRight", 10),
  rfdgdl = cGPfa(pfx.."lights/RFDGaugesDownLeft", 10),
  rfdgdr = cGPfa(pfx.."lights/RFDGaugesDownRight", 10),
  rfdgul = cGPfa(pfx.."lights/RFDGaugesUpLeft", 10),
  rfdgur = cGPfa(pfx.."lights/RFDGaugesUpRight", 10),
  olb = cGPfa(pfx.."lights/overhead_lamp_bort", 10),
  oll = cGPfa(pfx.."lights/overhead_lamp_left", 10),
  olr = cGPfa(pfx.."lights/overhead_lamp_right", 10),
  olpl = cGPfa(pfx.."lights/overhead_lamp_pilotleft", 10),
  olpr = cGPfa(pfx.."lights/overhead_lamp_pilotright", 10),
  olnl = cGPfa(pfx.."lights/overhead_lamp_navleft", 10),
  olnr = cGPfa(pfx.."lights/overhead_lamp_navright", 10),
  olrad = cGPfa(pfx.."lights/overhead_lamp_rad", 10),
  -- Lights in the cockpit
  ollb = cGPf(pfx.."lights/overhead_lamp_left_bright", 1),
  ollm = cGPi(pfx.."lights/overhead_lamp_left_mode"), -- 0 off, 1 red, 2 white
  ollra = cGPf(pfx.."lights/overhead_lamp_left_rot_around"),
  ollru = cGPf(pfx.."lights/overhead_lamp_left_rot_updown", 45),
  olrb = cGPf(pfx.."lights/overhead_lamp_right_bright", 1),
  olrm = cGPi(pfx.."lights/overhead_lamp_right_mode"), -- 0 off, 1 red, 2 white
  olrra = cGPf(pfx.."lights/overhead_lamp_right_rot_around"),
  olrru = cGPf(pfx.."lights/overhead_lamp_right_rot_updown", 45),
  olprb = cGPf(pfx.."lights/overhead_lamp_pilot_right_bright", 1),
  olprm = cGPi(pfx.."lights/overhead_lamp_pilot_right_mode"), -- 0 off, 1 red, 2 white
  olprra = cGPf(pfx.."lights/overhead_lamp_pilot_right_rot_around"),
  olprru = cGPf(pfx.."lights/overhead_lamp_pilot_right_rot_updown", 45),
  olplb = cGPf(pfx.."lights/overhead_lamp_pilot_left_bright", 1),
  olplm = cGPi(pfx.."lights/overhead_lamp_pilot_left_mode"), -- 0 off, 1 red, 2 white
  olplra = cGPf(pfx.."lights/overhead_lamp_pilot_left_rot_around"),
  olplru = cGPf(pfx.."lights/overhead_lamp_pilot_left_rot_updown", 45),
  olnlb = cGPf(pfx.."lights/overhead_lamp_nav_left_bright", 1),
  olnlm = cGPi(pfx.."lights/overhead_lamp_nav_left_mode"), -- 0 off, 1 red, 2 white
  olnlra = cGPf(pfx.."lights/overhead_lamp_nav_left_rot_around"),
  olnlru = cGPf(pfx.."lights/overhead_lamp_nav_left_rot_updown", 50),
  olnrb = cGPf(pfx.."lights/overhead_lamp_nav_right_bright", 1),
  olnrm = cGPi(pfx.."lights/overhead_lamp_nav_right_mode"), -- 0 off, 1 red, 2 white
  olnrra = cGPf(pfx.."lights/overhead_lamp_nav_right_rot_around", 30),
  olnrru = cGPf(pfx.."lights/overhead_lamp_nav_right_rot_updown", 30),
  olradb = cGPf(pfx.."lights/overhead_lamp_rad_bright", 1),
  olradm = cGPi(pfx.."lights/overhead_lamp_rad_mode"), -- 0 off, 1 red, 2 white
  olradra = cGPf(pfx.."lights/overhead_lamp_rad_rot_around", -6),
  olradru = cGPf(pfx.."lights/overhead_lamp_rad_rot_updown", 20),
}

-- Animations
cGPi(pfx.."anim/crew")
cGPf(pfx.."anim/headlight")

-- Propeller feather buttons (KFL-37)
cGPi(pfx.."prop/feather1_button")
cGPi(pfx.."prop/feather2_button")
cGPi(pfx.."prop/feather1_test1")
cGPi(pfx.."prop/feather2_test1")
cGPi(pfx.."prop/feather1_test2")
cGPi(pfx.."prop/feather2_test2")
cGPi(pfx.."prop/feather_test_cap")

-- V11 autofeather: "Engine failure" lamps in the KFL-37 buttons
cGPi(pfx.."prop/feather1_lamp")           -- left engine failure lamp (KFL-37)
cGPi(pfx.."prop/feather2_lamp")           -- right engine failure lamp (KFL-37)

-- Propeller pitch stop (low-pitch lock on start)
cGPi(pfx.."prop/pitch_stop")
cGPi(pfx.."prop/pitch_stop_cap", 1) -- default 1 = cap closed
cGPi(pfx.."prop/pitch_stop_set")

-- Fuel system — pilot switches (written by panel, read by fuel sim logic)
cGPi(pfx.."fuel/fire_valve1_sw", 1)          -- fire/fuel shutoff valve switch engine 1
cGPi(pfx.."fuel/fire_valve2_sw", 1)          -- fire/fuel shutoff valve switch engine 2
cGPi(pfx.."fuel/fire_valve3_sw")          -- fire/fuel shutoff valve switch RU-19
cGPi(pfx.."fuel/fuel_circle_valve_sw")    -- cross-feed (fuel circle) valve switch
cGPi(pfx.."fuel/pump1_switch", 2)            -- fuel pump switch tank 1
cGPi(pfx.."fuel/pump2_switch", 1)            -- fuel pump switch tank 2
cGPi(pfx.."fuel/pump3_switch", 1)            -- fuel pump switch tank 3
cGPi(pfx.."fuel/pump4_switch", 2)            -- fuel pump switch tank 4
cGPi(pfx.."fuel/q_meter1_switch", 1)         -- fuel quantity meter left on/off
cGPi(pfx.."fuel/q_meter2_switch", 1)         -- fuel quantity meter right on/off
cGPi(pfx.."fuel/ff_meter_switch", 1)         -- fuel flow meter on/off
cGPi(pfx.."fuel/auto_ff_switch", 1)          -- automatic fuel flow meter on/off
cGPi(pfx.."fuel/quantity_mode", 1)           -- fuel quantity display mode (0-3)
cGPi(pfx.."fuel/fuel_stop1", 1)              -- fuel stop valve 1
cGPi(pfx.."fuel/fuel_stop2", 1)              -- fuel stop valve 2
cGPi(pfx.."fuel/fuel_stop1_cap")          -- fuel stop valve 1 cap
cGPi(pfx.."fuel/fuel_stop2_cap")          -- fuel stop valve 2 cap
cGPi(pfx.."fuel/fuel_quant_button")       -- quantity test button (momentary)

-- Fuel system — valve and pump states (written by fuel sim logic)
cGPf(pfx.."fuel/fuel_access1", 1)            -- fuel shutoff valve 1 position (0=closed, 1=open)
cGPf(pfx.."fuel/fuel_access2", 1)            -- fuel shutoff valve 2 position
cGPf(pfx.."fuel/fuel_access3", 1)            -- fuel shutoff valve 3 (RU-19) position
cGPi(pfx.."fuel/fuel_circle_valve")       -- cross-feed valve actual position
cGPi(pfx.."fuel/tank1_pump", 1)              -- fuel pump 1 actual state
cGPi(pfx.."fuel/tank2_pump", 1)              -- fuel pump 2 actual state
cGPi(pfx.."fuel/tank3_pump", 1)              -- fuel pump 3 actual state
cGPi(pfx.."fuel/tank4_pump", 1)              -- fuel pump 4 actual state

-- Fuel system — quantity indication (written by fuel sim or tank logic)
cGPf(pfx.."fuel/tank1_q_ind")             -- tank 1 indicated quantity (kg)
cGPf(pfx.."fuel/tank2_q_ind")             -- tank 2 indicated quantity (kg)
cGPf(pfx.."fuel/tank3_q_ind")             -- tank 3 indicated quantity (kg)
cGPf(pfx.."fuel/tank4_q_ind")             -- tank 4 indicated quantity (kg)

-- Fuel system — panel LEDs and needle angles (written by fuel_panel_3d, read by fuel_panel_2d)
cGPi(pfx.."fuel/quant_1000_lit")          -- fuel quantity < 1000 kg warning lamp
cGPi(pfx.."fuel/left_filter_block_lit")   -- left fuel filter blockage lamp
cGPi(pfx.."fuel/right_filter_block_lit")  -- right fuel filter blockage lamp
cGPi(pfx.."fuel/fuel_circle_lit")         -- cross-feed valve open lamp
cGPi(pfx.."fuel/left_fuel_press_lit")     -- left engine fuel pressure OK lamp
cGPi(pfx.."fuel/right_fuel_press_lit")    -- right engine fuel pressure OK lamp
cGPi(pfx.."fuel/left_pk_open_lit")        -- left fire valve open lamp (PK)
cGPi(pfx.."fuel/right_pk_open_lit")       -- right fire valve open lamp (PK)
cGPi(pfx.."fuel/left_chip_lit")           -- left gearbox chip detector lamp
cGPi(pfx.."fuel/right_chip_lit")          -- right gearbox chip detector lamp
cGPi(pfx.."fuel/fuel_lump1_lit")          -- pump 1 run lamp
cGPi(pfx.."fuel/fuel_lump2_lit")          -- pump 2 run lamp
cGPi(pfx.."fuel/fuel_lump3_lit")          -- pump 3 run lamp
cGPi(pfx.."fuel/fuel_lump4_lit")          -- pump 4 run lamp
cGPi(pfx.."fuel/ru19_pk_open_lit")        -- RU-19 fire valve open lamp
cGPi(pfx.."fuel/ru19_pk_close_lit")       -- RU-19 fire valve closed lamp
cGPf(pfx.."fuel/fuel_flow_cc")            -- fuel flow meter state (0=off, 4=on)
cGPf(pfx.."fuel/fuel_flow_left_angle")    -- left flow needle angle (degrees)
cGPf(pfx.."fuel/fuel_flow_right_angle")   -- right flow needle angle (degrees)
cGPf(pfx.."fuel/fuel_flow_left_count")    -- left flow counter display value
cGPf(pfx.."fuel/fuel_flow_right_count")   -- right flow counter display value
cGPf(pfx.."fuel/fuel_flow_left_count_rot", 675)  -- left flow counter rotary accumulator
cGPf(pfx.."fuel/fuel_flow_right_count_rot", 675) -- right flow counter rotary accumulator
cGPf(pfx.."fuel/fuel_quant1_angle")       -- left quantity needle angle (degrees)
cGPf(pfx.."fuel/fuel_quant2_angle")       -- right quantity needle angle (degrees)

-- Start system — pilot inputs (written by start_panel_3d, read by start_logic)
cGPi(pfx.."start/eng_start_btn")          -- engine start button (momentary)
cGPi(pfx.."start/start_at_ground_cap")    -- ground/air start selector cap
cGPi(pfx.."start/start_at_ground")        -- ground start mode selector (0=air, 1=ground)
cGPi(pfx.."start/sel_left_right")         -- engine selector (-1=left, 0=none, 1=right)
cGPi(pfx.."start/eng_start_mode")         -- start mode (0=cold rotate, 1=start)
cGPi(pfx.."start/eng_start_stop")         -- start abort button (momentary)
cGPi(pfx.."start/left_temp_check")        -- left engine temperature check mode
cGPi(pfx.."start/left_prt24_on", 1)          -- left PRT-24 voltage regulator on/off
cGPi(pfx.."start/right_temp_check")       -- right engine temperature check mode
cGPi(pfx.."start/right_prt24_on", 1)         -- right PRT-24 voltage regulator on/off
cGPi(pfx.."start/ru19_air_start_btn")     -- RU-19 air start button (momentary)
cGPi(pfx.."start/ru19_ground_start_btn")  -- RU-19 ground start button (momentary)
cGPi(pfx.."start/ru19_ground_start_cap")  -- RU-19 ground start button protective cap
cGPi(pfx.."start/ru19_start_mode")        -- RU-19 start mode
cGPi(pfx.."start/ru19_start_stop")        -- RU-19 stop button (momentary)
cGPi(pfx.."start/ru19_start_main_sw")     -- RU-19 main switch
cGPi(pfx.."start/ru19_start_main_sw_cap") -- RU-19 main switch protective cap

-- Start system — status lamps (written by start_logic, read by start_panel_3d)
cGPi(pfx.."start/apd_work_lit")           -- APD starter work lamp
cGPi(pfx.."start/pt29_work_lit")          -- PT-29 (RU-19 starter) work lamp
cGPi(pfx.."start/strip_lit")              -- strip (RU-19 running) lamp
cGPf(pfx.."start/starter_volt")           -- starter voltmeter reading
cGPf(pfx.."start/starter_amp")            -- starter ammeter reading
-- V11: smoothed starter gauge values written by amp_volt_filter from starter_amp/volt
cGPf(pfx.."start/starter_amp_filtered")   -- filtered starter ammeter reading
cGPf(pfx.."start/starter_volt_filtered")  -- filtered starter voltmeter reading

-- Start system — internal fuel start valves and starter modes
cGPi(pfx.."start/fuel_start1", 1)            -- engine 1 start fuel valve position
cGPi(pfx.."start/fuel_start2", 1)            -- engine 2 start fuel valve position
cGPi(pfx.."start/fuel_start3", 1)            -- RU-19 start fuel valve position
cGPf(pfx.."start/ru19_N1")                -- RU-19 N1 RPM (%)
cGPi(pfx.."power/stg1_starter")           -- STG-12 generator 1 used as starter
cGPi(pfx.."power/stg2_starter")           -- STG-12 generator 2 used as starter
cGPi(pfx.."power/gs24_starter")           -- GS-24 ground power unit used as starter

-- Autopilot (AP-28) — state datarefs (declared here; used by ap28_logic and gps_nav)
cGPi(pfx.."ap/ap_state")                  -- AP-28 overall engagement state
cGPi(pfx.."ap/ap_curse_stab", 2)             -- course stabilisation mode (0=off,1=HDG,2=GPK,3=GPS)
cGPf(pfx.."ap/ap_hdg_diff")               -- heading error fed to AP yaw channel
cGPf(pfx.."ap/ap_yaw_comm")               -- AP yaw (rudder) command output
cGPf(pfx.."ap/ap_roll_comm")              -- AP roll (aileron) command output
cGPf(pfx.."ap/curse_gpk")                 -- GPK compass course for AP
cGPf(pfx.."ap/curse_gps")                 -- GPS course output to AP
cGPi(pfx.."ap/gps_valid")                 -- GPS route validity flag (1=valid)
cGPf(pfx.."ap/gps_xtk_correction")        -- GPS cross-track correction (degrees)
cGPi(pfx.."ap/gps_mode_on")               -- GPS mode active flag (1=AP following GPS route)
cGPf(pfx.."ap/ap_power_cc")               -- AP power consumption (amps)

-- Gauges — current consumption datarefs (read by bus_counter)
cGPf(pfx.."gauges/uvid_30_cc")
cGPf(pfx.."gauges/feet_meter_cc")
cGPf(pfx.."gauges/AHZ_cc")
cGPf(pfx.."gauges/eup53_cc")
cGPf(pfx.."gauges/GIK_cc")
cGPf(pfx.."gauges/GPK_cc")
cGPf(pfx.."gauges/curs_mp_cc")
cGPf(pfx.."gauges/dme_cc")
cGPf(pfx.."gauges/mrp_cc")
cGPf(pfx.."gauges/rv_2_cc")
cGPf(pfx.."gauges/ssos_cc")
cGPf(pfx.."gauges/auasp_cc")
cGPf(pfx.."gauges/uprt_cc")

-- Fuel system — additional states and current consumption
cGPi(pfx.."fuel/auto_ff", 1)                 -- auto fuel flow active state
cGPf(pfx.."fuel/fire_valve1", 1)             -- fire shutoff valve 1 actual position
cGPf(pfx.."fuel/fire_valve2", 1)             -- fire shutoff valve 2 actual position
cGPf(pfx.."fuel/fire_valve3")             -- fire shutoff valve 3 (RU-19) actual position
cGPf(pfx.."fuel/fuel_pumps_cc")           -- fuel pumps total current consumption
cGPf(pfx.."fuel/fuel_valves_cc")          -- fuel valves total current consumption
cGPf(pfx.."fuel/fuel_circle_cc")          -- cross-feed valve current consumption
cGPf(pfx.."fuel/fuel_meter_cc")           -- fuel meter current consumption

-- Autopilot (AP-28) — extended state, commands, and mode flags
cGPi(pfx.."ap/ap_ON")                     -- AP master on/off
cGPi(pfx.."ap/ap_power", 1)                  -- AP power supply state
cGPi(pfx.."ap/ap_pitch_sw", 1)               -- pitch channel switch
cGPi(pfx.."ap/ap_pitch")                  -- pitch channel value
cGPf(pfx.."ap/ap_pitch_comm")             -- pitch command output
cGPf(pfx.."ap/ap_pitch_diff")             -- pitch error
cGPi(pfx.."ap/ap_pitch_power")            -- pitch channel power
cGPf(pfx.."ap/ap_roll")                   -- roll channel value
cGPf(pfx.."ap/ap_roll_diff")              -- roll error
cGPi(pfx.."ap/ap_roll_power")             -- roll channel power
cGPi(pfx.."ap/ap_hdg_power")              -- heading channel power
cGPf(pfx.."ap/ap_yaw_spd")               -- yaw rate
cGPi(pfx.."ap/ap_trim", 1)                   -- trim position
cGPi(pfx.."ap/ap_horizont")               -- artificial horizon reference
cGPi(pfx.."ap/ap_kv")                     -- KV mode selector
cGPi(pfx.."ap/ap_kv_lit")                 -- KV mode lamp
cGPi(pfx.."ap/ap_mech_off")               -- mechanical AP disconnect
cGPi(pfx.."ap/ap_mech_off_cap")           -- mechanical disconnect cap
cGPi(pfx.."ap/ap_on_lit")                 -- AP on lamp
cGPi(pfx.."ap/ap_ready_lit")              -- AP ready lamp
cGPi(pfx.."ap/ap_up_lit")                 -- pitch up lamp
cGPi(pfx.."ap/ap_down_lit")               -- pitch down lamp
cGPi(pfx.."ap/ap_ail_fail_lit")           -- aileron failure lamp
cGPi(pfx.."ap/ap_elev_fail_lit")          -- elevator failure lamp
cGPf(pfx.."ap/curse_gik")                 -- GIK compass course for AP
cGPf(pfx.."ap/curse_zk")                  -- ZK compass course for AP
cGPf(pfx.."ap/indicated_pitch")           -- indicated pitch angle
cGPf(pfx.."ap/indicated_roll")            -- indicated roll angle

-- Autopilot state for SmartCopilot sync
cGPf(pfx.."autopilot_state_PF")
cGPf(pfx.."autopilot_state_PF_ApbuttonState", 3)
cGPi(pfx.."autopilot_state_PF_button")
cGPf(pfx.."autopilot_state_FO")
cGPf(pfx.."autopilot_state_FO_ApbuttonState", 3)
cGPi(pfx.."autopilot_state_FO_button")

-- ARK-11 automatic direction finder (ADF) — two units
cGPf(pfx.."ark/ark1_angle")               -- ADF1 bearing angle
cGPi(pfx.."ark/ark1_ant_sw")              -- ADF1 antenna switch
cGPi(pfx.."ark/ark1_band")                -- ADF1 frequency band
cGPi(pfx.."ark/ark1_band_fix")            -- ADF1 band fixed value
cGPi(pfx.."ark/ark1_band_need")           -- ADF1 required band
cGPi(pfx.."ark/ark1_button")              -- ADF1 button
cGPf(pfx.."ark/ark1_cc")                  -- ADF1 current consumption
cGPi(pfx.."ark/ark1_cw", 1)                  -- ADF1 CW mode
cGPi(pfx.."ark/ark1_fine_tune")           -- ADF1 fine tune position
cGPi(pfx.."ark/ark1_fine_tune_need")      -- ADF1 required fine tune
cGPi(pfx.."ark/ark1_mode", 1)                -- ADF1 operating mode
cGPi(pfx.."ark/ark1_need_freq")           -- ADF1 target frequency
cGPf(pfx.."ark/ark1_signal")              -- ADF1 signal strength
cGPi(pfx.."ark/ark1_tune")                -- ADF1 tuning position
cGPi(pfx.."ark/ark1_tune_fix")            -- ADF1 fixed tuning
cGPi(pfx.."ark/ark1_tune_need")           -- ADF1 required tuning
cGPf(pfx.."ark/ark2_angle")               -- ADF2 bearing angle
cGPi(pfx.."ark/ark2_ant_sw")              -- ADF2 antenna switch
cGPi(pfx.."ark/ark2_band")                -- ADF2 frequency band
cGPi(pfx.."ark/ark2_band_fix")            -- ADF2 band fixed value
cGPi(pfx.."ark/ark2_band_need")           -- ADF2 required band
cGPi(pfx.."ark/ark2_button")              -- ADF2 button
cGPf(pfx.."ark/ark2_cc")                  -- ADF2 current consumption
cGPi(pfx.."ark/ark2_cw", 1)                  -- ADF2 CW mode
cGPi(pfx.."ark/ark2_fine_tune")           -- ADF2 fine tune position
cGPi(pfx.."ark/ark2_fine_tune_need")      -- ADF2 required fine tune
cGPi(pfx.."ark/ark2_mode", 1)                -- ADF2 operating mode
cGPi(pfx.."ark/ark2_need_freq")           -- ADF2 target frequency
cGPf(pfx.."ark/ark2_signal")              -- ADF2 signal strength
cGPi(pfx.."ark/ark2_tune")                -- ADF2 tuning position
cGPi(pfx.."ark/ark2_tune_fix")            -- ADF2 fixed tuning
cGPi(pfx.."ark/ark2_tune_need")           -- ADF2 required tuning

-- Beacon and cabin alerts
cGPi(pfx.."beacon_up")                    -- beacon up state
cGPi(pfx.."beacon_down")                  -- beacon down state
cGPi(pfx.."isalerton")                    -- alert system active
cGPi(pfx.."nosmokingswitch")              -- no smoking switch
cGPi(pfx.."nosmokingswitchonoff")         -- no smoking switch toggled state
cGPi(pfx.."soundCap")                     -- sound cap
cGPi(pfx.."test_lamp_pilot")              -- test lamp pilot
cGPi(pfx.."test_lamp_pilot1_switch")      -- test lamp pilot 1 switch
cGPi(pfx.."test_lamp_pilot2_switch")      -- test lamp pilot 2 switch
cGPi(pfx.."testmsrp")                     -- MSRP test
cGPi(pfx.."testmsrp_cap")                 -- MSRP test cap
cGPi(pfx.."testmsrp_sound_switch")        -- MSRP test sound switch
cGPi(pfx.."testmsrp_sound_switch_cap")    -- MSRP test sound switch cap
cGPi(pfx.."msrp_switch")                  -- MSRP switch
cGPi(pfx.."msrp_switch_cap")              -- MSRP switch cap
cGPi(pfx.."msrp_sound_switch")            -- MSRP sound switch
cGPi(pfx.."msrp_sound_switch_cap")        -- MSRP sound switch cap
cGPi(pfx.."msrplight")                    -- MSRP light
cGPi(pfx.."push/steward")                 -- steward call button
cGPi(pfx.."push/steward_mode")            -- steward call mode
cGPi(pfx.."ssosstate")                    -- SSOS state
cGPf(pfx.."flightdeckdoor_toggle")        -- flight deck door toggle
cGPf(pfx.."flightdeckdoor_state")         -- flight deck door state (0=closed, 1=open)
cGPf(pfx.."flightdeckdoor")               -- flight deck door animation position
cGPf(pfx.."lukbesson")                    -- Lukbesson music player state
cGPi(pfx.."lukbesson_switch")             -- Lukbesson music switch
cGPi(pfx.."sim_version", 9)                  -- simulator version flag

-- Clocks
cGPf(pfx.."clocks/chrono_min_angle")      -- chronometer minutes needle
cGPf(pfx.."clocks/chrono_sec_angle")      -- chronometer seconds needle
cGPf(pfx.."clocks/flight_hour_angle")     -- flight clock hours needle
cGPf(pfx.."clocks/flight_min_angle")      -- flight clock minutes needle
cGPf(pfx.."clocks/flight_mode")           -- flight clock mode
cGPf(pfx.."clocks/flight_time")           -- flight elapsed time (seconds)
cGPf(pfx.."clocks/sec_mode")              -- stopwatch mode
cGPf(pfx.."clocks/sec_time")              -- stopwatch elapsed time
cGPf(pfx.."clocks/start_flight")          -- start flight clock button
cGPf(pfx.."clocks/start_sec")             -- start stopwatch button

-- Yoke and flight controls animation
cGPf(pfx.."controls/yoke_pitch")          -- yoke pitch animation
cGPf(pfx.."controls/yoke_roll")           -- yoke roll animation
cGPf(pfx.."controls/yoke_yaw")            -- rudder pedal animation

-- Engine cowl flap switches
cGPi(pfx.."cowl/flap_switch_L", 1)           -- left engine cowl flap switch
cGPi(pfx.."cowl/flap_switch_R", 1)           -- right engine cowl flap switch

-- Engine oil temperature (written by fake.lua thermal model, read by gauges)
cGPf(pfx.."engines/oil_temp_left")        -- left engine oil temperature
cGPf(pfx.."engines/oil_temp_right")       -- right engine oil temperature

-- Ground covers
cGPi(pfx.."covers/left_eng_main", 1)         -- left engine main cover
cGPi(pfx.."covers/left_eng_ext", 1)          -- left engine exhaust cover
cGPi(pfx.."covers/right_eng_main", 1)        -- right engine main cover
cGPi(pfx.."covers/right_eng_ext", 1)         -- right engine exhaust cover
cGPi(pfx.."covers/ru19_eng_ext", 1)          -- RU-19 exhaust cover
cGPi(pfx.."covers/antiice_left", 1)          -- left wing anti-ice cover
cGPi(pfx.."covers/antiice_right", 1)         -- right wing anti-ice cover
cGPi(pfx.."covers/rockets", 1)               -- rocket cover
cGPi(pfx.."covers/pitot_1", 1)               -- pitot 1 cover
cGPi(pfx.."covers/pitot_2", 1)               -- pitot 2 cover
cGPi(pfx.."covers/pitot_3", 1)               -- pitot 3 cover
cGPi(pfx.."covers/grounding", 1)             -- grounding cable
cGPi(pfx.."covers/gear_blocks", 1)           -- wheel chocks

-- Fire protection system
cGPi(pfx.."fire/fire_main_switcher", 1)      -- fire protection main switch
cGPi(pfx.."fire/fire_left_eng_lit")       -- left engine fire lamp
cGPi(pfx.."fire/fire_right_eng_lit")      -- right engine fire lamp
cGPi(pfx.."fire/fire_ru19_lit")           -- RU-19 fire lamp
cGPi(pfx.."fire/fire_left_nacelle_lit")   -- left nacelle fire lamp
cGPi(pfx.."fire/fire_right_nacelle_lit")  -- right nacelle fire lamp
cGPi(pfx.."fire/fire_left_wing_lit")      -- left wing fire lamp
cGPi(pfx.."fire/fire_right_wing_lit")     -- right wing fire lamp
cGPi(pfx.."fire/fire_warinig")            -- general fire warning lamp
cGPi(pfx.."fire/fire_left_eng_ext")       -- left engine fire extinguisher button
cGPi(pfx.."fire/fire_left_eng_ext_cap")   -- left engine extinguisher cap
cGPi(pfx.."fire/fire_right_eng_ext")      -- right engine fire extinguisher button
cGPi(pfx.."fire/fire_right_eng_ext_cap")  -- right engine extinguisher cap
cGPi(pfx.."fire/fire_second_ext")         -- second extinguisher button
cGPi(pfx.."fire/fire_second_ext_cap")     -- second extinguisher cap
cGPi(pfx.."fire/fire_left_nacelle_btn")   -- left nacelle extinguisher button
cGPi(pfx.."fire/fire_right_nacelle_btn")  -- right nacelle extinguisher button
cGPi(pfx.."fire/fire_left_wing_btn")      -- left wing extinguisher button
cGPi(pfx.."fire/fire_right_wing_btn")     -- right wing extinguisher button
cGPi(pfx.."fire/fire_ru19_btn")           -- RU-19 extinguisher button
cGPi(pfx.."fire/ext_left_ready_lit")      -- left extinguisher ready lamp
cGPi(pfx.."fire/ext_right_ready_lit")     -- right extinguisher ready lamp
cGPi(pfx.."fire/ext_first_ready_lit")     -- first bottle ready lamp
cGPi(pfx.."fire/ext_second_ready_lit")    -- second bottle ready lamp
cGPf(pfx.."fire/fire_cc")                 -- fire system current consumption

-- Gear door animation ratios
cGPf(pfx.."gear/door_ratio_0")            -- nose gear door animation
cGPf(pfx.."gear/door_ratio_1")            -- left main gear door animation
cGPf(pfx.."gear/door_ratio_2")            -- right main gear door animation

-- Hydraulic system
cGPi(pfx.."hydro/abs_sw")                 -- anti-lock brake switch
cGPf(pfx.."hydro/brake_left")             -- left brake pressure
cGPf(pfx.."hydro/brake_right")            -- right brake pressure
cGPf(pfx.."hydro/brake_press", 60)            -- brake system pressure
cGPi(pfx.."hydro/direction")              -- steering direction
cGPf(pfx.."hydro/emerg_brake")            -- emergency brake active
cGPf(pfx.."hydro/emerg_press", 100)            -- emergency system pressure
cGPf(pfx.."hydro/emerg_press_angle")      -- emergency pressure gauge needle
cGPi(pfx.."hydro/emerg_pump_sw")          -- emergency hydraulic pump switch
cGPf(pfx.."hydro/flap_cc")                -- flap actuator current consumption
cGPi(pfx.."hydro/flaps_rotary")           -- flap position indicator rotary
cGPi(pfx.."hydro/flaps_valve")            -- flap hydraulic valve
cGPi(pfx.."hydro/flaps_valve_emerg")      -- flap emergency valve
cGPi(pfx.."hydro/flaps_valve_emerg_cap")  -- flap emergency valve cap
cGPi(pfx.."hydro/frontgear_use_hydro", 1)    -- nose gear uses hydraulic steering
cGPi(pfx.."hydro/gear_rotary")            -- gear position indicator rotary
cGPi(pfx.."hydro/gear_unblock")           -- gear safety lock release
cGPi(pfx.."hydro/gear_unblock_cap")       -- gear safety lock cap
cGPi(pfx.."hydro/gear_valve")             -- gear hydraulic valve
cGPi(pfx.."hydro/hydro_circle")           -- hydraulic bypass circuit
cGPf(pfx.."hydro/hydro_quantity", 28)         -- hydraulic fluid quantity
cGPf(pfx.."hydro/hydro_quantity_angle")   -- hydraulic fluid quantity gauge needle
cGPf(pfx.."hydro/hydro_store", 100)            -- hydraulic accumulator pressure
cGPf(pfx.."hydro/left_press_angle")       -- left brake pressure gauge needle
cGPf(pfx.."hydro/main_press", 100)             -- main hydraulic pressure
cGPf(pfx.."hydro/main_press_angle")       -- main pressure gauge needle
cGPf(pfx.."hydro/park_brake")             -- parking brake active
cGPf(pfx.."hydro/pump_cc")                -- hydraulic pump current consumption
cGPf(pfx.."hydro/right_press_angle")      -- right brake pressure gauge needle
cGPf(pfx.."hydro/store_press_angle")      -- accumulator pressure gauge needle

-- Anti-ice system
cGPf(pfx.."ice/aa_main_cc")               -- main anti-ice current consumption
cGPf(pfx.."ice/aa_emerg_cc")              -- emergency anti-ice current consumption
cGPf(pfx.."ice/aa_115_cc")                -- 115V anti-ice current consumption
cGPi(pfx.."ice/aoa_ht_sw")                -- AOA sensor heat switch
cGPi(pfx.."ice/aoa_heat_lit")             -- AOA heat active lamp
cGPi(pfx.."ice/aoa_heat_test_lit")        -- AOA heat test lamp
cGPi(pfx.."ice/engine_ht_sw")             -- engine inlet heat switch
cGPi(pfx.."ice/engine_heat_lit")          -- engine heat active lamp
cGPi(pfx.."ice/pitot1_sw")                -- pitot 1 heat switch
cGPi(pfx.."ice/pitot1_lit")               -- pitot 1 heat lamp
cGPi(pfx.."ice/pitot1_test_lit")          -- pitot 1 heat test lamp
cGPi(pfx.."ice/pitot2_sw")                -- pitot 2 heat switch
cGPi(pfx.."ice/pitot2_lit")               -- pitot 2 heat lamp
cGPi(pfx.."ice/pitot2_test_lit")          -- pitot 2 heat test lamp
cGPi(pfx.."ice/prop_ht_sw")               -- propeller heat switch
cGPi(pfx.."ice/prop_left_lit")            -- left prop heat lamp
cGPi(pfx.."ice/prop_right_lit")           -- right prop heat lamp
cGPi(pfx.."ice/rio_sw")                   -- windshield (RIO) heat switch
cGPi(pfx.."ice/rio_heat_lit")             -- windshield heat lamp
cGPi(pfx.."ice/wing_ht_sw")               -- wing heat switch
cGPi(pfx.."ice/wing_heat_lit")            -- wing heat active lamp
cGPi(pfx.."ice/ice_left_eng_lit")         -- left engine ice detected lamp
cGPi(pfx.."ice/ice_right_eng_lit")        -- right engine ice detected lamp
cGPi(pfx.."ice/test_btn")                 -- anti-ice test button
cGPf(pfx.."ice/thermo_angle")             -- thermometer gauge needle
cGPi(pfx.."ice/window_ht_sw2")            -- window heat switch 2
cGPi(pfx.."ice/window_ht_psw1")           -- window heat pilot switch 1
cGPi(pfx.."ice/window_ht_psw2")           -- window heat pilot switch 2
cGPi(pfx.."ice/window_ht_cpsw1")          -- window heat copilot switch 1
cGPi(pfx.."ice/window_ht_cpsw2")          -- window heat copilot switch 2

-- Cockpit lighting
cGPf(pfx.."misc/beacon_light")            -- beacon light state
cGPf(pfx.."misc/bec_light_cc")            -- beacon light current consumption
cGPf(pfx.."misc/cockpit_light_cc")        -- cockpit lighting current consumption
cGPi(pfx.."misc/cockpit_panel")           -- cockpit panel brightness
cGPf(pfx.."misc/cockpit_red")             -- cockpit red light brightness
cGPf(pfx.."misc/cockpit_spot1")           -- cockpit spot 1 brightness
cGPf(pfx.."misc/cockpit_spot2")           -- cockpit spot 2 brightness
cGPf(pfx.."misc/lan_light_cc")            -- landing light current consumption
cGPi(pfx.."misc/lan_light_sw")            -- landing light switch
cGPi(pfx.."misc/lan_light_open_sw")       -- landing light extend switch
cGPf(pfx.."misc/nav_light")               -- navigation light state
cGPf(pfx.."misc/nav_light_cc")            -- nav light current consumption
cGPi(pfx.."misc/nav_light_sw", 1)            -- nav light switch
cGPi(pfx.."misc/hide_yokes")              -- hide yoke animation
-- RUD stop latch — owned here; engine_logic.lua references via gPi/gPf
cGPi(pfx.."misc/rud_close")               -- engine RUD stop latch
cGPi(pfx.."misc/rud_close_ru19")          -- RU-19 RUD stop latch
cGPi(pfx.."misc/rud_close_pos")           -- RUD stop latch position
cGPf(pfx.."misc/rud_stopor")              -- RUD stopor
-- Cockpit fans — owned here; cockpit_fan_anim.lua references via gPf/gPi
cGPf(pfx.."misc/vent_1")                  -- fan 1 rotation angle
cGPf(pfx.."misc/vent_2")
cGPf(pfx.."misc/vent_3")
cGPf(pfx.."misc/vent_4")
cGPi(pfx.."misc/vent_1_sw")               -- fan 1 switch
cGPi(pfx.."misc/vent_2_sw")
cGPi(pfx.."misc/vent_3_sw")
cGPi(pfx.."misc/vent_4_sw")
cGPi(pfx.."misc/vent_1_op")               -- fan 1 operating flag
cGPi(pfx.."misc/vent_2_op")
cGPi(pfx.."misc/vent_3_op")
cGPi(pfx.."misc/vent_4_op")
cGPf(pfx.."misc/podnos")                  -- tray animation state

-- Misc cockpit animations
cGPf(pfx.."misc/ag1_pitch")               -- AG1 pitch animation
cGPf(pfx.."misc/ag1_pitch_rot")           -- AG1 pitch rotation
cGPf(pfx.."misc/ag1_roll")                -- AG1 roll animation
cGPf(pfx.."misc/ag2_pitch")               -- AG2 pitch animation
cGPf(pfx.."misc/ag2_pitch_rot")           -- AG2 pitch rotation
cGPf(pfx.."misc/ag2_roll")                -- AG2 roll animation
cGPf(pfx.."misc/ag3_pitch")               -- AG3 pitch animation
cGPf(pfx.."misc/ag3_pitch_rot")           -- AG3 pitch rotation
cGPf(pfx.."misc/ag3_roll")                -- AG3 roll animation
cGPf(pfx.."misc/aoa_sensor_angle")        -- AOA sensor angle
cGPf(pfx.."misc/ushdb_1_scale_angle")     -- USHDB-1 scale angle
cGPf(pfx.."misc/ushdb_1_scale_dir")       -- USHDB-1 scale direction
cGPf(pfx.."misc/ushdb_2_scale_angle")     -- USHDB-2 scale angle (referenced by radiocompas_big_2d.lua)
cGPf(pfx.."misc/ushdb_2_scale_dir")       -- USHDB-2 scale direction
cGPf(pfx.."misc/ushdb_3_scale_angle")     -- USHDB-3 scale angle
cGPf(pfx.."misc/ushdb_3_scale_dir")       -- USHDB-3 scale direction

-- GNS430 knob animation angles (referenced by gns430_anim.lua; note 'custom/' prefix, not project)
cGPi("custom/GNS430/fine_angle1")         -- fine tuning knob angle
cGPi("custom/GNS430/coarse_angle1")       -- coarse tuning knob angle
cGPi("custom/GNS430/page_angle1")         -- page knob angle
cGPi("custom/GNS430/chapter_angle1")      -- chapter knob angle

-- NAS-1 navigation computer
cGPf(pfx.."nas1/DISS", 1)                    -- DISS sensor active
cGPf(pfx.."nas1/E_needle")                -- east needle
cGPf(pfx.."nas1/N_needle")                -- north needle
cGPf(pfx.."nas1/counter")                 -- distance counter
cGPf(pfx.."nas1/map_angle")               -- map rotation angle
cGPf(pfx.."nas1/mode1")                   -- operating mode 1
cGPf(pfx.."nas1/mode2")                   -- operating mode 2
cGPf(pfx.."nas1/nas1_cc")                 -- NAS-1 current consumption
cGPf(pfx.."nas1/water")                   -- water detector active
cGPf(pfx.."nas1/windangle")               -- wind direction
cGPf(pfx.."nas1/windspeed")               -- wind speed

-- Panel visibility state — created by panel_logic.lua; no declaration needed here

-- Electrical power system
cGPi(pfx.."power/available")              -- avionics power-available flag (referenced by klnpwr_logic.lua)
cGPi(pfx.."power/DC_source", 1)              -- DC 27V bus source (0=none,1=STG1,2=STG2,3=GS24,4=bat)
cGPi(pfx.."power/AC_source", 1)              -- AC 115V bus source (1=gen,2=inverter,3=external)
cGPi(pfx.."power/DC_volt_mode", 2)           -- DC voltmeter selector
cGPi(pfx.."power/AC36_volt_mode")         -- AC 36V voltmeter selector
cGPi(pfx.."power/AC115_volt_mode")        -- AC 115V voltmeter selector
cGPi(pfx.."power/power_mode", 2)             -- power management mode
cGPi(pfx.."power/ground_available")       -- ground power connected
cGPi(pfx.."power/emerg_mode", 1)             -- emergency power mode active
cGPf(pfx.."power/emerg_cap")              -- emergency mode cap
cGPi(pfx.."power/main_on_emerg", 1)          -- main bus tied to emergency bus
cGPi(pfx.."power/GS24_mode", 2)              -- GS-24 generator mode
cGPi(pfx.."power/PO750_mode", 2)             -- PO-750 inverter mode
cGPi(pfx.."power/PT1000_mode", 2)            -- PT-1000 inverter mode
cGPi(pfx.."power/inv_PT1000_1", 1)           -- PT-1000 inverter 1 active
cGPi(pfx.."power/inv_PT1000_2")           -- PT-1000 inverter 2 active
cGPi(pfx.."power/inv_PT750", 1)              -- PT-750 inverter active
cGPi(pfx.."power/STG_disconnect_cap1")    -- STG generator 1 disconnect cap
cGPi(pfx.."power/STG_disconnect_cap2")    -- STG generator 2 disconnect cap
cGPi(pfx.."power/stg1_on", 1)                -- STG-12 generator 1 switch on
cGPi(pfx.."power/stg2_on", 1)                -- STG-12 generator 2 switch on
cGPi(pfx.."power/stg1_is_gen", 1)            -- STG-12 generator 1 generating
cGPi(pfx.."power/stg2_is_gen", 1)            -- STG-12 generator 2 generating
cGPi(pfx.."power/stg1_on_bus", 1)            -- STG-12 generator 1 on bus
cGPi(pfx.."power/stg2_on_bus", 1)            -- STG-12 generator 2 on bus
cGPf(pfx.."power/stg1_volt", 28.5)              -- STG-12 generator 1 voltage
cGPf(pfx.."power/stg2_volt", 28.5)              -- STG-12 generator 2 voltage
cGPf(pfx.."power/stg1_amp")               -- STG-12 generator 1 current
cGPf(pfx.."power/stg2_amp")               -- STG-12 generator 2 current
cGPf(pfx.."power/stg1_amp_cc")            -- STG-12 generator 1 current consumption
cGPf(pfx.."power/stg2_amp_cc")            -- STG-12 generator 2 current consumption
cGPi(pfx.."power/gs24_is_gen", 1)            -- GS-24 generator generating
cGPi(pfx.."power/gs24_on_bus", 1)            -- GS-24 generator on bus
cGPf(pfx.."power/gs24_volt", 28.5)              -- GS-24 voltage
cGPf(pfx.."power/gs24_amp")               -- GS-24 current
cGPf(pfx.."power/gs24_amp_cc")            -- GS-24 current consumption
cGPi(pfx.."power/go1_on_bus", 1)             -- GO-1 (external) generator 1 on bus
cGPi(pfx.."power/go2_on_bus", 1)             -- GO-2 (external) generator 2 on bus
cGPf(pfx.."power/go1_volt", 115)               -- external generator 1 voltage
cGPf(pfx.."power/go2_volt", 115)               -- external generator 2 voltage
cGPf(pfx.."power/go1_amp")                -- external generator 1 current
cGPf(pfx.."power/go2_amp")                -- external generator 2 current
cGPi(pfx.."power/bat1_on", 1)                -- battery 1 switch
cGPi(pfx.."power/bat2_on", 1)                -- battery 2 switch
cGPi(pfx.."power/bat3_on", 1)                -- battery 3 switch
cGPf(pfx.."power/bat1_volt", 24)              -- battery 1 voltage
cGPf(pfx.."power/bat2_volt", 24)              -- battery 2 voltage
cGPf(pfx.."power/bat3_volt", 24)              -- battery 3 voltage
cGPf(pfx.."power/bat1_amp")               -- battery 1 current
cGPf(pfx.."power/bat2_amp")               -- battery 2 current
cGPf(pfx.."power/bat3_amp")               -- battery 3 current
cGPf(pfx.."power/bat_all_volt")           -- total battery voltage
cGPf(pfx.."power/bat_all_amp")            -- total battery current
cGPf(pfx.."power/bat_amp_cc")             -- battery charging current consumption

-- RLS weather radar
cGPi(pfx.."rls/rls_power_sw", 1)             -- radar power switch
cGPf(pfx.."rls/rls_power_cc")             -- radar current consumption
cGPi(pfx.."rls/rls_mode")                 -- radar operating mode
cGPi(pfx.."rls/rls_mode_lamp")            -- radar mode lamp
cGPf(pfx.."rls/rls_bright", 1)               -- radar display brightness
cGPf(pfx.."rls/rls_contr", 1)                -- radar display contrast
cGPi(pfx.."rls/rls_scan_spd", 50)             -- radar scan speed
cGPi(pfx.."rls/rls_scan_spd_up")          -- radar scan speed up control
cGPi(pfx.."rls/rls_scan_spd_down")        -- radar scan speed down control
cGPf(pfx.."rls/rls_signs", 1)                -- radar sign mode
cGPf(pfx.."rls_pos_angle")                -- radar antenna position angle (used by cockpit OBJ animation)

-- RSBN short-range navigation
-- RSBN root-level datarefs (legacy names used by the RSBN panel and SmartCopilot)
cGPf(pfx.."rsbn_set_ZPU")                 -- RSBN set ZPU (assigned track angle)
cGPf(pfx.."rsbn_set_targetangle")         -- RSBN target angle
cGPf(pfx.."rsbn_set_targetdist")          -- RSBN target distance
cGPf(pfx.."rsbn_ch1")                     -- RSBN channel selector 1
cGPf(pfx.."rsbn_ch2")                     -- RSBN channel selector 2
cGPf(pfx.."rsbn_mode")                    -- RSBN mode
cGPf(pfx.."rsbn_power_sw")                -- RSBN power switch
cGPf(pfx.."rsbn_set_azimut")              -- RSBN set azimuth
cGPf(pfx.."rsbn_set_orbit")               -- RSBN set orbit
cGPi(pfx.."rsbn/dataset", 1)                 -- RSBN dataset selector
cGPi(pfx.."rsbn/receive")                 -- RSBN receive active
cGPi(pfx.."rsbn/channel")                 -- RSBN channel
cGPf(pfx.."rsbn/lat")                     -- RSBN beacon latitude
cGPf(pfx.."rsbn/lon")                     -- RSBN beacon longitude
cGPf(pfx.."rsbn/elev")                    -- RSBN beacon elevation
cGPf(pfx.."rsbn/defl")                    -- RSBN course deviation
cGPi(pfx.."rsbn/flag")                    -- RSBN valid flag
cGPf(pfx.."rsbn/rsbn_cc")                 -- RSBN current consumption

-- SKV pressurization system
cGPi(pfx.."skv/bleed1_sw", 1)                -- bleed air 1 switch
cGPi(pfx.."skv/bleed2_sw", 1)                -- bleed air 2 switch
cGPi(pfx.."skv/dump_sw")                  -- pressure dump switch
cGPi(pfx.."skv/dump_cap")                 -- pressure dump cap
cGPi(pfx.."skv/skv_siren")                -- pressurization siren
cGPi(pfx.."skv/skv_siren_alarm")          -- pressurization siren alarm

-- SQI transponder
cGPi(pfx.."sq/sq_sw", 1)                     -- transponder switch
cGPi(pfx.."sq/sq_mode")                   -- transponder mode
cGPi(pfx.."sq/sq_emerg_cap")              -- transponder emergency cap
cGPi(pfx.."sq/emerg")                     -- transponder emergency squawk
cGPi(pfx.."sq/digit_1")                   -- transponder digit 1
cGPi(pfx.."sq/digit_2")                   -- transponder digit 2
cGPi(pfx.."sq/digit_3")                   -- transponder digit 3
cGPi(pfx.."sq/digit_4")                   -- transponder digit 4
cGPf(pfx.."sq/sq_cc")                     -- transponder current consumption

-- Sound system flags
cGPi(pfx.."sound/gndsound")               -- ground sounds active
cGPf(pfx.."sound/interier_cutoff")        -- interior sound cutoff frequency
cGPf(pfx.."sound/fmodvol")                -- main volume slider

-- Additional settings
cGPi(pfx.."set/arrest_third")             -- third engine arrest setting
cGPi(pfx.."set/left_agd_arrest")          -- left AGD arrest setting
cGPi(pfx.."set/right_agd_arrest")         -- right AGD arrest setting

-- Cabin lighting
cGPi(pfx.."switch/main_cabin_light")      -- main cabin light switch
cGPf(pfx.."switch/main_cabin_light_mode", 1) -- cabin light mode
cGPi(pfx.."switch/main_cabin_light_modeL")-- cabin light mode left
cGPi(pfx.."switch/main_cabin_light_modeR")-- cabin light mode right

-- Trim switches
cGPi(pfx.."trimm/ail_sw")                 -- aileron trim switch
cGPi(pfx.."trimm/rudd_sw")                -- rudder trim switch

-- View/camera settings
cGPi(pfx.."view/switch_vib", 1)              -- vibration effect switch
cGPi(pfx.."view/switch_view")             -- view mode switch

-- Gauges — navigation and flight instruments
cGPi(pfx.."gauges/gear_test_button")      -- landing gear lamp test button (referenced by gear_panel.lua)
cGPi(pfx.."gauges/AGB_left", 1)              -- AGB gyro left
cGPi(pfx.."gauges/AGD_left", 1)              -- AGD artificial horizon left
cGPi(pfx.."gauges/AGD_right", 1)             -- AGD artificial horizon right
cGPf(pfx.."gauges/agd_pitch_left")        -- AGD left pitch
cGPf(pfx.."gauges/agd_pitch_right")       -- AGD right pitch
cGPf(pfx.."gauges/agd_roll_left")         -- AGD left roll
cGPf(pfx.."gauges/agd_roll_right")        -- AGD right roll
cGPi(pfx.."gauges/GIK_sw", 1)                -- GIK compass switch
cGPi(pfx.."gauges/GIK_button")            -- GIK correction button
cGPf(pfx.."gauges/GIK_curse")             -- GIK heading output
cGPi(pfx.."gauges/GPK_sw", 1)                -- GPK gyrocompass switch
cGPi(pfx.."gauges/GPK_corr_sw", 1)           -- GPK correction switch
cGPf(pfx.."gauges/GPK_curse")             -- GPK heading output
cGPf(pfx.."gauges/GPK_corr")              -- GPK correction angle
cGPi(pfx.."gauges/GPK_corr_rot")          -- GPK correction rotary
cGPf(pfx.."gauges/GPK_lat")               -- GPK latitude setting
cGPf(pfx.."gauges/GPK_lat_rotary")        -- GPK latitude rotary
cGPf(pfx.."gauges/ap_GPK_corr")           -- AP GPK correction
cGPf(pfx.."gauges/gyro_curse")            -- gyro compass course
cGPf(pfx.."gauges/gyro2_curse")           -- gyro 2 compass course
cGPi(pfx.."gauges/ark_vor")               -- ADF/VOR selector
cGPf(pfx.."gauges/curs_1")                -- course deviation indicator 1
cGPf(pfx.."gauges/curs_2")                -- course deviation indicator 2
cGPi(pfx.."gauges/curs_mp1_sw", 1)           -- course indicator 1 switch
cGPi(pfx.."gauges/curs_mp2_sw", 1)           -- course indicator 2 switch
cGPf(pfx.."gauges/glide_1")               -- glideslope deviation 1
cGPf(pfx.."gauges/glide_2")               -- glideslope deviation 2
cGPf(pfx.."gauges/vor_1")                 -- VOR deviation 1
cGPf(pfx.."gauges/vor_2")                 -- VOR deviation 2
cGPi(pfx.."gauges/sp_ils", 1)                -- ILS lateral deviation
cGPi(pfx.."gauges/g1_flag", 1)               -- flag 1 (warn)
cGPi(pfx.."gauges/g2_flag", 1)               -- flag 2 (warn)
cGPi(pfx.."gauges/k1_flag", 1)               -- K flag 1
cGPi(pfx.."gauges/k2_flag", 1)               -- K flag 2
cGPi(pfx.."gauges/obs1_fromto")           -- OBS 1 from/to
cGPi(pfx.."gauges/obs1_fromto_lit")       -- OBS 1 from/to lamp
cGPi(pfx.."gauges/obs2_fromto")           -- OBS 2 from/to
cGPi(pfx.."gauges/obs2_fromto_lit")       -- OBS 2 from/to lamp
cGPi(pfx.."gauges/nav_select", 3)            -- NAV source selector
cGPi(pfx.."gauges/eup53_sw", 1)              -- EUP-53 turn coordinator switch
cGPi(pfx.."gauges/eup1_sw", 1)               -- switcher for eup1 turn coordinator
cGPf(pfx.."gauges/eup1_cc")               -- current consumption of eup1 turn coordinator
cGPi(pfx.."gauges/auasp_sw", 1)              -- AUASP switch
cGPi(pfx.."gauges/auasp_button")          -- AUASP button
cGPi(pfx.."gauges/auasp_warning")         -- AUASP warning lamp
cGPf(pfx.."gauges/feet_meter_press", 29.92)      -- feet/meter altimeter pressure setting
cGPi(pfx.."gauges/feet_meter_sw", 1)         -- feet/meter altimeter switch
cGPf(pfx.."gauges/radioalt")              -- radio altimeter reading
cGPi(pfx.."gauges/radioalt_dh")           -- radio altimeter decision height
cGPi(pfx.."gauges/rv_2_sw", 1)              -- RV-2 radio altimeter switch
cGPi(pfx.."gauges/uvid_30_sw", 1)            -- UVID-30 altimeter switch
cGPi(pfx.."gauges/dme_on", 1)               -- DME power switch
cGPi(pfx.."gauges/iv41_sw", 1)               -- IV-41 vertical speed switch
cGPi(pfx.."gauges/iv41_test")             -- IV-41 test button
cGPi(pfx.."gauges/bkk_sw", 1)                -- BKK switch
cGPi(pfx.."gauges/bkk_sw_cap")            -- BKK switch cap
cGPi(pfx.."gauges/bkk_check_sw", 1)          -- BKK check switch
cGPi(pfx.."gauges/bkk_check_sw_cap")      -- BKK check switch cap
cGPi(pfx.."gauges/ssos_sw")               -- SSOS switch
cGPi(pfx.."gauges/ssos_sw_cap")           -- SSOS switch cap
cGPi(pfx.."gauges/ssos_test_sw")          -- SSOS test switch
cGPi(pfx.."gauges/ssos_power_lit")        -- SSOS power lamp
cGPi(pfx.."gauges/ssos_warning")          -- SSOS warning
cGPi(pfx.."gauges/SSOS_alarm")            -- SSOS alarm
cGPi(pfx.."gauges/spu_mode", 3)              -- SPU intercom mode
cGPi(pfx.."gauges/spu_power_sw", 1)          -- SPU intercom power switch
cGPi(pfx.."gauges/mrp_mode")              -- MRP mode
cGPi(pfx.."gauges/oil_lamp1")             -- oil pressure lamp 1
cGPi(pfx.."gauges/oil_lamp2")             -- oil pressure lamp 2
cGPf(pfx.."gauges/torque_left")            -- left engine torque
cGPf(pfx.."gauges/torque_right")           -- right engine torque
cGPi(pfx.."gauges/high_vibro")             -- high vibration warning
cGPi(pfx.."gauges/roll_high")              -- high roll warning
cGPi(pfx.."gauges/noseweel")               -- nosewheel steering angle
cGPi(pfx.."gauges/nosewheel_mode_lamp")    -- nosewheel mode lamp
cGPi(pfx.."gauges/nosewheel_mode_ready")   -- nosewheel mode ready
cGPi(pfx.."gauges/nosewheel_mode_ready_delay")   -- nosewheel ready delay
cGPi(pfx.."gauges/nosewheel_mode_time_to_ready") -- nosewheel time to ready
cGPi(pfx.."gauges/gear_down")              -- gear down and locked lamp
cGPi(pfx.."gauges/gear_siren")             -- gear warning siren
cGPi(pfx.."gauges/flaps_siren")            -- flaps warning siren
cGPi(pfx.."gauges/siren_button")           -- siren cancel button

-- Gauges — SmartCopilot sync angles
cGPf(pfx.."gauges/sc_angle")
cGPf(pfx.."gauges/sc_ap_angle")
cGPf(pfx.."gauges/sc_curse_angle")
cGPf(pfx.."gauges/sc_ap_curse_angle")
cGPf(pfx.."gauges/sc_corr_angle")
cGPf(pfx.."gauges/sc_corr_ap_angle")
cGPf(pfx.."gauges/sc_ZK_curse_angle")
cGPf(pfx.."gauges/sc_KPPM_1_curse_angle")
cGPf(pfx.."gauges/sc_KPPM_2_curse_angle")
cGPf(pfx.."gauges/curse_angle")           -- course angle
cGPf(pfx.."gauges/scale_angle_1_smartcopilot")
cGPf(pfx.."gauges/scale_angle_2_smartcopilot")
cGPi(pfx.."gauges/rotate_dir1_smartcopilot")
cGPi(pfx.."gauges/rotate_dir2_smartcopilot")
cGPf(pfx.."gauges/zk_scale_angle_smartcopilot")
cGPi(pfx.."gauges/zk_rotate_dir_smartcopilot")
