return function(Original_Table)
	local function CloneTable(t)
		local tab = {}
		for _,v in pairs(t) do
			if type(v) == "table" then
				tab[_] = CloneTable(v)
			else
				tab[_] = v;
			end
		end
		return tab
	end

	local NewTable=CloneTable(Original_Table)
		
	return NewTable
end