size = {256, 240}

-- define property table
defineProperty("camera_subpanel", globalProperty("an-24/panels/camera_subpanel"))
-- points of view: 0-captain 1-copilot 2-eng 3-navigator 4-overhead 5-passanger left to landing gear

defineProperty("swview", globalProperty("an-24/view/switch_view"))

local bg = langImages("camera", nil, nil, nil, nil, ".png")

components = { 
    ----------------
    -- clickables --
    ----------------

    -- Captain view
    clickable {
        position = {0, 120, 110, 60}, -- search and set right
        cursor = Cursors.HAND,
        onMouseDown = function()
            if get(swview) == 10 then
                set(swview, 0)
            else
                set(swview, 10)
            end
            return true
        end
    }, 
    
    -- copilot view
    clickable {
        position = {145, 120, 110, 60}, -- search and set right
        cursor = Cursors.HAND,
        onMouseDown = function()
            if get(swview) == 11 then
                set(swview, 1)
            else
                set(swview, 11)
            end
            return true
        end
    }, 
    
    -- RUD view
    clickable {
        position = {100, 40, 50, 70}, -- search and set right
        cursor = Cursors.HAND,
        onMouseDown = function()
            if get(swview) == 12 then
                set(swview, 2)
            else
                set(swview, 12)
            end
            return true
        end
    }, 
    
    -- navigator view
    clickable {
        position = {0, 25, 70, 85}, -- search and set right
        cursor = Cursors.HAND,
        onMouseDown = function()
            if get(swview) == 13 then
                set(swview, 3)
            else
                set(swview, 13)
            end
            return true
        end

    }, 
    
    -- overhead view
    clickable {
        position = {40, 190, 170, 40}, -- search and set right
        cursor = Cursors.HAND,
        onMouseDown = function()
            if get(swview) == 14 then
                set(swview, 4)
            else
                set(swview, 14)
            end
            return true
        end
    }, 
    
    -- pax 1 view
    clickable {
        position = {165, 25, 40, 85}, -- search and set right
        cursor = Cursors.HAND,
        onMouseDown = function()
            if get(swview) == 15 then
                set(swview, 5)
            else
                set(swview, 15)
            end
            return true
        end
    }, 
    
    -- pax 2 view
    clickable {
        position = {215, 25, 40, 85}, -- search and set right
        cursor = Cursors.HAND,
        onMouseDown = function()
            if get(swview) == 16 then
                set(swview, 6)
            else
                set(swview, 16)
            end
            return true
        end
    }
}

function draw()
    drawLangBackground(bg, size[1], size[2])
end
