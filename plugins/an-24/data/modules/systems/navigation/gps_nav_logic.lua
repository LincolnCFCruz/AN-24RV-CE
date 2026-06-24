-- gps_nav.lua
-- XP12: GPS navigation for AP-28 An-24
--
-- This module reads data from the standard X-Plane GPS (or KLN-90, GNS-430,
-- if they are connected to the standard GPS channel via override_gps) and
-- calculates the required angular deviation from the course (like curse_gpk/curse_gik).
--
-- The result is written to an-24/ap/curse_gps, which ap28_logic.lua uses
-- in mode ap_curse_stab == 3 (GPS).
--
-- If the GPS is not active, the route is not loaded, or the signal is bad — the module
-- writes 0 to curse_gps and raises the flag an-24/ap/gps_valid = 0, so the AP can
-- "understand" that the GPS mode is invalid.
--
-- Note: the module does NOT switch the ap_curse_stab mode itself — that is done
-- via the switch in the cockpit (or via command).
-- ============================================================================
-- INPUT DATAREFS (read)
-- ============================================================================
-- GPS power (1 = on, 0 = off)
defineProperty("gps_power", globalProperty("sim/cockpit2/radios/actuators/gps_power"))

-- Magnetic bearing from the aircraft to the current GPS route point
defineProperty("gps_bearing_mag", globalProperty("sim/cockpit2/radios/indicators/gps_bearing_deg_mag"))

-- Programmed GPS course (what it should fly by) - in true degrees
defineProperty("gps_course_true", globalProperty("sim/cockpit/gps/course"))

-- Current magnetic heading of the aircraft (for difference calculation)
defineProperty("magnetic_heading", globalProperty("sim/flightmodel/position/mag_psi"))

-- Magnetic declination (for converting true to magnetic, if needed)
defineProperty("mag_variation", globalProperty("sim/flightmodel/position/magnetic_variation"))

-- Lateral deviation from the route line (CDI deflection in "dots"; -2.5 ... +2.5)
defineProperty("gps_hdef_dots", globalProperty("sim/cockpit2/radios/indicators/gps_hdef_dots_pilot"))

-- XP12: CDI sensitivity — how many nautical miles per one "dot" of deflection.
-- gps_xtk is often = 0 for various GPS units, so we compute XTK via hdef_dots * nm_per_dot.
defineProperty("gps_nm_per_dot", globalProperty("sim/cockpit/radios/gps_hdef_nm_per_dot"))

-- Cross-track deviation in miles (backup dataref, often = 0)
defineProperty("gps_xtk_nm", globalProperty("sim/cockpit2/radios/indicators/gps_xtk"))

-- Distance to the next point (miles)
defineProperty("gps_dme_nm", globalProperty("sim/cockpit2/radios/indicators/gps_dme_distance_nm"))

-- Whether GPS target is active (1 = flying to point, 2 = from point, 0 = no target)
defineProperty("gps_fromto", globalProperty("sim/cockpit/radios/gps_fromto"))

-- Current magnetic course from the aircraft's GPK (for comparison)
defineProperty("curse_gpk", globalProperty("an-24/ap/curse_gpk"))

-- DIAGNOSTICS: read AP-28 state to see what mode it is operating in
defineProperty("diag_ap_state", globalProperty("an-24/ap/ap_state"))
defineProperty("diag_ap_curse_stab", globalProperty("an-24/ap/ap_curse_stab"))
defineProperty("diag_ap_hdg_diff", globalProperty("an-24/ap/ap_hdg_diff"))
defineProperty("diag_ap_yaw_comm", globalProperty("an-24/ap/ap_yaw_comm"))
defineProperty("diag_ap_roll_comm", globalProperty("an-24/ap/ap_roll_comm"))

-- Frame time (for smoothing)
defineProperty("frame_time", globalProperty("an-24/time/frame_time"))

-- ============================================================================
-- FALLBACK DATAREFS — for KLN90B and other plugins with NAVSYNC=ON
-- ============================================================================
-- KLN90B (plugin todirbg) by DEFAULT does not write to standard gps_* datarefs.
-- NAVSYNC=ON must be enabled on page SET 11 of the KLN90B. After that it
-- synchronizes data into NAV datarefs (HSI). Here we use NAV1
-- as a fallback source in case GPS_* are empty.
--
-- ALTERNATIVELY: direct waypoint coordinates can be used and bearing calculated
-- manually — this works even if KLN publishes nothing.

