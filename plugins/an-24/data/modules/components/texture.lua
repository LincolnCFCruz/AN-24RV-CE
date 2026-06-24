-- Draws a texture filling the component area. Draw body is drawTextureFill
-- (modules/core/glbl_draw.lua), shared with textureLit.
-- `id` identifies this instance in the log if the image is missing.

defineProperty("image")
defineProperty("id", "texture")

local warned = false

function draw()
    local img = get(image)
    if img then
        drawTextureFill(img, size[1], size[2])
    elseif not warned then
        print("[an-24] texture id='" .. tostring(get(id)) .. "' has no image " .. cTag(_C))
        warned = true
    end
end
