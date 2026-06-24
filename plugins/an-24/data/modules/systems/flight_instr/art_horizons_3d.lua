-- Attitude indicators (AGD-left / AGD-right / AGB-third) 3D-panel RENDER only.
-- All compute (attitude error model, arresting, fail/roll/check lamp logic, cold-start init,
-- command handlers, SmartCopilot) lives in art_horizons_logic.lua (registered immediately
-- before this in main.lua). It publishes the attitude datarefs (ag1/2/3_pitch/roll, *_pitch_rot)
-- and the lamp seam datarefs (an-24/gauges/ind_*). This module renders them + the clickables.
size = {2048, 2048}

-- images
defineProperty("tapeImage", sasl.gl.loadImage("ag_tape.dds", 0, 0, 256, 1024))
defineProperty("planeImage", langImage("needles", 73, 228, 121, 27))
defineProperty("flagImage", langImage("needles", 85, 198, 58, 22))
defineProperty("triangle", sasl.gl.loadImage("triangle.png", 0, 0, 8, 8))
defineProperty("red_led", loadLED("red"))
defineProperty("green_led", loadLED("green"))
defineProperty("planka", sasl.gl.loadImage("ag_tape.dds", 0, 668, 10, 200))

-- attitude datarefs (read-only; written by art_horizons_logic.lua)
defineProperty("ag1_pitch", globalProperty("an-24/misc/ag1_pitch"))
defineProperty("ag2_pitch", globalProperty("an-24/misc/ag2_pitch"))
defineProperty("ag3_pitch", globalProperty("an-24/misc/ag3_pitch"))
defineProperty("ag3_roll", globalProperty("an-24/misc/ag3_roll"))
defineProperty("ag1_pitch_rot", globalProperty("an-24/misc/ag1_pitch_rot"))
defineProperty("ag2_pitch_rot", globalProperty("an-24/misc/ag2_pitch_rot"))
defineProperty("ag3_pitch_rot", globalProperty("an-24/misc/ag3_pitch_rot"))

-- lamp/flag seam datarefs (read-only)
defineProperty("ind_ahz_left_fail", globalProperty("an-24/gauges/ind_ahz_left_fail"))
defineProperty("ind_ahz_right_fail", globalProperty("an-24/gauges/ind_ahz_right_fail"))
defineProperty("ind_ahz_third_fail", globalProperty("an-24/gauges/ind_ahz_third_fail"))
defineProperty("ind_roll_left_big", globalProperty("an-24/gauges/ind_roll_left_big"))
defineProperty("ind_roll_right_big", globalProperty("an-24/gauges/ind_roll_right_big"))
defineProperty("ind_check_ahz", globalProperty("an-24/gauges/ind_check_ahz"))
defineProperty("ind_check_bkk", globalProperty("an-24/gauges/ind_check_bkk"))
defineProperty("ind_power27", globalProperty("an-24/gauges/ind_power27"))

-- input datarefs (clickables write these; logic reads them)
defineProperty("left_agd_arrest", globalProperty("an-24/set/left_agd_arrest"))
defineProperty("right_agd_arrest", globalProperty("an-24/set/right_agd_arrest"))
defineProperty("arrest_third", globalProperty("an-24/set/arrest_third"))
defineProperty("AGD_right", globalProperty("an-24/gauges/AGD_right"))
defineProperty("bkk_check_sw", globalProperty("an-24/gauges/bkk_check_sw"))
defineProperty("bkk_check_sw_cap", globalProperty("an-24/gauges/bkk_check_sw_cap"))
defineProperty("ahz_start_right", globalProperty("an-24/gauges/ahz_start_right")) -- stamped by AGD-right switch
defineProperty("sim_time", globalProperty("sim/time/total_running_time_sec"))

local switch_sound = loadSample('sounds/custom/metal_switch.wav')
local cap_sound = loadSample('sounds/custom/cap.wav')
local btn_click = loadSample('sounds/custom/plastic_btn.wav')
local rot_click = loadSample('sounds/custom/rot_click.wav')

-- height of visible window area
local winHeight = 130 / 512
-- height of one degree in texture coordinates
local pitch_deg = 2.0 / 512
local pitch_rot_left = 0
local pitch_rot_right = 0
local pitch_rot_third = 0
local arrest_push_third = false

