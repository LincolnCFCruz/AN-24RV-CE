size = {30, 120}

-- property table
defineProperty("value", {0}) -- variable for changing

defineProperty("minimum", 0) -- minimum for variable, lower position of lever
defineProperty("maximum", 1) -- maximum for variable, higher position of lever

defineProperty("lever_count", 1)  -- count of levers to manipulate


-- images
defineProperty("back_img") -- background image
defineProperty("lever_img") -- lever image  

local Min = get(minimum)
local Max = get(maximum)
local Range = Max - Min  -- define range of used variable
local Count = get(lever_count)

local mouse_stat = false
local v = get(value)
local inverse = false
inverse = Max < Min

-- lever consist of several components
components = {
           
     -- movable lever image
    free_textureLit {
        image = get(lever_img),
        position_x = 0,
        position_y = function()
             local a = (get(v[1]) - Min) * 90 / Range
             if a > 90 then a = 90 end
             if a < 0 then a = 0 end
             return a - 10   
        end,
        width = 30,
        height = 30, 
    },
    
    -- clicable area for lever
    -- NOTE: mouse y below is normalized by 100 = this clickable's height in px;
    -- keep the literal 100s in sync if this position rect changes
    clickable {
       position = { 5, 0, 20, 100 },
        
       cursor = Cursors.UP_DOWN,
        
        -- SASL3: onMouseDown fires once per press (SASL2's repeating
        -- onMouseClick needed a was_click guard here; no longer required).
        -- Dragging is handled by onMouseMove while mouse_stat is true.
        onMouseDown = function(comp, x, y, button)
           mouse_stat = true
           if y < 0 then y = 0 elseif y > 100 then y = 100 end
		   local val = y / 100 * Range + Min
           for i = 1, Count, 1 do
              set(v[i], val)
           end
           return true
        end,

        onMouseUp = function(comp, x, y, button)
           mouse_stat = false
           return true
        end,
        
        onMouseMove = function(comp, x, y, button) 
           if y < 0 then y = 0 elseif y > 100 then y = 100 end
		   local val = y / 100 * Range + Min
		   if mouse_stat then 
              for i = 1, Count, 1 do  
                  set(v[i], val)
              end
           end
           return true 
        end,
    },

}
