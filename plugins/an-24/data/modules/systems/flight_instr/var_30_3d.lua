size = {200, 200}

-- initialize component property table
defineProperty("vvi", globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot"))

-- background image

-- needle image
defineProperty("needleImage", langImage("needles", 86, 10, 18, 173))

local variometer_table = {
    {-100, -180}, 
    {-30, -180}, 
    {-20, -140}, 
    {-10, -80}, 
    {10, 80}, 
    {20, 140}, 
    {30, 180}, 
    {100, 180}
}

-- interpolate(): shared helper in core/glbl_func.lua

-- post frame calculations
local vvi_angle

function update()
    vvi_angle = interpolate(variometer_table, get(vvi) * 0.00508) - 90
end

components = { 
    -- vvi needle
    needle {
        position = {10, 10, 180, 180},
        image = function()
            return get(needleImage)
        end,
        angle = function()
            return vvi_angle
        end
    }
}
