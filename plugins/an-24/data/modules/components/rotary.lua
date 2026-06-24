-- Rotary knob: two clickable halves (left = decrease, right = increase).
-- Ported from SASL2: coord system unchanged (uses sub-components).

defineProperty("image")
defineProperty("value",      0)
defineProperty("step",       1)
defineProperty("autoRepeat", true)

local function updateValue(newValue)
    local a = rawget(_C, "adjuster")
    if a then newValue = a(newValue) end
    set(value, newValue)
end

-- SASL2's onMouseClick fired on the press AND repeated while held (initial
-- delay, then a steady period). In SASL3 the press is onMouseDown and the
-- held repeat is holdToRepeat (glbl_func.lua), which restores that timing;
-- with autoRepeat disabled the hold does nothing.
local repeatDec = holdToRepeat(function() updateValue(get(value) - get(step)) end)
local repeatInc = holdToRepeat(function() updateValue(get(value) + get(step)) end)

components = {
    -- background image (only drawn when the rotary was given an image)
    texture { image = image, visible = function() return get(image) ~= nil end },

    clickable {
        position = {0, 0, size[1] / 2, size[2]},
        cursor   = Cursors.ROTATE_LEFT,
        onMouseDown = function()
            updateValue(get(value) - get(step))
            return true
        end,
        onMouseHold = function(comp, x, y, button, parentX, parentY)
            if not get(autoRepeat) then return false end
            return repeatDec(comp, x, y, button, parentX, parentY)
        end,
    },

    clickable {
        position = {size[1] / 2, 0, size[1] / 2, size[2]},
        cursor   = Cursors.ROTATE_RIGHT,
        onMouseDown = function()
            updateValue(get(value) + get(step))
            return true
        end,
        onMouseHold = function(comp, x, y, button, parentX, parentY)
            if not get(autoRepeat) then return false end
            return repeatInc(comp, x, y, button, parentX, parentY)
        end,
    },
}