-- scrollable rotatable tape, drawn independent of the cockpit lighting (always lit).
-- Draw body is drawRotatedScrollTape (modules/core/glbl_draw.lua).

defineProperty("image")
defineProperty("window", { 1.0, 1.0 })   -- size of visible area
defineProperty("scrollX", 0)             -- amount to scroll horizontally
defineProperty("scrollY", 0)             -- amount to scroll vertically
defineProperty("angle", 0)               -- rotation angle

function draw(self)
    drawRotatedScrollTape(get(image), get(angle), get(window), get(scrollX), get(scrollY),
        size[1], size[2], {1, 1, 1})
end