-- NAV1 — fallback (KLN90B with NAVSYNC=ON writes course/deviation HSI here):
defineProperty("nav1_bearing", globalProperty("sim/cockpit2/radios/indicators/nav_bearing_deg_mag[0]"))
defineProperty("nav1_hdef_dot", globalProperty("sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot"))
defineProperty("nav1_dme_nm", globalProperty("sim/cockpit/radios/nav1_dme_dist_m"))
defineProperty("nav1_fromto", globalProperty("sim/cockpit/radios/nav1_fromto"))
defineProperty("nav1_obs_mag", globalProperty("sim/cockpit/radios/nav1_obs_degm"))

-- Coordinates of the current GPS destination waypoint. The XP12 datarefs that
-- used to publish them (gps_nav_id_latitude/longitude) are gone, so we resolve
-- the coordinates via SASL3's nav-database API instead: getGPSDestination()
-- returns the nav-aid ID of the active GPS target, and getNavAidInfo(id) returns
-- its lat/lon (see the source-3 fallback in update()). We then calculate the
-- bearing ourselves via the spherical formula. This is the most reliable path —
-- it works with any GPS plugin that drives the standard GPS destination.
defineProperty("plane_lat", globalProperty("sim/flightmodel/position/latitude"))
defineProperty("plane_lon", globalProperty("sim/flightmodel/position/longitude"))

-- ============================================================================
-- OUTPUT DATAREFS (create and write)
-- ============================================================================

-- Output datarefs declared in glbl_drfs.lua; bind here for local use.
-- Main output: GPS course for AP (like curse_gpk/curse_gik, but from GPS)
defineProperty("curse_gps", globalProperty("an-24/ap/curse_gps"))
-- Validity flag: 1 if GPS is active and route is loaded, 0 if unusable
defineProperty("gps_valid", globalProperty("an-24/ap/gps_valid"))
-- Course correction from XTK (for fine track-following)
defineProperty("gps_xtk_correction", globalProperty("an-24/ap/gps_xtk_correction"))
-- GPS mode flag: 1 = AP following GPS route, 0 = AP using normal modes
defineProperty("gps_mode_on", globalProperty("an-24/ap/gps_mode_on"))

-- ============================================================================
-- SETTINGS
-- ============================================================================

-- How many degrees GPS can "steer" the aircraft via XTK correction.
-- If the aircraft deviated from the route line, GPS adds correction to the course.
-- Higher = more aggressive GPS return to track, but less smoothness.
-- Real KLN-90 gives approximately 10-20° per 1 nautical mile deviation.
local XTK_GAIN = 15.0 -- degrees of correction per 1 nautical mile deviation
local XTK_MAX_DEG = 30.0 -- maximum correction (limit)

-- Diagnostics — print GPS state every 5 sec
local diag_counter = 0
local diag_interval = 5.0

-- ============================================================================
-- MAIN LOGIC
-- ============================================================================

