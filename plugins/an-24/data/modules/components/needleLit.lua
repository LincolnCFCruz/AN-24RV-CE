-- Rotating needle gauge, drawn independent of the cockpit lighting (always lit).
-- Draw body is drawNeedleTex (modules/core/glbl_draw.lua), shared with needle.
-- `id` identifies this instance in the log if the image is missing.

defineProperty("angle", 0)
defineProperty("image")
defineProperty("id", "needleLit")

local warned = false

function draw()
    local img = get(image)
    if not img then
        if not warned then
            print("[an-24] needleLit id='" .. tostring(get(id)) .. "' has no image " .. cTag(_C))
            warned = true
        end
        return
    end
    drawNeedleTex(img, get(angle), size[1], size[2], {1, 1, 1, 1})
end
