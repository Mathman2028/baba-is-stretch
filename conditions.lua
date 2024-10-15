conds = {
    lonely = function(unit)
        return #unit:collisions(nil, nil, true) == 0
    end
}