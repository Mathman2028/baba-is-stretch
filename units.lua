Unit = {}
function Unit:new(name, x, y, dir, xsize, ysize, id, noundo)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.name = name
    o.x = x
    o.y = y
    o.xsize = xsize or 1
    o.ysize = ysize or 1
    o.dir = dir
    o.id = id or #units + 1
    units[o.id] = o
    if not noundo then
        addundo({type = "create", id = o.id})
    end
    return o
end

function Unit:collide(other, x, y, ignorefloat)
    local x = x or self.x
    local y = y or self.y
    return x < other.x + other.xsize and x + self.xsize > other.x and y < other.y + other.ysize and y + self.ysize > other.y and (ignorefloat or other:hasrule("is", "float") == self:hasrule("is", "float"))
end

function Unit:collisions(x, y, ignorefloat)
    local collisions = {}
    for id, unit in pairs(units) do
        if id ~= self.id and self:collide(unit, x, y, ignorefloat) then
            table.insert(collisions, unit)
        end
    end
    return collisions
end

function Unit:move(ox, oy)
    triedtomove[self.id] = true
    local newx = self.x + ox
    local newy = self.y + oy
    if newx < 0 or newx + self.xsize > leveldata.width or newy < 0 or newy + self.ysize > leveldata.height then return false end
    for i, unit in ipairs(self:collisions(newx, newy, true)) do
        if not triedtomove[unit.id] then
            local stopped = false
            if unit:hasrule("is", "push") then
                stopped = not unit:canmove(ox, oy)
            elseif unit:hasrule("is", "stop") or unit:hasrule("is", "pull") then
                stopped = true
            end
            if stopped and (self:hasrule("is", "open") and unit:hasrule("is", "shut")) or (self:hasrule("is", "shut") and unit:hasrule("is", "open")) then
                stopped = false
            end
            if stopped then return false end
        end
    end
    
    local willdie = {}
    for i, unit in ipairs(self:collisions(newx, newy, true)) do
        if not triedtomove[unit.id] then
            local stopped = false
            if unit:hasrule("is", "push") then
                stopped = not unit:move(ox, oy)
            elseif unit:hasrule("is", "stop") or unit:hasrule("is", "pull") then
                stopped = true
            end
            if stopped and (self:hasrule("is", "open") and unit:hasrule("is", "shut")) or (self:hasrule("is", "shut") and unit:hasrule("is", "open")) then
                table.insert(willdie, self)
                table.insert(willdie, unit)
                stopped = false
            end
            if stopped then return false end
        end
    end
    for i, unit in ipairs(self:collisions(nil, nil, true)) do
        if not triedtomove[unit.id] then
            local stopped = false
            if unit:hasrule("is", "bind") then
                stopped = not unit:move(ox, oy)
            end
            if stopped then return false end
        end
    end
    local returntrue = false
    for i, unit in ipairs(willdie) do
        returntrue = true
        if units[unit.id] == unit then
            unit:destroy()
        end
    end
    if returntrue then return true end
    local movedir
    if ox > 0 then movedir = "right" end
    if ox < 0 then movedir = "left" end
    if oy > 0 then movedir = "down" end
    if oy < 0 then movedir = "up" end
    if not moved[movedir][self.id] then
        addundo({type = "move", x = self.x, y = self.y, id = self.id})
        self.x = newx
        self.y = newy
        moved[movedir][self.id] = true
        for i, unit in ipairs(self:collisions(newx-2*ox, newy-2*oy, true)) do
            if not triedtomove[unit.id] then
                local stopped = false
                if unit:hasrule("is", "pull") then
                    unit:move(ox, oy)
                end
            end
        end
    end
    return true
end

function Unit:canmove(ox, oy)
    triedtocanmove[self.id] = true
    local newx = self.x + ox
    local newy = self.y + oy
    if newx < 0 or newx + self.xsize > leveldata.width or newy < 0 or newy + self.ysize > leveldata.height then return false end
    for i, unit in ipairs(self:collisions(newx, newy, true)) do
        if not triedtocanmove[unit.id] then
            local stopped = false
            if unit:hasrule("is", "push") then
                stopped = not unit:canmove(ox, oy)
            elseif unit:hasrule("is", "stop") then
                stopped = true
            end
            if stopped and (self:hasrule("is", "open") and unit:hasrule("is", "shut")) or (self:hasrule("is", "shut") and unit:hasrule("is", "open")) then
                stopped = false
            end
            if stopped then return false end
        end
    end
    for i, unit in ipairs(self:collisions(nil, nil, true)) do
        if not triedtocanmove[unit.id] then
            local stopped = false
            if unit:hasrule("is", "bind") then
                stopped = not unit:canmove(ox, oy)
            end
            if stopped then return false end
        end
    end
    return true
end

function Unit:stretch(ox, oy, altanchor)
    if self.xsize + ox <= 0 or self.ysize + oy <= 0 then
        self:destroy()
        return
    end
    if altanchor then
        addundo({type = "move", id = self.id, x = self.x, y = self.y})
        self.x = self.x - ox
        self.y = self.y - oy
    end
    addundo({type = "sizechange", id = self.id, xsize = self.xsize, ysize = self.ysize})
    self.xsize = self.xsize + ox
    self.ysize = self.ysize + oy
end

function Unit:hasrule(verb, action)
    for i, v in ipairs(ruleindex[action] or {}) do
        if (v.target == self.name or v.target == "text" and self.name:sub(1, 5) == "text_") or (v.target:sub(1, 4) == "not " and self.name:sub(1, 5) ~= "text_" and v.target:sub(5, -1) ~= self.name) and v.verb == verb and not self:hasrule(verb, "not " .. action) then
            local condspass = true
            for i2, v2 in ipairs(v.conds) do
                if v2[1]:sub(0, 4) == "not " then
                    if conds[v2[1]:sub(5, -1)](self, v2[2]) then
                        condspass = false
                        break
                    end
                else
                    if not conds[v2[1]](self, v2[2]) then
                        condspass = false
                        break
                    end
                end
            end
            return condspass
        end
    end
    return false
end

function Unit:rulecount(verb, action)
    local count = 0
    for i, v in ipairs(ruleindex[action] or {}) do
        if (v.target == self.name or v.target == "text" and self.name:sub(1, 5) == "text_") or (v.target:sub(1, 4) == "not " and self.name:sub(1, 5) ~= "text_" and v.target:sub(5, -1) ~= self.name) and v.verb == verb and not self:hasrule(verb, "not " .. action) then
            local condspass = true
            for i2, v2 in ipairs(v.conds) do
                if v2[1]:sub(0, 4) == "not " then
                    if conds[v2[1]:sub(5, -1)](self, v2[2]) then
                        condspass = false
                        break
                    end
                else
                    if not conds[v2[1]](self, v2[2]) then
                        condspass = false
                        break
                    end
                end
            end
            if condspass then
                count = count + 1
            end
        end
    end
    return count
end

function Unit:destroy(noundo)
    if not noundo then
        addundo({type = "destroy", name = self.name, x = self.x, y = self.y, dir = self.dir, xsize = self.xsize, ysize = self.ysize, id = self.id})
    end
    units[self.id] = nil
end

function Unit:rotate(dir, noundo)
    if not noundo then
        addundo({type = "rotate", dir = self.dir, id = self.id})
    end
    self.dir = dir
end