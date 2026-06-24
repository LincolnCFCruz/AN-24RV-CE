size = {530, 530}

-- define property table
defineProperty("map_subpanel", globalProperty("an-24/panels/map_subpanel"))

-- add map textures
-- SASL3: maps live in modules/images/maps (SASL2 used panelDir.."/maps")
local mapsDir = moduleDirectory .. "/images/maps"
if isFileExists(mapsDir .. "/map_1.png") == true then
    defineProperty("map_1", sasl.gl.loadImage(mapsDir .. "/map_1.png"))
end
if isFileExists(mapsDir .. "/map_2.png") == true then
    defineProperty("map_2", sasl.gl.loadImage(mapsDir .. "/map_2.png"))
end
if isFileExists(mapsDir .. "/map_3.png") == true then
    defineProperty("map_3", sasl.gl.loadImage(mapsDir .. "/map_3.png"))
end
if isFileExists(mapsDir .. "/map_4.png") == true then
    defineProperty("map_4", sasl.gl.loadImage(mapsDir .. "/map_4.png"))
end
if isFileExists(mapsDir .. "/map_5.png") == true then
    defineProperty("map_5", sasl.gl.loadImage(mapsDir .. "/map_5.png"))
end
-- texture table
defineProperty("num_1", sasl.gl.loadImage("map_cover_e.dds", 379, 492, 32, 13))
defineProperty("num_2", sasl.gl.loadImage("map_cover_e.dds", 379, 473, 32, 13))
defineProperty("num_3", sasl.gl.loadImage("map_cover_e.dds", 379, 453, 32, 13))
defineProperty("num_4", sasl.gl.loadImage("map_cover_e.dds", 379, 433, 32, 13))
defineProperty("num_5", sasl.gl.loadImage("map_cover_e.dds", 379, 413, 32, 13))
defineProperty("size_025", sasl.gl.loadImage("map_cover_e.dds", 379, 392, 32, 13))
defineProperty("size_05", sasl.gl.loadImage("map_cover_e.dds", 379, 374, 32, 13))
defineProperty("size_1", sasl.gl.loadImage("map_cover_e.dds", 379, 355, 32, 13))
defineProperty("size_2", sasl.gl.loadImage("map_cover_e.dds", 379, 335, 32, 13))
defineProperty("size_4", sasl.gl.loadImage("map_cover_e.dds", 379, 314, 32, 13))

local num = {num_1, num_2, num_3, num_4, num_5}
local map_size = {size_025, size_05, size_1, size_2, size_4}
local size_num = 3

-- calculate map sizes
local w = {1, 1, 1, 1, 1}
local h = {1, 1, 1, 1, 1}

local maps = {map_1, map_2, map_3, map_4, map_5}

for i = 1, 5, 1 do
    if get(maps[i]) then
        w[i], h[i] = getTextureSize(get(maps[i]))
    end
end

local click_X = 0 -- place where mouse was clicked
local click_Y = 0

local move_X = 0 -- places ower mouse was moved
local move_Y = 0

local drag = false -- indicator of drag

local winWidth -- relative to map's size width of window
local winHeight -- relative to map's size height of window

local curent_map = 1 -- counter for switch maps
local scale = 1 -- zoom of map.

local X_scroll = 0 -- variables for scroll the map
local Y_scroll = 0

local X = 0
local Y = 0

function update()
    -- calculate window sizes
    winWidth = (512) / w[curent_map] / scale
    winHeight = (512) / h[curent_map] / scale

    -- calculate map movement
    X = move_X - click_X
    Y = move_Y - click_Y

    X_scroll = X_scroll - X / 100 * winWidth
    Y_scroll = Y_scroll + Y / 100 * winHeight

    click_X = move_X
    click_Y = move_Y

    if X_scroll > 1 - winWidth then
        X_scroll = 1 - winWidth
    end
    if X_scroll < 0 then
        X_scroll = 0
    end

    if Y_scroll > 1 - winHeight then
        Y_scroll = 1 - winHeight
    end
    if Y_scroll < 0 then
        Y_scroll = 0
    end

    -- recalculate size num
    if scale == 0.25 then
        size_num = 1
    elseif scale == 0.5 then
        size_num = 2
    elseif scale == 1 then
        size_num = 3
    elseif scale == 2 then
        size_num = 4
    else
        size_num = 5
    end

end

-- map table consist of several components
components = {
    rectangle {
        position = {0, 0, size[1], size[2]},
        color = {0, 0, 0, 0.5}
    }, 
    
    -- show the map
    tapeLit {
        position = {0, 40, 530, 490},
        image = function()
            return get(maps[curent_map])
        end,
        window = function()
            local a = {winWidth, winHeight}
            return a
        end,
        scrollX = function()
            return X_scroll
        end,
        scrollY = function()
            return Y_scroll
        end

    }, 
    
    -- cover texture
    textureLit {
        image = langImage("map_cover", 0, 147, 350, 365),
        position = {-5, -5, 540, 540}
    }, 
    
    -- number of map texture
    textureLit {
        position = {180, 10, 50, 20},
        image = function()
            return get(num[curent_map])
        end

    }, 
    
    -- scale number texture
    textureLit {
        position = {403, 10, 50, 20},
        image = function()
            return get(map_size[size_num])
        end
    }, 
    
    -- clickables for change map
    clickable {
        position = {130, 0, 50, 40},
        cursor = Cursors.HAND,
        onMouseDown = function()
            curent_map = curent_map - 1
            if curent_map < 1 then
                curent_map = 5
            end
            scale = 1
            return true
        end
    }, 
    
    clickable {
        position = {200, 0, 50, 40},
        cursor = Cursors.HAND,
        onMouseDown = function()
            curent_map = curent_map + 1
            if curent_map > 5 then
                curent_map = 1
            end
            scale = 1
            return true
        end
    }, 
    
    -- clickables for change map's scale
    clickable {
        position = {365, 0, 50, 40},
        cursor = Cursors.HAND,
        onMouseDown = function()
            scale = scale / 2
            if scale < 0.25 then
                scale = 0.25
            end
            -- X_Scroll = X_scroll - winWidth / 2
            -- Y_scroll = Y_scroll - winHeight / 2
            return true
        end
    }, 
    
    clickable {
        position = {435, 0, 50, 40},
        cursor = Cursors.HAND,
        onMouseDown = function()
            scale = scale * 2
            if scale > 4 then
                scale = 4
            end
            return true
        end
    }, 
    
    -- clickable area for map moving
    clickable {
        position = {0, 40, 530, 490},
        cursor = Cursors.FOUR_ARROWS,
        onMouseDown = function(comp, x, y)
            if not drag then
                click_X = x
                click_Y = y
                move_X = x
                move_Y = y
                drag = true
            end
            return true
        end,
        onMouseMove = function(comp, x, y)
            if drag then
                move_X = x
                move_Y = y
            end
            return true
        end,
        onMouseUp = function()
            drag = false
            click_X = 0
            click_Y = 0
            move_X = 0
            move_Y = 0
            return true
        end
    }
}
