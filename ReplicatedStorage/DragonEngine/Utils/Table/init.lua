local Table={}

for _,Module in pairs(script:GetChildren()) do
	Table[Module.Name]=require(Module)
end

return Table