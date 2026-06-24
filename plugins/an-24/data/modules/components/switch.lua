-- general two-state toggable button

-- image used when button in "ON" state
defineProperty("btnOn")

-- image used when button in "OFF" state
defineProperty("btnOff")

-- function called to get button state
defineProperty("state")

-- optional string to identify this instance in the log / project tree
defineProperty("id", "switch")

-- left mouse button only; this switch's handler sits on the parent (the inner
-- clickable only carries the cursor), so guard it here. See leftMouseOnly in
-- glbl_func.lua.
onMouseDown = leftMouseOnly(onMouseDown)
onMouseUp   = leftMouseOnly(onMouseUp)
onMouseHold = leftMouseOnly(onMouseHold)

components = {

    -- "on" state texture (only shown when an "on" image was supplied;
    -- click-only switches leave btnOn/btnOff nil and draw nothing)
    texture {
        image = btnOn,
        visible = function() return get(state) and get(btnOn) ~= nil; end,
    };

    -- "off" state texture
    texture {
        image = btnOff,
        visible = function() return (not get(state)) and get(btnOff) ~= nil; end,
    };

    -- clickable area
    clickable {
        cursor = Cursors.HAND,
    };
}

