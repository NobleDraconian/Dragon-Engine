local function ConvertTableToFolder(Original_Table)
    local Folder=Instance.new('Folder')
	local Object;

    for Index,Value in pairs(Original_Table) do
        if typeof(Value)=="table" then
            Object=ConvertTableToFolder(Value)
        else
            if typeof(Value)=="number" then
                Object=Instance.new('NumberValue')
            end
            if typeof(Value)=="string" then
                Object=Instance.new('StringValue')
            end
            if typeof(Value)=="boolean" then
                Object=Instance.new('BoolValue')
            end
            if typeof(Value)=="Instance" then
                Object=Instance.new('ObjectValue')
            end
            Object.Value=Value
        end
        Object.Name=Index
        Object.Parent=Folder
    end
    return Folder
end

return ConvertTableToFolder