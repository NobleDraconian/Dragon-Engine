local InstanceUtils={}

for _,Module in pairs(script:GetChildren()) do
	InstanceUtils[Module.Name]=require(Module)
end

return InstanceUtils