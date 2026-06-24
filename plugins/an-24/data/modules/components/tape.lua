-- scrollable tape
-- Draw body is drawScrollTape (modules/core/glbl_draw.lua), shared with tapeLit.

defineProperty("image")
defineProperty("id", "tape")             -- optional log / project-tree identifier
defineProperty("window", { 1.0, 1.0 })   -- size of visible area
defineProperty("scrollX", 0)             -- amount to scroll horizontally
defineProperty("scrollY", 0)             -- amount to scroll vertically

function draw(self)
    drawScrollTape(get(image), get(window), get(scrollX), get(scrollY), size[1], size[2])
end
