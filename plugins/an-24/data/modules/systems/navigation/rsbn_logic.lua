defineProperty("run_time", globalProperty("sim/time/total_running_time_sec"))
defineProperty("lat", globalProperty("sim/flightmodel/position/latitude"))
defineProperty("lon", globalProperty("sim/flightmodel/position/longitude"))
defineProperty("alt", globalProperty("sim/flightmodel/position/elevation"))

defineProperty("dataset", globalProperty("an-24/rsbn/dataset"))
defineProperty("rsbn_receive", globalProperty("an-24/rsbn/receive"))
defineProperty("rsbn_channel", globalProperty("an-24/rsbn/channel"))
defineProperty("rsbn_lat", globalProperty("an-24/rsbn/lat"))
defineProperty("rsbn_lon", globalProperty("an-24/rsbn/lon"))
defineProperty("rsbn_elev", globalProperty("an-24/rsbn/elev"))
defineProperty("rsbn_cc", globalProperty("an-24/rsbn/rsbn_cc"))

local timer = get(run_time)
local notLoaded = true
local line = 0
local i = 0
local j = 0
local channel = 0
local name = 0
local ident = 0
local freq = 0
local elev = 0
local orbit = 0
local range = 0
local la1 = 0
local lon1 = 0
local d = 0
local prev_channel
local filename = 0

-- dataset: 0 = USSR, 1 = CIS

function loadrsbn()
    local file = io.open(filename, "r")
    -- If file exists: read and find the matching channel
    if file then
        repeat
            local line = file:read("*line")
            if line == nil then
                break
            end
            channel = string.sub(line, 1, 2)
            -- If this station has the matching channel, read all data
            if tonumber(channel) == get(rsbn_channel) then
                i = string.find(line, "|")
                j = string.find(line, "|", i + 1)
                name = string.sub(line, i + 1, j - 1)
                i = string.find(line, "|", j + 1)
                ident = string.sub(line, j + 1, i - 1)
                j = string.find(line, "|", i + 1)
                freq = string.sub(line, i + 1, j - 1)
                i = string.find(line, "|", j + 1)
                lat2 = tonumber(string.sub(line, j + 1, i - 1)) * math.pi / 180
                i = string.find(line, "|", j + 1)
                j = string.find(line, "|", i + 1)
                lon2 = tonumber(string.sub(line, i + 1, j - 1)) * math.pi / -180
                elev = tonumber(string.sub(line, j + 1, -1))
                lat1 = get(lat) * math.pi / 180
                lon1 = get(lon) * math.pi / -180
                -- Calculate slant range to beacon
                orbit = (2 * math.asin(math.sqrt(
                    (math.sin((lat1 - lat2) / 2)) ^ 2 + math.cos(lat1) * math.cos(lat2) * (math.sin((lon1 - lon2) / 2)) ^
                        2)))
                range = 3.57 * math.sqrt(get(alt)) * 1000
                orbit = orbit * 10800 / math.pi * 1852
                if orbit < range and orbit > get(alt) then
                    set(rsbn_receive, 1)
                    set(rsbn_lat, lat2)
                    set(rsbn_lon, lon2)
                    set(rsbn_elev, elev)
                end
            end
        until get(rsbn_receive) == 1
        if get(rsbn_receive) ~= 1 then
            set(rsbn_receive, -1)
        end
        file:close()
    else
        print("RSBN database couldn't be read")
    end
end

function update()
    -- Re-trigger search when channel changes
    if prev_channel ~= get(rsbn_channel) then
        set(rsbn_receive, 0)
        prev_channel = get(rsbn_channel)
    end

    -- If we lost the station, search immediately.
    -- If the search failed (-1), retry every 5 seconds.
    if get(rsbn_receive) == 0 then
        notLoaded = true
    elseif get(rsbn_receive) == -1 and get(run_time) > timer then
        notLoaded = true
        timer = get(run_time) + 5
    end

    if notLoaded and get(rsbn_cc) ~= 0 then
        notLoaded = false
        if get(dataset) == 1 then
            filename = pluginDataDir .. "/modules/databases/ussr.dat"
        else
            filename = pluginDataDir .. "/modules/databases/cis.dat"
        end
        loadrsbn()
    end
end
