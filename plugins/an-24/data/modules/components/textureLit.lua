-- Draws a texture independent of the cockpit lighting system (always lit).
-- Draw body is drawTextureFill (modules/core/glbl_draw.lua), shared with texture.
-- `id` identifies this instance in the log if the image is missing.

defineProperty("image")
defineProperty("id", "textureLit")

local warned = false

function draw()
    local img = get(image)
    if img then
        drawTextureFill(img, size[1], size[2], {1, 1, 1, 1})
    elseif not warned then
        print("[an-24] textureLit id='" .. tostring(get(id)) .. "' has no image " .. cTag(_C))
        warned = true
    end
end