components = { 
  -- left AGD

  -- attitude tape
  tape {
      id = "agd-left-tape",
      position = {1229, 1874, 145, 148},
      image = get(tapeImage),
      window = {1.0, winHeight},
      -- calculate pitch level
      scrollY = function()
          return (0.5 - winHeight / 2) - pitch_deg * (get(ag1_pitch) + get(ag1_pitch_rot))
      end
  }, 
  
  -- arrest button (momentary)
  momentaryButton {
      position = {1368, 2015, 30, 30},
      drf = left_agd_arrest
  }, 
  
  -- pitch rotary (-12..12, auto-repeats)
  stepButton {
      position = {1202, 1850, 15, 30},
      cursor = Cursors.ROTATE_LEFT,
      repeating = true,
      onStep = function()
          pitch_rot_left = get(ag1_pitch_rot) - 1
          if pitch_rot_left < -12 then
              pitch_rot_left = -12
          end
          set(ag1_pitch_rot, pitch_rot_left)
      end
  }, 
  
  stepButton {
      position = {1217, 1850, 15, 30},
      cursor = Cursors.ROTATE_RIGHT,
      repeating = true,
      onStep = function()
          pitch_rot_left = get(ag1_pitch_rot) + 1
          if pitch_rot_left > 12 then
              pitch_rot_left = 12
          end
          set(ag1_pitch_rot, pitch_rot_left)
      end
  }, 
  
  -- rotary indicator
  rectangle {
      id = "agd-left-rot-indicator-bg",
      position = {1208, 1887.5, 9, 20},
      color = {0, 0, 0, 1}
  }, 
  
  free_texture {
      id = "agd-left-rot-indicator",
      image = get(triangle),
      position_x = 1210,
      position_y = function()
          return 1894 - get(ag1_pitch_rot) * 0.7
      end,
      width = 6,
      height = 6
  }, 
  
  -- fail indicator
  textureLit {
      id = "agd-left-fail-led",
      position = {1369, 1849, 30, 30},
      image = get(red_led),
      visible = function()
          return get(ind_ahz_left_fail) == 1
      end
  }, 
  
  ---------------------------------------
  
  -- right AGD
  
  -- attitude tape
  tape {
      id = "agd-right-tape",
      position = {1629, 1874, 145, 148},
      image = get(tapeImage),
      window = {1.0, winHeight},

      -- calculate pitch level
      scrollY = function()
          return (0.5 - winHeight / 2) - pitch_deg * (get(ag2_pitch) + get(ag2_pitch_rot));
      end
  }, 
  
  -- arrest button (momentary)
  momentaryButton {
      position = {1768, 2015, 30, 30},
      drf = right_agd_arrest
  }, 
  
  -- pitch rotary (-12..12, auto-repeats)
  stepButton {
      position = {1605, 1850, 15, 30},
      cursor = Cursors.ROTATE_LEFT,
      repeating = true,
      onStep = function()
          pitch_rot_right = get(ag2_pitch_rot) - 1
          if pitch_rot_right < -12 then
              pitch_rot_right = -12
          end
          set(ag2_pitch_rot, pitch_rot_right)
      end
  }, 
  
  stepButton {
      position = {1620, 1850, 15, 30},
      cursor = Cursors.ROTATE_RIGHT,
      repeating = true,
      onStep = function()
          pitch_rot_right = get(ag2_pitch_rot) + 1
          if pitch_rot_right > 12 then
              pitch_rot_right = 12
          end
          set(ag2_pitch_rot, pitch_rot_right)
      end
  }, 
  
  -- rotary indicator
  rectangle {
      id = "agd-right-rot-indicator-bg",
      position = {1609, 1887.5, 9, 20},
      color = {0, 0, 0, 1}
  }, 
  
  free_texture {
      id = "agd-right-rot-indicator",
      image = get(triangle),
      position_x = 1611,
      position_y = function()
          return 1894 - get(ag2_pitch_rot) * 0.7
      end,
      width = 6,
      height = 6
  }, 
  
  -- fail indicator
  textureLit {
      id = "agd-right-fail-led",
      position = {1769, 1849, 30, 30},
      image = get(red_led),
      visible = function()
          return get(ind_ahz_right_fail) == 1
      end
  }, 
  
  -- switcher (turning it on stamps the spin-up start time)
  toggleSwitch {
      position = {825, 272, 15, 15},
      drf = AGD_right,
      sound = switch_sound,
      onToggle = function(nv)
          if nv ~= 0 then
              set(ahz_start_right, get(sim_time))
          end
      end
  }, 
  
  ---------------------------------
  
  -- third AGD
  
  -- attitude tape
  tape {
      id = "agb-third-tape",
      position = {1428, 1874, 145, 148},
      image = get(tapeImage),
      window = {1.0, winHeight / 1.3},

      -- calculate pitch level
      scrollY = function()
          return (0.5 - winHeight / 2 / 1.3) - pitch_deg * (get(ag3_pitch) + get(ag3_pitch_rot));
      end
  }, 
  
  -- plank
  rectangle {
      id = "agb-third-plank-bg",
      position = {1497, 1849, 7, 200},
      color = {0, 0, 0, 0.5}
  }, 
  
  -- plank
  texture {
      id = "agb-third-plank",
      position = {1498, 1849, 5, 200},
      image = get(planka)
  }, 
  
  -- aircraft image
  needle {
      id = "agb-third-plane",
      position = {1420, 1868, 160, 160},
      image = function()
          return get(planeImage)
      end,
      angle = function()
          return get(ag3_roll)
      end
  }, 
  
  -- arrest button
  clickable {
      id = "agb-third-arrest-btn",
      position = {1568, 2015, 30, 30},
      cursor = Cursors.HAND,
      onMouseDown = function(x, y, button)
          if not arrest_push_third then
              arrest_push_third = true
              set(arrest_third, 1)
          end
          return true
      end,
      onMouseUp = function(x, y, button)
          arrest_push_third = false
          set(arrest_third, 0)
          return true
      end
  }, 
  
  -- pitch rotary
  clickable {
      id = "agb-third-pitch-rot-dn",
      position = {1403, 1850, 15, 30},
      cursor = Cursors.ROTATE_LEFT,
      onMouseHold = holdToRepeat(),
      onMouseDown = function(x, y, button)
          pitch_rot_third = get(ag3_pitch_rot) - 1
          if pitch_rot_third < -12 then
              pitch_rot_third = -12
          end
          set(ag3_pitch_rot, pitch_rot_third)
          return true
      end
  }, 
  
  clickable {
      id = "agb-third-pitch-rot-up",
      position = {1417, 1850, 15, 30},
      cursor = Cursors.ROTATE_RIGHT,
      onMouseHold = holdToRepeat(),
      onMouseDown = function(x, y, button)
          pitch_rot_third = get(ag3_pitch_rot) + 1
          if pitch_rot_third > 12 then
              pitch_rot_third = 12
          end
          set(ag3_pitch_rot, pitch_rot_third)
          return true
      end
  }, 
  
  -- rotary indicator
  rectangle {
      id = "agb-third-rot-indicator-bg",
      position = {1409, 1887.5, 9, 20},
      color = {0, 0, 0, 1}
  }, 
  
  free_texture {
      id = "agb-third-rot-indicator",
      image = get(triangle),
      position_x = 1410,
      position_y = function()
          return 1894 - get(ag3_pitch_rot) * 0.7
      end,
      width = 6,
      height = 6
  }, 
  
  -- fail indicator
  texture {
      id = "agb-third-fail-flag",
      position = {1425, 1980, 70, 30},
      image = function()
          return get(flagImage)
      end,
      visible = function()
          return get(ind_ahz_third_fail) == 1 or get(ind_power27) == 0
      end
  }, 
  
  ----------------------
  -- lamps over panel --
  ----------------------
  
  -- fail indicator left
  textureLit {
      id = "lamp-fail-left",
      position = {1398, 518, 45, 27},
      image = langImage("lamps", 0, 98, 50, 30),
      visible = function()
          return get(ind_ahz_left_fail) == 1
      end
  }, 
  
  -- fail indicator third
  textureLit {
      id = "lamp-fail-third",
      position = {1455, 518, 43, 27},
      image = langImage("lamps", 50, 98, 50, 30),
      visible = function()
          return get(ind_ahz_third_fail) == 1
      end
  }, 
  
  -- fail indicator right
  textureLit {
      id = "lamp-fail-right",
      position = {1007, 484, 45, 27},
      image = langImage("lamps", 100, 98, 50, 30),
      visible = function()
          return get(ind_ahz_right_fail) == 1
      end
  }, 
  
  -- left roll indicator
  textureLit {
      id = "lamp-roll-left",
      position = {1062, 484, 45, 27},
      image = langImage("lamps", 150, 98, 50, 30),
      visible = function()
          return get(ind_roll_left_big) == 1
      end
  }, 
  
  -- right roll indicator
  textureLit {
      id = "lamp-roll-right",
      position = {1119, 484, 43, 27},
      image = langImage("lamps", 200, 98, 50, 30),
      visible = function()
          return get(ind_roll_right_big) == 1
      end
  }, 
  
  -- check ahz
  textureLit {
      id = "lamp-check-ahz",
      position = {1174, 484, 43, 27},
      image = langImage("lamps", 0, 68, 50, 30),
      visible = function()
          return get(ind_check_ahz) == 1
      end
  }, 
  
  -- bkk test cap
  switch {
      id = "bkk-test-cap",
      position = {0, 490, 33, 44},
      state = function()
          return get(bkk_check_sw_cap) ~= 0
      end,
      onMouseDown = function()
          if get(bkk_check_sw_cap) ~= 0 then
              set(bkk_check_sw_cap, 0)
              set(bkk_check_sw, 1)
          else
              set(bkk_check_sw_cap, 1)
          end
          return true;
      end
  }, 
  
  -- switch up
  clickable {
      id = "bkk-test-sw-up",
      position = {862, 374, 15, 7}, -- search and set right
      cursor = Cursors.HAND,
      onMouseDown = function()
          if get(bkk_check_sw_cap) == 1 then
              set(bkk_check_sw, 2)
          end
          return true
      end,
      onMouseUp = function()
          set(bkk_check_sw, 1)
          return true
      end
  }, 
  
  -- switch down
  clickable {
      id = "bkk-test-sw-dn",
      position = {862, 365, 15, 7}, -- search and set right
      cursor = Cursors.HAND,
      onMouseDown = function()
          if get(bkk_check_sw_cap) == 1 then
              set(bkk_check_sw, 0)
          end
          return true
      end,
      onMouseUp = function()
          set(bkk_check_sw, 1)
          return true
      end
  }, 
  
  -- check indicator
  textureLit {
      id = "bkk-check-led",
      position = {700, 428, 20, 20},
      image = get(green_led),
      visible = function()
          return get(ind_check_bkk) == 1
      end
  }
}
