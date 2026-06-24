--[[

  File: glbl_func.lua
  -----
  Shared value/helper functions, all global so any component can call them
  without include/defineProperty.

--]]

-- Global datarefs
function cGPi(drf, def)
    return createGlobalPropertyi(drf, def or 0)
end
function cGPf(drf, def)
    return createGlobalPropertyf(drf, def or 0)
end
function cGPfa(drf, def)
    return createGlobalPropertyfa(drf, def or 0)
end
function gP(drf)
    return globalProperty(drf)
end
function gPi(drf)
    return globalPropertyi(drf)
end
function gPf(drf)
    return globalPropertyf(drf)
end

-- Boolean function
function setbool(prop, cond)
    set(prop, cond and 1 or 0)
end

-- bool -> int and int -> bool. bool2int is the value-returning sibling of setbool.
function _G.bool2int(v)
    if v then
        return 1
    else
        return 0
    end
end
function _G.int2bool(v)
    return v ~= 0
end

-- Clamp val to the [minv, maxv] range.
function math.clamp(minv, val, maxv)
    return (math.max(minv, math.min(maxv, val)))
end

-- Piecewise-linear interpolation over a sorted {{x1,y1},{x2,y2},...} table.
-- Returns the matching y for an exact x, linearly interpolates within range, and
-- past the last point continues with the "value - lastActual + lastReference" tail.
function _G.interpolate(tbl, value)
    local lastActual = 0
    local lastReference = 0
    for _k, v in pairs(tbl) do
        if value == v[1] then
            return v[2]
        end
        if value < v[1] then
            local a = value - lastActual
            local m = v[2] - lastReference
            return lastReference + a / (v[1] - lastActual) * m
        end
        lastActual = v[1]
        lastReference = v[2]
    end
    return value - lastActual + lastReference
end

-- Frame-rate-aware exponential smoothing: nudge `actual` toward `target` by
-- `rate` (default 1) scaled by the frame time `passed`, i.e.
-- actual = actual + rate * (target - actual) * passed.
function _G.approach(actual, target, passed, rate)
    return actual + (rate or 1) * (target - actual) * passed
end

-- SASL3's onMouseHold fires every frame, so a value-stepping handler would
-- advance 3-12x during one ordinary click. This factory restores SASL2's repeat
-- timing (an initial delay, then a steady period); a new press is detected by a
-- gap in hold events, so onMouseDown needs no changes.
--   onMouseHold = holdToRepeat(),       -- repeat the comp's onMouseDown
--   onMouseHold = holdToRepeat(stepFn), -- repeat a custom step function
local repeatClock = sasl.createTimer()
sasl.startTimer(repeatClock)

function _G.holdToRepeat(stepFn, delay, period)
    delay = delay or 0.5
    period = period or 0.15
    local lastSeen, dueAt = -1, 0
    return function(comp, x, y, button, parentX, parentY)
        local now = sasl.getElapsedSeconds(repeatClock)
        if now - lastSeen > 0.3 then -- hold events stopped arriving: new press
            dueAt = now + delay
        end
        lastSeen = now
        if now < dueAt then
            return true
        end
        dueAt = now + period
        if stepFn then
            return stepFn(comp, x, y, button, parentX, parentY) ~= false
        end
        return comp.onMouseDown(comp, x, y, button, parentX, parentY)
    end
end

-- Wraps a mouse-button handler so it fires only on the LEFT button; right/middle
-- clicks return false, letting the click fall through to the parent and
-- ultimately X-Plane (e.g. right-drag view pan). Because returning false defers
-- to the PARENT, every component with its own onMouseDown must apply this guard
-- (button/switch/switchLit wrap at the parent, not just the inner clickable).
-- onMouseWheel / onMouseMove are intentionally left alone.
function _G.leftMouseOnly(handler)
    return function(comp, x, y, button, parentX, parentY, ...)
        if button ~= MB_LEFT then
            return false
        end
        return handler(comp, x, y, button, parentX, parentY, ...)
    end
end

-- Builds a "(file #index)" tag for a component so diagnostic logs can trace a
-- misbehaving item (e.g. a textureless image) to its module + list position.
-- Reachable from any component env via the _G fallback in compIndex.
function _G.cTag(comp)
    local p = rawget(comp, "_P")
    local file = p and rawget(p, "componentFileName") or "?"
    local idx = "?"
    if p then
        local list = rawget(p, "components")
        if list then
            for i, c in ipairs(list) do
                if c == comp then
                    idx = i;
                    break
                end
            end
        end
    end
    return "(" .. tostring(file) .. " #" .. tostring(idx) .. ")"
end
