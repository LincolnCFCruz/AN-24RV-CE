--[[

  File: start_lock_logic.lua
  -----
  Propeller low-pitch stop (start lock) — V11

  At low engine RPM (start, idle, cooldown) the oil pressure in the prop
  command channel drops below working level and XP12 may SPONTANEOUSLY
  feather the prop (assuming a governor failure), stalling the engine at
  ~30% RPM. The real An-24 has a mechanical low-pitch stop that holds the
  prop at low pitch under low oil pressure; this emulates it through the
  XP12 start_lock_engaged actuators:
    1 -> prop fixed at low pitch, cannot feather
    0 -> prop under normal governor control

  Logic:
    - on the ground / during start (N1 < 55%) -> lock engaged (protection)
    - normal operation (N1 >= 70%)            -> lock released
    - autofeather fired (feather lamp on)     -> lock released so the prop
      can actually go to feather

--]] 

-- Engine RPM:
defineProperty("sl_n1_left", globalProperty("sim/flightmodel/engine/ENGN_N1_[0]"))
defineProperty("sl_n1_right", globalProperty("sim/flightmodel/engine/ENGN_N1_[1]"))

-- Low-pitch stop control (XP12):
defineProperty("sl_lock_left", globalProperty("sim/cockpit2/engine/actuators/start_lock_engaged[0]"))
defineProperty("sl_lock_right", globalProperty("sim/cockpit2/engine/actuators/start_lock_engaged[1]"))

-- Autofeather lamps (when feathered, the lock must release):
defineProperty("sl_feather_lamp_left", globalProperty("an-24/prop/feather1_lamp"))
defineProperty("sl_feather_lamp_right", globalProperty("an-24/prop/feather2_lamp"))

-- RPM thresholds with hysteresis (prevents chatter around a single point):
local LOCK_ON_N1 = 55 -- % — below this the lock engages (feather protection)
local LOCK_OFF_N1 = 70 -- % — above this the lock releases (normal operation)

-- Hysteresis state — lock engaged by default (engine start)
local lock_state_left = true
local lock_state_right = true

local function process_engine(n1, lock_state, feathered)
    -- Prop is feathered (autofeather lamp) — release the lock so the prop
    -- can actually reach the feather position.
    if feathered then
        return false
    end

    if lock_state then
        -- Lock currently ENGAGED — release only at high RPM
        if n1 >= LOCK_OFF_N1 then
            return false
        end
        return true
    else
        -- Lock currently RELEASED — engage only at low RPM
        if n1 < LOCK_ON_N1 then
            return true
        end
        return false
    end
end

function update()
    -- Left engine
    local n1_l = get(sl_n1_left)
    local feathered_l = (get(sl_feather_lamp_left) == 1)
    lock_state_left = process_engine(n1_l, lock_state_left, feathered_l)
    set(sl_lock_left, lock_state_left and 1 or 0)

    -- Right engine
    local n1_r = get(sl_n1_right)
    local feathered_r = (get(sl_feather_lamp_right) == 1)
    lock_state_right = process_engine(n1_r, lock_state_right, feathered_r)
    set(sl_lock_right, lock_state_right and 1 or 0)
end
