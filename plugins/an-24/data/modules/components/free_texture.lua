-- Draws a texture at an explicit position/size inside the parent's coordinate
-- space (does not use the component `position`/transform).
-- `id` is an optional string used to identify this instance in the log if it breaks.

defineProperty("image")
defineProperty("position_x")
defineProperty("position_y")
defineProperty("width")
defineProperty("height")
defineProperty("id", "free_texture")

local warned = false

function draw(self)
    local img = get(image)
    if img then
        sasl.gl.drawTexture(img, get(position_x), get(position_y), get(width), get(height))
    elseif not warned then
        print("[an-24] free_texture id='" .. tostring(get(id)) .. "' has no image " .. cTag(_C))
        warned = true
    end
end
