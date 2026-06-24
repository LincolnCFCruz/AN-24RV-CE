-- numeric digit strip, drawn independent of the cockpit lighting (always lit).
-- Draw body is drawDigitStrip (modules/core/glbl_draw.lua), shared with digitstape.

defineProperty("image")                  -- no image by default
defineProperty("overlayImage")           -- image drawn over the digits (for a 3d effect)
defineProperty("value", 0)               -- default value
defineProperty("digits", 1)              -- maximum digits
defineProperty("fractional", 0)          -- number of fractional digits
defineProperty("allowNonRound", false)   -- allow non-round values
defineProperty("valueEnabler", true)     -- enable or disable value display
defineProperty("showLeadingZeros", false)-- show leading zeros
defineProperty("showSign", false)        -- show sign instead of first digit

function draw(self)
    drawDigitStrip(get(image), get(overlayImage), get(value), get(digits), get(fractional),
        get(allowNonRound), get(valueEnabler), get(showLeadingZeros), get(showSign),
        size[1], size[2], {1, 1, 1})
end
