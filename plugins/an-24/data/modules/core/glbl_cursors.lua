--[[

  File: glbl_cursors.lua
  -----
  Named mouse cursors, sourced from the shared atlas components/cursors.png.

  cursors.png is the X-Plane cursor set as an 8x8 grid of 64px cells (512x512,
  rows 0-5 populated). Each glyph sits inside its cell with transparent padding,
  so we extract a TIGHT crop per glyph and draw it at its native size (~16px,
  matching the old loose cursor PNGs it replaces).

  A cursor descriptor is the table SASL's interaction system reads from a
  clickable's `cursor` field (see private.getComponentCursor, initMain.lua):
      { x, y, width, height, shape, hideOSCursor }
  shape        = loaded texture (a sub-region of cursors.png)
  x, y         = hot point: offset (px) of the glyph's lower-left corner from the
                 mouse (NOT an in-image point). The default (-w/2, -h) anchors the
                 mouse at the glyph's TOP-centre so the glyph hangs below the
                 pointer, mimicking the Windows cursor; (-w/2, -h/2) centres the
                 glyph on the pointer, and (-w/2, 0) anchors its bottom-centre.
                 Tunable in this file alone.
  w, h         = on-screen draw size (the crop's native size)
  hideOSCursor = hide the X-Plane system arrow while shown (else double cursor)

  CALIBRATION NOTE: crop rects use a bottom-left image origin -- each `ay` was
  computed as (512 - top - h), where `top` is the glyph's top-left row in the
  atlas as authored (atlas is 512px tall). The `top=` comment on each entry keeps
  that source value so the rect stays easy to re-derive. If cursors render
  vertically mirrored in-sim, revert `ay` to the `top=` value (top-left origin).

  Usage:  cursor = Cursors.HAND   /   cursor = Cursors.ROTATE_LEFT

--]]

local ATLAS = "cursors.png"

-- Tight-cropped cursor glyph from the atlas (hot-point + hideOSCursor semantics
-- documented in the header).
--   ax, ay, w, h = pixel rect inside cursors.png (bottom-left origin)
--   hx, hy       = optional hot-point override (offset of the glyph's lower-left
--                  corner from the mouse); negative moves it left/down
local function cur(ax, ay, w, h, hx, hy)
    return {
        x = hx or (-w / 2),
        y = hy or -h, -- default: mouse at glyph top-centre, so the glyph hangs below it (Windows-style)
        width = w,
        height = h,
        shape = loadImage(ATLAS, ax, ay, w, h),
        hideOSCursor = true
    }
end

Cursors = {
    -- hands ------------------------------------------------------------------
    HAND        = cur(281, 461, 17, 19), -- top=32  pointing finger: buttons, toggles, generic clickables
    OPEN_HAND   = cur(343, 460, 18, 20), -- top=32  flat hand: pannable / draggable surface
    HAND_GRAB   = cur(408, 465, 15, 16), -- top=31  closed hand: grabbed handle while dragging

    -- translation ------------------------------------------------------------
    FOUR_ARROWS = cur(463, 462, 35, 35, nil, -35 / 2), -- top=15  free 2D drag / move (centred)
    UP_DOWN     = cur(347, 398, 11, 35, nil, -35 / 2), -- top=79  levers / vertical sliders / up-down drag (centred)
    LEFT_RIGHT  = cur(270, 410, 35, 11, nil, -11 / 2), -- top=91  horizontal sliders / left-right drag (centred)

    -- single-step arrows -----------------------------------------------------
    UP          = cur(411, 409, 11, 19), -- top=84   step up
    DOWN        = cur(411, 341, 11, 19), -- top=152  step down
    LEFT        = cur(277, 347, 19, 11), -- top=154  step left
    RIGHT       = cur(344, 347, 19, 11), -- top=154  step right

    -- rotation ---------------------------------------------------------------
    ROTATE       = cur(70, 464, 52, 32, nil, -32 / 2), -- top=16   bidirectional drag-rotate knob ("- ( ) +") (centred)
    ROTATE_LEFT  = cur(277, 271, 21, 32),              -- top=209  rotary decrease half (replaces rotateleft.png)
    ROTATE_RIGHT = cur(86, 271, 21, 32),               -- top=209  rotary increase half (replaces rotateright.png)

    -- wheel ------------------------------------------------------------------
    SPIN         = cur(78, 399, 35, 35, nil, -35 / 2) -- top=78   scroll / spin-wheel knob (centred)
}
