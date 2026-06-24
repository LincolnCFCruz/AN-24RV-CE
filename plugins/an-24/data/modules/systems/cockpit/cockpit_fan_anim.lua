--[[

  File: cockpit_fan_anim.lua
  -----
  This is cockpit fan angle calculations for animation

--]] 

local numfan = 4
local vent, ventsw, ventop = {}, {}, {}
local vspd = {0, 0, 0, 0}

local upspd = 1000
local dnspd = 400
local maxspd = 1200 -- Deg per second

for i = 1, numfan do
    vent[i] = gPf(pfx .. "misc/vent_" .. i) -- created in glbl_drfs.lua
    ventsw[i] = gPi(pfx .. "misc/vent_" .. i .. "_sw") -- created in glbl_drfs.lua
    ventop[i] = gPi(pfx .. "misc/vent_" .. i .. "_op") -- created in glbl_drfs.lua
end

function update()
    for i = 1, numfan do
        local v = (gvar.bus_dc27v > 21 and get(ventsw[i]) == 1) and 1 or 0
        set(ventop[i], v)
        vspd[i] = math.clamp(0, v == 1 and vspd[i] + upspd * gvar.frame_time or vspd[i] - dnspd * gvar.frame_time,
            maxspd)
        set(vent[i], (get(vent[i]) + vspd[i] * gvar.frame_time) % 360)
    end
end
