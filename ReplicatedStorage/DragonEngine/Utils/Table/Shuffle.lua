return function(Tab)
    local Rand=Random.new(tick())
    local size = #Tab
    for i = size, 1, -1 do
        local rand = Rand:NextInteger(1,size)
        Tab[i], Tab[rand] = Tab[rand], Tab[i]
    end
    return Tab
end