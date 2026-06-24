defineProperty("external_view", globalProperty("sim/graphics/view/view_is_external"))
defineProperty("bus_DC_27_volt", globalProperty("an-24/power/bus_DC_27_volt"))
defineProperty("bus_DC_27_volt_emerg", globalProperty("an-24/power/bus_DC_27_volt_emerg"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- time for frames

-- coordinates of airplane and camera
defineProperty("local_x", globalProperty("sim/flightmodel/position/local_x")) -- position X
defineProperty("local_y", globalProperty("sim/flightmodel/position/local_y")) -- position Y
defineProperty("local_z", globalProperty("sim/flightmodel/position/local_z")) -- position Z
defineProperty("view_x", globalProperty("sim/graphics/view/view_x")) -- camera position X
defineProperty("view_y", globalProperty("sim/graphics/view/view_y")) -- camera position Y
defineProperty("view_z", globalProperty("sim/graphics/view/view_z")) -- camera position Z

-- window wind
local wind_sound = loadSample('sounds/custom/window_wind.wav')
local last_dist = 0

sasl.al.playSample(wind_sound, true) -- wind in windows
setSampleGain(wind_sound, 0)

defineProperty("hole1", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[2]"))
defineProperty("hole2", globalProperty("sim/flightmodel2/misc/custom_slider_ratio[3]"))
defineProperty("ias", globalProperty("sim/flightmodel/position/indicated_airspeed"))

defineProperty("prop_pitch_1", globalProperty("sim/cockpit2/engine/actuators/prop_pitch_deg[0]")) -- propeller pitch
defineProperty("prop_pitch_2", globalProperty("sim/cockpit2/engine/actuators/prop_pitch_deg[1]"))

defineProperty("eng1_N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[0]")) -- engine 1 rpm
defineProperty("eng2_N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[1]")) -- engine 2 rpm
defineProperty("ru19_N1", globalProperty("sim/flightmodel/engine/ENGN_N1_[2]")) -- engine 3 rpm

local last_dist = 0

function update()
    local passed = get(frame_time)
    local power = get(bus_DC_27_volt) > 20 or get(bus_DC_27_volt_emerg) > 20
    local external = get(external_view) -- 0 = inside, 1 = external
    local camera_distance = math.sqrt(((get(view_x) - get(local_x)) ^ 2) + ((get(view_y) - get(local_y)) ^ 2) +
                                          ((get(view_z) - get(local_z)) ^ 2)) -- in meters
    
    -- limit minimum distance
    if camera_distance < 10 then
        camera_distance = 10
    end 
	
    local dist_coef = 200 / camera_distance ^ 1.1
    if dist_coef > 1 then
        dist_coef = 1
    end
	
    -- calculate camera/aircraft speed
    local spd_time = math.min(0.0001, passed)
    local camera_spd = -(camera_distance - last_dist) / spd_time
    last_dist = camera_distance
    local dopp_coef = camera_spd * 0.02
    if dopp_coef > 400 then
        dopp_coef = 300
    elseif dopp_coef < -300 then
        dopp_coef = -300
    end

    -- noise when open windows in flight
    local window_open = math.max(get(hole1), get(hole2))
    local spd = get(ias) * 0.5
    local wind_gain = math.min(1000, window_open * spd * 10) * (1 - external)
    setSampleGain(wind_sound, wind_gain)

    -- prop sounds
    local prop_angle_1 = get(prop_pitch_1)
    local prop_angle_2 = get(prop_pitch_2)

    if prop_angle_1 < 1 then
        prop_angle_1 = 1
    end
    if prop_angle_2 < 1 then
        prop_angle_2 = 1
    end

    local prop_loud_1 = 1000 / prop_angle_1
    local prop_loud_2 = 1000 / prop_angle_2

    local N1 = get(eng1_N1) * 0.01
    local N2 = get(eng2_N1) * 0.01
    local N3 = get(ru19_N1) * 0.01
end
