return function(Path)
	local Objects={}
	local ObjectReference=game
	
	for Object in string.gmatch(Path,"%a+") do
		if Object~="game" then
			table.insert(Objects,Object)
		end
	end
	
	for _,Object in next,Objects do
		ObjectReference=ObjectReference[Object]
	end
	
	return ObjectReference
end