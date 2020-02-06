return function(Context,ServiceName)
	Context:Reply("Stopping service '"..ServiceName.."'...")

	if shared.DragonEngine.Services[ServiceName]~=nil then
		local Success,Error=shared.DragonEngine:StopService(ServiceName)
		if Success then
			return "Service stopped successfully."
		else
			return "Service could not be stopped : "..Error
		end
	else
		return "Service '"..ServiceName.."' was not found."
	end
end