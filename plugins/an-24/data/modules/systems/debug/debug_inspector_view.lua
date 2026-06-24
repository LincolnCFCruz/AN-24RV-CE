--[[

  File: debug_inspector_view.lua
  -----
  AN-24 System Viewer / Debug Inspector — the tabbed UI component.

  Developer/debug tool. Renders a graphical, tabbed overview of the major
  aircraft systems (gauges / bars / LEDs / chips) by reading datarefs LIVE.

  DECOUPLING CONTRACT (do not break):
    * This file reads aircraft state ONLY by dataref string name, through a
      memoised globalProperty() cache (see H()/readv() below). It never
      include()s or references any modules/systems/*.lua file, and it
      never set()s a system dataref. The schema table below is just strings.
    * "Commands" in X-Plane are momentary and have no readable state, so the
      schema surfaces the *datarefs the commands act on* (switch / lever / mode
      positions, status lamps) — that is the observable system state.

  Layout is a fixed 920x560 canvas; the context window scales it
  proportionally (see debug_inspector.lua). Long tabs scroll vertically
  (mouse wheel or the arrow buttons in the right gutter).

--]] size = {920, 560}

-- ---------------------------------------------------------------------------
-- Palette (SASL colours are {r,g,b,a} floats 0..1)
-- ---------------------------------------------------------------------------
local COL_BG = {0.10, 0.11, 0.13, 0.97}
local COL_TAB = {0.14, 0.15, 0.18, 1}
local COL_TABON = {0.20, 0.22, 0.27, 1}
local COL_CARD = {0.13, 0.14, 0.17, 1}
local COL_FRAME = {0.28, 0.30, 0.35, 1}
local COL_TEXT = {0.88, 0.90, 0.94, 1}
local COL_DIM = {0.55, 0.58, 0.64, 1}
local COL_GREEN = {0.27, 0.82, 0.40, 1}
local COL_AMBER = {0.98, 0.74, 0.20, 1}
local COL_RED = {0.94, 0.30, 0.30, 1}
local COL_ACCENT = {0.32, 0.66, 0.96, 1}
local COL_OFF = {0.30, 0.32, 0.37, 1}

local font = sasl.gl.loadFont("Roboto-Regular.ttf")

-- ---------------------------------------------------------------------------
-- Schema: one entry per tab. `short` is the tab-bar label, `name` the header.
-- Field kinds: gauge | bar | value | lamp | fail | enum
--   gauge/bar : min, max, unit, [warn_lo], [warn_hi], [dp]
--   value     : unit, [dp], [scale]
--   lamp      : on at value > 0.5; [fault]=true => on is bad (red), off is OK
--   fail      : X-Plane failure code (0 OK, 6 inoperative, else armed)
--   enum      : map = { [n] = "LABEL", ... }
-- ---------------------------------------------------------------------------
local schema = {{
    name = "Electrical",
    short = "Elec",
    fields = {{
        label = "DC 27V bus",
        dref = "an-24/power/bus_DC_27_volt",
        kind = "gauge",
        min = 0,
        max = 32,
        unit = "V",
        warn_lo = 24
    }, {
        label = "DC emerg bus",
        dref = "an-24/power/bus_DC_27_volt_emerg",
        kind = "gauge",
        min = 0,
        max = 32,
        unit = "V",
        warn_lo = 24
    }, {
        label = "DC bus load",
        dref = "an-24/power/bus_DC_27_amp",
        kind = "bar",
        min = 0,
        max = 600,
        unit = "A"
    }, {
        label = "AC 115V bus",
        dref = "an-24/power/bus_AC_115_volt",
        kind = "gauge",
        min = 0,
        max = 130,
        unit = "V",
        warn_lo = 104
    }, {
        label = "AC 115 load",
        dref = "an-24/power/bus_AC_115_amp",
        kind = "bar",
        min = 0,
        max = 200,
        unit = "A"
    }, {
        label = "AC 36V bus",
        dref = "an-24/power/bus_AC_36_volt",
        kind = "gauge",
        min = 0,
        max = 45,
        unit = "V",
        warn_lo = 33
    }, {
        label = "AC 36 load",
        dref = "an-24/power/bus_AC_36_amp",
        kind = "bar",
        min = 0,
        max = 100,
        unit = "A"
    }, {
        label = "DC source",
        dref = "an-24/power/DC_source",
        kind = "enum",
        map = {
            [0] = "NONE",
            [1] = "STG1",
            [2] = "STG2",
            [3] = "GS24",
            [4] = "BAT"
        }
    }, {
        label = "AC source",
        dref = "an-24/power/AC_source",
        kind = "enum",
        map = {
            [1] = "GEN",
            [2] = "INV",
            [3] = "EXT"
        }
    }, {
        label = "STG-1 gen",
        dref = "an-24/power/stg1_is_gen",
        kind = "lamp"
    }, {
        label = "STG-1 on bus",
        dref = "an-24/power/stg1_on_bus",
        kind = "lamp"
    }, {
        label = "STG-1 volt",
        dref = "an-24/power/stg1_volt",
        kind = "gauge",
        min = 0,
        max = 32,
        unit = "V",
        warn_lo = 24
    }, {
        label = "STG-1 amp",
        dref = "an-24/power/stg1_amp",
        kind = "bar",
        min = 0,
        max = 400,
        unit = "A"
    }, {
        label = "STG-2 gen",
        dref = "an-24/power/stg2_is_gen",
        kind = "lamp"
    }, {
        label = "STG-2 on bus",
        dref = "an-24/power/stg2_on_bus",
        kind = "lamp"
    }, {
        label = "STG-2 volt",
        dref = "an-24/power/stg2_volt",
        kind = "gauge",
        min = 0,
        max = 32,
        unit = "V",
        warn_lo = 24
    }, {
        label = "STG-2 amp",
        dref = "an-24/power/stg2_amp",
        kind = "bar",
        min = 0,
        max = 400,
        unit = "A"
    }, {
        label = "GS-24 gen",
        dref = "an-24/power/gs24_is_gen",
        kind = "lamp"
    }, {
        label = "GS-24 volt",
        dref = "an-24/power/gs24_volt",
        kind = "gauge",
        min = 0,
        max = 32,
        unit = "V",
        warn_lo = 24
    }, {
        label = "GS-24 amp",
        dref = "an-24/power/gs24_amp",
        kind = "bar",
        min = 0,
        max = 400,
        unit = "A"
    }, {
        label = "BAT-1 on",
        dref = "an-24/power/bat1_on",
        kind = "lamp"
    }, {
        label = "BAT-1 volt",
        dref = "an-24/power/bat1_volt",
        kind = "gauge",
        min = 0,
        max = 30,
        unit = "V",
        warn_lo = 22
    }, {
        label = "BAT-2 on",
        dref = "an-24/power/bat2_on",
        kind = "lamp"
    }, {
        label = "BAT-2 volt",
        dref = "an-24/power/bat2_volt",
        kind = "gauge",
        min = 0,
        max = 30,
        unit = "V",
        warn_lo = 22
    }, {
        label = "BAT-3 on",
        dref = "an-24/power/bat3_on",
        kind = "lamp"
    }, {
        label = "BAT-3 volt",
        dref = "an-24/power/bat3_volt",
        kind = "gauge",
        min = 0,
        max = 30,
        unit = "V",
        warn_lo = 22
    }, {
        label = "Bat total amp",
        dref = "an-24/power/bat_all_amp",
        kind = "value",
        unit = "A",
        dp = 0
    }, {
        label = "PT-1000 inv1",
        dref = "an-24/power/inv_PT1000_1",
        kind = "lamp"
    }, {
        label = "PT-750 inv",
        dref = "an-24/power/inv_PT750",
        kind = "lamp"
    }}
}, {
    name = "Fuel",
    short = "Fuel",
    fields = {{
        label = "Tank 1 qty",
        dref = "an-24/fuel/tank1_q_ind",
        kind = "bar",
        min = 0,
        max = 1500,
        unit = "kg"
    }, {
        label = "Tank 2 qty",
        dref = "an-24/fuel/tank2_q_ind",
        kind = "bar",
        min = 0,
        max = 1500,
        unit = "kg"
    }, {
        label = "Tank 3 qty",
        dref = "an-24/fuel/tank3_q_ind",
        kind = "bar",
        min = 0,
        max = 1500,
        unit = "kg"
    }, {
        label = "Tank 4 qty",
        dref = "an-24/fuel/tank4_q_ind",
        kind = "bar",
        min = 0,
        max = 1500,
        unit = "kg"
    }, {
        label = "Pump 1",
        dref = "an-24/fuel/tank1_pump",
        kind = "lamp"
    }, {
        label = "Pump 2",
        dref = "an-24/fuel/tank2_pump",
        kind = "lamp"
    }, {
        label = "Pump 3",
        dref = "an-24/fuel/tank3_pump",
        kind = "lamp"
    }, {
        label = "Pump 4",
        dref = "an-24/fuel/tank4_pump",
        kind = "lamp"
    }, {
        label = "Fire valve 1",
        dref = "an-24/fuel/fire_valve1",
        kind = "lamp"
    }, {
        label = "Fire valve 2",
        dref = "an-24/fuel/fire_valve2",
        kind = "lamp"
    }, {
        label = "Fire valve 3",
        dref = "an-24/fuel/fire_valve3",
        kind = "lamp"
    }, {
        label = "Shutoff 1",
        dref = "an-24/fuel/fuel_access1",
        kind = "lamp"
    }, {
        label = "Shutoff 2",
        dref = "an-24/fuel/fuel_access2",
        kind = "lamp"
    }, {
        label = "Cross-feed",
        dref = "an-24/fuel/fuel_circle_valve",
        kind = "lamp"
    }, {
        label = "Qty < 1000",
        dref = "an-24/fuel/quant_1000_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "L filter blk",
        dref = "an-24/fuel/left_filter_block_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "R filter blk",
        dref = "an-24/fuel/right_filter_block_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "L fuel press",
        dref = "an-24/fuel/left_fuel_press_lit",
        kind = "lamp"
    }, {
        label = "R fuel press",
        dref = "an-24/fuel/right_fuel_press_lit",
        kind = "lamp"
    }, {
        label = "L flow count",
        dref = "an-24/fuel/fuel_flow_left_count",
        kind = "value",
        unit = "",
        dp = 0
    }, {
        label = "R flow count",
        dref = "an-24/fuel/fuel_flow_right_count",
        kind = "value",
        unit = "",
        dp = 0
    }, {
        label = "L fuel flow",
        dref = "sim/flightmodel/engine/ENGN_FF_[0]",
        kind = "value",
        unit = "kg/s",
        dp = 3
    }, {
        label = "R fuel flow",
        dref = "sim/flightmodel/engine/ENGN_FF_[1]",
        kind = "value",
        unit = "kg/s",
        dp = 3
    }}
}, {
    name = "Hydraulic",
    short = "Hydr",
    fields = {{
        label = "Main press",
        dref = "an-24/hydro/main_press",
        kind = "gauge",
        min = 0,
        max = 210,
        unit = "kg",
        warn_lo = 120
    }, {
        label = "Emerg press",
        dref = "an-24/hydro/emerg_press",
        kind = "gauge",
        min = 0,
        max = 210,
        unit = "kg",
        warn_lo = 120
    }, {
        label = "Accumulator",
        dref = "an-24/hydro/hydro_store",
        kind = "gauge",
        min = 0,
        max = 210,
        unit = "kg"
    }, {
        label = "Fluid qty",
        dref = "an-24/hydro/hydro_quantity",
        kind = "bar",
        min = 0,
        max = 30,
        unit = "L",
        warn_lo = 18
    }, {
        label = "Brake press",
        dref = "an-24/hydro/brake_press",
        kind = "gauge",
        min = 0,
        max = 160,
        unit = "kg"
    }, {
        label = "Brake left",
        dref = "an-24/hydro/brake_left",
        kind = "bar",
        min = 0,
        max = 160,
        unit = "kg"
    }, {
        label = "Brake right",
        dref = "an-24/hydro/brake_right",
        kind = "bar",
        min = 0,
        max = 160,
        unit = "kg"
    }, {
        label = "Park brake",
        dref = "an-24/hydro/park_brake",
        kind = "lamp"
    }, {
        label = "Emerg brake",
        dref = "an-24/hydro/emerg_brake",
        kind = "lamp"
    }, {
        label = "Anti-skid",
        dref = "an-24/hydro/abs_sw",
        kind = "lamp"
    }, {
        label = "Emerg pump",
        dref = "an-24/hydro/emerg_pump_sw",
        kind = "lamp"
    }, {
        label = "Gear valve",
        dref = "an-24/hydro/gear_valve",
        kind = "enum",
        map = {
            [0] = "NEUT",
            [1] = "DN",
            [2] = "UP"
        }
    }, {
        label = "Flaps valve",
        dref = "an-24/hydro/flaps_valve",
        kind = "enum",
        map = {
            [0] = "NEUT",
            [1] = "DN",
            [2] = "UP"
        }
    }, {
        label = "Gear indicator",
        dref = "an-24/hydro/gear_rotary",
        kind = "value",
        unit = ""
    }, {
        label = "Flap indicator",
        dref = "an-24/hydro/flaps_rotary",
        kind = "value",
        unit = ""
    }}
}, {
    name = "Engines",
    short = "Eng",
    fields = {{
        label = "N1 left",
        dref = "sim/flightmodel/engine/ENGN_N1_[0]",
        kind = "gauge",
        min = 0,
        max = 110,
        unit = "%",
        warn_hi = 101
    }, {
        label = "N1 right",
        dref = "sim/flightmodel/engine/ENGN_N1_[1]",
        kind = "gauge",
        min = 0,
        max = 110,
        unit = "%",
        warn_hi = 101
    }, {
        label = "N2 left",
        dref = "sim/flightmodel/engine/ENGN_N2_[0]",
        kind = "gauge",
        min = 0,
        max = 110,
        unit = "%"
    }, {
        label = "N2 right",
        dref = "sim/flightmodel/engine/ENGN_N2_[1]",
        kind = "gauge",
        min = 0,
        max = 110,
        unit = "%"
    }, {
        label = "Torque L",
        dref = "an-24/gauges/torque_left",
        kind = "gauge",
        min = 0,
        max = 100,
        unit = "%"
    }, {
        label = "Torque R",
        dref = "an-24/gauges/torque_right",
        kind = "gauge",
        min = 0,
        max = 100,
        unit = "%"
    }, {
        label = "Oil temp L",
        dref = "sim/cockpit2/engine/indicators/oil_temperature_deg_C[0]",
        kind = "gauge",
        min = -20,
        max = 120,
        unit = "C",
        warn_hi = 90
    }, {
        label = "Oil temp R",
        dref = "sim/cockpit2/engine/indicators/oil_temperature_deg_C[1]",
        kind = "gauge",
        min = -20,
        max = 120,
        unit = "C",
        warn_hi = 90
    }, {
        label = "Oil press L",
        dref = "sim/cockpit2/engine/indicators/oil_pressure_psi[0]",
        kind = "gauge",
        min = 0,
        max = 100,
        unit = "psi"
    }, {
        label = "Oil press R",
        dref = "sim/cockpit2/engine/indicators/oil_pressure_psi[1]",
        kind = "gauge",
        min = 0,
        max = 100,
        unit = "psi"
    }, {
        label = "Fuel press L",
        dref = "sim/cockpit2/engine/indicators/fuel_pressure_psi[0]",
        kind = "gauge",
        min = 0,
        max = 100,
        unit = "psi"
    }, {
        label = "Fuel press R",
        dref = "sim/cockpit2/engine/indicators/fuel_pressure_psi[1]",
        kind = "gauge",
        min = 0,
        max = 100,
        unit = "psi"
    }, {
        label = "Virt RUD 1",
        dref = "an-24/misc/virt_rud1",
        kind = "value",
        dp = 2
    }, {
        label = "Virt RUD 2",
        dref = "an-24/misc/virt_rud2",
        kind = "value",
        dp = 2
    }, {
        label = "Burning L",
        dref = "sim/flightmodel2/engines/engine_is_burning_fuel[0]",
        kind = "lamp"
    }, {
        label = "Burning R",
        dref = "sim/flightmodel2/engines/engine_is_burning_fuel[1]",
        kind = "lamp"
    }, {
        label = "Cowl flap L",
        dref = "sim/cockpit2/engine/actuators/cowl_flap_ratio[0]",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "Cowl flap R",
        dref = "sim/cockpit2/engine/actuators/cowl_flap_ratio[1]",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }}
}, {
    name = "Propellers",
    short = "Prop",
    fields = {{
        label = "Pitch left",
        dref = "sim/cockpit2/engine/actuators/prop_pitch_deg[0]",
        kind = "gauge",
        min = 0,
        max = 90,
        unit = "deg"
    }, {
        label = "Pitch right",
        dref = "sim/cockpit2/engine/actuators/prop_pitch_deg[1]",
        kind = "gauge",
        min = 0,
        max = 90,
        unit = "deg"
    }, {
        label = "Prop mode L",
        dref = "sim/flightmodel/engine/ENGN_propmode[0]",
        kind = "enum",
        map = {
            [0] = "FEATH",
            [1] = "NORM",
            [2] = "BETA",
            [3] = "REV"
        }
    }, {
        label = "Prop mode R",
        dref = "sim/flightmodel/engine/ENGN_propmode[1]",
        kind = "enum",
        map = {
            [0] = "FEATH",
            [1] = "NORM",
            [2] = "BETA",
            [3] = "REV"
        }
    }, {
        label = "Feather 1 btn",
        dref = "an-24/prop/feather1_button",
        kind = "lamp"
    }, {
        label = "Feather 2 btn",
        dref = "an-24/prop/feather2_button",
        kind = "lamp"
    }, {
        label = "Eng fail L",
        dref = "an-24/prop/feather1_lamp",
        kind = "lamp",
        fault = true
    }, {
        label = "Eng fail R",
        dref = "an-24/prop/feather2_lamp",
        kind = "lamp",
        fault = true
    }, {
        label = "Pitch stop",
        dref = "an-24/prop/pitch_stop",
        kind = "lamp"
    }, {
        label = "Pitch stop cap",
        dref = "an-24/prop/pitch_stop_cap",
        kind = "lamp"
    }, {
        label = "Park position",
        dref = "an-24/set/park_position",
        kind = "enum",
        map = {
            [0] = "X",
            [1] = "+"
        }
    }}
}, {
    name = "Fire",
    short = "Fire",
    fields = {{
        label = "L engine fire",
        dref = "an-24/fire/fire_left_eng_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "R engine fire",
        dref = "an-24/fire/fire_right_eng_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "RU-19 fire",
        dref = "an-24/fire/fire_ru19_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "L nacelle",
        dref = "an-24/fire/fire_left_nacelle_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "R nacelle",
        dref = "an-24/fire/fire_right_nacelle_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "L wing fire",
        dref = "an-24/fire/fire_left_wing_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "R wing fire",
        dref = "an-24/fire/fire_right_wing_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "Fire warning",
        dref = "an-24/fire/fire_warinig",
        kind = "lamp",
        fault = true
    }, {
        label = "Main switch",
        dref = "an-24/fire/fire_main_switcher",
        kind = "lamp"
    }, {
        label = "Ext L ready",
        dref = "an-24/fire/ext_left_ready_lit",
        kind = "lamp"
    }, {
        label = "Ext R ready",
        dref = "an-24/fire/ext_right_ready_lit",
        kind = "lamp"
    }, {
        label = "Bottle 1 ready",
        dref = "an-24/fire/ext_first_ready_lit",
        kind = "lamp"
    }, {
        label = "Bottle 2 ready",
        dref = "an-24/fire/ext_second_ready_lit",
        kind = "lamp"
    }, {
        label = "Sim fire L",
        dref = "sim/operation/failures/rel_engfir0",
        kind = "fail"
    }, {
        label = "Sim fire R",
        dref = "sim/operation/failures/rel_engfir1",
        kind = "fail"
    }}
}, {
    name = "Anti-Ice",
    short = "Ice",
    fields = {{
        label = "Pitot 1 sw",
        dref = "an-24/ice/pitot1_sw",
        kind = "lamp"
    }, {
        label = "Pitot 1 heat",
        dref = "an-24/ice/pitot1_lit",
        kind = "lamp"
    }, {
        label = "Pitot 2 sw",
        dref = "an-24/ice/pitot2_sw",
        kind = "lamp"
    }, {
        label = "Pitot 2 heat",
        dref = "an-24/ice/pitot2_lit",
        kind = "lamp"
    }, {
        label = "Engine sw",
        dref = "an-24/ice/engine_ht_sw",
        kind = "lamp"
    }, {
        label = "Engine heat",
        dref = "an-24/ice/engine_heat_lit",
        kind = "lamp"
    }, {
        label = "Prop sw",
        dref = "an-24/ice/prop_ht_sw",
        kind = "lamp"
    }, {
        label = "Prop L heat",
        dref = "an-24/ice/prop_left_lit",
        kind = "lamp"
    }, {
        label = "Prop R heat",
        dref = "an-24/ice/prop_right_lit",
        kind = "lamp"
    }, {
        label = "Wing sw",
        dref = "an-24/ice/wing_ht_sw",
        kind = "lamp"
    }, {
        label = "Wing heat",
        dref = "an-24/ice/wing_heat_lit",
        kind = "lamp"
    }, {
        label = "Windshld sw",
        dref = "an-24/ice/rio_sw",
        kind = "lamp"
    }, {
        label = "Windshld heat",
        dref = "an-24/ice/rio_heat_lit",
        kind = "lamp"
    }, {
        label = "AOA sw",
        dref = "an-24/ice/aoa_ht_sw",
        kind = "lamp"
    }, {
        label = "AOA heat",
        dref = "an-24/ice/aoa_heat_lit",
        kind = "lamp"
    }, {
        label = "Ice det L",
        dref = "an-24/ice/ice_left_eng_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "Ice det R",
        dref = "an-24/ice/ice_right_eng_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "Thermometer",
        dref = "an-24/ice/thermo_angle",
        kind = "value",
        dp = 0
    }}
}, {
    name = "Start / APU",
    short = "Start",
    fields = {{
        label = "Start button",
        dref = "an-24/start/eng_start_btn",
        kind = "lamp"
    }, {
        label = "Stop button",
        dref = "an-24/start/eng_start_stop",
        kind = "lamp"
    }, {
        label = "Ground/air",
        dref = "an-24/start/start_at_ground",
        kind = "enum",
        map = {
            [0] = "AIR",
            [1] = "GND"
        }
    }, {
        label = "Eng select",
        dref = "an-24/start/sel_left_right",
        kind = "enum",
        map = {
            [-1] = "LEFT",
            [0] = "NONE",
            [1] = "RIGHT"
        }
    }, {
        label = "Start mode",
        dref = "an-24/start/eng_start_mode",
        kind = "enum",
        map = {
            [0] = "ROTATE",
            [1] = "START"
        }
    }, {
        label = "APD work",
        dref = "an-24/start/apd_work_lit",
        kind = "lamp"
    }, {
        label = "PT-29 work",
        dref = "an-24/start/pt29_work_lit",
        kind = "lamp"
    }, {
        label = "RU-19 strip",
        dref = "an-24/start/strip_lit",
        kind = "lamp"
    }, {
        label = "Starter volt",
        dref = "an-24/start/starter_volt",
        kind = "gauge",
        min = 0,
        max = 32,
        unit = "V"
    }, {
        label = "Starter amp",
        dref = "an-24/start/starter_amp",
        kind = "bar",
        min = 0,
        max = 2000,
        unit = "A"
    }, {
        label = "RU-19 N1",
        dref = "an-24/start/ru19_N1",
        kind = "gauge",
        min = 0,
        max = 110,
        unit = "%"
    }, {
        label = "Fuel start 1",
        dref = "an-24/start/fuel_start1",
        kind = "lamp"
    }, {
        label = "Fuel start 2",
        dref = "an-24/start/fuel_start2",
        kind = "lamp"
    }, {
        label = "Fuel start 3",
        dref = "an-24/start/fuel_start3",
        kind = "lamp"
    }, {
        label = "STG1 starter",
        dref = "an-24/power/stg1_starter",
        kind = "lamp"
    }, {
        label = "STG2 starter",
        dref = "an-24/power/stg2_starter",
        kind = "lamp"
    }, {
        label = "GS24 starter",
        dref = "an-24/power/gs24_starter",
        kind = "lamp"
    }, {
        label = "RU-19 main sw",
        dref = "an-24/start/ru19_start_main_sw",
        kind = "lamp"
    }}
}, {
    name = "Gear / Brakes",
    short = "Gear",
    fields = {{
        label = "Gear down",
        dref = "an-24/gauges/gear_down",
        kind = "lamp"
    }, {
        label = "Nose door",
        dref = "an-24/gear/door_ratio_0",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "L main door",
        dref = "an-24/gear/door_ratio_1",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "R main door",
        dref = "an-24/gear/door_ratio_2",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "Gear valve",
        dref = "an-24/hydro/gear_valve",
        kind = "enum",
        map = {
            [0] = "NEUT",
            [1] = "DN",
            [2] = "UP"
        }
    }, {
        label = "Gear unblock",
        dref = "an-24/hydro/gear_unblock",
        kind = "lamp"
    }, {
        label = "Nosewheel ang",
        dref = "an-24/gauges/noseweel",
        kind = "value",
        unit = "deg",
        dp = 0
    }, {
        label = "Nosewheel mode",
        dref = "an-24/gauges/nosewheel_mode_lamp",
        kind = "lamp"
    }, {
        label = "Nosewheel rdy",
        dref = "an-24/gauges/nosewheel_mode_ready",
        kind = "lamp"
    }, {
        label = "Brake left",
        dref = "an-24/hydro/brake_left",
        kind = "gauge",
        min = 0,
        max = 160,
        unit = "kg"
    }, {
        label = "Brake right",
        dref = "an-24/hydro/brake_right",
        kind = "gauge",
        min = 0,
        max = 160,
        unit = "kg"
    }, {
        label = "Park brake",
        dref = "an-24/hydro/park_brake",
        kind = "lamp"
    }, {
        label = "Anti-skid",
        dref = "an-24/hydro/abs_sw",
        kind = "lamp"
    }, {
        label = "Gear siren",
        dref = "an-24/gauges/gear_siren",
        kind = "lamp",
        fault = true
    }, {
        label = "Flaps siren",
        dref = "an-24/gauges/flaps_siren",
        kind = "lamp",
        fault = true
    }}
}, {
    name = "Navigation",
    short = "Nav",
    fields = {{
        label = "ADF-1 freq",
        dref = "sim/cockpit2/radios/actuators/adf1_frequency_hz",
        kind = "value",
        unit = "kHz"
    }, {
        label = "ADF-1 bearing",
        dref = "sim/cockpit2/radios/indicators/adf1_relative_bearing_deg",
        kind = "gauge",
        min = 0,
        max = 360,
        unit = "deg"
    }, {
        label = "ADF-1 signal",
        dref = "an-24/ark/ark1_signal",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "ADF-1 mode",
        dref = "an-24/ark/ark1_mode",
        kind = "enum",
        map = {
            [0] = "OFF",
            [1] = "ANT",
            [2] = "ADF",
            [3] = "LOOP"
        }
    }, {
        label = "ADF-2 freq",
        dref = "sim/cockpit2/radios/actuators/adf2_frequency_hz",
        kind = "value",
        unit = "kHz"
    }, {
        label = "ADF-2 bearing",
        dref = "sim/cockpit2/radios/indicators/adf2_relative_bearing_deg",
        kind = "gauge",
        min = 0,
        max = 360,
        unit = "deg"
    }, {
        label = "ADF-2 signal",
        dref = "an-24/ark/ark2_signal",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "NAV-1 freq",
        dref = "sim/cockpit2/radios/actuators/nav1_frequency_hz",
        kind = "value",
        unit = ""
    }, {
        label = "NAV-1 LOC",
        dref = "sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot",
        kind = "bar",
        min = -2.5,
        max = 2.5,
        unit = "dot"
    }, {
        label = "NAV-1 G/S",
        dref = "sim/cockpit2/radios/indicators/nav1_vdef_dots_pilot",
        kind = "bar",
        min = -2.5,
        max = 2.5,
        unit = "dot"
    }, {
        label = "NAV-2 freq",
        dref = "sim/cockpit2/radios/actuators/nav2_frequency_hz",
        kind = "value",
        unit = ""
    }, {
        label = "NAV-2 LOC",
        dref = "sim/cockpit2/radios/indicators/nav2_hdef_dots_pilot",
        kind = "bar",
        min = -2.5,
        max = 2.5,
        unit = "dot"
    }, {
        label = "DME dist",
        dref = "sim/cockpit2/radios/indicators/nav2_dme_distance_nm",
        kind = "value",
        unit = "nm",
        dp = 1
    }, {
        label = "GIK heading",
        dref = "an-24/gauges/GIK_curse",
        kind = "gauge",
        min = 0,
        max = 360,
        unit = "deg"
    }, {
        label = "GIK switch",
        dref = "an-24/gauges/GIK_sw",
        kind = "lamp"
    }, {
        label = "GPK heading",
        dref = "an-24/gauges/GPK_curse",
        kind = "gauge",
        min = 0,
        max = 360,
        unit = "deg"
    }, {
        label = "GPK switch",
        dref = "an-24/gauges/GPK_sw",
        kind = "lamp"
    }, {
        label = "RSBN power",
        dref = "an-24/rsbn_power_sw",
        kind = "lamp"
    }, {
        label = "RSBN channel",
        dref = "an-24/rsbn/channel",
        kind = "value",
        unit = ""
    }, {
        label = "RSBN dev",
        dref = "an-24/rsbn/defl",
        kind = "bar",
        min = -3,
        max = 3,
        unit = ""
    }, {
        label = "RSBN valid",
        dref = "an-24/rsbn/flag",
        kind = "lamp"
    }, {
        label = "Radio alt",
        dref = "an-24/gauges/radioalt",
        kind = "value",
        unit = "m",
        dp = 0
    }, {
        label = "NAS-1 wind sp",
        dref = "an-24/nas1/windspeed",
        kind = "value",
        unit = "",
        dp = 0
    }, {
        label = "NAS-1 wind dir",
        dref = "an-24/nas1/windangle",
        kind = "value",
        unit = "deg",
        dp = 0
    }}
}, -- GPS / KLN90B diagnostics. Mirrors the three data sources gps_nav_logic.lua
-- tries in priority order, so you can see which one is (or isn't) feeding
-- an-24/ap/gps_valid: (1) standard gps_*, (2) NAV1 fallback (KLN NAVSYNC=ON),
-- (3) direct waypoint calc. Plus the KLN handshake/override state on top.
{
    name = "GPS / KLN90B",
    short = "GPS",
    fields = { -- Which unit is primary + override state (KLN sets override_gps when primary)
    {
        label = "KLN primary",
        dref = "an-24/set/kln90b_pri",
        kind = "lamp"
    }, {
        label = "GNS430 primary",
        dref = "an-24/set/gns430_pri",
        kind = "lamp"
    }, {
        label = "KLN init",
        dref = "an-24/set/kln_init",
        kind = "lamp"
    }, {
        label = "KLN power",
        dref = "custom/KLN90/kln_power",
        kind = "lamp"
    }, {
        label = "KLN state",
        dref = "custom/KLN90/kln_state",
        kind = "value",
        dp = 0
    }, {
        label = "Override GPS",
        dref = "sim/operation/override/override_gps",
        kind = "lamp"
    }, {
        label = "Override NAV1",
        dref = "sim/operation/override/override_nav1_needles",
        kind = "lamp"
    }, -- Source 1: standard GPS channel (gps_*). With the KLN, gps_bearing/power stay
    -- 0 (it writes course/dir instead), so this branch never validates — see course/rel.
    {
        label = "GPS power",
        dref = "sim/cockpit2/radios/actuators/gps_power",
        kind = "lamp"
    }, {
        label = "GPS from/to",
        dref = "sim/cockpit/radios/gps_fromto",
        kind = "enum",
        map = {
            [0] = "NONE",
            [1] = "TO",
            [2] = "FROM"
        }
    }, {
        label = "GPS bearing",
        dref = "sim/cockpit2/radios/indicators/gps_bearing_deg_mag",
        kind = "value",
        unit = "deg",
        dp = 0
    }, {
        label = "GPS course",
        dref = "sim/cockpit/radios/gps_course_degtm",
        kind = "value",
        unit = "deg",
        dp = 0
    }, {
        label = "GPS rel bear",
        dref = "sim/cockpit/radios/gps_dir_degt",
        kind = "value",
        unit = "deg",
        dp = 0
    }, {
        label = "GPS hdef dots",
        dref = "sim/cockpit2/radios/indicators/gps_hdef_dots_pilot",
        kind = "bar",
        min = -2.5,
        max = 2.5,
        unit = "dot"
    }, {
        label = "GPS hdef raw",
        dref = "sim/cockpit/radios/gps_hdef_dot",
        kind = "bar",
        min = -2.5,
        max = 2.5,
        unit = "dot"
    }, {
        label = "GPS nm/dot",
        dref = "sim/cockpit/radios/gps_hdef_nm_per_dot",
        kind = "value",
        unit = "nm",
        dp = 2
    }, {
        label = "GPS XTK",
        dref = "sim/cockpit2/radios/indicators/gps_xtk",
        kind = "value",
        unit = "nm",
        dp = 2
    }, {
        label = "GPS DME",
        dref = "sim/cockpit2/radios/indicators/gps_dme_distance_nm",
        kind = "value",
        unit = "nm",
        dp = 1
    }, -- Source 2: NAV1 fallback. The KLN only writes these with NAVSYNC=ON, so
    -- nav1_fromto != 0 here is what flips gps_valid for the KLN.
    {
        label = "NAV1 from/to",
        dref = "sim/cockpit/radios/nav1_fromto",
        kind = "enum",
        map = {
            [0] = "NONE",
            [1] = "TO",
            [2] = "FROM"
        }
    }, {
        label = "NAV1 bearing",
        dref = "sim/cockpit2/radios/indicators/nav_bearing_deg_mag[0]",
        kind = "value",
        unit = "deg",
        dp = 0
    }, {
        label = "NAV1 hdef dots",
        dref = "sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot",
        kind = "bar",
        min = -2.5,
        max = 2.5,
        unit = "dot"
    }, {
        label = "NAV1 OBS",
        dref = "sim/cockpit/radios/nav1_obs_degm",
        kind = "value",
        unit = "deg",
        dp = 0
    }, {
        label = "NAV1 DME",
        dref = "sim/cockpit/radios/nav1_dme_dist_m",
        kind = "value",
        unit = "nm",
        dp = 1
    }, -- An-24 GPS-nav outputs (written by gps_nav_logic.lua; consumed by ap28_logic)
    {
        label = "GPS valid",
        dref = "an-24/ap/gps_valid",
        kind = "lamp"
    }, {
        label = "GPS mode on",
        dref = "an-24/ap/gps_mode_on",
        kind = "lamp"
    }, {
        label = "GPS course out",
        dref = "an-24/ap/curse_gps",
        kind = "value",
        unit = "deg",
        dp = 1
    }, {
        label = "XTK correction",
        dref = "an-24/ap/gps_xtk_correction",
        kind = "value",
        unit = "deg",
        dp = 1
    }, {
        label = "AP course mode",
        dref = "an-24/ap/ap_curse_stab",
        kind = "enum",
        map = {
            [0] = "OFF",
            [1] = "HDG",
            [2] = "GPK",
            [3] = "GPS"
        }
    }}
}, {
    name = "Autopilot",
    short = "AP",
    fields = {{
        label = "AP master",
        dref = "an-24/ap/ap_ON",
        kind = "lamp"
    }, {
        label = "AP power",
        dref = "an-24/ap/ap_power",
        kind = "lamp"
    }, {
        label = "Course mode",
        dref = "an-24/ap/ap_curse_stab",
        kind = "enum",
        map = {
            [0] = "OFF",
            [1] = "HDG",
            [2] = "GPK",
            [3] = "GPS"
        }
    }, {
        label = "Pitch cmd",
        dref = "an-24/ap/ap_pitch_comm",
        kind = "value",
        dp = 2
    }, {
        label = "Pitch error",
        dref = "an-24/ap/ap_pitch_diff",
        kind = "value",
        dp = 2
    }, {
        label = "Roll cmd",
        dref = "an-24/ap/ap_roll_comm",
        kind = "value",
        dp = 2
    }, {
        label = "Roll error",
        dref = "an-24/ap/ap_roll_diff",
        kind = "value",
        dp = 2
    }, {
        label = "Yaw cmd",
        dref = "an-24/ap/ap_yaw_comm",
        kind = "value",
        dp = 2
    }, {
        label = "Hdg error",
        dref = "an-24/ap/ap_hdg_diff",
        kind = "value",
        dp = 2
    }, {
        label = "AP trim",
        dref = "an-24/ap/ap_trim",
        kind = "value",
        dp = 2
    }, {
        label = "On lamp",
        dref = "an-24/ap/ap_on_lit",
        kind = "lamp"
    }, {
        label = "Ready lamp",
        dref = "an-24/ap/ap_ready_lit",
        kind = "lamp"
    }, {
        label = "Pitch up",
        dref = "an-24/ap/ap_up_lit",
        kind = "lamp"
    }, {
        label = "Pitch down",
        dref = "an-24/ap/ap_down_lit",
        kind = "lamp"
    }, {
        label = "Ail fail",
        dref = "an-24/ap/ap_ail_fail_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "Elev fail",
        dref = "an-24/ap/ap_elev_fail_lit",
        kind = "lamp",
        fault = true
    }, {
        label = "GPS mode",
        dref = "an-24/ap/gps_mode_on",
        kind = "lamp"
    }, {
        label = "GPS valid",
        dref = "an-24/ap/gps_valid",
        kind = "lamp"
    }, {
        label = "GPS course",
        dref = "an-24/ap/curse_gps",
        kind = "value",
        unit = "deg",
        dp = 0
    }, {
        label = "Ind. pitch",
        dref = "an-24/ap/indicated_pitch",
        kind = "value",
        unit = "deg",
        dp = 1
    }, {
        label = "Ind. roll",
        dref = "an-24/ap/indicated_roll",
        kind = "value",
        unit = "deg",
        dp = 1
    }, {
        label = "AP load",
        dref = "an-24/ap/ap_power_cc",
        kind = "value",
        unit = "A",
        dp = 1
    }}
}, {
    name = "Lighting",
    short = "Light",
    fields = {{
        label = "Nav lights",
        dref = "an-24/misc/nav_light_sw",
        kind = "lamp"
    }, {
        label = "Beacon",
        dref = "an-24/misc/beacon_light",
        kind = "lamp"
    }, {
        label = "Landing sw",
        dref = "an-24/misc/lan_light_sw",
        kind = "lamp"
    }, {
        label = "Landing ext",
        dref = "an-24/misc/lan_light_open_sw",
        kind = "lamp"
    }, {
        label = "Cabin light",
        dref = "an-24/switch/main_cabin_light",
        kind = "lamp"
    }, {
        label = "Cabin mode",
        dref = "an-24/switch/main_cabin_light_mode",
        kind = "enum",
        map = {
            [0] = "OFF",
            [1] = "DIM",
            [2] = "BRIGHT"
        }
    }, {
        label = "Cockpit red",
        dref = "an-24/misc/cockpit_red",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "Spot 1",
        dref = "an-24/misc/cockpit_spot1",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "Spot 2",
        dref = "an-24/misc/cockpit_spot2",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "Panel bright",
        dref = "an-24/misc/cockpit_panel",
        kind = "value",
        dp = 0
    }, {
        label = "Overhead L",
        dref = "an-24/lights/overhead_lamp_left_mode",
        kind = "enum",
        map = {
            [0] = "OFF",
            [1] = "RED",
            [2] = "WHITE"
        }
    }, {
        label = "Overhead R",
        dref = "an-24/lights/overhead_lamp_right_mode",
        kind = "enum",
        map = {
            [0] = "OFF",
            [1] = "RED",
            [2] = "WHITE"
        }
    }, {
        label = "Nav L mode",
        dref = "an-24/lights/overhead_lamp_nav_left_mode",
        kind = "enum",
        map = {
            [0] = "OFF",
            [1] = "RED",
            [2] = "WHITE"
        }
    }, {
        label = "Nav R mode",
        dref = "an-24/lights/overhead_lamp_nav_right_mode",
        kind = "enum",
        map = {
            [0] = "OFF",
            [1] = "RED",
            [2] = "WHITE"
        }
    }, {
        label = "No smoking",
        dref = "an-24/nosmokingswitchonoff",
        kind = "lamp"
    }}
}, {
    name = "Pneumatic",
    short = "Pneu",
    fields = {{
        label = "Bleed 1",
        dref = "an-24/skv/bleed1_sw",
        kind = "lamp"
    }, {
        label = "Bleed 2",
        dref = "an-24/skv/bleed2_sw",
        kind = "lamp"
    }, {
        label = "Dump switch",
        dref = "an-24/skv/dump_sw",
        kind = "lamp"
    }, {
        label = "Dump cap",
        dref = "an-24/skv/dump_cap",
        kind = "lamp"
    }, {
        label = "SKV siren",
        dref = "an-24/skv/skv_siren",
        kind = "lamp",
        fault = true
    }, {
        label = "Siren alarm",
        dref = "an-24/skv/skv_siren_alarm",
        kind = "lamp",
        fault = true
    }, {
        label = "Cabin alt",
        dref = "sim/cockpit2/pressurization/indicators/cabin_altitude_ft",
        kind = "value",
        unit = "ft",
        dp = 0
    }, {
        label = "Cabin VS",
        dref = "sim/cockpit2/pressurization/indicators/cabin_vvi_fpm",
        kind = "value",
        unit = "fpm",
        dp = 0
    }, {
        label = "Diff press",
        dref = "sim/cockpit2/pressurization/indicators/pressure_diffential_psi",
        kind = "gauge",
        min = 0,
        max = 8,
        unit = "psi",
        warn_hi = 6
    }}
}, {
    name = "Comms",
    short = "Comm",
    fields = {{
        label = "COM-1 freq",
        dref = "sim/cockpit2/radios/actuators/com1_frequency_hz",
        kind = "value",
        unit = ""
    }, {
        label = "COM-2 freq",
        dref = "sim/cockpit2/radios/actuators/com2_frequency_hz",
        kind = "value",
        unit = ""
    }, {
        label = "NAV-1 freq",
        dref = "sim/cockpit2/radios/actuators/nav1_frequency_hz",
        kind = "value",
        unit = ""
    }, {
        label = "NAV-2 freq",
        dref = "sim/cockpit2/radios/actuators/nav2_frequency_hz",
        kind = "value",
        unit = ""
    }, {
        label = "ADF-1 freq",
        dref = "sim/cockpit2/radios/actuators/adf1_frequency_hz",
        kind = "value",
        unit = "kHz"
    }, {
        label = "ADF-2 freq",
        dref = "sim/cockpit2/radios/actuators/adf2_frequency_hz",
        kind = "value",
        unit = "kHz"
    }, {
        label = "XPDR power",
        dref = "an-24/sq/sq_sw",
        kind = "lamp"
    }, {
        label = "XPDR mode",
        dref = "an-24/sq/sq_mode",
        kind = "enum",
        map = {
            [0] = "OFF",
            [1] = "STBY",
            [2] = "ON",
            [3] = "ALT"
        }
    }, {
        label = "Squawk 1",
        dref = "an-24/sq/digit_1",
        kind = "value",
        dp = 0
    }, {
        label = "Squawk 2",
        dref = "an-24/sq/digit_2",
        kind = "value",
        dp = 0
    }, {
        label = "Squawk 3",
        dref = "an-24/sq/digit_3",
        kind = "value",
        dp = 0
    }, {
        label = "Squawk 4",
        dref = "an-24/sq/digit_4",
        kind = "value",
        dp = 0
    }, {
        label = "SPU power",
        dref = "an-24/gauges/spu_power_sw",
        kind = "lamp"
    }, {
        label = "SPU mode",
        dref = "an-24/gauges/spu_mode",
        kind = "value",
        dp = 0
    }, {
        label = "Radar power",
        dref = "an-24/rls/rls_power_sw",
        kind = "lamp"
    }, {
        label = "Radar mode",
        dref = "an-24/rls/rls_mode",
        kind = "value",
        dp = 0
    }, {
        label = "Radar bright",
        dref = "an-24/rls/rls_bright",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "Radar scan",
        dref = "an-24/rls/rls_scan_spd",
        kind = "value",
        dp = 0
    }}
}, {
    name = "Controls",
    short = "Ctrl",
    fields = {{
        label = "Elevator trim",
        dref = "sim/cockpit2/controls/elevator_trim",
        kind = "gauge",
        min = -1,
        max = 1,
        unit = ""
    }, {
        label = "Aileron trim",
        dref = "sim/cockpit2/controls/aileron_trim",
        kind = "gauge",
        min = -1,
        max = 1,
        unit = ""
    }, {
        label = "Rudder trim",
        dref = "sim/cockpit2/controls/rudder_trim",
        kind = "gauge",
        min = -1,
        max = 1,
        unit = ""
    }, {
        label = "Flap ratio",
        dref = "sim/cockpit2/controls/flap_ratio",
        kind = "bar",
        min = 0,
        max = 1,
        unit = ""
    }, {
        label = "Yoke pitch",
        dref = "sim/cockpit2/controls/yoke_pitch_ratio",
        kind = "gauge",
        min = -1,
        max = 1,
        unit = ""
    }, {
        label = "Yoke roll",
        dref = "sim/cockpit2/controls/yoke_roll_ratio",
        kind = "gauge",
        min = -1,
        max = 1,
        unit = ""
    }, {
        label = "Yoke yaw",
        dref = "sim/cockpit2/controls/yoke_heading_ratio",
        kind = "gauge",
        min = -1,
        max = 1,
        unit = ""
    }, {
        label = "Ail trim sw",
        dref = "an-24/trimm/ail_sw",
        kind = "value",
        dp = 0
    }, {
        label = "Rud trim sw",
        dref = "an-24/trimm/rudd_sw",
        kind = "value",
        dp = 0
    }}
}, {
    name = "Failures",
    short = "Fail",
    fields = {{
        label = "Eng fire 1",
        dref = "sim/operation/failures/rel_engfir0",
        kind = "fail"
    }, {
        label = "Eng fire 2",
        dref = "sim/operation/failures/rel_engfir1",
        kind = "fail"
    }, {
        label = "Eng fire 3",
        dref = "sim/operation/failures/rel_engfir2",
        kind = "fail"
    }, {
        label = "Eng sep 1",
        dref = "sim/operation/failures/rel_engsep0",
        kind = "fail"
    }, {
        label = "Eng sep 2",
        dref = "sim/operation/failures/rel_engsep1",
        kind = "fail"
    }, {
        label = "Eng sep 3",
        dref = "sim/operation/failures/rel_engsep2",
        kind = "fail"
    }, {
        label = "Generator 1",
        dref = "sim/operation/failures/rel_genera0",
        kind = "fail"
    }, {
        label = "Generator 2",
        dref = "sim/operation/failures/rel_genera1",
        kind = "fail"
    }, {
        label = "Generator 3",
        dref = "sim/operation/failures/rel_genera2",
        kind = "fail"
    }, {
        label = "Nose gear",
        dref = "sim/operation/failures/rel_lagear1",
        kind = "fail"
    }, {
        label = "L main gear",
        dref = "sim/operation/failures/rel_lagear2",
        kind = "fail"
    }, {
        label = "R main gear",
        dref = "sim/operation/failures/rel_lagear3",
        kind = "fail"
    }, {
        label = "L tire",
        dref = "sim/operation/failures/rel_tire2",
        kind = "fail"
    }, {
        label = "R tire",
        dref = "sim/operation/failures/rel_tire3",
        kind = "fail"
    }, {
        label = "L brakes",
        dref = "sim/operation/failures/rel_lbrakes",
        kind = "fail"
    }, {
        label = "R brakes",
        dref = "sim/operation/failures/rel_rbrakes",
        kind = "fail"
    }, {
        label = "Pitot 1",
        dref = "sim/operation/failures/rel_pitot",
        kind = "fail"
    }, {
        label = "Pitot 2",
        dref = "sim/operation/failures/rel_pitot2",
        kind = "fail"
    }, {
        label = "Cockpit smoke",
        dref = "sim/operation/failures/rel_smoke_cpit",
        kind = "fail"
    }, {
        label = "H stab L",
        dref = "sim/operation/failures/rel_hstbL",
        kind = "fail"
    }, {
        label = "H stab R",
        dref = "sim/operation/failures/rel_hstbR",
        kind = "fail"
    }, {
        label = "V stab 1",
        dref = "sim/operation/failures/rel_vstb1",
        kind = "fail"
    }, {
        label = "V stab 2",
        dref = "sim/operation/failures/rel_vstb2",
        kind = "fail"
    }}
}}

-- ---------------------------------------------------------------------------
-- Decoupled dataref read cache (memoised handles, like texSize in glbl_draw)
-- ---------------------------------------------------------------------------
local handles = {}
local function H(name)
    local h = handles[name]
    if not h then
        h = globalProperty(name);
        handles[name] = h
    end
    return h
end
local function readv(name)
    local ok, v = pcall(get, H(name))
    if ok and type(v) == "number" then
        return v
    end
    return 0
end

-- ---------------------------------------------------------------------------
-- Geometry (fixed canvas; window scales it proportionally)
-- ---------------------------------------------------------------------------
local W, Hh = size[1], size[2]
local TAB_H = 30
local HEADER_H = 28
local PAD = 10
local CARD_W = 219
local CARD_H = 74
local CARD_GAP = 8
local COL_STRIDE = CARD_W + CARD_GAP -- 227
local ROW_STRIDE = CARD_H + CARD_GAP -- 82
-- tab bar wraps to as many rows as needed to keep each tab >= MIN_TAB_W wide
local N_TABS = #schema
local MIN_TAB_W = 84
local TAB_ROWS = math.max(1, math.ceil(N_TABS / math.floor(W / MIN_TAB_W)))
local TAB_PER_ROW = math.ceil(N_TABS / TAB_ROWS)
local TAB_W = W / TAB_PER_ROW
local TAB_AREA_H = TAB_ROWS * TAB_H
local CONTENT_L = PAD -- 10
local CONTENT_T = Hh - TAB_AREA_H - HEADER_H -- top y, below the tab rows
local CONTENT_B = PAD -- 10
local CONTENT_W = W - 2 * PAD -- 900
local CONTENT_H = CONTENT_T - CONTENT_B -- 492
local COLS = 4
local VIS_ROWS = math.floor((CONTENT_H + CARD_GAP) / ROW_STRIDE) -- 6

-- shared UI state (upvalues; read/written by clickables, update(), draw())
local current_tab = 1
local scroll_row = 0
local max_scroll = 0

local function colorFor(v, warn_lo, warn_hi)
    if warn_lo and v < warn_lo then
        return COL_AMBER
    end
    if warn_hi and v > warn_hi then
        return COL_RED
    end
    return COL_GREEN
end

local function fmt(v, dp)
    return string.format("%." .. (dp or 0) .. "f", v)
end

-- ---------------------------------------------------------------------------
-- Widget renderers — each draws inside the card rect (x = left, y = bottom)
-- ---------------------------------------------------------------------------
local function drawLabel(x, y, text)
    sasl.gl.drawText(font, x + 8, y + CARD_H - 17, text, 12, false, false, TEXT_ALIGN_LEFT, COL_DIM)
end

local function wLamp(x, y, f, v)
    local on = v > 0.5
    local col
    if f.fault then
        col = on and COL_RED or COL_GREEN
    else
        col = on and COL_GREEN or COL_OFF
    end
    local cx, cy = x + 20, y + 24
    sasl.gl.drawCircle(cx, cy, 9, true, col)
    sasl.gl.drawCircle(cx, cy, 9, false, COL_FRAME)
    local txt
    if f.fault then
        txt = on and "ALARM" or "OK"
    else
        txt = on and "ON" or "OFF"
    end
    sasl.gl.drawText(font, x + 38, y + 18, txt, 14, false, false, TEXT_ALIGN_LEFT, on and COL_TEXT or COL_DIM)
end

local function wFail(x, y, f, v)
    local col, txt
    if v <= 0 then
        col, txt = COL_GREEN, "OK"
    elseif v >= 6 then
        col, txt = COL_RED, "FAIL"
    else
        col, txt = COL_AMBER, "ARM " .. fmt(v, 0)
    end
    local cx, cy = x + 20, y + 24
    sasl.gl.drawCircle(cx, cy, 9, true, col)
    sasl.gl.drawCircle(cx, cy, 9, false, COL_FRAME)
    sasl.gl.drawText(font, x + 38, y + 18, txt, 14, false, false, TEXT_ALIGN_LEFT, COL_TEXT)
end

local function wBar(x, y, f, v)
    local minv, maxv = f.min or 0, f.max or 1
    local frac = math.clamp(0, (v - minv) / (maxv - minv), 1)
    local col = colorFor(v, f.warn_lo, f.warn_hi)
    local bx, by, bw, bh = x + 8, y + 14, CARD_W - 16, 14
    sasl.gl.drawRectangle(bx, by, bw, bh, COL_OFF)
    sasl.gl.drawRectangle(bx, by, bw * frac, bh, col)
    sasl.gl.drawFrame(bx, by, bw, bh, COL_FRAME)
    local dp = f.dp or ((maxv - minv) >= 50 and 0 or 1)
    sasl.gl.drawText(font, x + CARD_W - 8, y + 36, fmt(v, dp) .. " " .. (f.unit or ""), 14, false, false,
        TEXT_ALIGN_RIGHT, COL_TEXT)
end

local function wGauge(x, y, f, v)
    local minv, maxv = f.min or 0, f.max or 1
    local frac = math.clamp(0, (v - minv) / (maxv - minv), 1)
    local col = colorFor(v, f.warn_lo, f.warn_hi)
    local cx, cy, r = x + 32, y + 30, 22
    local startA, sweep = 135, 270
    sasl.gl.drawArc(cx, cy, r - 6, r, startA, sweep, COL_OFF)
    if frac > 0 then
        sasl.gl.drawArc(cx, cy, r - 6, r, startA, sweep * frac, col)
    end
    local dp = f.dp or ((maxv - minv) >= 50 and 0 or 1)
    sasl.gl.drawText(font, x + 64, y + 32, fmt(v, dp), 17, false, false, TEXT_ALIGN_LEFT, COL_TEXT)
    sasl.gl.drawText(font, x + 64, y + 16, f.unit or "", 11, false, false, TEXT_ALIGN_LEFT, COL_DIM)
end

local function wValue(x, y, f, v)
    local s = fmt(v, f.dp or 0)
    if f.unit and f.unit ~= "" then
        s = s .. " " .. f.unit
    end
    sasl.gl.drawText(font, x + 8, y + 22, s, 20, false, false, TEXT_ALIGN_LEFT, COL_TEXT)
end

local function wEnum(x, y, f, v)
    local key = math.floor(v + 0.5)
    local txt = (f.map and f.map[key]) or fmt(v, 0)
    local active = key ~= 0
    local tw = sasl.gl.measureText(font, txt, 13, false, false)
    local cw = math.clamp(40, tw + 18, CARD_W - 16)
    local bx, by = x + 8, y + 14
    sasl.gl.drawRectangle(bx, by, cw, 22, active and COL_ACCENT or COL_OFF)
    sasl.gl.drawText(font, bx + cw / 2, by + 5, txt, 13, false, false, TEXT_ALIGN_CENTER, COL_TEXT)
end

local RENDER = {
    lamp = wLamp,
    fail = wFail,
    bar = wBar,
    gauge = wGauge,
    value = wValue,
    enum = wEnum
}

local function drawCard(x, y, f)
    sasl.gl.drawRectangle(x, y, CARD_W, CARD_H, COL_CARD)
    sasl.gl.drawFrame(x, y, CARD_W, CARD_H, COL_FRAME)
    drawLabel(x, y, f.label)
    local r = RENDER[f.kind] or wValue
    r(x, y, f, readv(f.dref))
end

-- ---------------------------------------------------------------------------
-- Frame
-- ---------------------------------------------------------------------------
function update()
    local n = #schema[current_tab].fields
    local total_rows = math.ceil(n / COLS)
    max_scroll = math.max(0, total_rows - VIS_ROWS)
    scroll_row = math.clamp(0, scroll_row, max_scroll)
end

local function drawTabBar()
    for i = 1, N_TABS do
        local j = i - 1
        local row = math.floor(j / TAB_PER_ROW)
        local x0 = (j % TAB_PER_ROW) * TAB_W
        local y0 = Hh - (row + 1) * TAB_H
        local on = (i == current_tab)
        sasl.gl.drawRectangle(x0, y0, TAB_W, TAB_H, on and COL_TABON or COL_TAB)
        sasl.gl.drawText(font, x0 + TAB_W / 2, y0 + 9, schema[i].short, 13, false, false, TEXT_ALIGN_CENTER,
            on and COL_TEXT or COL_DIM)
        if on then
            sasl.gl.drawRectangle(x0, y0, TAB_W, 3, COL_ACCENT)
        end
        sasl.gl.drawLine(x0, y0, x0, y0 + TAB_H, COL_BG)
    end
end

local function drawHeader()
    local y = CONTENT_T
    sasl.gl.drawText(font, PAD, y + 7, schema[current_tab].name, 17, false, false, TEXT_ALIGN_LEFT, COL_TEXT)
    -- always-on power readout (visible from any tab)
    local dcv = readv("an-24/power/bus_DC_27_volt")
    sasl.gl.drawCircle(W - 150, y + 14, 6, true, dcv >= 24 and COL_GREEN or COL_RED)
    sasl.gl.drawText(font, W - 138, y + 7, "DC " .. fmt(dcv, 1) .. "V", 14, false, false, TEXT_ALIGN_LEFT, COL_DIM)
    sasl.gl.drawLine(PAD, y + 2, W - PAD, y + 2, COL_FRAME)
end

local function drawScrollbar()
    if max_scroll <= 0 then
        return
    end
    local total_rows = VIS_ROWS + max_scroll
    local trackX, trackW = W - 8, 5
    sasl.gl.drawRectangle(trackX, CONTENT_B, trackW, CONTENT_H, COL_OFF)
    local thumbH = CONTENT_H * (VIS_ROWS / total_rows)
    local thumbY = CONTENT_T - thumbH - (CONTENT_H - thumbH) * (scroll_row / max_scroll)
    sasl.gl.drawRectangle(trackX, thumbY, trackW, thumbH, COL_ACCENT)
    -- arrow glyphs (clickable areas are separate components)
    local ax = W - 18
    sasl.gl.drawTriangle(ax, CONTENT_T - 4, ax + 8, CONTENT_T - 4, ax + 4, CONTENT_T - 14, COL_DIM) -- up
    sasl.gl.drawTriangle(ax, CONTENT_B + 14, ax + 8, CONTENT_B + 14, ax + 4, CONTENT_B + 4, COL_DIM) -- down
end

function draw()
    sasl.gl.drawRectangle(0, 0, W, Hh, COL_BG)
    drawTabBar()
    drawHeader()

    local fields = schema[current_tab].fields
    sasl.gl.setClipArea(CONTENT_L, CONTENT_B, CONTENT_W, CONTENT_H)
    for k = 0, #fields - 1 do
        local row = math.floor(k / COLS)
        local screenRow = row - scroll_row
        if screenRow >= 0 and screenRow < VIS_ROWS then
            local col = k % COLS
            local cx = CONTENT_L + col * COL_STRIDE
            local cy = CONTENT_T - (screenRow + 1) * CARD_H - screenRow * CARD_GAP
            drawCard(cx, cy, fields[k + 1])
        end
    end
    sasl.gl.resetClipArea()

    drawScrollbar()
end

-- ---------------------------------------------------------------------------
-- Interactivity — child clickables (handlers are rawget-dispatched, so they
-- must be constructor props on real clickable components, not file globals)
-- ---------------------------------------------------------------------------
local function scrollBy(d)
    scroll_row = math.clamp(0, scroll_row + d, max_scroll)
end

local comps = {}

-- tab buttons across the top (multi-row grid; matches drawTabBar)
do
    for i = 1, N_TABS do
        local j = i - 1
        local row = math.floor(j / TAB_PER_ROW)
        local x0 = (j % TAB_PER_ROW) * TAB_W
        local y0 = Hh - (row + 1) * TAB_H
        comps[#comps + 1] = clickable {
            position = {x0, y0, TAB_W, TAB_H},
            onMouseDown = function()
                current_tab = i;
                scroll_row = 0;
                return true
            end
        }
    end
end

-- mouse-wheel scrolling over the content area
comps[#comps + 1] = clickable {
    position = {CONTENT_L, CONTENT_B, CONTENT_W, CONTENT_H},
    onMouseWheel = function(_, _, _, _, _, _, clicks)
        scrollBy(-(clicks or 0));
        return true
    end
}

-- scroll arrows (right gutter)
comps[#comps + 1] = clickable {
    position = {W - 20, CONTENT_T - 16, 16, 16},
    onMouseDown = function()
        scrollBy(-1);
        return true
    end,
    onMouseHold = holdToRepeat(function()
        scrollBy(-1)
    end)
}
comps[#comps + 1] = clickable {
    position = {W - 20, CONTENT_B, 16, 16},
    onMouseDown = function()
        scrollBy(1);
        return true
    end,
    onMouseHold = holdToRepeat(function()
        scrollBy(1)
    end)
}

components = comps
