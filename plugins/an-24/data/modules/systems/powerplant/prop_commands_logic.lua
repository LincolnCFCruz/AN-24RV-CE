--[[

  File: prop_commands.lua
  -----
  Propeller pitch stop commands for keyboard/joystick binding (V11)

  Commands for Settings -> Keyboard / Joystick to control the propeller
  low-pitch stop and its protective cap. The cockpit switch logic itself
  lives in prop_logic.lua; the an-24/prop/pitch_stop* datarefs are created
  in core/glbl_drfs.lua.

--]] 

defineProperty("pitch_stop", globalProperty("an-24/prop/pitch_stop")) -- 0=on the stop, 1=off the stop
defineProperty("pitch_stop_cap", globalProperty("an-24/prop/pitch_stop_cap")) -- 1=cap closed, 0=open

-- 1) An-24/Prop/pitch_stop_toggle — main command, honours the protective cap.
-- On the real An-24 the prop is either ON the low-pitch stop (before takeoff)
-- or OFF the stop (normal governor control after takeoff/climb). The switch
-- only works with the cap OPEN (pitch_stop_cap = 0) — the real two-step guard.
registerCommandHandler(createCommand("An-24/Prop/pitch_stop_toggle",
    "Propeller: toggle the low-pitch stop (requires open cap)."), 0, function(p)
    if p == 0 then
        if get(pitch_stop_cap) == 0 then
            set(pitch_stop, math.abs(1 - get(pitch_stop)))
        end
    end
    return 0
end)

-- 2) An-24/Prop/pitch_stop_cap_toggle — the red protective cap over the switch.
registerCommandHandler(createCommand("An-24/Prop/pitch_stop_cap_toggle",
    "Propeller: open/close the pitch stop protective cap."), 0, function(p)
    if p == 0 then
        set(pitch_stop_cap, math.abs(1 - get(pitch_stop_cap)))
    end
    return 0
end)

-- 3) An-24/Prop/pitch_stop_direct — direct toggle, ignores the cap.
-- Convenient single-button joystick binding.
registerCommandHandler(createCommand("An-24/Prop/pitch_stop_direct",
    "Propeller: toggle the low-pitch stop directly (no cap)."), 0, function(p)
    if p == 0 then
        set(pitch_stop, math.abs(1 - get(pitch_stop)))
    end
    return 0
end)
