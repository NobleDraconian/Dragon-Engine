local function ConvertFolderToTable(Folder)
	local Tab={}
	local Keyname;
	local Value;

	for i,v in pairs(Folder:GetChildren()) do
		if v:IsA("Folder") then
			Value=ConvertFolderToTable(v)
			Keyname=v.Name
		else
			Keyname=v.Name
			Value=v.Value
		end
		Tab[Keyname]=Value
	end
	return Tab
end

return ConvertFolderToTable