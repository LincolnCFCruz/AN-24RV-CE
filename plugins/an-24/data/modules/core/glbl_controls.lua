--[[

  File: glbl_controls.lua
  -----
  Data-driven interaction-control factories (toggleSwitch / momentaryButton /
  stepButton), generalising the switch/clickable bodies that were hand-wired
  across ~37 modules (electric_panel_2d's busSwitch() was the only parametrized
  precursor). Each factory reproduces the original body exactly -- sound, cursor
  and click-zone semantics preserved.

  No an-24/... datarefs are bound at include time: the factories take dataref
  *handles* and build components only when CALLED, so this file is safe to
  include after glbl_drfs.lua (switch/clickable, Cursors, holdToRepeat,
  playUISound all resolve lazily at call time).

  The SASL2-era `switcher_pushed` debounce is intentionally gone: SASL3 fires
  onMouseDown once per press, so the flag never blocked anything.

--]]
-------------------------------------------------------------------------------
-- toggleSwitch{ position, drf, btnOn, btnOff, sound, state, onToggle }
-- Two-state switch bound to a 0/1 dataref. Generalizes busSwitch().
--   drf      : dataref toggled between 0 and onValue (required unless `state`)
--   onValue  : the "on" value written (default 1; e.g. wiper uses 2)
--   btnOn/Off: textures for the on/off states (optional; click-only if nil)
--   sound    : sample played on toggle (optional)
--   state    : override visual-state getter (defaults to get(drf) ~= 0)
--   onToggle : optional side-effect, called with the new value
--   guard    : optional predicate; toggle (and its sound) only fire when true
--              (e.g. a covered switch that only acts while its cap is open)
-------------------------------------------------------------------------------
function _G.toggleSwitch(t)
    local drf, sound, onToggle, guard = t.drf, t.sound, t.onToggle, t.guard
    local onValue = t.onValue ~= nil and t.onValue or 1
    -- `lit = true` uses the backlit switch variant (textureLit) instead of switch.
    local comp = t.lit and switchLit or switch
    return comp {
        position = t.position,
        visible = t.visible,
        state = t.state or function()
            return get(drf) ~= 0
        end,
        btnOn = t.btnOn,
        btnOff = t.btnOff,
        -- SASL3 fires onMouseDown once per press, so no debounce guard is needed.
        onMouseDown = function()
            if not guard or guard() then
                playUISound(sound)
                local nv = (get(drf) ~= 0) and 0 or onValue
                set(drf, nv)
                if onToggle then
                    onToggle(nv)
                end
            end
            return true
        end
    }
end

-------------------------------------------------------------------------------
-- momentaryButton{ position, drf, onValue, offValue, sound, soundUp, cursor }
-- Push-to-make: sets drf to onValue (default 1) on press, offValue (default 0)
-- on release. `sound` plays on press, `soundUp` on release (both optional).
-------------------------------------------------------------------------------
function _G.momentaryButton(t)
    local drf = t.drf
    local onValue = t.onValue ~= nil and t.onValue or 1
    local offValue = t.offValue ~= nil and t.offValue or 0
    local sound, soundUp = t.sound, t.soundUp
    return clickable {
        position = t.position,
        cursor = t.cursor or Cursors.HAND,
        onMouseDown = function()
            set(drf, onValue)
            playUISound(sound)
            return true
        end,
        onMouseUp = function()
            set(drf, offValue)
            playUISound(soundUp)
            return true
        end
    }
end

-------------------------------------------------------------------------------
-- stepButton{ position, cursor, sound, onStep, repeating }
-- A single click zone (no texture) that runs onStep() then plays `sound` on
-- press. With repeating=true it auto-repeats while held at SASL2 cadence
-- (holdToRepeat). This is the building block for rotary knob halves, frequency
-- tuners and up/down tumbler arrows — two stepButtons make one knob/tumbler.
--   onStep : function performing the value change (clamp/wrap lives here)
-------------------------------------------------------------------------------
function _G.stepButton(t)
    local sound, onStep = t.sound, t.onStep
    local function doStep()
        onStep()
        playUISound(sound)
    end
    return clickable {
        position = t.position,
        cursor = t.cursor,
        onMouseDown = function()
            doStep();
            return true
        end,
        onMouseHold = t.repeating and holdToRepeat(doStep) or nil
    }
end
