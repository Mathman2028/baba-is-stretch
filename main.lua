require "units"
require "constants"
require "rules"
require "undo"
require "utils"
require "movement"
require "saving"
require "conditions"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 16)
    love.window.setMode(864, 664, {resizable = true})
    tilename = "baba"
    prevtiles = {"text_is", "text_you", "text_win"}
    editor = true
    palette = love.image.newImageData("Palettes/default.png")
    dir = 0
    outlines = false
    clearlevel("Level title", 20, 20)
end

function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text)
	local font       = love.graphics.getFont()
	local textWidth  = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print(text, rectX+rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
end

function love.draw()
    local x, y, w, h = love.window.getSafeArea()
    tilesize = math.min((w-64) / leveldata.width, (h-64) / leveldata.height)
    xoffset = (w - tilesize * leveldata.width) / 2
    yoffset = (h - tilesize * leveldata.height) / 2
    love.graphics.setColor(1, 1, 1, 1)
    drawCenteredText(x, y, w, 32, leveldata.title)
    for id, unit in pairs(units) do
        local image
        if directionality[unit.name] then
            image = love.graphics.newImage("Sprites/" .. unit.name .. "_" .. unit.dir .. ".png")
        else
            image = love.graphics.newImage("Sprites/" .. unit.name .. ".png")
        end
        love.graphics.setColor(palette:getPixel(colors[unit.name][1], colors[unit.name][2]))
        love.graphics.draw(image, xoffset + unit.x * tilesize, yoffset + unit.y * tilesize, 0, tilesize * unit.xsize / image:getWidth(), tilesize * unit.ysize / image:getHeight())
        if outlines then
            local r, g, b, a = palette:getPixel(colors[unit.name][1], colors[unit.name][2])
            love.graphics.setColor(r, g, b, a/2)
            love.graphics.rectangle("line", xoffset + unit.x * tilesize, yoffset + unit.y * tilesize, tilesize * unit.xsize, tilesize * unit.ysize)
        end
    end

    if editor then
        local image
        if directionality[tilename] then
            image = love.graphics.newImage("Sprites/" .. tilename .. "_" .. dir .. ".png")
        else
            image = love.graphics.newImage("Sprites/" .. tilename .. ".png")
        end
        love.graphics.setColor(palette:getPixel(colors[tilename][1], colors[tilename][2]))
        love.graphics.draw(image, x + w - image:getWidth() * 2, y, 0, 2)
        local r, g, b, a = palette:getPixel(colors[tilename][1], colors[tilename][2])
        love.graphics.setColor(r, g, b, a/2)
        love.graphics.rectangle("line", x + w - image:getWidth() * 2, y, image:getWidth() * 2, image:getHeight() * 2)
        local imgy = y + 32
        for i, v in ipairs(prevtiles) do
            if directionality[v] then
                image = love.graphics.newImage("Sprites/" .. v .. "_" .. dir .. ".png")
            else
                image = love.graphics.newImage("Sprites/" .. v .. ".png")
            end
            love.graphics.setColor(palette:getPixel(colors[v][1], colors[v][2]))
            love.graphics.draw(image, x + w - image:getWidth() * 2, imgy, 0, 2)
            imgy = imgy + 32
        end
        if mousedown == 1 then
            if directionality[tilename] then
                image = love.graphics.newImage("Sprites/" .. tilename .. "_" .. dir .. ".png")
            else
                image = love.graphics.newImage("Sprites/" .. tilename .. ".png")
            end
            love.graphics.setColor(palette:getPixel(colors[tilename][1], colors[tilename][2]))
            love.graphics.draw(image, xoffset + math.min(selectx, finalx) * tilesize, yoffset + math.min(selecty, finaly) * tilesize, 0, (math.max(selectx, finalx) - math.min(selectx, finalx) + 1) * tilesize / image:getWidth(), (math.max(selecty, finaly) - math.min(selecty, finaly) + 1) * tilesize / image:getHeight())
            if outlines then
                local r, g, b, a = palette:getPixel(colors[tilename][1], colors[tilename][2])
                love.graphics.setColor(r, g, b, a/2)
                love.graphics.rectangle("line", xoffset + math.min(selectx, finalx) * tilesize, yoffset + math.min(selecty, finaly) * tilesize, (math.max(selectx, finalx) - math.min(selectx, finalx) + 1) * tilesize, (math.max(selecty, finaly) - math.min(selecty, finaly) + 1) * tilesize)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", xoffset, yoffset, leveldata.width * tilesize, leveldata.height * tilesize)

    if typing then
        love.graphics.setColor(0, 0, 0, 0.5)
        local width, height = love.graphics.getDimensions()
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(typed, 0, 0)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if keymapping[key] == "outlines" then
        outlines = not outlines
        return
    end
    if typing then
        if key == "backspace" then
            typed = typed:sub(1, -2)
        elseif key == "return" then
            typing = false
            if typingtype == "tileselect" then
                if objects[typed] or typetable[typed:sub(6)] then
                    table.insert(prevtiles, 1, tilename)
                    tilename = typed
                end
            elseif typingtype == "leveltitle" then
                leveldata.title = typed
            end
        elseif ({up = true, down = true, left = true, right = true})[key] then
            typed = typed .. key
        elseif key == "escape" then
            typing = false
        end
    else
        if keymapping[key] == "editor" then
            editor = not editor
            if editor then
                units = savedunits
            else
                savedunits = deepcopy(units)
            end
            return
        end
        if editor then
            if keymapping[key] == "swap" then
                if tilename:sub(1, 5) == "text_" then
                    if objects[tilename:sub(6, -1)] then
                        tilename = tilename:sub(6, -1)
                    end
                else
                    tilename = "text_" .. tilename
                end
            elseif keymapping[key] == "right" then
                dir = 0
            elseif keymapping[key] == "up" then
                dir = 1
            elseif keymapping[key] == "left" then
                dir = 2
            elseif keymapping[key] == "down" then
                dir = 3
            elseif keymapping[key] == "load" then
                local code = love.system.getClipboardText()
                if code ~= "" then
                    loadlevel(code)
                end
            elseif keymapping[key] == "save" then
                local code = savelevel()
                love.system.setClipboardText(code)
            end
            return
        end
        if key == "tab" then
            for i, v in ipairs(rules) do
                print(v.target .. " " .. v.verb .. " " .. v.action)
            end
        end
        if not keymapping[key] then return end
        if keymapping[key] == "undo" then
            undo()
            return
        end
        turn(keymapping[key])
    end
end

function love.textinput(text)
    if not typing then return end
    if typingtype == "tileselect" and text == "$" then
        typed = typed .. "text_"
        return
    end
    typed = typed .. text
end

function clearlevel(title, width, height)
    units = {}
    leveldata = {width = width, height = height, title = title, subtitle = "", author = "", palette = "default", music = "", particle = "", userdata = ""}
    rules = {}
    ruleindex = {}
    undos = {}
end

function love.mousepressed(x, y, button, istouch, presses)
    if editor then
        local xstart, ystart, w, h = love.window.getSafeArea()
        if x > xstart + w - 32 and x < xstart + w then
            if y < 32 then
                typing = true
                typingtype = "tileselect"
                typed = ""
                return
            else
                local index = math.floor(y / 32)
                table.insert(prevtiles, 1, tilename)
                tilename = table.remove(prevtiles, index + 1)
            end
        elseif y < 32 then
            typing = true
            typingtype = "leveltitle"
            typed = ""
            return
        end
        selectx = math.floor((x - xoffset) / tilesize)
        selecty = math.floor((y - yoffset) / tilesize)
        if selectx < 0 then return end
        if selectx >= leveldata.width then return end
        if selecty < 0 then return end
        if selecty >= leveldata.height then return end
        mousedown = button
        if button == 1 then
        elseif button == 2 then
            for i, v in pairs(units) do
                if v.x <= selectx and v.y <= selecty and v.x + v.xsize > selectx and v.y + v.ysize > selecty then
                    v:destroy(true)
                end
            end
        elseif button == 3 then
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if xoffset == nil then return end
    finalx = math.floor((x - xoffset) / tilesize)
    finaly = math.floor((y - yoffset) / tilesize)
    if finalx < 0 then return end
    if finalx >= leveldata.width then return end
    if finaly < 0 then return end
    if finaly >= leveldata.height then return end
end

function love.mousereleased(x, y, button, istouch, presses)
    if not mousedown then return end
    if editor then
        if button == 1 then
            Unit:new(tilename, math.min(selectx, finalx), math.min(selecty, finaly), dir, math.max(selectx, finalx)-math.min(selectx, finalx)+1, math.max(selecty, finaly)-math.min(selecty, finaly)+1, nil, true)
            selectx = nil
            selecty = nil
        end
    end
    mousedown = nil
end

function turn(input)
    newundo()
    parse()
    movement(input)
    -- Transform
    -- Create
    -- Destroy
    local kill = {}
    for id, unit in pairs(units) do
        if unit:hasrule("is", "sink") then
            for  i, v in ipairs(unit:collisions()) do
                table.insert(kill, v)
                table.insert(kill, unit)
            end
        end
    end
    for i, v in ipairs(kill) do
        if units[v.id] == v then
            v:destroy()
        end
    end
    kill = {}
    for id, unit in pairs(units) do
        if unit:hasrule("is", "hot") then
            for i, v in ipairs(unit:collisions()) do
                if v:hasrule("is", "melt") then
                    table.insert(kill, v)
                end
            end
            if unit:hasrule("is", "melt") then
                table.insert(kill, unit)
            end
        end
    end
    for i, v in ipairs(kill) do
        if units[v.id] == v then
            v:destroy()
        end
    end
    kill = {}
    for id, unit in pairs(units) do
        if unit:hasrule("is", "defeat") then
            for i, v in ipairs(unit:collisions()) do
                if v:hasrule("is", "you") then
                    table.insert(kill, v)
                end
            end
            if unit:hasrule("is", "you") then
                table.insert(kill, unit)
            end
        end
    end
    for i, v in ipairs(kill) do
        if units[v.id] == v then
            v:destroy()
        end
    end
    kill = {}
    for id, unit in pairs(units) do
        if unit:hasrule("is", "win") then
            for i, v in ipairs(unit:collisions()) do
                if v:hasrule("is", "you") then
                    editor = true
                    units = savedunits
                end
            end
            if unit:hasrule("is", "you") then
                editor = true
                units = savedunits
            end
        end
    end
end