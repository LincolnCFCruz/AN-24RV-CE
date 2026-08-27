--[[

  File: flight_logger.lua
  -----
  Flight-test logger (developer tool) — NOT REGISTERED BY DEFAULT

  Ported from Evgeny Gimaev's an24_logger.lua. This is the instrument the
  engine/aero calibration was flown with: it samples the handful of numbers the
  RLE checkpoints are stated in (altitude, IAS, TAS, V/S, torque, UPRT, N1) at a
  fixed interval, so a climb or a cruise leg can be compared against the AFM
  table afterwards without staring at gauges.

  It writes with print(), so the samples land in
  plugins/an-24/data/output/SASLLog.txt, tagged [AN24] for grepping.

  TO ENABLE: uncomment `flight_logger {},` in the V11/V13 upgrade block of
  main.lua. It is left out of the component list by default because a line
  every 5 s of flight is noise in an ordinary log — the same convention
  fuse_cd_logic.lua follows.

  Sampling is gated on AGL > 30 m so taxi and parking do not fill the log.

--]]

defineProperty("fl_time", globalProperty("sim/time/total_running_time_sec"))
defineProperty("fl_alt", globalProperty("sim/flightmodel/position/elevation")) -- metres MSL
defineProperty("fl_agl", globalProperty("sim/flightmodel/position/y_agl")) -- metres AGL
defineProperty("fl_ias", globalProperty("sim/flightmodel/position/indicated_airspeed2")) -- see IAS note below
defineProperty("fl_tas", globalProperty("sim/flightmodel/position/true_airspeed")) -- m/s
defineProperty("fl_vs", globalProperty("sim/flightmodel/position/vh_ind")) -- m/s
defineProperty("fl_trq", globalProperty("sim/flightmodel/engine/ENGN_TRQ[0]")) -- N*m, engine 1
defineProperty("fl_n1", globalProperty("sim/flightmodel/engine/ENGN_N1_[0]")) -- %, engine 1
defineProperty("fl_uprt", globalProperty("an-24/misc/virt_rud1")) -- UPRT lever, 0..1

local LOG_INTERVAL = 5.0 -- seconds between samples
local MIN_AGL = 30.0 -- metres — below this we are taxiing, not testing
local KT_TO_KMH = 1.852
local MS_TO_KMH = 3.6

local last_time = 0

function update()
    local t = get(fl_time)
    if t - last_time < LOG_INTERVAL then
        return
    end
    last_time = t

    if get(fl_agl) < MIN_AGL then
        return
    end

    -- IAS note: DataRefs.txt documents indicated_airspeed2 as kias, but the
    -- calibration flights only reconcile with the AFM if it is read as m/s.
    -- Rather than bake in a guess, log the RAW value alongside both readings —
    -- one glance at a cruise sample against the KUS-730 settles which is right.
    local ias_raw = get(fl_ias)

    print(string.format(
        "[AN24] t=%.0f alt=%.0f agl=%.0f ias_raw=%.1f (=%.0f km/h if kt, %.0f km/h if m/s) " ..
            "tas=%.0f km/h vs=%.1f trq=%.1f uprt=%.0f%% n1=%.1f%%", t, get(fl_alt), get(fl_agl), ias_raw,
        ias_raw * KT_TO_KMH, ias_raw * MS_TO_KMH, get(fl_tas) * MS_TO_KMH, get(fl_vs), get(fl_trq),
        get(fl_uprt) * 100, get(fl_n1)))
end
