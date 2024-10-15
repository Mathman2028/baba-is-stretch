function newundo()
    table.insert(undos, {})
end

function addundo(data)
    table.insert(undos[#undos], 1, data)
end

function undo()
    if #undos == 0 then return end
    thisundo = undos[#undos]
    undos[#undos] = nil
    for i, undodata in ipairs(thisundo) do
        if undodata.type == "move" then
            local unit = units[undodata.id]
            if unit ~= nil then
                unit.x = undodata.x
                unit.y = undodata.y
            end
        elseif undodata.type == "create" then
            local unit = units[undodata.id]
            unit:destroy(true)
        elseif undodata.type == "destroy" then
            Unit:new(undodata.name, undodata.x, undodata.y, undodata.dir, undodata.xsize, undodata.ysize, undodata.id, true)
        elseif undodata.type == "rotate" then
            local unit = units[undodata.id]
            unit:rotate(undodata.dir, true)
        elseif undodata.type == "sizechange" then
            local unit = units[undodata.id]
            unit.xsize = undodata.xsize
            unit.ysize = undodata.ysize
        end
    end
end