function update()
    local passed = get(frame_time)

    -- ════════════════════════════════════════════════════════════════════
    -- DETERMINE DATA SOURCE — three options in priority order:
    --   1. Standard gps_* (XP12 GPS, GNS-430/530, KLN90B with NAVSYNC=ON)
    --   2. NAV1 (KLN90B with NAVSYNC=ON or GNS in NAV mode)
    --   3. Direct calculation from waypoint coordinates (universal fallback)
    -- ════════════════════════════════════════════════════════════════════

    local valid = 0
    local bearing = 0 -- magnetic bearing to point (target course)
    local xtk = 0 -- lateral deviation in nautical miles
    local source = 0 -- 0=none, 1=GPS, 2=NAV1, 3=calculated

    -- Source 1: standard X-Plane GPS (gps_*)
    if get(gps_power) == 1 and get(gps_fromto) ~= 0 then
        local gps_bear = get(gps_bearing_mag)
        if gps_bear ~= nil and gps_bear ~= 0 then
            bearing = gps_bear
            -- XTK via hdef * nm_per_dot (standard XP12 method)
            local nm_per_dot = get(gps_nm_per_dot)
            local hdef = get(gps_hdef_dots)
            if nm_per_dot ~= nil and nm_per_dot > 0.001 then
                xtk = hdef * nm_per_dot
            else
                xtk = get(gps_xtk_nm) or 0
            end
            source = 1
            valid = 1
        end
    end

    -- Source 2: NAV1 (if KLN90B is active with NAVSYNC=ON)
    -- KLN writes the point course to nav1_obs_mag, deviation to nav1_hdef_dot
    if valid == 0 then
        local nav_ft = get(nav1_fromto)
        if nav_ft ~= nil and nav_ft ~= 0 then
            -- nav1_obs_degm — point course (OBS), not bearing.
            -- Use bearing if available, otherwise OBS as approximation.
            local nav_bear = get(nav1_bearing)
            if nav_bear ~= nil and nav_bear ~= 0 then
                bearing = nav_bear
            else
                bearing = get(nav1_obs_mag) or 0
            end
            -- nav1_hdef in dots — for VOR/GPS this is ~1 dot = 1 NM
            xtk = (get(nav1_hdef_dot) or 0) * 1.0
            source = 2
            valid = 1
        end
    end

    -- Source 3: direct calculation from point coordinates
    -- Used when the plugin writes neither to gps_* nor to nav1_*.
    -- Resolve the active GPS destination through SASL3's nav-database API:
    -- getGPSDestination() → nav-aid ID, getNavAidInfo(id) → (type, lat, lon, …).
    if valid == 0 then
        local dest_lat, dest_lon
        local dest_id = sasl.getGPSDestination()
        if dest_id ~= nil and dest_id ~= NAV_NOT_FOUND then
            local _, navLat, navLon = sasl.getNavAidInfo(dest_id)
            dest_lat = navLat
            dest_lon = navLon
        end
        if dest_lat ~= nil and dest_lon ~= nil and (dest_lat ~= 0 or dest_lon ~= 0) then
            local lat = get(plane_lat)
            local lon = get(plane_lon)
            -- Spherical bearing calculation (Forward Azimuth formula)
            local lat1 = math.rad(lat)
            local lat2 = math.rad(dest_lat)
            local dlon = math.rad(dest_lon - lon)
            local y = math.sin(dlon) * math.cos(lat2)
            local x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dlon)
            local bearing_true = math.deg(math.atan2(y, x))
            -- Convert to magnetic course (XP12 magnetic_variation: + = east)
            bearing = bearing_true - get(mag_variation)
            -- Normalize 0..360
            while bearing < 0 do
                bearing = bearing + 360
            end
            while bearing > 360 do
                bearing = bearing - 360
            end
            -- XTK here = 0 (cannot compute precisely without knowing previous point)
            xtk = 0
            source = 3
            valid = 1
        end
    end

    -- ════════════════════════════════════════════════════════════════════
    -- If no source provided data — disable GPS
    -- ════════════════════════════════════════════════════════════════════
    if valid == 0 then
        set(curse_gps, 0)
        set(gps_valid, 0)
        set(gps_xtk_correction, 0)
        return
    end

    set(gps_valid, 1)

    -- Current magnetic heading of the aircraft
    local heading = get(magnetic_heading)

    -- If XTK is still ~0 but hdef is deflected — rough estimate via dots
    if math.abs(xtk) < 0.001 then
        local hdef = get(gps_hdef_dots) or 0
        if math.abs(hdef) > 0.01 then
            xtk = hdef * 1.0 -- 1 dot ≈ 1 nautical mile (rough)
        end
    end

    -- Correction from lateral deviation (XTK)
    local xtk_correction = xtk * XTK_GAIN
    if xtk_correction > XTK_MAX_DEG then
        xtk_correction = XTK_MAX_DEG
    elseif xtk_correction < -XTK_MAX_DEG then
        xtk_correction = -XTK_MAX_DEG
    end

    set(gps_xtk_correction, xtk_correction)

    -- Target course = bearing to point + correction to return to track line
    local target_heading = bearing + xtk_correction
    -- Normalize 0...360
    while target_heading > 360 do
        target_heading = target_heading - 360
    end
    while target_heading < 0 do
        target_heading = target_heading + 360
    end

    -- Difference between required and current course
    local diff = target_heading - heading
    while diff > 180 do
        diff = diff - 360
    end
    while diff < -180 do
        diff = diff + 360
    end

    set(curse_gps, diff)
end
