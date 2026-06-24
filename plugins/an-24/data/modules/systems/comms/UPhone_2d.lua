size = {241, 446}

defineProperty("bg", sasl.gl.loadImage("UPhone.dds", 0, 66, 241, 446))
defineProperty("APPS", sasl.gl.loadImage("UPhone.dds", 260, 207, 205, 305))
defineProperty("digitsImage", sasl.gl.loadImage("UPhone.dds", 493, 232, 14, 280))

program = 0

-- Define commands
defineProperty("uphone_subpanel", globalProperty("an-24/panels/uphone_subpanel"))

components = {
    textureLit {
        position = {0, 0, 240, 444},
        image = get(bg),
        visible = true
    }, 
    
    -- menu button
    clickable {
        position = {71, 19, 99, 40},

        cursor = Cursors.HAND,

        onMouseDown = function()
            program = 0
            return true
        end
    }, 
    
    -- APPS screen
    textureLit {
        position = {20, 68, 205, 305},
        image = get(APPS),
        visible = function()
            return program == 0
        end
    }, 
    
    clickable {
        position = {30, 300, 25, 25},
        cursor = Cursors.HAND,
        visible = function()
            return program == 0
        end,
        onMouseDown = function()
            program = 1
        end
    }, 
    
    UHUD_2d {
        position = {20, 68, 205, 305},
        visible = function()
            return program == 1
        end
    }, 
    
    clickable {
        position = {65, 300, 25, 25},
        cursor = Cursors.HAND,
        visible = function()
            return program == 0
        end,
        onMouseDown = function()
            program = 2
        end
    }, 
    
    UConvert_2d {
        position = {20, 68, 205, 305},
        visible = function()
            return program == 2
        end
    }, 
    
    clickable {
        position = {100, 300, 25, 25},
        cursor = Cursors.HAND,
        visible = function()
            return program == 0
        end,
        onMouseDown = function()
            program = 3
        end
    }, 
    
    UTurn_2d {
        position = {20, 68, 205, 305},
        visible = function()
            return program == 3
        end
    }, 
    
    clickable {
        position = {135, 300, 25, 25},
        cursor = Cursors.HAND,
        visible = function()
            return program == 0
        end,
        onMouseDown = function()
            program = 4
        end
    }, 
    
    UMETAR_2d {
        position = {20, 68, 205, 305},
        visible = function()
            return program == 4
        end
    }
}
