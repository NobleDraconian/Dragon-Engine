--[[
	Required boilerplate functions for the engine.
]]

local BoilerPlate={}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Recurse
-- @Description : Returns all items in a folder/model/table and all of its subfolders/submodels/subtables.
--                If it is a table, it returns all items in a table and all items in all of its sub-tables.
-- @Params : Instance <Folder>/table "Root" - The folder/table to recurse through.
-- @Returns : table "Items" - A table containing all of the items.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BoilerPlate.Recurse(Root)
	local Items={}

	if typeof(Root)=="Instance" then --Root is an instance, make sure it is a model or a folder.

		if Root:IsA("Model") or Root:IsA("Folder") then --It's a folder or a model.
			for _,Object in pairs(Root:GetChildren()) do
				if Object:IsA("Folder") then --Recurse through this subfolder.
					local SubObjects=BoilerPlate.Recurse(Object)
					for _,SubObject in pairs(SubObjects) do
						table.insert(Items,SubObject)
					end
				else --Just a regular instance, add it to the items list.
					table.insert(Items,Object)
				end
			end
		end

	elseif typeof(Root)=="table" then --Root is a table.

		for _,Item in pairs(Root) do
			if typeof(Item)=="table" then --Recurse through this subtable.
				local SubItems=BoilerPlate.Recurse(Item)
				for _,SubItem in pairs(SubItems) do
					table.insert(Items,SubItem)
				end
			else --Just a regular value, add it to the items list.
				table.insert(Items,Item)
			end
		end

	end

	return Items
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RecurseFind
-- @Description : Returns all items of a given type in a folder/model and all of its subfolders/submodels.
--                If it is a table, it returns all items of a given type in a table and all items in all of its
--                sub-tables.
-- @Params : Instance <Folder>/table "Root" - The folder/table to recurse through.
--           Variant "ItemType" - The type of the item to search for.
-- @Returns : table "Items" - A table containing all of the found items.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BoilerPlate.RecurseFind(Root,ItemType)
	local Items={}

	if typeof(Root)=="Instance" then
		if Root:IsA("Folder") or Root:IsA("Model") then
			for _,Item in pairs(BoilerPlate.Recurse(Root)) do
				if Item:IsA(ItemType) then 
					table.insert(Items,Item) 
				end
			end
		end
	elseif typeof(Root)=="table" then
		for _,Item in pairs(BoilerPlate.Recurse(Root)) do
			if typeof(Item)==ItemType then 
				table.insert(Items,Item) 
			end
		end
	end

	return Items
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RecurseFilter
-- @Description : Returns all items that are NOT a given type in a folder/model and all of its subfolders/submodels.
--                If it is a table, it returns all items that are NOT a given type in a table and all items in all
--                of its sub-tables.
-- @Params : Instance <Folder>/table "Root" - The folder/table to recurse through.
--           Variant "ItemType" - The type of the item to filter.
-- @Returns : table "Items" - A table containing all of the filtered items.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BoilerPlate.RecurseFilter(Root,ItemType)
	local Items={}

	if typeof(Root)=="Instance" then
		if Root:IsA("Folder") or Root:IsA("Model") then
			for _,Item in pairs(BoilerPlate.Recurse(Root)) do
				if not Item:IsA(ItemType) then 
					table.insert(Items,Item) 
				end
			end
		end
	elseif typeof(Root)=="table" then
		for _,Item in pairs(BoilerPlate.Recurse(Root)) do
			if typeof(Item)~=ItemType then 
				table.insert(Items,Item) 
			end
		end
	end

	return Items
end

return BoilerPlate