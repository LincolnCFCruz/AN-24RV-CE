--[[

  File: glbl_sounds.lua
  -----
  Shared UI click-sound loader: centralises the five interaction-sound paths that
  were hand-loadSample'd across ~25 modules.

  loadUISounds() returns FRESH instances per call, NOT one shared table:
  loadSample() makes one OpenAL source per id and playSample() restarts that
  source, so a single shared id would truncate overlapping plays. Each module
  owning its own sources lets two panels ring the same click as independent
  voices -- a behaviour we must preserve.

  Usage:
    local snd = loadUISounds()  -- snd.switch / snd.cap / snd.btn / snd.rot / snd.plastic

--]]
local UI_SOUND_PATHS = {
    switch = 'sounds/custom/metal_switch.wav', -- metal toggle / tumbler
    cap = 'sounds/custom/cap.wav', -- guard cap open/close
    btn = 'sounds/custom/plastic_btn.wav', -- plastic push button
    rot = 'sounds/custom/rot_click.wav', -- rotary / knob detent
    plastic = 'sounds/custom/plastic_switch.wav' -- plastic toggle
}

-- Returns a fresh table of loaded samples: { switch, cap, btn, rot, plastic }.
function _G.loadUISounds()
    return {
        switch = loadSample(UI_SOUND_PATHS.switch),
        cap = loadSample(UI_SOUND_PATHS.cap),
        btn = loadSample(UI_SOUND_PATHS.btn),
        rot = loadSample(UI_SOUND_PATHS.rot),
        plastic = loadSample(UI_SOUND_PATHS.plastic)
    }
end

-- Play a one-shot UI sample (no-op if nil). Mirrors the hand-written
-- `sasl.al.playSample(s, false)` calls; used by the glbl_controls factories.
function _G.playUISound(sample)
    if sample then
        sasl.al.playSample(sample, false)
    end
end
