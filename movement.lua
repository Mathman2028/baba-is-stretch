function newmovement()
    moved = {up = {}, down = {}, left = {}, right = {}}
    triedtomove = {}
    triedtocanmove = {}
end

function movement(input)
    newmovement()
    local inputdir = dirnames[input]
    if input ~= "idle" then
        for id, unit in pairs(units) do
            if unit:hasrule("is", "you") then
                unit:rotate(dirnames2[input])
                unit:move(inputdir[1], inputdir[2])
            end
        end
    end
    local anymovers = true
    local requirement = 1
    while anymovers do
        anymovers = false
        newmovement()
        for id, unit in pairs(units) do
            if unit:rulecount("is", "move") >= requirement then
                anymovers = true
                local success = unit:canmove(dirs[unit.dir+1][1], dirs[unit.dir+1][2])
                if success then
                    unit:move(dirs[unit.dir+1][1], dirs[unit.dir+1][2])
                else
                    unit:rotate((unit.dir + 2) % 4)
                    unit:move(dirs[unit.dir+1][1], dirs[unit.dir+1][2])
                end
            end
        end
        requirement = requirement + 1
    end
    anymovers = true
    requirement = 1
    while anymovers do
        anymovers = false
        newmovement()
        for id, unit in pairs(units) do
            if unit:rulecount("is", "stretchright") >= requirement then
                anymovers = true
                if unit:canmove(1, 0) then
                    unit:stretch(1, 0, true)
                    unit:move(1, 0)
                end
            end
        end
        requirement = requirement + 1
    end
    anymovers = true
    requirement = 1
    while anymovers do
        anymovers = false
        newmovement()
        for id, unit in pairs(units) do
            if unit:rulecount("is", "stretchup") >= requirement then
                anymovers = true
                if unit:canmove(0, -1) then
                    unit:stretch(0, 1)
                    unit:move(0, -1)
                end
            end
        end
        requirement = requirement + 1
    end
    anymovers = true
    requirement = 1
    while anymovers do
        anymovers = false
        newmovement()
        for id, unit in pairs(units) do
            if unit:rulecount("is", "stretchleft") >= requirement then
                anymovers = true
                if unit:canmove(-1, 0) then
                    unit:stretch(1, 0)
                    unit:move(-1, 0)
                end
            end
        end
        requirement = requirement + 1
    end
    anymovers = true
    requirement = 1
    while anymovers do
        anymovers = false
        newmovement()
        for id, unit in pairs(units) do
            if unit:rulecount("is", "stretchdown") >= requirement then
                anymovers = true
                if unit:canmove(0, 1) then
                    unit:stretch(0, 1, true)
                    unit:move(0, 1)
                end
            end
        end
        requirement = requirement + 1
    end
    anymovers = true
    requirement = 1
    while anymovers do
        anymovers = false
        newmovement()
        for id, unit in pairs(units) do
            if unit:rulecount("is", "shrinkright") >= requirement then
                anymovers = true
                unit:stretch(-1, 0)
                unit:move(1, 0)
            end
        end
        requirement = requirement + 1
    end
    anymovers = true
    requirement = 1
    while anymovers do
        anymovers = false
        newmovement()
        for id, unit in pairs(units) do
            if unit:rulecount("is", "shrinkup") >= requirement then
                anymovers = true
                unit:stretch(0, -1, true)
                unit:move(0, -1)
            end
        end
        requirement = requirement + 1
    end
    anymovers = true
    requirement = 1
    while anymovers do
        anymovers = false
        newmovement()
        for id, unit in pairs(units) do
            if unit:rulecount("is", "shrinkleft") >= requirement then
                anymovers = true
                unit:stretch(-1, 0, true)
                unit:move(-1, 0)
            end
        end
        requirement = requirement + 1
    end
    anymovers = true
    requirement = 1
    while anymovers do
        anymovers = false
        newmovement()
        for id, unit in pairs(units) do
            if unit:rulecount("is", "shrinkdown") >= requirement then
                anymovers = true
                unit:stretch(0, -1)
                unit:move(0, 1)
            end
        end
        requirement = requirement + 1
    end
    newmovement()
    for id, unit in pairs(units) do
        if unit:hasrule("is", "shift") then
            for i, v in ipairs(unit:collisions()) do
                v:rotate(unit.dir)
                v:move(dirs[unit.dir+1][1], dirs[unit.dir+1][2])
            end
        end
    end
end