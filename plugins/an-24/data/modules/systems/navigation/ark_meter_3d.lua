size = {100, 100}

defineProperty("signal", globalProperty("an-24/ark/ark1_signal"))
defineProperty("frame_time", globalProperty("an-24/time/frame_time")) -- frame time
defineProperty("needleImg", langImage("needles", 226, 252, 118, 4))

local ndl_angle = -48
local last_angle = -48

-- post-frame calculations
function update()
    local passed = get(frame_time)
    -- time bug workaround
    if passed > 0 then
        local delta = (get(signal) * 70 - 48) - last_angle
        ndl_angle = ndl_angle + 3 * delta * passed
        last_angle = ndl_angle
    end
end

components = {
    needle {
        position = {-9, -36, 118, 118},
        image = function()
            return get(needleImg)
        end,
        angle = function()
            return ndl_angle + 90
        end
    }
}
