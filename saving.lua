function savelevel()
    local rawstring = leveldata.width .. "," .. leveldata.height .. "\n" .. leveldata.title .. "," .. leveldata.subtitle .. "," .. leveldata.author .. "\n" .. leveldata.palette .. "," .. leveldata.music .. "," .. leveldata.particle .. "\n" .. leveldata.userdata
    for i, v in pairs(units) do
        rawstring = rawstring .. "\n" .. v.id .. "," .. v.name .."," .. v.x .. "," .. v.y .. "," .. v.dir .. "," .. v.xsize .. "," .. v.ysize
    end
    return love.data.encode("string", "base64", love.data.compress("string", "zlib", rawstring))
end

function loadlevel(data)
    local rawstring = love.data.decompress("string", "zlib", love.data.decode("string", "base64", data))
    local linesplit = split(rawstring, "\n")
    local width, height = unpack(split(table.remove(linesplit, 1), ","))
    width = tonumber(width)
    height = tonumber(height)
    local title, subtitle, author = unpack(split(table.remove(linesplit, 1), ","))
    local palette, music, particle = unpack(split(table.remove(linesplit, 1), ","))
    local userdata = table.remove(linesplit, 1)
    clearlevel(title, width, height)
    leveldata.subtitle = subtitle
    leveldata.author = author
    leveldata.palette = palette
    leveldata.music = music
    leveldata.particle = particle
    leveldata.userdata = userdata
    for i, v in ipairs(linesplit) do
        local id, name, x, y, dir, xsize, ysize = unpack(split(v, ","))
        x = tonumber(x)
        y = tonumber(y)
        Unit:new(name, x, y, dir, xsize, ysize, id, true)
    end
end