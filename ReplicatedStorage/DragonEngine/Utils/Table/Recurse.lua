local function Recurse(Table)
    local Items={}

    for _,Item in pairs(Table) do
        if typeof(Item)=="table" then --Recurse through this subtable.
            local SubItems=Recurse(Item)

            for _,SubItem in pairs(SubItems) do
                table.insert(Items,SubItem)
            end
        else --Just a regular value, add it to the items list.
            table.insert(Items,Item)
        end
    end
    return Items
end

return Recurse