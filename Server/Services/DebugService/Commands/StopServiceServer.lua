return function(Context,ServiceName)
	Context:Reply("Stopping service '"..ServiceName.."'...")

	if shared.DragonEngineServer[ServiceName]~=nil then
		local Success,Error=shared.DragonEngineServer:StopService(ServiceName)
		if Success then
			return "Service stopped successfully."
		else
			return "Service could not be stopped : "..Error
		end
	else
		return "Service '"..ServiceName.."' was not found."
	end
end