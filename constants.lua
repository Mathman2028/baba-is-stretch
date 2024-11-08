keymapping = {up = "up", down = "down", left = "left", right = "right", space = "idle", z = "undo", f3 = "editor", t = "swap", tab = "outlines", l = "load", s = "save"}
dirnames = {up = {0, -1}, down = {0, 1}, left = {-1, 0}, right = {1, 0}, idle = {0, 0}}
dirnames2 = {right = 0, up = 1, left = 2, down = 3}
dirs = {{1, 0}, {0, -1}, {-1, 0}, {0, 1}}
texttypes = {noun = 0, verb = 1, property = 2, prefix = 3, modifier = 4, letter = 5, joiner = 6, infix = 7}
typetable = {
    baba = texttypes.noun,
    rock = texttypes.noun,
    wall = texttypes.noun,
    flag = texttypes.noun,
    keke = texttypes.noun,
    key = texttypes.noun,
    door = texttypes.noun,
    text = texttypes.noun,
    belt = texttypes.noun,
    water = texttypes.noun,
    lava = texttypes.noun,
    skull = texttypes.noun,
    ice = texttypes.noun,
    is = texttypes.verb,
    you = texttypes.property,
    push = texttypes.property,
    stop = texttypes.property,
    win = texttypes.property,
    move = texttypes.property,
    open = texttypes.property,
    shut = texttypes.property,
    shift = texttypes.property,
    defeat = texttypes.property,
    melt = texttypes.property,
    hot = texttypes.property,
    sink = texttypes.property,
    stretchright = texttypes.property,
    stretchup = texttypes.property,
    stretchleft = texttypes.property,
    stretchdown = texttypes.property,
    shrinkright = texttypes.property,
    shrinkup = texttypes.property,
    shrinkleft = texttypes.property,
    shrinkdown = texttypes.property,
    pull = texttypes.property,
    bind = texttypes.property,
    float = texttypes.property,
    fallright = texttypes.property,
    fallup = texttypes.property,
    fallleft = texttypes.property,
    falldown = texttypes.property,
    ["and"] = texttypes.joiner,
    ["not"] = texttypes.modifier,
    lonely = texttypes.prefix
}

objects = {
    baba = true,
    keke = true,
    rock = true,
    flag = true,
    wall = true,
    key = true,
    door = true,
    belt = true,
    water = true,
    lava = true,
    skull = true,
    ice = true,
}

colors = {
    baba = {0, 4},
    text_baba = {6, 1},
    keke = {1, 2},
    text_keke = {1, 2},
    rock = {2, 4},
    text_rock = {2, 4},
    flag = {3, 4},
    text_flag = {3, 4},
    wall = {1, 4},
    text_wall = {1, 4},
    key = {3, 4},
    text_key = {3, 4},
    door = {1, 2},
    text_door = {1, 2},
    belt = {4, 1},
    text_belt = {4, 1},
    water = {4, 4},
    text_water = {4, 4},
    lava = {2, 2},
    text_lava = {2, 2},
    skull = {1, 1},
    text_skull = {1, 1},
    ice = {4, 2},
    text_ice = {4, 2},
    text_is = {0, 4},
    text_you = {6, 1},
    text_and = {0, 4},
    text_push = {2, 4},
    text_stop = {3, 1},
    text_text = {6, 1},
    text_win = {3, 4},
    text_move = {3, 2},
    text_open = {3, 4},
    text_shut = {1, 2},
    text_shift = {4, 1},
    text_defeat = {1, 1},
    text_melt = {4, 2},
    text_hot = {2, 2},
    text_sink = {4, 4},
    text_not = {1, 2},
    text_stretchright = {3, 2},
    text_stretchup = {3, 2},
    text_stretchleft = {3, 2},
    text_stretchdown = {3, 2},
    text_shrinkright = {4, 2},
    text_shrinkup = {4, 2},
    text_shrinkleft = {4, 2},
    text_shrinkdown = {4, 2},
    text_pull = {2, 4},
    text_lonely = {1, 2},
    text_bind = {2, 4},
    text_float = {4, 2},
    text_fallright = {3, 2},
    text_fallup = {3, 2},
    text_fallleft = {3, 2},
    text_falldown = {3, 2},
}

directionality = {
    baba = true,
    keke = true,
    key = true,
    belt = true,
}