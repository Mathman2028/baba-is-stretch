function shallowcopy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function deepcopy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[deepcopy(k, s)] = deepcopy(v, s) end
    return res
end

function split(text, delimiter)
    text = text .. delimiter
    local index = 0
    local result = {}
    while text:find(delimiter, index+1) ~= nil do
        local oldindex = index
        _, index = text:find(delimiter, index+1)
        table.insert(result, text:sub(oldindex+1, index-1))
    end
    return result
end