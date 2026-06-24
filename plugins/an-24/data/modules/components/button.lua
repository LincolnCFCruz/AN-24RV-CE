-- button is clickable area with texture
-- no image
defineProperty("image")

-- function
defineProperty("action")

-- left mouse button only; this button's handler sits on the parent (the inner
-- clickable only carries the cursor), so guard it here. See leftMouseOnly in
-- glbl_func.lua.
onMouseDown = leftMouseOnly(onMouseDown)
onMouseUp = leftMouseOnly(onMouseUp)
onMouseHold = leftMouseOnly(onMouseHold)

components = { 
    -- background image
    texture {
        image = image
    }, 
    
    -- clickable area
    clickable {
        cursor = Cursors.HAND
    }
}

