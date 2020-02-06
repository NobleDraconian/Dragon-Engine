return function(Context,ServiceName)
	Context:Reply("Starting service '"..ServiceName.."'...")

	if shared.DragonEngine.Services[ServiceName]~=nil then
		local Success,Error=shared.DragonEngine:StartService(ServiceName)
		if Success then
			return "Service started successfully."
		else
			return "Service could not be started : "..Error
		end
	else
		return "Service '"..ServiceName.."' was not found."
	end
end