Rule = {}
function Rule:new(target, verb, action, conds, tags)
    print(target .. " " .. verb .. " " .. action)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.target = target
    o.verb = verb
    o.action = action
    o.conds = conds or {}
    o.tags = tags or {}
    table.insert(rules, o)
    ruleindex[target] = ruleindex[target] or {}
    ruleindex[verb] = ruleindex[verb] or {}
    ruleindex[action] = ruleindex[action] or {}
    table.insert(ruleindex[target], o)
    table.insert(ruleindex[verb], o)
    table.insert(ruleindex[action], o)
    return o
end

function meaning(unit)
    if unit:hasrule("is", "word") then
        return unit.name
    elseif unit.name:sub(1, 5) == "text_" then
        return unit.name:sub(6, -1)
    end
end

function parse()
    rules = {}
    ruleindex = {}
    Rule:new("text", "is", "push")
    local queue = {}
    for i, v in pairs(units) do
        local meaning = meaning(v)
        if meaning and typetable[meaning] == texttypes.verb then
            table.insert(queue, {base = v, current = v, right = true, needand = false, dir = "right", prefix = "", nounsfound = {}, conds = {}, prev = {}})
            table.insert(queue, {base = v, current = v, right = true, needand = false, dir = "down", prefix = "", nounsfound = {}, conds = {}, prev = {}})
        end
    end
    while #queue > 0 do
        state = table.remove(queue, 1)
        if state.right then
            local nextunits
            if state.dir == "right" then
                nextunits = state.current:collisions(state.current.x + 1, state.current.y, true)
            else
                nextunits = state.current:collisions(state.current.x, state.current.y + 1, true)
            end
            for i, v in ipairs(nextunits) do
                local meaning = meaning(v)
                if (not meaning) or state.prev[v.id] then goto continue end
                if state.needand and typetable[meaning] == texttypes.joiner then
                    local newstate = shallowcopy(state)
                    newstate.prev = shallowcopy(newstate.prev)
                    newstate.prev[v.id] = true
                    newstate.needand = false
                    newstate.current = v
                    newstate.prefix = ""
                    table.insert(queue, newstate)
                elseif not state.needand and typetable[meaning] == texttypes.modifier then
                    local newstate = shallowcopy(state)
                    newstate.prev = shallowcopy(newstate.prev)
                    newstate.prev[v.id] = true
                    newstate.current = v
                    newstate.prefix = meaning .. " "
                    table.insert(queue, newstate)
                elseif not state.needand and typetable[meaning] == texttypes.noun or typetable[meaning] == texttypes.property then
                    local newstate = shallowcopy(state)
                    newstate.prev = shallowcopy(newstate.prev)
                    newstate.prev[v.id] = true
                    newstate.current = newstate.base
                    newstate.action = state.prefix .. meaning
                    newstate.right = false
                    table.insert(queue, newstate)
                    newstate = shallowcopy(state)
                    newstate.prev = shallowcopy(newstate.prev)
                    newstate.prev[v.id] = true
                    newstate.needand = true
                    newstate.current = v
                    table.insert(queue, newstate)
                end
                ::continue::
            end
        else
            local nextunits
            if state.dir == "right" then
                nextunits = state.current:collisions(state.current.x - 1, state.current.y, true)
            else
                nextunits = state.current:collisions(state.current.x, state.current.y - 1, true)
            end
            local continuerule = false
            for i, v in ipairs(nextunits) do
                local meaning = meaning(v)
                if (not meaning) or state.prev[v.id] then goto continue2 end
                local newstate = shallowcopy(state)
                newstate.current = v
                newstate.prev = shallowcopy(newstate.prev)
                newstate.prev[v.id] = true
                if state.needand then
                    -- X BABA IS YOU
                    -- can be a condition, a prefix, a joiner, or a modifier
                    if typetable[meaning] == texttypes.modifier and not state.prefixesonly then
                        continuerule = true
                        newstate.nounsfound[#newstate.nounsfound] = meaning .. " " .. newstate.nounsfound[#newstate.nounsfound]
                        newstate.aftercond = true
                        newstate.needand = false
                        table.insert(queue, newstate)
                    elseif typetable[meaning] == texttypes.joiner then
                        continuerule = true
                        newstate.needand = false
                        table.insert(queue, newstate)
                    elseif typetable[meaning] == texttypes.prefix and not state.prefixesonly then
                        continuerule = true
                        table.insert(newstate.conds, {meaning, {}})
                        newstate.prefixesonly = true
                        table.insert(queue, newstate)
                    elseif typetable[meaning] == texttypes.infix and not state.nomoreconds then
                        continuerule = true
                        table.insert(newstate.conds, {meaning, state.nounsfound})
                        newstate.nounsfound = {}
                        newstate.needand = false
                        newstate.aftercond = true
                        table.insert(queue, newstate)
                    end
                else
                    if typetable[meaning] == texttypes.joiner and state.aftercond then
                        continuerule = true
                        newstate.nomoreconds = true
                        newstate.aftercond = false
                        table.insert(queue, newstate)
                    elseif typetable[meaning] == texttypes.noun then
                        continuerule = true
                        newstate.nounsfound = shallowcopy(newstate.nounsfound)
                        table.insert(newstate.nounsfound, meaning)
                        newstate.needand = true
                        table.insert(queue, newstate)
                    end
                end
                ::continue2::
            end
            if not continuerule then
                for i, v in ipairs(state.nounsfound) do
                    Rule:new(v, state.base.name:sub(6, -1), state.action, state.conds)
                end
            end
        end
    end
end