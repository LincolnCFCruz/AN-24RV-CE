-- Invisible clickable area. Shows a debug outline when showClickableAreas is true.
-- `id` is an optional string used to identify this instance (drawn next to the
-- debug outline when showClickableAreas is on).

defineProperty("id", "clickable")

-- Accept the LEFT mouse button only; right/middle clicks return false and fall
-- through to X-Plane (e.g. right-drag view pan).
--
-- WHY this works for inline `clickable { onMouseDown = ... }` call sites: SASL
-- merges the {...} args into this component's env (initMain.lua setupComponent)
-- BEFORE running this file body (setfenv(f,t); f(t)). So by line 14 below,
-- `onMouseDown` already IS the caller's handler, and we re-wrap it in place. The
-- nested clickables inside rotary.lua / lever.lua are themselves `clickable`
-- instances, so they're covered the same way.
--
-- This ONLY guards handlers hosted on a `clickable`. button/switch/switchLit put
-- their handler on the PARENT wrapper (the inner clickable just carries the
-- cursor), so they apply leftMouseOnly in their own files. Any handler on a
-- different host (e.g. mouseFocusedZone in popupCloseButton.lua) must wrap
-- itself. Scroll (onMouseWheel) and hover (onMouseMove) are left untouched.
onMouseDown = leftMouseOnly(onMouseDown)
onMouseUp   = leftMouseOnly(onMouseUp)
onMouseHold = leftMouseOnly(onMouseHold)

function draw(self)
    if globalShowInteractiveAreas then
        sasl.gl.drawFrame(0, 0, size[1], size[2])
    end
end
