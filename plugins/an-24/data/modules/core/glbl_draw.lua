--[[

  File: glbl_draw.lua
  -----
  Shared draw helpers for the instrument components. Each draw component file is
  a thin wrapper around one of these; texture sizes are memoised in texSize()
  instead of queried every frame. The functions live on _G so the component
  draw() environments can reach them (like glbl_func.lua's holdToRepeat()/cTag()).

  Colour convention: "Lit" component variants pass an explicit white tint; base
  variants pass nil and the helper substitutes WHITE below (the SASL drawTexture*
  functions error on an explicit nil colour, and white is their default).

--]]

-- Default white tint, substituted when a helper is called with no colour (the
-- SASL drawTexture* functions reject an explicit nil). One shared table.
local WHITE = {1, 1, 1, 1}

-- Localised image helpers (load the _e English / _r Russian variants of a base
-- name and select by the an-24/set/language dataref). The _langDrf handle is
-- resolved LAZILY on first use, not at include time: glbl_draw.lua loads BEFORE
-- glbl_drfs.lua creates an-24/set/language, so binding here would yield an
-- unresolved handle whose get() returns nil (rule 4).
local _langDrf

-- Returns the raw { [0] = English img, [1] = Russian img } table, indexable by
-- the language value -- use this when a module indexes the table inline (e.g.
-- `image = function() return cover[get(language)] end`). `ext` defaults to
-- ".dds" (pass ".png" for PNG backgrounds); x == nil loads the whole image (no crop).
function _G.langImages(baseName, x, y, w, h, ext)
    ext = ext or ".dds"
    local en, ru = baseName .. "_e" .. ext, baseName .. "_r" .. ext
    if x == nil then
        return {
            [0] = sasl.gl.loadImage(en),
            sasl.gl.loadImage(ru)
        }
    end
    return {
        [0] = sasl.gl.loadImage(en, x, y, w, h),
        sasl.gl.loadImage(ru, x, y, w, h)
    }
end

-- Returns a getter closure that selects the variant by the language dataref.
-- Use this for the common case fed straight into a property:
--   defineProperty("X", langImage("base", x,y,w,h))
-- `ext`/no-crop are forwarded to langImages (see above).
function _G.langImage(baseName, x, y, w, h, ext)
    if not _langDrf then
        _langDrf = globalProperty("an-24/set/language")
    end
    local drf = _langDrf
    local imgs = langImages(baseName, x, y, w, h, ext)
    return function()
        return imgs[get(drf)]
    end
end

-- Indicator LEDs all live on one spritesheet (leds.dds); naming the crops here
-- and loading via loadLED("green") avoids hand-coding the typo-prone rects (the
-- colours differ only by x offset). Big colours are 20x20 on row y=12; the two
-- "_small" variants are 10x10 on row y=22. A fresh handle is loaded per call.
-- (radar_panel's lone 100,12,10,10 crop is left inline.)
local LED = {
    white = {0, 12, 20, 20},
    green = {20, 12, 20, 20},
    red = {40, 12, 20, 20},
    yellow = {60, 12, 20, 20},
    blue = {80, 12, 20, 20},
    yellow_small = {100, 22, 10, 10},
    red_small = {110, 22, 10, 10}
}
function _G.loadLED(name)
    local c = LED[name]
    return sasl.gl.loadImage("leds.dds", c[1], c[2], c[3], c[4])
end

-- Texture dimensions never change at runtime, so cache them by texture handle
-- and avoid the per-frame getTextureSize() call inside every draw().
local sizeCache = {}
function _G.texSize(img)
    local s = sizeCache[img]
    if not s then
        s = {sasl.gl.getTextureSize(img)}
        sizeCache[img] = s
    end
    return s[1], s[2]
end

-- texture.lua / textureLit.lua: fill the component area with a texture.
function _G.drawTextureFill(img, w, h, color)
    if not img then
        return
    end
    color = color or WHITE
    drawTexture(img, 0, 0, w, h, color)
end

-- Draws a localised panel background from a langImages() table, picking the EN/RU
-- variant by the language dataref (resolved lazily, like langImage, so callers
-- that built `bg` via langImages() need not keep their own `language` handle).
function _G.drawLangBackground(imgs, w, h, color)
    if not _langDrf then
        _langDrf = globalProperty("an-24/set/language")
    end
    drawTextureFill(imgs[get(_langDrf)], w, h, color)
end

-- Source rect for a scroll tape: maps window size + scroll offset onto the
-- texture and flips the Y origin. SASL3 texture-part coords are in PIXELS with a
-- BOTTOM-LEFT origin (SASL2 used normalized 0-1 from the TOP). Shared by the
-- plain and rotated tape helpers (returns the four src args).
local function tapeRect(img, window, sx, sy)
    local tw, th = texSize(img)
    local szx = (window and window[1]) or 1
    local szy = (window and window[2]) or 1
    sx, sy = sx or 0, sy or 0
    return sx * tw, th - (sy + szy) * th, szx * tw, szy * th
end

-- tape.lua / tapeLit.lua: scrollable tape.
function _G.drawScrollTape(img, window, sx, sy, w, h, color)
    if not img then
        return
    end
    color = color or WHITE
    local rx, ry, rw, rh = tapeRect(img, window, sx, sy)
    drawTexturePart(img, 0, 0, w, h, rx, ry, rw, rh, color)
end

-- rotated_tapeLit.lua: scrollable tape rotated around its centre.
function _G.drawRotatedScrollTape(img, angle, window, sx, sy, w, h, color)
    if not img then
        return
    end
    color = color or WHITE
    local rx, ry, rw, rh = tapeRect(img, window, sx, sy)
    drawRotatedTexturePart(img, angle or 0, 0, 0, w, h, rx, ry, rw, rh, color)
end

-- needle.lua / needleLit.lua: rotating needle, centred and aspect-preserved
-- within the component area. `angle` may be a value or a function returning one.
function _G.drawNeedleTex(img, angle, w, h, color)
    if not img then
        return
    end
    color = color or WHITE
    local a = angle
    if type(a) == "function" then
        a = a()
    elseif a == nil then
        a = 0
    end
    local tw, th = texSize(img)
    local max = tw
    if th > max then
        max = th
    end
    local rw = (tw / max) * w
    local rh = (th / max) * h
    sasl.gl.drawRotatedTexture(img, a, (w - rw) / 2, (h - rh) / 2, rw, rh, color)
end

-- digitstape.lua / digitstapeLit.lua: numeric digit strip.
-- The digit texture has DIGIT_STRIP_ROWS rows: digits 0-9 occupy the first ten, the
-- decimal point is at row ROW_DECIMAL and the minus sign at row ROW_SIGN. One digit =
-- th/DIGIT_STRIP_ROWS pixels tall and the full strip width (tw) wide. `y` keeps the
-- SASL2 top-down cell offset; the flip to SASL3's bottom-left origin is at the draw call.
local DIGIT_STRIP_ROWS = 14
local ROW_DECIMAL = 12
local ROW_SIGN = 13
function _G.drawDigitStrip(img, overlayImg, value, digits, frac, allowNonRound, valueEnabler, showLeadingZeros,
    showSign, w, h, color)
    if not img then
        return
    end
    color = color or WHITE

    local symbolsNum = digits
    if 0 < frac then
        symbolsNum = symbolsNum + 1
    end
    local digitWidth = w / symbolsNum

    local v = math.abs(value or 0) * (10 ^ frac)
    if allowNonRound then
        v = math.floor(v + 0.5)
    end
    local pos = w - digitWidth

    local tw, th = texSize(img)
    local digitHeight = th / DIGIT_STRIP_ROWS

    if 0 < frac then
        local y = (ROW_DECIMAL + 1) * digitHeight
        drawTexturePart(img, pos - digitWidth * frac, 0, digitWidth, h, 0, th - y - digitHeight, tw, digitHeight, color)
    end

    if valueEnabler then
        local prevDigit = 0
        local digitsNum = digits
        if showSign then
            digitsNum = digitsNum - 1
        end
        for i = 1, digitsNum do
            local digit = v % 10
            if 9.5 < prevDigit then
                digit = digit + 1
            end
            prevDigit = digit
            v = math.floor(v / 10)
            local y = (10 - digit + 1) * digitHeight
            drawTexturePart(img, pos, 0, digitWidth, h, 0, th - y - digitHeight, tw, digitHeight, color)
            pos = pos - digitWidth
            if frac == i then
                pos = pos - digitWidth
            end
            if (i > frac) and (not showLeadingZeros) and (0 == v) then
                break
            end
        end
        if showSign and (0 > (value or 0)) then
            local y = (ROW_SIGN + 1) * digitHeight
            drawTexturePart(img, pos, 0, digitWidth, h, 0, th - y - digitHeight, tw, digitHeight, color)
        end
    end

    if overlayImg then
        drawTexture(overlayImg, 0, 0, w, h, color)
    end
end
